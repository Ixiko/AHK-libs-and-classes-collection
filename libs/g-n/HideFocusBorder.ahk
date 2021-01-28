; ==================================================================================================================================
; Hides the focus border for the given GUI control or GUI and all of its children.
; Call the function passing only the HWND of the control / GUI in wParam as only parameter.
; WM_UPDATEUISTATE  -> msdn.microsoft.com/en-us/library/ms646361(v=vs.85).aspx
; The Old New Thing -> blogs.msdn.com/b/oldnewthing/archive/2013/05/16/10419105.aspx
; ==================================================================================================================================
HideFocusBorder(wParam, lParam := "", uMsg := "", hWnd := "") {
   ; WM_UPDATEUISTATE = 0x0128
	Static Affected := [] ; affected controls / GUIs
        , HideFocus := 0x00010001 ; UIS_SET << 16 | UISF_HIDEFOCUS
	     , OnMsg := OnMessage(0x0128, Func("HideFocusBorder"))
	If (uMsg = 0x0128) { ; called by OnMessage()
      If (wParam = HideFocus)
         Affected[hWnd] := True
      Else If Affected[hWnd]
         PostMessage, 0x0128, %HideFocus%, 0, , ahk_id %hWnd%
   }
   Else If DllCall("IsWindow", "Ptr", wParam, "UInt")
	  PostMessage, 0x0128, %HideFocus%, 0, , ahk_id %wParam%
}