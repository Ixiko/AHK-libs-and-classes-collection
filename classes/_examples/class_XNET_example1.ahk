#SingleInstance, Force
#Include %A_ScriptDir%\..\XNET.ahk
#Warn

nIfCount := 0,  List := ""
DllCall( "iphlpapi\GetNumberOfInterfaces", "PtrP",nIfCount )

NET := new XNET( False )  

Loop %nIfCount% 
  NET.InterfaceIndex := A_Index
, List .= "InterfaceIndex  :  " NET.InterfaceIndex  "`n"
       .  "InterfaceLuid   :  " NET.InterfaceLuid   "`n"
       .  "InterfaceGuid   :  " NET.InterfaceGuid   "`n"
       .  "Alias           :  " NET.Alias           "`n"
       .  "Description     :  " NET.Description   "`n`n"

Gui, Font, S10, Courier New
Gui, Add, Edit, w640 h480 -Wrap hwndhEdit, %List%
Gui, Show,, Network Interfaces (%nIfCount%)
DllCall( "SendMessage", "Ptr",hEdit, "UInt",0xB1, "Ptr",0 , "Ptr",0 ) ; EM_SETSEL
Return

GuiEscape:
GuiClose:
 ExitApp