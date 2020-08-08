/*
	Title: _WindowHandlerEvent.ahk
		Helper classes to define constants for different events

	Author: 
		hoppfrosch@ahk4.me
		
	License: 
		This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
		
	Changelog:

		0.1.0 - [+] Initial
		
*/

class CONST_EVENT{
	; see: http://msdn.microsoft.com/en-us/library/windows/desktop/dd318066%28v=vs.85%29.aspx
	class SYSTEM {
		static SOUND             := 0x0001
		static ALERT             := 0x0002
		static FOREGROUND        := 0x0003
		static MENUSTART         := 0x0004
		static MENUEND           := 0x0005
		static MENUPOPUPSTART    := 0x0006
		static MENUPOPUPEND      := 0x0007
		static CAPTURESTART      := 0x0008
		static CAPTUREEND        := 0x0009
		static MOVESIZESTART     := 0x000A
		static MOVESIZEEND       := 0x000B
		static CONTEXTHELPSTART  := 0x000C
		static CONTEXTHELPEND    := 0x000D
		static DRAGDROPSTART     := 0x000E
		static DRAGDROPEND       := 0x000F
		static DIALOGSTART       := 0x0010
		static DIALOGEND         := 0x0011
		static SCROLLINGSTART    := 0x0012
		static SCROLLINGEND      := 0x0013
		static SWITCHSTART       := 0x0014
		static SWITCHEND         := 0x0015
		static MINIMIZESTART     := 0x0016
		static MINIMIZEEND       := 0x0017
		static DESKTOPSWITCH     := 0x0020
		static END               := 0x00FF
		static ARRANGMENTPREVIEW := 0x8016
	}
	
	class OBJECT {
		static CREATE               := 0x8000  ; hwnd + ID + idChild is created item
		static DESTROY              := 0x8001  ; hwnd + ID + idChild is destroyed item
		static SHOW                 := 0x8002  ; hwnd + ID + idChild is shown item
		static HIDE                 := 0x8003  ; hwnd + ID + idChild is hidden item
		static REORDER              := 0x8004  ; hwnd + ID + idChild is parent of zordering children
		static FOCUS                := 0x8005  ; hwnd + ID + idChild is focused item
		static SELECTION            := 0x8006  ; hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex
		static SELECTIONADD         := 0x8007  ; hwnd + ID + idChild is item added
		static SELECTIONREMOVE      := 0x8008  ; hwnd + ID + idChild is item removed
		static SELECTIONWITHIN      := 0x8009  ; hwnd + ID + idChild is parent of changed selected items
		static STATECHANGE          := 0x800A  ; hwnd + ID + idChild is item w/ state change
		static LOCATIONCHANGE       := 0x800B  ; hwnd + ID + idChild is moved/sized item
		static NAMECHANGE           := 0x800C  ; hwnd + ID + idChild is item w/ name change
		static DESCRIPTIONCHANGE    := 0x800D  ; hwnd + ID + idChild is item w/ desc change
		static VALUECHANGE          := 0x800E  ; hwnd + ID + idChild is item w/ value change
		static PARENTCHANGE         := 0x800F  ; hwnd + ID + idChild is item w/ new parent
		static HELPCHANGE           := 0x8010  ; hwnd + ID + idChild is item w/ help change
		static DEFACTIONCHANGE      := 0x8011  ; hwnd + ID + idChild is item w/ def action change
		static ACCELERATORCHANGE    := 0x8012  ; hwnd + ID + idChild is item w/ keybd accel change
		static INVOKED              := 0x8013  ; hwnd + ID + idChild is item invoked
		static TEXTSELECTIONCHANGED := 0x8014  ; hwnd + ID + idChild is item w? test selection change
		static CONTENTSCROLLED      := 0x8015
		static END                  := 0x80FF
	}
}

class CONST_HSHELL {
	static WINDOWCREATED        := 1
	static WINDOWDESTROYED      := 2
	static ACTIVATESHELLWINDOW  := 3
	static WINDOWACTIVATED      := 4
	static GETMINRECT           := 5
	static REDRAW               := 6
	static TASKMAN              := 7
	static LANGUAGE             := 8
	static SYSMENU              := 9
	static ENDTASK              := 10
	static ACCESSIBILITYSTATE   := 11
	static APPCOMMAND           := 12
	static WINDOWREPLACED       := 13
	static WINDOWREPLACING      := 14
	static HIGHBIT              := 0x8000
	static FLASH                := (6|0x8000)
	static RUDEAPPACTIVATED     := (4|0x8000)
}

; Simple helper function to translate system constants (Event-IDs) in human readable strings
Event2Str(id) {
	ret := id 
	if (id = CONST_EVENT.SYSTEM.SOUND)
		ret := "SYSTEM.SOUND"
	else if (id = CONST_EVENT.SYSTEM.ALERT)
		ret := "SYSTEM.ALERT"
	else if (id = CONST_EVENT.SYSTEM.FOREGROUND)
		ret := "SYSTEM.FOREGROUND"
	else if (id = CONST_EVENT.SYSTEM.MENUSTART)
		ret := "SYSTEM.MENUSTART"
	else if (id = CONST_EVENT.SYSTEM.MENUEND)
		ret := "SYSTEM.MENUEND"
	else if (id = CONST_EVENT.SYSTEM.MENUPOPUPSTART)
		ret := "SYSTEM.MENUPOPUPSTART"
	else if (id = CONST_EVENT.SYSTEM.MENUPOPUPEND)
		ret := "SYSTEM.MENUPOPUPEND"
	else if (id = CONST_EVENT.SYSTEM.CAPTURESTART)
		ret := "SYSTEM.CAPTURESTART"
	else if (id = CONST_EVENT.SYSTEM.CAPTUREEND)
		ret := "SYSTEM.CAPTUREEND"
	else if (id = CONST_EVENT.SYSTEM.MOVESIZESTART)
		ret := "SYSTEM.MOVESIZESTART"
	else if (id = CONST_EVENT.SYSTEM.MOVESIZEEND)
		ret := "SYSTEM.MOVESIZEEND"
	else if (id = CONST_EVENT.SYSTEM.CONTEXTHELPSTART)
		ret := "SYSTEM.CONTEXTHELPSTART"
	else if (id = CONST_EVENT.SYSTEM.CONTEXTHELPEND)
		ret := "SYSTEM.CONTEXTHELPEND"
	else if (id = CONST_EVENT.SYSTEM.DRAGDROPSTART)
		ret := "SYSTEM.DRAGDROPSTART"
	else if (id = CONST_EVENT.SYSTEM.DRAGDROPEND)
		ret := "SYSTEM.DRAGDROPEND"
	else if (id = CONST_EVENT.SYSTEM.DIALOGSTART)
		ret := "SYSTEM.DIALOGSTART"
	else if (id = CONST_EVENT.SYSTEM.DIALOGEND)
		ret := "SYSTEM.DIALOGEND"
	else if (id = CONST_EVENT.SYSTEM.SCROLLINGSTART)
		ret := "SYSTEM.SCROLLINGSTART"
	else if (id = CONST_EVENT.SYSTEM.SCROLLINGEND)
		ret := "SYSTEM.SCROLLINGEND"
	else if (id = CONST_EVENT.SYSTEM.SWITCHSTART)
		ret := "SYSTEM.SWITCHSTART"
	else if (id = CONST_EVENT.SYSTEM.SWITCHEND)
		ret := "SYSTEM.SWITCHEND"
	else if (id = CONST_EVENT.SYSTEM.MINIMIZESTART)
		ret := "SYSTEM.MINIMIZESTART"
	else if (id = CONST_EVENT.SYSTEM.MINIMIZEEND)
		ret := "SYSTEM.MINIMIZEEND"
	else if (id = CONST_EVENT.SYSTEM.DESKTOPSWITCH)
		ret := "SYSTEM.DESKTOPSWITCH"
	else if (id = CONST_EVENT.SYSTEM.END)
		ret := "SYSTEM.END"
	else if (id = CONST_EVENT.OBJECT.CREATE)
		ret := "OBJECT.CREATE"
	else if (id = CONST_EVENT.OBJECT.DESTROY)
		ret := "OBJECT.DESTROY"
	else if (id = CONST_EVENT.OBJECT.SHOW)
		ret := "OBJECT.SHOW"
	else if (id = CONST_EVENT.OBJECT.HIDE)
		ret := "OBJECT.HIDE"
	else if (id = CONST_EVENT.OBJECT.REORDER)
		ret := "OBJECT.REORDER"
	else if (id = CONST_EVENT.OBJECT.FOCUS)
		ret := "OBJECT.FOCUS"
	else if (id = CONST_EVENT.OBJECT.SELECTION)
		ret := "OBJECT.SELECTION"
	else if (id = CONST_EVENT.OBJECT.SELECTIONADD)
		ret := "OBJECT.SELECTIONADD"
	else if (id = CONST_EVENT.OBJECT.SELECTIONREMOVE)
		ret := "OBJECT.SELECTIONREMOVE"
	else if (id = CONST_EVENT.OBJECT.SELECTIONWITHIN)
		ret := "OBJECT.SELECTIONWITHIN"
	else if (id = CONST_EVENT.OBJECT.STATECHANGE)
		ret := "OBJECT.STATECHANGE"
	else if (id = CONST_EVENT.OBJECT.LOCATIONCHANGE)
		ret := "OBJECT.LOCATIONCHANGE"
	else if (id = CONST_EVENT.OBJECT.NAMECHANGE)
		ret := "OBJECT.NAMECHANGE"
	else if (id = CONST_EVENT.OBJECT.DESCRIPTIONCHANGE)
		ret := "OBJECT.DESCRIPTIONCHANGE"
	else if (id = CONST_EVENT.OBJECT.VALUECHANGE)
		ret := "OBJECT.VALUECHANGE"
	else if (id = CONST_EVENT.OBJECT.PARENTCHANGE)
		ret := "OBJECT.PARENTCHANGE"
	else if (id = CONST_EVENT.OBJECT.HELPCHANGE)
		ret := "OBJECT.HELPCHANGE"
	else if (id = CONST_EVENT.OBJECT.DEFACTIONCHANGE)
		ret := "OBJECT.DEFACTIONCHANGE"
	else if (id = CONST_EVENT.OBJECT.ACCELERATORCHANGE)
		ret := "OBJECT.ACCELERATORCHANGE"
	else if (id = CONST_EVENT.OBJECT.INVOKED)
		ret := "OBJECT.INVOKED"
	else if (id = CONST_EVENT.OBJECT.TEXTSELECTIONCHANGED)
		ret := "OBJECT.TEXTSELECTIONCHANGED"
	else if (id = CONST_EVENT.OBJECT.CONTENTSCROLLED)
		ret := "OBJECT.CONTENTSCROLLED"
	else if (id = CONST_EVENT.SYSTEM.ARRANGMENTPREVIEW)
		ret := "SYSTEM.ARRANGMENTPREVIEW"
	else if (id = CONST_EVENT.OBJECT.END)
		ret := "OBJECT.END"

	if (ret = "")
		ret := id
	return ret
}
