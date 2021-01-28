q:: ;test UTF-8 conversion
vText := Chr(8730) Chr(33) Chr(333) Chr(3333) Chr(33333) Chr(8730)
MsgBox, % vText
vUtf8 := JEE_StrTextToUtf8Bytes(vText)
MsgBox, % vUtf8
vText2 := JEE_StrUtf8BytesToText(vUtf8)
MsgBox, % (vText = vText2)
return
w:: ;test 'UTF-8 ini files'
vText := ";this line is required for a 'UTF-8 ini file'"
vPath := A_Desktop "\MyUtf8Ini.ini"
FileAppend, % vText, % "*" vPath, UTF-8
vSection := Chr(8730) "Section" Chr(8730)
vKey := Chr(8730) "Key" Chr(8730)
vValue := Chr(8730) Chr(33) Chr(333) Chr(3333) Chr(33333) Chr(8730)
JEE_IniWriteUtf8(vValue, vPath, vSection, vKey)
MsgBox, % JEE_IniReadUtf8(vPath, vSection, vKey)
return
;==================================================
;note: a 'UTF-8 ini file' will need a comment as the first line
;e.g. ';my comment'
JEE_IniReadUtf8(vPath, vSection:="", vKey:="", vDefault:="") {
local vOutput
vSection := JEE_StrTextToUtf8Bytes(vSection)
vKey := JEE_StrTextToUtf8Bytes(vKey)
IniRead, vOutput, % vPath, % vSection, % vKey, % vDefault
if !ErrorLevel
return JEE_StrUtf8BytesToText(vOutput)
}
;==================================================
JEE_IniWriteUtf8(vValue, vPath, vSection, vKey:="") {
vSection := JEE_StrTextToUtf8Bytes(vSection)
vKey := JEE_StrTextToUtf8Bytes(vKey)
vValue := JEE_StrTextToUtf8Bytes(vValue)
IniWrite, % vValue, % vPath, % vSection, % vKey
return !ErrorLevel
}
;==================================================
JEE_IniDeleteUtf8(vPath, vSection, vKey:="") {
vSection := JEE_StrTextToUtf8Bytes(vSection)
vKey := JEE_StrTextToUtf8Bytes(vKey)
IniDelete, % vPath, % vSection, % vKey
return !ErrorLevel
}
;==================================================
JEE_StrUtf8BytesToText(vUtf8) {
if A_IsUnicode
{
VarSetCapacity(vUtf8X, StrPut(vUtf8, "CP0"))
StrPut(vUtf8, &vUtf8X, "CP0")
return StrGet(&vUtf8X, "UTF-8")
}
else
return StrGet(&vUtf8, "UTF-8")
}
;==================================================
JEE_StrTextToUtf8Bytes(vText) {
VarSetCapacity(vUtf8, StrPut(vText, "UTF-8"))
StrPut(vText, &vUtf8, "UTF-8")
return StrGet(&vUtf8, "CP0")
}
;==================================================