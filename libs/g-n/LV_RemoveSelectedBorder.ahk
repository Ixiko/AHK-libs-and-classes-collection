LV_RemoveSelBorder(HLV, a*) {
	Static WM_CHANGEUISTATE := 0x127
	     , WM_UPDATEUISTATE := 0x128
	     , UIS_SET := 1
	     , UISF_HIDEFOCUS := 0x1
	     , wParam := (UIS_SET << 16) | (UISF_HIDEFOCUS & 0xffff) ; MakeLong
	     , _ := OnMessage(WM_UPDATEUISTATE, "LV_RemoveSelBorder")
	If (a.2 = WM_UPDATEUISTATE)
		Return 0 ; Prevent alt key from restoring the selection border
	PostMessage, WM_CHANGEUISTATE, wParam, 0,, % "ahk_id " . HLV
}