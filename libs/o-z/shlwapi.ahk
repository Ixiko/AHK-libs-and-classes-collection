; wrapper for some shlwapi.dll functions
; requires updates.ahk
; v1.0 © Drugwash, 2017.06.19
;================================================================
PathGetArgs(strg)
;================================================================
{
Global
return DllCall("shlwapi\" A_ThisFunc AW, "Str", strg, "Str")
}
;================================================================
PathRemoveArgs(ByRef strg)
;================================================================
{
Global
DllCall("shlwapi\" A_ThisFunc AW, "Str", strg)
}
;================================================================
PathQuoteSpaces(ByRef strg)
;================================================================
{
Global
VarSetCapacity(strg2, 260*A_CharSize, 0)
DllCall("lstrcpy" AW, "Str", strg2, "Str", strg)
DllCall("shlwapi\" A_ThisFunc AW, "Str", strg2)
DllCall("lstrcpy" AW, "Str", strg, "Str", strg2)
VarSetCapacity(strg2, 0)
}
;================================================================
PathUnquoteSpaces(ByRef strg)
;================================================================
{
Global
DllCall("shlwapi\" A_ThisFunc AW, "Str", strg)
}
;================================================================
PathFindFileName(strg)
;================================================================
{
Global
return DllCall("shlwapi\" A_ThisFunc AW, "Str", strg, "Str")
}


