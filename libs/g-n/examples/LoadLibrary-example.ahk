#include, LoadLibrary.ahk

loops := 100000
SetBatchLines, -1
global gdiplus := LoadLibrary("gdiplus")
VarSetCapacity(bin, 20, 0)
NumPut(1, bin, 0, "int")
DllCall(gdiplus.GdiplusStartup, "ptr*", token, "ptr", &bin, "ptr", 0)
DllCall(gdiplus.GdipCreateBitmapFromScan0, "int", 1, "int", 1, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", pBitmap)

start := A_TickCount
Loop, % loops
  DllCall("gdiplus\GdipBitmapGetPixel", "ptr", pBitmap, "int", 1, "int", 1, "uint*", col)
timeA := A_TickCount-start

start := A_TickCount
Loop, % loops
  DllCall(gdiplus.GdipBitmapGetPixel, "ptr", pBitmap, "int", 1, "int", 1, "uint*", col)
timeB := A_TickCount-start

DllCall(gdiplus.DisposeImage, "ptr", pBitmap)
DllCall(gdiplus.Cleanup, "ptr", token)
MsgBox, % "Standard DllCall:`n" timeA "`n`nMit Funktion:`n" timeB "`n`n(kleiner ist besser)`n`n" timeA/timeB