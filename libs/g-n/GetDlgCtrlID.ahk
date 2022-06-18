GetDlgCtrlID(hwnd) {                                                                                                        	;-- retrieves numbering of a control
;Link: https://autohotkey.com/boards/viewtopic.php?t=56851
return DllCall("GetDlgCtrlID", "Ptr", HCTRL, "Int")
}