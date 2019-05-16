/* About CreateFocusRec()
 
 Draws a transparent but coloured recangle over a controll.
 
 Parmaters:
  1: The handle for the control to draw on.
  2: The handle for the window to which the control belongs to.
  3: The colour for the layer.

*/

CreateFocusRec(CtrlhWnd, WinHwnd, Clr) {
    Critical

    SetControlDelay -1
    
    GuiControlGet c, Pos, %CtrlhWnd%

    Gui, GdiLayer: -Caption +E0x80000 +LastFound +AlwaysOnTop hwndhGdiLayer
    Gui, GdiLayer: Show, NA

    DllCall("SetParent", "uint", hGdiLayer, "uint", WinHwnd)
    
    ; Rectangle structure, only need x and y here
    VarSetCapacity(Rect, 8)
    NumPut(cX, Rect, 0, "UInt"), NumPut(cY, Rect, 4, "UInt")

    ; Bitmap structure. Aplha RGB -> 32bits -> Per Pixel
    VarSetCapacity(Bitmap, 40, 0)
    NumPut(40, Bitmap, 0, "uint"), NumPut(cW, Bitmap, 4, "uint")
    NumPut(cH, Bitmap, 8, "uint"), NumPut(1, Bitmap, 12, "ushort")
    NumPut(32, Bitmap, 14, "ushort"), NumPut(0, Bitmap, 16, "uInt")
    
    ; Use x64 or win32 pointers?
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    PtrA := A_PtrSize ? "UPtr*" : "Uint*"
    
    ; Create Mem Bitmap.
    dc := DllCall("GetDC", Ptr, CtrlhWnd, "Ptr")
    hbm := DllCall("CreateDIBSection", Ptr, dc, Ptr, &Bitmap, "uint", 0, PtrA, 0, Ptr, 0, "uint", 0, "Ptr")
    hdc := DllCall("CreateCompatibleDC", Ptr, dc)
    obm := DllCall("SelectObject", Ptr, hdc, Ptr, hbm)
    DllCall("gdiplus\GdipCreateFromHDC", Ptr, hdc, PtrA, G)
    DllCall("gdiplus\GdipSetSmoothingMode", Ptr, G, "int", 4)
    
    ; Use Drawing tools.
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", Clr, PtrA, pBrush)
    DllCall("gdiplus\GdipFillRectangle", Ptr, G, Ptr, pBrush, "float", 0, "float", 0, "float", cW, "float", cH)
    DllCall("gdiplus\GdipDeleteBrush", Ptr, pBrush)

    ; Update the layered window.
    DllCall("UpdateLayeredWindow", Ptr, hGdiLayer, Ptr, 0, Ptr, &Rect, "int64*", cW|cH<<32, Ptr, hdc, "int64*", 0, "uint", 0, "UInt*", 0x1FF0000, "uint", 2)

    ; Free Memory.
    DllCall("SelectObject", Ptr, hdc, Ptr, obm)
    DllCall("DeleteObject", Ptr, hbm)
    DllCall("DeleteDC", Ptr, hdc), DllCall("DeleteDC", Ptr, dc)
    DllCall("gdiplus\GdipDeleteGraphics", Ptr, G)
}
