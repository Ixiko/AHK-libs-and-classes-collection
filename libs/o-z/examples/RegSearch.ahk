#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1  ; Makes searching occur at maximum speed.

; runwait("AutoHotkey.exe E:\AH\RegSearch.ahk UserChoice"),t("done")

#INCLUDE E:\AH\Functions.ahk
count=0
Search = %1%
if !search
InputBox, search
if errorlevel
exitapp
Gosub, RegSearch
append(regedit "`n" AHKwrite "`n" Search,"E:\AH\regwrite- " Search " " count ".txt")
exitapp
RegSearch:
ContinueRegSearch = y
Loop, Reg, HKEY_LOCAL_MACHINE, KVR
{
    Gosub, CheckThisRegItem
    if ContinueRegSearch = n ; It told us to stop.
        return
}
Loop, Reg, HKEY_USERS, KVR
{
    Gosub, CheckThisRegItem
    if ContinueRegSearch = n ; It told us to stop.
        return
}
Loop, Reg, HKEY_CURRENT_CONFIG, KVR
{
    Gosub, CheckThisRegItem
    if ContinueRegSearch = n ; It told us to stop.
        return
}
; Note: I believe HKEY_CURRENT_USER does not need to be searched if HKEY_USERS
; is being searched.  The same might also be true for HKEY_CLASSES_ROOT if
; HKEY_LOCAL_MACHINE is being searched.
return
CheckThisRegItem:
; if A_LoopRegType = KEY  ; Remove these two lines if you want to check key names too.
;     return
RegRead, RegValue
if ErrorLevel
    return
IfInString, RegValue, %Search%
{
regedit.="[" A_LoopRegKey "\" A_LoopRegSubKey "\" A_LoopRegName "]`n" RegValue "`n"
AHKwrite.="regwrite(""" A_LoopRegType """ , """ A_LoopRegKey "\" A_LoopRegSubKey """ , " A_LoopRegName " , """ RegValue """)`n" 
if (count+=1)>10
ContinueRegSearch = n
}
return
esc::
exitapp