#Include ClearArray.ahk

Loop, 16
{
  var := "Array" . A_Index-1
  %var% := "bar"
}

Array10 := ""
Array13 := "foo bar"

var := ""
var := var . "0" . "  " . Array0 . "`n"
Loop, 14
  var := var . A_Index . "  " . Array%A_Index% . "`n"
var := var . "15" . "  " . Array15
MsgBox % var

MsgBox % "ClearArray returns " ClearArray("Array",5)

var := ""
var := var . "0" . "  " . Array0 . "`n"
Loop, 14
  var := var . A_Index . "  " . Array%A_Index% . "`n"
var := var . "15" . "  " . Array15
MsgBox % var

Return