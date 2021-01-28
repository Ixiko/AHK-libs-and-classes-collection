;==================================================
;JEEGuiText.ahk
;use this function anywhere in a script
;to include this library at the bottom of the script
;==================================================

/*                                                	functions from other libraries:
;Acc_ ...
;DirExist
;JEE_DC ...
;JEE_StrRept
;SendMessage

;==================================================

;FUNCTIONS - CONSTANTS

;==================================================

;note: throughout this script the following constants are used:

;PROCESS_QUERY_INFORMATION := 0x400 ;PROCESS_VM_WRITE := 0x20
;PROCESS_VM_READ := 0x10 ;PROCESS_VM_OPERATION := 0x8
;e.g. JEE_DCOpenProcess(0x438, 0, vPID)
;IsWow64Process - The handle must have the PROCESS_QUERY_INFORMATION access right.
;WriteProcessMemory - The handle must have PROCESS_VM_WRITE and PROCESS_VM_OPERATION access to the process.
;ReadProcessMemory - The handle must have PROCESS_VM_READ access to the process.

;MEM_RESERVE := 0x2000 ;MEM_COMMIT := 0x1000
;PAGE_READWRITE := 0x4
;e.g. pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)

;MEM_RELEASE := 0x8000
;e.g. JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)

;note: the following 6 dll functions are used repeatedly
;when interacting with external windows/controls
;OpenProcess
;VirtualAllocEx
;WriteProcessMemory
;ReadProcessMemory
;VirtualFreeEx
;CloseHandle

;==================================================

;FUNCTIONS - INTRO

;==================================================

;notes:
;i: work on internal controls only
;r: require remote buffers on external controls (e.g. Edit/Static/Button/ListBox/ComboBox)
;a: uses Acc
;x: uses an AHK command/function

;s: single item selection
;m: multiple items selection
;z: multiple items (but none typically selected)

;note: any 'Get' function for controls with multiple items can return an object
;note: JEE_LVXXXText has columns not just items
;note: all functions get/set all text, as a variable, by default
;note: the user must set DetectHiddenWindows as appropriate, before using each function

;==================================================

;FUNCTIONS - SUMMARY

;==================================================

;function prefixes

;general
;Acc	Microsoft Active Accessibility (MSAA)
;Win	window

;control specific - one item
;Edit	Edit
;Static	Static
;Btn	Button
;PB	msctls_progress32
;TrB	msctls_trackbar32
;RE	RICHEDIT50W
;DTP	SysDateTimePick32
;MonthCal	SysMonthCal32
;HotkeyCtl	msctls_hotkey32
;LinkCtl	SysLink
;Sci	Scintilla

;control specific - multiple items
;LB	ListBox
;CB	ComboBox
;LV	SysListView32
;LVH	SysHeader32
;TV	SysTreeView32
;SB	msctls_statusbar32
;TB	ToolbarWindow32
;TC	SysTabControl32

;further
;CFD	Common File Dialog (older-style open/save as prompts)
;CID	Common Item Dialog (newer-style open/save as prompts)

;==================================================

;total functions (4+37+17+6+22=86)

;general (4)
;__ JEE_GetSelectedText(vWait:=3)
;__ JEE_AccCtlGetText(hWnd, vSep:="`n")
;__ JEE_WinGetText(hWnd)
;__ JEE_WinSetText(hWnd, vText)

;control specific - one item (37)
;[Edit,Static,Button,msctls_progress32,msctls_trackbar32,RICHEDIT50W,SysDateTimePick32,SysMonthCal32,msctls_hotkey32,SysLink,Scintilla]
;__ JEE_EditGetText(hCtl, vPos1:="", vPos2:="")
;__ JEE_EditSetText(hCtl, vText)
;__ JEE_EditPaste(hCtl, vText, vCanUndo:=1)
;__ JEE_EditGetTextSpecialPlace(hCtl)
;__ JEE_EditSetTextSpecialPlace(hCtl, vText)
;__ JEE_StaticGetText(hCtl)
;__ JEE_StaticSetText(hCtl, vText)
;__ JEE_BtnGetText(hCtl)
;__ JEE_BtnSetText(hCtl, vText)
;__ JEE_PBGetPos(hCtl)
;__ JEE_PBSetPos(hCtl, vPos)
;__ JEE_TrBGetPos(hCtl)
;__ JEE_TrBSetPos(hCtl, vPos)
;x_ JEE_REGetText(hCtl)
;r_ JEE_RESetText(hCtl, vText, vFlags:=0x0, vCP:=0x0)
;i_ JEE_REGetStream(hCtl, vFormat)
;i_ JEE_REGetStreamCallback(dwCookie, pbBuff, cb, pcb)
;i_ JEE_REGetStreamToFile(hCtl, vFormat, vPath)
;i_ JEE_REGetStreamToFileCallback(dwCookie, pbBuff, cb, pcb)
;i_ JEE_RESetStream(hCtl, vFormat, vAddr, vSize)
;i_ JEE_RESetStreamCallback(dwCookie, pbBuff, cb, pcb)
;i_ JEE_RESetStreamFromFile(hCtl, vFormat, vPath)
;i_ JEE_RESetStreamFromFileCallback(dwCookie, pbBuff, cb, pcb)
;r_ JEE_DTPGetDate(hCtl, vLen:=14)
;r_ JEE_DTPSetDate(hCtl, vDate)
;r_ JEE_MonthCalGetDate(hCtl, vLen:=14)
;r_ JEE_MonthCalSetDate(hCtl, vDate)
;a_ JEE_HotkeyCtlGetText(hCtl)
;x_ JEE_HotkeyCtlSetText(hCtl, vKeys)
;a_ JEE_LinkCtlGetText(hCtl, vDoGetFull:=1)
;x_ JEE_LinkCtlSetText(hCtl, vText)
;r_ JEE_SciGetText(hCtl, vEnc:="UTF-8")
;r_ JEE_SciSetText(hCtl, vText)
;r_ JEE_SciPaste(hCtl, vText, vSize:=-1)
;x_ JEE_SciGetTextAlt(hCtl, vEnc:="UTF-8")
;x_ JEE_SciSetTextAlt(hCtl, vText)
;x_ JEE_SciPasteAlt(hCtl, vText)

;control specific - multiple items (17)
;[ListBox,ComboBox,SysListView32,SysHeader32,SysTreeView32,msctls_statusbar32,ToolbarWindow32,SysTabControl32]
;_m JEE_LBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;_m JEE_LBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;_s JEE_CBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;_s JEE_CBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;rm JEE_LVGetText(hCtl, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="")
;rm JEE_LVSetText(hCtl, vText, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="")
;rs JEE_LVHGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;rs JEE_LVHSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;rs JEE_TVGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="", vDirPfx:="")
;rs JEE_TVSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;rz JEE_SBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;rz JEE_SBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;rz JEE_TBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;rz JEE_TBGetTextPool(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;rz JEE_TBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
;rs JEE_TCGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
;rs JEE_TCSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")

;control specific - multiple items further (6)
;__ JEE_LBInsStr(hCtl, vText, vPos:=-1)
;__ JEE_LBDelStr(hCtl, vPos:=-1)
;__ JEE_CBInsStr(hCtl, vText, vPos:=-1)
;__ JEE_CBDelStr(hCtl, vPos:=-1)
;__ JEE_TrayIconRename(hWnd, uID, vWinTitle)
;__ JEE_TrayIconModify(hWnd, uID, uMsg, hIcon, vWinTitle)

;further (22)
;[#32768,#32770,tooltips_class32]
;__ JEE_MenuGetText(hWndOrMenu:="", vSep:="`n", vOpt:="")
;__ JEE_MenuGetTextAll(hWndOrMenu:="", vSep:="`n", vOpt:="")
;__ JEE_MenuItemPosGetText(hMenu, vPos)
;__ JEE_MenuItemIDGetText(hMenu, vID)
;__ JEE_MenuItemPosSetText(hMenu, vText, vPos)
;__ JEE_MenuItemIDSetText(hMenu, vText, vID)
;__ JEE_CFDGetDir(hWnd)
;__ JEE_CFDGetPath(hWnd)
;__ JEE_CFDGetName(hWnd)
;__ JEE_CFDGetDirName(hWnd)
;__ JEE_CFDSetDir(hWnd, vDir)
;__ JEE_CFDSetPath(hWnd, vPath)
;__ JEE_CFDGetPathAlt(hWnd, vSep:="|")
;__ JEE_CFDChoosePath(hWnd, vPath)
;__ JEE_CIDGetDir(hWnd)
;__ JEE_CIDGetPath(hWnd, vSep:="|")
;__ JEE_CIDGetName(hWnd, vSep:="|")
;__ JEE_CIDSetDir(hWnd, vDir)
;__ JEE_CIDSetPath(hWnd, vPath)
;__ JEE_CIDChoosePath(hWnd, vPath)
;__ JEE_ToolTipGetText(hWnd)
;__ JEE_ToolTipSetText(hWnd, vText)

;==================================================

;maximum string lengths

;for the following 8 controls types:
;ListBox,ComboBox,SysListView32,SysHeader32,SysTreeView32,ToolbarWindow32,msctls_statusbar32,SysTabControl32
;based on investigations here:
;GUI: control types and maximum string lengths - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=5&t=40292

;- You can display 5460 characters fine (5641 if include the null) in all 8 control types, beyond that, some controls display blanks (listviews/listview headers/treeviews continue to display fine).
;- You can retrieve 65534 (65535 if include the null) characters from one of the items (parts) in a status bar control. The documentation suggests that this is the maximum number of characters you can get, but that you can set a larger number.
;- It is not clear what the actual limits of these control types are.

;==================================================

;information on getting/setting text and structs:

;although getting/setting the text of items
;often requires a struct, you usually only need to
;set the contents of the struct once,
;occasions where indexes in structs need to be
;changed for each item:
;get/set listview/treeview text
;(usually you specify the index in the PostMessage/SendMessage)

;LB_GETTEXTLEN, LB_GETTEXT
;LB_DELETESTRING, LB_INSERTSTRING

;CB_GETLBTEXTLEN, CB_GETLBTEXT
;CB_DELETESTRING, CB_INSERTSTRING

;LVM_GETITEMTEXTW (LVITEM) (iItem (row)/iSubItem (column) specified in struct)
;LVM_SETITEMTEXTW (LVITEM) (iItem (row)/iSubItem (column) specified in struct)

;HDM_GETITEMW (HDITEM)
;HDM_SETITEMW (HDITEM)

;TVM_GETITEMW (TVITEM) (hItem specified in struct)
;TVM_SETITEMW (TVITEM) (hItem specified in struct)

;SB_GETTEXTW
;SB_SETTEXTW

;[note: TBBUTTON structs are used to convert indexes to command IDs]
;TB_GETBUTTONTEXTW or TB_GETSTRINGW
;TB_SETBUTTONINFOW (TBBUTTONINFO)

;TCM_GETITEMW (TCITEM)
;TCM_SETITEMW (TCITEM)

;==================================================

;information on getting text and messages:

;when getting strings:
;LB_GETTEXTLEN - gives size of string
;CB_GETLBTEXTLEN - gives size of string
;LVM_GETITEMTEXTW - gives size of string
;HDM_GETITEMW - doesn't give size of string
;TVM_GETITEMW - doesn't give size of string
;SB_GETTEXT - gives size of string
;TB_GETBUTTONTEXTW / TB_GETSTRINGW - both give size of string
;TCM_GETITEMW - doesn't give size of string

;==================================================

;information on listbox controls:

;when determining the focused item/selected items:
;get focus (single-selection): LB_GETCURSEL/LB_GETCARETINDEX
;get selection (single-selection): LB_GETCURSEL/LB_GETCARETINDEX
;get focus (multi-selection): LB_GETCURSEL/LB_GETCARETINDEX
;get selection (multi-selection): LB_GETSELITEMS
*/

;for a list of role types see:
;AccViewer Basic - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=32039

;note: Acc seems able to get text from virtually all controls,
;although it appears that it can't get the raw data for
;secondary columns in AccViewer, although 'Description'
;contains a summary of the secondary columns

;hh_kwd_vlist (e.g. AutoHotkey.chm)
;MSTaskListWClass (e.g. taskbar)
JEEGuiText_Load() {
}


;==================================================
;                                             	FUNCTIONS - START
;==================================================
JEE_GetSelectedText(vWait:=3) {
	
	/*                              	EXAMPLE(s)
	
			; ;===============
			; ;e.g.
			; vText := JEE_GetSelectedText()
			; ;===============
			
			; ;===============
			; ;e.g. get selected text simple alternative
			; Clipboard := ""
			; SendInput, 
			; ClipWait, 3
			; if ErrorLevel
			; 
			; 	MsgBox, % "error: failed to retrieve clipboard text"
			; 	return
			; 
			; vText := Clipboard
			; ;===============
			
	*/
			
	WinGet, hWnd, ID, A
	ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		ControlGet, vText, Selected,, % vCtlClassNN, % "ahk_id " hWnd
	else
	{
		ClipSaved := ClipboardAll
		Clipboard := ""
		SendInput, ^c
		ClipWait, % vWait
		if ErrorLevel
		{
			ToolTip, % "ClipWait failed (" A_ThisHotkey ")"
			Clipboard := ClipSaved
			ClipSaved := ""
			Sleep, 1000
			ToolTip
			Exit ;terminate the thread that launched this function
		}
		vText := Clipboard
		Clipboard := ClipSaved
		ClipSaved := ""
	}
	return vText
}
JEE_AccCtlGetText(hWnd, vSep:="`n") {                                                              	;-- JEE_AccControlGetText
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; ;q::
			; MouseGetPos,,, hWnd, hCtl, 2
			; if (hCtl = "")
			; 	hCtl := hWnd
			; WinGetClass, vWinClass, % "ahk_id " hCtl
			; vText := JEE_AccCtlGetText(hCtl, "`r`n")
			; MsgBox, % "[" vWinClass "]`r`n" vText
			; return
			
	*/
	
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass ~= "^(ComboLBox|hh_kwd_vlist|ListBox|msctls_statusbar32|MSTaskListWClass|SysHeader32|SysLink|SysListView32|SysTabControl32|SysTreeView32|ToolbarWindow32)$")
	{
		oAcc := Acc_Get("Object", "4", 0, "ahk_id " hWnd)
		Loop, % oAcc.accChildCount
			try vOutput .= oAcc.accName(A_Index) vSep
		vOutput := SubStr(vOutput, 1, -StrLen(vSep))
	}
	else if (vWinClass = "#32768")
	{
		oAcc := Acc_Get("Object", "1", 0, "ahk_id " hWnd)
		Loop, % oAcc.accChildCount
			try vOutput .= oAcc.accName(A_Index) vSep
		vOutput := SubStr(vOutput, 1, -StrLen(vSep))
	}
	else if (vWinClass ~= "^(ComboBox|Edit|msctls_hotkey32|msctls_progress32|msctls_trackbar32|RICHEDIT50W|SysDateTimePick32)$")
	{
		oAcc := Acc_Get("Object", "4", 0, "ahk_id " hWnd)
		vOutput := oAcc.accValue
	}
	else if (vWinClass ~= "^(Button|Scintilla|Static|tooltips_class32)$")
	{
		oAcc := Acc_Get("Object", "4", 0, "ahk_id " hWnd)
		vOutput := oAcc.accName
	}
	else if (vWinClass = "SysMonthCal32")
	{
		oAcc := Acc_Get("Object", "4.4", 0, "ahk_id " hWnd)
		vOutput := oAcc.accName(0)
	}
	else
	{
		oAcc := Acc_ObjectFromWindow(hWnd)
		try vName := oAcc.accName(0)
		try vValue := oAcc.accValue(0)
		if !(vName = "") && !(vValue = "")
			vOutput := vName vSep vValue
		else if !(vName = "")
			vOutput := vName
		else if !(vValue = "")
			vOutput := vValue
	}
	oAcc := oChild := oChild2 := ""
	return vOutput
}
JEE_WinGetText(hWnd) {
	vChars := DllCall("user32\GetWindowTextLength", Ptr,hWnd) + 1
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	DllCall("user32\GetWindowText", Ptr,hWnd, Str,vText, Int,vChars)
	return vText
}
JEE_WinSetText(hWnd, vText) {
	DllCall("user32\SetWindowText", Ptr,hWnd, Str,vText)
}
JEE_EditGetText(hCtl, vPos1:="", vPos2:="") {
	vChars := 1+SendMessage(0xE, 0, 0,, "ahk_id " hCtl) ;WM_GETTEXTLENGTH := 0xE
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	SendMessage(0xD, vChars, &vText,, "ahk_id " hCtl) ;WM_GETTEXT := 0xD
	VarSetCapacity(vText, -1)
	if (vPos1 vPos2 = "")
		return vText

	if (vPos2 = -1)
		vPos2 := ""
	if !(vPos2 = "") || (vPos1 ~= "^\d")
	{
		if (vPos1 = "")
			vPos1 := 1
		if (vPos2 = "")
			vPos2 := StrLen(vText)
		return SubStr(vText, vPos1, vPos2-vPos1+1)
	}

	vCateg := vPos1
	VarSetCapacity(vPos1, 4, 0), VarSetCapacity(vPos2, 4, 0)
	SendMessage(0xB0, &vPos1, &vPos2,, "ahk_id " hCtl) ;EM_GETSEL := 0xB0
	vPos1 := NumGet(&vPos1, 0, "UInt"), vPos2 := NumGet(&vPos2, 0, "UInt")
	if (vPos1 = vPos2)
		return
	else if (vCateg = "sel")
		return SubStr(vText, vPos1+1, vPos2-vPos1+1)
	else if (vCateg = "abo") ;before selection
		return SubStr(vText, 1, vPos1)
	else if (vCateg = "bel") ;after + including selection
		return SubStr(vText, vPos1+1)
}
JEE_EditSetText(hCtl, vText) {
	SendMessage(0xC,, &vText,, "ahk_id " hCtl) ;WM_SETTEXT := 0xC
}
JEE_EditPaste(hCtl, vText, vCanUndo:=1) {
	vChars := StrLen(vText)+1
	SendMessage(0xC2, vCanUndo, &vText,, "ahk_id " hCtl) ;EM_REPLACESEL := 0xC2
}
JEE_EditGetTextSpecialPlace(hCtl) {                                                                     	;-- The secret life of GetWindowText – The Old New Thing
	
	;https://blogs.msdn.microsoft.com/oldnewthing/20030821-00/?p=42833
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
	{
		vChars := DllCall("user32\GetWindowTextLength", Ptr,hCtl) + 1
		VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
		DllCall("user32\GetWindowText", Ptr,hCtl, Str,vText, Int,vChars)
		return vText
	}
	vScript .= "vChars := DllCall(" Chr(34) "user32\GetWindowTextLength" Chr(34) ", Ptr," hCtl ") + 1"
	vScript .= "`r`n" "VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)"
	vScript .= "`r`n" "DllCall(" Chr(34) "user32\GetWindowText" Chr(34) ", Ptr," hCtl ", Str,vText, Int,vChars)"
	vScript .= "`r`n" "FileAppend, % vText, *"

	oShell := ComObjCreate("WScript.Shell")
	oExec := oShell.Exec(Chr(34) A_AhkPath Chr(34) " /ErrorStdOut *")
	oExec.StdIn.Write(vScript)
	oExec.StdIn.Close()
	vStdOut := oExec.StdOut.ReadAll()
	oShell := oExec := ""
	return vStdOut
}
JEE_EditSetTextSpecialPlace(hCtl, vText) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
	{
		DllCall("user32\SetWindowText", Ptr,hCtl, Str,vText)
		return
	}
	vText := StrReplace(vText, "``", "````")
	vText := StrReplace(vText, "`r", "``r")
	vText := StrReplace(vText, "`n", "``n")
	if !!SubStr(1,0) ;vIsV1
		vText := StrReplace(vText, Chr(34), Chr(34) Chr(34))
	else
		vText := StrReplace(vText, Chr(34), "``" Chr(34))
	vScript := "DllCall(" Chr(34) "user32\SetWindowText" Chr(34) ", Ptr," hCtl ", Str," Chr(34) vText Chr(34) ")"

	oShell := ComObjCreate("WScript.Shell")
	oExec := oShell.Exec(Chr(34) A_AhkPath Chr(34) " /ErrorStdOut *")
	oExec.StdIn.Write(vScript)
	oExec.StdIn.Close()
	oShell := oExec := ""
}
JEE_StaticGetText(hCtl) {                                                                                      	;-- same as EditGetText
	vChars := 1+SendMessage(0xE, 0, 0,, "ahk_id " hCtl) ;WM_GETTEXTLENGTH := 0xE
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	SendMessage(0xD, vChars, &vText,, "ahk_id " hCtl) ;WM_GETTEXT := 0xD
	VarSetCapacity(vText, -1)
	return vText
}
JEE_StaticSetText(hCtl, vText) {
	SendMessage(0xC,, &vText,, "ahk_id " hCtl) ;WM_SETTEXT := 0xC
}
JEE_BtnGetText(hCtl) {
	vChars := 1+SendMessage(0xE, 0, 0,, "ahk_id " hCtl) ;WM_GETTEXTLENGTH := 0xE
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	SendMessage(0xD, vChars, &vText,, "ahk_id " hCtl) ;WM_GETTEXT := 0xD
	VarSetCapacity(vText, -1)
	return vText
}
JEE_BtnSetText(hCtl, vText) {                                                                                	;-- same as EditSetText
	SendMessage(0xC,, &vText,, "ahk_id " hCtl) ;WM_SETTEXT := 0xC
}
JEE_PBGetPos(hCtl) {
	return SendMessage(0x408,,,, "ahk_id " hCtl) ;PBM_GETPOS := 0x408
}
JEE_PBSetPos(hCtl, vPos) {
	SendMessage(0x402, vPos,,, "ahk_id " hCtl) ;PBM_SETPOS := 0x402
}
JEE_TrBGetPos(hCtl) {
	return SendMessage(0x400,,,, "ahk_id " hCtl) ;TBM_GETPOS := 0x400
}
JEE_TrBSetPos(hCtl, vPos) {
	SendMessage(0x422,, vPos,, "ahk_id " hCtl) ;TBM_SETPOSNOTIFY := 0x422
}
JEE_REGetText(hCtl) {
	ControlGetText, vText,, % "ahk_id " hCtl
	return vText
}
JEE_RESetText(hCtl, vText, vFlags:=0x0, vCP:=0x0) {
	
	/*                              	EXAMPLE(s)
	
			; ;tested on WordPad (Windows XP and Windows 7 versions)
			; ;q:: ;RichEdit control - set text (RTF)
			; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
			; FormatTime, vDate,, HH:mm dd/MM/yyyy
			; vRtf := ""
			; JEE_RESetText(hCtl, vRtf)
			; return
			
	*/
	
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;ST_UNICODE := 0x8 ;ST_NEWCHARS := 0x4
	;ST_SELECTION := 0x2 ;ST_KEEPUNDO := 0x1
	;ST_DEFAULT := 0x0
	;CP_ACP := 0 ;Unicode (1200)
	VarSetCapacity(SETTEXTEX, 8)
	NumPut(vFlags, &SETTEXTEX, 0, "UInt") ;flags
	NumPut(vCP, &SETTEXTEX, 4, "UInt") ;codepage

	if ((vCP = 1200) = !!A_IsUnicode)
	{
		vSize := (StrLen(vText)+1) << !!A_IsUnicode
		pText := &vText
	}
	else
	{
		vSize := StrPut(vText, (vCP = 1200)?"UTF-16":"CP0")
		VarSetCapacity(vOutput, vSize)
		StrPut(vText, &vOutput, (vCP = 1200)?"UTF-16":"CP0")
		pText := &vOutput
	}

	if vIsLocal
		SendMessage(0x461, &SETTEXTEX, pText,, "ahk_id " hCtl) ;EM_SETTEXTEX := 0x461
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, 8+vSize, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &SETTEXTEX, 8, 0)
		JEE_DCWriteProcessMemory(hProc, pBuf+8, pText, vSize, 0)
		SendMessage(0x461, pBuf, pBuf+8,, "ahk_id " hCtl) ;EM_SETTEXTEX := 0x461
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_REGetStream(hCtl, vFormat) {                                                                         	;-- only works on internal controls
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; ;q::
			; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
			; MsgBox, % JEE_REGetStream(hCtl, 0x11)
			; MsgBox, % JEE_REGetStream(hCtl, 0x2)
			; return
			
	*/
	
	static  pFunc := RegisterCallback("JEE_REGetStreamCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
		return
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_USECODEPAGE := 0x20 ;SF_UNICODE := 0x10
	;SF_RTFNOOBJS := 0x3 ;SF_RTF := 0x2 ;SF_TEXT := 0x1
	vSize := A_PtrSize=8?20:12
	VarSetCapacity(EDITSTREAM, vSize, 0)
	NumPut(vFormat, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	SendMessage(0x44A, vFormat, &EDITSTREAM,, "ahk_id " hCtl) ;EM_STREAMOUT := 0x44A
	return JEE_REGetStreamCallback("Get", 0, 0, 0)
}
JEE_REGetStreamCallback(dwCookie, pbBuff, cb, pcb) {
	static vTextOut := ""
	if (cb > 0)
	{
		if (dwCookie & 0x10)
			vTextOut .= StrGet(pbBuff, cb/2, "UTF-16")
		else
			vTextOut .= StrGet(pbBuff, cb, "CP0")
		return 0
	}
	if (dwCookie = "Get")
	{
		vTemp := vTextOut
		vTextOut := ""
		return vTemp
	}
	return 1
}
JEE_REGetStreamToFile(hCtl, vFormat, vPath) {                                                   	;-- only works on internal controls
	static  pFunc := RegisterCallback("JEE_REGetStreamToFileCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
		return
	if !(oFile := FileOpen(vPath, "rw"))
		return 0
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_USECODEPAGE := 0x20 ;SF_UNICODE := 0x10
	;SF_RTFNOOBJS := 0x3 ;SF_RTF := 0x2 ;SF_TEXT := 0x1
	vSize := A_PtrSize=8?20:12
	VarSetCapacity(EDITSTREAM, vSize, 0)
	NumPut(oFile.__Handle, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	SendMessage(0x44A, vFormat, &EDITSTREAM,, "ahk_id " hCtl) ;EM_STREAMOUT := 0x44A
	oFile.Close()
	return
}
JEE_REGetStreamToFileCallback(dwCookie, pbBuff, cb, pcb) {
	static vTextOut := ""
	if (cb > 0)
		return !DllCall("kernel32\WriteFile", Ptr,dwCookie, Ptr,pbBuff, UInt,cb, Ptr,pcb, Ptr,0)
	return 1
}
JEE_RESetStream(hCtl, vFormat, vAddr, vSize) {                                                  	;-- only works on internal controls
	
	/*                              	EXAMPLE(s)
	
			; ;q::
			; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
			; FormatTime, vDate,, HH:mm dd/MM/yyyy
			; vRtf := ""
			; VarSetCapacity(vRtf2, 100, 0)
			; vSize := StrPut(vRtf, &vRtf2, "CP0")
			; JEE_RESetStream(hCtl, 0x4002, &vRtf2, vSize)
			; return
			
	*/
	
	static pFunc := RegisterCallback("JEE_RESetStreamCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
		return
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_USECODEPAGE := 0x20 ;SF_UNICODE := 0x10
	;SF_RTFNOOBJS := 0x3 ;SF_RTF := 0x2 ;SF_TEXT := 0x1
	;UTF-16 (1200)

	VarSetCapacity(EDITSTREAM, A_PtrSize=8?20:12, 0)
	NumPut(vAddr, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	JEE_RESetStreamCallback("Init", vSize, 0, 0)
	return SendMessage(0x449, vFormat, &EDITSTREAM,, "ahk_id " hCtl) ;EM_STREAMIN := 0x449 ;chars read (any CRLFs are counted as single characters)
}
JEE_RESetStreamCallback(dwCookie, pbBuff, cb, pcb) {
	static vRemain, vOffset
	if (dwCookie = "Init")
	{
		vRemain := pbBuff, vOffset := 0
		return 0
	}
	if (vRemain <= cb)
	{
		DllCall("kernel32\RtlMoveMemory", Ptr,pbBuff, Ptr,dwCookie+vOffset, UPtr,vRemain)
		NumPut(vRemain, pcb+0, 0, "Ptr")
		vOffset += vRemain, vRemain := 0
		return 0
	}
	else
	{
		DllCall("kernel32\RtlMoveMemory", Ptr,pbBuff, Ptr,dwCookie+vOffset, UPtr,cb)
		NumPut(cb, pcb+0, 0, "Ptr")
		vOffset += cb, vRemain -= cb
		return 0
	}
}
JEE_RESetStreamFromFile(hCtl, vFormat, vPath) {                                               	;-- only works on internal controls
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; ;q::
			; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
			; vPath := A_Desktop "\MyFile.rtf"
			; JEE_RESetStreamFromFile(hCtl, 0x4002, vPath)
			; return
			
	*/
	
	static pFunc := RegisterCallback("JEE_RESetStreamFromFileCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if !(vPID = vScriptPID)
		return
	;SFF_SELECTION := 0x8000 ;SFF_PLAINRTF := 0x4000
	;SF_USECODEPAGE := 0x20 ;SF_UNICODE := 0x10
	;SF_RTFNOOBJS := 0x3 ;SF_RTF := 0x2 ;SF_TEXT := 0x1
	;UTF-16 (1200)

	if !(oFile := FileOpen(vPath, "r"))
		return 0
	VarSetCapacity(EDITSTREAM, A_PtrSize=8?20:12, 0)
	NumPut(oFile.__Handle, &EDITSTREAM, 0, "UPtr") ;dwCookie
	NumPut(pFunc, &EDITSTREAM, A_PtrSize=8?12:8, "Ptr") ;pfnCallback
	vChars := SendMessage(0x449, vFormat, &EDITSTREAM,, "ahk_id " hCtl) ;EM_STREAMIN := 0x449
	oFile.Close()
	return vChars ;chars read (any CRLFs are counted as single characters)
}
JEE_RESetStreamFromFileCallback(dwCookie, pbBuff, cb, pcb) {
	return !DllCall("kernel32\ReadFile", Ptr,dwCookie, Ptr,pbBuff, UInt,cb, Ptr,pcb, Ptr,0)
}
JEE_DTPGetDate(hCtl, vLen:=14) {
	if !(vLen=14) && !RegExMatch(vLen, "^(4|6|8|10|12|14|17)$")
		return
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)
	vSize := 16

	VarSetCapacity(SYSTEMTIME, 16, 0)
	;GDT_VALID := 0
	if vIsLocal
		SendMessage(0x1001, 0, &SYSTEMTIME,, "ahk_id " hCtl) ;DTM_GETSYSTEMTIME := 0x1001
	else
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		SendMessage(0x1001, 0, pBuf,, "ahk_id " hCtl) ;DTM_GETSYSTEMTIME := 0x1001
		JEE_DCReadProcessMemory(hProc, pBuf, &SYSTEMTIME, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	Loop, 7
		if !(A_Index = 3)
			vDate .= Format("{:02}", NumGet(&SYSTEMTIME, A_Index*2-2, "UShort"))
	vDate .= Format("{:03}", NumGet(&SYSTEMTIME, 14, "UShort"))
	return SubStr(vDate, 1, vLen)
}
JEE_DTPSetDate(hCtl, vDate) {
	vLen := StrLen(vDate)
	if !RegExMatch(vLen, "^(4|6|8|10|12|14|17)$")
		return
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if (vLen < 17)
		vDate .= SubStr(19990101000000000, vLen+1) ;17 characters: Y M D H M S M
	vDate := RegExReplace(vDate, "(....)(..)(..)(..)(..)(..)(...)", "$1-$2-0-$3-$4-$5-$6-$7")
	vSize := 16
	VarSetCapacity(SYSTEMTIME, 16, 0)
	Loop, Parse, vDate, % "-"
		NumPut(A_LoopField, &SYSTEMTIME, (A_Index*2)-2, "UShort")

	;GDT_VALID := 0
	if vIsLocal
		SendMessage(0x1002, 0, &SYSTEMTIME,, "ahk_id " hCtl) ;DTM_SETSYSTEMTIME := 0x1002
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &SYSTEMTIME, vSize, 0)
		SendMessage(0x1002, 0, pBuf,, "ahk_id " hCtl) ;DTM_SETSYSTEMTIME := 0x1002
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_MonthCalGetDate(hCtl, vLen:=14) {
	if !(vLen=14) && !RegExMatch(vLen, "^(4|6|8|10|12|14|17)$")
		return
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	ControlGet, vCtlStyle, Style,,, % "ahk_id " hCtl
	if (vCtlStyle & 0x2) ;MCS_MULTISELECT := 0x2
		vSize := 32, vMsg := 0x1005 ;MCM_GETSELRANGE := 0x1005
	else
		vSize := 16, vMsg := 0x1001 ;MCM_GETCURSEL := 0x1001

	VarSetCapacity(ArraySYSTEMTIME, vSize, 0)
	if vIsLocal
		SendMessage(vMsg, 0, &ArraySYSTEMTIME,, "ahk_id " hCtl) ;MCM_GETCURSEL := 0x1001 ;MCM_GETSELRANGE := 0x1005
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		SendMessage(vMsg, 0, pBuf,, "ahk_id " hCtl) ;MCM_GETCURSEL := 0x1001 ;MCM_GETSELRANGE := 0x1005
		JEE_DCReadProcessMemory(hProc, pBuf, &ArraySYSTEMTIME, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	Loop, 7
		if !(A_Index = 3)
			vDate .= Format("{:02}", NumGet(&ArraySYSTEMTIME, A_Index*2-2, "UShort"))
	vDate .= Format("{:03}", NumGet(&ArraySYSTEMTIME, 14, "UShort"))
	return SubStr(vDate, 1, vLen)
}
JEE_MonthCalSetDate(hCtl, vDate) {
	vLen := StrLen(vDate)
	if !RegExMatch(vLen, "^(4|6|8|10|12|14|17)$")
		return
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	ControlGet, vCtlStyle, Style,,, % "ahk_id " hCtl
	if (vCtlStyle & 0x2) ;MCS_MULTISELECT := 0x2
		vSize := 32, vMsg := 0x1006 ;MCM_SETSELRANGE := 0x1006
	else
		vSize := 16, vMsg := 0x1002 ;MCM_SETCURSEL := 0x1002

	if (vLen < 17)
		vDate .= SubStr(19990101000000000, vLen+1) ;17 characters: Y M D H M S M
	vDate := RegExReplace(vDate, "(....)(..)(..)(..)(..)(..)(...)", "$1-$2-0-$3-$4-$5-$6-$7")
	VarSetCapacity(ArraySYSTEMTIME, vSize, 0)
	Loop, Parse, vDate, % "-"
	{
		NumPut(A_LoopField, &ArraySYSTEMTIME, (A_Index*2)-2, "UShort")
		if (vCtlStyle & 0x2)
			NumPut(A_LoopField, &ArraySYSTEMTIME, 16+(A_Index*2)-2, "UShort")
	}

	if vIsLocal
		SendMessage(vMsg, 0, &ArraySYSTEMTIME,, "ahk_id " hCtl) ;MCM_SETCURSEL := 0x1002 ;MCM_SETSELRANGE := 0x1006
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &ArraySYSTEMTIME, vSize, 0)
		SendMessage(vMsg, 0, pBuf,, "ahk_id " hCtl) ;MCM_SETCURSEL := 0x1002 ;MCM_SETSELRANGE := 0x1006
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_HotkeyCtlGetText(hCtl) {
	oAcc := Acc_Get("Object", "4", 0, "ahk_id " hCtl)
	vText := oAcc.accValue(0)
	oAcc := ""
	return vText
}
JEE_HotkeyCtlSetText(hCtl, vKeys) {                                                                    	;-- note: the hotkey control doesn't detect the Win key
	ControlSend,, % vKeys, % "ahk_id " hCtl
}
JEE_LinkCtlGetText(hCtl, vDoGetFull:=1) {
	if vDoGetFull
	{
		ControlGetText, vText,, % "ahk_id " hCtl
		return vText
	}
	oAcc := Acc_ObjectFromWindow(hCtl)
	vText := oAcc.accName(0)
	oAcc := ""
	return vText
}
JEE_LinkCtlSetText(hCtl, vText) {
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; ;q::
			; ControlGet, hCtl, Hwnd,, SysLink1, A
			; vText = <a href="https://autohotkey.com/">https://autohotkey.com/</a>
			; JEE_LinkCtlSetText(hCtl, vText)
			; return
			
	*/
	
	ControlSetText,, % vText, % "ahk_id " hCtl
}
JEE_SciGetText(hCtl, vEnc:="UTF-8") {                                                                 	;-- JEE_ScintillaGetText
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; ;q::
			; ControlGet, hCtl, Hwnd,, Scintilla1, A
			; MsgBox, % JEE_SciGetText(hCtl)
			; MsgBox, % JEE_SciGetText(hCtl, "CP0")
			; MsgBox, % JEE_SciGetText(hCtl, "UTF-16")
			; return
			; ;===============
			
	*/
	
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vSize := 1+SendMessage(2006, 0, 0,, "ahk_id " hCtl) ;SCI_GETLENGTH := 2006 ;returns size of UTF-8 buffer in bytes (not chars)
	VarSetCapacity(vText, vSize, 0)

	if vIsLocal
		SendMessage(2182, vSize, &vText,, "ahk_id " hCtl) ;SCI_GETTEXT := 2182
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		SendMessage(2182, vSize, pBuf,, "ahk_id " hCtl) ;SCI_GETTEXT := 2182
		JEE_DCReadProcessMemory(hProc, pBuf, &vText, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	return StrGet(&vText, vEnc)
}
JEE_SciSetText(hCtl, vText) {                                                                                	;-- JEE_ScintillaSetText
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vSize := StrPut(vText, "UTF-8")
	vOutput := ""
	VarSetCapacity(vOutput, vSize, 0)
	StrPut(vText, &vOutput, "UTF-8")

	if vIsLocal
		SendMessage(2181,, &vOutput,, "ahk_id " hCtl) ;SCI_SETTEXT := 2181
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &vOutput, vSize, 0)
		SendMessage(2181,, pBuf,, "ahk_id " hCtl) ;SCI_SETTEXT := 2181
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_SciPaste(hCtl, vText, vSize:=-1) {
	
	/*                              	DESCRIPTION
	
			;vSize: the size in bytes
			
	*/
	
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vSize2 := StrPut(vText, "UTF-8")
	vOutput := ""
	VarSetCapacity(vOutput, vSize2, 0)
	StrPut(vText, &vOutput, "UTF-8")
	(vSize = -1) && (vSize := vSize2-1)

	if vIsLocal
		SendMessage(2001, vSize, &vOutput,, "ahk_id " hCtl) ;SCI_ADDTEXT := 2001
	else
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize2, 0x3000, 0x4)
			return
		JEE_DCWriteProcessMemory(hProc, pBuf, &vOutput, vSize2, 0)
		SendMessage(2001, vSize, pBuf,, "ahk_id " hCtl) ;SCI_ADDTEXT := 2001
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_SciGetTextAlt(hCtl, vEnc:="UTF-8") {
	ControlGetText, vText,, % "ahk_id " hCtl
	return StrGet(&vText, vEnc)
}
JEE_SciSetTextAlt(hCtl, vText) {
	vSize := StrPut(vText, "UTF-8") + 2
	VarSetCapacity(vUtf8, vSize, 0)
	StrPut(vText, &vUtf8, "UTF-8")
	VarSetCapacity(vUtf8, -1)
	ControlSetText,, % vUtf8, % "ahk_id " hCtl
}
JEE_SciPasteAlt(hCtl, vText) {
	vSize := StrPut(vText, "UTF-8") + 2
	VarSetCapacity(vUtf8, vSize, 0)
	StrPut(vText, &vUtf8, "UTF-8")
	VarSetCapacity(vUtf8, -1)
	Control, EditPaste, % vUtf8,, % "ahk_id " hCtl
}
JEE_LBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: leave blank, there are no options currently
			
	*/
	
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x18B, 0, 0,, "ahk_id " hCtl) ;LB_GETCOUNT := 0x18B
	if (vCount = 0) || (vCount = 0xFFFFFFFF) ;LB_ERR := -1
		return
	if (SubStr(vList, 1, 1) = "s")
	{
		vCountSel := SendMessage(0x190,,,, "ahk_id " hCtl) ;LB_GETSELCOUNT := 0x190
		if (vCountSel = 0xFFFFFFFF) ;LB_ERR := -1 ;returns an error if a single-selection listbox
			vList := "f"
		else if (vCountSel = 0)
			return
	}
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		vIndex := SendMessage(0x188, 0, 0,, "ahk_id " hCtl) ;LB_GETCURSEL := 0x188
		if (vIndex = 0xFFFFFFFF) ;LB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		VarSetCapacity(vArray, vCountSel*4, 0)
		vCountSel := SendMessage(0x191, vCountSel, &vArray,, "ahk_id " hCtl) ;LB_GETSELITEMS := 0x191
		if (vCountSel = 0) || (vCountSel = 0xFFFFFFFF) ;LB_ERR := -1
			return
		Loop, % vCountSel
			oArray.Push(NumGet(&vArray, A_Index*4-4, "Int") + 1)
	}
	else if !(vList = -1)
		oArray := [vList]

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vChars := SendMessage(0x18A, vIndex, 0,, "ahk_id " hCtl) ;LB_GETTEXTLEN := 0x18A
		if (vChars = 0xFFFFFFFF) ;LB_ERR := -1
			vChars := 0
		vSize := (vChars+1) << !!A_IsUnicode
		VarSetCapacity(vTemp, vSize, 0)
		if vChars
			SendMessage(0x189, vIndex, &vTemp,, "ahk_id " hCtl) ;LB_GETTEXT := 0x189
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_LBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x18B, 0, 0,, "ahk_id " hCtl) ;LB_GETCOUNT := 0x18B
	if (vCount = 0)
		return
	if (SubStr(vList, 1, 1) = "s")
	{
		vCountSel := SendMessage(0x190,,,, "ahk_id " hCtl) ;LB_GETSELCOUNT := 0x190
		if (vCountSel = 0xFFFFFFFF) ;LB_ERR := -1 ;returns an error if a single-selection listbox
			vList := "f"
		else if (vCountSel = 0)
			return
	}
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		vIndex := SendMessage(0x188, 0, 0,, "ahk_id " hCtl) ;LB_GETCURSEL := 0x188
		if (vIndex = 0xFFFFFFFF) ;LB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		VarSetCapacity(vArray, vCountSel*4, 0)
		vCountSel := SendMessage(0x191, vCountSel, &vArray,, "ahk_id " hCtl) ;LB_GETSELITEMS := 0x191
		if (vCountSel = 0) || (vCountSel = 0xFFFFFFFF) ;LB_ERR := -1
			return
		Loop, % vCountSel
			oArray.Push(NumGet(&vArray, A_Index*4-4, "Int") + 1)
	}
	else if !(vList = -1)
		oArray := [vList]

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vTemp := A_LoopField
		SendMessage(0x182, vIndex,,, "ahk_id " hCtl) ;LB_DELETESTRING := 0x182
		SendMessage(0x181, vIndex, &vTemp,, "ahk_id " hCtl) ;LB_INSERTSTRING := 0x181
	}
}
JEE_CBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: leave blank, there are no options currently
			
	*/
	
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x146, 0, 0,, "ahk_id " hCtl) ;CB_GETCOUNT := 0x146
	if (vCount = 0) || (vCount = 0xFFFFFFFF) ;CB_ERR := -1
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x147, 0, 0,, "ahk_id " hCtl) ;CB_GETCURSEL := 0x147
		if (vIndex = 0xFFFFFFFF) ;CB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vChars := SendMessage(0x149, vIndex, 0,, "ahk_id " hCtl) ;CB_GETLBTEXTLEN := 0x149
		if (vChars = 0xFFFFFFFF) ;CB_ERR := -1
			vChars := 0
		vSize := (vChars+1) << !!A_IsUnicode
		VarSetCapacity(vTemp, vSize, 0)
		if vChars
			SendMessage(0x148, vIndex, &vTemp,, "ahk_id " hCtl) ;CB_GETLBTEXT := 0x148
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_CBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x146, 0, 0,, "ahk_id " hCtl) ;CB_GETCOUNT := 0x146
	if (vCount = 0) || (vCount = 0xFFFFFFFF) ;CB_ERR := -1
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x147, 0, 0,, "ahk_id " hCtl) ;CB_GETCURSEL := 0x147
		if (vIndex = 0xFFFFFFFF) ;CB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vTemp := A_LoopField
		SendMessage(0x144, vIndex,,, "ahk_id " hCtl) ;CB_DELETESTRING := 0x144
		SendMessage(0x14A, vIndex, &vTemp,, "ahk_id " hCtl) ;CB_INSERTSTRING := 0x14A
	}
}
JEE_LVGetText(hCtl, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;count items (rows) and columns
	if !vCount := SendMessage(0x1004, 0, 0,, "ahk_id " hCtl) ;LVM_GETITEMCOUNT := 0x1004
		return
	if !hLVH := SendMessage(0x101F,,,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	if !vCountCol := SendMessage(0x1200,,,, "ahk_id " hLVH) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCountCol = 0xFFFFFFFF) ;-1
		return

	if (vCol = -1)
	{
		vCol := "1"
		Loop, % vCountCol - 1
			vCol .= "," (A_Index+1)
	}

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		;LVNI_FOCUSED := 0x1
		vIndex := SendMessage(0x100C, -1, 0x1,, "ahk_id " hCtl) ;LVM_GETNEXTITEM := 0x100C
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		;LVNI_SELECTED := 0x2
		vItem := -1
		Loop
		{
			vItem := SendMessage(0x100C, vItem, 0x2,, "ahk_id " hCtl) ;LVM_GETNEXTITEM := 0x100C
			if (vItem = 0xFFFFFFFF) ;-1
				break
			oArray.Push(vItem+1)
		}
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?40:28
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(LVITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &LVITEM, pBuf2 := &vTemp

	NumPut(0x1, &LVITEM, 0, "UInt") ;mask ;LVIF_TEXT := 0x1
	NumPut(pBuf2, &LVITEM, vPIs64?24:20, vPtrType) ;pszText
	NumPut(vMaxChars, &LVITEM, vPIs64?32:24, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &LVITEM, vSize1, 0)

	vMsg := A_IsUnicode?0x1073:0x102D

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if vGetObj
			oOutput[vIndex+1] := {}
		else
			vOutput .= (A_Index=1?"":vSep)
		Loop, Parse, vCol, % ","
		{
			StrPut("", &vTemp)
			NumPut(vIndex, &LVITEM, 4, "Int") ;iItem
			NumPut(A_LoopField-1, &LVITEM, 8, "Int") ;iSubItem
			if !vIsLocal
				JEE_DCWriteProcessMemory(hProc, pBuf+4, &LVITEM+4, 8, 0)
			vChars := SendMessage(vMsg, vIndex, pBuf,, "ahk_id " hCtl) ;LVM_GETITEMTEXTW := 0x1073 ;LVM_GETITEMTEXTA := 0x102D
			vSize2X := (vChars+1) << !!A_IsUnicode
			if vChars && !vIsLocal
				JEE_DCReadProcessMemory(hProc, pBuf2, &vTemp, vSize2X, 0)
			VarSetCapacity(vTemp, -1)
			if vGetObj
				oOutput[vIndex+1].Push(vTemp)
			else
				vOutput .= (A_Index=1?"":vSepTab) vTemp
		}
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return vOutput
}
JEE_LVSetText(hCtl, vText, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;count items (rows) and columns
	if !vCount := SendMessage(0x1004, 0, 0,, "ahk_id " hCtl) ;LVM_GETITEMCOUNT := 0x1004
		return
	if !hLVH := SendMessage(0x101F,,,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	if !vCountCol := SendMessage(0x1200,,,, "ahk_id " hLVH) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCountCol = 0xFFFFFFFF) ;-1
		return

	if (vCol = -1)
	{
		vCol := "1"
		Loop, % vCountCol - 1
			vCol .= "," (A_Index+1)
	}

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		;LVNI_FOCUSED := 0x1
		vIndex := SendMessage(0x100C, -1, 0x1,, "ahk_id " hCtl) ;LVM_GETNEXTITEM := 0x100C
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		;LVNI_SELECTED := 0x2
		vItem := -1
		Loop
		{
			vItem := SendMessage(0x100C, vItem, 0x2,, "ahk_id " hCtl) ;LVM_GETNEXTITEM := 0x100C
			if (vItem = 0xFFFFFFFF) ;-1
				break
			oArray.Push(vItem+1)
		}
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?40:28
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(LVITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &LVITEM, pBuf2 := &vTemp

	NumPut(0x1, &LVITEM, 0, "UInt") ;mask ;LVIF_TEXT := 0x1
	NumPut(pBuf2, &LVITEM, vPIs64?24:20, vPtrType) ;pszText
	NumPut(vMaxChars, &LVITEM, vPIs64?32:24, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &LVITEM, vSize1, 0)
	vMsg := A_IsUnicode?0x1074:0x102E
	oCol := StrSplit(vCol, ",")
	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? (A_Index-1) : (oArray[A_Index]-1)
		vTemp2 := A_LoopField
		Loop, Parse, vTemp2, % vSepTab
		{
			vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
			vSize2X := vChars << !!A_IsUnicode
			vCol := oCol[A_Index]-1
			NumPut(vIndex, &LVITEM, 4, "Int") ;iItem
			NumPut(vCol, &LVITEM, 8, "Int") ;iSubItem
			if !vIsLocal
			{
				JEE_DCWriteProcessMemory(hProc, pBuf+4, &LVITEM+4, 8, 0)
				JEE_DCWriteProcessMemory(hProc, pBuf2, &vTemp, vSize2X, 0)
			}
			SendMessage(vMsg, vIndex, pBuf,, "ahk_id " hCtl) ;LVM_SETITEMTEXTW := 0x1074 ;LVM_SETITEMTEXTA := 0x102E
		}
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_LVHGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			;hCtl: pass the control hWnd for a SysListView32 or SysHeader32 control
			
	*/
	
	(vList = "") && (vList := -1)
	WinGetClass, vCtlClass, % "ahk_id " hCtl
	if (vCtlClass = "SysListView32")
	&& !hCtl := SendMessage(0x101F, 0, 0,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	else if !(vCtlClass = "SysHeader32")
		return

	if !vCount := SendMessage(0x1200,,,, "ahk_id " hCtl) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCount = 0xFFFFFFFF) ;-1
		return

	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		;the index of the leftmost column
		vIndex := SendMessage(0x121B,,,, "ahk_id " hCtl) ;HDM_GETFOCUSEDITEM := 0x121B
		oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?72:48
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(HDITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &HDITEM, pBuf2 := &vTemp

	NumPut(0x2, &HDITEM, 0, "UInt") ;mask ;HDI_TEXT := 0x2
	NumPut(pBuf2, &HDITEM, 8, vPtrType) ;pszText
	NumPut(vMaxChars, &HDITEM, vPIs64?24:16, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &HDITEM, vSize1, 0)

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		StrPut("", &vTemp)
		vRet := SendMessage(A_IsUnicode?0x120B:0x1203, vIndex, pBuf,, "ahk_id " hCtl) ;HDM_GETITEMW := 0x120B ;HDM_GETITEMA := 0x1203
		if vRet && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf+vSize1, &vTemp, vSize2, 0)
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_LVHSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			;hCtl: pass the control hWnd for a SysListView32 or SysHeader32 control
			
	*/
	
	(vList = "") && (vList := -1)
	WinGetClass, vCtlClass, % "ahk_id " hCtl
	if (vCtlClass = "SysListView32")
	&& !hCtl := SendMessage(0x101F, 0, 0,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	else if !(vCtlClass = "SysHeader32")
		return

	if !vCount := SendMessage(0x1200,,,, "ahk_id " hCtl) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCount = 0xFFFFFFFF) ;-1
		return

	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		;the index of the leftmost column
		vIndex := SendMessage(0x121B,,,, "ahk_id " hCtl) ;HDM_GETFOCUSEDITEM := 0x121B
		oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?72:48
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(HDITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &HDITEM, pBuf2 := &vTemp

	NumPut(0x2, &HDITEM, 0, "UInt") ;mask ;HDI_TEXT := 0x2
	NumPut(pBuf2, &HDITEM, 8, vPtrType) ;pszText
	NumPut(vMaxChars, &HDITEM, vPIs64?24:16, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &HDITEM, vSize1, 0)

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
		vSize2X := vChars << !!A_IsUnicode
		if !vIsLocal
			JEE_DCWriteProcessMemory(hProc, pBuf+vSize1, &vTemp, vSize2X, 0)
		SendMessage(A_IsUnicode?0x120C:0x1204, vIndex, pBuf,, "ahk_id " hCtl) ;HDM_SETITEMW := 0x120C ;HDM_SETITEMA := 0x1204
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_TVGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="", vDirPfx:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
			;further options:
			;vOpt: d: get dirs (list items with children)
			;vOpt: f: get files (list items with no children)
			;vOpt: p: show full paths
			;vOpt: i: indentation on
			;vOpt: c: parent name column
			;vOpt: o: return an object instead of text
			
			;vList: warning: paths/hierarchy information is only expected to be correct when vList:=-1
			;vDirPfx: if specified, a column is added that indicates items that are 'dirs' (that have children)
			
	*/
	
	/*                              	EXAMPLE(s)
	
			; ;===============
			; ;e.g.
			; ;q::
			; ControlGet, hCtl, Hwnd,, SysTreeView321, A
			; MsgBox, % JEE_TVGetText(hCtl)
			; MsgBox, % JEE_TVGetText(hCtl, "f")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "", "[DIR]")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "p", "[DIR]")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "i", "[DIR]")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "c")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "cp")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "icp")
			; MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "icp", "[DIR]")
			; return
			; ;===============
			
			; ;===============
			; ;e.g.
			; ;q:: ;get visible items
			; ControlGet, hCtl, Hwnd,, SysTreeView321, A
			; ;TVGN_NEXTVISIBLE := 0x6 ;TVGN_FIRSTVISIBLE := 0x5
			; oArray := , hItem := 0
			; Loop
			; 
			; 	if hItem := SendMessage(0x110A, (A_Index=1)?0x5:0x6, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
			; 		oArray.Push(hItem)
			; 	else
			; 		break
			; 
			; MsgBox, % JEE_TVGetText(hCtl, oArray)
			; return
			; ;===============
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x1105,,,, "ahk_id " hCtl) ;TVM_GETCOUNT := 0x1105
		return

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		;TVGN_CARET := 0x9
		hItem := SendMessage(0x110A, 0x9, 0,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
		oArray := [hItem]
	}
	else if !(vList = -1)
		oArray := [vList]
	else if (vList = -1)
	{
		;TVGN_ROOT := 0x0
		hItemNext := SendMessage(0x110A, 0x0, 0,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
	}

	vMsg := A_IsUnicode?0x113E:0x110C
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?56:40
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(TVITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
		return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &TVITEM, pBuf2 := &vTemp

	NumPut(0x1, &TVITEM, 0, "UInt") ;mask ;TVIF_TEXT := 0x1
	NumPut(pBuf2, &TVITEM, vPIs64?24:16, vPtrType) ;pszText
	NumPut(vMaxChars, &TVITEM, vPIs64?32:20, "UInt") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &TVITEM, vSize1, 0)
	vMsg := A_IsUnicode?0x113E:0x110C

	vGen := 1
	if !InStr(vOpt, "d") && !InStr(vOpt, "f")
		vOpt .= "df"
	vOffset := vPIs64?8:4

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		hItem := (vList = -1) ? hItemNext : oArray[A_Index]
		vHasSibling := vHasChild := 0

		;==============================
		;get next element: child, else sibling, else ancestor's sibling

		;check for child
		;TVGN_CHILD := 0x4
		hItemNext := SendMessage(0x110A, 0x4, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
		if hItemNext
			vHasChild := 1

		;check for sibling
		if !vHasChild
		{
			;TVGN_NEXT := 0x1
			hItemNext := SendMessage(0x110A, 0x1, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
			if hItemNext
				vHasSibling := 1
		}
		;check for ancestor's sibling (find first ancestor with a sibling)
		vHasSibling2 := 0
		if !vHasChild && !vHasSibling
		{
			vGenNext := vGen, hItemNext := hItem
			Loop
			{
				if (vGenNext = 1)
				{
					hItemNext := 0
					break
				}
				;get parent
				;TVGN_PARENT := 0x3
				hItemNext := SendMessage(0x110A, 0x3, hItemNext,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
				vGenNext--
				;check for sibling
				;TVGN_NEXT := 0x1
				hItemNext2 := SendMessage(0x110A, 0x1, hItemNext,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
				if hItemNext2
				{
					hItemNext := hItemNext2, vHasSibling2 := 1
					break
				}
			}
		}
		;==============================

		StrPut("", &vTemp)
		NumPut(hItem, &TVITEM, vPIs64?8:4, vPtrType) ;hItem
		if !vIsLocal
			JEE_DCWriteProcessMemory(hProc, pBuf+vOffset, &TVITEM+vOffset, vOffset, 0)
		vRet := SendMessage(vMsg, 0, pBuf,, "ahk_id " hCtl) ;TVM_GETITEMW := 0x113E ;TVM_GETITEMA := 0x110C
		if vRet && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf2, &vTemp, vSize2, 0)
		VarSetCapacity(vTemp, -1)

		if vHasChild
			vDir%vGen% := vTemp
		vGenX := vGen-1

		if (InStr(vOpt, "d") && vHasChild)
		|| (InStr(vOpt, "f") && !vHasChild)
		{
			vTemp2 := ""
			if InStr(vOpt, "c")
				vTemp2 .= vDir%vGenX% "`t"
			if !(vDirPfx = "")
				vTemp2 .= (vHasChild ? vDirPfx : "") "`t"
			if InStr(vOpt, "i")
				vTemp2 .= JEE_StrRept("`t", vGen-1)
			if InStr(vOpt, "p")
				Loop, % vGenX
					vTemp2 .= vDir%A_Index% "\"
			if vGetObj
				oOutput.Push(vTemp2 vTemp)
			else
				vOutput .= vTemp2 vTemp vSep
		}
		if vHasChild
			vGen++
		if vHasSibling2
			vGen := vGenNext
		if !hItemNext
			break
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_TVSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x1105,,,, "ahk_id " hCtl) ;TVM_GETCOUNT := 0x1105
		return

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		;TVGN_CARET := 0x9
		hItem := SendMessage(0x110A, 0x9, 0,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
		oArray := [hItem]
	}
	else if !(vList = -1)
		oArray := [vList]
	else if (vList = -1)
	{
		;TVGN_ROOT := 0x0
		hItemNext := SendMessage(0x110A, 0x0, 0,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
	}

	vMsg := A_IsUnicode?0x113F:0x110D
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vPtrType := vPIs64?"Int64":"Int"
	vSize1 := vPIs64?40:24
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(TVITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &TVITEM, pBuf2 := &vTemp

	NumPut(0x1, &TVITEM, 0, "UInt") ;mask ;LVIF_TEXT := 0x1
	NumPut(pBuf2, &TVITEM, vPIs64?24:16, vPtrType) ;pszText
	NumPut(vMaxChars, &TVITEM, vPIs64?32:20, "Int") ;cchTextMax

	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &TVITEM, vSize1, 0)

	vGen := 1
	vOffset := vPIs64?8:4

	Loop, Parse, vText, % vSep
	{
		vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
		vSize2X := vChars << !!A_IsUnicode
		hItem := (vList = -1) ? hItemNext : oArray[A_Index]
		vHasSibling := vHasChild := 0

		;==============================
		;get next element: child, else sibling, else ancestor's sibling

		;check for child
		;TVGN_CHILD := 0x4
		hItemNext := SendMessage(0x110A, 0x4, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
		if hItemNext
			vHasChild := 1

		;check for sibling
		if !vHasChild
		{
			;TVGN_NEXT := 0x1
			hItemNext := SendMessage(0x110A, 0x1, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
			if hItemNext
				vHasSibling := 1
		}
		;check for ancestor's sibling (find first ancestor with a sibling)
		vHasSibling2 := 0
		if !vHasChild && !vHasSibling
		{
			vGenNext := vGen, hItemNext := hItem
			Loop
			{
				if (vGenNext = 1)
				{
					hItemNext := 0
					break
				}
				;get parent
				;TVGN_PARENT := 0x3
				hItemNext := SendMessage(0x110A, 0x3, hItemNext,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
				vGenNext--
				;check for sibling
				;TVGN_NEXT := 0x1
				hItemNext2 := SendMessage(0x110A, 0x1, hItemNext,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
				if hItemNext2
				{
					hItemNext := hItemNext2, vHasSibling2 := 1
					break
				}
			}
		}
		;==============================

		NumPut(hItem, &TVITEM, vPIs64?8:4, vPtrType) ;hItem
		if !vIsLocal
		{
			JEE_DCWriteProcessMemory(hProc, pBuf+vOffset, &TVITEM+vOffset, vOffset, 0)
			JEE_DCWriteProcessMemory(hProc, pBuf2, &vTemp, vSize2X, 0)
		}
		SendMessage(vMsg, hItem, pBuf,, "ahk_id " hCtl) ;TVM_SETITEMW := 0x113F ;TVM_SETITEMA := 0x110D
		if vHasChild
			vGen++
		if vHasSibling2
			vGen := vGenNext
		if !hItemNext
			break
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_SBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x406, 0, 0,, "ahk_id " hCtl) ;SB_GETPARTS := 0x406
		return

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
		oArray := [1]
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize := vMaxChars << !!A_IsUnicode
	VarSetCapacity(vTemp, vSize, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}
	else
		pBuf := &vTemp

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		StrPut("", &vTemp)
		vChars := 0xFFFF & SendMessage(A_IsUnicode?0x40D:0x402, vIndex, pBuf,, "ahk_id " hCtl) ;SB_GETTEXTW := 0x40D ;SB_GETTEXTA := 0x402
		vSizeX := (vChars+1) << !!A_IsUnicode
		if (vChars > 0) && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf, &vTemp, vSizeX, 0)
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_SBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
		
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x406, 0, 0,, "ahk_id " hCtl) ;SB_GETPARTS := 0x406
		return

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize := vMaxChars << !!A_IsUnicode
	VarSetCapacity(vTemp, vSize, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}
	else
		pBuf := &vTemp

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
		oArray := [1]
	else if !(vList = -1)
		oArray := [vList]

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
		vSizeX := vChars << !!A_IsUnicode
		JEE_DCWriteProcessMemory(hProc, pBuf, &vTemp, vSizeX, 0)
		SendMessage(A_IsUnicode?0x40B:0x401, vIndex, pBuf,, "ahk_id " hCtl) ;SB_SETTEXTW := 0x40B ;SB_SETTEXTA := 0x401
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_TBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
			;further options:
			;vOpt: t: return object with systray info
			;vOpt: i: list contains IDs not positions
			;vOpt: x: exclude separators (no blank lines for separators)
			;vOpt: c: include command IDs in output
				
	*/
	
	/*		                           	EXAMPLE(s)
		
			; ;q:: ;tray icon - get info
			; DetectHiddenWindows, On
			; ControlGet, hTB, Hwnd,, ToolbarWindow321, ahk_class NotifyIconOverflowWindow
			; oTrayInfo := JEE_TBGetText(hTB, -1, "`n", "t")
			; vOutput := ""
			; for vKey1 in oTrayInfo
			; 
			; 	for vKey, vValue in oTrayInfo[vKey1]
			; 		vOutput .= (A_Index=1?"":"|") vKey ": " vValue
			; 	vOutput .= "`r`n"
			; 
			; MsgBox, % vOutput
			; return
			; ;===============
			
	*/
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x418, 0, 0,, "ahk_id " hCtl) ;TB_BUTTONCOUNT := 0x418
		return

	if InStr(vOpt, "t")
		oTrayInfo := {}
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x447,,,, "ahk_id " hCtl) ;TB_GETHOTITEM := 0x447
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		else
			oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vUPtrType := vPIs64?"UInt64":"UInt"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?32:20
	vSize2 := vMaxChars << !!A_IsUnicode
	vSize3 := vPIs64?48:32
	VarSetCapacity(TBBUTTON, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2+vSize3, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &TBBUTTON, pBuf2 := &vTemp

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1

		;index to command identifier if appropriate
		if InStr(vOpt, "i") ;number is ID
			vIDCmd := vIndex+1
		else ;number is index, get ID
		{
			SendMessage(0x417, vIndex, pBuf,, "ahk_id " hCtl) ;TB_GETBUTTON := 0x417
			if !vIsLocal
				JEE_DCReadProcessMemory(hProc, pBuf, &TBBUTTON, vSize1, 0)
			vIDCmd := NumGet(&TBBUTTON, 4, "Int") ;idCommand
		}

		vChars := SendMessage(A_IsUnicode?0x44B:0x42D, vIDCmd, 0,, "ahk_id " hCtl) ;TB_GETBUTTONTEXTW := 0x44B ;TB_GETBUTTONTEXTA := 0x42D
		if InStr(vOpt, "x") && (vChars = 0xFFFFFFFF) ;-1 ;separator
			continue
		else if (vChars = 0xFFFFFFFF) ;-1 ;separator
			vChars := 0
		StrPut("", &vTemp)
		if vChars
			vChars := SendMessage(A_IsUnicode?0x44B:0x42D, vIDCmd, pBuf2,, "ahk_id " hCtl) ;TB_GETBUTTONTEXTW := 0x44B ;TB_GETBUTTONTEXTA := 0x42D
		vSize2X := (vChars+1) << !!A_IsUnicode
		if vChars && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf2, &vTemp, vSize2X, 0)
		VarSetCapacity(vTemp, -1)
		if InStr(vOpt, "c")
			vTemp := vIDCmd "`t" vTemp
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep

		;===============
		;TRAYDATA may be an unofficial name
		if InStr(vOpt, "t") ;special handling for systray icons
		{
			pTRAYDATA := NumGet(&TBBUTTON, vPIs64?16:12, vUPtrType) ;dwData
			if !vIsLocal
			{
				VarSetCapacity(TRAYDATA, vSize3, 0)
				JEE_DCReadProcessMemory(hProc, pTRAYDATA, &TRAYDATA, vSize3, 0)
				pTRAYDATA := &TRAYDATA
			}
			vIndex := oTrayInfo.MaxIndex() ? oTrayInfo.MaxIndex()+1 : 1
			hWnd := NumGet(pTRAYDATA+0, 0, vPtrType)
			uID := NumGet(pTRAYDATA+0, vPIs64?8:4, "UInt")
			uMsg := NumGet(pTRAYDATA+0, vPIs64?12:8, "UInt")
			hIcon := NumGet(pTRAYDATA+0, vPIs64?24:20, vPtrType)

			hWndParent := DllCall("user32\GetParent", Ptr,hCtl, Ptr)
			WinGetClass, vTray, % "ahk_id " hWndParent

			WinGet, vPID, PID, % "ahk_id " hWnd
			WinGet, vPName, ProcessName, % "ahk_id " hWnd
			WinGet, vPPath, ProcessPath, % "ahk_id " hWnd
			WinGetClass, vWinClass, % "ahk_id " hWnd
			WinGetTitle, vWinTitle, % "ahk_id " hWnd

			oTrayInfo[vIndex, "Index"] := A_Index-1 ;0-based index
			oTrayInfo[vIndex, "IDCmd"] := vIDCmd ;cf. menu item's wParam for WM_COMMAND
			oTrayInfo[vIndex, "PID"] := vPID
			oTrayInfo[vIndex, "uID"] := uID ;ID for process to distinguish between multiple tray icons
			oTrayInfo[vIndex, "uMsg"] := uMsg ;cf. WM_COMMAND := 0x111
			oTrayInfo[vIndex, "hIcon"] := hIcon
			oTrayInfo[vIndex, "hWnd"] := hWnd
			oTrayInfo[vIndex, "Class"] := vWinClass
			oTrayInfo[vIndex, "PName"] := vPName
			oTrayInfo[vIndex, "PPath"] := vPPath
			oTrayInfo[vIndex, "Title"] := vWinTitle
			oTrayInfo[vIndex, "ToolTip"] := vTemp
			oTrayInfo[vIndex, "Tray"] := vTray
		}
		;===============
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if InStr(vOpt, "t")
		return oTrayInfo
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_TBGetTextPool(hCtl, vList:=-1, vSep:="`n", vOpt:="") {                                 	;-- get text from toolbar's string pool
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
		
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x418, 0, 0,, "ahk_id " hCtl) ;TB_BUTTONCOUNT := 0x418
		return

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x447,,,, "ahk_id " hCtl) ;TB_GETHOTITEM := 0x447
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		else
			oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize := vMaxChars << !!A_IsUnicode
	VarSetCapacity(vTemp, vSize, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}
	else
		pBuf := &vTemp

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		StrPut("", &vTemp)
		vChars := SendMessage(A_IsUnicode?0x45B:0x45C, vSize + 0x10000*vIndex, pBuf,, "ahk_id " hCtl) ;TB_GETSTRINGW := 0x45B ;TB_GETSTRINGA := 0x45C
		if (vChars = 0xFFFFFFFF) ;-1
			vChars := 0
		vSizeX := vChars << !!A_IsUnicode
		if vChars && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf, &vTemp, vSizeX, 0)
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_TBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
			;further options:
			;vOpt: i: vList contains IDs not positions
			
			;this may not necessarily work since toolbars
			;can store text in different ways,
			;if multiple items have the same command ID,
			;only the text of one button is set
			
	*/
			
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x418, 0, 0,, "ahk_id " hCtl) ;TB_BUTTONCOUNT := 0x418
		return

	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x447,,,, "ahk_id " hCtl) ;TB_GETHOTITEM := 0x447
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		else
			oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vPtrType := vPIs64?"Int64":"Int"
	vUPtrType := vPIs64?"UInt64":"UInt"
	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?32:20
	vSize2 := vPIs64?48:32
	vSize3 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(TBBUTTON, vSize1, 0)
	VarSetCapacity(TBBUTTONINFO, vSize2, 0)
	VarSetCapacity(vTemp, vSize3, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2+vSize3, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
		pBuf3 := pBuf2 + vSize2
	}
	else
		pBuf := &TBBUTTON, pBuf2 := &TBBUTTONINFO, pBuf3 := &vTemp

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? (A_Index-1) : (oArray[A_Index]-1)
		vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
		vSize3X := vChars << !!A_IsUnicode

		;index to command identifier if appropriate
		if InStr(vOpt, "i") ;number is ID
			vIDCmd := vIndex+1
		else ;number is index, get ID
		{
			SendMessage(0x417, vIndex, pBuf,, "ahk_id " hCtl) ;TB_GETBUTTON := 0x417
			if !vIsLocal
				JEE_DCReadProcessMemory(hProc, pBuf, &TBBUTTON, vSize1, 0)
			vIDCmd := NumGet(&TBBUTTONINFO, 4, "Int") ;idCommand
		}

		NumPut(vSize2, &TBBUTTONINFO, 0, "UInt") ;cbSize
		NumPut(0x2, &TBBUTTONINFO, 4, "UInt") ;dwMask ;TBIF_TEXT := 0x2
		NumPut(pBuf3, &TBBUTTONINFO, vPIs64?32:24, vUPtrType) ;pszText
		if !vIsLocal
		{
			JEE_DCWriteProcessMemory(hProc, pBuf2, &TBBUTTONINFO, vSize2, 0)
			JEE_DCWriteProcessMemory(hProc, pBuf3, &vTemp, vSize3X, 0)
		}
		SendMessage(A_IsUnicode?0x440:0x442, vIDCmd, pBuf2,, "ahk_id " hCtl) ;TB_SETBUTTONINFOW := 0x440 ;TB_SETBUTTONINFOA := 0x442
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_TCGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
		
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x1304,,,, "ahk_id " hCtl) ;TCM_GETITEMCOUNT := 0x1304
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		vIndex := SendMessage(0x132F,,,, "ahk_id " hCtl) ;TCM_GETCURFOCUS := 0x132F
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x130B,,,, "ahk_id " hCtl) ;TCM_GETCURSEL := 0x130B
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		else
			oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?40:28
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(TCITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &TCITEM, pBuf2 := &vTemp

	NumPut(0x1, &TCITEM, 0, "UInt") ;mask ;TCIF_TEXT := 0x1
	NumPut(pBuf2, &TCITEM, vPIs64?16:12, "Ptr") ;pszText
	NumPut(vMaxChars, &TCITEM, vPIs64?24:16, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &TCITEM, vSize1, 0)

	if vGetObj := !!InStr(vOpt, "o")
		(oOutput := {}).SetCapacity(vCount)
	else
		VarSetCapacity(vOutput, 100*vCount << !!A_IsUnicode)
	Loop, % oArray.Length() ? oArray.Length() : vCount
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		StrPut("", &vTemp)
		vRet := SendMessage(A_IsUnicode?0x133C:0x1305, vIndex, pBuf,, "ahk_id " hCtl) ;TCM_GETITEMW := 0x133C ;TCM_GETITEMA := 0x1305
		if vRet && !vIsLocal
			JEE_DCReadProcessMemory(hProc, pBuf2, &vTemp, vSize2, 0)
		VarSetCapacity(vTemp, -1)
		if vGetObj
			oOutput.Push(vTemp)
		else
			vOutput .= vTemp vSep
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
	if vGetObj
		return oOutput
	else
		return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_TCSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;vList: 1-based comma-separated list or array
			;vList: -1/f/s: all/focused/selected items
			;vOpt: m: e.g. m1000, specify max chars 1000
			;vOpt: o: return an object instead of a string
			
	*/
		
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hCtl
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	if !vCount := SendMessage(0x1304,,,, "ahk_id " hCtl) ;TCM_GETITEMCOUNT := 0x1304
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	{
		vIndex := SendMessage(0x132F,,,, "ahk_id " hCtl) ;TCM_GETCURFOCUS := 0x132F
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x130B,,,, "ahk_id " hCtl) ;TCM_GETCURSEL := 0x130B
		if (vIndex = 0xFFFFFFFF) ;-1
			return
		else
			oArray := [vIndex+1]
	}
	else if !(vList = -1)
		oArray := [vList]

	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if A_Is64bitOS && !DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
			return
		vPIs64 := !vIsWow64Process
	}

	vMaxChars := RegExReplace(vOpt "m260", ".*?m(\d+).*", "$1")
	vSize1 := vPIs64?40:28
	vSize2 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(TCITEM, vSize1, 0)
	VarSetCapacity(vTemp, vSize2, 0)

	if !vIsLocal
	{
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf := &TCITEM, pBuf2 := &vTemp

	NumPut(0x1, &TCITEM, 0, "UInt") ;mask ;TCIF_TEXT := 0x1
	NumPut(pBuf2, &TCITEM, vPIs64?16:12, "Ptr") ;pszText
	NumPut(vMaxChars, &TCITEM, vPIs64?24:16, "Int") ;cchTextMax
	if !vIsLocal
		JEE_DCWriteProcessMemory(hProc, pBuf, &TCITEM, vSize1, 0)

	Loop, Parse, vText, % vSep
	{
		vIndex := (vList = -1) ? A_Index-1 : oArray[A_Index]-1
		if !(vIndex >= 0) || !(vIndex < vCount)
			continue
		vChars := StrPut(SubStr(A_LoopField, 1, vMaxChars-1), &vTemp)
		vSize2X := vChars << !!A_IsUnicode
		if !vIsLocal
			JEE_DCWriteProcessMemory(hProc, pBuf2, &vTemp, vSize2X, 0)
		SendMessage(A_IsUnicode?0x133D:0x1306, vIndex, pBuf,, "ahk_id " hCtl) ;TCM_SETITEMW := 0x133D ;TCM_SETITEMA := 0x1306
	}

	if !vIsLocal
	{
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
JEE_LBInsStr(hCtl, vText, vPos:=-1) {
	(vPos != -1) && (vPos -= 1)
	SendMessage(0x181, vPos, &vText,, "ahk_id " hCtl) ;LB_INSERTSTRING := 0x181
}
JEE_LBDelStr(hCtl, vPos:=-1) {
	if (vPos = -1)
		SendMessage(0x184,,,, "ahk_id " hCtl) ;LB_RESETCONTENT := 0x184
	else
		SendMessage(0x182, vPos-1,,, "ahk_id " hCtl) ;LB_DELETESTRING := 0x182
}
JEE_CBInsStr(hCtl, vText, vPos:=-1) {
	(vPos != -1) && (vPos -= 1)
	SendMessage(0x14A, vPos, &vText,, "ahk_id " hCtl) ;CB_INSERTSTRING := 0x14A
}
JEE_CBDelStr(hCtl, vPos:=-1) {
	if (vPos = -1)
		SendMessage(0x14B,,,, "ahk_id " hCtl) ;CB_RESETCONTENT := 0x14B
	else
		SendMessage(0x144, vPos-1,,, "ahk_id " hCtl) ;CB_DELETESTRING := 0x144
}
JEE_TrayIconRename(hWnd, uID, vWinTitle) {                                                      	;-- rename system tray icon
		
	vSize := A_IsUnicode?168:152
	VarSetCapacity(NOTIFYICONDATA, vSize, 0)
	NumPut(vSize, &NOTIFYICONDATA, 0, "UInt") ;cbSize
	NumPut(hWnd, &NOTIFYICONDATA, A_PtrSize=8?8:4, "Ptr") ;hWnd ;(window that receives notifications associated with an icon)
	NumPut(uID, &NOTIFYICONDATA, A_PtrSize=8?16:8, "UInt") ;uID
	;NIF_TIP := 0x4
	NumPut(0x4, &NOTIFYICONDATA, A_PtrSize=8?20:12, "UInt") ;uFlags
	StrPut(vWinTitle, &NOTIFYICONDATA+(A_PtrSize=8?40:24), 64) ;szTip[64]
	;NIM_MODIFY := 0x1
	DllCall("shell32\Shell_NotifyIcon" (A_IsUnicode?"W":"A"), UInt,0x1, Ptr,&NOTIFYICONDATA)
}
JEE_TrayIconModify(hWnd, uID, uMsg, hIcon, vWinTitle) {
	vSize := A_IsUnicode?168:152
	VarSetCapacity(NOTIFYICONDATA, vSize, 0)
	NumPut(vSize, &NOTIFYICONDATA, 0, "UInt") ;cbSize
	NumPut(hWnd, &NOTIFYICONDATA, A_PtrSize=8?8:4, "Ptr") ;hWnd ;(window that receives notifications associated with an icon)
	NumPut(uID, &NOTIFYICONDATA, A_PtrSize=8?16:8, "UInt") ;uID
	;NIF_TIP := 0x4 ;NIF_ICON := 0x2 ;NIF_MESSAGE := 0x1
	NumPut(0x7, &NOTIFYICONDATA, A_PtrSize=8?20:12, "UInt") ;uFlags
	NumPut(uMsg, &NOTIFYICONDATA, A_PtrSize=8?24:16, "UInt") ;uCallbackMessage
	NumPut(hIcon, &NOTIFYICONDATA, A_PtrSize=8?32:20, "Ptr") ;hIcon
	StrPut(vWinTitle, &NOTIFYICONDATA+(A_PtrSize=8?40:24), 64) ;szTip[64]
	;NIM_MODIFY := 0x1
	DllCall("shell32\Shell_NotifyIcon" (A_IsUnicode?"W":"A"), UInt,0x1, Ptr,&NOTIFYICONDATA)
}
JEE_MenuGetText(hWndOrMenu:="", vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;a - pass an hWnd rather than an hMenu: get alt-space menu (sysmenu)
			;c - context menu
			;w - pass an hWnd rather than an hMenu
			;x - exclude items with ID = 0 (separators)
			
	*/
	
	if !hWndOrMenu && !InStr(vOpt, "c")
		hWndOrMenu := WinExist("A"), vOpt .= "w"
	if InStr(vOpt, "a")
		hMenu := DllCall("user32\GetSystemMenu", Ptr,hWndOrMenu, Int,0, Ptr) ;get handle to alt+space menu
	else if InStr(vOpt, "w")
		hMenu := DllCall("user32\GetMenu", Ptr,hWndOrMenu, Ptr)
	else if InStr(vOpt, "c")
		hMenu := SendMessage(0x1E1, 0, 0,, "ahk_class #32768") ;MN_GETHMENU := 0x1E1
	else
		hMenu := hWndOrMenu

	Loop, % DllCall("user32\GetMenuItemCount", Ptr,hMenu)
	{
		vIndex := A_Index-1
		vID := DllCall("user32\GetMenuItemID", Ptr,hMenu, Int,vIndex, UInt)
		vChars := DllCall("user32\GetMenuString", Ptr,hMenu, UInt,vIndex, Ptr,0, Int,0, UInt,0x400) + 1
		VarSetCapacity(vText, vChars << !!A_IsUnicode)
		DllCall("user32\GetMenuString", Ptr,hMenu, UInt,vIndex, Str,vText, Int,vChars, UInt,0x400) ;MF_BYPOSITION := 0x400
		if InStr(vOpt, "x") && (vID = 0)
			continue
		if (vID = 0xFFFFFFFF) ;-1
			vID := -1
		vOutput .= vID (vText=""?"":"`t" vText) vSep
	}
	if InStr(vOpt, "a")
		DllCall("user32\GetSystemMenu", Ptr,hWndOrMenu, Int,1, Ptr)
	return vOutput
}
;JEE_MenusGetText
JEE_MenuGetTextAll(hWndOrMenu:="", vSep:="`n", vOpt:="") {
	
	/*                              	DESCRIPTION
	
			;get text of menu and all descendant submenus
			;a - pass an hWnd rather than an hMenu: get alt-space menu (sysmenu)
			;c - context menu
			;w - pass an hWnd rather than an hMenu
			;x - exclude items with ID = 0 (separators)
			
	*/
	
	if !hWndOrMenu && !InStr(vOpt, "c")
		hWndOrMenu := WinExist("A"), vOpt .= "w"
	if InStr(vOpt, "a")
		hMenu := DllCall("user32\GetSystemMenu", Ptr,hWndOrMenu, Int,0, Ptr) ;get handle to alt+space menu
	else if InStr(vOpt, "w")
		hMenu := DllCall("user32\GetMenu", Ptr,hWndOrMenu, Ptr)
	else if InStr(vOpt, "c")
		hMenu := SendMessage(0x1E1, 0, 0,, "ahk_class #32768") ;MN_GETHMENU := 0x1E1
	else
		hMenu := hWndOrMenu

	vLevel := 0, oTitle := {}, vOutput := ""
	oArray := {}, oArray.0 := {}, oArray.0.1 := hMenu
	Loop
	{
		if (vLevel = -1)
			break
		else if oArray[vLevel+1].Length()
			vLevel++
		else if !oArray[vLevel].Length()
		{
			vLevel--
			continue
		}
		hMenu := oArray[vLevel].1
		oArray[vLevel].RemoveAt(1)
		if oTitle.HasKey(hMenu)
			vOutput .= JEE_StrRept("`t", vLevel) "[" oTitle[hMenu] "]" vSep
		Loop, % DllCall("user32\GetMenuItemCount", Ptr,hMenu)
		{
			vIndex := A_Index-1
			vID := DllCall("user32\GetMenuItemID", Ptr,hMenu, Int,vIndex, UInt)
			vChars := DllCall("user32\GetMenuString", Ptr,hMenu, UInt,vIndex, Ptr,0, Int,0, UInt,0x400) + 1
			VarSetCapacity(vText, vChars << !!A_IsUnicode)
			DllCall("user32\GetMenuString", Ptr,hMenu, UInt,vIndex, Str,vText, Int,vChars, UInt,0x400) ;MF_BYPOSITION := 0x400
			if InStr(vOpt, "x") && (vID = 0)
				continue
			if (vID = 0xFFFFFFFF) ;-1
			{
				vID := -1
				hSubMenu := DllCall("user32\GetSubMenu", Ptr,hMenu, Int,vIndex, Ptr)
				if !oArray.HasKey(vLevel+1)
					oArray[vLevel+1] := {}
				oArray[vLevel+1].Push(hSubMenu)
				oTitle[hSubMenu] := vText
			}
			vOutput .= JEE_StrRept("`t", vLevel) vID (vText=""?"":"`t" vText) vSep
		}
		vOutput .= vSep
	}
	if InStr(vOpt, "a")
		DllCall("user32\GetSystemMenu", Ptr,hWndOrMenu, Int,1, Ptr)
	return SubStr(vOutput, 1, -4)
}
;works on internal + external menus
;vPos: 1-based index
JEE_MenuItemPosGetText(hMenu, vPos) {
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	DllCall("user32\GetMenuItemInfo", Ptr,hMenu, UInt,vPos-1, Int,1, Ptr,&MENUITEMINFO)
	vChars := NumGet(&MENUITEMINFO, A_PtrSize=8?64:40, "UInt") ;cch
	if (vChars <= 0)
		return
	VarSetCapacity(vText, (vChars+1) << !!A_IsUnicode, 0)
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	NumPut(vChars+1, &MENUITEMINFO, A_PtrSize=8?64:40, "UInt") ;cch
	DllCall("user32\GetMenuItemInfo", Ptr,hMenu, UInt,vPos-1, Int,1, Ptr,&MENUITEMINFO)
	VarSetCapacity(vText, -1)
	return vText
}
;works on internal + external menus
JEE_MenuItemIDGetText(hMenu, vID) {
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	DllCall("user32\GetMenuItemInfo", Ptr,hMenu, UInt,vID, Int,0, Ptr,&MENUITEMINFO)
	vChars := NumGet(&MENUITEMINFO, A_PtrSize=8?64:40, "UInt") ;cch
	if (vChars <= 0)
		return
	VarSetCapacity(vText, (vChars+1) << !!A_IsUnicode, 0)
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	NumPut(vChars+1, &MENUITEMINFO, A_PtrSize=8?64:40, "UInt") ;cch
	DllCall("user32\GetMenuItemInfo", Ptr,hMenu, UInt,vID, Int,0, Ptr,&MENUITEMINFO)
	VarSetCapacity(vText, -1)
	return vText
}
;works on internal + external menus
;vPos: 1-based index
JEE_MenuItemPosSetText(hMenu, vText, vPos) {
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	DllCall("user32\SetMenuItemInfo", Ptr,hMenu, UInt,vPos-1, Int,1, Ptr,&MENUITEMINFO)
}
;works on internal + external menus
JEE_MenuItemIDSetText(hMenu, vText, vID) {
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	DllCall("user32\SetMenuItemInfo", Ptr,hMenu, UInt,vID, Int,0, Ptr,&MENUITEMINFO)
}
JEE_CFDGetDir(hWnd) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hWnd
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vMaxChars := 260
	vSize := vMaxChars << !!A_IsUnicode
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}

	VarSetCapacity(vText, vSize, 0)
	if vIsLocal
		vChars := SendMessage(0x466, vMaxChars, &vText,, "ahk_id " hWnd) ;CDM_GETFOLDERPATH := 0x466
	else
		vChars := SendMessage(0x466, vMaxChars, pBuf,, "ahk_id " hWnd) ;CDM_GETFOLDERPATH := 0x466
	if (vChars <= 0)
		return

	if !vIsLocal
	{
		JEE_DCReadProcessMemory(hProc, pBuf, &vText, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	VarSetCapacity(vText, -1)
	return vText
}
JEE_CFDGetPath(hWnd) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hWnd
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vMaxChars := 260
	vSize := vMaxChars << !!A_IsUnicode
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}

	VarSetCapacity(vText, vSize, 0)
	if vIsLocal
		vChars := SendMessage(0x465, vMaxChars, &vText,, "ahk_id " hWnd) ;CDM_GETFILEPATH := 0x465
	else
		vChars := SendMessage(0x465, vMaxChars, pBuf,, "ahk_id " hWnd) ;CDM_GETFILEPATH := 0x465
	if (vChars <= 0)
		return

	if !vIsLocal
	{
		JEE_DCReadProcessMemory(hProc, pBuf, &vText, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	VarSetCapacity(vText, -1)
	return vText
}
JEE_CFDGetName(hWnd) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hWnd
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vMaxChars := 260
	vSize := vMaxChars << !!A_IsUnicode
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}

	VarSetCapacity(vText, vSize, 0)
	if vIsLocal
		vChars := SendMessage(0x464, vMaxChars, &vText,, "ahk_id " hWnd) ;CDM_GETSPEC := 0x464
	else
		vChars := SendMessage(0x464, vMaxChars, pBuf,, "ahk_id " hWnd) ;CDM_GETSPEC := 0x464
	if (vChars <= 0)
		return

	if !vIsLocal
	{
		JEE_DCReadProcessMemory(hProc, pBuf, &vText, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	VarSetCapacity(vText, -1)
	return vText
}
;note: getting inconsistent results with this approach
JEE_CFDGetDirName(hWnd) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hWnd
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vMaxChars := 260
	vSize := vMaxChars << !!A_IsUnicode
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)
			return
	}

	VarSetCapacity(vData, vSize, 0)
	if vIsLocal
		vSize2 := SendMessage(0x467, vMaxChars, &vData,, "ahk_id " hWnd) ;CDM_GETFOLDERIDLIST := 0x467
	else
		vSize2 := SendMessage(0x467, vMaxChars, pBuf,, "ahk_id " hWnd) ;CDM_GETFOLDERIDLIST := 0x467
	if (vSize2 <= 0)
		return

	if !vIsLocal
	{
		JEE_DCReadProcessMemory(hProc, pBuf, &vData, vSize, 0)
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}

	;SHGFI_ATTRIBUTES := 0x800 ;SHGFI_TYPENAME := 0x400
	;SHGFI_DISPLAYNAME := 0x200 ;SHGFI_ICON := 0x100
	;SHGFI_PIDL := 0x8
	vSize3 := A_PtrSize=8?696:692
	vSize4 := vMaxChars << !!A_IsUnicode
	VarSetCapacity(SHFILEINFO, vSize3, 0)
	DllCall("shell32\SHGetFileInfo" (A_IsUnicode?"W":"A"), Ptr,&vData, UInt,0, Ptr,&SHFILEINFO, UInt,vSize3, UInt,0xF08, UPtr)
	VarSetCapacity(vDName, vSize4, 0)
	DllCall("msvcrt\memcpy", Ptr,&vDName, Ptr,&SHFILEINFO+(A_PtrSize=8?16:12), UPtr,vSize4, "Cdecl Int")
	VarSetCapacity(vDName, -1)
	;e.g. 'Computer' (for equivalent of My Computer on Windows 7)
	return vDName
}
JEE_CFDSetDir(hWnd, vDir) {
	if !DirExist(vDir)
		return
	vDir2 := JEE_CFDGetDir(hWnd)
	if (vDir = vDir2)
		return

	ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
	ControlSetText, Edit1, % vDir, % "ahk_id " hWnd
	ControlFocus, Button2, % "ahk_id " hWnd
	ControlSend, Button2, {Enter}, % "ahk_id " hWnd
	Loop, 30
	{
		ControlFocus, % vCtlClassNN, % "ahk_id " hWnd
		Sleep, 100
		ControlGetFocus, vCtlClassNN2, % "ahk_id " hWnd
		if (vCtlClassNN = vCtlClassNN2)
			break
	}
}
JEE_CFDSetPath(hWnd, vPath) {
	SplitPath, vPath,, vDir
	if !DirExist(vDir)
		return
	JEE_CFDSetDir(hWnd, vDir)
	ControlGetText, vDName2, Edit1, % "ahk_id " hWnd
	VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
	DllCall("comdlg32\GetFileTitle", Str,vPath, Str,vDName, UShort,260, Short) ;get display name
	if !(vDName = vDName2)
	{
		ControlSetText, Edit1, % vDName, % "ahk_id " hWnd
		SendMessage(0xB1, 0, -1, Edit1, "ahk_id " hWnd) ;EM_SETSEL := 0xB1
	}
	ControlFocus, Edit1, % "ahk_id " hWnd
}
;combine dir with Edit/listview item
;get the path of the selected listview item
;note: this could return multiple paths, if multiple files have the same display name
JEE_CFDGetPathAlt(hWnd, vSep:="|") {
	vDir := JEE_CFDGetDir(hWnd)
	ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd

	if (vCtlClassNN = "SysListView321")
		ControlGet, vName, List, Focused Col1, SysListView321, % "ahk_id " hWnd
	else
		ControlGetText, vName, Edit1, % "ahk_id " hWnd

	Loop, Files, % vDir "\*", F
	{
		VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
		DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
		if (vDName = vName)
			vOutput .= vDir "\" A_LoopFileName vSep
	}
	return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_CFDChoosePath(hWnd, vPath) {
	ControlSetText, Edit1, % vPath, % "ahk_id " hWnd
	ControlFocus, Button2, % "ahk_id " hWnd
	ControlSend, Button2, {Enter}, % "ahk_id " hWnd
}
JEE_CIDGetDir(hWnd) {
	ControlGetText, vDir, ToolbarWindow322, % "ahk_id " hWnd
	if !InStr(vDir, ": ")
		ControlGetText, vDir, ToolbarWindow323, % "ahk_id " hWnd
	vDir := SubStr(vDir, InStr(vDir, ": ")+2)
	vDir := RTrim(vDir, "\")
	if !(SubStr(vDir, 2, 1) = ":")
		if (vDir = "Libraries\Documents")
			vDir := A_MyDocuments
		else if (vDir = "Libraries\Pictures")
			vDir := "C:\Users\" A_UserName "\Pictures"
		else if (vDir = "Libraries\Videos")
			vDir := "C:\Users\" A_UserName "\Videos"
		else if (vDir = A_UserName)
			vDir := "C:\Users\" A_UserName
	return vDir
}
JEE_CIDGetPath(hWnd, vSep:="|") {
	vDir := JEE_CIDGetDir(hWnd)
	ControlGetText, vName, Edit1, % "ahk_id " hWnd
	if (vDir = "Desktop")
	{
		Loop, Files, % A_Desktop "\*", F
		{
			VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
			DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
			if (vDName = vName)
				vOutput .= A_Desktop "\" A_LoopFileName vSep
		}
		vDir := A_DesktopCommon
	}
	if DirExist(vDir)
	{
		Loop, Files, % vDir "\*", F
		{
			VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
			DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
			if (vDName = vName)
				vOutput .= vDir "\" A_LoopFileName vSep
		}
	}
	return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_CIDGetName(hWnd, vSep:="|") {
	vDir := JEE_CIDGetDir(hWnd)
	ControlGetText, vName, Edit1, % "ahk_id " hWnd
	if (vDir = "Desktop")
	{
		Loop, Files, % A_Desktop "\*", F
		{
			VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
			DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
			if (vDName = vName)
				vOutput .= A_LoopFileName vSep
		}
		vDir := A_DesktopCommon
	}
	if DirExist(vDir)
	{
		Loop, Files, % vDir "\*", F
		{
			VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
			DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
			if (vDName = vName)
				vOutput .= A_LoopFileName vSep
		}
	}
	return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_CIDSetDir(hWnd, vDir) {
	if (vDir = "Desktop")
		vDir := A_Desktop
	if !DirExist(vDir)
		return
	vDir2 := JEE_CIDGetDir(hWnd)
	if (vDir = vDir2)
		return

	ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
	ControlSetText, Edit1, % vDir, % "ahk_id " hWnd
	ControlFocus, Button1, % "ahk_id " hWnd
	ControlSend, Button1, {Enter}, % "ahk_id " hWnd
	Loop, 30
	{
		ControlFocus, % vCtlClassNN, % "ahk_id " hWnd
		Sleep, 100
		ControlGetFocus, vCtlClassNN2, % "ahk_id " hWnd
		if (vCtlClassNN = vCtlClassNN2)
			break
	}
}
JEE_CIDSetPath(hWnd, vPath) {
	SplitPath, vPath,, vDir
	if !DirExist(vDir)
		return
	JEE_CFDSetDir(hWnd, vDir)
	ControlGetText, vDName2, Edit1, % "ahk_id " hWnd
	VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
	DllCall("comdlg32\GetFileTitle", Str,vPath, Str,vDName, UShort,260, Short) ;get display name
	if !(vDName = vDName2)
	{
		ControlSetText, Edit1, % vDName, % "ahk_id " hWnd
		SendMessage(0xB1, 0, -1, Edit1, "ahk_id " hWnd) ;EM_SETSEL := 0xB1
	}
	ControlFocus, Edit1, % "ahk_id " hWnd
}
JEE_CIDChoosePath(hWnd, vPath) {
	ControlSetText, Edit1, % vPath, % "ahk_id " hWnd
	ControlFocus, Button1, % "ahk_id " hWnd
	ControlSend, Button1, {Enter}, % "ahk_id " hWnd
}
;gets text from ToolTips and TrayTips
JEE_ToolTipGetText(hWnd) {
	vChars := 1+SendMessage(0xE, 0, 0,, "ahk_id " hWnd) ;WM_GETTEXTLENGTH := 0xE
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	SendMessage(0xD, vChars, &vText,, "ahk_id " hWnd) ;WM_GETTEXT := 0xD
	VarSetCapacity(vText, -1)
	return vText
}
;sets text in ToolTips (but not TrayTips)
JEE_ToolTipSetText(hWnd, vText) {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	WinGet, vPID, PID, % "ahk_id " hWnd
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vSize1 := A_PtrSize=8?72:48
	vSize2 := (StrLen(vText)+1) << !!A_IsUnicode
	if !vIsLocal
	{
		if !hProc := JEE_DCOpenProcess(0x438, 0, vPID)
			return
		if !pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize1+vSize2, 0x3000, 0x4)
			return
		pBuf2 := pBuf + vSize1
	}
	else
		pBuf2 := &vText

	VarSetCapacity(TOOLINFO, vSize1, 0)
	NumPut(vSize1, &TOOLINFO, 0, "UInt") ;cbSize
	NumPut(pBuf2, &TOOLINFO, A_PtrSize=8?48:36, "Ptr") ;lpszText

	if vIsLocal
		SendMessage(A_IsUnicode?0x439:0x40C,, &TOOLINFO,, "ahk_id " hWnd) ;TTM_UPDATETIPTEXTW := 0x439 ;TTM_UPDATETIPTEXTA := 0x40C
	else
	{
		JEE_DCWriteProcessMemory(hProc, pBuf, &TOOLINFO, vSize1, 0)
		JEE_DCWriteProcessMemory(hProc, pBuf2, &vText, vSize2, 0)
		SendMessage(A_IsUnicode?0x439:0x40C,, pBuf,, "ahk_id " hWnd) ;TTM_UPDATETIPTEXTW := 0x439 ;TTM_UPDATETIPTEXTA := 0x40C
		JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)
		JEE_DCCloseHandle(hProc)
	}
}
;FURTHER ADDITIONS
JEE_AccGetTextAll(hWnd:=0, vSep:="`n", vIndent:="`t", vOpt:="") {
	
		/*                              	DESCRIPTION
		
			;vOpt: space-separated list
			;vOpt: n: e.g. n20 ;limit retrieve name to first 20 characters
			;vOpt: v: e.g. v20 ;limit retrieve value to first 20 characters
			
	*/
	
	/*                              	EXAMPLE(s)
	
			; ;e.g.
			; q::
			; WinGet, hWnd, ID, A
			; MsgBox, % Clipboard := JEE_AccGetTextAll(hWnd, "`r`n")
			; return
			
			; ;e.g.
			; q::
			; ControlGet, hCtl, Hwnd,, Edit1, A
			; MsgBox, % Clipboard := JEE_AccGetTextAll(hCtl, "`r`n")
			; return
			
			; ;e.g.
			; q::
			; ControlGetFocus, vCtlClassNN, A
			; ControlGet, hCtl, Hwnd,, % vCtlClassNN, A
			; MsgBox, % Clipboard := JEE_AccGetTextAll(hCtl, "`r`n")
			; return
			
	*/
	
	vLimN := 20, vLimV := 20
	Loop, Parse, vOpt, % " "
	{
		vTemp := A_LoopField
		if (SubStr(vTemp, 1, 1) = "n")
			vLimN := SubStr(vTemp, 2)
		else if (SubStr(vTemp, 1, 1) = "v")
			vLimV := SubStr(vTemp, 2)
	}

	oMem := {}, oPos := {}
	;OBJID_WINDOW := 0x0
	oMem[1, 1] := Acc_ObjectFromWindow(hWnd, 0x0)
	oPos[1] := 1, vLevel := 1
	VarSetCapacity(vOutput, 1000000*2)

	Loop
	{
		if !vLevel
			break
		if !oMem[vLevel].HasKey(oPos[vLevel])
		{
			oMem.Delete(vLevel)
			oPos.Delete(vLevel)
			vLevelLast := vLevel, vLevel -= 1
			oPos[vLevel]++
			continue
		}
		oKey := oMem[vLevel, oPos[vLevel]]

		vName := "", vValue := ""
		if IsObject(oKey)
		{
			vRoleText := Acc_GetRoleText(oKey.accRole(0))
			try vName := oKey.accName(0)
			try vValue := oKey.accValue(0)
		}
		else
		{
			oParent := oMem[vLevel-1,oPos[vLevel-1]]
			vChildId := IsObject(oKey) ? 0 : oPos[vLevel]
			vRoleText := Acc_GetRoleText(oParent.accRole(vChildID))
			try vName := oParent.accName(vChildID)
			try vValue := oParent.accValue(vChildID)
		}
		if (StrLen(vName) > vLimN)
			vName := SubStr(vName, 1, vLimN) "..."
		if (StrLen(vValue) > vLimV)
			vValue := SubStr(vValue, 1, vLimV) "..."
		vName := RegExReplace(vName, "[`r`n]", " ")
		vValue := RegExReplace(vValue, "[`r`n]", " ")

		vAccPath := ""
		if IsObject(oKey)
		{
			Loop, % oPos.Length() - 1
				vAccPath .= (A_Index=1?"":".") oPos[A_Index+1]
		}
		else
		{
			Loop, % oPos.Length() - 2
				vAccPath .= (A_Index=1?"":".") oPos[A_Index+1]
			vAccPath .= " c" oPos[oPos.Length()]
		}
		vOutput .= vAccPath "`t" JEE_StrRept(vIndent, vLevel-1) vRoleText " [" vName "][" vValue "]" vSep

		oChildren := Acc_Children(oKey)
		if !oChildren.Length()
			oPos[vLevel]++
		else
		{
			vLevelLast := vLevel, vLevel += 1
			oMem[vLevel] := oChildren
			oPos[vLevel] := 1
		}
	}
	return SubStr(vOutput, 1, -StrLen(vSep))
}
JEE_SetSelectedText(vText, vWait:=3) {
	;based on ClipPaste by ObiWanKenobi
	;Robust copy and paste routine (function) - Scripts and Functions - AutoHotkey Community
	;https://autohotkey.com/board/topic/111817-robust-copy-and-paste-routine-function/

	WinGet, hWnd, ID, A
	ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		Control, EditPaste, % vText, Edit1, % "ahk_id " hWnd
	else
	{
		ClipSaved := ClipboardAll
		Clipboard := vText
		SendInput, {Shift Down}{Shift Up}{Ctrl Down}{vk56sc02F Down}
		;'PasteWait'
		vWait *= 1000
		vStartTime := A_TickCount
		Sleep, 100
	        while (DllCall("GetOpenClipboardWindow", Ptr) && (A_TickCount-vStartTime < vWait))
			Sleep, 100
		SendInput, {vk56sc02F Up}{Ctrl Up}
		Clipboard := ClipSaved
		ClipSaved := ""
	}
}
JEE_CtlGetText(hCtl, vLim:="", vOpt:="") {
	
	ControlGetText, vText,, % "ahk_id " hCtl
	if !(vLim = "") && (StrLen(vText) > vLim)
		vText := SubStr(vText, 1, vLim) "..."
	if InStr(vOpt, "x")
	{
		vText := StrReplace(vText, "`r", " ")
		vText := StrReplace(vText, "`n", " ")
	}
	return vText
}
