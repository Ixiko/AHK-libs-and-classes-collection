#SingleInstance force

a := new classAutoPath("msgbox")
while true {
	if a.ready || a.error
		break
	sleep 500
}

if a.error
	MsgBox("error")
if a.ready
	Run(a.path)


Class classAutoPath {
	path := ""
	ready := 0
	error := 0
	list := []
	listPrev := []
	endChar := "*"
	
	__New(onComplete := "", defaultPath := "", guiShowOpt := "w600") {
		;make sure provided path is valid
		if !DirExist(defaultPath)
			defaultPath := A_ScriptDir
		if SubStr(defaultPath, -1) != "\"			
			defaultPath := defaultPath . "\"
		this.defaultPath := defaultPath
		this.onComplete := onComplete
		
		;Gui stuff
		this.gui := GuiCreate(guiOpt)
		this.editBox := this.gui.Add("Edit", "w600", this.defaultPath)
		this.editBox.OnEvent("Change", ()=>this.editChanged())
		this.displayBox := this.gui.Add("Text", "+readonly -wrap r20 w600", "")
		this.btn := this.gui.add("Button", "Default w0", "OK")
		this.btn.OnEvent("Click", ()=>this.enterKey()) 
		this.gui.OnEvent("Close", ()=>this.onClose())
		this.gui.OnEvent("Escape", ()=>this.onClose())
		this.gui.Show(guiShowOpt)
		this.editBox.move("x5 w" (this.gui.ClientPos.w-10), true)
		this.displayBox.move("x5 w" (this.gui.ClientPos.w-10), true)
		
		ControlSend("{End}", "Edit1", "ahk_id " this.gui.hwnd)	;goto end of line
		
		;Setup keybind for "/" (auto-complete)
		HotKey("IfWinActive", "ahk_id " this.gui.hwnd)
		;HotKey("/", ()=>this.autoComplete())			;so / can be used as to pass parameters
		HotKey("Tab", ()=>this.autoComplete())
		HotKey("+Tab", ()=>this.autoComplete(-1))
		HotKey("If")

		;initial display
		this.mode := "FD"
		this.findFile(this.editBox.Value)
		this.listPrev := this.list.Clone()	
	}
	
	;When we complete
	onSubmit() {
		this.path := this.editBox.Value
		this.ready := 1
		this.cleanUp()
		this.gui.Destroy()
		func(this.onComplete).call(this.path)
	}
	
	;When we exit before a path/file is submitted by user
	onClose() {
		this.cleanUp
		this.gui.Destroy()
		this.error := 1
	}
	
	cleanUp() {		
		this.list := ""
		this.listPrev := ""
	}

	;When the content of editBox changes
	editChanged() {
		;loop files mode to "D" = show folders only.  Select trigger ("<") so it will get overwritten
		;when any changes occur
		if InStr(this.editBox.Value, "<") {
			this.mode := "D"
			SendMessage(0xb1, StrLen(this.editBox.Value) - 1, -1, "Edit1", "ahk_id " this.gui.hwnd)
		}
		;loop files mode to "F" = show files only.  Select trigger ("<") so it will get overwritten
		else if InStr(this.editBox.Value, ">") {
			this.mode := "F"
			SendMessage(0xb1, StrLen(this.editBox.Value) - 1, -1, "Edit1", "ahk_id " this.gui.hwnd)
		}
		;show both
		else
			this.mode := "FD"
		
		;Ending with " (double quote character) will make disable auto appending of * at the end
		if InStr(this.editBox.Value, '"') {
			this.endChar := ""
			;SendMessage(0xb1, StrLen(this.editBox.Value) - 1, -1, "Edit1", "ahk_id " this.gui.hwnd)
		} else
			this.endChar := "*"
		this.findFile(this.editBox.Value)
	}
	
	;User presses ENTER
	enterKey() {
		this.selectedText := ControlGetSelected("Edit1", "ahk_id " this.gui.hwnd)
		;No selection => user is submitting folder/file path
		if this.selectedText == ""
			this.onSubmit()
		;user has accepted autocomplete suggestion
		else {
			this.editChanged()
			ControlSend("{End}", "Edit1", "ahk_id " this.gui.hwnd)
			this.acceptedSuggestion := true
		}
	}

	;code for auto-completion
	autoComplete(direction := 1) {
		static index := 1
		static prevPath := ""

		;revert to defaultPath if editBox is empty
		if !Trim(this.editBox.Value, " `t`n`r") {
			this.editBox.Value := this.defaultPath
			this.findFile(this.editBox.Value)
			ControlSend("{End}", "Edit1", "ahk_id " this.gui.hwnd)
			return
		}
		
		;to see if user is still cycling through selections (without hitting enter)
		found := false
		for k, v in this.listPrev {
			if this.editBox.Value == v {
				index := k + 1 * direction
				if index > this.listPrev.Length()
					index := 1
				else if index < 1
					index := this.listPrev.Length()
				found := true
				break
			}	
		}
		
		;a folder change has occured (either user input or acceptance of autocomplete suggestion)
		;we're looking at a new folder here, start cycling suggestions from index=1
		if this.acceptedSuggestion || !found {
			prevPath := this.editBox.Value
			this.listPrev := []
			this.listPrev := this.list.Clone()
			index := 1	

			this.acceptedSuggestion := false
		}
		
		;if folder appears to be empty (or we have no rights to see its content),
		;don't make any suggestion and leave editBox.Value unchanged
		if this.listPrev.length() > 0 {		
			this.editChanged()
			this.editBox.Value := this.listPrev[index]
			SendMessage(0xb1, StrLen(prevPath), -1, "Edit1", "ahk_id " this.gui.hwnd)
			this.selectedText := ControlGetSelected("Edit1", "ahk_id " this.gui.hwnd)
			this.findFile(this.editBox.Value)
		}
	}

	;loop through files and determine if they are files or folders, put result in list array
	findFile(p) {
		this.displayBox.Value := ""
		this.list := []

		Loop Files p this.endChar, this.mode {
			If A_Index > 20
				break
			path := A_LoopFileFullPath
			displayName := A_LoopFileName
			if InStr(FileExist(path), "D") {
				path .= "\"
				displayName := "[" . displayName . "]"
			}
			this.displayBox.Value := this.displayBox.Value . (A_Index > 1 ? "`n" : "") . displayName 
			this.list.push(path)
		}
	}
}