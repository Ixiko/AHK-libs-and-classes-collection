/*

A class to grab the source code of a web page
By Clive Galway - evilc@evilc.com
License: WTFPL

ToDo:
* Test with Edge

*/

class SourceGrab {
	GuiWidth := 200
	
	__New(hotkey, duration := 2000){
		this.Duration := duration
		; Bind Hotkeys to class methods
		fn := this.DoGrab.Bind(this)
		hotkey, % hotkey, % fn
		
		; Set up confirmation dialog
		Gui, New, HwndHwnd -Border
		this.ConfirmationHwnd := hwnd
		Gui, Add, Text, % "hwndhwnd Center w" this.GuiWidth
		this.TitleHwnd := hwnd
	}
	
	DoGrab(){
		this.Source := ""
		; Save clipboard state
		this.Clipboard := Clipboard
		; Clear Clipboard
		clipboard := ""
		grabbed := 0
		; Get process name of active window
		WinGet, win, ProcessName, A
		; Check if active window is a browser
		if (win = "chrome.exe"){
			SetTitleMatchMode, 1
			; ============== CHROME ==============
			; Open ViewSource
			Send ^u
			; Wait for new window
			WinWait, ahk_exe chrome.exe,, 3
			WinGetTitle, new_win
			
			if (substr(new_win, 1, 12) = "view-source:"){
				; Saw source window pop up
				time := A_TickCount + 2000
				; Wait for source window to populate
				while (this.Source = "" && A_TickCount < time){
					; Select all
					Send ^a
					Sleep 100
					; Copy to clipboard
					Send ^c
					Sleep 100
					this.Source := Clipboard
				}
				; Close source window
				Send ^{f4}
			} else {
				return
			}
			
		} else if (win = "firefox.exe") {
			SetTitleMatchMode, 1
			; ============== FIREFOX ==============
			; Open ViewSource
			Send ^u
			; Wait for new window
			WinWait, Source of:,, 3
			if (ErrorLevel){
				; WinWait timed out
				return
			}
			; Saw source window pop up
			time := A_TickCount + 2000
			; Wait for source window to populate
			while (this.Source = "" && A_TickCount < time){
				; Select all
				Send ^a
				Sleep 100
				; Copy to clipboard
				Send ^c
				Sleep 100
				this.Source := Clipboard
			}
			; Close source window
			WinClose
		} else if (win = "iexplore.exe"){
			; ============== INTERNET EXPLORER ==============
			SetTitleMatchMode, RegEx
			; Open ViewSource
			Send ^u
			; Wait for new window
			WinWait, .* - Original Source$,, 3
			if (ErrorLevel){
				; WinWait timed out
				return
			}
			; Saw source window pop up
			time := A_TickCount + 2000
			; Wait for source window to populate
			while (this.Source = "" && A_TickCount < time){
				; Select all
				Send ^a
				Sleep 100
				; Copy to clipboard
				Send ^c
				Sleep 100
				this.Source := Clipboard
			}
			; Close source window
			WinClose
		}
		; Restore clipboard
		Clipboard := this.Clipboard
		this.ShowConfirmation()
	}
	
	; Sets the title of the Confirmation Dialog
	SetTitle(title){
		GuiControl,,% this.TitleHwnd, % title
	}
	
	; Prepends hwnd of Gui to Gui commands
	GuiCmd(cmd){
		return this.ConfirmationHwnd ":" cmd
	}
	
	; Shows the confirmation Gui
	ShowConfirmation(){
		; Show the Confirmation Dialog
		Gui, % this.GuiCmd("Show")
		fn := this.HideConfirmation.Bind(this)
		; Hide Confirmation Dialog after delay
		SetTimer, % fn, % "-" this.Duration
	}
	
	; Hides the confirmation Gui
	HideConfirmation(){
		; Hide the Confirmation Dialog
		Gui, % this.GuiCmd("Hide")
	}
}
