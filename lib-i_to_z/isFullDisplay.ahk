; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

IsFullDisplay(hWnd)             {          ; v0.66 by SKAN on D38S/D391 @ tiny.cc/isfulldisplay
Local                       
  hMon := DllCall("MonitorFromWindow", "Ptr",hWnd, "Int",0x2, "Ptr") ; MONITOR_DEFAULTTONEAREST
, VarSetCapacity(MONITORINFO,40,0),   VarSetCapacity(WINDOWINFO,60,0),  VarSetCapacity(RECT,16)
, NumPut(40, MONITORINFO, "Int"),     DllCall("GetMonitorInfo", "Ptr",hMon, "Ptr",&MONITORINFO)
, NumPut(60, WINDOWINFO, "Int"),      DllCall("GetWindowInfo",  "Ptr",hWnd, "Ptr",&WINDOWINFO)
, Style:=NumGet(WINDOWINFO, 36, "UInt"),  WS_CAPTION:=0xC00000,  WS_THICKFRAME:=0x40000
Return  ( DllCall("SubtractRect", "Ptr",&RECT, "Ptr",&MONITORINFO+04, "Ptr",&WINDOWINFO+04) = 0
   ? ( (Style & WS_CAPTION) = 0 ? True : (Style & WS_THICKFRAME) = 0 ? True : False ) : False )
}        

