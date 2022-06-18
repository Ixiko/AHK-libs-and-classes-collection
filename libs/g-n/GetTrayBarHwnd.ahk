GetTrayBarHwnd() {

	; Based on Sean's GetTrayBar()
	;   http://www.autohotkey.com/forum/topic17314.html

	WinGet, ControlList, ControlList, ahk_class Shell_TrayWnd
    RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)

    Loop, %nTB%
    {
        ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
        hParent := DllCall("GetParent", "Uint", hWnd)
        WinGetClass, sClass, ahk_id %hParent%
        If sClass != SysPager
            Continue
        return hWnd
    }

    return 0
}