; #Include ThousandsSep.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox %  ThousandsSep(1)
   . "`n" ThousandsSep(12)
   . "`n" ThousandsSep(1234)
   . "`n" ThousandsSep(1234567890)
   . "`n`n" ThousandsSep(1.1)
   . "`n" ThousandsSep(12.12)
   . "`n" ThousandsSep(123.123)
   . "`n" ThousandsSep(1234.1234)
   . "`n" ThousandsSep(1234567890.1234567890)