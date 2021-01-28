; #Include ShowMenu.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

ShowMenu("[MyMenu]`nitem1`nitem2`n-`nitem3")
return

MyMenu:
   MsgBox %A_ThisMenuItem%
return 