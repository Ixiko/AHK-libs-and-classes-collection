;[Acc functions]
;Acc library (MSAA) and AccViewer download links - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=26201

;==================================================

JEE_ExpWinGetText(hWnd, vSep:="`n")
{
	ControlGet, hCtl, Hwnd,, DirectUIHWND3, % "ahk_id " hWnd
	oAcc := Acc_Get("Object", "4", 0, "ahk_id " hCtl)
	for _, oChild in Acc_Children(oAcc)
	{
		if !(oChild.accRole(0) = 0x22) ;ROLE_SYSTEM_LISTITEM := 0x22
			continue
		for _, oChild2 in Acc_Children(oChild)
			if (oChild2.accRole(0) = 0x2A) ;ROLE_SYSTEM_TEXT := 0x2A
			{
				try vOutput .= oChild2.accValue(0) "`t"
				catch
					vOutput .= "`t"
			}
		vOutput := SubStr(vOutput, 1, -1) vSep
	}
	oAcc := oChild := oChild2 := ""
	return SubStr(vOutput, 1, -StrLen(vSep))
}

;==================================================
