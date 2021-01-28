#Include %A_ScriptDir%\..\lib-i_to_z\WaitPixelColor.ahk

CoordMode, Pixel, Screen

MsgBox % "This example will wait for pixel at 0,0 to be black."

MsgBox % WaitPixelColor(0,0,0)