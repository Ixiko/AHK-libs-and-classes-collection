; #Include Notify.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Title= Hello
Message= World
Duration=0
Options:="GC=bbffbb TC=White MC=White"
Image=14

Notify(Title,Message,Duration,Options,Image)
