DynaRun(s,pn:="",pr:="",exe:=""){
static AhkPath,h2o
if !AhkPath
AhkPath:="""" A_AhkPath """" (A_IsCompiled||(A_IsDll&&DllCall(A_AhkPath "\ahkgetvar","Str","A_IsCompiled","CDecl"))?" /E":"")
,h2o:="B29C2D1CA2C24A57BC5E208EA09E162F(){`nPLACEHOLDERB29C2D1CA2C24A57BC5E208EA09E162FVarSetCapacity(dmp,sz:=StrLen(hex)//2,0)`nLoop,Parse,hex`nIf (""""!=h.=A_LoopField) && !Mod(A_Index,2)`nNumPut(""0x"" h,&dmp,A_Index/2-1,""UChar""),h:=""""`nreturn ObjLoad(&dmp)`n}`n"
if (-1=p1:=DllCall("CreateNamedPipe","str",pf:="\\.\pipe\" (pn!=""?pn:"AHK" A_TickCount),"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
|| (-1=p2:=DllCall("CreateNamedPipe","str",pf,"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
Return 0
Run % (exe?exe:AhkPath) " """ pf """ " (IsObject(pr)?"": " " pr),,UseErrorLevel HIDE,P
If ErrorLevel
return DllCall("CloseHandle","Ptr",p1),DllCall("CloseHandle","Ptr",p2),0
If IsObject(pr) {
sz:=ObjDump(pr,dmp),hex:=BinToHex(&dmp,sz)
While % _hex:=SubStr(Hex,1 + (A_Index-1)*16370,16370)
_s.= "hex" (A_Index=1?":":".") "=""" _hex """`n"
Arg:=StrReplace(h2o,"PLACEHOLDERB29C2D1CA2C24A57BC5E208EA09E162F",_s) "global A_Args:=B29C2D1CA2C24A57BC5E208EA09E162F()`n"
}
DllCall("ConnectNamedPipe","Ptr",p1,"Ptr",0),DllCall("CloseHandle","Ptr",p1),DllCall("ConnectNamedPipe","Ptr",p2,"Ptr",0)
if !DllCall("WriteFile","Ptr",p2,"Wstr",s:=(A_IsUnicode?chr(0xfeff):"﻿") Arg s,"UInt",StrLen(s)*(A_IsUnicode?2:1)+(A_IsUnicode?4:3),"uint*",0,"Ptr",0)
P:=0
DllCall("CloseHandle","Ptr",p2)
Return P
}