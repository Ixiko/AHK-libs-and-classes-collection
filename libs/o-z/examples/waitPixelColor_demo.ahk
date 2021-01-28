; #Include WaitPixelColor.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

CoordMode, Pixel, Screen

MsgBox % "This example will wait 2 seconds, and then wait until at position x=640, y=480 the color changes to white."
Sleep, 2000
ExitCode := WaitPixelColor(0xFFFFFF, 640, 480, 20000)
If (ExitCode = 0)
{
    MsgBox The desired color was found
}
Else If (ExitCode = 1)
{
    MsgBox There was a problem during PixelGetColor
}
Else If (ExitCode = 2)
{
    MsgBox The function timed out
}

