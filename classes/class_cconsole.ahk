; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=64724
; Author:	FredOoo
; Date:   	24.06.2019
; for:     	AHK_L

; A simple "Console.log" for debugging or developping time.

/*
	; AHK v1.1
	global Console := new CConsole
	Console.hotkey := "^+c"  ; to show the Console
	Console.log("Hello", "world", "Mina", "konnichiha", "Bonjour tout le monde")
	Console.show()  ; must use parentheses
	Console.log("Point", {x:100,y:200})
	;Hello world Mina konnichiha Bonjour tout le monde
	;Point {
	;	x: 100
	;	y: 200
	;}
*/

class CConsole
{
    ahkPID  :=
    ahkHWND :=

	__New( title := "Console" ) {
		HWND := WinExist( %title% " ahk_class Notepad" )
		if ( HWND ) {
			WinGet, PID, PID, % "ahk_id " HWND
			this.ahkPID  := "ahk_pid " PID
			this.ahkHWND := "ahk_id " HWND
			this.clear()
		} else {
			DetectHiddenWindows, On
			Run, Notepad,, Hide, PID
			this.ahkPID := "ahk_pid " PID
			WinWait, % this.ahkPID
			HWND := WinExist( this.ahkPID )
			if HWND=0
				return
			this.ahkHWND := "ahk_id " HWND
			WinMove, % this.ahkHWND,, 0, 0, % A_ScreenWidth/4, % A_ScreenHeight
			WinSetTitle, % this.ahkHWND,, %title%
			;WinActivate, % this.ahkHWND
			WinShow, % this.ahkHWND
		}
    }

	hotkey{
		set {
			show_bind := ObjBindMethod( this, "show" )
			Hotkey, % value, % show_bind
		}
	}

	log( texts* ) {
		if ( !WinExist( this.ahkHWND ) )
			return
		last := texts.Length()
		if last == 0
			Control, EditPaste, % "`r`n", Edit1, % this.ahkHWND
		for index, txt in texts {
			if (IsObject(txt)) {
				Control, EditPaste, % "{`r`n", Edit1, % this.ahkHWND
				for key, value in txt {
					Control, EditPaste, % "`t" key ": " value "`r`n", Edit1, % this.ahkHWND
				}
				Control, EditPaste, % "}`r`n", Edit1, % this.ahkHWND
			} else {
				sep := (index=last? "`r`n" : " ")
				Control, EditPaste, % txt sep, Edit1, % this.ahkHWND  ; ControlSendText ? ControlEditPaste
			}
		}
	}

	show() {
		WinSet, AlwaysOnTop, % true, % this.ahkHWND
		WinSet, AlwaysOnTop, % false, % this.ahkHWND
	}

	clear() {
		ControlSetText, Edit1,, % this.ahkHWND
	}

}