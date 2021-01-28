; #Include xpath.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; using variables:
x = <root><element var="test"/></root>
xpath_load(x) ; XML content can be loaded in-place directly
xpath(x, "element/text()", "new content")
MsgBox, % xpath_save(x) ; show the new source without having to save it