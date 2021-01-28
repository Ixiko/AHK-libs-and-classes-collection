; Link:   	    https://www.autohotkey.com/boards/viewtopic.php?f=6&t=77953&sid=c205ee06fe9219bf44575dc38958db17
; Author:	SKAN
; Date:   	
; for:     	AHK_L

/*


*/

CtrlCoOrder(ControlListHwnd) { ; By SKAN on D36U/D36U @ tiny.cc/ctrlcoorder
Local C:="", X, Y
  Loop, Parse, ControlListHwnd, `n
  {
      ControlGetPos, X, Y,,,, ahk_id %A_LoopField%
      C.=Format("0x{1:06x}`t{3:05}{2:05}`n", A_LoopField, 32768+Y, 32768+X)
  }   
  Sort, C, D`n P10 
Return RTrim(RegExReplace(C,"\t[0-9]+\n","`n"), "`n")
}
