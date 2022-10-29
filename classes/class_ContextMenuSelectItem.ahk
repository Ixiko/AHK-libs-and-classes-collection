	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	;#Warn  ; Enable warnings to assist with detecting common errors.
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	
	
	q:: 
	SendInput {Appskey}
	hMenu := "Null"
	While hMenu = "FAIL" or hMenu = "Null" {
		SendMessage, 0x1E1,,,, ahk_class #32768 ;MN_GETHMENU := 0x1E1, 
		hMenu := ErrorLevel
		if (A_Index > 30)
			break
	}
	ContextMenuSelect(hMenu, "Paste") 
	return
	
	
	;based on:
	;https://www.autohotkey.com/boards/viewtopic.php?t=41170
	;GUIs via DllCall: get/set internal/external control text - AutoHotkey Community
	;https://autohotkey.com/boards/viewtopic.php?f=6&t=40514
	;context menu window messages: focus/invoke item - AutoHotkey Community
	;https://autohotkey.com/boards/viewtopic.php?f=5&t=39209
	
	ContextMenuSelect(hMenu, vNeedle := "Paste") {
	SendMessage, 0x1E1,,,, ahk_class #32768 ;MN_GETHMENU := 0x1E1
	hMenu := ErrorLevel
	vNeedle := StrReplace(vNeedle, "&")
		Loop, % DllCall("user32\GetMenuItemCount", Ptr,hMenu) {
			vID := DllCall("user32\GetMenuItemID", Ptr,hMenu, Int,A_Index-1, UInt)
			if (vID = 0) || (vID = 0xFFFFFFFF) ;-1
				continue
			vChars := DllCall("user32\GetMenuString", Ptr,hMenu, UInt,A_Index-1, Ptr,0, Int,0, UInt,0x400) + 1 ;Get text of the control 
			VarSetCapacity(vText, vChars << !!A_IsUnicode)
			DllCall("user32\GetMenuString", Ptr,hMenu, UInt,A_Index-1, Str,vText, Int,vChars, UInt,0x400) ;MF_BYPOSITION := 0x400
			if (StrReplace(vText, "&") = vNeedle) {
				PostMessage, 0x1F1, % A_Index-1, 0,, ahk_class #32768 ;MN_DBLCLK := 0x1F1
				break
			}
		}
	}