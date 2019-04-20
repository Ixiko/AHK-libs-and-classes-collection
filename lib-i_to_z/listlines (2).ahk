ListLines(NumLines="",endline="",params*)
{
static hwndEdit, pSFW, pSW, bkpSFW, bkpSW
ListLines Off
if !hwndEdit
{
; Retrieve the handle of our main window's Edit control:
dhw := A_DetectHiddenWindows
DetectHiddenWindows, On
Process, Exist
ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
DetectHiddenWindows, %dhw%
astr := A_IsUnicode ? "astr" : "str"
ptr := A_PtrSize=8 ? "ptr":"uint"
hmod := DllCall("GetModuleHandle", "str", "user32.dll")
pSFW := DllCall("GetProcAddress", "uint", hmod, astr, "SetForegroundWindow")
pSW := DllCall("GetProcAddress", "uint", hmod, astr, "ShowWindow")
DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
bkpSFW := NumGet(pSFW+0, 0, "int64")
bkpSW := NumGet(pSW+0, 0, "int64")
}
if (A_PtrSize=8)
NumPut(0x0000C300000001B8,pSFW+0,0,"int64"),NumPut(0x0000C300000001B8,pSW+0,0,"int64")
else,NumPut(0x0004C200000001B8,pSFW+0,0,"int64"),NumPut(0x0008C200000001B8,pSW+0,0,"int64")
ListLines
NumPut(bkpSFW, pSFW+0, 0, "int64"),NumPut(bkpSW, pSW+0, 0, "int64")
ControlGetText, txt,, ahk_id %hwndEdit%
RegExMatch(txt, ".*`r`n`r`n\K[\s\S]*(?=`r`n`r`n.*$)", txt)

if NumLines {
txt:=substr(txt,FoundLinePos:=instr(txt,"`n",,0,NumLines))
txt:=ltrim(txt,"`r`n ")
if (endline)
txt:=substr(txt,1,instr(txt,"`n",,,endline))

						}
; for k,v in ss("A_scriptdir,A_workingdir,A_ScriptFullPath,A_ScriptName,A_LineFile,A_LineNumber")
; (%v%)?a.=v "=" (%v%) "`n"
; txt.=a
ListLines On

return txt  ; This line appears in ListLines if we're called more than once.
}
