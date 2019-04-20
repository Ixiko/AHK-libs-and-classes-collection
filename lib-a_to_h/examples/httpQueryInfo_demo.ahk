; #Include HttpQueryInfo.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

url1 = http://www.autohotkey.com
url2 = http://www.autohotkey.com/download/AutoHotkeyInstall.exe
MsgBox % HttpQueryInfo(url1)
MsgBox % HttpQueryInfo(url2, 5)
MsgBox % HttpQueryInfo(url2, 1)