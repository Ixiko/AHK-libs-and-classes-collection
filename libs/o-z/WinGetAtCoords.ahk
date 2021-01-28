WinGetAtCoords(x,y,what="Title") {     ; by SKAN and Learning one
	; Returns Title/ID/Class/PID of window at given coordinates 
    WinID := DllCall( "GetAncestor", UInt      ; by SKAN
           ,DllCall( "WindowFromPoint", Int,X, Int,Y )
           , UInt, GA_ROOT := 2)
	if (what = "Title" or what = "T") {
		WinGetTitle, WinTitle, ahk_id %WinID%
		Return WinTitle
	}
	else if (what = "ID" or what = "I")
		Return WinID
	else if (what = "Class" or what = "C") {
		WinGetClass, WinClass, ahk_id %WinID%
		Return WinClass
	}
	else if (what = "PID" or what = "P") {
		WinGet, WinPID, PID, ahk_id %WinID%
		Return WinPID
	}
}	; http://www.autohotkey.com/forum/viewtopic.php?p=341120#341120


CoordGetConrol(xCoord, yCoord)
{
   _hWin := WinGetAtCoords(xCoord, yCoord, "ID") ; First get the window at the specified coordinates using CoordGetWin()
   WinGetPos, xWin, yWin,,, ahk_id %_hWin%
   xCoord -= xWin, yCoord -= yWin ; Convert CoordMode to be realtive to the window
   CtrlArray := Object() 
   WinGet, ControlList, ControlListhwnd, ahk_id %_hWin%
   Loop, Parse, ControlList, `n
   {
      Control := A_LoopField
      ControlGetPos, left, top, right, bottom, , ahk_id %Control%
      right += left, bottom += top
      if (xCoord >= left && xCoord <= right && yCoord >= top && yCoord <= bottom)
         MatchList .= Control "|"
   }
   StringTrimRight, MatchList, MatchList, 1
   Loop, Parse, MatchList, |
   {
      ControlGetPos,,, w, h, , ahk_id %a_loopfield%
      Area := w * h
      CtrlArray[Area] := A_LoopField
   }
   for Area, Ctrl in CtrlArray
   {
      Control := Ctrl
      if A_Index = 1
         break
   }
   return Control
}