ListVars()
{
static hwndEdit,pSFW,pSW,bkpSFW,bkpSW
if !hwndEdit
{
dhw:=A_DetectHiddenWindows
DetectHiddenWindows,On
Process,Exist
ControlGet,hwndEdit,Hwnd,,Edit1,ahk_class AutoHotkey ahk_pid %ErrorLevel%
DetectHiddenWindows,%dhw%
astr:=A_IsUnicode ? "astr":"str"
ptr:=A_PtrSize=8 ? "ptr":"uint"
hmod:=DllCall("GetModuleHandle","str","user32.dll",ptr)
pSFW:=DllCall("GetProcAddress",ptr,hmod,astr,"SetForegroundWindow",ptr)
pSW:=DllCall("GetProcAddress",ptr,hmod,astr,"ShowWindow",ptr)
DllCall("VirtualProtect",ptr,pSFW,ptr,8,"uint",0x40,"uint*",0)
DllCall("VirtualProtect",ptr,pSW,ptr,8,"uint",0x40,"uint*",0)
bkpSFW:=NumGet(pSFW+0,0,"int64"),bkpSW:=NumGet(pSW+0,0,"int64")
}
if (A_PtrSize=8) {
NumPut(0x0000C300000001B8,pSFW+0,0,"int64")  ; return TRUE
NumPut(0x0000C300000001B8,pSW+0,0,"int64")   ; return TRUE
} else {
NumPut(0x0004C200000001B8,pSFW+0,0,"int64")  ; return TRUE
NumPut(0x0008C200000001B8,pSW+0,0,"int64")   ; return TRUE
}
ListVars
NumPut(bkpSFW,pSFW+0,0,"int64"),NumPut(bkpSW,pSW+0,0,"int64")
ControlGetText,text,,ahk_id %hwndEdit%
RegExMatch(text,"sm).*(?<=^Global Variables \(alphabetical\)`r`n-{50}`r`n)",text)
return text
}