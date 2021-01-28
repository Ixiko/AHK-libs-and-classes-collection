; #Include UnHTM.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

HTM = <a href="/intl/en/ads/">Advertising&nbsp;Programs</a>
MsgBox, % UnHTM( HTM )
