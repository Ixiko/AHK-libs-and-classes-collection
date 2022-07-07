GetZOrderPosition(hwnd)	{                                                                                                                                                               	;-- gets the number/position of the window in the z-order

	; GetZorderPosition / GetTopMostTableInStack by Guest3456 https://autohotkey.com/boards/viewtopic.php?p=92069#p92069

	   PtrType := A_PtrSize ? "Ptr" : "UInt" ; AHK_L : AHK_Basic
	   z := 0, h := hwnd

	   while h
		  h := DllCall("user32.dll\GetWindow", PtrType, h, "UInt", GW_HWNDPREV := 3), z++

return z
}