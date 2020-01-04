Global g_center_to_this_hwnd  ; Unconditionally forces all dialogs to center to this window (safer than relying on default below)
OnMessage(WM_COMMNOTIFY, "WM_COMMNOTIFY")

WM_COMMNOTIFY(wParam, lParam, msg, hWnd)
{
	If (wParam = 0x403)         ; Dialog box
	{
        saved_detect_hidden_windows := A_DetectHiddenWindows
        If (g_center_to_this_hwnd == "")
        {
            DetectHiddenWindows, Off
            WinGet, zorder_list, List                   ; The 2nd topmost zorder window is probably the window that opened   
            g_center_to_this_hwnd := zorder_list2       ; the dialog box (the dialog is topmost - 1st zorder window)
        }

        DetectHiddenWindows, On
        ; WinGet, topmost_gui_id, ID, ahk_class AutoHotkeyGUI ahk_exe AutoHotkey.exe
		; If WinExist("ahk_id" topmost_gui_id) ; Window to Center In
		If WinExist("ahk_id " g_center_to_this_hwnd) 
		{
			WinGet, State, MinMax
			If (State = -1)
                WinRestore
            WinGetPos, eX, eY, eW, eH
            Process, Exist
            If WinExist("ahk_class #32770 ahk_pid " ErrorLevel)
            {
                WinGetPos,,,mW,mH
                WinMove, (eW-mW)/2 + eX, (eH-mH)/2 + eY
            }
		}
        DetectHiddenWindows, %saved_detect_hidden_windows%
	}
    Return
}
