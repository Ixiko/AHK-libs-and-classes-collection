; ***************************************************************************************************************************
;                   	THIS LIBRARY IS MADE BY JEESWG * taken from AUTOHOTKEY FORUM * date 23.10.2018
;                                   	https://www.autohotkey.com/boards/viewtopic.php?t=58207&start=20
; ***************************************************************************************************************************


JEEGuiText_Load() {
}

/* OTHER LIBRARIES
other libraries:
[Acc.ahk]
Acc library (MSAA) and AccViewer download links - AutoHotkey Community
https://autohotkey.com/boards/viewtopic.php?f=6&t=26201
[JEEAhk1FC.ahk]
commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

functions from other libraries:
JEE_DCXXX (6 functions)
JEE_GetSelectedText
JEE_SetSelectedText
JEE_StrRept
JEE_WinIs64Bit



FUNCTIONS - CONSTANTS



note: throughout this script the following constants are used:

PROCESS_QUERY_INFORMATION := 0x400 ;PROCESS_VM_WRITE := 0x20
PROCESS_VM_READ := 0x10 ;PROCESS_VM_OPERATION := 0x8
e.g. JEE_DCOpenProcess(0x438, 0, vPID)
IsWow64Process - The handle must have the PROCESS_QUERY_INFORMATION access right.
WriteProcessMemory - The handle must have PROCESS_VM_WRITE and PROCESS_VM_OPERATION access to the process.
ReadProcessMemory - The handle must have PROCESS_VM_READ access to the process.

MEM_RESERVE := 0x2000 ;MEM_COMMIT := 0x1000
PAGE_READWRITE := 0x4
e.g. pBuf := JEE_DCVirtualAllocEx(hProc, 0, vSize, 0x3000, 0x4)

MEM_RELEASE := 0x8000
e.g. JEE_DCVirtualFreeEx(hProc, pBuf, 0, 0x8000)

note: the following 6 dll functions are used repeatedly
when interacting with external windows/controls
OpenProcess
VirtualAllocEx
WriteProcessMemory
ReadProcessMemory
VirtualFreeEx
CloseHandle



FUNCTIONS - INTRO



notes:
i: work on internal controls only
r: require remote buffers on external controls (e.g. Edit/Static/Button/ListBox/ComboBox)
a: uses Acc
x: uses an AHK command/function

s: single item selection
m: multiple items selection
z: multiple items (but none typically selected)

note: any 'Get' function for controls with multiple items can return an object
note: JEE_LVXXXText has columns not just items
note: all functions get/set all text, as a variable, by default
note: the user must set DetectHiddenWindows as appropriate, before using each function



FUNCTIONS - SUMMARY



function prefixes

general
Acc	Microsoft Active Accessibility (MSAA)
Win	window

control specific - one item
Edit	Edit
Static	Static
Btn	Button
PB	msctls_progress32
TrB	msctls_trackbar32
RE	RICHEDIT50W
DTP	SysDateTimePick32
MonthCal	SysMonthCal32
HotkeyCtl	msctls_hotkey32
LinkCtl	SysLink
Sci	Scintilla

control specific - multiple items
LB	ListBox
CB	ComboBox
LV	SysListView32
LVH	SysHeader32
TV	SysTreeView32
SB	msctls_statusbar32
TB	ToolbarWindow32
TC	SysTabControl32

further
CFD	Common File Dialog (older-style open/save as prompts)
CID	Common Item Dialog (newer-style open/save as prompts)



total functions (4+37+17+6+22=86)

general (4)
__ JEE_GetSelectedText(vWait:=3)
__ JEE_AccCtlGetText(hWnd, vSep:="`n")
__ JEE_WinGetText(hWnd)
__ JEE_WinSetText(hWnd, vText)

control specific - one item (37)
[Edit,Static,Button,msctls_progress32,msctls_trackbar32,RICHEDIT50W,SysDateTimePick32,SysMonthCal32,msctls_hotkey32,SysLink,Scintilla]
__ JEE_EditGetText(hCtl, vPos1:="", vPos2:="")
__ JEE_EditSetText(hCtl, vText)
__ JEE_EditPaste(hCtl, vText, vCanUndo:=1)
__ JEE_EditGetTextSpecialPlace(hCtl)
__ JEE_EditSetTextSpecialPlace(hCtl, vText)
__ JEE_StaticGetText(hCtl)
__ JEE_StaticSetText(hCtl, vText)
__ JEE_BtnGetText(hCtl)
__ JEE_BtnSetText(hCtl, vText)
__ JEE_PBGetPos(hCtl)
__ JEE_PBSetPos(hCtl, vPos)
__ JEE_TrBGetPos(hCtl)
__ JEE_TrBSetPos(hCtl, vPos)
x_ JEE_REGetText(hCtl)
r_ JEE_RESetText(hCtl, vText, vFlags:=0x0, vCP:=0x0)
i_ JEE_REGetStream(hCtl, vFormat)
i_ JEE_REGetStreamCallback(dwCookie, pbBuff, cb, pcb)
i_ JEE_REGetStreamToFile(hCtl, vFormat, vPath)
i_ JEE_REGetStreamToFileCallback(dwCookie, pbBuff, cb, pcb)
i_ JEE_RESetStream(hCtl, vFormat, vAddr, vSize)
i_ JEE_RESetStreamCallback(dwCookie, pbBuff, cb, pcb)
i_ JEE_RESetStreamFromFile(hCtl, vFormat, vPath)
i_ JEE_RESetStreamFromFileCallback(dwCookie, pbBuff, cb, pcb)
r_ JEE_DTPGetDate(hCtl, vLen:=14)
r_ JEE_DTPSetDate(hCtl, vDate)
r_ JEE_MonthCalGetDate(hCtl, vLen:=14)
r_ JEE_MonthCalSetDate(hCtl, vDate)
a_ JEE_HotkeyCtlGetText(hCtl)
x_ JEE_HotkeyCtlSetText(hCtl, vKeys)
a_ JEE_LinkCtlGetText(hCtl, vDoGetFull:=1)
x_ JEE_LinkCtlSetText(hCtl, vText)
r_ JEE_SciGetText(hCtl, vEnc:="UTF-8")
r_ JEE_SciSetText(hCtl, vText)
r_ JEE_SciPaste(hCtl, vText, vSize:=-1)
x_ JEE_SciGetTextAlt(hCtl, vEnc:="UTF-8")
x_ JEE_SciSetTextAlt(hCtl, vText)
x_ JEE_SciPasteAlt(hCtl, vText)

control specific - multiple items (17)
[ListBox,ComboBox,SysListView32,SysHeader32,SysTreeView32,msctls_statusbar32,ToolbarWindow32,SysTabControl32]
_m JEE_LBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
_m JEE_LBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
_s JEE_CBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
_s JEE_CBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
rm JEE_LVGetText(hCtl, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="")
rm JEE_LVSetText(hCtl, vText, vList:=-1, vCol:=-1, vSep:="`n", vSepTab:="`t", vOpt:="")
rs JEE_LVHGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
rs JEE_LVHSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
rs JEE_TVGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="", vDirPfx:="")
rs JEE_TVSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
rz JEE_SBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
rz JEE_SBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
rz JEE_TBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
rz JEE_TBGetTextPool(hCtl, vList:=-1, vSep:="`n", vOpt:="")
rz JEE_TBSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")
rs JEE_TCGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="")
rs JEE_TCSetText(hCtl, vText, vList:=-1, vSep:="`n", vOpt:="")

control specific - multiple items further (6)
__ JEE_LBInsStr(hCtl, vText, vPos:=-1)
__ JEE_LBDelStr(hCtl, vPos:=-1)
__ JEE_CBInsStr(hCtl, vText, vPos:=-1)
__ JEE_CBDelStr(hCtl, vPos:=-1)
__ JEE_TrayIconRename(hWnd, uID, vWinTitle)
__ JEE_TrayIconModify(hWnd, uID, uMsg, hIcon, vWinTitle)

further (22)
[#32768,#32770,tooltips_class32]
__ JEE_MenuGetText(hWndOrMenu:="", vSep:="`n", vOpt:="")
__ JEE_MenuGetTextAll(hWndOrMenu:="", vSep:="`n", vOpt:="")
__ JEE_MenuItemPosGetText(hMenu, vPos)
__ JEE_MenuItemIDGetText(hMenu, vID)
__ JEE_MenuItemPosSetText(hMenu, vText, vPos)
__ JEE_MenuItemIDSetText(hMenu, vText, vID)
__ JEE_CFDGetDir(hWnd)
__ JEE_CFDGetPath(hWnd)
__ JEE_CFDGetName(hWnd)
__ JEE_CFDGetDirName(hWnd)
__ JEE_CFDSetDir(hWnd, vDir)
__ JEE_CFDSetPath(hWnd, vPath)
__ JEE_CFDGetPathAlt(hWnd, vSep:="|")
__ JEE_CFDChoosePath(hWnd, vPath)
__ JEE_CIDGetDir(hWnd)
__ JEE_CIDGetPath(hWnd, vSep:="|")
__ JEE_CIDGetName(hWnd, vSep:="|")
__ JEE_CIDSetDir(hWnd, vDir)
__ JEE_CIDSetPath(hWnd, vPath)
__ JEE_CIDChoosePath(hWnd, vPath)
__ JEE_ToolTipGetText(hWnd)
__ JEE_ToolTipSetText(hWnd, vText)



maximum string lengths

for the following 8 controls types:
ListBox,ComboBox,SysListView32,SysHeader32,SysTreeView32,ToolbarWindow32,msctls_statusbar32,SysTabControl32
based on investigations here:
GUI: control types and maximum string lengths - AutoHotkey Community
https://autohotkey.com/boards/viewtopic.php?f=5&t=40292

- You can display 5460 characters fine (5641 if include the null) in all 8 control types, beyond that, some controls display blanks (listviews/listview headers/treeviews continue to display fine).
- You can retrieve 65534 (65535 if include the null) characters from one of the items (parts) in a status bar control. The documentation suggests that this is the maximum number of characters you can get, but that you can set a larger number.
- It is not clear what the actual limits of these control types are.



information on getting/setting text and structs:

although getting/setting the text of items
often requires a struct, you usually only need to
set the contents of the struct once,
occasions where indexes in structs need to be
changed for each item:
get/set listview/treeview text
(usually you specify the index in the PostMessage/SendMessage)

LB_GETTEXTLEN, LB_GETTEXT
LB_DELETESTRING, LB_INSERTSTRING

CB_GETLBTEXTLEN, CB_GETLBTEXT
CB_DELETESTRING, CB_INSERTSTRING

LVM_GETITEMTEXTW (LVITEM) (iItem (row)/iSubItem (column) specified in struct)
LVM_SETITEMTEXTW (LVITEM) (iItem (row)/iSubItem (column) specified in struct)

HDM_GETITEMW (HDITEM)
HDM_SETITEMW (HDITEM)

TVM_GETITEMW (TVITEM) (hItem specified in struct)
TVM_SETITEMW (TVITEM) (hItem specified in struct)

SB_GETTEXTW
SB_SETTEXTW

[note: TBBUTTON structs are used to convert indexes to command IDs]
TB_GETBUTTONTEXTW or TB_GETSTRINGW
TB_SETBUTTONINFOW (TBBUTTONINFO)

TCM_GETITEMW (TCITEM)
TCM_SETITEMW (TCITEM)



information on getting text and messages:

when getting strings:
LB_GETTEXTLEN - gives size of string
CB_GETLBTEXTLEN - gives size of string
LVM_GETITEMTEXTW - gives size of string
HDM_GETITEMW - doesn't give size of string
TVM_GETITEMW - doesn't give size of string
SB_GETTEXT - gives size of string
TB_GETBUTTONTEXTW / TB_GETSTRINGW - both give size of string
TCM_GETITEMW - doesn't give size of string



information on listbox controls:

when determining the focused item/selected items:
get focus (single-selection): LB_GETCURSEL/LB_GETCARETINDEX
get selection (single-selection): LB_GETCURSEL/LB_GETCARETINDEX
get focus (multi-selection): LB_GETCURSEL/LB_GETCARETINDEX
get selection (multi-selection): LB_GETSELITEMS


*/

;FUNCTIONS - START

/* ;moved to JEEGen

JEE_GetSelectedText
 ;===============
 ;e.g.
 ;q::
 MouseGetPos,,, hWnd, hCtl, 2
 if (hCtl = "")
 	hCtl := hWnd
 WinGetClass, vWinClass, % "ahk_id " hCtl
 vText := JEE_AccCtlGetText(hCtl, "`r`n")
 MsgBox, % "[" vWinClass "]`r`n" vText
 return
 ;===============

for a list of role types see:
AccViewer Basic - AutoHotkey Community
https://autohotkey.com/boards/viewtopic.php?f=6&t=32039

note: Acc seems able to get text from virtually all controls,
although it appears that it can't get the raw data for
secondary columns in AccViewer, although 'Description'
contains a summary of the secondary columns

hh_kwd_vlist (e.g. AutoHotkey.chm)
MSTaskListWClass (e.g. taskbar)

*/

JEE_AccCtlGetText(hWnd, vSep:="`n") {
	vWinClass := WinGetClass("ahk_id " hWnd)
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

JEE_EditGetTextSpecialPlace(hCtl) {
	
	;The secret life of GetWindowText – The Old New Thing
	;https://blogs.msdn.microsoft.com/oldnewthing/20030821-00/?p=42833
	
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	vPID := WinGetPID("ahk_id " hCtl)
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

JEE_StaticGetText(hCtl) {
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

JEE_BtnSetText(hCtl, vText) {
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
	
	; ;===============
	; ;e.g.
	; ;tested on WordPad (Windows XP and Windows 7 versions)
	; ;q:: ;RichEdit control - set text (RTF)
	; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
	; FormatTime, vDate,, HH:mm dd/MM/yyyy
	; vRtf := "{\rtf{\b " vDate "}}"
	; JEE_RESetText(hCtl, vRtf)
	; return
	; ;===============
	
	vText := ControlGetText(, "ahk_id " hCtl)
	return vText
}

JEE_RESetText(hCtl, vText, vFlags:=0x0, vCP:=0x0) {
	
	; ;===============
	; ;e.g.
	; ;q::
	; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
	; MsgBox, % JEE_REGetStream(hCtl, 0x11)
	; MsgBox, % JEE_REGetStream(hCtl, 0x2)
	; return
	; ;===============

	;only works on internal controls
	
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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

JEE_REGetStream(hCtl, vFormat) {
	static  pFunc := RegisterCallback("JEE_REGetStreamCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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

JEE_REGetStreamToFile(hCtl, vFormat, vPath) {
	;only works on internal controls
	static  pFunc := RegisterCallback("JEE_REGetStreamToFileCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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

JEE_RESetStream(hCtl, vFormat, vAddr, vSize) {
	; ;===============
	; ;e.g.
	; ;q::
	; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
	; FormatTime, vDate,, HH:mm dd/MM/yyyy
	; vRtf := "{\rtf{\b " vDate "}}"
	; VarSetCapacity(vRtf2, 100, 0)
	; vSize := StrPut(vRtf, &vRtf2, "CP0")
	; JEE_RESetStream(hCtl, 0x4002, &vRtf2, vSize)
	; return
	; ;===============

	;only works on internal controls
	
	static pFunc := RegisterCallback("JEE_RESetStreamCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	; ;===============
	; ;e.g.
	; ;q::
	; ControlGet, hCtl, Hwnd,, RICHEDIT50W1, A
	; vPath := A_Desktop "\MyFile.rtf"
	; JEE_RESetStreamFromFile(hCtl, 0x4002, vPath)
	; return
	; ;===============

	;only works on internal controls
	
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

JEE_RESetStreamFromFile(hCtl, vFormat, vPath) {
	static pFunc := RegisterCallback("JEE_RESetStreamFromFileCallback")
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	vPID := WinGetPID("ahk_id " hCtl)
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
	vPID := WinGetPID("ahk_id " hCtl)
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
	vPID := WinGetPID("ahk_id " hCtl)
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vCtlStyle := ControlGetStyle(, "ahk_id " hCtl)
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
	vPID := WinGetPID("ahk_id " hCtl)
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	vCtlStyle := ControlGetStyle(, "ahk_id " hCtl)
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

JEE_HotkeyCtlSetText(hCtl, vKeys) {
	ControlSend(vKeys,, "ahk_id " hCtl)
}

JEE_LinkCtlGetText(hCtl, vDoGetFull:=1) {
	
	; ;===============
	; ;e.g.
	; ;q::
	; ControlGet, hCtl, Hwnd,, SysLink1, A
	; vText = <a href="https://autohotkey.com/">https://autohotkey.com/</a>
	; JEE_LinkCtlSetText(hCtl, vText)
	; return
	; ;===============
	
	if vDoGetFull
	{
		vText := ControlGetText(, "ahk_id " hCtl)
		return vText
	}
	oAcc := Acc_ObjectFromWindow(hCtl)
	vText := oAcc.accName(0)
	oAcc := ""
	return vText
}

JEE_LinkCtlSetText(hCtl, vText) {
	; ;===============
	; ;e.g.
	; ;q::
	; ControlGet, hCtl, Hwnd,, Scintilla1, A
	; MsgBox, % JEE_SciGetText(hCtl)
	; MsgBox, % JEE_SciGetText(hCtl, "CP0")
	; MsgBox, % JEE_SciGetText(hCtl, "UTF-16")
	; return
	; ;===============

	ControlSetText(vText,, "ahk_id " hCtl)
}

JEE_SciGetText(hCtl, vEnc:="UTF-8") {
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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

JEE_SciSetText(hCtl, vText) {
	
	;vSize: the size in bytes
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	vText := ControlGetText(, "ahk_id " hCtl)
	return StrGet(&vText, vEnc)
}

JEE_SciSetTextAlt(hCtl, vText) {
	vSize := StrPut(vText, "UTF-8") + 2
	VarSetCapacity(vUtf8, vSize, 0)
	StrPut(vText, &vUtf8, "UTF-8")
	VarSetCapacity(vUtf8, -1)
	ControlSetText(vUtf8,, "ahk_id " hCtl)
}

JEE_SciPasteAlt(hCtl, vText) {
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: leave blank, there are no options currently
	
	vSize := StrPut(vText, "UTF-8") + 2
	VarSetCapacity(vUtf8, vSize, 0)
	StrPut(vText, &vUtf8, "UTF-8")
	VarSetCapacity(vUtf8, -1)
	ControlEditPaste(vUtf8,, "ahk_id " hCtl)
}

JEE_LBGetText(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: o: return an object instead of a string

	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x18B, 0, 0,, "ahk_id " hCtl) ;LB_GETCOUNT := 0x18B
	if (vCount = 0) || (vCount = vErr) ;LB_ERR := -1
		return
	if (SubStr(vList, 1, 1) = "s")
	{
		vCountSel := SendMessage(0x190,,,, "ahk_id " hCtl) ;LB_GETSELCOUNT := 0x190
		if (vCountSel = vErr) ;LB_ERR := -1 ;returns an error if a single-selection listbox
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
		if (vIndex = vErr) ;LB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		VarSetCapacity(vArray, vCountSel*4, 0)
		vCountSel := SendMessage(0x191, vCountSel, &vArray,, "ahk_id " hCtl) ;LB_GETSELITEMS := 0x191
		if (vCountSel = 0) || (vCountSel = vErr) ;LB_ERR := -1
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
		if (vChars = vErr) ;LB_ERR := -1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: leave blank, there are no options currently
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x18B, 0, 0,, "ahk_id " hCtl) ;LB_GETCOUNT := 0x18B
	if (vCount = 0)
		return
	if (SubStr(vList, 1, 1) = "s")
	{
		vCountSel := SendMessage(0x190,,,, "ahk_id " hCtl) ;LB_GETSELCOUNT := 0x190
		if (vCountSel = vErr) ;LB_ERR := -1 ;returns an error if a single-selection listbox
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
		if (vIndex = vErr) ;LB_ERR := -1
			return
		oArray := [vIndex+1]
	}
	else if (SubStr(vList, 1, 1) = "s")
	{
		oArray := {}
		VarSetCapacity(vArray, vCountSel*4, 0)
		vCountSel := SendMessage(0x191, vCountSel, &vArray,, "ahk_id " hCtl) ;LB_GETSELITEMS := 0x191
		if (vCountSel = 0) || (vCountSel = vErr) ;LB_ERR := -1
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

	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x146, 0, 0,, "ahk_id " hCtl) ;CB_GETCOUNT := 0x146
	if (vCount = 0) || (vCount = vErr) ;CB_ERR := -1
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x147, 0, 0,, "ahk_id " hCtl) ;CB_GETCURSEL := 0x147
		if (vIndex = vErr) ;CB_ERR := -1
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
		if (vChars = vErr) ;CB_ERR := -1
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
		
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCount := SendMessage(0x146, 0, 0,, "ahk_id " hCtl) ;CB_GETCOUNT := 0x146
	if (vCount = 0) || (vCount = vErr) ;CB_ERR := -1
		return
	if IsObject(vList)
		oArray := vList
	else if InStr(vList, ",")
		oArray := StrSplit(vList, ",")
	else if (SubStr(vList, 1, 1) = "f")
	|| (SubStr(vList, 1, 1) = "s")
	{
		vIndex := SendMessage(0x147, 0, 0,, "ahk_id " hCtl) ;CB_GETCURSEL := 0x147
		if (vIndex = vErr) ;CB_ERR := -1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string

	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;count items (rows) and columns
	if !vCount := SendMessage(0x1004, 0, 0,, "ahk_id " hCtl) ;LVM_GETITEMCOUNT := 0x1004
		return
	if !hLVH := SendMessage(0x101F,,,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	if !vCountCol := SendMessage(0x1200,,,, "ahk_id " hLVH) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCountCol = vErr) ;-1
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
		if (vIndex = vErr) ;-1
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
			if (vItem = vErr) ;-1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string
	;hCtl: pass the control hWnd for a SysListView32 or SysHeader32 control
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
	if (vPID = vScriptPID)
		vIsLocal := 1, vPIs64 := (A_PtrSize=8)

	;count items (rows) and columns
	if !vCount := SendMessage(0x1004, 0, 0,, "ahk_id " hCtl) ;LVM_GETITEMCOUNT := 0x1004
		return
	if !hLVH := SendMessage(0x101F,,,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	if !vCountCol := SendMessage(0x1200,,,, "ahk_id " hLVH) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCountCol = vErr) ;-1
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
		if (vIndex = vErr) ;-1
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
			if (vItem = vErr) ;-1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string
	;hCtl: pass the control hWnd for a SysListView32 or SysHeader32 control

	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCtlClass := WinGetClass("ahk_id " hCtl)
	if (vCtlClass = "SysListView32")
	&& !hCtl := SendMessage(0x101F, 0, 0,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	else if !(vCtlClass = "SysHeader32")
		return

	if !vCount := SendMessage(0x1200,,,, "ahk_id " hCtl) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCount = vErr) ;-1
		return

	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vCtlClass := WinGetClass("ahk_id " hCtl)
	if (vCtlClass = "SysListView32")
	&& !hCtl := SendMessage(0x101F, 0, 0,, "ahk_id " hCtl) ;LVM_GETHEADER := 0x101F
		return
	else if !(vCtlClass = "SysHeader32")
		return

	if !vCount := SendMessage(0x1200,,,, "ahk_id " hCtl) ;HDM_GETITEMCOUNT := 0x1200
		return
	if (vCount = vErr) ;-1
		return

	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	
	/* 
		===============
		e.g.
		q::
		 ControlGet, hCtl, Hwnd,, SysTreeView321, A
		 MsgBox, % JEE_TVGetText(hCtl)
		 MsgBox, % JEE_TVGetText(hCtl, "f")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "", "[DIR]")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "p", "[DIR]")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "i", "[DIR]")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "c")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "cp")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "icp")
		 MsgBox, % JEE_TVGetText(hCtl, -1, "`r`n", "icp", "[DIR]")
		 return
		===============
			
		===============
		e.g.
		q:: ;get visible items
		 ControlGet, hCtl, Hwnd,, SysTreeView321, A
		TVGN_NEXTVISIBLE := 0x6 ;TVGN_FIRSTVISIBLE := 0x5
		 oArray := {}, hItem := 0
		 Loop
		 {
			if hItem := SendMessage(0x110A, (A_Index=1)?0x5:0x6, hItem,, "ahk_id " hCtl) ;TVM_GETNEXTITEM := 0x110A
				oArray.Push(hItem)
			else
				break
		 }
		 MsgBox, % JEE_TVGetText(hCtl, oArray)
		 return
		===============

		vList: 1-based comma-separated list or array
		vList: -1/f/s: all/focused/selected items
		vOpt: m#: e.g. m1000, specify max chars 1000
		vOpt: o: return an object instead of a string

		further options:
		vOpt: d: get dirs (list items with children)
		vOpt: f: get files (list items with no children)
		vOpt: p: show full paths
		vOpt: i: indentation on
		vOpt: c: parent name column
		vOpt: o: return an object instead of text

		vList: warning: paths/hierarchy information is only expected to be correct when vList:=-1
		vDirPfx: if specified, a column is added that indicates items that are 'dirs' (that have children)
	 */
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string	
		
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string
	
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
	
	; ;===============
	; ;e.g.
	; ;q:: ;tray icon - get info
	; DetectHiddenWindows, On
	; ControlGet, hTB, Hwnd,, ToolbarWindow321, ahk_class NotifyIconOverflowWindow
	; oTrayInfo := JEE_TBGetText(hTB, -1, "`n", "t")
	; vOutput := ""
	; for vKey1 in oTrayInfo
	; {
	; 	for vKey, vValue in oTrayInfo[vKey1]
	; 		vOutput .= (A_Index=1?"":"|") vKey ": " vValue
	; 	vOutput .= "`r`n"
	; }
	; MsgBox, % vOutput
	; return
	; ;===============

	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string

	;further options:
	;vOpt: t: return object with systray info
	;vOpt: i: list contains IDs not positions
	;vOpt: x: exclude separators (no blank lines for separators)
	;vOpt: c: include command IDs in output
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		if (vIndex = vErr) ;-1
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
		if InStr(vOpt, "x") && (vChars = vErr) ;-1 ;separator
			continue
		else if (vChars = vErr) ;-1 ;separator
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
			vTray := WinGetClass("ahk_id " hWndParent)

			vPID := WinGetPID("ahk_id " hWnd)
			vPName := WinGetProcessName("ahk_id " hWnd)
			vPPath := WinGetProcessPath("ahk_id " hWnd)
			vWinClass := WinGetClass("ahk_id " hWnd)
			vWinTitle := WinGetTitle("ahk_id " hWnd)

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

JEE_TBGetTextPool(hCtl, vList:=-1, vSep:="`n", vOpt:="") {
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		if (vIndex = vErr) ;-1
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
		if (vChars = vErr) ;-1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string

	;further options:
	;vOpt: i: vList contains IDs not positions

	;this may not necessarily work since toolbars
	;can store text in different ways,
	;if multiple items have the same command ID,
	;only the text of one button is set
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		if (vIndex = vErr) ;-1
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
	
	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		if (vIndex = vErr) ;-1
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
	
	;vList: 1-based comma-separated list or array
	;vList: -1/f/s: all/focused/selected items
	;vOpt: m#: e.g. m1000, specify max chars 1000
	;vOpt: o: return an object instead of a string

	vErr := A_PtrSize=8 && JEE_WinIs64Bit(hCtl) ? -1 : 0xFFFFFFFF
	(vList = "") && (vList := -1)
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hCtl)
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
		if (vIndex = vErr) ;-1
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

JEE_TrayIconRename(hWnd, uID, vWinTitle) {
	; ;===============
	; ;e.g.
	; ;q:: ;modify AHK tray icon label
	; DetectHiddenWindows, On
	; ControlGet, hTB, Hwnd,, ToolbarWindow321, ahk_class NotifyIconOverflowWindow
	; oTrayInfo := JEE_TBGetText(hTB, -1, "`n", "t")
	; hWnd := A_ScriptHwnd
	; Loop, % oTrayInfo.MaxIndex()
	; 	if (oTrayInfo[A_Index].hWnd = hWnd)
	; 	{
	; 		uID := oTrayInfo[A_Index].uID
	; 		vWinTitle := "New Title"
	; 		JEE_TrayIconRename(hWnd, uID, vWinTitle)
	; 	}
	; return
	; ;===============

	;rename system tray icon
	
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
	
	;a - pass an hWnd rather than an hMenu: get alt-space menu (sysmenu)
	;c - context menu
	;w - pass an hWnd rather than an hMenu
	;x - exclude items with ID = 0 (separators)
	
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

JEE_MenuGetTextAll(hWndOrMenu:="", vSep:="`n", vOpt:="") {
	
	;get text of menu and all descendant submenus
	;a - pass an hWnd rather than an hMenu: get alt-space menu (sysmenu)
	;c - context menu
	;w - pass an hWnd rather than an hMenu
	;x - exclude items with ID = 0 (separators)
	
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

JEE_MenuItemIDGetText(hMenu, vID) {
	
	;works on internal + external menus
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

JEE_MenuItemPosSetText(hMenu, vText, vPos) 
{
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	DllCall("user32\SetMenuItemInfo", Ptr,hMenu, UInt,vPos-1, Int,1, Ptr,&MENUITEMINFO)
}



;works on internal + external menus

JEE_MenuItemIDSetText(hMenu, vText, vID)
{
	vSize := A_PtrSize=8?80:48
	VarSetCapacity(MENUITEMINFO, vSize, 0)
	NumPut(vSize, &MENUITEMINFO, 0, "UInt") ;cbSize
	;MIIM_STRING := 0x40
	NumPut(0x40, &MENUITEMINFO, 4, "UInt") ;fMask
	NumPut(&vText, &MENUITEMINFO, A_PtrSize=8?56:36, "Ptr") ;dwTypeData
	DllCall("user32\SetMenuItemInfo", Ptr,hMenu, UInt,vID, Int,0, Ptr,&MENUITEMINFO)
}



JEE_CFDGetDir(hWnd)
{
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hWnd)
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



JEE_CFDGetPath(hWnd)
{
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hWnd)
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



JEE_CFDGetName(hWnd)
{
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hWnd)
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

JEE_CFDGetDirName(hWnd)
{
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hWnd)
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



JEE_CFDSetDir(hWnd, vDir)
{
	if !DirExist(vDir)
		return
	vDir2 := JEE_CFDGetDir(hWnd)
	if (vDir = vDir2)
		return

	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	ControlSetText(vDir, "Edit1", "ahk_id " hWnd)
	ControlFocus("Button2", "ahk_id " hWnd)
	ControlSend("{Enter}", "Button2", "ahk_id " hWnd)
	Loop, 30
	{
		ControlFocus(vCtlClassNN, "ahk_id " hWnd)
		Sleep(100)
		vCtlClassNN2 := ControlGetFocus("ahk_id " hWnd)
		if (vCtlClassNN = vCtlClassNN2)
			break
	}
}



JEE_CFDSetPath(hWnd, vPath)
{
	SplitPath(vPath,, vDir)
	if !DirExist(vDir)
		return
	JEE_CFDSetDir(hWnd, vDir)
	vDName2 := ControlGetText("Edit1", "ahk_id " hWnd)
	VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
	DllCall("comdlg32\GetFileTitle", Str,vPath, Str,vDName, UShort,260, Short) ;get display name
	if !(vDName = vDName2)
	{
		ControlSetText(vDName, "Edit1", "ahk_id " hWnd)
		SendMessage(0xB1, 0, -1, Edit1, "ahk_id " hWnd) ;EM_SETSEL := 0xB1
	}
	ControlFocus("Edit1", "ahk_id " hWnd)
}



;combine dir with Edit/listview item
;get the path of the selected listview item
;note: this could return multiple paths, if multiple files have the same display name

JEE_CFDGetPathAlt(hWnd, vSep:="|")
{
	vDir := JEE_CFDGetDir(hWnd)
	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)

	if (vCtlClassNN = "SysListView321")
		vName := ControlGetList("Focused Col1", "SysListView321", "ahk_id " hWnd)
	else
		vName := ControlGetText("Edit1", "ahk_id " hWnd)

	Loop, Files, % vDir "\*", F
	{
		VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
		DllCall("comdlg32\GetFileTitle", Str,A_LoopFileFullPath, Str,vDName, UShort,260, Short) ;get display name
		if (vDName = vName)
			vOutput .= vDir "\" A_LoopFileName vSep
	}
	return SubStr(vOutput, 1, -StrLen(vSep))
}



JEE_CFDChoosePath(hWnd, vPath)
{
	ControlSetText(vPath, "Edit1", "ahk_id " hWnd)
	ControlFocus("Button2", "ahk_id " hWnd)
	ControlSend("{Enter}", "Button2", "ahk_id " hWnd)
}



JEE_CIDGetDir(hWnd)
{
	vDir := ControlGetText("ToolbarWindow322", "ahk_id " hWnd)
	if !InStr(vDir, ": ")
		vDir := ControlGetText("ToolbarWindow323", "ahk_id " hWnd)
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



JEE_CIDGetPath(hWnd, vSep:="|")
{
	vDir := JEE_CIDGetDir(hWnd)
	vName := ControlGetText("Edit1", "ahk_id " hWnd)
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



JEE_CIDGetName(hWnd, vSep:="|")
{
	vDir := JEE_CIDGetDir(hWnd)
	vName := ControlGetText("Edit1", "ahk_id " hWnd)
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



JEE_CIDSetDir(hWnd, vDir)
{
	if (vDir = "Desktop")
		vDir := A_Desktop
	if !DirExist(vDir)
		return
	vDir2 := JEE_CIDGetDir(hWnd)
	if (vDir = vDir2)
		return

	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	ControlSetText(vDir, "Edit1", "ahk_id " hWnd)
	ControlFocus("Button1", "ahk_id " hWnd)
	ControlSend("{Enter}", "Button1", "ahk_id " hWnd)
	Loop, 30
	{
		ControlFocus(vCtlClassNN, "ahk_id " hWnd)
		Sleep(100)
		vCtlClassNN2 := ControlGetFocus("ahk_id " hWnd)
		if (vCtlClassNN = vCtlClassNN2)
			break
	}
}



JEE_CIDSetPath(hWnd, vPath)
{
	SplitPath(vPath,, vDir)
	if !DirExist(vDir)
		return
	JEE_CFDSetDir(hWnd, vDir)
	vDName2 := ControlGetText("Edit1", "ahk_id " hWnd)
	VarSetCapacity(vDName, 260 << !!A_IsUnicode, 0)
	DllCall("comdlg32\GetFileTitle", Str,vPath, Str,vDName, UShort,260, Short) ;get display name
	if !(vDName = vDName2)
	{
		ControlSetText(vDName, "Edit1", "ahk_id " hWnd)
		SendMessage(0xB1, 0, -1, Edit1, "ahk_id " hWnd) ;EM_SETSEL := 0xB1
	}
	ControlFocus("Edit1", "ahk_id " hWnd)
}



JEE_CIDChoosePath(hWnd, vPath)
{
	ControlSetText(vPath, "Edit1", "ahk_id " hWnd)
	ControlFocus("Button1", "ahk_id " hWnd)
	ControlSend("{Enter}", "Button1", "ahk_id " hWnd)
}



;gets text from ToolTips and TrayTips

JEE_ToolTipGetText(hWnd)
{
	vChars := 1+SendMessage(0xE, 0, 0,, "ahk_id " hWnd) ;WM_GETTEXTLENGTH := 0xE
	VarSetCapacity(vText, vChars << !!A_IsUnicode, 0)
	SendMessage(0xD, vChars, &vText,, "ahk_id " hWnd) ;WM_GETTEXT := 0xD
	VarSetCapacity(vText, -1)
	return vText
}



;sets text in ToolTips (but not TrayTips)

JEE_ToolTipSetText(hWnd, vText)
{
	vScriptPID := DllCall("kernel32\GetCurrentProcessId", UInt)
	vPID := WinGetPID("ahk_id " hWnd)
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

;vOpt: space-separated list
;vOpt: n#: e.g. n20 ;limit retrieve name to first 20 characters
;vOpt: v#: e.g. v20 ;limit retrieve value to first 20 characters

JEE_AccGetTextAll(hWnd:=0, vSep:="`n", vIndent:="`t", vOpt:="")
{
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



;moved to JEEGen
;JEE_SetSelectedText



JEE_CtlGetText(hCtl, vLim:="", vOpt:="")
{
	vText := ControlGetText(, "ahk_id " hCtl)
	if !(vLim = "") && (StrLen(vText) > vLim)
		vText := SubStr(vText, 1, vLim) "..."
	if InStr(vOpt, "x")
	{
		vText := StrReplace(vText, "`r", " ")
		vText := StrReplace(vText, "`n", " ")
	}
	return vText
}




;functions from other libraries:
;JEE_DCXXX (6 functions)
;JEE_GetSelectedText
;JEE_SetSelectedText
;JEE_StrRept
;JEE_WinIs64Bit



JEE_DCOpenProcess(vAccess, hInherit, vPID)
{
	return DllCall("kernel32\OpenProcess", UInt,vAccess, Int,hInherit, UInt,vPID, Ptr)
}
JEE_DCVirtualAllocEx(hProc, vAddress, vSize, vAllocType, vProtect)
{
	return DllCall("kernel32\VirtualAllocEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vAllocType, UInt,vProtect, Ptr)
}
JEE_DCWriteProcessMemory(hProc, vBAddress, pBuf, vSize, vWritten)
{
	return DllCall("kernel32\WriteProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vWritten)
}
JEE_DCReadProcessMemory(hProc, vBAddress, pBuf, vSize, vRead)
{
	return DllCall("kernel32\ReadProcessMemory", Ptr,hProc, Ptr,vBAddress, Ptr,pBuf, UPtr,vSize, Ptr,vRead)
}
JEE_DCVirtualFreeEx(hProc, vAddress, vSize, vFreeType)
{
	return DllCall("kernel32\VirtualFreeEx", Ptr,hProc, Ptr,vAddress, UPtr,vSize, UInt,vFreeType)
}
JEE_DCCloseHandle(hObject) ;e.g. hProc
{
	return DllCall("kernel32\CloseHandle", Ptr,hObject)
}



; ;===============
; ;e.g.
; vText := JEE_GetSelectedText()
; ;===============

; ;===============
; ;e.g. get selected text simple alternative
; Clipboard := ""
; SendInput, ^c
; ClipWait, 3
; if ErrorLevel
; {
; 	MsgBox, % "error: failed to retrieve clipboard text"
; 	return
; }
; vText := Clipboard
; ;===============

JEE_GetSelectedText(vWait:=3)
{
	static vIsV1 := !!SubStr(1, 0)
	hWnd := WinGetID("A")
	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		vText := ControlGetSelected(vCtlClassNN, "ahk_id " hWnd)
	else
	{
		ClipSaved := vIsV1 ? ClipboardAll : ClipboardAll()
		Clipboard := ""
		SendInput("^c")
		ClipWait(vWait)
		if ErrorLevel
		{
			ToolTip("ClipWait failed (" A_ThisHotkey ")")
			Clipboard := ClipSaved
			ClipSaved := ""
			Sleep(1000)
			ToolTip()
			Exit() ;terminate the thread that launched this function
		}
		vText := Clipboard
		Clipboard := ClipSaved
		ClipSaved := ""
	}
	return vText
}



JEE_SetSelectedText(vText, vWait:=3)
{
	;adapted from ClipPaste by ObiWanKenobi
	;Robust copy and paste routine (function) - Scripts and Functions - AutoHotkey Community
	;https://autohotkey.com/board/topic/111817-robust-copy-and-paste-routine-function/

	static vIsV1 := !!SubStr(1, 0)
	hWnd := WinGetID("A")
	vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
	if (RegExReplace(vCtlClassNN, "\d") = "Edit")
		ControlEditPaste(vText, "Edit1", "ahk_id " hWnd)
	else
	{
		ClipSaved := vIsV1 ? ClipboardAll : ClipboardAll()
		Clipboard := vText
		SendInput("{Shift Down}{Shift Up}{Ctrl Down}{vk56 Down}") ;vk56 sc02F
		;'PasteWait'
		vWait *= 1000
		vStartTime := A_TickCount
		Sleep(100)
		while (DllCall("user32\GetOpenClipboardWindow", Ptr) && (A_TickCount-vStartTime < vWait))
			Sleep(100)
		SendInput("{vk56 Up}{Ctrl Up}") ;vk56 sc02F
		Clipboard := ClipSaved
		ClipSaved := ""
	}
}



JEE_StrRept(vText, vNum)
{
	if (vNum <= 0)
		return
	return StrReplace(Format("{:" vNum "}","")," ",vText)
	;return StrReplace(Format("{:0" vNum "}",0),0,vText)
}



JEE_WinIs64Bit(hWnd)
{
	vPID := WinGetPID("ahk_id " hWnd)
	if !vPID
		return
	if !A_Is64bitOS
		return 0
	;PROCESS_QUERY_INFORMATION := 0x400
	hProc := DllCall("kernel32\OpenProcess", UInt,0x400, Int,0, UInt,vPID, Ptr)
	DllCall("kernel32\IsWow64Process", Ptr,hProc, PtrP,vIsWow64Process)
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return !vIsWow64Process
}




; http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/
; https://dl.dropbox.com/u/47573473/Web%20Server/AHK_L/Acc.ahk
;------------------------------------------------------------------------------
; Acc.ahk Standard Library
; by Sean
; Updated by jethrow:
; 	Modified ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
; 	Changed ComObjUnwrap to ComObjValue in order to avoid AddRef (thanks fincs)
; 	Added Acc_GetRoleText & Acc_GetStateText
; 	Added additional functions - commented below
; 	Removed original Acc_Children function
; last updated 2/25/2010
;------------------------------------------------------------------------------

Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return	ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
	Return	hWnd
}

Acc_GetRoleText(nRole)
{
	nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
	Return	sRole
}

Acc_GetStateText(nState)
{
	nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
	Return	sState
}

Acc_SetWinEventHook(eventMin, eventMax, pCallback)
{
	Return	DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", 0, "Ptr", pCallback, "Uint", 0, "Uint", 0, "Uint", 0)
}

Acc_UnhookWinEvent(hHook)
{
	Return	DllCall("UnhookWinEvent", "Ptr", hHook)
}
/*	Win Events:
	pCallback := RegisterCallback("WinEventProc")
	WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime)
	{
		Critical
		Acc := Acc_ObjectFromEvent(_idChild_, hWnd, idObject, idChild)
		; Code Here:
	}
*/

; Written by jethrow
Acc_Role(Acc, ChildId=0) {
	try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}
Acc_State(Acc, ChildId=0) {
	try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
}
Acc_Location(Acc, ChildId=0, byref Position="") { ; adapted from Sean's code
	try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	catch
		return
	Position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
	return	{x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}
Acc_Parent(Acc) { 
	try parent:=Acc.accParent
	return parent?Acc_Query(parent):
}
Acc_Child(Acc, ChildId=0) {
	try child:=Acc.accChild(ChildId)
	return child?Acc_Query(child):
}
Acc_Query(Acc) { ; thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530
	try return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
Acc_Error(p="") {
	static setting:=0
	return p=""?setting:setting:=p
}
Acc_Children(Acc) {
	if ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			return Children.MaxIndex()?Children:
		} else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_ChildrenByRole(Acc, Role) {
	if ComObjType(Acc,"Name")!="IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren% {
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
				if NumGet(varChildren,i-8)=9
					AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
				else
					Acc_Role(Acc, child)=Role?Children.Insert(child):
			}
			return Children.MaxIndex()?Children:, ErrorLevel:=0
		} else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj :=   IsObject(WinTitle)? WinTitle
			:   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
	if ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	else {
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			try {
				if A_LoopField is digit
					Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in else-statement
				else
					RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
				if Not Children.HasKey(m2)
					throw
				AccObj := Children[m2]
			} catch {
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				if Acc_Error()
					throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				return
			}
		Acc_Error(AccError)
		StringReplace, Cmd, Cmd, %A_Space%, , All
		properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
		try {
			if (Cmd = "Location")
				AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
			  , ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
			else if (Cmd = "Object")
				ret_val := AccObj
			else if Cmd in Role,State
				ret_val := Acc_%Cmd%(AccObj, ChildID+0)
			else if Cmd in ChildCount,Selection,Focus
				ret_val := AccObj["acc" Cmd]
			else
				ret_val := AccObj["acc" Cmd](ChildID+0)
		} catch {
			ErrorLevel := """" Cmd """ Cmd Not Implemented"
			if Acc_Error()
				throw Exception("Cmd Not Implemented", -1, Cmd)
			return
		}
		return ret_val, ErrorLevel:=0
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}



;AHK v2 functions for AHK v1
;[first released: 2017-03-26]
;[updated: 2018-04-05]

;use at your own risk
;warning: the RegDelete/RegDeleteKey/RegWrite functions are untested

;link:
;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

;functions from AHK v2 not replicated:
;GuiCreate
;GuiCtrlFromHwnd
;GuiFromHwnd
;MenuCreate
;MenuFromHandle

;known issues/limitations:
;CallbackCreate - less functionality than the AHK v2 function
;ClipboardAll - binary variable
;FileAppend - binary variable (RAW)
;FileInstall - will only perform a FileCopy
;FileRead - binary variable (RAW)
;(IniRead) - AHK v2 handles a default value of multiple spaces as a blank
;InputBox - password character
;InputEnd - doesn't fully match AHK v2 function
;ListVars - can only list global variables
;(PostMessage/SendMessage) - currently do not support Var to mean &Var
;Type - doesn't fully match AHK v2 function (and misidentifies a Float as a String)
;WinGetClientPos - not giving the same results as AHK v2
;(WinWait/WinWaitActive) - I've assumed that WinWait/WinWaitActive will return an hWnd in future

;see also (re. functions):
;GitHub - cocobelgica/AutoHotkey-Future: Port of AutoHotkey v2.0-a built-in functions for AHK v1.1+
;https://github.com/cocobelgica/AutoHotkey-Future
;AutoHotkey-Future/Lib at master · cocobelgica/AutoHotkey-Future · GitHub
;https://github.com/cocobelgica/AutoHotkey-Future/tree/master/Lib
;Default/Portable installation StdLib - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=13&t=10434

;see also (re. GUIs):
;objects: backport AHK v2 Gui/Menu classes to AHK v1 - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=43530



BlockInput(Mode)
{
    if Mode in 1,0
        Mode := Mode ? "On" : "Off"
    BlockInput %Mode%
}
CallbackCreate(Function, Options:="", ParamCount:="")
{
    return RegisterCallback(Function, Options, ParamCount)
}
CallbackFree(Address)
{
    DllCall("kernel32\GlobalFree", Ptr,Address, Ptr)
}
CaretGetPos(ByRef OutputVarX:="", ByRef OutputVarY:="")
{
    local GUITHREADINFO, hWnd, hWndC, Mode, OriginX, OriginY, POINT, RECT, TID
    ;this works but there was an issue regarding A_CaretX/A_CaretY not updating correctly:
    ;OutputVarX := A_CaretX, OutputVarY := A_CaretY
    hWnd := WinExist("A")
    VarSetCapacity(GUITHREADINFO, A_PtrSize=8?72:48, 0)
    NumPut(A_PtrSize=8?72:48, &GUITHREADINFO, 0, "UInt") ;cbSize
    TID := DllCall("user32\GetWindowThreadProcessId", Ptr,hWnd, UIntP,0, UInt)
    DllCall("user32\GetGUIThreadInfo", UInt,TID, Ptr,&GUITHREADINFO)
    hWndC := NumGet(&GUITHREADINFO, A_PtrSize=8?48:28, "Ptr") ;hwndCaret
    OutputVarX := NumGet(&GUITHREADINFO, A_PtrSize=8?56:32, "Int") ;rcCaret ;x
    OutputVarY := NumGet(&GUITHREADINFO, A_PtrSize=8?60:36, "Int") ;rcCaret ;y
    Mode := SubStr(A_CoordModeCaret, 1, 1)
    VarSetCapacity(POINT, 8)
    NumPut(OutputVarX, &POINT, 0, "Int")
    NumPut(OutputVarY, &POINT, 4, "Int")
    DllCall("user32\ClientToScreen", Ptr,hWndC, Ptr,&POINT)
    OutputVarX := NumGet(&POINT, 0, "Int")
    OutputVarY := NumGet(&POINT, 4, "Int")
    if (Mode = "S") ;screen
        return
    else if (Mode = "C") ;client
    {
        VarSetCapacity(POINT, 8, 0)
        DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&POINT)
        OriginX := NumGet(&POINT, 0, "Int")
        OriginY := NumGet(&POINT, 4, "Int")
    }
    else if (Mode = "W") ;window
    {
        VarSetCapacity(RECT, 16, 0)
        DllCall("user32\GetWindowRect", Ptr,hWnd, Ptr,&RECT)
        OriginX := NumGet(&RECT, 0, "Int")
        OriginY := NumGet(&RECT, 4, "Int")
    }
    OutputVarX -= OriginX, OutputVarY -= OriginY
}
Click(Params*)
{
    local i, Param, Args
    for i, Param in Params
        Args .= " " . Param
    Click %Args%
}
ClipboardAll(Data:="", Size:="")
{
    ;this function allows the ClipboardAll function to appear in an AHK v1 script without crashing it
    MsgBox warning: the ClipboardAll function doesn't work in AutoHotkey v1
}
ClipWait(SecondsToWait:="", Param:=1)
{
    ClipWait %SecondsToWait%, %Param%
    return !ErrorLevel
}
ControlAddItem(String, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd, Class
    Control Add, %String%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if ErrorLevel
        return
    ControlGet Hwnd, Hwnd,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    WinGetClass Class, ahk_id %Hwnd%
    if InStr(Class, "ListBox")
        SendMessage 0x18B, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;LB_GETCOUNT
    else if InStr(Class, "ComboBox")
        SendMessage 0x146, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;CB_GETCOUNT
    return ErrorLevel
}
ControlChoose(N, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd, Class
    ControlGet Hwnd, Hwnd,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    WinGetClass Class, ahk_id %Hwnd%
    if !(N = 0)
        Control Choose, %N%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    else if InStr(Class, "ListBox")
        SendMessage 0x185, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;LB_SETSEL
    else if InStr(Class, "ComboBox")
        SendMessage 0x14E, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;CB_SETCURSEL
    else
        ErrorLevel := 1
}
ControlChooseString(String, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd, Class
    Control ChooseString, %String%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if ErrorLevel
        return
    ControlGet Hwnd, Hwnd,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    WinGetClass Class, ahk_id %Hwnd%
    if InStr(Class, "ListBox")
        SendMessage 0x188, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;LB_GETCURSEL
    else InStr(Class, "ComboBox")
        SendMessage 0x147, 0, -1, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;CB_GETCURSEL
    return ErrorLevel+1
}
ControlClick(ControlOrPos:="", WinTitle:="", WinText:="", WhichButton:="", ClickCount:="", Options:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlClick %ControlOrPos%, %WinTitle%, %WinText%, %WhichButton%, %ClickCount%, %Options%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlDeleteItem(String, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control Delete, %String%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlEditPaste(String, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control EditPaste, %String%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlFindItem(String, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, FindString, %String%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlFocus(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlFocus %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlGetChecked(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Checked,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetChoice(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Choice,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetCurrentCol(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, CurrentCol,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetCurrentLine(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, CurrentLine,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetEnabled(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Enabled,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetExStyle(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, ExStyle,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetFocus(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGetFocus OutputVar, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !ErrorLevel
        return OutputVar
}
ControlGetHwnd(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Hwnd,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetLine(Index, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Line, %Index%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetLineCount(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, LineCount,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetList(Options:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, List, %Options%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlGetPos X, Y, Width, Height, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlGetSelected(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Selected,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetStyle(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Style,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetTab(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Tab,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlGetText(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGetText OutputVar, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !ErrorLevel
        return OutputVar
}
ControlGetVisible(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    ControlGet OutputVar, Visible,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
ControlHide(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control Hide,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlHideDropDown(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control HideDropDown,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlMove(X:="", Y:="", Width:="", Height:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlMove %Control%, %X%, %Y%, %Width%, %Height%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlSend(Keys, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlSend %Control%, %Keys%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlSendRaw(Keys, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlSendRaw %Control%, %Keys%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlSetChecked(TrueFalseToggle, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Boolean
    ControlGet Boolean, Checked,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (TrueFalseToggle = "Toggle" || TrueFalseToggle == "-1")
        TrueFalseToggle := !Boolean
    if (TrueFalseToggle = "On" || TrueFalseToggle == "1")
        Control Check,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    else if (TrueFalseToggle = "Off" || TrueFalseToggle == "0")
        Control Uncheck,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlSetEnabled(TrueFalseToggle, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Boolean
    ControlGet Boolean, Enabled,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (TrueFalseToggle = "Toggle" || TrueFalseToggle == "-1")
        TrueFalseToggle := !Boolean
    if (TrueFalseToggle = "On" || TrueFalseToggle == "1")
        Control Enable,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    else if (TrueFalseToggle = "Off" || TrueFalseToggle == "0")
        Control Disable,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlSetExStyle(Value, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control ExStyle, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlSetStyle(Value, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control Style, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlSetTab(N, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    SendMessage 0x1330, %N%,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;TCM_SETCURFOCUS
    Sleep 0
    SendMessage 0x130C, %N%,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText% ;TCM_SETCURSEL
}
ControlSetText(NewText, Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    ControlSetText %Control%, %NewText%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
ControlShow(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control Show,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
ControlShowDropDown(Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    Control ShowDropDown,, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
CoordMode(Param1, Param2:="Screen")
{
    CoordMode %Param1%, %Param2%
}
Critical(Param:="")
{
    Critical %Param%
}
DateAdd(DateTime, Time, TimeUnits)
{
    EnvAdd DateTime, %Time%, %TimeUnits%
    return DateTime
}
DateDiff(DateTime1, DateTime2, TimeUnits)
{
    EnvSub DateTime1, %DateTime2%, %TimeUnits%
    return DateTime1
}
DetectHiddenText(OnOrOff)
{
    if OnOrOff in 1,0
        OnOrOff := OnOrOff ? "On" : "Off"
    DetectHiddenText %OnOrOff%
}
DetectHiddenWindows(OnOrOff)
{
    if OnOrOff in 1,0
        OnOrOff := OnOrOff ? "On" : "Off"
    DetectHiddenWindows %OnOrOff%
}
DirCopy(Source, Dest, Flag:=0)
{
    FileCopyDir %Source%, %Dest%, %Flag%
    return !ErrorLevel
}
DirCreate(DirName)
{
    FileCreateDir %DirName%
    return !ErrorLevel
}
DirDelete(DirName, Recurse:=0)
{
    FileRemoveDir %DirName%, %Recurse%
    return !ErrorLevel
}
DirExist(FilePattern)
{
    local AttributeString := FileExist(FilePattern)
    return InStr(AttributeString, "D") ? AttributeString : ""
}
DirMove(Source, Dest, Flag:=0)
{
    FileMoveDir %Source%, %Dest%, %Flag%
    return !ErrorLevel
}
DirSelect(StartingFolder:="", Options:=1, Prompt:="")
{
    local OutputVar
    FileSelectFolder OutputVar, %StartingFolder%, %Options%, %Prompt%
    if !ErrorLevel
        return OutputVar
}
Download(URL, FileName)
{
    UrlDownloadToFile %URL%, %FileName%
    return !ErrorLevel
}
DriveEject(Drive:="", Retract:=false)
{
    Drive Eject, %Drive%, %Retract%
}
DriveGetCapacity(Path)
{
    local OutputVar
    DriveGet OutputVar, Capacity, %Path%
    return OutputVar
}
DriveGetFilesystem(Drive)
{
    local OutputVar
    DriveGet OutputVar, Filesystem, %Drive%
    return OutputVar
}
DriveGetLabel(Drive)
{
    local OutputVar
    DriveGet OutputVar, Label, %Drive%
    return OutputVar
}
DriveGetList(Type:="")
{
    local OutputVar
    DriveGet OutputVar, List, %Type%
    return OutputVar
}
DriveGetSerial(Drive)
{
    local OutputVar
    DriveGet OutputVar, Serial, %Drive%
    return OutputVar
}
DriveGetSpaceFree(Path)
{
    local OutputVar
    DriveSpaceFree OutputVar, %Path%
    return OutputVar
}
DriveGetStatus(Drive)
{
    local OutputVar
    DriveGet OutputVar, Status, %Drive%
    return OutputVar
}
DriveGetStatusCD(Drive:="")
{
    local OutputVar
    DriveGet OutputVar, StatusCD, %Drive%
    return OutputVar
}
DriveGetType(Drive)
{
    local OutputVar
    DriveGet OutputVar, Type, %Drive%
    return OutputVar
}
DriveLock(Drive)
{
    Drive Lock, %Drive%
}
DriveSetLabel(Drive, NewLabel:="")
{
    Drive Label, %Drive%, %NewLabel%
}
DriveUnlock(Drive)
{
    Drive Unlock, %Drive%
}
Edit()
{
    Edit
}
EnvGet(EnvVarName)
{
    local OutputVar
    EnvGet OutputVar, %EnvVarName%
    return OutputVar
}
EnvSet(EnvVar, Value:="")
{
    EnvSet %EnvVar%, %Value%
    return !ErrorLevel
}
Exit(ExitCode:=0)
{
    Exit %ExitCode%
}
ExitApp(ExitCode:=0)
{
    ExitApp %ExitCode%
}
FileAppend(Text, Filename:="", Options:="")
{
    local EOL, Encoding
    Encoding := A_FileEncoding
    EOL := "*"
    Loop Parse, Options, % " `t"
    {
        if (A_LoopField = "`n")
            EOL := ""
        else if (A_LoopField ~= "i)^(UTF-|CP)")
            Encoding := A_LoopField
    }
    FileAppend %Text%, %EOL%%Filename%, %Encoding%
    return !ErrorLevel
}
FileCopy(Source, Dest, Flag:=0)
{
    FileCopy %Source%, %Dest%, %Flag%
    return !ErrorLevel
}
FileCreateShortcut(Target, LinkFile, WorkingDir:="", Args:="", Description:="", IconFile:="", ShortcutKey:="", IconNumber:="", RunState:=1)
{
    FileCreateShortcut %Target%, %LinkFile%, %WorkingDir%, %Args%, %Description%, %IconFile%, %ShortcutKey%, %IconNumber%, %RunState%
    return !ErrorLevel
}
FileDelete(FilePattern)
{
    FileDelete %FilePattern%
    return !ErrorLevel
}
FileEncoding(Encoding:="")
{
    FileEncoding %Encoding%
}
FileGetAttrib(Filename:="")
{
    local OutputVar
    FileGetAttrib OutputVar, %Filename%
    if !ErrorLevel
        return OutputVar
}
FileGetShortcut(LinkFile, ByRef OutTarget:="", ByRef OutDir:="", ByRef OutArgs:="", ByRef OutDescription:="", ByRef OutIcon:="", ByRef OutIconNum:="", ByRef OutRunState:="")
{
    FileGetShortcut %LinkFile%, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
    return !ErrorLevel
}
FileGetSize(Filename:="", Units:="")
{
    local OutputVar
    FileGetSize OutputVar, %Filename%, %Units%
    if !ErrorLevel
        return OutputVar
}
FileGetTime(Filename:="", WhichTime:="M")
{
    local OutputVar
    FileGetTime OutputVar, %Filename%, %WhichTime%
    if !ErrorLevel
        return OutputVar
}
FileGetVersion(Filename:="")
{
    local OutputVar
    FileGetVersion OutputVar, %Filename%
    if !ErrorLevel
        return OutputVar
}
FileInstall(Source, Dest, Flag:=0)
{
    FileCopy %Source%, %Dest%, %Flag%
    return !ErrorLevel
}
FileMove(SourcePattern, DestPattern, Flag:=0)
{
    FileMove %SourcePattern%, %DestPattern%, %Flag%
    return !ErrorLevel
}
FileRead(Filename, Options:="")
{
    local OutputVar, Options2
    Loop Parse, Options, % " `t"
    {
        if (SubStr(A_LoopField, 1, 1) = "m")
            Options2 .= "*" A_LoopField " "
        else if (A_LoopField = "`n")
            Options2 .= "*t "
        else if (SubStr(A_LoopField, 1, 2) = "CP")
            Options2 .= "*" SubStr(A_LoopField, 2) " "
        else if (SubStr(A_LoopField, 1, 5) = "UTF-8")
            Options2 .= "*P65001 "
        else if (SubStr(A_LoopField, 1, 6) = "UTF-16")
            Options2 .= "*P1200 "
    }
    FileRead OutputVar, %Options2%%Filename%
    if !ErrorLevel
        return OutputVar
}
FileRecycle(FilePattern)
{
    FileRecycle %FilePattern%
    return !ErrorLevel
}
FileRecycleEmpty(DriveLetter:="")
{
    FileRecycleEmpty %DriveLetter%
    return !ErrorLevel
}
FileSelect(Options:=0, RootDir_Filename:="", Prompt:="", Filter:="")
{
    local OutputVar
    FileSelectFile OutputVar, %Options%, %RootDir_Filename%, %Prompt%, %Filter%
    if !ErrorLevel
        return OutputVar
}
FileSetAttrib(Attributes, FilePattern:="", Mode:="")
{
    if !RegExMatch(Attributes, "^[+\-\^]")
    {
        FileSetAttrib -RASHOT, %FilePattern%, % InStr(Mode, "D") ? (InStr(Mode, "F") ? 1 : 2) : 0, % !!InStr(Mode, "R")
        Attributes := "+" Attributes
    }
    FileSetAttrib %Attributes%, %FilePattern%, % InStr(Mode, "D") ? (InStr(Mode, "F") ? 1 : 2) : 0, % !!InStr(Mode, "R")
    return !ErrorLevel
}
FileSetTime(YYYYMMDDHH24MISS:="", FilePattern:="", WhichTime:="M", Mode:="")
{
    FileSetTime %YYYYMMDDHH24MISS%, %FilePattern%, %WhichTime%, % InStr(Mode, "D") ? (InStr(Mode, "F") ? 1 : 2) : 0, % !!InStr(Mode, "R")
    return !ErrorLevel
}
FormatTime(YYYYMMDDHH24MISS:="", Format:="")
{
    local OutputVar
    FormatTime OutputVar, %YYYYMMDDHH24MISS%, %Format%
    return OutputVar
}
GroupActivate(GroupName, R:="")
{
    GroupActivate %GroupName%, %R%
    return !ErrorLevel
}
GroupAdd(GroupName, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    GroupAdd %GroupName%, %WinTitle%, %WinText%,, %ExcludeTitle%, %ExcludeText%
}
GroupClose(GroupName, AR:="")
{
    GroupClose %GroupName%, %AR%
}
GroupDeactivate(GroupName, R:="")
{
    GroupDeactivate %GroupName%, %R%
}
Hotkey(Param1, Param2:="", Param3:="")
{
    Hotkey %Param1%, %Param2%, %Param3%
    if (InStr(Param1, "IfWin") || InStr(Param3, "UseErrorLevel"))
        return !ErrorLevel
}
ImageSearch(ByRef OutputVarX:="", ByRef OutputVarY:="", X1:="", Y1:="", X2:="", Y2:="", ImageFile:="")
{
    ImageSearch OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ImageFile%
    return !ErrorLevel
}
IniDelete(Params*) ;Filename, Section, Key
{
    local Filename, Key, Section
    Filename := Params.1
    Section := Params.2
    Key := Params.3
    if (Params.Length() = 3)
        IniDelete %Filename%, %Section%, %Key%
    else if (Params.Length() = 2)
        IniDelete %Filename%, %Section%
    return !ErrorLevel
}
IniRead(Filename, Section:="", Key:="", Default:="")
{
    local OutputVar
    if (Default = "")
        Default := " "
    IniRead OutputVar, %Filename%, %Section%, %Key%, %Default%
    if !ErrorLevel
        return OutputVar
}
IniWrite(Value, Filename, Section, Key:="")
{
    IniWrite %Value%, %Filename%, %Section%, %Key%
    return !ErrorLevel
}
Input(Options:="", EndKeys:="", MatchList:="")
{
    local OutputVar
    Input OutputVar, %Options%, %EndKeys%, %MatchList%
    return OutputVar
}
InputBox(Params*) ;Text, Title, Options, Default
{
    local _, _X, _Y, _W, _H, _T, _P, _Err, Default, Options, Text, Title
    Text := Params.1
    Title := !Params.HasKey(2) ? A_ScriptName : (Params.2 = "") ? " " : Params.2
    Options := Params.3
    Default := Params.4

    ; v2 validates the value of a particular option:
    ; X and Y = integer (can be negative)
    ; W and H = postive integer only
    ; T = postive integer/float
    ; Credits to Lexikos [https://goo.gl/VjMTYu , https://goo.gl/ebEjon]
    RegExMatch(Options, "i)^[ \t]*(?:(?:X(?<X>-?\d+)|Y(?<Y>-?\d+)|W(?<W>\d+)"
        . "|H(?<H>\d+)|T(?<T>\d+(?:\.\d+)?)|(?<P>Password\S?)"
        . "|(?<Err>\S+)(*ACCEPT)"
        . ")(?=[ \t]|$)[ \t]*)*$", _)

    if (_Err != "")
        throw Exception("Invalid option.", -1, _Err)

    local OutputVar
    InputBox, OutputVar, %Title%, %Text%, % _P ? "HIDE" : "", %_W%, %_H%, %_X%, %_Y%,, %_T%, %Default%
    return OutputVar
}
InputEnd()
{
    Input
    return !ErrorLevel
}
KeyHistory()
{
    KeyHistory
}
KeyWait(KeyName, Options:="")
{
    KeyWait %KeyName%, %Options%
    return !ErrorLevel
}
ListHotkeys()
{
    ListHotkeys
}
ListLines(OnOrOff:="")
{
    if OnOrOff in 1,0
        OnOrOff := OnOrOff ? "On" : "Off"
    ListLines %OnOrOff%
}
ListVars()
{
    ; Limitation -> won't work if called from within a function
    global
    ListVars
}
MenuSelect(WinTitle:="", WinText:="", Menu:="", SubMenu1:="", SubMenu2:="", SubMenu3:="", SubMenu4:="", SubMenu5:="", SubMenu6:="", ExcludeTitle:="", ExcludeText:="")
{
    WinMenuSelectItem %WinTitle%, %WinText%, %Menu%, %SubMenu1%, %SubMenu2%, %SubMenu3%, %SubMenu4%, %SubMenu5%, %SubMenu6%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
MonitorGet(N:="", ByRef OutLeft:="", ByRef OutTop:="", ByRef OutRight:="", ByRef OutBottom:="")
{
    local Out
    SysGet Out, Monitor, %N%
    return (OutLeft != "" && OutTop != "" && OutRight != "" && OutBottom != "")
}
MonitorGetCount()
{
    local OutputVar
    SysGet OutputVar, MonitorCount
    return OutputVar
}
MonitorGetName(N:="")
{
    local OutputVar
    SysGet OutputVar, MonitorName
    return OutputVar
}
MonitorGetPrimary()
{
    local OutputVar
    SysGet OutputVar, MonitorPrimary
    return OutputVar
}
MonitorGetWorkArea(N:="", ByRef OutLeft:="", ByRef OutTop:="", ByRef OutRight:="", ByRef OutBottom:="")
{
    local Out
    SysGet Out, MonitorWorkArea, %N%
    return (OutLeft != "" && OutTop != "" && OutRight != "" && OutBottom != "")
}
MouseClick(WhichButton:="Left", X:="", Y:="", ClickCount:="", Speed:="", DU:="", R:="")
{
    MouseClick %WhichButton%, %X%, %Y%, %ClickCount%, %Speed%, %DU%, %R%
}
MouseClickDrag(WhichButton, X1:="", Y1:="", X2:="", Y2:="", Speed:="", R:="")
{
    MouseClickDrag %WhichButton%, %X1%, %Y1%, %X2%, %Y2%, %Speed%, %R%
}
MouseGetPos(ByRef OutputVarX:="", ByRef OutputVarY:="", ByRef OutputVarWin:="", ByRef OutputVarControl:="", Mode:=0)
{
    MouseGetPos OutputVarX, OutputVarY, OutputVarWin, OutputVarControl, %Mode%
    OutputVarWin += 0
    if (Mode & 2)
        OutputVarControl += 0
}
MouseMove(X, Y, Speed:="", R:="")
{
    MouseMove %X%, %Y%, %Speed%, %R%
}
MsgBox(Params*) ;Text, Title, Options
{
    local Match, Options, Result, Temp, Text, Timeout, Title, Type
    static TypeArray := {"OK":0, "O":0, "OKCancel":1, "O/C":1, "OC":1, "AbortRetryIgnore":2, "A/R/I":2, "ARI":2
        , "YesNoCancel":3, "Y/N/C":3, "YNC":3, "YesNo":4, "Y/N":4, "YN":4, "RetryCancel":5, "R/C":5, "RC":5
        , "CancelTryAgainContinue":6, "C/T/C":6, "CTC":6, "Iconx":16, "Icon?":32, "Icon!":48, "Iconi":64
        , "Default2":256, "Default3":512, "Default4":768}

    Text := !Params.Length() ? "Press OK to continue." : Params.HasKey(1) ? Params.1 : ""
    Title := !Params.HasKey(2) ? A_ScriptName : (Params.2 = "") ? " " : Params.2
    Options := Params.3, Timeout := "", Type := 0
    if (Options)
    {
        Loop, Parse, Options, % " `t"
            (Temp := Abs(A_LoopField)) || (Temp := TypeArray[A_LoopField]) ? (Type |= Temp)
                : RegExMatch(A_LoopField, "Oi)^T(\d+\.?\d*)$", Match) ? Timeout := Match.1
                : 0
    }
    MsgBox % Type, % Title, % Text, % Timeout
    Loop Parse, % "Timeout,OK,Cancel,Yes,No,Abort,Ignore,Retry,Continue,TryAgain", % ","
        IfMsgBox % Result := A_LoopField
            break
    return Result
}
OutputDebug(Text)
{
    OutputDebug %Text%
}
Pause(Mode:="", OperateOnUnderlyingThread:=0)
{
    if Mode in 1,0,-1 ; On,Off,Toggle
        Mode := Mode == -1 ? "Toggle" : Mode ? "On" : "Off"
    Pause %Mode%, %OperateOnUnderlyingThread%
}
PixelGetColor(X, Y, AltSlow:="")
{
    local OutputVar
    PixelGetColor OutputVar, %X%, %Y%, %AltSlow% RGB ; v2 uses RGB
    if !ErrorLevel
        return OutputVar
}
PixelSearch(ByRef OutputVarX:="", ByRef OutputVarY:="", X1:="", Y1:="", X2:="", Y2:="", ColorID:="", Variation:=0, Fast:="")
{
    PixelSearch OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ColorID%, %Variation%, %Fast% RGB
    return !ErrorLevel
}
PostMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    PostMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    ErrorLevel := (ErrorLevel = "FAIL")
    ;PostMessage returns an empty string.
}
ProcessClose(PIDorName)
{
    Process Close, %PIDorName%
    return ErrorLevel
}
ProcessExist(PIDorName:="")
{
    Process Exist, %PIDorName%
    return ErrorLevel
}
ProcessSetPriority(Priority, PIDorName:="")
{
    Process Priority, %PIDorName%, %Priority%
    return ErrorLevel
}
ProcessWait(PIDorName, SecondsToWait:="")
{
    Process Wait, %PIDorName%, %SecondsToWait%
    return ErrorLevel
}
ProcessWaitClose(PIDorName, SecondsToWait:="")
{
    Process WaitClose, %PIDorName%, %SecondsToWait%
    return ErrorLevel
}
Random(Min:="", Max:="")
{
    local OutputVar
    Random OutputVar, %Min%, %Max%
    return OutputVar
}
RandomSeed(NewSeed)
{
    Random , %NewSeed%
}
RegDelete(Params*) ;KeyName, ValueName
{
    ;MsgBox, % "REGDELETE"
    if (Params.Length() = 1)
        Params[2] := "AHK_DEFAULT"
    if Params.Length()
    {
        if InStr(Params[1], "\")
            RegDelete % Params[1], % Params[2]
        else
            RegDelete % Params[1],, % Params[2]
    }
    else
    {
        if (A_LoopRegType = "KEY")
            ErrorLevel := 1
        else if (A_LoopRegName = "")
            RegDelete %A_LoopRegKey%, %A_LoopRegSubkey%, AHK_DEFAULT
        else
            RegDelete %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%
    }
    return !ErrorLevel
}
RegDeleteKey(KeyName:="")
{
    ;MsgBox, % "REGDELETEKEY"
    if !(A_LoopRegSubkey = "")
        RegDelete %A_LoopRegKey%
    else if !(A_LoopRegKey = "")
        RegDelete %A_LoopRegKey%\%A_LoopRegSubkey%
    else
        RegDelete %KeyName%
    return !ErrorLevel
}
RegRead(Params*) ;KeyName, ValueName
{
    local OutputVar
    if Params.Length()
    {
        if InStr(Params[1], "\")
            RegRead OutputVar, % Params[1], % Params[2]
        else
            RegRead OutputVar, % Params[1],, % Params[2]
    }
    else
    {
        if (A_LoopRegType = "KEY")
            ErrorLevel := 1
        else
            RegRead OutputVar, %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%
    }
    if !ErrorLevel
        return OutputVar
}
RegWrite(Params*) ;Value, ValueType, KeyName, ValueName
{
    ;if !(Params.3 = "HKEY_CURRENT_USER\Software\Microsoft\Notepad")
        ;MsgBox, % "REGWRITE`r`n" JEE_ObjPreview(Params)
    if (Params.Length() > 2)
    {
        if InStr(Params[3], "\")
            RegWrite % Params[2], % Params[3], % Params[4], % Params[1]
        else
            RegWrite % Params[2], % Params[3],, % Params[4], % Params[1]
    }
    else if (Params.Length() = 1)
    {
        if (A_LoopRegType = "KEY")
            ErrorLevel := 1
        else
            RegWrite %A_LoopRegType%, %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%, % Params[1]
    }
    else if (Params.Length() = 0)
    {
        if (A_LoopRegType = "KEY")
            ErrorLevel := 1
        else if InStr(A_LoopRegType, "_SZ")
            RegWrite %A_LoopRegType%, %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%, % ""
        else
            RegWrite %A_LoopRegType%, %A_LoopRegKey%, %A_LoopRegSubkey%, %A_LoopRegName%, 0
    }
    return !ErrorLevel
}
Reload()
{
    Reload
}
Run(Target, WorkingDir:="", Options:="", ByRef OutputVarPID:="")
{
    Run %Target%, %WorkingDir%, %Options%, OutputVarPID
    if InStr(Options, "UseErrorLevel")
        return !ErrorLevel
}
RunAs(User:="", Password:="", Domain:="")
{
    RunAs %User%, %Password%, %Domain%
}
RunWait(Target, WorkingDir:="", Options:="", ByRef OutputVarPID:="")
{
    RunWait %Target%, %WorkingDir%, %Options%, OutputVarPID
    return ErrorLevel
}
Send(Keys)
{
    Send %Keys%
}
SendEvent(Keys)
{
    SendEvent %keys%
}
SendInput(Keys)
{
    SendInput %Keys%
}
SendLevel(Level)
{
    SendLevel %Level%
}
SendMessage(Msg, wParam:="", lParam:="", Control:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="", Timeout:="")
{
    local MsgReply
    SendMessage %Msg%, %wParam%, %lParam%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%, %Timeout%
    MsgReply := (ErrorLevel = "FAIL") ? "" : ErrorLevel
    ErrorLevel := (ErrorLevel = "FAIL")
    return MsgReply
}
SendMode(Mode)
{
    SendMode %Mode%
}
SendPlay(Keys)
{
    SendPlay %Keys%
}
SendRaw(Keys)
{
    SendRaw %Keys%
}
SetCapsLockState(State:="")
{
    if State in 1,0
        State := State ? "On" : "Off"
    SetCapsLockState %State%
}
SetControlDelay(Delay)
{
    SetControlDelay %Delay%
}
SetDefaultMouseSpeed(Speed)
{
    SetDefaultMouseSpeed %Speed%
}
SetKeyDelay(Delay:="", PressDuration:="", Play:="")
{
    SetKeyDelay %Delay%, %PressDuration%, %Play%
}
SetMouseDelay(Delay, Play:="")
{
    SetMouseDelay %Delay%, %Play%
}
SetNumLockState(State:="")
{
    if State in 1,0
        State := State ? "On" : "Off"
    SetNumLockState %State%
}
SetRegView(RegView)
{
    SetRegView %RegView%
}
SetScrollLockState(State:="")
{
    if State in 1,0
        State := State ? "On" : "Off"
    SetScrollLockState %State%
}
SetStoreCapsLockMode(OnOrOff)
{
    if OnOrOff in 1,0
        OnOrOff := OnOrOff ? "On" : "Off"
    SetStoreCapsLockMode %OnOrOff%
}
SetTimer(Label:="", Period:="", Priority:=0)
{
    SetTimer %Label%, %Period%, %Priority%
}
SetTitleMatchMode(MatchModeOrSpeed)
{
    SetTitleMatchMode %MatchModeOrSpeed%
}
SetWinDelay(Delay)
{
    SetWinDelay %Delay%
}
SetWorkingDir(DirName)
{
    SetWorkingDir %DirName%
    return !ErrorLevel
}
Shutdown(Code)
{
    Shutdown %Code%
}
Sleep(DelayInMilliseconds)
{
    Sleep %DelayInMilliseconds%
}
Sort(String, Options:="")
{
    Sort String, %Options%
    return String
}
SoundBeep(Frequency:=523, Duration:=150)
{
    SoundBeep %Frequency%, %Duration%
}
SoundGet(ComponentType:="", ControlType:="", DeviceNumber:="")
{
    local OutputVar
    SoundGet OutputVar, %ComponentType%, %ControlType%, %DeviceNumber%
    if !ErrorLevel
        return OutputVar
}
SoundPlay(Filename, Wait:="")
{
    SoundPlay %Filename%, %Wait%
    return !ErrorLevel
}
SoundSet(NewSetting, ComponentType:="", ControlType:="", DeviceNumber:="")
{
    SoundSet %NewSetting%, %ComponentType%, %ControlType%, %DeviceNumber%
    return !ErrorLevel
}
SplitPath(Path, ByRef OutFileName:="", ByRef OutDir:="", ByRef OutExtension:="", ByRef OutNameNoExt:="", ByRef OutDrive:="")
{
    SplitPath % Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}
StatusBarGetText(PartNum:=1, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    StatusBarGetText OutputVar, %PartNum%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !ErrorLevel
        return OutputVar
}
StatusBarWait(BarText:="", Seconds:="", PartNum:=1, WinTitle:="", WinText:="", Interval:=50, ExcludeTitle:="", ExcludeText:="")
{
    StatusBarWait %BarText%, %Seconds%, %PartNum%, %WinTitle%, %WinText%, %Interval%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
StringCaseSense(OnOffLocale)
{
    StringCaseSense %OnOffLocale%
}
StrLower(String, T:="")
{
    local OutputVar
    StringLower OutputVar, String, %T%
    return OutputVar
}
StrUpper(String, T:="")
{
    local OutputVar
    StringUpper OutputVar, String, %T%
    return OutputVar
}
Suspend(Mode:="Toggle")
{
    if Mode in 1,0,-1 ; On,Off,Toggle
        Mode := Mode == -1 ? "Toggle" : Mode ? "On" : "Off"
    Suspend %Mode%
}
SysGet(SubCommand)
{
    local OutputVar
    SysGet OutputVar, %SubCommand%
    return OutputVar
}
Thread(Param1, Param2:="", Param3:="")
{
    Thread %Param1%, %Param2%, %Param3%
}
ToolTip(Text:="", X:="", Y:="", WhichToolTip:=1)
{
    ToolTip %Text%, %X%, %Y%, %WhichToolTip%
}
TraySetIcon(FileName:="", IconNumber:="", Freeze:="")
{
    Menu Tray, Icon, %FileName%, %IconNumber%, %Freeze%
}
TrayTip(Params*) ;Text, Title, Options
{
    local Num := 0, Options, Text, Title
    Text := !Params.HasKey(1) ? " " : (Params.1 = "") ? " " : Params.1
    Title := !Params.HasKey(2) ? "" : Params.2
    Options := Params.HasKey(3) ? Params.3 : 0
    Loop Parse, Options, % " `t"
    {
        (A_LoopField = "Iconi") ? (Num |= 1) : ""
        (A_LoopField = "Icon!") ? (Num |= 2) : ""
        (A_LoopField = "Iconx") ? (Num |= 3) : ""
        (A_LoopField = "Mute") ? (Num |= 16) : ""
        if A_LoopField is integer
            Num |= A_LoopField
    }
    TrayTip %Title%, %Text%,, %Num%
}
Type(Value)
{
    local m, f, e
    if IsObject(Value)
    {
        static nMatchObj  := NumGet(&(m, RegExMatch("", "O)", m)))
        static nBoundFunc := NumGet(&(f := Func("Func").Bind()))
        static nFileObj   := NumGet(&(f := FileOpen("*", "w")))
        static nEnumObj   := NumGet(&(e := ObjNewEnum({})))

        return ObjGetCapacity(Value) != ""  ? "Object"
             : IsFunc(Value)                ? "Func"
             : ComObjType(Value) != ""      ? "ComObject"
             : NumGet(&Value) == nBoundFunc ? "BoundFunc"
             : NumGet(&Value) == nMatchObj  ? "RegExMatchObject"
             : NumGet(&Value) == nFileObj   ? "FileObject"
             : NumGet(&Value) == nEnumObj   ? "Object::Enumerator"
             :                                "Property"
    }
    else if (ObjGetCapacity([Value], 1) != "")
        return "String"
    else
        return InStr(Value, ".") ? "Float" : "Integer"
}
WinActivate(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinActivate %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinActivateBottom(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinActivateBottom %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinClose(WinTitle:="", WinText:="", SecondsToWait:="", ExcludeTitle:="", ExcludeText:="")
{
    WinClose %WinTitle%, %WinText%, %SecondsToWait%, %ExcludeTitle%, %ExcludeText%
}
WinGetClass(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGetClass OutputVar, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local hWnd, RECT
    hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
    X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
    Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}
WinGetControls(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, ControlList, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return StrSplit(OutputVar, "`n")
}
WinGetControlsHwnd(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar, ControlsHwnd, i
    WinGet OutputVar, ControlListHwnd, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    ControlsHwnd := StrSplit(OutputVar, "`n")
    for i in ControlsHwnd
        ControlsHwnd[i] += 0
    return ControlsHwnd
}
WinGetCount(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, Count, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetExStyle(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, ExStyle, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar + 0
}
WinGetID(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar + 0
}
WinGetIDLast(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, IDLast, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar + 0
}
WinGetList(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar, List
    WinGet OutputVar, List, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    List := []
    Loop % OutputVar
        List.Push(OutputVar%A_Index% + 0)
    return List
}
WinGetMinMax(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, MinMax, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetPID(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, PID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinGetPos X, Y, Width, Height, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinGetProcessName(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, ProcessName, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetProcessPath(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, ProcessPath, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetStyle(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, Style, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar + 0
}
WinGetText(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGetText OutputVar, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if !ErrorLevel
        return OutputVar
}
WinGetTitle(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGetTitle OutputVar, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetTransColor(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, TransColor, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinGetTransparent(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local OutputVar
    WinGet OutputVar, Transparent, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return OutputVar
}
WinHide(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinHide %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinKill(WinTitle:="", WinText:="", SecondsToWait:="", ExcludeTitle:="", ExcludeText:="")
{
    WinKill %WinTitle%, %WinText%, %SecondsToWait%, %ExcludeTitle%, %ExcludeText%
}
WinMaximize(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinMaximize %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinMinimize(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinMinimize %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinMinimizeAll()
{
    WinMinimizeAll
}
WinMinimizeAllUndo()
{
    WinMinimizeAllUndo
}
WinMove(Params*) ;X, Y [, Width, Height, WinTitle, WinText, ExcludeTitle, ExcludeText]
{
    local WinTitle, WinText, X, Y, Width, Height, ExcludeTitle, ExcludeText
    local Len
    if (Len := Params.Length())
    {
        if (Len > 2)
        {
            X            := Params[1]
            Y            := Params[2]
            Width        := Params[3]
            Height       := Params[4]
            WinTitle     := Params[5]
            WinText      := Params[6]
            ExcludeTitle := Params[7]
            ExcludeText  := Params[8]
            WinMove %WinTitle%, %WinText%, %X%, %Y%, %Width%, %Height%, %ExcludeTitle%, %ExcludeText%
        }
        else
        {
            X := Params[1]
            Y := Params[2]
            WinMove %X%, %y%
        }
    }
    else
        WinMove
}
WinMoveBottom(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet Bottom,, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinMoveTop(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet Top,, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinRedraw(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet Redraw,, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinRestore(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinRestore %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinSetAlwaysOnTop(Value:="Toggle", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd
    WinGet Hwnd, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (!Hwnd)
        return 0

    if Value in 1,0,-1 ; On,Off,Toggle
        Value := Value == -1 ? "Toggle" : Value ? "On" : "Off"

    if Value not in On,Off,Toggle
        throw Exception("Parameter #1 invalid.", -1) ; v2 raises an error

    WinSet AlwaysOnTop, %Value%, ahk_id %Hwnd%
    return 1
}
WinSetEnabled(Value, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd
    WinGet Hwnd, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (!Hwnd)
        return 0

    ; 1, 0 and -1 are compared as strings, non-integer values(e.g.: 1.0) are not allowed
    local Style
    if (Value = "Toggle" || Value == "-1")
    {
        WinGet Style, Style, ahk_id %Hwnd%
        Value := (Style & 0x8000000) ? "On" : "Off" ; WS_DISABLED = 0x8000000
    }

    if (Value = "On" || Value == "1")
        WinSet Enable,, ahk_id %Hwnd%
    else if (Value = "Off" || Value == "0")
        WinSet Disable,, ahk_id %Hwnd%
    else
        throw Exception("Paramter #1 invalid.", -1) ; v2 raises an error
    return 1
}
WinSetExStyle(N, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet ExStyle, %N%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
WinSetRegion(Options:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet Region, %Options%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
WinSetStyle(N, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinSet Style, %N%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
WinSetTitle(NewTitle, Params*) ;NewTitle [, WinTitle, WinText, ExcludeTitle, ExcludeText]
{
    local WinTitle, WinText, ExcludeTitle, ExcludeText
    if (Params.Length())
    {
        WinTitle     := Params[1]
        WinText      := Params[2]
        ExcludeTitle := Params[3]
        ExcludeText  := Params[4]
        WinSetTitle %WinTitle%, %WinText%, %NewTitle%, %ExcludeTitle%, %ExcludeText%
    }
    else
        WinSetTitle %NewTitle%
}
WinSetTransColor(ColorN, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd
    WinGet Hwnd, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (!Hwnd)
        return 0

    WinSet TransColor, %ColorN%, ahk_id %Hwnd%
    return 1
}
WinSetTransparent(N, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local Hwnd
    WinGet Hwnd, ID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    if (!Hwnd)
        return 0

    WinSet Transparent, %N%, ahk_id %Hwnd%
    return 1
}
WinShow(WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    WinShow %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
}
WinWait(WinTitle:="", WinText:="", Seconds:="", ExcludeTitle:="", ExcludeText:="")
{
    WinWait %WinTitle%, %WinText%, %Seconds%, %ExcludeTitle%, %ExcludeText%
    return ErrorLevel ? 0 : WinExist()
}
WinWaitActive(WinTitle:="", WinText:="", Seconds:="", ExcludeTitle:="", ExcludeText:="")
{
    WinWaitActive %WinTitle%, %WinText%, %Seconds%, %ExcludeTitle%, %ExcludeText%
    return ErrorLevel ? 0 : WinExist()
}
WinWaitClose(WinTitle:="", WinText:="", Seconds:="", ExcludeTitle:="", ExcludeText:="")
{
    WinWaitClose %WinTitle%, %WinText%, %Seconds%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}
WinWaitNotActive(WinTitle:="", WinText:="", Seconds:="", ExcludeTitle:="", ExcludeText:="")
{
    WinWaitNotActive %WinTitle%, %WinText%, %Seconds%, %ExcludeTitle%, %ExcludeText%
    return !ErrorLevel
}

;A_TrayMenu.ClickCount
class A_TrayMenu
{
	static varClickCount := 2
	ClickCount[]
	{
		get
		{
			return this.varClickCount
		}
		set
		{
			Menu, Tray, Click, % value
			return this.varClickCount := value
		}
	}
}



;old version:
;CaretGetPos(ByRef OutputVarX:="", ByRef OutputVarY:="")
;{
;    OutputVarX := A_CaretX, OutputVarY := A_CaretY
;}

;hoped-for version (with added Format parameter):
;DateAdd(DateTime, Time, TimeUnits, Format:="yyyyMMddHHmmss")
;{
;    EnvAdd DateTime, %Time%, %TimeUnits%
;    if !(Format == "yyyyMMddHHmmss")
;        FormatTime DateTime, %DateTime%, %Format%
;    return DateTime
;}

