#NoEnv
#KeyHistory 0
#SingleInstance force
ListLines Off
Process, Priority, , H
SetBatchLines, -1

windowTitle := "A" ; active window = "A", entire screen = ""
, scanPosX = 0 ; left edge of the scan area
, scanPosY = 0 ; top edge of the scan area
, scanWidth = 1000 ; width of the scan area
, scanHeight = 1000 ; height of the scan area

, scanRowSkip = 1.0 ; how often to skip rows, must use skipping loop
, scanColumnSkip = 1.0 ; how often to skip columns, must use skipping loop

; Boilerplate
WinGet, winId, ID, %windowTitle%
hDcWnd := DllCall("GetDC", "UInt", winId, "Ptr")
, hDcBuffer := DllCall("CreateCompatibleDC", "Ptr", hDcWnd, "Ptr")
, hBmBuffer := DllCall("CreateCompatibleBitmap", "Ptr", hDcWnd, "Int", scanWidth, "Int", scanHeight, "Ptr")
, DllCall("SelectObject", "Ptr", hDcBuffer, "Ptr", hBmBuffer)

; Init gdiplus
, VarSetCapacity(startInput,  A_PtrSize = 8 ? 24 : 16, 0)
, startInput := Chr(1)
, hModuleGdip := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
, DllCall("gdiplus\GdiplusStartup", "Ptr*", pToken, "Ptr", &startInput, "Ptr", 0)

; Get proc address for max performance
, procBitBlt := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "gdi32", "Ptr"), "AStr", "BitBlt", "Ptr")
, procCreateBitmap := DllCall("GetProcAddress", "Ptr", hModuleGdip, "AStr", "GdipCreateBitmapFromHBITMAP", "Ptr")
, procBitmapLock := DllCall("GetProcAddress", "Ptr", hModuleGdip, "AStr", "GdipBitmapLockBits", "Ptr")
, procBitmapUnlock := DllCall("GetProcAddress", "Ptr", hModuleGdip, "AStr", "GdipBitmapUnlockBits", "Ptr")
, procDisposeImage := DllCall("GetProcAddress", "Ptr", hModuleGdip, "AStr", "GdipDisposeImage", "Ptr")

, startTick := A_TickCount
, frames := 10
loop %frames% {
	; Get bitmap
	DllCall(procBitBlt, "Ptr", hDcBuffer, "Int", 0, "Int", 0, "Int", scanWidth, "Int", scanHeight, "Ptr", hDcWnd, "Int", scanPosX, "Int", scanPosY, "UInt", 0xCC0020)
	, DllCall(procCreateBitmap, "Ptr", hBmBuffer, "Ptr", 0, "Ptr*", pBitmap)

	; Lock bitmap and get byte iteration data
	, VarSetCapacity(bitmapRect, 16, 0)
	, NumPut(scanWidth, bitmapRect, 8, "Int")
	, NumPut(scanHeight, bitmapRect, 12, "Int")
	, VarSetCapacity(bitmapData, A_PtrSize * 2 + 16, 0)
	, DllCall(procBitmapLock, "Ptr", pBitmap, "Ptr", &bitmapRect, "UInt", 3, "Int", 0x26200a, "Ptr", &bitmapData)
	, stride := NumGet(bitmapData, 8, "Int")
	, scan0 := NumGet(bitmapData, 16)

	; Iterate through pixels, ~5,100,000px/s
	Loop %scanHeight% {
		y := A_Index - 1
		Loop %scanWidth%
			col := NumGet(scan0 + 0, (A_Index - 1) * 4 + y * stride, "UInt")
	}
	
	; Uncomment to use skipping, ~4,110,000px/s
	;Loop % Floor(scanHeight / scanRowSkip) {
	;	y := Floor((A_Index - 1) * scanRowSkip)
	;	Loop % Floor(scanWidth / scanColumnSkip)
	;		col := NumGet(scan0, Floor((A_Index - 1) * scanColumnSkip) * 4 + y * stride, "UInt")
	;		;col := Format("{:p}", NumGet(scan0 + 0, Floor((A_Index - 1) * scanColumnSkip) * 4 + y * stride, "UInt"))
	;}

	; Unlock and dispose bitmap
	DllCall(procBitmapUnlock, "Ptr", pBitmap, "Ptr", &bitmapData)
	, DllCall(procDisposeImage, "Ptr", pBitmap)
}
elapsed := A_TickCount - startTick
pixels := scanWidth * scanHeight * frames
MsgBox % elapsed . "ms for " . pixels . "px`nat " . Round(pixels * 1000 / elapsed)   . "px/s"

; Clean up
DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
, DllCall("FreeLibrary", "Ptr", hModuleGdip)
, DllCall("DeleteObject", "Ptr", hBmBuffer)
, DllCall("DeleteDC", "Ptr", hDcBuffer)
, DllCall("DeleteDC", "Ptr", hDcWnd)