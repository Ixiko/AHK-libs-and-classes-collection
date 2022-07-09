;requires:
;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

JEE_ExpWinGetSel(hWnd:=0, vSep:="")
{
	local oItem, oOutput, oWin, oWindows, vCount, vOutput, vWinClass
	DetectHiddenWindows("On")
	(!hWnd) && hWnd := WinExist("A")
	vWinClass := WinGetClass("ahk_id " hWnd)
	if (vWinClass = "CabinetWClass") || (vWinClass = "ExploreWClass")
	{
		for oWin2 in ComObjCreate("Shell.Application").Windows
			if (oWin2.HWND = hWnd)
			{
				oWin := oWin2
				break
			}
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
	if (vSep = "")
	{
		oOutput := []
		for oItem in oWin.Document.SelectedItems
			if !(SubStr(oItem.path, 1, 3) = "::{")
				oOutput.Push(oItem.path)
		oWindows := oWin := oWin2 := oItem := ""
		return oOutput
	}
	else
	{
		vOutput := ""
		VarSetCapacity(vOutput, (260+StrLen(vSep))*vCount*2)
		for oItem in oWin.Document.SelectedItems
			if !(SubStr(oItem.path, 1, 3) = "::{")
				vOutput .= oItem.path vSep
		oWindows := oWin := oWin2 := oItem := ""
		return SubStr(vOutput, 1, -StrLen(vSep))
	}
}
