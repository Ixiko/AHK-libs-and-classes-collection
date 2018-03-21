; RegionGetColor - Average color a window - v3.8 +MCode!
; http://www.autohotkey.com/forum/topic36394.html
;region ;Functions; ######################################################################
regionGetColor(x, y, w, h, hwnd=0) {
; created by Infogulch - thanks to Titan for much of this
; x, y, w, h  ~  coordinates of the region to average
; hwnd        ~  handle to the window that coords refers to
   DllCall("QueryPerformanceCounter", "Int64 *", Start1)
   If !hwnd, hdc := regionGetColor_GetDC( hwnd )
      hcdc := hdc
   Else
   {
      WinGetPos, , , hwndW, hwndH, ahk_id %hwnd%
      hcdc := regionGetColor_CreateCompatibleDC( hdc )
      , hbmp := regionGetColor_CreateCompatibleBitmap( hdc, hwndW, hwndH )
      , hobj := regionGetColor_SelectObject( hcdc, hbmp )
      , regionGetColor_PrintWindow( hwnd, hcdc, 0 )
   }
   memdc := regionGetColor_CreateCompatibleDC( hdc )
   , membmp := regionGetColor_CreateCompatibleBitmap( hdc, w, h )
   , memobj := regionGetColor_SelectObject( memdc, membmp )
   , regionGetColor_BitBlt( memdc, 0, 0, w, h, hcdc, x, y, 0xCC0020 )
   , fmtI := A_FormatInteger
   SetFormat,    Integer, Hex
   retval := regionGetColor_AvgBitmap(membmp, w * h) + 0
   SetFormat,    Integer, %fmtI%
   
   If hbmp
      regionGetColor_DeleteObject(hbmp), regionGetColor_SelectObject(hcdc, hobj), regionGetColor_DeleteDC(hcdc)
   regionGetColor_DeleteObject(membmp), regionGetColor_SelectObject(memdc, memobj), regionGetColor_DeleteDC(memdc)
   , regionGetColor_ReleaseDC(hwnd, hdc)
   , DllCall("QueryPerformanceCounter", "Int64 *", End1), DllCall("QueryPerformanceFrequency", "Int64 *", f)
   return retval, ErrorLevel := (End1-Start1)/f
}

regionGetColor_AvgBitmap(hbmp, pc) {
; by Infogulch
; hbmp  ~  handle to an existing bitmap
; pc    ~  size of the bitmap, should be w * h
; http://msdn.microsoft.com/en-us/library/dd144850(VS.85).aspx
   DllCall("GetBitmapBits", "UInt", hbmp, "UInt", VarSetCapacity(bits, pc*4, 0), "UInt", &bits)
   regionGetColor_SumIntBytes(bits, pc, ca, cr, cg, cb)
   return ((Round(cr/pc) & 0xff) << 16) | ((Round(cg/pc) & 0xff) << 8) | (Round(cb/pc) & 0xff)
}

regionGetColor_SumIntBytes( ByRef arr, len, ByRef a, ByRef r, ByRef g, ByRef b ) {
; by infogulch
; 32 bit:             16,843,009 px ||       4,104 x       4,104 px screen
; 64 bit: 72,340,172,838,076,673 px || 268,961,285 x 268,961,285 px screen
  static f, i
  if !i
  {
    t =
    (LTrim Join
    558bec81eccc0000005356578dbd34ffffffb933000000b8ccccccccf3abc745
    f800000000eb098b45f883c0018945f88b45f83b450c0f83940000008b45f88b
    4d088b1481c1ea1833c08b4d1003118b490413c88b451089108948048b45f88b
    4d088b1481c1ea1081e2ff00000033c08b4d1403118b490413c88b4514891089
    48048b45f88b4d088b1481c1ea0881e2ff00000033c08b4d1803118b490413c8
    8b451889108948048b45f88b4d088b148181e2ff00000033c08b4d1c03118b49
    0413c88b451c8910894804e957ffffff5f5e5b8be55dc3
    )
    VarSetCapacity(f, tl := StrLen(t)/2), i := 0
    While i < tl
      NumPut("0x" SubStr(t, i*2+1, 2), f, i, "UChar"), i++
  }
    VarSetCapacity(a, 8, 0), VarSetCapacity(r, 8, 0)
  , VarSetCapacity(g, 8, 0), VarSetCapacity(b, 8, 0)
  , DllCall( &f, "UInt", &arr, "UInt", len
    , "UInt", &a, "UInt", &r, "UInt", &g, "UInt", &b
    , "CDecl")
  , a := NumGet(a, 0, "UInt64"), r := NumGet(r, 0, "UInt64")
  , g := NumGet(g, 0, "UInt64"), b := NumGet(b, 0, "UInt64")
}

regionGetColor_regionWaitColor(color, X, Y, W, H, hwnd=0, interval=100, timeout=5000, a="", b="", c="") {
   regionGetColor_CompareColor := (color != "" ? color : regionGetColor(X, Y, W, H, hwnd))
   Start := A_TickCount
   while !(color ? retVal : !retVal) && !(timeout > 0 ? A_TickCount-Start > timeout : 0)
   {
      retVal := regionGetColor_regionCompareColor( CompareColor, x, y, w, h, hwnd, a, b, c)
      If interval
         Sleep interval
   }
   ErrorLevel := A_TickCount-Start
   Return (color ? retVal : !retVal)
}

regionGetColor_regionCompareColor(color, x, y, w, h, hwnd=0, a="", b="", c="") {
   return regionGetColor_withinVariation(regionGetColor(x, y, w, h, hwnd), color, a, b, c)
}

regionGetColor_withinVariation( x, y, a, b="", c="") {
; return wether x is within ±A ±B ±C of y
; if a is blank return wether x = y
; if b or c is blank, they are set equal to a
    If (a = "")
        return (x = y)
    v := regionGetColor_Variation(x, y)
    return v >> 16 & 0xFF <= a
        && v >> 8  & 0xFF <= (b+0 ? b : a)
        && v       & 0xFF <= (c+0 ? c : a)
}

regionGetColor_Variation( x, y ) {
    return Abs((x & 0xFF0000) - (y & 0xFF0000))
         | Abs((x & 0x00FF00) - (y & 0x00FF00))
         | Abs((x & 0x0000FF) - (y & 0x0000FF))
}

regionGetColor_invertColor(x, a = "") {
; by Infogulch
; inverts the rgb/bgr hex color passed
; x: color to be inverted
; a: true to invert alpha as well
   return ~x & (a ? 0xFFFFFFFF : 0xFFFFFF)
}

/* Old version, if you want to compare performance
AvgBitmap(hbmp, pc) {
; by Infogulch
; hbmp  ~  handle to an existing bitmap
; pc    ~  size of the bitmap, should be w * h
; http://msdn.microsoft.com/en-us/library/dd144850(VS.85).aspx
   cb := cg := cr := 0
   DllCall("GetBitmapBits", "UInt", hbmp, "UInt", VarSetCapacity(bits, pc*4, 0), "UInt", &bits)
   Loop, % pc
   {
      a := NumGet(bits, A_Index*4-4)
      , cr += a >> 16 & 0xff
      , cg += (a >> 8) & 0xff
      , cb += a & 0xff
   }
   return ((Round(cr/pc) & 0xff) << 16) | ((Round(cg/pc) & 0xff) << 8) | (Round(cb/pc) & 0xff)
}
*/
;end_region

;region ;mfc wrapper;#####################################################################
regionGetColor_CreateCompatibleDC(hdc=0) {
   return DllCall("CreateCompatibleDC", "UInt", hdc)
}     

regionGetColor_CreateCompatibleBitmap(hdc, w, h) {
   return DllCall("CreateCompatibleBitmap", UInt, hdc, Int, w, Int, w)
}

regionGetColor_SelectObject(hdc, hgdiobj) {
   return DllCall("SelectObject", "UInt", hdc, "UInt", hgdiobj)
}

regionGetColor_GetDC(hwnd=0) {
   return DllCall("GetDC", "UInt", hwnd)
}

regionGetColor_BitBlt( hdc_dest, x1, y1, w1, h1 , hdc_source, x2, y2 , mode ) {
   return DllCall("BitBlt"
          , UInt,hdc_dest   , Int, x1, Int, y1, Int, w1, Int, h1
          , UInt,hdc_source , Int, x2, Int, y2
          , UInt, mode)
}

regionGetColor_DeleteObject(hObject) {
   Return, DllCall("DeleteObject", "UInt", hObject)
}

regionGetColor_DeleteDC(hdc) {
   Return, DllCall("DeleteDC", "UInt", hdc)
}

regionGetColor_ReleaseDC(hwnd, hdc) {
   Return, DllCall("ReleaseDC", "UInt", hwnd, "UInt", hdc)
}

regionGetColor_PrintWindow(hwnd, hdc, Flags=0) {
   return DllCall("PrintWindow", "UInt", hwnd, "UInt", hdc, "UInt", Flags)
}
;end_region