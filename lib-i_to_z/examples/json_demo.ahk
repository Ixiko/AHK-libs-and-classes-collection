; #Include json.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; JSON string:
j = {"version":"1","window":{"state":3,"screenX":25,"screenY":25,"width":790,"height":605,"test":{"nested":"object"}},"sidebar":{"visible":false,"width":"200"}}
MsgBox, % json(j, "version") ; returns "1"
MsgBox, % json(j, "window.width", 800) ; returns 790, sets window->width to 800

r = { "a" : true, "b" : [ 1, [ 2.1, 2.2, { "sub" : false, "test" : [ null, "pass" ] } ], 3 ] }
MsgBox, % json(r, "b[1][2].test[1]") ; array support