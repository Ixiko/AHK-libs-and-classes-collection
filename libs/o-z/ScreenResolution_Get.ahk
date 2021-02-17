; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=77664
; Author:	SKAN
; Date:
; for:     	AHK_L

/*


*/

ScreenResolution_Get(Disp:=0) {              ; v0.90 By SKAN on D36I/D36M @ tiny.cc/screenresolution
Local DM, N:=VarSetCapacity(DM,220,0)
Return DllCall("EnumDisplaySettingsW", (Disp=0 ? "Ptr" : "WStr"),Disp, "Int",-1, "Ptr",&DM)=0 ? ""
     : Format("{:}x{:}@{:}", NumGet(DM,172,"UInt"),NumGet(DM,176,"UInt"),NumGet(DM,184,"UInt"))
}

ScreenResolution_List(Disp:=0) {             ; v0.90 By SKAN on D36I/D36M @ tiny.cc/screenresolution
Local DM, N:=VarSetCapacity(DM,220,0), L:="", DL:=","
  While DllCall("EnumDisplaySettingsW", (Disp=0 ? "Ptr" : "WStr"),Disp, "Int",A_Index-1, "Ptr",&DM)
  If ( NumGet(DM,168,"UInt")=32 && NumGet(DM,184,"UInt")>59)
    L.=Format("{:}x{:}@{:}" . DL, NumGet(DM,172,"UInt"),NumGet(DM,176,"UInt"),NumGet(DM,184,"UInt"))
Return RTrim(L,DL)
}

ScreenResolution_Set(WxHaF, Disp:=0) {       ; v0.90 By SKAN on D36I/D36M @ tiny.cc/screenresolution
Local DM, N:=VarSetCapacity(DM,220,0), F:=StrSplit(WxHaF,["x","@"],A_Space)
Return DllCall("ChangeDisplaySettingsExW",(Disp=0 ? "Ptr" : "WStr"),Disp, "Ptr",NumPut(F[3]
     , NumPut(F[2], NumPut(F[1], NumPut(32, NumPut(0x5C0000, NumPut(220,DM,68,"UShort")+2,"UInt")+92
     , "UInt"),"UInt"),"UInt")+4,"UInt")-188, "Ptr",0, "Int",0, "Int",0)
}