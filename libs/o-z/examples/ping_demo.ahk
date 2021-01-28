; #Include ping.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

hostlist := "127.0.0.1|192.168.2.1|http://www.google.com||http://www.wikipedia.com|99.99.99.99|"
data := "AHK test"
timeout := "500"

Loop, Parse, hostlist, |
{
    MsgBox,, %A_LoopField%, % ping(A_LoopField, data, timeout)
}
   
