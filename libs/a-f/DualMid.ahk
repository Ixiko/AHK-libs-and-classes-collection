; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

DualMID() {                                           ; v0.90 By SKAN on D36I/D36M @ tiny.cc/dualmid
Local
  ClassGuid:="{4d36e96e-e325-11ce-bfc1-08002be10318}", M1:="", M2:="", M3:=""
  WMI:=ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
  For Monitor in  WMI.ExecQuery("SELECT * FROM Win32_PnPEntity WHERE ClassGuid='" . ClassGuid . "'")
  {
    M:=StrSplit(U:=Monitor.DeviceID, ["\","UID"]),     M%A_Index%:=Format("{2:}\{4:}", M*) 
    RegRead, U, HKLM\SYSTEM\CurrentControlSet\Enum\%U%\Device Parameters, EDID
    U%A_Index% := Format("{1:}_{8:}{9:}{6:}{7:}{4:}{5:}{2:}{3:}", M[2], StrSplit(SubStr(U, 25, 8))*)
  } 

  Loop % ( 2, VarSetCapacity(DD,840,0),  NumPut(840,DD,0,"UInt"), D1:="", D2:="" )
    DllCall("EnumDisplayDevicesW", "wStr","\\.\DISPLAY" . A_Index, "Int",0, "Ptr",&DD, "Int",1)
  , D:=StrSplit(StrGet(&DD+328,"UTF-16"),["#","UID"]), D%A_Index%:=(D ? Format("{2:}\{4:}",D*) : "")

  R1:="\\.\DISPLAY1",  R2:="\\.\DISPLAY2", NUL:=""
  Return (M3) ? NUL  : (M2="")       ?          {(U1):(R1)}   
                     : (M2 && D2)    ? (M2=D2 ? {(U1):(R1),(U2):(R2)} : {(U2):(R1),(U1):(R2)})
                     : (M2 && D2="") ? (M1=D1 ? {(U1):(R1),(U2):(R2)} : {(U2):(R1),(U1):(R2)}) : NUL
}
