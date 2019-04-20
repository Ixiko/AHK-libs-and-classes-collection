LV(va=""){
static hwndEdit,pSFW,pSW,bkpSFW,bkpSW,v
if !hwndEdit {
dhw:=A_DetectHiddenWindows
DetectHiddenWindows,On
Process,Exist
ControlGet,hwndEdit,Hwnd,,Edit1,ahk_class AutoHotkey ahk_pid %ErrorLevel%
DetectHiddenWindows,%dhw%
astr:=A_IsUnicode ? "astr":"str",ptr:=A_PtrSize=8 ? "ptr":"uint"
hmod:=DllCall("GetModuleHandle","str","user32.dll",ptr)
pSFW:=DllCall("GetProcAddress",ptr,hmod,astr,"SetForegroundWindow",ptr)
pSW:=DllCall("GetProcAddress",ptr,hmod,astr,"ShowWindow",ptr)
DllCall("VirtualProtect",ptr,pSFW,ptr,8,"uint",0x40,"uint*",0)
DllCall("VirtualProtect",ptr,pSW,ptr,8,"uint",0x40,"uint*",0)
bkpSFW:=NumGet(pSFW+0,0,"int64"),bkpSW:=NumGet(pSW+0,0,"int64")
 V:={bkpSFW:bkpSFW,bkpSW:bkpSW,pSW:pSW,pSF:pSF,hmod:hmod,ptr:ptr,astr:astr,hwndEdit:hwndEdit,dhw:dhw}
}if va
return v.haskey(va)?V[VA]:V
(A_PtrSize=8)?(NumPut(0x0000C300000001B8,pSFW+0,0,"int64"),NumPut(0x0000C300000001B8,pSW+0,0,"int64")):(NumPut(0x0004C200000001B8,pSFW+0,0,"int64"),NumPut(0x0008C200000001B8,pSW+0,0,"int64"))
}
LV2(v=""){
NumPut(lv("bkpSFW"),lv("pSFW")+0,0,"int64"),NumPut(lv("bkpSW"),lv("pSW")+0,0,"int64")
; NumPut(v.bkpSFW,v.pSFW+0,0,"int64"),NumPut(v.bkpSW,v.pSW+0,0,"int64")
ControlGettext,t,,% "ahk_id " LV("hwndEdit")
RegExMatch(t,"sm)((\w+)\(\).*-+).*(?=Global Variables \(alphabetical\)`r`n-{50}`r`n)",t)
; t:=r(t,"^(\w+)[^-]*-*","Function: $1")
; t:=r(t,"\w+\[[^\]]*\]:[\W]+\R+"),t:=r(t,"\[[^\]]*\]")

; RegExMatch(t,"([[:print:]]*)\Q[Object]:\E([[:print:]]*)", Match)

; R(lv2(),"(\w*)\[[^\]]*\].*","$1")
; for k,v in ss(R(lv2(),"(\w*)\[[^\]]*\].*","$1"),"`n","`r")
; f:=fcount(t2) ;,t:=sr(t,t1)
; t:=r(t,"^[^-]*-+`r`n")
return t
for k,v in ss(f.ps){
if ifequal(V,"O","k","v","","val") ; if (V="O") or (V="k") or (V="v")
continue
RegExMatch(t,v "(\[[^\]]*\]:)([[:print:]]*)",m)
O[V]:=M2
MSG(M1)
}
t:=sr(t,"`r`n`r`n","`r`n")
if RegExMatch(t,r(v,"=.*") "[[:print:]]*",m)
p.=m ", ",t:=sr(t,m)
p:=substr(p,1,-2)
p:=r(p,"\[.*?\]:",":=")
N:=f.h "`n" p t
n:=trim(n,":`n`r`t ")
return n
}

; v:=localvar(bkpSFW,pSFW,bkpSW,pSW,hwndEdit)
; NumPut(v.bkpSFW,v.pSFW+0,0,"int64"),NumPut(v.bkpSW,v.pSW+0,0,"int64")
; ControlGetText,text,,% "ahk_id " v.hwndEdit
; RegExMatc