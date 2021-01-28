; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

GuiList() { ;           List all Gui names, by SKAN http://goo.gl/qgxzhx | Created: 31-Aug-2014
  Static TList := "", ADM := 0x801 
  Local  Instance := 0, List := "" 

  IfNotEqual, A_Gui,, Return 0, TList .= A_Gui "`n"

  DetectHiddenWindows, % SubStr( ( ADHW := A_DetectHiddenWindows ) . "On", -1 )
  WinGet, Instance, List, % "ahk_class AutoHotkeyGUI ahk_pid " DllCall( "GetCurrentProcessId" )
  DetectHiddenWindows, %ADHW%
  IfEqual, Instance, 0, Return "", ErrorLevel := 0

  OnMessage( ADM, A_ThisFunc )
  Loop %Instance%
    DllCall( "SendMessage", "Ptr",Instance%A_Index%, "UInt",ADM, "Ptr",0, "Ptr",0 )
  OnMessage( ADM, "" )    

  StringTrimRight, List, TList, 1  
Return List,  TList := "",  ErrorLevel := Instance
}
