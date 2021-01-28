#Include WaitPixelColor.ahk

CoordMode, Pixel, Screen

MsgBox % "This example will wait for pixel at 0,0 to be black."

MsgBox % WaitPixelColor(0x000000,0,0)