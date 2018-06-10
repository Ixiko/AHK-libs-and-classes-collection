; ==================================================================================================================================
; IDragSourceHelper interface -> msdn.microsoft.com/en-us/library/bb762034(v=vs.85).aspx
; CLSID_DragDropHelper     "{4657278A-411B-11D2-839A-00C04FD918D0}"
; IID_IDropSourcetHelper   "{DE5BF786-477A-11D2-839D-00C04FD918D0}"
; ==================================================================================================================================
; Initializes the drag-image manager for a windowless control.
; ==================================================================================================================================
IDragSourceHelper_CreateFromBitmap(pDataObj, HBITMAP, Width, Height, ColorKey := 0x00FFFFFF, OffCX := 0, OffCY := 0) {
   Static InitializeFromBitmap := A_PtrSize * 3
   VarSetCapacity(SHDI, 32, 0) ; SHDRAGIMAGE structure, 64-bit size
   NumPut(Width, SHDI, 0, "Int")
   NumPut(Height, SHDI, 4, "Int")
   NumPut(OffCX, SHDI, 8, "Int")
   NumPut(OffCY, SHDI, 12, "Int")
   NumPut(20, SHDI, 8, "Int")
   NumPut(20, SHDI, 12, "Int")
   NumPut(HBITMAP, SHDI, 16, "UPtr")
   NumPut(ColorKey, SHDI, 16 + A_PtrSize, "UInt")
   If (pIDSH := ComObjCreate("{4657278A-411B-11D2-839A-00C04FD918D0}", "{DE5BF786-477A-11D2-839D-00C04FD918D0}")) {
      pVTBL := NumGet(pIDSH + 0, "UPtr")
      ToolTip, % DllCall(NumGet(pVTBL + 0, InitializeFromBitmap, "UPtr"), "Ptr", pIDSH, "Ptr", &SHDI, "Ptr", pDataObj, "Int")
      Return pIDSH
   }
   Return False
}
; ==================================================================================================================================
; Initializes the drag-image manager for a control with a window.
; ==================================================================================================================================
IDragSourceHelper_CreateFromWindow(pDataObj, HWND, OffCX := 0, OffCY := 0) {
   Static InitializeFromWindow := A_PtrSize * 4
   If (pIDSH := ComObjCreate("{4657278A-411B-11D2-839A-00C04FD918D0}", "{DE5BF786-477A-11D2-839D-00C04FD918D0}")) {
      pVTBL := NumGet(pIDSH + 0, "UPtr")
      ToolTip, % DllCall(NumGet(pVTBL + 0, InitializeFromWindow, "UPtr"), "Ptr", pIDSH, "Ptr", HWND, "Ptr", 0, "Ptr", pDataObj, "Int")
      Return pIDSH
   }
   Return False
}
; ==================================================================================================================================
; Auxiliary functions:
; ==================================================================================================================================
IDragSourceHelper_LoadImage(ImagePath, W := 0, H := 0) {
   HBITMAP := 0
   GDIPModule := DllCall("LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
   VarSetCapacity(SI, 24, 0)
   NumPut(1, SI, 0, "UInt")
   DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", GDIPToken, "Ptr", &SI, "Ptr", 0)
   DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", ImagePath, "PtrP", GDIPBitmap)
	DllCall("Gdiplus.dll\GdipGetImageWidth", "Ptr", GDIPBitmap, "UIntP", PW)
	DllCall("Gdiplus.dll\GdipGetImageHeight", "Ptr", GDIPBitmap, "UIntP", PH)
   DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", GDIPBitmap, "PtrP", HBITMAP, "UInt", 0xFFFFFFFF)
   DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", GDIPBitmap)
   DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GDIPToken)
   DllCall("FreeLibrary", "Ptr", GDIPModule)
   If (W = 0)
      W := PW
   If (H = 0)
      H := PH
   If (W <> PW) || (H <> PH)
      HBITMAP := DllCall("CopyImage", "Ptr", HBITMAP, "UInt", 0, "Int", W, "Int", H, "UInt", 0x800A, "UPtr") ; 0x200A
   Return HBITMAP
}