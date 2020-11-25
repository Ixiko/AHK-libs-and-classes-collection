; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=35041
; Author:	jeeswg
; Date:
; for:     	AHK_L

/*


*/

;functions for Desktop and Explorer folder windows:
;JEE_ExpWinGetFoc ;get focused file
;JEE_ExpWinGetSel ;get selected files (list)
;JEE_ExpWinSetFoc ;set focused file
;JEE_ExpWinSetSel ;set selected files
;JEE_ExpWinGetFileCount ;get file count (selected, total)
;JEE_ExpOpenContainingFolder ;select file(s) in folder (open new window)
;JEE_ExpOpenContainingFolder2 ;select file in folder (open new window)
;JEE_ExpOpenContainingFolderEx ;select file in folder (use existing window, else, open new window)
;JEE_ExpListOpenDirs ;get folders for open Explorer windows (list)
;JEE_ExpWinInvSel ;set selected files: invert selection
;JEE_ExpWinSelAll ;set selected files: select all
;JEE_ExpWinSelNone2 ;set selected files: select none
;JEE_ExpWinSelNone ;set selected files: select none
;JEE_ExpWinGetDir ;get Explorer window folder
;JEE_ExpWinSetDir ;set Explorer window folder (navigate) (or open file/url in new window)
;JEE_ExpWinNewFile ;create new file/folder (create file, focus file, start edit mode)
;JEE_ExpWinSelFirst ;set selected files: jump to first file/folder
;JEE_ExpWinGetText ;get text from visible rows (requires Acc library)

;==================================================

JEE_ExpWinGetFoc(hWnd:=0)
{
	local oItem, oWin, oWindows, vPath, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	vPath := oWin.Document.FocusedItem.path
	oWindows := oWin := oItem := ""
	return vPath
}

;==================================================

JEE_ExpWinGetSel(hWnd:=0, vSep:="`n")
{
	local oItem, oWin, oWindows, vCount, vOutput, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	vCount := oWin.Document.SelectedItems.Count
	vOutput := ""
	VarSetCapacity(vOutput, (260+StrLen(vSep))*vCount*2)
	for oItem in oWin.Document.SelectedItems
		if !(SubStr(oItem.path, 1, 3) = "::{")
			vOutput .= oItem.path vSep
	oWindows := oWin := oItem := ""
	return SubStr(vOutput, 1, -StrLen(vSep))
}

;==================================================

;vByPos allows you to use vName to specify a file by position (1-based index)
JEE_ExpWinSetFoc(hWnd, vName, vByPos:=0, vFlags:=0x1D)
{
	local oItems, oWin, oWindows, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	oItems := oWin.Document.Folder.Items
	;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
	;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
	;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
	if !vByPos
		oWin.Document.SelectItem(oItems.Item(vName), vFlags)
	else
		oWin.Document.SelectItem(oItems.Item(vName-1), vFlags)
	oWindows := oWin := oItems := ""
}

;==================================================

;the first file in the list can be given different flags to the other files
JEE_ExpWinSetSel(hWnd, vList, vSep:="`n", vFlagsF:=0x1D, vFlagsS:=0x1)
{
	local oItems, oWin, oWindows, vFlags, vName, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	oItems := oWin.Document.Folder.Items
	Loop, Parse, vList, % vSep
	{
		;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
		;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
		;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
		vFlags := (A_Index = 1) ? vFlagsF : vFlagsS
		if !InStr(A_LoopField, "\")
			oWin.Document.SelectItem(oItems.Item(A_LoopField), vFlags)
		else
		{
			SplitPath, A_LoopField, vName
			oWin.Document.SelectItem(oItems.Item(vName), vFlags)
		}
	}
	oWindows := oWin := oItems := ""
}

;==================================================

JEE_ExpWinGetFileCount(hWnd, ByRef vCountS, ByRef vCountT)
{
	local oWin, oWindows, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	vCountS := oWin.Document.SelectedItems.count
	vCountT := oWin.Document.Folder.Items.count
	oWindows := oWin := ""
}

;==================================================

JEE_ExpOpenContainingFolder(vList, vSep:="`n")
{
	local ArrayITEMIDLIST, DirITEMIDLIST, PathITEMIDLIST, vComSpec, vCount, vDir, vList2, vPath
	vPath := SubStr(vList, 1, InStr(vList vSep, vSep)-1)
	SplitPath, vPath,, vDir

	;this works but SHOpenFolderAndSelectItems is faster/smoother
	;if !InStr(vList, vSep)
	;{
	;	if FileExist(vPath)
	;	{
	;		vComSpec := A_ComSpec ? A_ComSpec : ComSpec
	;		Run, % vComSpec " /c explorer.exe /select, " Chr(34) vPath Chr(34),, Hide
	;	}
	;	else if InStr(FileExist(vDir), "D")
	;		Run, % vDir
	;	return
	;}

	vList2 := "", vCount := 0
	Loop, Parse, vList, % vSep
		if FileExist(A_LoopField)
			vList2 .= A_LoopField "`n", vCount += 1
	if !vCount
	{
		Run, % vDir
		return
	}
	VarSetCapacity(ArrayITEMIDLIST, vCount*A_PtrSize)
	Loop, Parse, vList, `n
	{
		DllCall("shell32\SHParseDisplayName", Str,A_LoopField, Ptr,0, PtrP,PathITEMIDLIST, UInt,0, Ptr,0)
		NumPut(PathITEMIDLIST, &ArrayITEMIDLIST, (A_Index-1)*A_PtrSize, "Ptr")
	}
	DllCall("ole32\CoInitializeEx", Ptr,0, UInt,0)
	DllCall("shell32\SHParseDisplayName", Str,vDir, Ptr,0, PtrP,DirITEMIDLIST, UInt,0, Ptr,0)
	DllCall("shell32\SHOpenFolderAndSelectItems", Ptr,DirITEMIDLIST, UInt,vCount, Ptr,&ArrayITEMIDLIST, UInt,0)
	DllCall("ole32\CoTaskMemFree", Ptr,DirITEMIDLIST)
	Loop, % vCount
		DllCall("ole32\CoTaskMemFree", Ptr,NumGet(&ArrayITEMIDLIST, (A_Index-1)*A_PtrSize, "Ptr"))
	DllCall("ole32\CoUninitialize")
}
return

;==================================================

JEE_ExpOpenContainingFolder2(vPath)
{
	local vComSpec
	if FileExist(vPath)
	{
		vComSpec := A_ComSpec ? A_ComSpec : ComSpec
		Run, % vComSpec " /c explorer.exe /select, " Chr(34) vPath Chr(34),, Hide
	}
	else if InStr(FileExist(vDir), "D")
		Run, % vDir
}

;==================================================

JEE_ExpOpenContainingFolderEx(vPath)
{
	local oItems, oWin, vComSpec, vDir, vName
	SplitPath, vPath, vName, vDir
	if !FileExist(vPath)
	{
		if FileExist(vDir)
			Run, % vDir
		return
	}
	for oWin in ComObjCreate("Shell.Application").Windows
		if (oWin.Name = "Windows Explorer")
		&& (vDir = oWin.Document.Folder.Self.Path)
		{
			WinActivate, % "ahk_id " oWin.HWND
			;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
			;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
			;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
			oItems := oWin.Document.Folder.Items
			oWin.Document.SelectItem(oItems.Item(vName), 0x1D)
			oWin := oItems := ""
			return
		}
	oWin := ""
	vComSpec := A_ComSpec ? A_ComSpec : ComSpec
	Run, % vComSpec " /c explorer.exe /select, " Chr(34) vPath Chr(34),, Hide
}

;==================================================

JEE_ExpListOpenDirs(vSep:="`n")
{
	local oWin, vOutput
	for oWin in ComObjCreate("Shell.Application").Windows
		if (oWin.Name = "Windows Explorer")
			vOutput .= oWin.Document.Folder.Self.Path vSep
	oWin := ""
	return SubStr(vOutput, 1, -StrLen(vSep))
}

;==================================================

JEE_ExpWinInvSel(hWnd:=0)
{
	(!hWnd) && hWnd := WinExist("A")
	SendMessage, 0x111, 28706, 0, SHELLDLL_DefView1, % "ahk_id " hWnd ;WM_COMMAND := 0x111 ;(invert selection)
}

;==================================================

JEE_ExpWinSelAll(hWnd:=0)
{
	(!hWnd) && hWnd := WinExist("A")
	SendMessage, 0x111, 28705, 0, SHELLDLL_DefView1, % "ahk_id " hWnd ;WM_COMMAND := 0x111 ;(select all)
}

;==================================================

JEE_ExpWinSelNone2(hWnd:=0)
{
	(!hWnd) && hWnd := WinExist("A")
	SendMessage, 0x111, 28705, 0, SHELLDLL_DefView1, % "ahk_id " hWnd ;select all
	SendMessage, 0x111, 28706, 0, SHELLDLL_DefView1, % "ahk_id " hWnd ;invert selection
}

;==================================================

JEE_ExpWinSelNone(hWnd:=0)
{
	local oItem, oItems, oWin, oWindows, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
	;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
	;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
	oItems := oWin.Document.Folder.Items
	oWin.Document.SelectItem(oItems.Item(0), 0x14)
	oWindows := oWin := oItems := ""
}

;==================================================

JEE_ExpWinGetDir(hWnd:=0)
{
	local oWin, oWindows, vDir, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return
	vDir := oWin.Document.Folder.Self.Path
	oWindows := oWin := ""
	return vDir
}

;==================================================

;sets dir (or opens file/url in new window)
JEE_ExpWinSetDir(hWnd, vDir)
{
	local oWin, vPIDL, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if !(vWinClass = "CabinetWClass") && !(vWinClass = "ExploreWClass")
		return
	for oWin in ComObjCreate("Shell.Application").Windows
		if (oWin.HWND = hWnd)
		{
			if !InStr(vDir, "#") || InStr(vDir, "://") ;folders that don't contain #, and urls
				oWin.Navigate(vDir)
			else ;folders that contain #
			{
				DllCall("shell32\SHParseDisplayName", WStr,vDir, Ptr,0, PtrP,vPIDL, UInt,0, Ptr,0)
				VarSetCapacity(SAFEARRAY, A_PtrSize=8?32:24, 0)
				NumPut(1, &SAFEARRAY, 0, "UShort") ;cDims
				NumPut(1, &SAFEARRAY, 4, "UInt") ;cbElements
				NumPut(vPIDL, &SAFEARRAY, A_PtrSize=8?16:12, "Ptr") ;pvData
				NumPut(DllCall("shell32\ILGetSize", Ptr,vPIDL, UInt), &SAFEARRAY, A_PtrSize=8?24:16, "Int") ;rgsabound[1]
				oWin.Navigate2(ComObject(0x2011, &SAFEARRAY), 0)
				DllCall("shell32\ILFree", Ptr,vPIDL)
			}
			break
		}
	oWin := ""
}

;==================================================

;e.g. JEE_ExpWinNewFile(hWnd, "New Text Document", "txt")
;e.g. JEE_ExpWinNewFile(hWnd, "New Folder", "", "d")
;e.g. JEE_ExpWinNewFile(hWnd, "New AutoHotkey Script", "ahk", "mc", "C:\Windows\ShellNew\Template.ahk")

;vOpt: d (dir), m/c (set modified/created dates to now, i.e. for copied template files)
JEE_ExpWinNewFile(hWnd, vNameNoExt, vExt, vOpt:="", vPathTemplate:="")
{
	local oItems, oWin, oWindows, vDir, vFlags, vName, vPath, vSfx, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	vDir := oWin.Document.Folder.Self.Path
	if !InStr(FileExist(vDir), "D")
	{
		oWindows := oWin := ""
		return
	}

	;note: Explorer creates files e.g. 'File, File (2), File (3)', but with no 'File (1)'
	if !(vExt = "")
		vExt := "." vExt
	Loop
	{
		vSfx := (A_Index=1) ? "" : " (" A_Index ")"
		vName := vNameNoExt vSfx vExt
		vPath := vDir "\" vName
		if !FileExist(vPath)
			break
	}
	if InStr(vOpt, "d")
		FileCreateDir, % vPath
	else if (vPathTemplate = "")
		FileAppend,, % vPath
	else
		FileCopy, % vPathTemplate, % vPath

	if InStr(vOpt, "m")
		FileSetTime,, % vPath, M
	if InStr(vOpt, "c")
		FileSetTime,, % vPath, C

	;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
	;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
	;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
	vFlags := WinActive("ahk_id " hWnd) ? 0x1F : 0x1D
	Loop, 30
	{
		oItems := oWin.Document.Folder.Items
		if !(oItems.Item(vName).path = "")
		{
			oWin.Document.SelectItem(oItems.Item(vName), vFlags)
			break
		}
		Sleep 100
	}
	oWindows := oWin := oItems := ""
}

;==================================================

;1=jump to first file, 0=jump to first dir, -1=toggle
;toggle jump to first file/folder
;note: slow on folders with lots of files/folders
JEE_ExpWinSelFirst(hWnd:=0, vOpt:=-1)
{
	local oItem, oItems, oWin, oWindows, vIsDir, vWinClass
	DetectHiddenWindows, On
	(!hWnd) && hWnd := WinExist("A")
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin in ComObjCreate("Shell.Application").Windows
			if (oWin.HWND = hWnd)
				break
	}
	else if (vWinClass = "Progman") || (vWinClass = "WorkerW")
	{
		oWindows := ComObjCreate("Shell.Application").Windows
		VarSetCapacity(hWnd, 4, 0)
		;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
		oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	}
	else
		return

	if (vOpt = -1)
		vIsDir := -!oWin.Document.FocusedItem.IsFolder ;IsFolder returns -1=true, 0=false
	else if (vOpt = 1)
		vIsDir := 0
	else if (vOpt = 0)
		vIsDir := -1
	for oItem in oWin.Document.Folder.Items
		if (vIsDir = oItem.IsFolder)
		{
			;SVSI_FOCUSED = 0x10 ;SVSI_ENSUREVISIBLE := 0x8
			;SVSI_DESELECTOTHERS := 0x4 ;SVSI_EDIT := 0x3
			;SVSI_SELECT := 0x1 ;SVSI_DESELECT := 0x0
			oWin.Document.SelectItem(oItem, 0x1D)
			break
		}
	oWindows := oWin := oItems := ""
}

;==================================================