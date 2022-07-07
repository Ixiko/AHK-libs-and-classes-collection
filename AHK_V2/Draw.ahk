;
; DrawFunctions.ahk
;
; by iPhilip
; November 15, 2011
;
; Inspired by the work of Shimanov, Metaxal, maximo3491, Relayer
; Reference: http://www.autohotkey.com/forum/topic41756.html
;
; Defines a set of functions to draw color dots, lines, and boxes on the screen
;
; init_draw(c=1)
;      Moves the mouse off the screen and blocks any further input.
;      Initializes buffers and paints the canvas with color index c (default = 1 = black).
;      See below for the index/color map. A value of 0 makes the canvas appear transparent.
;
; exit_draw()
;      Launches when the left mouse button is clicked, restoring the mouse to its original coordinates
;      and exiting the application.
;
; paint_canvas(c=1)
;      Paints the canvas with color index c (default = 1 = black). See below for the index/color map.
;      A value of 0 makes the canvas appear to be transparent. It's actually a screenshot of the background.
;      The canvas gets erased each time this function is called.
;
; draw_dot(x, y, r=1, c=16)
;      Draws a dot of radius r pixels and color index c at (x,y). The default radius is 1.
;      The default color index is 16 (white). See below for the index/color map.
;
; draw_line(x0, y0, x1, y1, w=1, c=16)
;      Draws a line of width 2w pixels and color index c from (x0,y0) to (x1,y1). The line has rounded ends.
;      The default width is 1. The default color index is 16 (white). See below for the index/color map.
;
; draw_box(x0, y0, x1, y1, c=16)
;      Draws a box defined by the upper-left coordinates (x0,y0) and the bottom-right coordinates (x1,y1)
;      with color index c. The default color index is 16 (white). See below for the index/color map.
;
; Gloval variables: origX, origY, hdc_buffer1, hdc_buffer2, hdc_canvas, color[0-16]
;
;---------------------------------------------------------------------------------------------------------

init_draw(c=1) {
   global origX, origY, hdc_buffer1, hdc_buffer2, hdc_canvas, color0

   ; Move the mouse off the screen and block any further input
   CoordMode, Mouse, Screen
   MouseGetPos origX, origY
   MouseMove A_ScreenWidth, A_ScreenHeight, 0
   BlockInput MouseMove

   ; Create a working buffer
   hdc_screen  := DllCall("GetDC", "uint", 0)
   hdc_buffer1 := DllCall("CreateCompatibleDC", "uint", hdc_screen)
   hbm_buffer1 := DllCall("CreateCompatibleBitmap", "uint", hdc_screen, "int", A_ScreenWidth, "int", A_ScreenHeight)
   DllCall("SelectObject", "uint", hdc_buffer1, "uint", hbm_buffer1)

   ; Create a secondary buffer
   hdc_buffer2 := DllCall("CreateCompatibleDC", "uint", hdc_screen)
   hbm_buffer2 := DllCall("CreateCompatibleBitmap", "uint", hdc_screen, "int", A_ScreenWidth, "int", A_ScreenHeight)
   DllCall("SelectObject", "uint", hdc_buffer2, "uint", hbm_buffer2)

   ; Initialize the buffers with a screenshot so that the canvas appears transparent
   DllCall("BitBlt", "uint", hdc_buffer1, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_screen, "int", 0, "int", 0, "uint", 0x00CC0020)
   DllCall("BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_screen, "int", 0, "int", 0, "uint", 0x00CC0020)

   ; Create a window with the size of the display
   Gui, +AlwaysOnTop -Caption
   Gui, Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%

   ; Get the handle of the window associated with the canvas
   PID := DllCall("GetCurrentProcessId")
   WinGet, hw_canvas, ID, ahk_class AutoHotkeyGUI ahk_pid %PID%
   hdc_canvas := DllCall("GetDC", "uint", hw_canvas)

   ; Define color array
   ; References: http://en.wikipedia.org/wiki/Web_colors#HTML_color_names
   ;             http://www.autohotkey.com/forum/topic47746.html
   color_codes = 0x000000   ; 1.  Black
                ,0x000080   ; 2.  Navy
                ,0x008000   ; 3.  Green
                ,0x008080   ; 4.  Teal
                ,0x800000   ; 5.  Maroon
                ,0x800080   ; 6.  Purple
                ,0x808000   ; 7.  Olive
                ,0xC0C0C0   ; 8.  Silver
                ,0x808080   ; 9.  Gray
                ,0x0000FF   ; 10. Blue
                ,0x00FF00   ; 11. Lime
                ,0x00FFFF   ; 12. Aqua
                ,0xFF0000   ; 13. Red
                ,0xFF00FF   ; 14. Fuchsia
                ,0xFFFF00   ; 15. Yellow
                ,0xFFFFFF   ; 16. White
   StringSplit color, color_codes, `,
   Loop 16
      color%A_Index% := SubStr(color%A_Index%,1,2) SubStr(color%A_Index%,7,2) SubStr(color%A_Index%,5,2) SubStr(color%A_Index%,3,2)

   ; Paint the canvas with the initial color
   paint_canvas(c)

   ; Define the exit function that gets called when the mouse is clicked
   ; Reference: http://www.autohotkey.com/docs/commands/OnMessage.htm
   WM_LBUTTONDOWN = 0x201
   OnMessage(WM_LBUTTONDOWN, "exit_draw")
}

exit_draw() {
   global origX, origY
   BlockInput MouseMoveOff
   MouseMove origX, origY, 0
   ExitApp
}

paint_canvas(c=1) {   ; Default canvas color is black
   global hdc_buffer1, hdc_buffer2, hdc_canvas, color0
   if !c   ; 0 = transparent
   {
      DllCall("BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer1, "int", 0, "int", 0, "uint", 0x00CC0020)
      DllCall("BitBlt", "uint", hdc_canvas , "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020)
      return
   }
   cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color%c%)
   DllCall("SelectObject", "uint", hdc_buffer2, "uint", cBrush)
   DllCall("BitBlt", "uint", hdc_buffer2, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer1, "int", 0, "int", 0, "uint", 0x00F00021)
   DllCall("SelectObject", "uint", hdc_buffer2, "uint", 0)
   DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
   DllCall("BitBlt", "uint", hdc_canvas , "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020)
}

draw_dot(x, y, r=1, c=16) {
   global hdc_buffer2, hdc_canvas, color0
   cBrush  := DllCall("gdi32.dll\CreateSolidBrush", "uint", color%c%)
   cRegion := DllCall("gdi32.dll\CreateRoundRectRgn", "int", x-r, "int", y-r, "int", x+r, "int", y+r, "int", r*2, "int", r*2)
   DllCall("gdi32.dll\FillRgn" , "uint", hdc_buffer2 , "uint", cRegion , "uint", cBrush)
   DllCall("gdi32.dll\DeleteObject", "uint", cRegion)
   DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
   DllCall("BitBlt", "uint", hdc_canvas , "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020)
}

draw_line(x0, y0, x1, y1, w=1, c=16) {
   global hdc_buffer2, hdc_canvas, color0
   dx := x1 - x0
   dy := y1 - y0
   dxy := abs(dx) > abs(dy) ? abs(dx) : abs(dy)
   dx := dx / dxy
   dy := dy / dxy
   cBrush := DllCall("gdi32.dll\CreateSolidBrush", "uint", color%c%)
   Loop % round(dxy) + 1
   {
      cRegion := DllCall("gdi32.dll\CreateRoundRectRgn", "int", x0-w, "int", y0-w, "int", x0+w, "int", y0+w, "int", w*2, "int", w*2)
      DllCall("gdi32.dll\FillRgn" , "uint", hdc_buffer2 , "uint", cRegion , "uint", cBrush)
      DllCall("gdi32.dll\DeleteObject", "uint", cRegion)
      x0 += dx
      y0 += dy
   }
   DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
   DllCall("BitBlt", "uint", hdc_canvas , "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020)
}

draw_box(x0, y0, x1, y1, c=16) {
   global hdc_buffer2, hdc_canvas, color0
   cBrush  := DllCall("gdi32.dll\CreateSolidBrush", "uint", color%c%)
   cRegion := DllCall("gdi32.dll\CreateRectRgn", "int", x0, "int", y0, "int", x1, "int", y1)
   DllCall("gdi32.dll\FillRgn" , "uint", hdc_buffer2 , "uint", cRegion , "uint", cBrush)
   DllCall("gdi32.dll\DeleteObject", "uint", cRegion)
   DllCall("gdi32.dll\DeleteObject", "uint", cBrush)
   DllCall("BitBlt", "uint", hdc_canvas , "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", hdc_buffer2, "int", 0, "int", 0, "uint", 0x00CC0020)
}