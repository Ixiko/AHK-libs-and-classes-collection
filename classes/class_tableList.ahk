/* Generic, flexible custom class for parsing lists.
	
	Throughout this documentation, "tl" will refer to an instance of this class.
	
	This class will read in a file (using tl.parseFile()) and return a multi-dimensional array:
		array[i]   = line i from the file
		array[i,j] = entry j from line i (split up by one or more tabs)
	
	Any line may be indented as desired:
		Spaces and tabs at the beginning of any line are ignored.
		Multiple tabs in a row within a row are treated as a single tab.
	
	Certain characters have special meaning when parsing the lines of a file. They include:
		At the start of a row:
			@ - Setting
				Any row that begins with one of these is assumed to be of the form @SettingName=value, where SettingName is one of the following:
					PlaceholderChar - the placeholder character to use
				Note that if any of these conflict with the settings passed programmatically, the programmatic settings win.
			
			; - Ignore[]
				If any of these characters are at the beginning of a line (ignoring any whitespace before that), the line is ignored and not added 
				to the array of lines.
				Override with settings["CHARS", "IGNORE"].
			
			( - Model
				You can have each line use string indices per value by creating a row that begins with this character. You can tab-separate this line to visually line up with your rows.
				Override with settings["CHARS", "MODEL"].
		
			[ - Mod
				A line which begins with this character will be processed as a mod (see mod section below for details).
		
			(no default) - Pass[]
				Any row that begins with one of these characters will not be broken up into multiple pieces, but will be a single-element array in the final output.
				Override with settings["CHARS", "PASS"].
			
		Within a "normal" row (not started with any of the special characters above):
			<No default> - Placeholder
				Having this allows you to have a truly empty value for a column in a given row (useful when optional columns are in the middle).
				Override with @PlaceholderChar or settings["CHARS", "PLACEHOLDER"].
			
			| - Multiple
				In a row that's being split, if an individual column within the row has this character, then that entry will be an array of the pipe-delimited values.
		
	These settings are also available:
		settings["FORMAT", "SEPARATE_MAP"]
			Associative array of CHAR => NAME.
			Rows that begin with a character that's a key (CHAR) in this array will be:
				Stored separately, can be retrieved with tl.getSeparateRows(NAME)
				Split like a normal row, but will always be numerically indexed
					This is true even if there is a model row, or the DEFAULT_INDICES setting is set.
			Example
				Settings
					settings["FORMAT", "SEPARATE_MAP"] := {")": "DATA_INDEX"}
					Model row
						(	NAME	ABBREV	DOACTION
				Input row
					)	A	B	C
				Output array (can get via tl.getSeparateRows("DATA_INDEX"))
					[1]	A
					[2]	B
					[3]	C
		
		settings["FORMAT", "DEFAULT_INDICES"]
			Numerically-indexed array that provides what string indices should be used. A model row will override this, and any data that falls outside of the given indices will be numerically indexed.
			Example
				Settings
					settings["FORMAT", "DEFAULT_INDICES"] := ["NAME", "ABBREV", "DOACTION"]
					(No model row)
				Input row
					A	B	C	D	E
				Output array (for the single row, stored in output)
					["NAME"]			A
					["ABBREV"]		B
					["DOACTION"]	C
					[4]				D
					[5]				E
		
	
	Mods are created by specially-formatted rows in the file that affect any rows that come after them in the file. The format for mod rows is as follows:
	
	1. Mod rows should always be wrapped in square brackets (start with [, end with ]).
	2. Mod rows may have any number of the following mod actions per line, separated by pipes (|):
			[] - Clear all mods
				A line with nothing but "[]" on it will clear all current mods added before that point in the file.
			
			r - Replace
				Replaces the part with the given string.
				Example
					Mods
						[r:zzz]
					Input
						AAA
					Result
						zzz
			
			b - Begin
				Adds the given string at the beginning of the part.
				Example
					Mods
						[b:eee]
					Input
						AAA
					Result
						eeeAAA
			
			e - End
				Adds the given string at the end of a part.
				Example
					Mods
						[e:eee]
					Input
						AAA
					Result
						AAAeee
			
			+x - Add label (x can be any number)
				Labels all following mods on the same row with the given numeric label, which can be used to remove them from executing on further lines further on with the - operator.
				Example: adds action1 and action2 as mods, both with a label of 5.
					[+5|action1|action2]	
			
			-x - Remove mods with label (x can be any number)
				Removes all currently active mods with this label. Typically the only thing on its row.
				Example: Removes all mods with the label 5.
					[-5]
			
	3. By default, all mods apply only to the first tab-separated entry in each row. 
			You can specify which entry in a row a mod should apply to by adding {x} before the mod action, where x can be any number.
			Example
				Mods
					[{3}b:AAA]
				Input
					W	X	Y	Z
				Result
					W
					X
					AAAY
					Z

*/

class TableList {
	; ==============================
	; == Public ====================
	; ==============================
	
	__New(fileName, settings = "") {
		this.parseFile(fileName, settings)
	}
	
	parseFile(fileName, settings = "") {
		if(!fileName || !FileExist(fileName))
			return ""
		
		this.init(settings)
		
		lines := fileLinesToArray(fileName)
		this.parseList(lines)
		
		return this.table
	}
	
	getTable() {
		return this.table
	}
	getRow(index) {
		return this.table[index]
	}
	
	getSeparateRows() {
		return this.separateRows
	}
	getSeparateRow(name) {
		return this.separateRows[name]
	}
	
	getIndexLabels() {
		return this.indexLabels
	}
	getIndexLabel(index) {
		return this.indexLabels[index]
	}
	
	; Return a table of all rows that have the allowed value in the filterColumn column.
	; Will only affect normal rows (i.e. what you get from tl.getTable())
	; column        - Which column to filter rows by.
	; allowedValue  - If a row has a value set for the given column, it must be set to this value to be included.
	; excludeBlanks - By default, rows with a blank value for the filter column will be included. Set this to true to exclude them.
	getFilteredTable(column, allowedValue = "", excludeBlanks = false) {
		; DEBUG.popup("column",column, "allowedValue",allowedValue, "excludeBlanks",excludeBlanks)
		if(!column)
			return ""
		
		filteredTable := []
		For i,currRow in this.table {
			if(this.shouldExcludeItem(currRow, column, allowedValue, excludeBlanks))
				Continue
			
			filteredTable.push(currRow)
		}
		
		return filteredTable
	}
	
	; Return a table of all rows that have the allowed value in the filterColumn.
	; However, return only one row per unique value of the uniqueColumn - a row with 
	; a blank filterColumn value will be dropped if there's another row with the same 
	; uniqueColumn value, with the correct allowedValue in the filterColumn column. 
	; If there are multiple rows with the same uniqueColumn, with the same filterColumn
	; value (either blank or allowedValue), the first one in the file wins.
	getFilteredTableUnique(uniqueColumn, filterColumn, allowedValue = "") {
		if(!uniqueColumn || !filterColumn)
			return ""
		
		uniqueAry := [] ; uniqueVal => {"Index": indexInTable, "FilterValue": filterVal}
		For i,currRow in this.table {
			if(this.shouldExcludeItem(currRow, filterColumn, allowedValue))
				Continue
			
			uniqueVal := currRow[uniqueColumn]
			filterVal := currRow[filterColumn]
			
			if(!uniqueAry[uniqueVal]) {
				uniqueAry[uniqueVal] := []
				uniqueAry[uniqueVal,"Index"]     := i
				uniqueAry[uniqueVal,"FilterVal"] := filterVal
			} else if( (filterVal = allowedValue) && (uniqueAry[uniqueVal]["FilterVal"] != allowedValue) ) {
				uniqueAry[uniqueVal,"Index"]     := i
				uniqueAry[uniqueVal,"FilterVal"] := filterVal
			}
		}
		
		filteredTable := []
		For i,ary in uniqueAry {
			index := ary["Index"]
			filteredTable.push(this.table[index])
		}
		
		return filteredTable
	}
	
	
	; ==============================
	; == Private ===================
	; ==============================
	
	init(settings) {
		this.mods  := []
		this.table := []
		
		this.chars       := mergeArrays(this.getDefaultChars(), settings["CHARS"])
		this.separateMap := mergeArrays([],                     settings["FORMAT", "SEPARATE_MAP"])
		this.indexLabels := mergeArrays([],                     settings["FORMAT", "DEFAULT_INDICES"])
	}
	
	; Special character defaults
	getDefaultChars() {
		chars := []
		chars["WHITESPACE"] := [ A_Space, A_Tab ]
		
		chars["MODSTART"] := "["
		chars["IGNORE"]   := [";"]
		chars["MODEL"]    := "("
		chars["SETTING"]  := "@"
		chars["PASS"]     := [] ; This one supports multiple entries
		
		chars["PLACEHOLDER"] := "" ; No default
		chars["MULTIENTRY"]  := "|"
		
		chars["MOD","ADD"]    := "+"
		chars["MOD","REMOVE"] := "-"
		
		return chars
	}
	
	parseList(lines) {
		delim := A_Tab
		currRow := []
		
		; Loop through and do work on them.
		For i,row in lines {
			row := dropWhitespace(row)
			
			; Reduce any sets of multiple delimiters in a row to a single one.
			Loop {
				if(!stringContains(row, delim delim))
					Break
				StringReplace, row, row, %delim%%delim%, %delim%
			}
			
			rowBits := StrSplit(row, delim)
			firstChar := SubStr(row, 1, 1)
			
			if(contains(this.chars["IGNORE"], firstChar) || firstChar = "") {
				; Ignore - it's either empty or a comment row.
			} else if(firstChar = this.chars["SETTING"]) {
				this.processSetting(SubStr(row, 2)) ; Strip off the @ at the beginning
				
			} else if(firstChar = this.chars["MODSTART"]) {
				this.updateMods(row)
			} else if(contains(this.chars["PASS"], firstChar)) {
				currRow := Object()
				currRow.push(row)
				this.table.push(currRow)
			} else if(this.separateMap.hasKey(firstChar)) { ; Separate characters mean that we split the row, but always store it numerically and separately from everything else.
				this.parseSeparateRow(firstChar, rowBits)
			} else if(firstChar = this.chars["MODEL"]) { ; Model row, causes us to use string subscripts instead of numeric per entry.
				this.parseModelRow(rowBits)
			} else {
				this.parseNormalRow(rowBits)
			}
			
		}
		
		; DEBUG.popup("TableList.parseList", "Finish", "State", this)
	}
	
	processSetting(settingString) {
		if(!settingString)
			return
		
		settingSplit := StrSplit(settingString, "=")
		name  := settingSplit[1]
		value := settingSplit[2]
		
		if(name = "PlaceholderChar")
			this.chars["PLACEHOLDER"] := value
	}

	; Update the given modifier string given the new one.
	updateMods(newRow) {
		label := 0
		
		; Strip off the square brackets.
		newRow := SubStr(newRow, 2, -1)
		
		; If it's just blank, all previous mods are wiped clean.
		if(newRow = "") {
			this.mods := Object()
		} else {
			; Check for a remove row label.
			; Assuming here that it will be the first and only thing in the mod row.
			if(SubStr(newRow, 1, 1) = this.chars["MOD","REMOVE"]) {
				remLabel := SubStr(newRow, 2)
				this.killMods(remLabel)
				label := 0
				
				return
			}
			
			; Split new into individual mods.
			newModsSplit := StrSplit(newRow, "|")
			For i,currMod in newModsSplit {
				firstChar := SubStr(currMod, 1, 1)
				
				; Check for an add row label.
				if(i = 1 && firstChar = this.chars["MOD","ADD"]) {
					label := SubStr(currMod, 2)
				} else {
					newMod := this.parseModLine(currMod, label)
					this.mods.push(newMod)
				}
			}
		}
	}

	; Takes a modifier string and constructs a mod object. Assumes no [] around it, and no special chars at start.
	parseModLine(modLine, label = 0) {
		origModLine := modLine
		
		; Check to see whether we have an explicit bit. Syntax: line starts with {bitLabel}
		firstChar := SubStr(modLine, 1, 1)
		if(firstChar = "{") {
			closeCurlyPos := InStr(modLine, "}")
			bit := SubStr(modLine, 2, closeCurlyPos - 2)
			
			modLine := SubStr(modLine, closeCurlyPos + 1)
		}
		
		operation := Substr(modLine, 1, 1)
		text := SubStr(modLine, 3) ; Ignore mod and colon at start
		
		newMod := new TableListMod(bit, operation, text, label)
		; DEBUG.popup("New mod", newMod, "Original mod line", origModLine, "Mod line without bit", modLine, "Operation", operation, "Text", text)
		
		return newMod
	}

	; Kill mods with the given label.
	killMods(killLabel = 0) {
		i := 1
		modsLen := this.mods.MaxIndex()
		Loop, %modsLen% {
			if(this.mods[i].label = killLabel) {
				this.mods.Remove(i)
				i--
			}
			i++
		}
	}
	
	; Row that starts with a special char, where we keep the row split but don't apply mods or labels.
	parseSeparateRow(char, rowBits) {
		if(!IsObject(this.separateRows))
			this.separateRows := []
		
		rowBits.RemoveAt(1) ; Get rid of the separate char bit.
		
		this.separateRows[this.separateMap[char]] := rowBits
	}
	
	; Function to deal with special model rows.
	parseModelRow(rowBits) {
		this.indexLabels := []
		
		rowBits.RemoveAt(1) ; Get rid of the "(" bit.
		
		For i,r in rowBits
			this.indexLabels[i] := r
	}
	
	parseNormalRow(rowAry) {
		if(IsObject(this.indexLabels))
			rowAry := this.applyIndexLabels(rowAry)
		
		currRow := this.applyMods(rowAry)
		
		; If any of the values were a placeholder, remove them now.
		For i,value in currRow.clone() ; Clone since we're deleting things.
			if(value = this.chars["PLACEHOLDER"])
				currRow.Delete(i)
		
		; Split up any entries that include the multi-entry character (pipe by default).
		For i,value in currRow
			if(stringContains(value, this.chars["MULTIENTRY"]))
				currRow[i] := StrSplit(value, this.chars["MULTIENTRY"])
		
		this.table.push(currRow)
	}
	
	applyIndexLabels(rowAry) {
		tempAry := []
		For i,value in rowAry {
			idxLabel := this.indexLabels[i]
			if(idxLabel)
				tempAry[idxLabel] := value
			else
				tempAry[i] := value
		}
		
		return tempAry
	}

	; Apply currently active string modifications to given row.
	applyMods(rowBits) {
		; If there aren't any mods, just split the row and send it on.
		if(this.mods.MaxIndex() != "") {
			; Apply the mods.
			For i,currMod in this.mods
				rowBits := currMod.executeMod(rowBits)
			
			return rowBits
		}
		
		return rowBits
	}
	
	; If a filter is given, exclude any rows that don't fit.
	shouldExcludeItem(currRow, column, allowedValue = "", excludeBlanks = false) {
		if(!column)
			return false
		
		valueToCompare := currRow[column]
		
		if(!excludeBlanks && !valueToCompare)
			return false
		
		if(valueToCompare = allowedValue)
			return false
		
		; Array case - multiple values in filter column.
		if(IsObject(valueToCompare) && contains(valueToCompare, allowedValue))
			return false
		
		return true
	}
	
	; Debug info
	debugName := "TableList"
	debugToString(debugBuilder) {
		debugBuilder.addLine("Chars",        this.chars)
		debugBuilder.addLine("Separate Map", this.separateMap)
		debugBuilder.addLine("Index labels", this.indexLabels)
		debugBuilder.addLine("Mods",         this.mods)
		debugBuilder.addLine("Table",        this.table)
	}
}