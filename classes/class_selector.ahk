/* Generic, flexible custom class for selecting from multiple choices, adding arbitrary input, and performing an action.
	
	This class will read in a file (using the TableList class) and turn it into a group of choices, which is then displayed to the user in a graphical list. The programmatic entry points are .selectGui() and .selectChoice().
	
	Certain characters have special meaning when parsing the lines of a file. They include:
		= - Window title
			This character starts a line that will be the title shown on the popup UI as a whole.
		
		# - Section title
			This character starts a line that will be shown as a section label in the UI (to group individual choices).
		
		| - Abbreviation delimiter
			You can give an individual choice multiple abbreviations that will work for the user, separated by this character. Only the first one will be displayed, however.
		
		* - Hidden
			Putting this character at the start of a line will hide that choice from the UI, but still allow it to be selected via its abbreviation.
		
		( - Model
			You can have more than the simple layout of NAME-ABBREV-ACTION by using a model row that begins with this character. This line is tab-separated in the same way as the choices, with each entry being the name for the corresponding column of each choice.
		
		) - Model Index
			This row corresponds to the model row, giving each of the named columns an index, which is the order in which the additional arbitrary fields in the UI (turned on using +ShowDataInputs, see settings below) will be shown. An index of 0 tells the UI not to show the field corresponding to that column at all.
		
		| - New column (in section title row)
			If this character is put at the beginning of a section title row (with a space on either side, such as "# | Title"), that title will force a new column in the UI.
		
		+ - Settings
			Lines which start with this character denote a setting that changes how the UI acts in some manner. They are always in the form "+Option=x", and include:
				ShowDataInputs
					If set to 1, the UI will show an additional input box on the UI for each piece defined by the model row (excluding NAME, ABBREV, and ACTION). Note that these will be shown in the order they are listed by the model row, unless a model index row is present, at which point it respects that.
				
				RowsPerColumn
					Set this to any number X to have the UI start a new column when it hits that many rows in the current column. Note that the current section title will carry over with a (2) if it's the first time it's been broken across columns, (3) if it's the second time, etc.
				
				MinColumnWidth
					Set this to any number X to have the UI be X pixels wide at a minimum (per column if multiple columns are shown). The UI might be larger if names are too long to fit.
				
				DefaultAction
					The default action that should be taken when this INI is used. Can be overridden by passing one into .select() directly.
				
				DefaultReturnColumn
					If the action to use is RET, this is the column that will be returned. Defaults to the DOACTION column.
	
	When the user selects their choice, the action passed in at the beginning will be evaluated as a function which receives a loaded SelectorRow object to perform the action on. See SelectorRow class for data structure.
	
	Once the UI is shown, the user can enter either the index or abbreviation for the choice that they would like to select. The user can give information to the popup in a variety of ways:
		Simplest case (+ShowDataInputs != 1, no model or model index rows):
			The user will only have a single input box, where they can add their choice and additional input using the arbitrary character (see below)
			Resulting SelectorRow object will have the name, abbreviation, and action. Arbitrary input is added to the end of the action.
		
		Model row, but +ShowDataInputs != 1
			The user still has a single input box.
			Resulting SelectorRow will have the various pieces in named subscripts of its data array, where the names are those from the model row. Note that name and abbreviation are still separate from the data array, and arbitrary additions are added to action, whether it is set or not.
		
		Model row, with +ShowDataInputs=1 (model index row optional)
			The user will see multiple input boxes, in the order listed in the input file, or in the order of the model index row if defined. The user can override the values defined by the selected choice for each of the columns shown before the requested action is performed.
			Resulting SelectorRow will have the various pieces in named subscripts of its data array, where the names are those from the model row. Note that name and abbreviation are still separate from the data array, and arbitrary additions are ignored entirely (as the user can use the additional inputs instead).
		
	The input that the user puts in the first (sometimes only) input box can also include some special characters:
		+ - Special actions
			These are special changes that can be made to the choice/UI at runtime, when the user is interacting with the UI. They include:
				e - edit
					Putting +e in the input will open the input file. If this is something like a txt or ini file, then it should open in a text editor.
				
				d - debug
					This will send the SelectorRow object to the function as usual, but with the isDebug flag set to true. Note that it's up to the called function to check this flag and send back debug info (stored in SelectorRow.debugResult) rather than actually performing the action, so if you add your own, be sure to include this check or else this option won't work. See selectorActions.ahk for more details.
					Selector will show that result (if given) using DEBUG.popup() (requires debug.ahk).
	
*/

; Wrapper functions
doSelect(filePath, actionType = "", iconPath = "") {
	s := new Selector(filePath)
	
	if(iconPath) {
		guiSettings := []
		guiSettings["Icon"] := iconPath
	}
	
	return s.selectGui(actionType, "", guiSettings)
}

; GUI Events
SelectorEscape() {
	SelectorClose()
}
SelectorClose() {
	Gui, Destroy
}
SelectorSubmit() {
	Gui, Submit ; Actually saves edit controls' values to respective GuiIn* variables
	Gui, Destroy
}

; Selector class which reads in and stores data from a file, and given an index, abbreviation or action, does that action.
class Selector {
	
	; ==============================
	; == Public ====================
	; ==============================
	
	__New(filePath = "", tableListSettings = "", filter = "") {
		this.chars          := this.getSpecialChars()
		this.guiSettings    := this.getDefaultGuiSettings()
		this.actionSettings := this.getDefaultActionSettings()
		
		tlSettings := mergeArrays(this.getDefaultTableListSettings(), tableListSettings)
		
		guiId := "Selector" getNextGuiId()
		Gui, %guiId%:Default ; GDB TODO if we want to truly run Selectors in parallel, we'll probably need to add guiId as a property and add it to all the Gui* calls.
		
		if(filePath) {
			this.filePath := this.findTrueFilePath(filePath)
			this.loadChoicesFromFile(tlSettings, filter)
		}
		
		; DEBUG.popup("Selector.__New", "Finish", "Filepath", this.filePath, "TableListSettings", this.tableListSettings, "Filter", this.filter, "State", this)
	}
	
	setChoices(choices) {
		this.choices := choices
	}
	
	selectGui(actionType = "", defaultData = "", guiSettings = "") {
		; DEBUG.popup("Selector.selectGui", "Start", "ActionType", actionType, "Default data", defaultData, "GUI Settings", guiSettings)
		
		if(actionType)
			this.actionSettings["ActionType"] := actionType
		if(defaultData)
			data := defaultData
		
		this.processGuiSettings(guiSettings)
		
		; Loop until we get good input, or the user gives up.
		while(rowToDo = "") {
			
			; Get the choice.
			userIn := this.launchSelectorPopup(data, dataFilled)
			setTrayIcon(this.originalIconPath) ; Restore the original tray icon before we start potentially quitting. Will be re-changed by launchSelectorPopup if it loops.
			
			; Blank input, we bail.
			if(!userIn && !dataFilled)
				return ""
			
			; User put something in the first box, which should come from the choices shown.
			if(userIn)
				rowToDo := this.parseChoice(userIn)
			
			; Blow in any data from the data input boxes.
			if(dataFilled && !rowToDo)
				rowToDo := new SelectorRow()
			if(IsObject(data)) {
				For label,value in data { ; Loop over the actual data given (as opposed to this.dataIndices) - this allows any data that came in via defaultData, but is not shown, to come along.
					if(value)
						rowToDo.data[label] := value
				}
			}
			
			; DEBUG.popup("User Input", userIn, "Row Parse Result", rowToDo, "Action type", this.actionSettings["ActionType"], "Data filled", dataFilled)
		}
		
		return this.doAction(rowToDo)
	}
	
	selectChoice(choice, actionType = "") {
		if(!choice)
			return ""
		
		if(actionType)
			this.actionSettings["ActionType"] := actionType
		
		this.hideErrors := true ; GDB TODO call this out in documentation.
		
		rowToDo := this.parseChoice(choice)
		if(!rowToDo)
			return ""
		
		return this.doAction(rowToDo)
	}
	
	
	; ==============================
	; == Private ===================
	; ==============================
	
	chars            := []    ; Special characters (see getSpecialChars)
	choices          := []    ; Visible choices the user can pick from (array of SelectorRow objects).
	hiddenChoices    := []    ; Invisible choices the user can pick from (array of SelectorRow objects).
	nonChoices       := []    ; Lines that will be displayed as titles, extra newlines, etc, but we won't search through.
	dataIndices      := []    ; Mapping from data field indices => data labels (column headers)
	guiSettings      := []    ; Settings related to the GUI popup we show
	actionSettings   := []    ; Settings related to what we do with the selection
	filePath         := ""    ; Where the .tl file lives if we're reading one in.
	originalIconPath := ""    ; What the current script's current icon is - used to restore it after we finish a gui popup (which takes an icon if given)
	hideErrors       := false ; Whether to suppress error popups (used by programmatic selections with no GUI)
	
	getSpecialChars() {
		chars := []
		
		chars["WINDOW_TITLE"]  := "="
		chars["SECTION_TITLE"] := "#"
		chars["NEW_COLUMN"]    := "|"
		chars["HIDDEN"]        := "*"
		chars["MODEL_INDEX"]   := ")"
		chars["SETTING"]       := "+"
		chars["COMMAND"]       := "+"
		
		chars["COMMANDS"] := []
		chars["COMMANDS", "EDIT"]  := "e"
		chars["COMMANDS", "DEBUG"] := "d"
		
		return chars
	}
	
	getDefaultGuiSettings() {
		settings := []
		
		settings["RowsPerColumn"]   := 99
		settings["MinColumnWidth"]  := 300
		settings["WindowTitle"]     := "Please make a choice by either number or abbreviation:"
		settings["ShowDataInputs"]  := false
		settings["IconPath"]        := ""
		settings["ExtraDataFields"] := ""
		
		return settings
	}
	
	getDefaultActionSettings() {
		settings := []
		
		settings["ReturnColumn"] := "DOACTION"
		settings["ActionType"]   := "RET"
		
		return settings
	}
	
	; Default settings to use with TableList object when parsing input file.
	getDefaultTableListSettings() {
		tableListSettings := []
		
		tableListSettings["CHARS"] := []
		tableListSettings["CHARS",  "PASS"]            := [this.chars["WINDOW_TITLE"], this.chars["SECTION_TITLE"], this.chars["SETTING"]]
		tableListSettings["FORMAT", "SEPARATE_MAP"]    := {this.chars["MODEL_INDEX"]: "DATA_INDEX"} 
		tableListSettings["FORMAT", "DEFAULT_INDICES"] := ["NAME", "ABBREV", "DOACTION"]
		
		return tableListSettings
	}
	
	findTrueFilePath(path) {
		if(!path)
			return ""
		
		; In the current folder, or full path
		if(FileExist(path))
			return path
		
		; If there's an Includes folder in the same directory, check in there as well.
		if(FileExist("Includes\" path))
			return "Includes\" path
		
		; Default folder for selector INIs
		if(FileExist(MainConfig.getFolder("AHK_ROOT") "\config\" path))
			return MainConfig.getFolder("AHK_ROOT") "\config\" path
		
		this.errPop("File doesn't exist", path)
		return ""
	}
	
	
	; Load the choices and other such things from a specially formatted file.
	loadChoicesFromFile(tableListSettings, filter) {
		this.choices       := [] ; Visible choices the user can pick from.
		this.hiddenChoices := [] ; Invisible choices the user can pick from.
		this.nonChoices    := [] ; Lines that will be displayed as titles, extra newlines, etc, but have no other significance.
		
		; DEBUG.popup("TableList Settings", tableListSettings)
		tl := new TableList(this.filePath, tableListSettings)
		if(filter)
			list := tl.getFilteredTable(filter["COLUMN"], filter["VALUE"], filter["EXCLUDE_BLANKS"])
		else
			list := tl.getTable()
		; DEBUG.popup("Filepath", this.filePath, "Parsed List", list, "Index labels", tl.getIndexLabels(), "Separate rows", tl.getSeparateRows())
		
		if(!IsObject(tl.getIndexLabels())) {
			this.errPop("Invalid settings", "No column index labels")
			return
		}
		
		; Special model index row that tells us how we should arrange data inputs.
		if(IsObject(tl.getSeparateRows())) {
			this.dataIndices := []
			For i,fieldIndex in tl.getSeparateRow("DATA_INDEX") {
				if(fieldIndex > 0) ; Filters out data columns we don't want fields for
					this.dataIndices[fieldIndex] := tl.getIndexLabel(i) ; Numeric, base-1 field index => column label (also the subscript in data array)
			}
		}
		
		; DEBUG.popup("Selector.loadChoicesFromFile", "Processed indices", "Index labels", tl.getIndexLabels(), "Separate rows", tl.getSeparateRows(), "Selector label indices", this.dataIndices)
		
		For i,currItem in list {
			; Parse this size-n array into a new SelectorRow object.
			currRow := new SelectorRow(currItem)
			if(currItem["NAME"])
				firstChar := SubStr(currItem["NAME"], 1, 1)
			else
				firstChar := SubStr(currItem[1], 1, 1) ; Only really populated for the non-normal rows.
			; DEBUG.popup("Curr Row", currRow, "First Char", firstChar)
			
			; Popup title.
			if(firstChar = this.chars["WINDOW_TITLE"]) {
				; DEBUG.popup("Title char", this.chars["WINDOW_TITLE"], "First char", firstChar, "Row", currRow)
				this.guiSettings["WindowTitle"] := SubStr(currItem[1], 2)
			
			; Options for the selector in general.
			} else if(firstChar = this.chars["SETTING"]) {
				settingString := SubStr(currRow.data[1], 2) ; Strip off the = at the beginning
				this.processSettingFromFile(settingString)
			
			; Special: add a section title to the list display.
			} else if(firstChar = this.chars["SECTION_TITLE"]) {
				; DEBUG.popup("Label char", this.chars["SECTION_TITLE"], "First char", firstChar, "Row", currRow)
				; Format should be #{Space}Title
				idx := 0
				if(this.choices.MaxIndex())
					idx := this.choices.MaxIndex()
				idx++ ; The next actual choice will be the first one under this header, so match that.
				
				this.nonChoices[idx] := SubStr(currItem[1], 3) ; If there are multiple headers in a row (for example when choices are filtered out) they should get overwritten in order here (which is correct).
				; DEBUG.popup("Just added nonchoice:", this.nonChoices[this.nonChoices.MaxIndex()], "At index", idx)
				
			; Invisible, but viable, choice.
			} else if(firstChar = this.chars["HIDDEN"]) {
				; DEBUG.popup("Hidden char", this.chars["HIDDEN"], "First char", firstChar, "Row", currRow)
				
				; DEBUG.popup("Hidden choice added", currRow)
				this.hiddenChoices.push(currRow)
			
			; Otherwise, it's a visible, viable choice!
			} else {
				; DEBUG.popup("Choice added", currRow)
				this.choices.push(currRow)
			}
		}
	}
	
	processSettingFromFile(settingString) {
		if(!settingString)
			return
		
		settingSplit := StrSplit(settingString, "=")
		name  := settingSplit[1]
		value := settingSplit[2]
		
		if(name = "ShowDataInputs")
			this.guiSettings["ShowDataInputs"] := (value = "1")
		else if(name = "RowsPerColumn")
			this.guiSettings["RowsPerColumn"] := value
		else if(name = "MinColumnWidth")
			this.guiSettings["MinColumnWidth"] := value
		else if(name = "DefaultAction")
			this.actionSettings["ActionType"] := value
		else if(name = "DefaultReturnColumn")
			this.actionSettings["ReturnColumn"] := value
	}
	
	processGuiSettings(settings) {
		if(settings["ShowDataInputs"]) ; This one can be set in the file too, so don't clear it if it's not passed.
			this.guiSettings["ShowDataInputs"] := settings["ShowDataInputs"]
		
		this.guiSettings["IconPath"] := this.findTrueFilePath(settings["Icon"])
		
		if(settings["ExtraDataFields"]) {
			baseLength := forceNumber(this.dataIndices.maxIndex())
			For i,label in settings["ExtraDataFields"]
				this.dataIndices[baseLength + i] := label
		}
	}
	
	; Generate the text for the GUI and display it, returning the user's response.
	launchSelectorPopup(ByRef data, ByRef dataFilled) {
		dataFilled := false
		if(!IsObject(data))
			data := Object()
		
		; Create and begin styling the GUI.
		this.originalIconPath := setTrayIcon(this.guiSettings["IconPath"])
		guiHandle := this.createSelectorGui()
		
		; GUI sizes
		marginLeft   := 10
		marginRight  := 10
		marginTop    := 10
		marginBottom := 10
		
		padIndexAbbrev := 5
		padAbbrevName  := 10
		padInputData   := 5
		padColumn      := 5
		
		widthIndex  := 25
		widthAbbrev := 50
		; (widthName and widthInputChoice/widthInputData exist but are calculated)
		
		heightLine  := 25
		heightInput := 24
	
		; Element starting positions (these get updated per column)
		xTitle       := marginLeft
		xIndex       := marginLeft
		xAbbrev      := xIndex  + widthIndex  + padIndexAbbrev
		xName        := xAbbrev + widthAbbrev + padAbbrevName
		xInputChoice := marginLeft
		
		xNameFirstCol := xName
		yCurrLine     := marginTop
		
		lineNum := 0
		columnNum := 1
		columnWidths := []
		
		For i,c in this.choices {
			lineNum++
			title := this.nonChoices[i]
			
			; Add a new column as needed.
			if(this.needNewColumn(title, lineNum, this.guiSettings["RowsPerColumn"])) {
				columnNum++
				
				xLastColumnOffset := columnWidths[columnNum - 1] + padColumn
				xTitle  += xLastColumnOffset
				xIndex  += xLastColumnOffset
				xAbbrev += xLastColumnOffset
				xName   += xLastColumnOffset
				
				if(!title) { ; We're not starting a new title here, so show the previous one, continued.
					titleInstance++
					title := currTitle " (" titleInstance ")"
					isContinuedTitle := true
				}
				
				lineNum := 1
				yCurrLine := marginTop
			}
			
			; Title rows.
			if(title) {
				if(!isContinuedTitle) {
					titleInstance := 1
					currTitle := title
				} else {
					isContinuedTitle := false
				}
				
				; Extra newline above titles, unless they're on the first line of a column.
				if(lineNum > 1) {
					yCurrLine += heightLine
					lineNum++
				}
				
				applyTitleFormat()
				Gui, Add, Text, x%xTitle% y%yCurrLine%, %title%
				colWidthFromTitle := getLabelWidthForText(title, "title" i) ; This must happen before we revert formatting, so that current styling (mainly bolding) is taken into account.
				clearTitleFormat()
				
				yCurrLine += heightLine
				lineNum++
			}
			
			name := c.data["NAME"]
			if(IsObject(c.data["ABBREV"]))
				abbrev := c.data["ABBREV"][1]
			else
				abbrev := c.data["ABBREV"]
			
			Gui, Add, Text, x%xIndex%  y%yCurrLine% w%widthIndex%   Right, % i ")"
			Gui, Add, Text, x%xAbbrev% y%yCurrLine% w%widthAbbrev%,        % abbrev ":"
			Gui, Add, Text, x%xName%   y%yCurrLine%,                       % name
			
			widthName := getLabelWidthForText(name, "name" i)
			colWidthFromName := widthIndex + padIndexAbbrev + widthAbbrev + padAbbrevName + widthName
			
			columnWidths[columnNum] := max(columnWidths[columnNum], colWidthFromTitle, colWidthFromName, this.guiSettings["MinColumnWidth"])
			
			yCurrLine += heightLine
			maxColumnHeight := max(maxColumnHeight, yCurrLine)
		}
		
		widthTotal := this.getTotalWidth(columnWidths, padColumn, marginLeft, marginRight)
		yInput := maxColumnHeight + heightLine ; Extra empty row before inputs.
		if(this.guiSettings["ShowDataInputs"])
			widthInputChoice := widthIndex + padIndexAbbrev + widthAbbrev ; Main edit control is same size as index + abbrev columns combined.
		else
			widthInputChoice := widthTotal - (marginLeft + marginRight)   ; Main edit control is nearly full width.
		static GuiInChoice
		GuiInChoice := "" ; Clear this to prevent bleed-over from previous uses. Must be on a separate line from the static declaration or it only happens once.
		Gui, Add, Edit, vGuiInChoice x%xInputChoice% y%yInput% w%widthInputChoice% h%heightInput% -E0x200 +Border
		
		if(this.guiSettings["ShowDataInputs"]) {
			numDataInputs := this.dataIndices.length()
			leftoverWidth  := widthTotal - xNameFirstCol - marginRight
			widthInputData := (leftoverWidth - ((numDataInputs - 1) * padInputData)) / numDataInputs
			
			xInput := xNameFirstCol
			For num,label in this.dataIndices {
				if(data[label]) ; Data given as default
					tempData := data[label]
				else               ; Data label
					tempData := label
				
				addInputField("GuiIn" num, xInput, yInput, widthInputData, heightInput, tempData)
				xInput += widthInputData + padInputData
			}
		}
		
		; Resize the GUI to show the newly added edit control row.
		heightTotal += maxColumnHeight + heightLine + heightInput + marginBottom ; maxColumnHeight includes marginTop, heightLine is for extra line between labels and inputs
		Gui, Show, h%heightTotal% w%widthTotal%, % this.guiSettings["WindowTitle"]
		
		; Focus the edit control.
		GuiControl, Focus,     GuiInChoice
		GuiControl, +0x800000, GuiInChoice
		
		; Wait for the user to submit the GUI.
		WinWaitClose, ahk_id %guiHandle%
		
		
		; == GUI waits for user to do something ==
		
		
		dataFilled := this.getDataFromGui(data)
		return GuiInChoice
	}
	
	createSelectorGui() {
		Gui, +LabelSelector  ; Allows use of LabelSelector* functions (custom label to override using default GuiClose, GuiSubmit, etc.)
		Gui, Color, 2A211C
		Gui, Font, s12 cBDAE9D
		Gui, +LastFound
		Gui, Add, Button, Hidden Default +gSelectorSubmit, SubmitSelector ; Hidden OK button for {Enter} submission.
		return WinExist()
	}
	
	needNewColumn(ByRef sectionTitle, lineNum, rowsPerColumn) {
		; Special character in sectionTitle forces a new column
		if(SubStr(sectionTitle, 1, 2) = this.chars["NEW_COLUMN"] " ") {
			sectionTitle := SubStr(sectionTitle, 3) ; Strip special character and space off, they've served their purpose.
			return true
		}
		
		; Out of space in the column
		if(lineNum > rowsPerColumn)
			return true
		
		; Technically have one left, but the current one is a title
		; (which would leave the title by itself at the end of a column)
		if(sectionTitle && ((lineNum + 1) > rowsPerColumn))
			return true
		
		return false
	}
	
	getTotalWidth(columnWidths, paddingBetweenColumns, leftMargin, rightMargin) {
		totalWidth := 0
		
		totalWidth += leftMargin
		Loop, % columnWidths.MaxIndex() {
			if(A_Index > 1)
				totalWidth += paddingBetweenColumns
			totalWidth += columnWidths[A_Index]
		}
		totalWidth += rightMargin
		
		return totalWidth
	}
	
	getDataFromGui(ByRef data) {
		if(!this.guiSettings["ShowDataInputs"])
			return false
		
		haveData := false
		For num,label in this.dataIndices {
			inputVal := GuiIn%num% ; GuiIn* variables are declared via assume-global mode in addInputField(), and populated by Gui, Submit.
			if(inputVal && (inputVal != label)) {
				haveData := true
				data[label] := inputVal
			}
		}
		
		; DEBUG.popup("Got data", data, "Have data flag", haveData)
		return haveData
	}
	
	; Function to turn the input into something useful.
	parseChoice(userIn) {
		commandCharPos := InStr(userIn, this.chars["COMMAND"])
		
		rowToDo := ""
		rest := SubStr(userIn, 2)
		
		; No input in main box, but others possibly filled out
		if(userIn = "") {
			return ""
		
		; Command choice - edit ini, debug, etc.
		} else if(commandCharPos = 1) {
			; DEBUG.popup("Got command", rest)
			commandChar := SubStr(rest, 1, 1)
			
			; Special case: +e is the edit action, which will open the current INI file for editing.
			if(commandChar = this.chars["COMMANDS", "EDIT"]) {
				this.actionSettings["ActionType"] := "DO"
				rowToDo := new SelectorRow()
				rowToDo.data["DOACTION"] := this.filePath
			
			; Special case: +d{Space}choice is debug action, which will copy/popup the result of the action.
			} else if(commandChar = this.chars["COMMANDS", "DEBUG"]) {
				; Peel off the d + space, and run it through this function again.
				StringTrimLeft, userIn, rest, 2
				rowToDo := this.parseChoice(userIn)
				if(rowToDo)
					rowToDo.isDebug := true
			
			; Otherwise, we don't know what this is.
			} else if(!isNum(rest)) {
				this.errPop("Invalid command input option")
			}
		
		; Otherwise, we search through the data structure by both number and shortcut and look for a match.
		} else {
			rowToDo := this.searchAllTables(userIn)
			
			if(!rowToDo)
				this.errPop("No matches found!")
		}
		
		; DEBUG.popup("Row to do", rowToDo)
		
		return rowToDo
	}

	; Search both given tables, the visible and the invisible.
	searchAllTables(input) {
		; Try the visible choices.
		out := this.searchTable(this.choices, input)
		if(out)
			return out
		
		; Try the invisible choices.
		out := this.searchTable(this.hiddenChoices, input)
		
		return out
	}

	; Function to search our generated table for a given index/shortcut.
	searchTable(table, input) {
		For i,t in table {
			if(input = i) ; They picked the index itself.
				return t.clone()
			
			; Abbreviation could be an array, so account for that.
			if(!IsObject(t.data["ABBREV"]) && (input = t.data["ABBREV"]))
				return t.clone()
			if(IsObject(t.data["ABBREV"]) && contains(t.data["ABBREV"], input))
				return t.clone()
		}
		
		return ""
	}

	; Function to do what it is we want done, then exit.
	doAction(rowToDo) {
		; DEBUG.popup("Action type", actionType, "Row to run", rowToDo, "Action", action)
		actionType := this.actionSettings["ActionType"]
		
		if(actionType = "RET")      ; Special case for simple return action, passing in the column to return.
			result := RET(rowToDo, this.actionSettings["ReturnColumn"])
		else if(isFunc(actionType)) ; Generic caller for many possible actions.
			result := %actionType%(rowToDo)
		else                        ; Error catch.
			this.errPop("Action not defined", actionType)
		
		; Debug case - show a popup with row info and copy it to the clipboard, don't do the actual action.
		if(rowToDo.isDebug) {
			result := ""
			if(!IsObject(rowToDo.debugResult))
				clipboard := rowToDo.debugResult
			DEBUG.popup("Debugged row", rowToDo)
		}
		
		return result
	}
	
	
	; Centralized MsgBox clone that respects the silencer flag.
	errPop(label, var) {
		if(!this.hideErrors) {
			if(!label)
				label := "Error"
			if(isFunc("DEBUG.popup"))
				DEBUG.popup(label, var)
			else
				MsgBox, % "Label: `n`t" label "`nText: `n`t" var
		}
	}
	
	; Debug info
	debugName := "Selector"
	debugToString(debugBuilder) {
		debugBuilder.addLine("Chars",              this.chars)
		debugBuilder.addLine("Data indices",       this.dataIndices)
		debugBuilder.addLine("GUI settings",       this.guiSettings)
		debugBuilder.addLine("Action settings",    this.actionSettings)
		debugBuilder.addLine("Filepath",           this.filePath)
		debugBuilder.addLine("Original icon path", this.originalIconPath)
		debugBuilder.addLine("Hide errors",        this.hideErrors)
		debugBuilder.addLine("Choices",            this.choices)
		debugBuilder.addLine("Hidden Choices",     this.hiddenChoices)
		debugBuilder.addLine("Non-Choices",        this.nonChoices)
	}
}