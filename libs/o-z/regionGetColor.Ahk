/*                        	Example
#NoEnv
#SingleInstance, Force
SetBatchLines, -1
CoordMode, Mouse, Screen
RegionMain:
If !regionInit
{
   OnExit, Exit
   Gui, 1:+AlwaysOnTop +ToolWindow
   Gui, 1:Color, 0xffffff
   Gui, 1:Add, Edit, vGuiTextVar +ReadOnly h160 w180, Color: 0xffffff`nCount: `nTime: `n`n`n`n`n`n`n
   Gui, 1:Show, , regionColor
   Gui, 2:Color, 0xCCCCCC
   Gui, 2:+ToolWindow -Caption +Border +AlwaysOnTop +0x20 ; 0x20=click-thru
   Gui, 2:Add, Text, vGuiTextVar2 w80
   Gui, 2:+LastFound
   2GuiID := WinExist()
   Gui, 2:Show, X-2000 Y-2000 W1 H1
   WinSet, Trans, 150, ahk_id %2GuiID%
;   CoordMode, Mouse, Screen
   Process, Priority,, High
   SetBatchLines, -1
   SetWinDelay, -1
   RegionInit = 1
   GuiX := GuiY := 0
   GuiW := GuiH := 100
}
Gui, 1:Show
return
;end_region

;region ;Labels and Hotkeys; #############################################################
Esc::
Exit:
GuiClose:
   ExitApp

!LButton::
; use gui 2 to create a rectangle for area selection
   If !RegionInit
      GoSub RegionMain
   MouseGetPos, s_MSX, s_MSY, s_ID, s_CID, 2 ;start mouse X and Y
   WinSet, AlwaysOnTop, On, ahk_id %2GuiID%
   Loop
   {
      Sleep 20
      If !GetKeyState("LButton", "P")                  ;break if user releases the mouse
         Break   
      MouseGetPos, c_MSX, c_MSY                     ;current mouse X and Y
      GuiX := (s_MSX < c_MSX ? s_MSX : c_MSX)            ;use whichever smaller for X and Y
      GuiY := (s_MSY < c_MSY ? s_MSY : c_MSY)
      GuiW := Abs(Abs(s_MSX)-Abs(c_MSX))               ;doesn't matter which is bigger,
      GuiH := Abs(Abs(s_MSY)-Abs(c_MSY))               ;the absloute difference will be the same
      WinMove, ahk_id %2GuiID%,, GuiX, GuiY, GuiW, GuiH   ;move the window there
      GuiControl, 2:, GuiTextVar2, % GuiW ", " GuiH
   }
^!+r::               ;to retry at the last used coord.
   WinMove, ahk_id %2GuiID%,, GuiX, GuiY, GuiW, GuiH      ;to see where it's retrying
   Sleep 100
   WinMove, ahk_id %2GuiID%,, -2000,-2000, 2, 2          ;hide the window away
      WinGetPos, WinX, WinY, WinW, WinH, ahk_id %s_ID%
      ControlGetPos, CtrX, CtrY, CtrW, CtrH, , ahk_id %s_CID%
      regionInfo := "Relative to:`n   Screen: " GuiX "," GuiY
      regionInfo .= "`n   Window: " GuiX-WinX "," GuiY-WinY
      regionInfo .= "`n   Control: " GuiX-WinX-CtrX "," Guiy-WinY-CtrY
      regionInfo .= "`nWidth/Height: " GuiW "," GuiH
   Info1 := "RGB:`t"
   Color1 := regionGetColor(GuiX, GuiY, GuiW, GuiH) ;get the color of the region
   Time1 := "Time: " ErrorLevel
   Gui, 1:Color, %Color1%
   GuiControl, , GuiTextVar, % Info1 Color1 "`n`t" Time1 "`n`n" regionInfo
return
;end_region
*/

regionGetColor(x, y, w, h, hwnd=0) {
; created by Infogulch - thanks to Titan for much of this
; x, y, w, h  ~  coordinates of the region to average
; hwnd        ~  handle to the window that coords refers to
   DllCall("QueryPerformanceCounter", "Int64 *", Start1)
   If !hwnd, hdc := GetDC( hwnd )
      hcdc := hdc
   Else
   {
      WinGetPos, , , hwndW, hwndH, ahk_id %hwnd%
      hcdc := CreateCompatibleDC( hdc )
      , hbmp := CreateCompatibleBitmap( hdc, hwndW, hwndH )
      , hobj := SelectObject( hcdc, hbmp )
      , PrintWindow( hwnd, hcdc, 0 )
   }
   memdc := CreateCompatibleDC( hdc )
   , membmp := CreateCompatibleBitmap( hdc, w, h )
   , memobj := SelectObject( memdc, membmp )
   , BitBlt( memdc, 0, 0, w, h, hcdc, x, y, 0xCC0020 )
   , fmtI := A_FormatInteger
   SetFormat,    Integer, Hex
   retval := AvgBitmap(membmp, w * h) + 0
   SetFormat,    Integer, %fmtI%
   
   If hbmp
      DeleteObject(hbmp), SelectObject(hcdc, hobj), DeleteDC(hcdc)
   DeleteObject(membmp), SelectObject(memdc, memobj), DeleteDC(memdc)
   , ReleaseDC(hwnd, hdc)
   , DllCall("QueryPerformanceCounter", "Int64 *", End1), DllCall("QueryPerformanceFrequency", "Int64 *", f)
   return retval, ErrorLevel := (End1-Start1)/f
}

AvgBitmap(hbmp, pc) {
; by Infogulch
; hbmp  ~  handle to an existing bitmap
; pc    ~  size of the bitmap, should be w * h
; http://msdn.microsoft.com/en-us/library/dd144850(VS.85).aspx
   DllCall("GetBitmapBits", "UInt", hbmp, "UInt", VarSetCapacity(bits, pc*4, 0), "UInt", &bits)
   SumIntBytes(bits, pc, ca, cr, cg, cb)
   return ((Round(cr/pc) & 0xff) << 16) | ((Round(cg/pc) & 0xff) << 8) | (Round(cb/pc) & 0xff)
}

SumIntBytes( ByRef arr, len, ByRef a, ByRef r, ByRef g, ByRef b ) {
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

regionWaitColor(color, X, Y, W, H, hwnd=0, interval=100, timeout=5000, a="", b="", c="") {
   CompareColor := (color != "" ? color : regionGetColor(X, Y, W, H, hwnd))
   Start := A_TickCount
   while !(color ? retVal : !retVal) && !(timeout > 0 ? A_TickCount-Start > timeout : 0) 
   {
      retVal := regionCompareColor( CompareColor, x, y, w, h, hwnd, a, b, c)
      If interval
         Sleep interval
   }
   ErrorLevel := A_TickCount-Start
   Return (color ? retVal : !retVal)
}

regionCompareColor(color, x, y, w, h, hwnd=0, a="", b="", c="") {
   return withinVariation(regionGetColor(x, y, w, h, hwnd), color, a, b, c)
}

withinVariation( x, y, a, b="", c="") { 
; return wether x is within ±A ±B ±C of y
; if a is blank return wether x = y
; if b or c is blank, they are set equal to a
    If (a = "")
        return (x = y)
    v := Variation(x, y)
    return v >> 16 & 0xFF <= a
        && v >> 8  & 0xFF <= (b+0 ? b : a)
        && v       & 0xFF <= (c+0 ? c : a)
}

Variation( x, y ) {
    return Abs((x & 0xFF0000) - (y & 0xFF0000))
         | Abs((x & 0x00FF00) - (y & 0x00FF00))
         | Abs((x & 0x0000FF) - (y & 0x0000FF))
}

invertColor(x, a = "") {
; by Infogulch
; inverts the rgb/bgr hex color passed
; x: color to be inverted
; a: true to invert alpha as well
   return ~x & (a ? 0xFFFFFFFF : 0xFFFFFF)
}

;region ;mfc wrapper;#####################################################################
CreateCompatibleDC(hdc=0) {
   return DllCall("CreateCompatibleDC", "UInt", hdc)
}     

CreateCompatibleBitmap(hdc, w, h) {
   return DllCall("CreateCompatibleBitmap", UInt, hdc, Int, w, Int, h)
}

SelectObject(hdc, hgdiobj) {
   return DllCall("SelectObject", "UInt", hdc, "UInt", hgdiobj)
}

GetDC(hwnd=0) {
   return DllCall("GetDC", "UInt", hwnd)
}

BitBlt( hdc_dest, x1, y1, w1, h1 , hdc_source, x2, y2 , mode ) {
   return DllCall("BitBlt"
          , UInt,hdc_dest   , Int, x1, Int, y1, Int, w1, Int, h1
          , UInt,hdc_source , Int, x2, Int, y2
          , UInt, mode) 
}

DeleteObject(hObject) {
   Return, DllCall("DeleteObject", "UInt", hObject)
}

DeleteDC(hdc) {
   Return, DllCall("DeleteDC", "UInt", hdc)
}

ReleaseDC(hwnd, hdc) {
   Return, DllCall("ReleaseDC", "UInt", hwnd, "UInt", hdc)
}

PrintWindow(hwnd, hdc, Flags=0) {
   return DllCall("PrintWindow", "UInt", hwnd, "UInt", hdc, "UInt", Flags)
}
;end_region