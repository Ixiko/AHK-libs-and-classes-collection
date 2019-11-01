mpgcScanPosX := -1
, mpgcScanPosY = -1
, mpgcScanWidth = -1
, mpgcScanHeight = -1

, mpgcHDcWnd = -1
, mpgcHDcBuffer = -1
, mpgcHModuleGdip = -1
, mpgcHBmBuffer = -1
, mpgcPToken = -1

, mpgcProcBitBlt = -1
, mpgcProcCreateBitmap = -1
, mpgcProcBitmapLock = -1
, mpgcProcBitmapUnlock = -1
, mpgcProcDisposeImage = -1

, mpgcPBitmap = 0
, mpgcBitmapData = -1
, mpgcStride = -1
, mpgcScan0 = -1

; Initializes the mpgc
; windowTitle (Str) title of the capture window, active window = "A", entire screen = ""
; leftEdge (Int) left edge of the scan area
; topEdge (Int) top edge of the scan area
; width (Int) width of the scan area
; height (Int) height of the scan area
init_mpgc(windowTitle := "", leftEdge := 0, topEdge := 0, width := -1, height := -1) {
	global mpgcScanPosX, mpgcScanPosY, mpgcScanWidth, mpgcScanHeight
	global mpgcHDcWnd, mpgcHDcBuffer, mpgcHModuleGdip, mpgcHBmBuffer, mpgcPToken
	global mpgcProcBitBlt, mpgcProcCreateBitmap, mpgcProcBitmapLock, mpgcProcBitmapUnlock, mpgcProcDisposeImage
	
	if width = -1
		width := A_ScreenWidth
	if height = -1
		height := A_ScreenHeight
	mpgcScanPosX := leftEdge
	mpgcScanPosY := topEdge
	mpgcScanWidth := width
	mpgcScanHeight := height
	
	; Boilerplate
	WinGet, winId, ID, %windowTitle%
	mpgcHDcWnd := DllCall("GetDC", "UInt", winId, "Ptr")
	, mpgcHDcBuffer := DllCall("CreateCompatibleDC", "Ptr", mpgcHDcWnd, "Ptr")
	, mpgcHBmBuffer := DllCall("CreateCompatibleBitmap", "Ptr", mpgcHDcWnd, "Int", mpgcScanWidth, "Int", mpgcScanHeight, "Ptr")
	, DllCall("SelectObject", "Ptr", mpgcHDcBuffer, "Ptr", mpgcHBmBuffer)

	; Init gdiplus
	, VarSetCapacity(startInput,  A_PtrSize = 8 ? 24 : 16, 0)
	, startInput := Chr(1)
	, mpgcHModuleGdip := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
	, DllCall("gdiplus\GdiplusStartup", "Ptr*", mpgcPToken, "Ptr", &startInput, "Ptr", 0)

	; Get proc address for max performance
	, mpgcProcBitBlt := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "gdi32", "Ptr"), "AStr", "BitBlt", "Ptr")
	, mpgcProcCreateBitmap := DllCall("GetProcAddress", "Ptr", mpgcHModuleGdip, "AStr", "GdipCreateBitmapFromHBITMAP", "Ptr")
	, mpgcProcBitmapLock := DllCall("GetProcAddress", "Ptr", mpgcHModuleGdip, "AStr", "GdipBitmapLockBits", "Ptr")
	, mpgcProcBitmapUnlock := DllCall("GetProcAddress", "Ptr", mpgcHModuleGdip, "AStr", "GdipBitmapUnlockBits", "Ptr")
	, mpgcProcDisposeImage := DllCall("GetProcAddress", "Ptr", mpgcHModuleGdip, "AStr", "GdipDisposeImage", "Ptr")
}

; Updates the bitmap buffer with new pixel information
update_mpgc() {
	global mpgcScanPosX, mpgcScanPosY, mpgcScanWidth, mpgcScanHeight
	global mpgcHDcWnd, mpgcHDcBuffer, mpgcHBmBuffer
	global mpgcProcBitBlt, mpgcProcCreateBitmap, mpgcProcBitmapLock, mpgcProcBitmapUnlock, mpgcProcDisposeImage
	global mpgcPBitmap, mpgcBitmapData, mpgcStride, mpgcScan0

	if (mpgcPBitmap != 0) {
		; Unlock and dispose bitmap
		DllCall(mpgcProcBitmapUnlock, "Ptr", mpgcPBitmap, "Ptr", &mpgcBitmapData)
		, DllCall(mpgcProcDisposeImage, "Ptr", mpgcPBitmap)
	}
	
	; Get bitmap
	DllCall(mpgcProcBitBlt, "Ptr", mpgcHDcBuffer, "Int", 0, "Int", 0, "Int", mpgcScanWidth, "Int", mpgcScanHeight, "Ptr", mpgcHDcWnd, "Int", mpgcScanPosX, "Int", mpgcScanPosY, "UInt", 0xCC0020)
	, DllCall(mpgcProcCreateBitmap, "Ptr", mpgcHBmBuffer, "Ptr", 0, "Ptr*", mpgcPBitmap)

	; Lock bitmap and get byte iteration data
	, VarSetCapacity(bitmapRect, 16, 0)
	, NumPut(mpgcScanWidth, bitmapRect, 8, "Int")
	, NumPut(mpgcScanHeight, bitmapRect, 12, "Int")
	, VarSetCapacity(mpgcBitmapData, A_PtrSize * 2 + 16, 0)
	, DllCall(mpgcProcBitmapLock, "Ptr", mpgcPBitmap, "Ptr", &bitmapRect, "UInt", 3, "Int", 0x26200a, "Ptr", &mpgcBitmapData)
	, mpgcStride := NumGet(mpgcBitmapData, 8, "Int")
	, mpgcScan0 := NumGet(mpgcBitmapData, 16)
}

; Gets the color information at a point
; x (Int) x position of the pixel
; y (Int) y position of the pixel
; return (UInt) the combined color of the pixel in base 10 RGB
mpgc(x, y) {
	global mpgcStride, mpgcScan0
	return NumGet(mpgcScan0 + 0, x * 4 + y * mpgcStride, "UInt")
}

; Unloads and frees memory and objects used by mpgc, recommended only when finished
end_mpgc() {
	global mpgcProcBitmapUnlock, mpgcProcDisposeImage
	global mpgcHDcWnd, mpgcHDcBuffer, mpgcHBmBuffer, mpgcHModuleGdip, mpgcPToken
	global mpgcPBitmap, mpgcBitmapData
	
	if(mpgcPBitmap) {
		DllCall(mpgcProcBitmapUnlock, "Ptr", mpgcPBitmap, "Ptr", &mpgcBitmapData)
		, DllCall(mpgcProcDisposeImage, "Ptr", mpgcPBitmap)
	}
	DllCall("gdiplus\GdiplusShutdown", "Ptr", mpgcPToken)
	, DllCall("FreeLibrary", "Ptr", mpgcHModuleGdip)
	, DllCall("DeleteObject", "Ptr", mpgcHBmBuffer)
	, DllCall("DeleteDC", "Ptr", mpgcHDcBuffer)
	, DllCall("DeleteDC", "Ptr", mpgcHDcWnd)
}