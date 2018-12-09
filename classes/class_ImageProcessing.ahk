; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 
;    Name:				class_ImageProcessing.ahk
;    Description: 	Image Processing Library - Scale, crop, and compare images from anywhere!
;    Author: 			iseahound
;    Posted: 			17 Nov 2018, 23:28
;    Link: ﻿				https://autohotkey.com/boards/viewtopic.php?t=59113
; *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  * 

#include <Gdip_All>    ; https://goo.gl/rUuEF5

; Preprocess() - Modifies an input image and returns it in a new form.
; Example: Preprocess("base64", "https://goo.gl/BWUygC")
;          The image is downloaded from the URL and is converted to base64.
ImagePreprocess(cotype, image, crop:="", scale:="", terms*){
   return Graphics.Picture.Preprocess(cotype, image, crop, scale, terms*)
}

ImageEquality(images*){
   return Graphics.Picture.Equality(images*)
}

ImageRender(image:="", style:="", polygons:=""){
   return Graphics.Picture.Render(image, style, polygons)
}

TextRender(text:="", style1:="", style2:=""){
   return Graphics.Subtitle.Render(text, style1, style2)
}

ImageToFile(image, crop := "", scale := "", filename := "", compression := "") {
   return Graphics.Picture.Preprocess("file", image, crop, scale, filename, compression)
}

ImageToBase64(image, crop := "", scale := "", extension := "", compression := "") {
   return Graphics.Picture.Preprocess("base64", image, crop, scale, extension, compression)
}

class Graphics {

   static pToken, Gdip := 0  ; Gdip is the number of active graphics objects.

   Startup() {
      global pToken
      return this.inner.pToken := (this.inner.Gdip++ > 0) ? this.inner.pToken : ((pToken) ? pToken : Gdip_Startup())
   }

   Shutdown() {
      global pToken
      return this.inner.pToken := (--this.inner.Gdip <= 0) ? ((pToken) ? pToken : Gdip_Shutdown(this.inner.pToken)) : this.inner.pToken
   }

   inner[] {
      get {
         if (_class := this.__class)
            Loop, Parse, _class, .
               inner := (A_Index=1) ? %A_LoopField% : inner[A_LoopField]
         return inner
      }
   }

   class memory {

      __New(width, height){
         this.hbm := CreateDIBSection(this.width := width, this.height := height)
         this.hdc := CreateCompatibleDC()
         this.obm := SelectObject(this.hdc, this.hbm)
         this.G := Gdip_GraphicsFromHDC(this.hdc)
         return this
      }

      __Delete(){
         Gdip_DeleteGraphics(this.G)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         return
      }
   }

   class queue {

      layers := []
      fn := []
      x := []
      y := []
      w := []
      h := []
      xx := []
      yy := []
      mx := []
      my := []
      x_mouse := ""
      y_mouse := ""

      New(function, x_mouse := "", y_mouse := ""){
         if (function == this.fn.2)
            return

         if (this.fn.2 != "" && this.lacuna(2))
            return

         this.shift()
         this.fn.2 := function
         this.x_mouse := x_mouse
         this.y_mouse := y_mouse
         return true ; useful for allowing a new function to execute when x,y coordinates have remained the same.
      }

      ; This function takes any number of inputs, from zero to 8. It will populate the inputs with their
      ; last known values if omitted. In the case of w & h it will check for a xx & yy input. In the case of
      ; xx & yy, it will check for a w & h input AND check w & h last known value. This means that if w, h, xx, yy
      ; are omitted, the width and height will remain constant, and the right and bottom values will change.
      Queue(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="", ByRef xx:="", ByRef yy:="", ByRef mx:="", ByRef my:=""){
         ; Store the last found w & h to check if size has changed, forcing a redraw.
         old_w := (this.w.2 != "") ? this.w.2 : this.w.1
         old_h := (this.h.2 != "") ? this.h.2 : this.h.1

         ; x & y are independent and mandatory inputs.
         if (x != "")
            this.x.2 := x
         else if (this.x.2 == "" && this.x.1 != "")
            this.x.2 := this.x.1
         else if (this.x.2 == "")
            throw Exception("x coordinate is a mandatory parameter.")

         if (y != "")
            this.y.2 := y
         else if (this.y.2 == "" && this.y.1 != "")
            this.y.2 := this.y.1
         else if (this.y.2 == "")
            throw Exception("y coordinate is a mandatory parameter.")

         ; w & h are dependent on this.x.2 and this.y.2
         if (w != "")
            this.w.2 := w
         else if (xx != "")
            this.w.2 := xx - this.x.2
         else if (this.w.2 == "" && this.w.1 != "")
            this.w.2 := this.w.1

         if (h != "")
            this.h.2 := h
         else if (yy != "")
            this.h.2 := yy - this.y.2
         else if (this.h.2 == "" && this.h.1 != "")
            this.h.2 := this.h.1

         ; xx & yy are dependent on this.x.2, this.y.2, this.w.2, and this.h.2
         if (xx != "")
            this.xx.2 := xx
         else if (x != "")
            this.xx.2 := this.w.2 + x
         else if (w != "")
            this.xx.2 := this.x.2 + w
         else if (this.xx.2 == "" && this.xx.1 != "")
            this.xx.2 := this.xx.1

         if (yy != "")
            this.yy.2 := yy
         else if (y != "")
            this.yy.2 := this.h.2 + y
         else if (h != "")
            this.yy.2 := this.y.2 + h
         else if (this.yy.2 == "" && this.y.1 != "")
            this.yy.2 := this.yy.1

         ; mx & my are independent variables.
         if (mx != "")
            this.mx.2 := mx
         else if (this.mx.2 == "" && this.mx.1 != "")
            this.mx.2 := this.mx.1

         if (my != "")
            this.my.2 := my
         else if (this.my.2 == "" && this.my.1 != "")
            this.my.2 := this.my.1

         ; Internal checking - can be commented out
         if (this.xx.2 - this.x.2 != this.w.2)
            throw Exception("Inconsistent width or x2.")

         if (this.yy.2 - this.y.2 != this.h.2)
            throw Exception("Inconsistent height or y2.")

         ; Detect if width or height has changed, requiring the image to be redrawn.
         this.identical := (this.w.2 == old_w) && (this.h.2 == old_h)

         ; Return coordinate values by reference.
         x := this.x.2, w := this.w.2, xx := this.xx.2, mx := this.mx.2
         y := this.y.2, h := this.h.2, yy := this.yy.2, my := this.my.2
      }

      Shift(){
         this.fn.RemoveAt(1)
         this.x.RemoveAt(1)
         this.y.RemoveAt(1)
         this.w.RemoveAt(1)
         this.h.RemoveAt(1)
         this.xx.RemoveAt(1)
         this.yy.RemoveAt(1)
         this.mx.RemoveAt(1)
         this.my.RemoveAt(1)
      }

      Lacuna(n := 2){
         return (this.x[n] == "" || this.y[n] == "" || this.w[n] == "" || this.h[n] == ""
            || this.xx[n] == "" || this.yy[n] == "")
      }

      Debug(){
         Tooltip % "function: " this.fn.2
            . "`nx: " this.x.2 "`ty: " this.y.2
            . "`nw: " this.w.2 "`th: " this.h.2
            . "`nx2: " this.xx.2 "`ty2: " this.yy.2
            . "`nmx: " this.mx.2 "`tmy: " this.my.2

            . "`nfunction: " this.fn.1
            . "`nx: " this.x.1 "`ty: " this.y.1
            . "`nw: " this.w.1 "`th: " this.h.1
            . "`nx2: " this.xx.1 "`ty2: " this.yy.1
            . "`nmx: " this.mx.1 "`tmy: " this.my.1
      }
   }

   class shared {

      __New(title := "", terms*) {
         global pToken
         if !(this.outer.Startup())
            if !(pToken)
               if !(this.pToken := Gdip_Startup())
                  throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

         Gui, New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndhwnd
         Gui, Show, % (this.activateOnAdmin && !this.isDrawable()) ? "" : "NoActivate"
         this.hwnd := hwnd
         this.title := (title != "") ? title : RegExReplace(this.__class, "(.*\.)*(.*)$", "$2") "_" this.hwnd
         DllCall("SetWindowText", "ptr",this.hwnd, "str",this.title)
         this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
         this.hdc := CreateCompatibleDC()
         this.obm := SelectObject(this.hdc, this.hbm)
         this.G := Gdip_GraphicsFromHDC(this.hdc)
         this.state := new this.outer.queue()
         this.Additional(terms*)
         return this
      }

      __Delete() {
         global pToken
         if (this.outer.pToken)
            return this.outer.Shutdown()
         if (pToken)
            return
         if (this.pToken)
            return Gdip_Shutdown(this.pToken)
      }

      MouseGetPos(ByRef x_mouse, ByRef y_mouse) {
         _cmm := A_CoordModeMouse
         CoordMode, Mouse, Screen
         MouseGetPos, x_mouse, y_mouse
         CoordMode, Mouse, %_cmm%
      }

      isDrawable(win := "A") {
          static WM_KEYDOWN := 0x100
          static WM_KEYUP := 0x101
          static vk_to_use := 7
          ; Test whether we can send keystrokes to this window.
          ; Use a virtual keycode which is unlikely to do anything:
          PostMessage, WM_KEYDOWN, vk_to_use, 0,, % win
          if !ErrorLevel
          {   ; Seems best to post key-up, in case the window is keeping track.
              PostMessage, WM_KEYUP, vk_to_use, 0xC0000000,, % win
              return true
          }
          return false
      }

      Rect() {
         x1 := this.x1(), y1 := this.y1(), x2 := this.x2(), y2 := this.y2()
         return (x2 > x1 && y2 > y1) ? [x1, y1, x2, y2] : ""
      }

      DetectScreenResolutionChange(width := "", height := "") {
         width := (width) ? width : A_ScreenWidth
         height := (height) ? height : A_ScreenHeight
         if (width != this.ScreenWidth || height != this.ScreenHeight) {
            this.ScreenWidth := width, this.ScreenHeight := height
            SelectObject(this.hdc, this.obm)
            DeleteObject(this.hbm)
            DeleteDC(this.hdc)
            Gdip_DeleteGraphics(this.G)
            this.hbm := CreateDIBSection(this.ScreenWidth, this.ScreenHeight)
            this.hdc := CreateCompatibleDC()
            this.obm := SelectObject(this.hdc, this.hbm)
            this.G := Gdip_GraphicsFromHDC(this.hdc)
            this.Recover(this.G)
         }
         return this
      }

      FreeMemory() {
         this.Before()
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         Gdip_DeleteGraphics(this.G)
         return this
      }

      Destroy() {
         this.FreeMemory()
         DllCall("DestroyWindow", "ptr",this.hwnd)
         return this
      }

      isVisible() {
         return DllCall("IsWindowVisible", "ptr",this.hwnd)
      }

      Hide() {
         DllCall("ShowWindow", "ptr",this.hwnd, "int",0)
         return this
      }

      Show(i := 8) {
         DllCall("ShowWindow", "ptr",this.hwnd, "int",i)
         return this
      }

      ToggleVisible() {
         return (this.isVisible()) ? this.Hide() : this.Show()
      }

      AlwaysOnTop(s := -1) {
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, AlwaysOnTop, % s, % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      Bottom() {
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, Bottom,, % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      ; NOT WORKING!
      Caption(s := -1) {
         s := (s = -1) ? "^" : (s = 0) ? "-" : "+"
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, Style, % s "0xC00000", % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      ClickThrough(s := -1) {
         s := (s = -1) ? "^" : (s = 0) ? "-" : "+"
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, ExStyle, % s "0x20", % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      Normal() {
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, AlwaysOnTop, Off, % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      ToolWindow(s := -1) {
         s := (s = -1) ? "^" : (s = 0) ? "-" : "+"
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         WinSet, ExStyle, % s "0x80", % "ahk_id" this.hwnd
         DetectHiddenWindows %_dhw%
         return this
      }

      Desktop() {
         ; Based on: https://www.codeproject.com/Articles/856020/Draw-Behind-Desktop-Icons-in-Windows-plus?msg=5478543#xx5478543xx
         DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",0)
         DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",1) ; Post-Creator's Update Windows 10.
         WinGet, windows, List, ahk_class WorkerW
         Loop, %windows%
            if (DllCall("FindWindowEx", "ptr",windows%A_Index%, "ptr",0, "str","SHELLDLL_DefView", "ptr",0) != 0)
               WorkerW := DllCall("FindWindowEx", "ptr",0, "ptr",windows%A_Index%, "str","WorkerW", "ptr",0)

         if (WorkerW) {
            this.Destroy()
            this.hwnd := WorkerW
            DllCall("SetWindowPos", "uint",WorkerW, "uint",1, "int",0, "int",0, "int",this.ScreenWidth, "int",this.ScreenHeight, "uint",0)
            this.base.FreeMemory := ObjBindMethod(this, "DesktopFreeMemory")
            this.base.Destroy := ObjBindMethod(this, "DesktopDestroy")
            this.hdc := DllCall("GetDCEx", "ptr",WorkerW, "ptr",0, "int",0x403)
            this.G := Gdip_GraphicsFromHDC(this.hdc)
         }
         return this
      }

      DesktopFreeMemory() {
         ReleaseDC(this.hdc)
         Gdip_DeleteGraphics(this.G)
         return this
      }

      DesktopDestroy() {
         this.FreeMemory()
         DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",0)
         DllCall("SendMessage", "ptr",WinExist("ahk_class Progman"), "uint",0x052C, "ptr",0x0000000D, "ptr",1)
         return this
      }

      color(c, default := 0xDD424242) {
         static colorRGB  := "^0x([0-9A-Fa-f]{6})$"
         static colorARGB := "^0x([0-9A-Fa-f]{8})$"
         static hex6      :=   "^([0-9A-Fa-f]{6})$"
         static hex8      :=   "^([0-9A-Fa-f]{8})$"

         if ObjGetCapacity([c], 1) {
            c  := (c ~= "^#") ? SubStr(c, 2) : c
            c  := ((___ := this.colorMap(c)) != "") ? ___ : c
            c  := (c ~= colorRGB) ? "0xFF" RegExReplace(c, colorRGB, "$1") : (c ~= hex8) ? "0x" c : (c ~= hex6) ? "0xFF" c : c
            c  := (c ~= colorARGB) ? c : default
         }
         return (c != "") ? c : default
      }

      colorMap(c) {
         static map

         if !(map) {
         color := [] ; 73 LINES MAX
         color["Clear"] := color["Off"] := color["None"] := color["Transparent"] := "0x00000000"

            color["AliceBlue"]             := "0xFFF0F8FF"
         ,  color["AntiqueWhite"]          := "0xFFFAEBD7"
         ,  color["Aqua"]                  := "0xFF00FFFF"
         ,  color["Aquamarine"]            := "0xFF7FFFD4"
         ,  color["Azure"]                 := "0xFFF0FFFF"
         ,  color["Beige"]                 := "0xFFF5F5DC"
         ,  color["Bisque"]                := "0xFFFFE4C4"
         ,  color["Black"]                 := "0xFF000000"
         ,  color["BlanchedAlmond"]        := "0xFFFFEBCD"
         ,  color["Blue"]                  := "0xFF0000FF"
         ,  color["BlueViolet"]            := "0xFF8A2BE2"
         ,  color["Brown"]                 := "0xFFA52A2A"
         ,  color["BurlyWood"]             := "0xFFDEB887"
         ,  color["CadetBlue"]             := "0xFF5F9EA0"
         ,  color["Chartreuse"]            := "0xFF7FFF00"
         ,  color["Chocolate"]             := "0xFFD2691E"
         ,  color["Coral"]                 := "0xFFFF7F50"
         ,  color["CornflowerBlue"]        := "0xFF6495ED"
         ,  color["Cornsilk"]              := "0xFFFFF8DC"
         ,  color["Crimson"]               := "0xFFDC143C"
         ,  color["Cyan"]                  := "0xFF00FFFF"
         ,  color["DarkBlue"]              := "0xFF00008B"
         ,  color["DarkCyan"]              := "0xFF008B8B"
         ,  color["DarkGoldenRod"]         := "0xFFB8860B"
         ,  color["DarkGray"]              := "0xFFA9A9A9"
         ,  color["DarkGrey"]              := "0xFFA9A9A9"
         ,  color["DarkGreen"]             := "0xFF006400"
         ,  color["DarkKhaki"]             := "0xFFBDB76B"
         ,  color["DarkMagenta"]           := "0xFF8B008B"
         ,  color["DarkOliveGreen"]        := "0xFF556B2F"
         ,  color["DarkOrange"]            := "0xFFFF8C00"
         ,  color["DarkOrchid"]            := "0xFF9932CC"
         ,  color["DarkRed"]               := "0xFF8B0000"
         ,  color["DarkSalmon"]            := "0xFFE9967A"
         ,  color["DarkSeaGreen"]          := "0xFF8FBC8F"
         ,  color["DarkSlateBlue"]         := "0xFF483D8B"
         ,  color["DarkSlateGray"]         := "0xFF2F4F4F"
         ,  color["DarkSlateGrey"]         := "0xFF2F4F4F"
         ,  color["DarkTurquoise"]         := "0xFF00CED1"
         ,  color["DarkViolet"]            := "0xFF9400D3"
         ,  color["DeepPink"]              := "0xFFFF1493"
         ,  color["DeepSkyBlue"]           := "0xFF00BFFF"
         ,  color["DimGray"]               := "0xFF696969"
         ,  color["DimGrey"]               := "0xFF696969"
         ,  color["DodgerBlue"]            := "0xFF1E90FF"
         ,  color["FireBrick"]             := "0xFFB22222"
         ,  color["FloralWhite"]           := "0xFFFFFAF0"
         ,  color["ForestGreen"]           := "0xFF228B22"
         ,  color["Fuchsia"]               := "0xFFFF00FF"
         ,  color["Gainsboro"]             := "0xFFDCDCDC"
         ,  color["GhostWhite"]            := "0xFFF8F8FF"
         ,  color["Gold"]                  := "0xFFFFD700"
         ,  color["GoldenRod"]             := "0xFFDAA520"
         ,  color["Gray"]                  := "0xFF808080"
         ,  color["Grey"]                  := "0xFF808080"
         ,  color["Green"]                 := "0xFF008000"
         ,  color["GreenYellow"]           := "0xFFADFF2F"
         ,  color["HoneyDew"]              := "0xFFF0FFF0"
         ,  color["HotPink"]               := "0xFFFF69B4"
         ,  color["IndianRed"]             := "0xFFCD5C5C"
         ,  color["Indigo"]                := "0xFF4B0082"
         ,  color["Ivory"]                 := "0xFFFFFFF0"
         ,  color["Khaki"]                 := "0xFFF0E68C"
         ,  color["Lavender"]              := "0xFFE6E6FA"
         ,  color["LavenderBlush"]         := "0xFFFFF0F5"
         ,  color["LawnGreen"]             := "0xFF7CFC00"
         ,  color["LemonChiffon"]          := "0xFFFFFACD"
         ,  color["LightBlue"]             := "0xFFADD8E6"
         ,  color["LightCoral"]            := "0xFFF08080"
         ,  color["LightCyan"]             := "0xFFE0FFFF"
         ,  color["LightGoldenRodYellow"]  := "0xFFFAFAD2"
         ,  color["LightGray"]             := "0xFFD3D3D3"
         ,  color["LightGrey"]             := "0xFFD3D3D3"
            color["LightGreen"]            := "0xFF90EE90"
         ,  color["LightPink"]             := "0xFFFFB6C1"
         ,  color["LightSalmon"]           := "0xFFFFA07A"
         ,  color["LightSeaGreen"]         := "0xFF20B2AA"
         ,  color["LightSkyBlue"]          := "0xFF87CEFA"
         ,  color["LightSlateGray"]        := "0xFF778899"
         ,  color["LightSlateGrey"]        := "0xFF778899"
         ,  color["LightSteelBlue"]        := "0xFFB0C4DE"
         ,  color["LightYellow"]           := "0xFFFFFFE0"
         ,  color["Lime"]                  := "0xFF00FF00"
         ,  color["LimeGreen"]             := "0xFF32CD32"
         ,  color["Linen"]                 := "0xFFFAF0E6"
         ,  color["Magenta"]               := "0xFFFF00FF"
         ,  color["Maroon"]                := "0xFF800000"
         ,  color["MediumAquaMarine"]      := "0xFF66CDAA"
         ,  color["MediumBlue"]            := "0xFF0000CD"
         ,  color["MediumOrchid"]          := "0xFFBA55D3"
         ,  color["MediumPurple"]          := "0xFF9370DB"
         ,  color["MediumSeaGreen"]        := "0xFF3CB371"
         ,  color["MediumSlateBlue"]       := "0xFF7B68EE"
         ,  color["MediumSpringGreen"]     := "0xFF00FA9A"
         ,  color["MediumTurquoise"]       := "0xFF48D1CC"
         ,  color["MediumVioletRed"]       := "0xFFC71585"
         ,  color["MidnightBlue"]          := "0xFF191970"
         ,  color["MintCream"]             := "0xFFF5FFFA"
         ,  color["MistyRose"]             := "0xFFFFE4E1"
         ,  color["Moccasin"]              := "0xFFFFE4B5"
         ,  color["NavajoWhite"]           := "0xFFFFDEAD"
         ,  color["Navy"]                  := "0xFF000080"
         ,  color["OldLace"]               := "0xFFFDF5E6"
         ,  color["Olive"]                 := "0xFF808000"
         ,  color["OliveDrab"]             := "0xFF6B8E23"
         ,  color["Orange"]                := "0xFFFFA500"
         ,  color["OrangeRed"]             := "0xFFFF4500"
         ,  color["Orchid"]                := "0xFFDA70D6"
         ,  color["PaleGoldenRod"]         := "0xFFEEE8AA"
         ,  color["PaleGreen"]             := "0xFF98FB98"
         ,  color["PaleTurquoise"]         := "0xFFAFEEEE"
         ,  color["PaleVioletRed"]         := "0xFFDB7093"
         ,  color["PapayaWhip"]            := "0xFFFFEFD5"
         ,  color["PeachPuff"]             := "0xFFFFDAB9"
         ,  color["Peru"]                  := "0xFFCD853F"
         ,  color["Pink"]                  := "0xFFFFC0CB"
         ,  color["Plum"]                  := "0xFFDDA0DD"
         ,  color["PowderBlue"]            := "0xFFB0E0E6"
         ,  color["Purple"]                := "0xFF800080"
         ,  color["RebeccaPurple"]         := "0xFF663399"
         ,  color["Red"]                   := "0xFFFF0000"
         ,  color["RosyBrown"]             := "0xFFBC8F8F"
         ,  color["RoyalBlue"]             := "0xFF4169E1"
         ,  color["SaddleBrown"]           := "0xFF8B4513"
         ,  color["Salmon"]                := "0xFFFA8072"
         ,  color["SandyBrown"]            := "0xFFF4A460"
         ,  color["SeaGreen"]              := "0xFF2E8B57"
         ,  color["SeaShell"]              := "0xFFFFF5EE"
         ,  color["Sienna"]                := "0xFFA0522D"
         ,  color["Silver"]                := "0xFFC0C0C0"
         ,  color["SkyBlue"]               := "0xFF87CEEB"
         ,  color["SlateBlue"]             := "0xFF6A5ACD"
         ,  color["SlateGray"]             := "0xFF708090"
         ,  color["SlateGrey"]             := "0xFF708090"
         ,  color["Snow"]                  := "0xFFFFFAFA"
         ,  color["SpringGreen"]           := "0xFF00FF7F"
         ,  color["SteelBlue"]             := "0xFF4682B4"
         ,  color["Tan"]                   := "0xFFD2B48C"
         ,  color["Teal"]                  := "0xFF008080"
         ,  color["Thistle"]               := "0xFFD8BFD8"
         ,  color["Tomato"]                := "0xFFFF6347"
         ,  color["Turquoise"]             := "0xFF40E0D0"
         ,  color["Violet"]                := "0xFFEE82EE"
         ,  color["Wheat"]                 := "0xFFF5DEB3"
         ,  color["White"]                 := "0xFFFFFFFF"
         ,  color["WhiteSmoke"]            := "0xFFF5F5F5"
            color["Yellow"]                := "0xFFFFFF00"
         ,  color["YellowGreen"]           := "0xFF9ACD32"
         map := color
         }

         return map[c]
      }

      margin_and_padding(m, default := 0) {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid := "(?i)^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         if IsObject(m) {
            m.1 := (m.top    != "") ? m.top    : m.t
            m.2 := (m.right  != "") ? m.right  : m.r
            m.3 := (m.bottom != "") ? m.bottom : m.b
            m.4 := (m.left   != "") ? m.left   : m.l
         } else if (m != "") {
            _ := RegExReplace(m, ":\s+", ":")
            _ := RegExReplace(_, "\s+", " ")
            _ := StrSplit(_, " ")
            _.1 := ((___ := RegExReplace(m, q1    "(t(op)?)"           q2, "${value}")) != m) ? ___ : _.1
            _.2 := ((___ := RegExReplace(m, q1    "(r(ight)?)"         q2, "${value}")) != m) ? ___ : _.2
            _.3 := ((___ := RegExReplace(m, q1    "(b(ottom)?)"        q2, "${value}")) != m) ? ___ : _.3
            _.4 := ((___ := RegExReplace(m, q1    "(l(eft)?)"          q2, "${value}")) != m) ? ___ : _.4
            m := _
         }
         else return {1:default, 2:default, 3:default, 4:default}

         ; Follow CSS guidelines for margin!
         if (m.2 == "" && m.3 == "" && m.4 == "")
            m.4 := m.3 := m.2 := m.1, exception := true
         if (m.3 == "" && m.4 == "")
            m.4 := m.2, m.3 := m.1
         if (m.4 == "")
            m.4 := m.2

         for key, value in m {
            m[key] := (m[key] ~= valid) ? RegExReplace(m[key], "\s", "") : default
            m[key] := (m[key] ~= "i)(pt|px)$") ? SubStr(m[key], 1, -2) : m[key]
            m[key] := (m[key] ~= "i)vw$") ? RegExReplace(m[key], "i)vw$", "") * this.vw : m[key]
            m[key] := (m[key] ~= "i)vh$") ? RegExReplace(m[key], "i)vh$", "") * this.vh : m[key]
            m[key] := (m[key] ~= "i)vmin$") ? RegExReplace(m[key], "i)vmin$", "") * this.vmin : m[key]
         }
         m.1 := (m.1 ~= "%$") ? SubStr(m.1, 1, -1) * this.vh : m.1
         m.2 := (m.2 ~= "%$") ? SubStr(m.2, 1, -1) * (exception ? this.vh : this.vw) : m.2
         m.3 := (m.3 ~= "%$") ? SubStr(m.3, 1, -1) * this.vh : m.3
         m.4 := (m.4 ~= "%$") ? SubStr(m.4, 1, -1) * (exception ? this.vh : this.vw) : m.4
         return m
      }

      GaussianBlur(ByRef pBitmap, radius, opacity := 1) {
         static x86 := "
         (LTrim
         VYnlV1ZTg+xci0Uci30c2UUgx0WsAwAAAI1EAAGJRdiLRRAPr0UYicOJRdSLRRwP
         r/sPr0UYiX2ki30UiUWoi0UQjVf/i30YSA+vRRgDRQgPr9ONPL0SAAAAiUWci0Uc
         iX3Eg2XE8ECJVbCJRcCLRcSJZbToAAAAACnEi0XEiWXk6AAAAAApxItFxIllzOgA
         AAAAKcSLRaiJZcjHRdwAAAAAx0W8AAAAAIlF0ItFvDtFFA+NcAEAAItV3DHAi12c
         i3XQiVXgAdOLfQiLVdw7RRiNDDp9IQ+2FAGLTcyLfciJFIEPtgwDD69VwIkMh4tN
         5IkUgUDr0THSO1UcfBKLXdwDXQzHRbgAAAAAK13Q6yAxwDtFGH0Ni33kD7YcAQEc
         h0Dr7kIDTRjrz/9FuAN1GItF3CtF0AHwiceLRbg7RRx/LDHJO00YfeGLRQiLfcwB
         8A+2BAgrBI+LfeQDBI+ZiQSPjTwz933YiAQPQevWi0UIK0Xci03AAfCJRbiLXRCJ
         /itdHCt13AN14DnZfAgDdQwrdeDrSot1DDHbK3XcAf4DdeA7XRh9KItV4ItFuAHQ
         A1UID7YEGA+2FBop0ItV5AMEmokEmpn3fdiIBB5D69OLRRhBAUXg66OLRRhDAUXg
         O10QfTIxyTtNGH3ti33Ii0XgA0UID7YUCIsEjynQi1XkAwSKiQSKi1XgjTwWmfd9
         2IgED0Hr0ItF1P9FvAFF3AFF0OmE/v//i0Wkx0XcAAAAAMdFvAAAAACJRdCLRbAD
         RQyJRaCLRbw7RRAPjXABAACLTdwxwItdoIt10IlN4AHLi30Mi1XcO0UYjQw6fSEP
         thQBi33MD7YMA4kUh4t9yA+vVcCJDIeLTeSJFIFA69Ex0jtVHHwSi13cA10Ix0W4
         AAAAACtd0OsgMcA7RRh9DYt95A+2HAEBHIdA6+5CA03U68//RbgDddSLRdwrRdAB
         8InHi0W4O0UcfywxyTtNGH3hi0UMi33MAfAPtgQIKwSPi33kAwSPmYkEj408M/d9
         2IgED0Hr1otFDCtF3ItNwAHwiUW4i10Uif4rXRwrddwDdeA52XwIA3UIK3Xg60qL
         dQgx2yt13AH+A3XgO10YfSiLVeCLRbgB0ANVDA+2BBgPthQaKdCLVeQDBJqJBJqZ
         933YiAQeQ+vTi0XUQQFF4Ouji0XUQwFF4DtdFH0yMck7TRh97Yt9yItF4ANFDA+2
         FAiLBI+LfeQp0ItV4AMEj4kEj408Fpn3fdiIBA9B69CLRRj/RbwBRdwBRdDphP7/
         //9NrItltA+Fofz//9no3+l2PzHJMds7XRR9OotFGIt9CA+vwY1EBwMx/zt9EH0c
         D7Yw2cBHVtoMJFrZXeTzDyx15InyiBADRRjr30MDTRDrxd3Y6wLd2I1l9DHAW15f
         XcM=
         )"
         static x64 := "
         (LTrim
         VUFXQVZBVUFUV1ZTSIHsqAAAAEiNrCSAAAAARIutkAAAAIuFmAAAAESJxkiJVRhB
         jVH/SYnPi42YAAAARInHQQ+v9Y1EAAErvZgAAABEiUUARIlN2IlFFEljxcdFtAMA
         AABIY96LtZgAAABIiUUID6/TiV0ESIld4A+vy4udmAAAAIl9qPMPEI2gAAAAiVXQ
         SI0UhRIAAABBD6/1/8OJTbBIiVXoSINl6PCJXdxBifaJdbxBjXD/SWPGQQ+v9UiJ
         RZhIY8FIiUWQiXW4RInOK7WYAAAAiXWMSItF6EiJZcDoAAAAAEgpxEiLRehIieHo
         AAAAAEgpxEiLRehIiWX46AAAAABIKcRIi0UYTYn6SIll8MdFEAAAAADHRdQAAAAA
         SIlFyItF2DlF1A+NqgEAAESLTRAxwEWJyEQDTbhNY8lNAflBOcV+JUEPthQCSIt9
         +EUPthwBSItd8IkUhw+vVdxEiRyDiRSBSP/A69aLVRBFMclEO42YAAAAfA9Ii0WY
         RTHbMdtNjSQC6ytMY9oxwE0B+0E5xX4NQQ+2HAMBHIFI/8Dr7kH/wUQB6uvGTANd
         CP/DRQHoO52YAAAAi0W8Ro00AH82SItFyEuNPCNFMclJjTQDRTnNftRIi1X4Qg+2
         BA9CKwSKQgMEiZlCiQSJ930UQogEDkn/wevZi0UQSWP4SAN9GItd3E1j9kUx200B
         /kQpwIlFrEiJfaCLdaiLRaxEAcA580GJ8XwRSGP4TWPAMdtMAf9MA0UY60tIi0Wg
         S408Hk+NJBNFMclKjTQYRTnNfiFDD7YUDEIPtgQPKdBCAwSJmUKJBIn3fRRCiAQO
         Sf/B69r/w0UB6EwDXQjrm0gDXQhB/8FEO00AfTRMjSQfSY00GEUx20U53X7jSItF
         8EMPthQcQosEmCnQQgMEmZlCiQSZ930UQogEHkn/w+vXi0UEAUUQSItF4P9F1EgB
         RchJAcLpSv7//0yLVRhMiX3Ix0UQAAAAAMdF1AAAAACLRQA5RdQPja0BAABEi00Q
         McBFichEA03QTWPJTANNGEE5xX4lQQ+2FAJIi3X4RQ+2HAFIi33wiRSGD69V3ESJ
         HIeJFIFI/8Dr1otVEEUxyUQ7jZgAAAB8D0iLRZBFMdsx202NJALrLUxj2kwDXRgx
         wEE5xX4NQQ+2HAMBHIFI/8Dr7kH/wQNVBOvFRANFBEwDXeD/wzudmAAAAItFsEaN
         NAB/NkiLRchLjTwjRTHJSY00A0U5zX7TSItV+EIPtgQPQisEikIDBImZQokEifd9
         FEKIBA5J/8Hr2YtFEE1j9klj+EwDdRiLXdxFMdtEKcCJRaxJjQQ/SIlFoIt1jItF
         rEQBwDnzQYnxfBFNY8BIY/gx20gDfRhNAfjrTEiLRaBLjTweT40kE0UxyUqNNBhF
         Oc1+IUMPthQMQg+2BA8p0EIDBImZQokEifd9FEKIBA5J/8Hr2v/DRANFBEwDXeDr
         mkgDXeBB/8FEO03YfTRMjSQfSY00GEUx20U53X7jSItF8EMPthQcQosEmCnQQgME
         mZlCiQSZ930UQogEHkn/w+vXSItFCP9F1EQBbRBIAUXISQHC6Uf+////TbRIi2XA
         D4Ui/P//8w8QBQAAAAAPLsF2TTHJRTHARDtF2H1Cicgx0kEPr8VImEgrRQhNjQwH
         McBIA0UIO1UAfR1FD7ZUAQP/wvNBDyrC8w9ZwfNEDyzQRYhUAQPr2kH/wANNAOu4
         McBIjWUoW15fQVxBXUFeQV9dw5CQkJCQkJCQkJCQkJAAAIA/
         )"
         width := Gdip_GetImageWidth(pBitmap)
         height := Gdip_GetImageHeight(pBitmap)
         clone := Gdip_CloneBitmapArea(pBitmap, 0, 0, width, height)
         E1 := Gdip_LockBits(pBitmap, 0, 0, width, height, Stride1, Scan01, BitmapData1)
         E2 := Gdip_LockBits(clone, 0, 0, width, height, Stride2, Scan02, BitmapData2)

         DllCall("crypt32\CryptStringToBinary", "str",(A_PtrSize == 8) ? x64 : x86, "uint",0, "uint",0x1, "ptr",0, "uint*",s, "ptr",0, "ptr",0)
         p := DllCall("GlobalAlloc", "uint",0, "ptr",s, "ptr")
         if (A_PtrSize == 8)
            DllCall("VirtualProtect", "ptr",p, "ptr",s, "uint",0x40, "uint*",op)
         DllCall("crypt32\CryptStringToBinary", "str",(A_PtrSize == 8) ? x64 : x86, "uint",0, "uint",0x1, "ptr",p, "uint*",s, "ptr",0, "ptr",0)
         value := DllCall(p, "ptr",Scan01, "ptr",Scan02, "uint",width, "uint",height, "uint",4, "uint",radius, "float",opacity)
         DllCall("GlobalFree", "ptr", p)

         Gdip_UnlockBits(pBitmap, BitmapData1)
         Gdip_UnlockBits(clone, BitmapData2)
         Gdip_DisposeImage(clone)
         return value
      }

      inner[] {
         get {
            if (_class := this.__class)
               Loop, Parse, _class, .
                  inner := (A_Index=1) ? %A_LoopField% : inner[A_LoopField]
            return inner
         }
      }
   }

   class Area {
      static extends := "shared"
      init := this._init(true)
      _init(endofunctor := "") {
         extends := this.extends
         under := ((this.outer)[extends])
            ? ((___ := (this.outer)[extends]._init()) ? ___ : (this.outer)[extends])
            : ((___ := %extends%._init()) ? ___ : %extends%)
         if (endofunctor)
            this.base.base := under
         else
            this.base := under
         return this
      }
      outer[] {
         get {
            if ((_class := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop, Parse, _class, .
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return outer
         }
      }

      activateOnAdmin := true
      ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

      __New(title := "", terms*) {
         global pToken
         if !(this.outer.Startup())
            if !(pToken)
               if !(this.pToken := Gdip_Startup())
                  throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

         Gui, New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndhwnd
         Gui, Show, % (this.activateOnAdmin && !this.isDrawable()) ? "" : "NoActivate"
         this.hwnd := hwnd
         this.title := (title != "") ? title : RegExReplace(this.__class, "(.*\.)*(.*)$", "$2") "_" this.hwnd
         DllCall("SetWindowText", "ptr",this.hwnd, "str",this.title)
         this.__screen := new this.outer.memory(this.ScreenWidth, this.ScreenHeight)
         this.state := new this.outer.queue()
         this.Additional(terms*)
         return this
      }

      Destroy() {
         this.__screen := ""
         DllCall("DestroyWindow", "ptr",this.hwnd)
         return this
      }

      Additional(terms*) {
         this.color := (terms.1) ? terms.1 : "0x7FDDDDDD"
         this.cache := 0
      }

      Render(color := "", style := "", empty := "", update := true) {
         if (!this.hwnd)
            return (new this).Render(color, style, empty)

         this.state.new(A_ThisFunc)

         Gdip_GraphicsClear(this.__screen.G)

         this.DetectScreenResolutionChange()
         this.Draw(color, style, empty)
         if (update)
            UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)

         if (this.time) {
            self_destruct := ObjBindMethod(this, "Destroy")
            SetTimer, % self_destruct, % -1 * this.time
         }

         ; Shift the layers.
         this.state.layers.RemoveAt(1)
         this.state.layers.2 := []

         return this
      }

      Redraw(x, y, w, h) {
         ;this.DetectScreenResolutionChange()
         Gdip_SetSmoothingMode(this.__screen.G, 4) ;Adds one clickable pixel to the edge.
         pBrush := Gdip_BrushCreateSolid(this.color)

         if (this.cache = 0) {
            Gdip_GraphicsClear(this.__screen.G)
            Gdip_FillRectangle(this.__screen.G, pBrush, x, y, w, h)
         }
         if (this.cache = 1) {
            if (!this.state.identical)
               this.__cache := ""

            if (!this.__cache) {
               this.__cache := new this.outer.memory(w + 1, h + 1)
               Gdip_FillRectangle(this.__cache.G, pBrush, 0, 0, w, h)
            }

            Gdip_GraphicsClear(this.__screen.G)
            BitBlt(this.__screen.hdc, x, y, w + 1, h + 1, this.__cache.hdc, 0, 0)
         }
         if (this.cache = 2) {
            if (!this.state.identical)
               this.__cache := ""

            if (!this.__cache) {
               this.__cache := new this.outer.memory(w + 1, h + 1)
               Gdip_FillRectangle(this.__cache.G, pBrush, 0, 0, w, h)
            }

            Gdip_GraphicsClear(this.__screen.G)
            StretchBlt(this.__screen.hdc, x, y, w + 1, h + 1, this.__cache.hdc, 0, 0, this.__cache.width, this.__cache.height)
         }
         UpdateLayeredWindow(this.hwnd, this.__screen.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
         Gdip_DeleteBrush(pBrush)
      }

      Paint(x, y, w, h, pGraphics) {
         pBrush := Gdip_BrushCreateSolid(this.color)
         Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
         Gdip_DeleteBrush(pBrush)
      }

      Draw(color := "", style := "", empty := "", pGraphics := "") {

         ; Note that only the second layer is drawn on. The first layer is the reference layer.
         if (pGraphics == "") {
            if (!this.state.layers.2.MaxIndex())
               this.__buffer := new this.outer.memory(this.ScreenWidth, this.ScreenHeight)
            pGraphics := this.__buffer.G
         }


         ; Retrieve last style if omitted. Reduce all whitespace to one space character.
         style := !IsObject(style) ? RegExReplace(style, "\s+", " ") : style
         style := (style == "") ? this.state.layers.2[this.state.layers.2.MaxIndex()].2 : style
         this.state.layers.2.push([color, style, empty])



         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         if IsObject(style) {
            t  := (style.time != "")        ? style.time        : style.t
            a  := (style.anchor != "")      ? style.anchor      : style.a
            x  := (style.left != "")        ? style.left        : style.x
            y  := (style.top != "")         ? style.top         : style.y
            w  := (style.width != "")       ? style.width       : style.w
            h  := (style.height != "")      ? style.height      : style.h
            m  := (style.margin != "")      ? style.margin      : style.m
            s  := (style.size != "")        ? style.size        : style.s
            c  := (style.color != "")       ? style.color       : style.c
            q  := (style.quality != "")     ? style.quality     : (style.q) ? style.q : style.InterpolationMode
         } else {
            t  := ((___ := RegExReplace(style, q1    "(t(ime)?)"          q2, "${value}")) != style) ? ___ : ""
            a  := ((___ := RegExReplace(style, q1    "(a(nchor)?)"        q2, "${value}")) != style) ? ___ : ""
            x  := ((___ := RegExReplace(style, q1    "(x|left)"           q2, "${value}")) != style) ? ___ : ""
            y  := ((___ := RegExReplace(style, q1    "(y|top)"            q2, "${value}")) != style) ? ___ : ""
            w  := ((___ := RegExReplace(style, q1    "(w(idth)?)"         q2, "${value}")) != style) ? ___ : ""
            h  := ((___ := RegExReplace(style, q1    "(h(eight)?)"        q2, "${value}")) != style) ? ___ : ""
            m  := ((___ := RegExReplace(style, q1    "(m(argin)?)"        q2, "${value}")) != style) ? ___ : ""
            s  := ((___ := RegExReplace(style, q1    "(s(ize)?)"          q2, "${value}")) != style) ? ___ : ""
            c  := ((___ := RegExReplace(style, q1    "(c(olor)?)"         q2, "${value}")) != style) ? ___ : ""
            q  := ((___ := RegExReplace(style, q1    "(q(uality)?)"       q2, "${value}")) != style) ? ___ : ""
         }

         static times := "(?i)^\s*(\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
         t  := ( t ~= times) ? RegExReplace( t, "\s", "") : 0 ; Default time is zero.
         t  := ((___ := RegExReplace( t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) !=  t) ? ___ *        1 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) !=  t) ? ___ *     1000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) !=  t) ? ___ *    60000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)h(our)?s?$"               , "$1")) !=  t) ? ___ *  3600000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)d(ay)?s?$"                , "$1")) !=  t) ? ___ * 86400000 : t
         this.time := t

         static valid := "(?i)^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         this.vw := 0.01 * this.ScreenWidth    ; 1% of viewport width.
         this.vh := 0.01 * this.ScreenHeight   ; 1% of viewport height.
         this.vmin := (this.vw < this.vh) ? this.vw : this.vh ; 1vw or 1vh, whichever is smaller.

         ; Default = 0, LowQuality = 1, HighQuality = 2, Bilinear = 3
         ; Bicubic = 4, NearestNeighbor = 5, HighQualityBilinear = 6, HighQualityBicubic = 7
         q := (q >= 0 && q <= 7) ? q : 7       ; Default InterpolationMode is HighQualityBicubic.
         Gdip_SetInterpolationMode(pGraphics, q)

         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : width ; Default width is image width.
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * this.vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * this.vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * this.vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * width :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : height ; Default height is image height.
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * this.vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * this.vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * this.vmin :  h
         h  := ( h ~= "%$") ? RegExReplace( h, "%$", "") * 0.01 * height :  h

         ; If size is "auto" automatically downscale by a multiple of 2. Ex: 50%, 25%, 12.5%...
         if (s = "auto") {
            ; Determine what is smaller: declared width and height or screen width and height.
            ; Since the declared w and h are overwritten by the size, they now determine the bounds.
            ; Default bounds are the ScreenWidth and ScreenHeight, and can be decreased, never increased.
            visible_w := (w > this.ScreenWidth) ? this.ScreenWidth : w
            visible_h := (h > this.ScreenHeight) ? this.ScreenHeight : h
            auto_w := (width > visible_w) ? width // visible_w + 1 : 1
            auto_h := (height > visible_h) ? height // visible_h + 1 : 1
            s := (auto_w > auto_h) ? (1 / auto_w) : (1 / auto_h)
            w := width ; Since the width was overwritten, restore it to the default.
            h := height ; w and h determine the bounds of the size.
         }

         s  := ( s ~= valid_positive) ? RegExReplace( s, "\s", "") : 1 ; Default size is 1.00.
         s  := ( s ~= "i)(pt|px)$") ? SubStr( s, 1, -2) :  s
         s  := ( s ~= "i)vw$") ? RegExReplace( s, "i)vw$", "") * this.vw / width :  s
         s  := ( s ~= "i)vh$") ? RegExReplace( s, "i)vh$", "") * this.vh / height:  s
         s  := ( s ~= "i)vmin$") ? RegExReplace( s, "i)vmin$", "") * this.vmin / minimum :  s
         s  := ( s ~= "%$") ? RegExReplace( s, "%$", "") * 0.01 :  s

         ; Scale width and height.
         w := Floor(w * s)
         h := Floor(h * s)

         a  := RegExReplace( a, "\s", "")
         a  := (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
            : (a ~= "i)top" && a ~= "i)right") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
            : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 6 : (a ~= "i)bottom" && a ~= "i)left") ? 7
            : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8 : (a ~= "i)bottom" && a ~= "i)right") ? 9
            : (a ~= "i)top") ? 2 : (a ~= "i)left") ? 4 : (a ~= "i)right") ? 6 : (a ~= "i)bottom") ? 8
            : (a ~= "i)cent(er|re)") ? 5 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

         a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
         a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

         ; Convert English words to numbers. Don't mess with these values any further.
         x  := ( x ~= "i)left") ? 0 : (x ~= "i)cent(er|re)") ? 0.5*this.ScreenWidth : (x ~= "i)right") ? this.ScreenWidth : x
         y  := ( y ~= "i)top") ? 0 : (y ~= "i)cent(er|re)") ? 0.5*this.ScreenHeight : (y ~= "i)bottom") ? this.ScreenHeight : y

         ; Validate x and y, convert to pixels.
         x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : 0 ; Default x is 0.
         x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
         x  := ( x ~= "i)(%|vw)$") ? RegExReplace( x, "i)(%|vw)$", "") * this.vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * this.vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * this.vmin :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : 0 ; Default y is 0.
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * this.vw :  y
         y  := ( y ~= "i)(%|vh)$") ? RegExReplace( y, "i)(%|vh)$", "") * this.vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * this.vmin :  y

         ; Modify x and y values with the anchor, so that the image has a new point of origin.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Prevent half-pixel rendering and keep image sharp.
         x := Floor(x)
         y := Floor(y)

         m := this.margin_and_padding(m)

         ; Calculate border using margin.
         _x  := x - (m.4)
         _y  := y - (m.1)
         _w  := w + (m.2 + m.4)
         _h  := h + (m.1 + m.3)

         ; Save size.
         this.x := _x
         this.y := _y
         this.w := _w
         this.h := _h

         if (image != "") {
            ; Draw border.
            c := this.color(c, 0xFF000000) ; Default color is black.
            pBrush := Gdip_BrushCreateSolid(c)
            Gdip_FillRectangle(pGraphics, pBrush, _x, _y, _w, _h)
            Gdip_DeleteBrush(pBrush)
            ; Draw image.
            Gdip_DrawImage(pGraphics, pBitmap, x, y, w, h, 0, 0, width, height)
         }

         ; POINTF
         Gdip_SetSmoothingMode(pGraphics, 4)  ; None = 3, AntiAlias = 4
         pPen := Gdip_CreatePen(0xFFFF0000, 1)

         for i, polygon in polygons {
            DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
            VarSetCapacity(pointf, 8*polygons[i].polygon.maxIndex(), 0)
            for j, point in polygons[i].polygon {
               NumPut(point.x*s + x, pointf, 8*(A_Index-1) + 0, "float")
               NumPut(point.y*s + y, pointf, 8*(A_Index-1) + 4, "float")
            }
            DllCall("gdiplus\GdipAddPathPolygon", "ptr",pPath, "ptr",&pointf, "uint",polygons[i].polygon.maxIndex())
            DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath) ; DRAWING!
         }

         Gdip_DeletePen(pPen)

         if (type != "pBitmap")
            Gdip_DisposeImage(pBitmap)

         return (pGraphics == "") ? this : ""
      }

      Origin() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         if (new_state = true || x_mouse != this.x_last || y_mouse != this.y_last) {
            this.x_last := x_mouse, this.y_last := y_mouse

            x := x_mouse
            y := y_mouse
            w := 1
            h := 1
            ;stabilize x/y corrdinates in window spy.

            this.state.queue(x, y, w, h, xx, yy, mx, my)
            this.Redraw(x, y, w, h)
         }
      }

      Drag() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         if (new_state = true || x_mouse != this.x_last || y_mouse != this.y_last) {
            this.x_last := x_mouse, this.y_last := y_mouse

            x_origin := (this.state.mx.1) ? this.state.x.1 : this.state.xx.1
            y_origin := (this.state.my.1) ? this.state.y.1 : this.state.yy.1

            mx := (x_mouse > x_origin) ? true : false
            my := (y_mouse > y_origin) ? true : false

            x := (mx) ? x_origin : x_mouse
            y := (my) ? y_origin : y_mouse
            xx := (mx) ? x_mouse : x_origin
            yy := (my) ? y_mouse : y_origin
            ;a := (xr && yr) ? "top left" : (xr && !yr) ? "bottom left" : (!xr && yr) ? "top right" : "bottom right"
            ;q := (xr && yr) ? "bottom right" : (xr && !yr) ? "top right" : (!xr && yr) ? "bottom left" : "top left"

            this.state.queue(x, y, w, h, xx, yy, mx, my)
            this.Redraw(x, y, w, h)
         }
      }

      Move() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         if (new_state = true || x_mouse != this.x_last || y_mouse != this.y_last) {
            this.x_last := x_mouse, this.y_last := y_mouse

            dx := x_mouse - this.state.x_mouse
            dy := y_mouse - this.state.y_mouse
            x := this.state.x.1 + dx
            y := this.state.y.1 + dy

            this.state.queue(x, y, w, h, xx, yy, mx, my)
            this.Redraw(x, y, w, h)
         }
      }

      Hover() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         this.state.queue()
      }

      Before() {
      }

      Recover() {
         Gdip_SetSmoothingMode(this.G, 4)
      }

      ChangeColor(color) {
         this.color := color
         Gdip_DeleteBrush(this.pBrush)
         this.pBrush := Gdip_BrushCreateSolid(this.color)
         this.Redraw(this.state.x.2, this.state.y.2, this.state.w.2, this.state.h.2)
      }

      ResizeCorners() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         if (new_state = true || x_mouse != this.x_last || y_mouse != this.y_last) {
            this.x_last := x_mouse, this.y_last := y_mouse

            xr := this.state.x_mouse - this.state.x.1 - (this.state.w.1 / 2)
            yr := this.state.y.1 - this.state.y_mouse + (this.state.h.1 / 2) ; Keep Change Change
            dx := x_mouse - this.state.x_mouse
            dy := y_mouse - this.state.y_mouse

            if (xr < -1 && yr > 1) {
               r := "top left"
               x := this.state.x.1 + dx
               y := this.state.y.1 + dy
               w := this.state.w.1 - dx
               h := this.state.h.1 - dy
            }
            if (xr >= -1 && yr > 1) {
               r := "top right"
               x := this.state.x.1
               y := this.state.y.1 + dy
               w := this.state.w.1 + dx
               h := this.state.h.1 - dy
            }
            if (xr < -1 && yr <= 1) {
               r := "bottom left"
               x := this.state.x.1 + dx
               y := this.state.y.1
               w := this.state.w.1 - dx
               h := this.state.h.1 + dy
            }
            if (xr >= -1 && yr <= 1) {
               r := "bottom right"
               x := this.state.x.1
               y := this.state.y.1
               w := this.state.w.1 + dx
               h := this.state.h.1 + dy
            }

            this.state.queue(x, y, w, h, xx, yy, mx, my)
            this.Redraw(x, y, w, h)
         }
      }

      ; This works by finding the line equations of the diagonals of the rectangle.
      ; To identify the quadrant the cursor is located in, the while loop compares it's y value
      ; with the function line values f(x) = m * xr and y = -m * xr.
      ; So if yr is below both theoretical y values, then we know it's in the bottom quadrant.
      ; Be careful with this code, it converts the y plane inversely to match the Decartes tradition.

      ; Safety features include checking for past values to prevent flickering
      ; Sleep statements are required in every while loop.

      ResizeEdges() {
         this.MouseGetPos(x_mouse, y_mouse)
         new_state := this.state.new(A_ThisFunc, x_mouse, y_mouse)
         if (new_state = true || x_mouse != this.x_last || y_mouse != this.y_last) {
            this.x_last := x_mouse, this.y_last := y_mouse

            m := -(this.state.h.1 / this.state.w.1)                              ; slope (dy/dx)
            xr := this.state.x_mouse - this.state.x.1 - (this.state.w.1 / 2)           ; draw a line across the center
            yr := this.state.y.1 - this.state.y_mouse + (this.state.h.1 / 2)           ; draw a vertical line halfing it
            dx := x_mouse - this.state.x_mouse
            dy := y_mouse - this.state.y_mouse

            if (m * xr >= yr && yr > -m * xr)
               r := "left",   x := this.state.x.1 + dx, w := this.state.w.1 - dx
            if (m * xr < yr && yr > -m * xr)
               r := "top",    y := this.state.y.1 + dy, h := this.state.h.1 - dy
            if (m * xr < yr && yr <= -m * xr)
               r := "right",  w := this.state.w.1 + dx
            if (m * xr >= yr && yr <= -m * xr)
               r := "bottom", h := this.state.h.1 + dy

            this.state.queue(x, y, w, h, xx, yy, mx, my)
            this.Redraw(x, y, w, h)
         }
      }

      isMouseInside() {
         this.MouseGetPos(x_mouse, y_mouse)
         return (x_mouse >= this.state.x.2 && x_mouse <= this.state.xx.2
            && y_mouse >= this.state.y.2 && y_mouse <= this.state.yy.2)
      }

      isMouseOutside() {
         return !this.isMouseInside()
      }

      isMouseOnCorner() {
         this.MouseGetPos(x_mouse, y_mouse)
         return (x_mouse == this.state.x.2 || x_mouse == this.state.xx.2)
            && (y_mouse == this.state.y.2 || y_mouse == this.state.yy.2)
      }

      isMouseOnEdge() {
         this.MouseGetPos(x_mouse, y_mouse)
         return ((x_mouse >= this.state.x.2 && x_mouse <= this.state.xx.2)
            && (y_mouse == this.state.y.2 || y_mouse == this.state.yy.2))
            OR ((y_mouse >= this.state.y.2 && y_mouse <= this.state.yy.2)
            && (x_mouse == this.state.x.2 || x_mouse == this.state.xx.2))
      }

      isMouseStopped() {
         this.MouseGetPos(x_mouse, y_mouse)
         return x_mouse == this.x_last && y_mouse == this.y_last
      }

      ScreenshotCoordinates() {
         return (this.state.w.2 > 0 && this.state.h.2 > 0)
            ? (this.state.x.2 "|" this.state.y.2 "|" this.state.w.2 "|" this.state.h.2) : ""
      }

      x1() {
         return this.state.x.2
      }

      y1() {
         return this.state.y.2
      }

      x2() {
         return this.state.xx.2
      }

      y2() {
         return this.state.yy.2
      }

      width() {
         return this.state.w.2
      }

      height() {
         return this.state.h.2
      }
   } ; End of Area class.

   class Picture {
      static extends := "shared"
      init := this._init(true)
      _init(endofunctor := "") {
         extends := this.extends
         under := ((this.outer)[extends])
            ? ((___ := (this.outer)[extends]._init()) ? ___ : (this.outer)[extends])
            : ((___ := %extends%._init()) ? ___ : %extends%)
         if (endofunctor)
            this.base.base := under
         else
            this.base := under
         return this
      }
      outer[] {
         get {
            if ((_class := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop, Parse, _class, .
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return outer
         }
      }

      ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

      ; Types of input accepted
      ; Objects: Rectangle Array (Screenshot)
      ; Strings: File, URL, Window Title (ahk_class...), base64
      ; Numbers: hwnd, GDI Bitmap, GDI HBitmap
      ; Rawfile: Binary

      ; Vis2.preprocess(image, crop) - This is a template function.
      ; Each service should implement their own preprocess function based off
      ; this template. Accepts all 8 input types, returns a cropped pBitmap.
      ; If a service implements this, it should return file/base64/binary.
      ; The service should also implement a bypass if there is no crop array,
      ; and the input and output types are the same.
      Render(image := "", style := "", polygons := "") {
         if (!this.hwnd)
            return (new this).Render(image, style, polygons)

         this.DetectScreenResolutionChange()
         Gdip_GraphicsClear(this.G)
         this.Draw(image, style, polygons)
         UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
         if (this.time) {
            self_destruct := ObjBindMethod(this, "Destroy")
            SetTimer, % self_destruct, % -1 * this.time
         }
         return this
      }

      Draw(image := "", style := "", polygons := "", pGraphics := "") {
         if (pGraphics == "")
            pGraphics := this.G

         if (image != "") {
            if !(type := this.DontVerifyImageType(image))
               type := this.ImageType(image)
            pBitmap := this.toBitmap(type, image)
         }

         style := !IsObject(style) ? RegExReplace(style, "\s+", " ") : style

         if (style == "")
            style := this.style
         else
            this.style := style

         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         if IsObject(style) {
            t  := (style.time != "")        ? style.time        : style.t
            a  := (style.anchor != "")      ? style.anchor      : style.a
            x  := (style.left != "")        ? style.left        : style.x
            y  := (style.top != "")         ? style.top         : style.y
            w  := (style.width != "")       ? style.width       : style.w
            h  := (style.height != "")      ? style.height      : style.h
            m  := (style.margin != "")      ? style.margin      : style.m
            s  := (style.size != "")        ? style.size        : style.s
            c  := (style.color != "")       ? style.color       : style.c
            q  := (style.quality != "")     ? style.quality     : (style.q) ? style.q : style.InterpolationMode
         } else {
            t  := ((___ := RegExReplace(style, q1    "(t(ime)?)"          q2, "${value}")) != style) ? ___ : ""
            a  := ((___ := RegExReplace(style, q1    "(a(nchor)?)"        q2, "${value}")) != style) ? ___ : ""
            x  := ((___ := RegExReplace(style, q1    "(x|left)"           q2, "${value}")) != style) ? ___ : ""
            y  := ((___ := RegExReplace(style, q1    "(y|top)"            q2, "${value}")) != style) ? ___ : ""
            w  := ((___ := RegExReplace(style, q1    "(w(idth)?)"         q2, "${value}")) != style) ? ___ : ""
            h  := ((___ := RegExReplace(style, q1    "(h(eight)?)"        q2, "${value}")) != style) ? ___ : ""
            m  := ((___ := RegExReplace(style, q1    "(m(argin)?)"        q2, "${value}")) != style) ? ___ : ""
            s  := ((___ := RegExReplace(style, q1    "(s(ize)?)"          q2, "${value}")) != style) ? ___ : ""
            c  := ((___ := RegExReplace(style, q1    "(c(olor)?)"         q2, "${value}")) != style) ? ___ : ""
            q  := ((___ := RegExReplace(style, q1    "(q(uality)?)"       q2, "${value}")) != style) ? ___ : ""
         }

         static times := "(?i)^\s*(\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
         t  := ( t ~= times) ? RegExReplace( t, "\s", "") : 0 ; Default time is zero.
         t  := ((___ := RegExReplace( t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) !=  t) ? ___ *        1 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) !=  t) ? ___ *     1000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) !=  t) ? ___ *    60000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)h(our)?s?$"               , "$1")) !=  t) ? ___ *  3600000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)d(ay)?s?$"                , "$1")) !=  t) ? ___ * 86400000 : t
         this.time := t

         static valid := "(?i)^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         this.vw := 0.01 * this.ScreenWidth    ; 1% of viewport width.
         this.vh := 0.01 * this.ScreenHeight   ; 1% of viewport height.
         this.vmin := (this.vw < this.vh) ? this.vw : this.vh ; 1vw or 1vh, whichever is smaller.

         ; Default = 0, LowQuality = 1, HighQuality = 2, Bilinear = 3
         ; Bicubic = 4, NearestNeighbor = 5, HighQualityBilinear = 6, HighQualityBicubic = 7
         q := (q >= 0 && q <= 7) ? q : 7       ; Default InterpolationMode is HighQualityBicubic.
         Gdip_SetInterpolationMode(pGraphics, q)

         ; Get original image width and height.
         width := Gdip_GetImageWidth(pBitmap)
         height := Gdip_GetImageHeight(pBitmap)
         minimum := (width < height) ? width : height

         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : width ; Default width is image width.
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * this.vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * this.vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * this.vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * width :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : height ; Default height is image height.
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * this.vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * this.vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * this.vmin :  h
         h  := ( h ~= "%$") ? RegExReplace( h, "%$", "") * 0.01 * height :  h

         ; If size is "auto" automatically downscale by a multiple of 2. Ex: 50%, 25%, 12.5%...
         if (s = "auto") {
            ; Determine what is smaller: declared width and height or screen width and height.
            ; Since the declared w and h are overwritten by the size, they now determine the bounds.
            ; Default bounds are the ScreenWidth and ScreenHeight, and can be decreased, never increased.
            visible_w := (w > this.ScreenWidth) ? this.ScreenWidth : w
            visible_h := (h > this.ScreenHeight) ? this.ScreenHeight : h
            auto_w := (width > visible_w) ? width // visible_w + 1 : 1
            auto_h := (height > visible_h) ? height // visible_h + 1 : 1
            s := (auto_w > auto_h) ? (1 / auto_w) : (1 / auto_h)
            w := width ; Since the width was overwritten, restore it to the default.
            h := height ; w and h determine the bounds of the size.
         }

         s  := ( s ~= valid_positive) ? RegExReplace( s, "\s", "") : 1 ; Default size is 1.00.
         s  := ( s ~= "i)(pt|px)$") ? SubStr( s, 1, -2) :  s
         s  := ( s ~= "i)vw$") ? RegExReplace( s, "i)vw$", "") * this.vw / width :  s
         s  := ( s ~= "i)vh$") ? RegExReplace( s, "i)vh$", "") * this.vh / height:  s
         s  := ( s ~= "i)vmin$") ? RegExReplace( s, "i)vmin$", "") * this.vmin / minimum :  s
         s  := ( s ~= "%$") ? RegExReplace( s, "%$", "") * 0.01 :  s

         ; Scale width and height.
         w := Floor(w * s)
         h := Floor(h * s)

         a  := RegExReplace( a, "\s", "")
         a  := (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
            : (a ~= "i)top" && a ~= "i)right") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
            : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 6 : (a ~= "i)bottom" && a ~= "i)left") ? 7
            : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8 : (a ~= "i)bottom" && a ~= "i)right") ? 9
            : (a ~= "i)top") ? 2 : (a ~= "i)left") ? 4 : (a ~= "i)right") ? 6 : (a ~= "i)bottom") ? 8
            : (a ~= "i)cent(er|re)") ? 5 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

         a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
         a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

         ; Convert English words to numbers. Don't mess with these values any further.
         x  := ( x ~= "i)left") ? 0 : (x ~= "i)cent(er|re)") ? 0.5*this.ScreenWidth : (x ~= "i)right") ? this.ScreenWidth : x
         y  := ( y ~= "i)top") ? 0 : (y ~= "i)cent(er|re)") ? 0.5*this.ScreenHeight : (y ~= "i)bottom") ? this.ScreenHeight : y

         ; Validate x and y, convert to pixels.
         x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : 0 ; Default x is 0.
         x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
         x  := ( x ~= "i)(%|vw)$") ? RegExReplace( x, "i)(%|vw)$", "") * this.vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * this.vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * this.vmin :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : 0 ; Default y is 0.
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * this.vw :  y
         y  := ( y ~= "i)(%|vh)$") ? RegExReplace( y, "i)(%|vh)$", "") * this.vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * this.vmin :  y

         ; Modify x and y values with the anchor, so that the image has a new point of origin.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Prevent half-pixel rendering and keep image sharp.
         x := Floor(x)
         y := Floor(y)

         m := this.margin_and_padding(m)

         ; Calculate border using margin.
         _x  := x - (m.4)
         _y  := y - (m.1)
         _w  := w + (m.2 + m.4)
         _h  := h + (m.1 + m.3)

         ; Save size.
         this.x := _x
         this.y := _y
         this.w := _w
         this.h := _h

         if (image != "") {
            ; Draw border.
            c := this.color(c, 0xFF000000) ; Default color is black.
            pBrush := Gdip_BrushCreateSolid(c)
            Gdip_FillRectangle(pGraphics, pBrush, _x, _y, _w, _h)
            Gdip_DeleteBrush(pBrush)
            ; Draw image.
            Gdip_DrawImage(pGraphics, pBitmap, x, y, w, h, 0, 0, width, height)
         }

         ; POINTF
         Gdip_SetSmoothingMode(pGraphics, 4)  ; None = 3, AntiAlias = 4
         pPen := Gdip_CreatePen(0xFFFF0000, 1)

         for i, polygon in polygons {
            DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
            VarSetCapacity(pointf, 8*polygons[i].polygon.maxIndex(), 0)
            for j, point in polygons[i].polygon {
               NumPut(point.x*s + x, pointf, 8*(A_Index-1) + 0, "float")
               NumPut(point.y*s + y, pointf, 8*(A_Index-1) + 4, "float")
            }
            DllCall("gdiplus\GdipAddPathPolygon", "ptr",pPath, "ptr",&pointf, "uint",polygons[i].polygon.maxIndex())
            DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath) ; DRAWING!
         }

         Gdip_DeletePen(pPen)

         if (type != "pBitmap")
            Gdip_DisposeImage(pBitmap)

         return (pGraphics == "") ? this : ""
      }

      ; Preprocess() - Modifies an input image and returns it in a new form.
      ; Example: Preprocess("base64", "https://goo.gl/BWUygC")
      ;          The image is downloaded from the URL and is converted to base64.
      Preprocess(cotype, image, crop := "", scale := "", terms*) {
         if (!this.hwnd) {
            _picture := new this("Picture.Preprocess")
            _picture.title := _picture.title "_" _picture.hwnd
            DllCall("SetWindowText", "ptr",_picture.hwnd, "str",_picture.title)
            coimage := _picture.Preprocess(cotype, image, crop, scale, terms*)
            _picture.FreeMemory()
            _picture := ""
            return coimage
         }

         ; Determine the representation (type) of the input image.
         if !(type := this.DontVerifyImageType(image))
            type := this.ImageType(image)
         ; If the type and cotype match, do nothing.
         if (type = cotype && !this.isRectangle(crop) && !(scale ~= "^\d+(\.\d+)?$" && scale != 1))
            return image
         ; Convert the image to a pBitmap (byte array).
         pBitmap := this.toBitmap(type, image)
         ; Crop the image, disposing if type is not pBitmap.
         if this.isRectangle(crop){
            pBitmap2 := this.Gdip_CropBitmap(pBitmap, crop)
            if !(type = "pBitmap")
               Gdip_DisposeImage(pBitmap)
            pBitmap := pBitmap2
         }
         ; Scale the image, disposing if type is not pBitmap.
         if (scale ~= "^\d+(\.\d+)?$" && scale != 1) {
            pBitmap2 := this.Gdip_ScaleBitmap(pBitmap, scale)
            if !(type = "pBitmap" && !this.isRectangle(crop))
               Gdip_DisposeImage(pBitmap)
            pBitmap := pBitmap2
         }
         ; Convert from the pBitmap intermediate to the desired representation.
         coimage := this.toCotype(cotype, pBitmap, terms*)
         ; Delete the pBitmap intermediate, unless the input/output is pBitmap.
         if !(cotype = "pBitmap"
            || (type = "pBitmap" && !this.isRectangle(crop) && !(scale ~= "^\d+(\.\d+)?$" && scale != 1)))
               Gdip_DisposeImage(pBitmap)
         return coimage
      }

      DontVerifyImageType(ByRef image) {
         ; Check for image type declaration.
         if !IsObject(image)
            return

         if (image.screen != "")
            return "screen", image := image.screen

         if (image.screenshot != "")
            return "screenshot", image := image.screenshot

         if (image.file != "")
            return "file", image := image.file

         if (image.url != "")
            return "url", image := image.url

         if (image.window != "")
            return "window", image := image.window

         if (image.hwnd != "")
            return "hwnd", image := image.hwnd

         if (image.pBitmap != "")
            return "pBitmap", image := image.pBitmap

         if (image.hBitmap != "")
            return "hBitmap", image := image.hBitmap

         if (image.base64 != "")
            return "base64", image := image.base64

         return
      }

      ImageType(image) {
         ; Check if image is empty string.
         if (image == "")
            throw Exception("Image data is empty string.")
         ; Check if image is an array of 4 numbers.
         if this.isRectangle(image)
            return "screenshot"
         ; Check if image points to a valid file.
         if FileExist(image)
            return "file"
         ; Check if image points to a valid URL.
         if this.isURL(image)
            return "url"
         ; Check if image matches a window title. Also matches "A".
         if WinExist(image)
            return "window"
         ; Check if image is a valid handle to a window.
         if DllCall("IsWindow", "ptr", image)
            return "hwnd"
         ; Check if image is a valid GDI Bitmap.
         if DeleteObject(Gdip_CreateHBITMAPFromBitmap(image))
            return "pBitmap"
         ; Check if image is a valid handle to a GDI Bitmap.
         if (DllCall("GetObjectType", "ptr", image) == 7)
            return "hBitmap"
         ; Check if image is a base64 string.
         if (image ~= "^\s*(?:data:image\/[a-z]+;base64,)?(?:[A-Za-z0-9+\/]{4})*+(?:[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)?\s*$")
            return "base64"

         throw Exception("Image type could not be identified.")
      }

      toBitmap(type, image) {
         if (type = "screen") {
            if (image > 0) {
               M := GetMonitorInfo(image)
               x := M.Left
               y := M.Top
               w := M.Right - M.Left
               h := M.Bottom - M.Top
            } else {
               x := DllCall("GetSystemMetrics", "int",76)
               y := DllCall("GetSystemMetrics", "int",77)
               w := DllCall("GetSystemMetrics", "int",78)
               h := DllCall("GetSystemMetrics", "int",79)
            }
            chdc := CreateCompatibleDC()
            hbm := CreateDIBSection(w, h, chdc)
            obm := SelectObject(chdc, hbm)
            hhdc := GetDC()
            BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster := "")
            ReleaseDC(hhdc)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
            return pBitmap
         }

         if (type = "screenshot") {
            chdc := CreateCompatibleDC()
            hbm := CreateDIBSection(image.3, image.4, chdc)
            obm := SelectObject(chdc, hbm)
            hhdc := GetDC()
            BitBlt(chdc, 0, 0, image.3, image.3, hhdc, image.1, image.2, Raster := "")
            ReleaseDC(hhdc)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
            return pBitmap
         }

         if (type = "file")
            return Gdip_CreateBitmapFromFile(image)

         if (type = "url") {
            req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            req.Open("GET", image)
            req.Send()
            pStream := ComObjQuery(req.ResponseStream, "{0000000C-0000-0000-C000-000000000046}")
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
            ObjRelease(pStream)
            return pBitmap
         }

         if (type = "window" || type = "hwnd") {
            image := (type = "window") ? WinExist(image) : image
            if DllCall("IsIconic", "ptr",image)
               DllCall("ShowWindow", "ptr",image, "int",4) ; Restore if minimized!
            VarSetCapacity(rc, 16)
            DllCall("GetClientRect", "ptr",image, "ptr",&rc)
            hbm := CreateDIBSection(NumGet(rc, 8, "int"), NumGet(rc, 12, "int"))
            VarSetCapacity(rc, 0)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            DllCall("PrintWindow", "ptr",image, "ptr",hdc, "uint",0x3)
            pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
            SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
            return pBitmap
         }

         if (type = "pBitmap")
            return image

         if (type = "hBitmap")
            return Gdip_CreateBitmapFromHBITMAP(image)

         if (type = "base64") {
            image := Trim(image)
            image := RegExReplace(image, "^data:image\/[a-z]+;base64,", "")
            DllCall("crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), "ptr",&image, "uint",0, "uint",1, "ptr",0, "uint*",nSize, "ptr",0, "ptr",0)
            VarSetCapacity(bin, nSize, 0)
            DllCall("crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), "ptr",&image, "uint",0, "uint",1, "ptr",&bin, "uint*",nSize, "ptr",0, "ptr",0)
            hData := DllCall("GlobalAlloc", "uint",0x2, "ptr",nSize)
            pData := DllCall("GlobalLock", "ptr",hData)
            DllCall("RtlMoveMemory", "ptr",pData, "ptr",&bin, "ptr",nSize)
            DllCall("ole32\CreateStreamOnHGlobal", "ptr",hData, "int",0, "uptr*",pStream)
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "uptr*",pBitmap)
            pBitmap2 := Gdip_CloneBitmapArea(pBitmap, 0, 0, Gdip_GetImageWidth(pBitmap), Gdip_GetImageHeight(pBitmap))
            Gdip_DisposeImage(pBitmap)
            ObjRelease(pStream)
            DllCall("GlobalUnlock", "ptr",hData)
            DllCall("GlobalFree", "ptr",hData) ; Will delete the original bitmap if not cloned.
            return pBitmap2
         }
      }

      toCotype(cotype, pBitmap, terms*) {
         if (cotype = "screenshot") {
            style := terms.1
            _picture := this.Render({"pBitmap":pBitmap}, style)
            return [_picture.x1(), _picture.y1(), _picture.width(), _picture.height()]
         }

         if (cotype = "file") {
            filename := (terms.1) ? terms.1 : this.title ".png"
            compression := terms.2
            Gdip_SaveBitmapToFile(pBitmap, filename, compression)
            return filename
         }

         if (cotype = "url") {
            ; make a url
         }

         if (cotype = "window")
            return "ahk_id " . this.Render({"pBitmap":pBitmap}).AlwaysOnTop().ToolWindow().Caption().hwnd

         if (cotype = "hwnd")
            return this.Render({"pBitmap":pBitmap}).hwnd

         if (cotype = "pBitmap")
            return pBitmap

         if (cotype = "hBitmap") {
            alpha := terms.1
            return Gdip_CreateHBITMAPFromBitmap(pBitmap, alpha)
         }

         if (cotype = "base64") {
            extension := (terms.1) ? terms.1 : "png"
            compression := terms.2
            return this.Gdip_EncodeBitmapToBase64(pBitmap, extension, compression)
         }
      }

      Gdip_CropBitmap(pBitmap, crop, width:="", height:=""){
         width := (width) ? width : Gdip_GetImageWidth(pBitmap)
         height := (height) ? height : Gdip_GetImageHeight(pBitmap)
         ; Are the numbers percentages?
         crop.1 := (crop.1 ~= "%$") ? SubStr(crop.1, 1, -1) * 0.01 * width : crop.1
         crop.2 := (crop.2 ~= "%$") ? SubStr(crop.2, 1, -1) * 0.01 * height : crop.2
         crop.3 := (crop.3 ~= "%$") ? SubStr(crop.3, 1, -1) * 0.01 * width : crop.3
         crop.4 := (crop.4 ~= "%$") ? SubStr(crop.4, 1, -1) * 0.01 * height : crop.4
         ; If numbers are negative, subtract the values from the edge.
         crop.1 := (crop.1 < 0) ? Abs(crop.1) : crop.1
         crop.2 := (crop.2 < 0) ? Abs(crop.2) : crop.2
         crop.3 := (crop.3 < 0) ? width + crop.3 : crop.3
         crop.4 := (crop.4 < 0) ? height + crop.4 : crop.4
         ; Round to the nearest integer.
         crop.1 := Round(crop.1)
         crop.2 := Round(crop.2)
         crop.3 := Round(crop.3)
         crop.4 := Round(crop.4)
         ; Ensure that coordinates can never exceed the expected Bitmap area.
         safe_x := (crop.1 > width) ? 0 : crop.1
         safe_y := (crop.2 > height) ? 0 : crop.2
         safe_w := (crop.1 + crop.3 > width) ? width - safe_x : crop.3
         safe_h := (crop.2 + crop.4 > height) ? height - safe_y : crop.4
         return Gdip_CloneBitmapArea(pBitmap, safe_x, safe_y, safe_w, safe_h)
      }

      Gdip_EncodeBitmapToBase64(pBitmap, ext, Quality=75) {
         ; Thanks to noname.
         if Ext not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
            return -1
         Extension := "." Ext

         DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
         VarSetCapacity(ci, nSize)
         DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
         if !(nCount && nSize)
            return -2

         Loop, %nCount%
         {
            sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
            if !InStr(sString, "*" Extension)
               continue

            pCodec := &ci+idx
            break
         }

         if !pCodec
            return -3

         if (Quality != 75)
         {
            Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
            if Extension in .JPG,.JPEG,.JPE,.JFIF
            {
               DllCall("gdiplus\GdipGetEncoderParameterListSize", Ptr, pBitmap, Ptr, pCodec, "uint*", nSize)
               VarSetCapacity(EncoderParameters, nSize, 0)
               DllCall("gdiplus\GdipGetEncoderParameterList", Ptr, pBitmap, Ptr, pCodec, "uint", nSize, Ptr, &EncoderParameters)
               Loop, % NumGet(EncoderParameters, "UInt")
               {
                  elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                  if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
                  {
                     p := elem+&EncoderParameters-pad-4
                     NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "UInt")), "UInt")
                     break
                  }
               }
            }
         }

         DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
         DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)

         DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
         pData := DllCall("GlobalLock", "ptr",hData, "uptr")
         nSize := DllCall("GlobalSize", "uint",pData)

         VarSetCapacity(Bin, nSize, 0)
         DllCall("RtlMoveMemory", "ptr",&Bin, "ptr",pData, "uint",nSize)
         DllCall("GlobalUnlock", "ptr",hData)
         DllCall(NumGet(NumGet(pStream + 0, 0, "uptr") + (A_PtrSize * 2), 0, "uptr"), "ptr",pStream)
         DllCall("GlobalFree", "ptr",hData)

         ; Using CryptBinaryToStringA saves about 2MB in memory.
         DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&Bin, "uint",nSize, "uint",0x40000001, "ptr",0, "uint*",base64Length)
         VarSetCapacity(base64, base64Length, 0)
         DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&Bin, "uint",nSize, "uint",0x40000001, "ptr",&base64, "uint*",base64Length)
         VarSetCapacity(Bin, 0)

         return StrGet(&base64, base64Length, "CP0")
      }

      Gdip_ScaleBitmap(pBitmap, scale, width:="", height:="") {
         width := (width) ? width : Gdip_GetImageWidth(pBitmap)
         height := (height) ? height : Gdip_GetImageHeight(pBitmap)

         safe_w := Ceil(width * scale)
         safe_h := Ceil(height * scale)

         pBitmap2 := Gdip_CreateBitmap(safe_w, safe_h)
         G2 := Gdip_GraphicsFromImage(pBitmap2)
         Gdip_SetSmoothingMode(G2, 4)
         Gdip_SetInterpolationMode(G2, 7)
         Gdip_DrawImage(G2, pBitmap, 0, 0, safe_w, safe_h)
         Gdip_DeleteGraphics(G2)
         return pBitmap2
      }

      Equality(images*) {
         if (!this.hwnd) {
            _picture := new this("Picture.Equality")
            _picture.title := _picture.title "_" _picture.hwnd
            DllCall("SetWindowText", "ptr",_picture.hwnd, "str",_picture.title)
            answer := _picture.Equality(images*)
            _picture.FreeMemory()
            _picture := ""
            return answer
         }

         ; Image equality can only be performed on one or more images.
         if (images.MaxIndex() == 1)
            return true

         ; Convert the images to pBitmaps (byte arrays).
         for i, image in images {
            if !(type := this.DontVerifyImageType(image))
               type := this.ImageType(image)

            if (A_Index == 1)
               pBitmap1 := this.toBitmap(type, image)
            else {
               pBitmap2 := this.toBitmap(type, image)
               result := this.isBitmapEqual(pBitmap1, pBitmap2)
               Gdip_DisposeImage(pBitmap2)
               if (result)
                  continue
               else
                  return false
            }
         }
         Gdip_DisposeImage(pBitmap1)
         return true
      }

      isBitmapEqual(pBitmap1, pBitmap2) {
         ; Make sure both Bitmaps are valid pointers.
         if !(pBitmap1 && pBitmap2)
            return false

         ; Check if pointers are identical.
         if (pBitmap1 == pBitmap2)
            return true

         pBitmap1_width  := Gdip_GetImageWidth(pBitmap1)
         pBitmap1_height := Gdip_GetImageHeight(pBitmap1)
         pBitmap2_width  := Gdip_GetImageWidth(pBitmap2)
         pBitmap2_height := Gdip_GetImageHeight(pBitmap2)

         ; Match image dimensions.
         if (pBitmap1_width != pBitmap2_width) OR (pBitmap1_height != pBitmap2_height)
            return false

         ; Find smaller width and height to match bytes.
         width := (pBitmap1_width < pBitmap2_width) ? pBitmap1_width : pBitmap2_width
         height := (pBitmap1_height < pBitmap2_height) ? pBitmap1_height : pBitmap2_height
         E1 := Gdip_LockBits(pBitmap1, 0, 0, width, height, Stride1, Scan01, BitmapData1)
         E2 := Gdip_LockBits(pBitmap2, 0, 0, width, height, Stride2, Scan02, BitmapData2)

         ; RtlCompareMemory preforms an unsafe comparison stopping at the first different byte.
         size := width * height * 4  ; ARGB = 4 bytes
         byte := DllCall("RtlCompareMemory", "ptr", Scan01+0, "ptr", Scan02+0, "uint", size)

         Gdip_UnlockBits(pBitmap1, BitmapData1)
         Gdip_UnlockBits(pBitmap2, BitmapData2)
         return (byte == size) ? true : false
      }

      isRectangle(array){
         if (array.MaxIndex() != 4)
            return false
         for index, value in array
            if !(value ~= "^\-?\d+(?:\.\d*)?%?$")
               return false
         return true
      }

      isURL(url){
         regex .= "((https?|ftp)\:\/\/)" ; SCHEME
         regex .= "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?" ; User and Pass
         regex .= "([a-z0-9-.]*)\.([a-z]{2,3})" ; Host or IP
         regex .= "(\:[0-9]{2,5})?" ; Port
         regex .= "(\/([a-z0-9+\$_-]\.?)+)*\/?" ; Path
         regex .= "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?" ; GET Query
         regex .= "(#[a-z_.-][a-z0-9+\$_.-]*)?" ; Anchor

         return (url ~= "i)" regex) ? true : false
      }

      x1() {
         return this.x
      }

      y1() {
         return this.y
      }

      x2() {
         return this.x + this.w
      }

      y2() {
         return this.y + this.h
      }

      width() {
         return this.w
      }

      height() {
         return this.h
      }
   } ; End of Image class.

   class Subtitle {
      static extends := "shared"
      init := this._init(true)
      _init(endofunctor := "") {
         extends := this.extends
         under := ((this.outer)[extends])
            ? ((___ := (this.outer)[extends]._init()) ? ___ : (this.outer)[extends])
            : ((___ := %extends%._init()) ? ___ : %extends%)
         if (endofunctor)
            this.base.base := under
         else
            this.base := under
         return this
      }
      outer[] {
         get {
            if ((_class := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop, Parse, _class, .
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return outer
         }
      }

      layers := {}, ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

      Recover(pGraphics) {
         loop % this.layers.maxIndex()
            this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
      }

      Bitmap(x := "", y := "", w := "", h := "") {
         x := (x != "") ? x : this.x
         y := (y != "") ? y : this.y
         w := (w != "") ? w : this.xx - this.x
         h := (h != "") ? h : this.yy - this.y

         pBitmap := Gdip_CreateBitmap(this.ScreenWidth, this.ScreenHeight)
         pGraphics := Gdip_GraphicsFromImage(pBitmap)
         loop % this.layers.maxIndex()
            this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3, pGraphics)
         Gdip_DeleteGraphics(pGraphics)
         pBitmapCopy := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
         Gdip_DisposeImage(pBitmap)
         return pBitmapCopy ; Please dispose of this image responsibly.
      }

      hBitmap(alpha := 0xFFFFFFFF) {
         ; hBitmap converts alpha channel to specified alpha color.
         ; Adds 1 pixel because Anti-Alias (SmoothingMode = 4)
         ; Should it be crop 1 pixel instead?
         pBitmap := this.Bitmap()
         hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, alpha)
         Gdip_DisposeImage(pBitmap)
         return hBitmap
      }

      Save(filename := "", quality := 92) {
         filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
                  : (filename != "") ? filename ".png" : this.title ".png"
         pBitmap := this.Bitmap()
         Gdip_SaveBitmapToFile(pBitmap, filename, quality)
         Gdip_DisposeImage(pBitmap)
         return this
      }

      Screenshot(filename := "", quality := 92) {
         filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
                  : (filename != "") ? filename ".png" : this.title ".png"
         pBitmap := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.xx - this.x "|" this.yy - this.y)
         Gdip_SaveBitmapToFile(pBitmap, filename, quality)
         Gdip_DisposeImage(pBitmap)
         return this
      }

      Render(text := "", style1 := "", style2 := "", update := true) {
         if (!this.hwnd)
            return (new this).Render(text, style1, style2, update)

         this.Draw(text, style1, style2)
         this.DetectScreenResolutionChange()
         if (this.allowDrag == true)
            this.Reposition()
         if (update == true) {
            UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)
         }
         if (this.time) {
            self_destruct := ObjBindMethod(this, "Destroy")
            SetTimer, % self_destruct, % -1 * this.time
         }
         this.rendered := true
         return this
      }

      RenderToBitmap(text := "", style1 := "", style2 := "") {
         if (!this.hwnd)
            return (new this).RenderToBitmap(text, style1, style2)

         this.Render(text, style1, style2, false)
         return this.Bitmap()
      }

      RenderToHBitmap(text := "", style1 := "", style2 := "") {
         if (!this.hwnd)
            return (new this).RenderToHBitmap(text, style1, style2)

         this.Render(text, style1, style2, false)
         return this.hBitmap()
      }

      Reposition() {
         CoordMode, Mouse, Screen
         MouseGetPos, x_mouse, y_mouse
         this.LButton := GetKeyState("LButton", "P") ? 1 : 0
         this.keypress := (this.LButton && DllCall("GetForegroundWindow") == this.hwnd) ? ((!this.keypress) ? 1 : -1) : ((this.keypress == -1) ? 2 : 0)

         if (this.keypress == 1) {
            this.x_mouse := x_mouse, this.y_mouse := y_mouse
            this.hbm2 := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
            this.hdc2 := CreateCompatibleDC()
            this.obm2 := SelectObject(this.hdc2, this.hbm2)
            this.G2 := Gdip_GraphicsFromHDC(this.hdc2)
         }

         if (this.keypress == -1) {
            dx := x_mouse - this.x_mouse
            dy := y_mouse - this.y_mouse
            safe_x := (0 + dx <= 0) ? 0 : 0 + dx
            safe_y := (0 + dy <= 0) ? 0 : 0 + dy
            safe_w := (0 + this.ScreenWidth + dx >= this.ScreenWidth) ? this.ScreenWidth : 0 + this.ScreenWidth + dx
            safe_h := (0 + this.ScreenHeight + dy >= this.ScreenHeight) ? this.ScreenHeight : 0 + this.ScreenHeight + dy
            source_x := (dx < 0) ? -dx : 0
            source_y := (dy < 0) ? -dy : 0
            ;Tooltip % dx ", " dy "`n" safe_x ", " safe_y ", " safe_w ", " safe_h
            Gdip_GraphicsClear(this.G2)
            BitBlt(this.hdc2, safe_x, safe_y, safe_w, safe_h, this.hdc, source_x, source_y)
            UpdateLayeredWindow(this.hwnd, this.hdc2, 0, 0, this.ScreenWidth, this.ScreenHeight)
         }

         if (this.keypress == 2) {
            Gdip_DeleteGraphics(this.G)
            SelectObject(this.hdc, this.obm)
            DeleteObject(this.hbm)
            DeleteDC(this.hdc)
            this.hdc := this.hdc2
            this.obm := this.obm2
            this.hbm := this.hbm2
            this.G := Gdip_GraphicsFromHDC(this.hdc2)
         }

         Reposition := ObjBindMethod(this, "Reposition")
         SetTimer, % Reposition, -10
      }

      Draw(text := "", style1 := "", style2 := "", pGraphics := "") {
         ; If the image was previously rendered, reset everything like a new Subtitle object.
         if (pGraphics == "") {
            if (this.rendered == true) {
               this.rendered := false
               this.layers := {}
               this.x := this.y := this.xx := this.yy := "" ; not 0!
               Gdip_GraphicsClear(this.G)
            }
            this.layers.push([text, style1, style2]) ; Saves each call of Draw()
            pGraphics := this.G
         }

         ; Remove excess whitespace. This is required for proper RegEx detection.
         style1 := !IsObject(style1) ? RegExReplace(style1, "\s+", " ") : style1
         style2 := !IsObject(style2) ? RegExReplace(style2, "\s+", " ") : style2

         ; Load saved styles if and only if both styles are blank.
         if (style1 == "" && style2 == "")
            style1 := this.style1, style2 := this.style2
         else
            this.style1 := style1, this.style2 := style2 ; Remember styles so that they can be loaded next time.

         ; RegEx help? https://regex101.com/r/xLzZzO/2
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         ; Extract styles from the background styles parameter.
         if IsObject(style1) {
            _t  := (style1.time != "")     ? style1.time     : style1.t
            _a  := (style1.anchor != "")   ? style1.anchor   : style1.a
            _x  := (style1.left != "")     ? style1.left     : style1.x
            _y  := (style1.top != "")      ? style1.top      : style1.y
            _w  := (style1.width != "")    ? style1.width    : style1.w
            _h  := (style1.height != "")   ? style1.height   : style1.h
            _r  := (style1.radius != "")   ? style1.radius   : style1.r
            _c  := (style1.color != "")    ? style1.color    : style1.c
            _m  := (style1.margin != "")   ? style1.margin   : style1.m
            _p  := (style1.padding != "")  ? style1.padding  : style1.p
            _q  := (style1.quality != "")  ? style1.quality  : (style1.q) ? style1.q : style1.SmoothingMode
         } else {
            _t  := ((___ := RegExReplace(style1, q1    "(t(ime)?)"          q2, "${value}")) != style1) ? ___ : ""
            _a  := ((___ := RegExReplace(style1, q1    "(a(nchor)?)"        q2, "${value}")) != style1) ? ___ : ""
            _x  := ((___ := RegExReplace(style1, q1    "(x|left)"           q2, "${value}")) != style1) ? ___ : ""
            _y  := ((___ := RegExReplace(style1, q1    "(y|top)"            q2, "${value}")) != style1) ? ___ : ""
            _w  := ((___ := RegExReplace(style1, q1    "(w(idth)?)"         q2, "${value}")) != style1) ? ___ : ""
            _h  := ((___ := RegExReplace(style1, q1    "(h(eight)?)"        q2, "${value}")) != style1) ? ___ : ""
            _r  := ((___ := RegExReplace(style1, q1    "(r(adius)?)"        q2, "${value}")) != style1) ? ___ : ""
            _c  := ((___ := RegExReplace(style1, q1    "(c(olor)?)"         q2, "${value}")) != style1) ? ___ : ""
            _m  := ((___ := RegExReplace(style1, q1    "(m(argin)?)"        q2, "${value}")) != style1) ? ___ : ""
            _p  := ((___ := RegExReplace(style1, q1    "(p(adding)?)"       q2, "${value}")) != style1) ? ___ : ""
            _q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"       q2, "${value}")) != style1) ? ___ : ""
         }

         ; Extract styles from the text styles parameter.
         if IsObject(style2) {
            t  := (style2.time != "")        ? style2.time        : style2.t
            a  := (style2.anchor != "")      ? style2.anchor      : style2.a
            x  := (style2.left != "")        ? style2.left        : style2.x
            y  := (style2.top != "")         ? style2.top         : style2.y
            w  := (style2.width != "")       ? style2.width       : style2.w
            h  := (style2.height != "")      ? style2.height      : style2.h
            m  := (style2.margin != "")      ? style2.margin      : style2.m
            f  := (style2.font != "")        ? style2.font        : style2.f
            s  := (style2.size != "")        ? style2.size        : style2.s
            c  := (style2.color != "")       ? style2.color       : style2.c
            b  := (style2.bold != "")        ? style2.bold        : style2.b
            i  := (style2.italic != "")      ? style2.italic      : style2.i
            u  := (style2.underline != "")   ? style2.underline   : style2.u
            j  := (style2.justify != "")     ? style2.justify     : style2.j
            n  := (style2.noWrap != "")      ? style2.noWrap      : style2.n
            z  := (style2.condensed != "")   ? style2.condensed   : style2.z
            d  := (style2.dropShadow != "")  ? style2.dropShadow  : style2.d
            o  := (style2.outline != "")     ? style2.outline     : style2.o
            q  := (style2.quality != "")     ? style2.quality     : (style2.q) ? style2.q : style2.TextRenderingHint
         } else {
            t  := ((___ := RegExReplace(style2, q1    "(t(ime)?)"          q2, "${value}")) != style2) ? ___ : ""
            a  := ((___ := RegExReplace(style2, q1    "(a(nchor)?)"        q2, "${value}")) != style2) ? ___ : ""
            x  := ((___ := RegExReplace(style2, q1    "(x|left)"           q2, "${value}")) != style2) ? ___ : ""
            y  := ((___ := RegExReplace(style2, q1    "(y|top)"            q2, "${value}")) != style2) ? ___ : ""
            w  := ((___ := RegExReplace(style2, q1    "(w(idth)?)"         q2, "${value}")) != style2) ? ___ : ""
            h  := ((___ := RegExReplace(style2, q1    "(h(eight)?)"        q2, "${value}")) != style2) ? ___ : ""
            m  := ((___ := RegExReplace(style2, q1    "(m(argin)?)"        q2, "${value}")) != style2) ? ___ : ""
            f  := ((___ := RegExReplace(style2, q1    "(f(ont)?)"          q2, "${value}")) != style2) ? ___ : ""
            s  := ((___ := RegExReplace(style2, q1    "(s(ize)?)"          q2, "${value}")) != style2) ? ___ : ""
            c  := ((___ := RegExReplace(style2, q1    "(c(olor)?)"         q2, "${value}")) != style2) ? ___ : ""
            b  := ((___ := RegExReplace(style2, q1    "(b(old)?)"          q2, "${value}")) != style2) ? ___ : ""
            i  := ((___ := RegExReplace(style2, q1    "(i(talic)?)"        q2, "${value}")) != style2) ? ___ : ""
            u  := ((___ := RegExReplace(style2, q1    "(u(nderline)?)"     q2, "${value}")) != style2) ? ___ : ""
            j  := ((___ := RegExReplace(style2, q1    "(j(ustify)?)"       q2, "${value}")) != style2) ? ___ : ""
            n  := ((___ := RegExReplace(style2, q1    "(n(oWrap)?)"        q2, "${value}")) != style2) ? ___ : ""
            z  := ((___ := RegExReplace(style2, q1    "(z|condensed)"      q2, "${value}")) != style2) ? ___ : ""
            d  := ((___ := RegExReplace(style2, q1    "(d(ropShadow)?)"    q2, "${value}")) != style2) ? ___ : ""
            o  := ((___ := RegExReplace(style2, q1    "(o(utline)?)"       q2, "${value}")) != style2) ? ___ : ""
            q  := ((___ := RegExReplace(style2, q1    "(q(uality)?)"       q2, "${value}")) != style2) ? ___ : ""
         }

         ; Extract the time variable and save it for later when we Render() everything.
         static times := "(?i)^\s*(\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
         t  := (_t) ? _t : t
         t  := ( t ~= times) ? RegExReplace( t, "\s", "") : 0 ; Default time is zero.
         t  := ((___ := RegExReplace( t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) !=  t) ? ___ *        1 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) !=  t) ? ___ *     1000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) !=  t) ? ___ *    60000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)h(our)?s?$"               , "$1")) !=  t) ? ___ *  3600000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)d(ay)?s?$"                , "$1")) !=  t) ? ___ * 86400000 : t
         this.time := t

         ; These are the type checkers.
         static valid := "(?i)^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         ; Define viewport width and height. This is the visible screen area.
         this.vw := 0.01 * this.ScreenWidth    ; 1% of viewport width.
         this.vh := 0.01 * this.ScreenHeight   ; 1% of viewport height.
         this.vmin := (this.vw < this.vh) ? this.vw : this.vh ; 1vw or 1vh, whichever is smaller.

         ; Get Rendering Quality.
         _q := (_q >= 0 && _q <= 4) ? _q : 4          ; Default SmoothingMode is 4 if radius is set. See Draw 1.
         q  := (q >= 0 && q <= 5) ? q : 4             ; Default TextRenderingHint is 4 (antialias).

         ; Get Font size.
         s  := (s ~= valid_positive) ? RegExReplace(s, "\s", "") : "2.23vh"           ; Default font size is 2.23vh.
         s  := (s ~= "i)(pt|px)$") ? SubStr(s, 1, -2) : s                               ; Strip spaces, px, and pt.
         s  := (s ~= "i)vh$") ? RegExReplace(s, "i)vh$", "") * this.vh : s                ; Relative to viewport height.
         s  := (s ~= "i)vw$") ? RegExReplace(s, "i)vw$", "") * this.vw : s                ; Relative to viewport width.
         s  := (s ~= "i)(%|vmin)$") ? RegExReplace(s, "i)(%|vmin)$", "") * this.vmin : s  ; Relative to viewport minimum.

         ; Get Bold, Italic, Underline, NoWrap, and Justification of text.
         style += (b) ? 1 : 0         ; bold
         style += (i) ? 2 : 0         ; italic
         style += (u) ? 4 : 0         ; underline
         style += (strikeout) ? 8 : 0 ; strikeout, not implemented.
         n  := (n) ? 0x4000 | 0x1000 : 0x4000
         j  := (j ~= "i)cent(er|re)") ? 1 : (j ~= "i)(far|right)") ? 2 : 0   ; Left/near, center/centre, far/right.

         ; Later when text x and w are finalized and it is found that x + ReturnRC[3] exceeds the screen,
         ; then the _redrawBecauseOfCondensedFont flag is set to true.
         if (this._redrawBecauseOfCondensedFont == true)
            f:=z, z:=0, this._redrawBecauseOfCondensedFont := false

         ; Create Font.
         hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial") ; Default font is Arial.
         hFont := Gdip_FontCreate(hFamily, s, style)
         ;GdipStringFormatGetGenericTypographic
         ;MsgBox % DllCall("gdiplus\GdipStringFormatGetGenericDefault", A_PtrSize ? "UPtr*" : "UInt*", hFormat)
         ;MsgBox % DllCall("gdiplus\GdipCreateStringFormat", "int", n, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
         hFormat := Gdip_StringFormatCreate(n)
         Gdip_SetStringFormatAlign(hFormat, j)  ; Left = 0, Center = 1, Right = 2

         ; Simulate string width and height. This will get the exact width and height of the text.
         CreateRectF(RC, 0, 0, 0, 0)
         Gdip_SetSmoothingMode(pGraphics, _q)     ; None = 3, AntiAlias = 4
         Gdip_SetTextRenderingHint(pGraphics, q)  ; Anti-Alias = 4, Cleartype = 5 (and gives weird effects.)
         ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
         ReturnRC := StrSplit(ReturnRC, "|")      ; Contains the values for measured x, y, w, h text.

         ; Get background width and height. Default width and height are simulated width and height.
         _w := (_w ~= valid_positive) ? RegExReplace(_w, "\s", "") : ReturnRC[3]
         _w := (_w ~= "i)(pt|px)$") ? SubStr(_w, 1, -2) : _w
         _w := (_w ~= "i)(%|vw)$") ? RegExReplace(_w, "i)(%|vw)$", "") * this.vw : _w
         _w := (_w ~= "i)vh$") ? RegExReplace(_w, "i)vh$", "") * this.vh : _w
         _w := (_w ~= "i)vmin$") ? RegExReplace(_w, "i)vmin$", "") * this.vmin : _w
         ; Output is a decimal with pixel units.

         _h := (_h ~= valid_positive) ? RegExReplace(_h, "\s", "") : ReturnRC[4]
         _h := (_h ~= "i)(pt|px)$") ? SubStr(_h, 1, -2) : _h
         _h := (_h ~= "i)vw$") ? RegExReplace(_h, "i)vw$", "") * this.vw : _h
         _h := (_h ~= "i)(%|vh)$") ? RegExReplace(_h, "i)(%|vh)$", "") * this.vh : _h
         _h := (_h ~= "i)vmin$") ? RegExReplace(_h, "i)vmin$", "") * this.vmin : _h
         ; Output is a decimal with pixel units.

         ; Get background anchor. This is where the origin of the image is located.
         ; The default origin is the top left corner. Default anchor is 1.
         _a := RegExReplace(_a, "\s", "")
         _a := (_a ~= "i)top" && _a ~= "i)left") ? 1 : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 2
            : (_a ~= "i)top" && _a ~= "i)right") ? 3 : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 4
            : (_a ~= "i)cent(er|re)" && _a ~= "i)right") ? 6 : (_a ~= "i)bottom" && _a ~= "i)left") ? 7
            : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 8 : (_a ~= "i)bottom" && _a ~= "i)right") ? 9
            : (_a ~= "i)top") ? 2 : (_a ~= "i)left") ? 4 : (_a ~= "i)right") ? 6 : (_a ~= "i)bottom") ? 8
            : (_a ~= "i)cent(er|re)") ? 5 : (_a ~= "^[1-9]$") ? _a : 1 ; Default anchor is top-left.

         ; _x and _y can be specified as locations (left, center, right, top, bottom).
         ; These location words in _x and _y take precedence over the values in _a.
         _a  := (_x ~= "i)left") ? 1+(((_a-1)//3)*3) : (_x ~= "i)cent(er|re)") ? 2+(((_a-1)//3)*3) : (_x ~= "i)right") ? 3+(((_a-1)//3)*3) : _a
         _a  := (_y ~= "i)top") ? 1+(mod(_a-1,3)) : (_y ~= "i)cent(er|re)") ? 4+(mod(_a-1,3)) : (_y ~= "i)bottom") ? 7+(mod(_a-1,3)) : _a

         ; Convert English words to numbers. Don't mess with these values any further.
         _x  := (_x ~= "i)left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*this.ScreenWidth : (_x ~= "i)right") ? this.ScreenWidth : _x
         _y  := (_y ~= "i)top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*this.ScreenHeight : (_y ~= "i)bottom") ? this.ScreenHeight : _y

         ; Get _x value.
         _x := (_x ~= valid) ? RegExReplace(_x, "\s", "") : 0  ; Default _x is 0.
         _x := (_x ~= "i)(pt|px)$") ? SubStr(_x, 1, -2) : _x
         _x := (_x ~= "i)(%|vw)$") ? RegExReplace(_x, "i)(%|vw)$", "") * this.vw : _x
         _x := (_x ~= "i)vh$") ? RegExReplace(_x, "i)vh$", "") * this.vh : _x
         _x := (_x ~= "i)vmin$") ? RegExReplace(_x, "i)vmin$", "") * this.vmin : _x

         ; Get _y value.
         _y := (_y ~= valid) ? RegExReplace(_y, "\s", "") : 0  ; Default _y is 0.
         _y := (_y ~= "i)(pt|px)$") ? SubStr(_y, 1, -2) : _y
         _y := (_y ~= "i)vw$") ? RegExReplace(_y, "i)vw$", "") * this.vw : _y
         _y := (_y ~= "i)(%|vh)$") ? RegExReplace(_y, "i)(%|vh)$", "") * this.vh : _y
         _y := (_y ~= "i)vmin$") ? RegExReplace(_y, "i)vmin$", "") * this.vmin : _y

         ; Now let's modify the _x and _y values with the _anchor, so that the image has a new point of origin.
         ; We need our calculated _width and _height for this.
         _x  -= (mod(_a-1,3) == 0) ? 0 : (mod(_a-1,3) == 1) ? _w/2 : (mod(_a-1,3) == 2) ? _w : 0
         _y  -= (((_a-1)//3) == 0) ? 0 : (((_a-1)//3) == 1) ? _h/2 : (((_a-1)//3) == 2) ? _h : 0
         ; Fractional y values might cause gdi+ slowdown.


         ; Get the text width and text height.
         ; Note that there are two new lines. Matching a percent symbol (%) will give text width/height
         ; that is relative to the background width/height. This is undesirable behavior, and so
         ; the user should use "vh" and "vw" whenever possible.
         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : ReturnRC[3] ; Default is simulated text width.
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * this.vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * this.vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * this.vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * _w :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : ReturnRC[4] ; Default is simulated text height.
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * this.vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * this.vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * this.vmin :  h
         h  := ( h ~= "%$") ? RegExReplace( h, "%$", "") * 0.01 * _h :  h

         ; If text justification is set but x is not, align the justified text relative to the center
         ; or right of the backgound, after taking into account the text width.
         if (x == "")
            x  := (j = 1) ? _x + (_w/2) - (w/2) : (j = 2) ? _x + _w - w : x

         ; Get anchor.
         a  := RegExReplace( a, "\s", "")
         a  := (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
            : (a ~= "i)top" && a ~= "i)right") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
            : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 6 : (a ~= "i)bottom" && a ~= "i)left") ? 7
            : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8 : (a ~= "i)bottom" && a ~= "i)right") ? 9
            : (a ~= "i)top") ? 2 : (a ~= "i)left") ? 4 : (a ~= "i)right") ? 6 : (a ~= "i)bottom") ? 8
            : (a ~= "i)cent(er|re)") ? 5 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

         ; Text x and text y can be specified as locations (left, center, right, top, bottom).
         ; These location words in text x and text y take precedence over the values in the text anchor.
         a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
         a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

         ; Convert English words to numbers. Don't mess with these values any further.
         ; Also, these values are relative to the background.
         x  := ( x ~= "i)left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*_w : (x ~= "i)right") ? _x + _w : x
         y  := ( y ~= "i)top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*_h : (y ~= "i)bottom") ? _y + _h : y

         ; Validate text x and y, convert to pixels.
         x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : _x ; Default text x is background x.
         x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
         x  := ( x ~= "i)vw$") ? RegExReplace( x, "i)vw$", "") * this.vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * this.vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * this.vmin :  x
         x  := ( x ~= "%$") ? RegExReplace( x, "%$", "") * 0.01 * _w :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : _y ; Default text y is background y.
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * this.vw :  y
         y  := ( y ~= "i)vh$") ? RegExReplace( y, "i)vh$", "") * this.vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * this.vmin :  y
         y  := ( y ~= "%$") ? RegExReplace( y, "%$", "") * 0.01 * _h :  y

         ; Modify text x and text y values with the anchor, so that the text has a new point of origin.
         ; The text anchor is relative to the text width and height before margin/padding.
         ; This is NOT relative to the background width and height.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Define margin and padding. Both parameters will leave the text unchanged,
         ; expanding the background box. The difference between the two is NON-EXISTENT.
         ; What does matter is if the margin/padding is a background style, the position of the text will not change.
         ; If the margin/padding is a text style, the text position will change.
         ; THERE REALLY IS NO DIFFERENCE BETWEEN MARGIN AND PADDING.
         _p := this.margin_and_padding(_p)
         _m := this.margin_and_padding(_m)
         p  := this.margin_and_padding( p)
         m  := this.margin_and_padding( m)

         ; Modify _x, _y, _w, _h with margin and padding, increasing the size of the background.
         if (_w || _h) {
            _w  += (_m.2 + _m.4 + _p.2 + _p.4) + (m.2 + m.4 + p.2 + p.4)
            _h  += (_m.1 + _m.3 + _p.1 + _p.3) + (m.1 + m.3 + p.1 + p.3)
            _x  -= (_m.4 + _p.4)
            _y  -= (_m.1 + _p.1)
         }

         ; If margin/padding are defined in the text parameter, shift the position of the text.
         x  += (m.4 + p.4)
         y  += (m.1 + p.1)

         ; Re-run: Condense Text using a Condensed Font if simulated text width exceeds screen width.
         if (Gdip_FontFamilyCreate(z)) {
            if (ReturnRC[3] + x > this.ScreenWidth) {
               this._redrawBecauseOfCondensedFont := true
               return this.Draw(text, style1, style2, pGraphics)
            }
         }

         ; Define radius of rounded corners.
         _r := (_r ~= valid_positive) ? RegExReplace(_r, "\s", "") : 0  ; Default radius is 0, or square corners.
         _r := (_r ~= "i)(pt|px)$") ? SubStr(_r, 1, -2) : _r
         _r := (_r ~= "i)vw$") ? RegExReplace(_r, "i)vw$", "") * this.vw : _r
         _r := (_r ~= "i)vh$") ? RegExReplace(_r, "i)vh$", "") * this.vh : _r
         _r := (_r ~= "i)vmin$") ? RegExReplace(_r, "i)vmin$", "") * this.vmin : _r
         ; percentage is defined as a percentage of the smaller background width/height.
         _r := (_r ~= "%$") ? RegExReplace(_r, "%$", "") * 0.01 * ((_w > _h) ? _h : _w) : _r
         ; the radius cannot exceed the half width or half height, whichever is smaller.
         _r  := (_r <= ((_w > _h) ? _h : _w) / 2) ? _r : 0

         ; Define color.
         _c := this.color(_c, 0xDD424242) ; Default background color is transparent gray.
         SourceCopy := (c ~= "i)(delete|eraser?|overwrite|sourceCopy)") ? 1 : 0 ; Eraser brush for text.
         if (!c) ; Default text color changes between white and black.
            c := (this.grayscale(_c) < 128) ? 0xFFFFFFFF : 0xFF000000
         c  := (SourceCopy) ? 0x00000000 : this.color( c)

         ; Define outline and dropShadow.
         o := this.outline(o, s, c)
         d := this.dropShadow(d, ReturnRC[3], ReturnRC[4], s)

         ; Round 9 - Define Text
         if (!A_IsUnicode){
            nSize := DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",0, "int",0)
            VarSetCapacity(wtext, nSize*2)
            DllCall("MultiByteToWideChar", "uint",0, "uint",0, "ptr",&text, "int",-1, "ptr",&wtext, "int",nSize)
         }

         ; Round 10 - Finalize _x, _y, _w, _h
         _x  := Round(_x)
         _y  := Round(_y)
         _w  := Round(_w)
         _h  := Round(_h)

         ; Define image boundaries using the background boundaries.
         this.x  := (this.x  = "" || _x < this.x) ? _x : this.x
         this.y  := (this.y  = "" || _y < this.y) ? _y : this.y
         this.xx := (this.xx = "" || _x + _w > this.xx) ? _x + _w : this.xx
         this.yy := (this.yy = "" || _y + _h > this.yy) ? _y + _h : this.yy

         ; Define image boundaries using the text boundaries + outline boundaries.
         artifacts := Ceil(o.3 + 0.5*o.1)
         this.x  := (x - artifacts < this.x) ? x - artifacts : this.x
         this.y  := (y - artifacts < this.y) ? y - artifacts : this.y
         this.xx := (x + w + artifacts > this.xx) ? x + w + artifacts : this.xx
         this.yy := (y + h + artifacts > this.yy) ? y + h + artifacts : this.yy

         ; Define image boundaries using the dropShadow boundaries.
         artifacts := Ceil(d.3 + d.6 + 0.5*o.1)
         this.x  := (x + d.1 - artifacts < this.x) ? x + d.1 - artifacts : this.x
         this.y  := (y + d.2 - artifacts < this.y) ? y + d.2 - artifacts : this.y
         this.xx := (x + d.1 + w + artifacts > this.xx) ? x + d.1 + w + artifacts : this.xx
         this.yy := (y + d.2 + h + artifacts > this.yy) ? y + d.2 + h + artifacts : this.yy

         ; Round to the nearest integer.
         this.x := Floor(this.x)
         this.y := Floor(this.y)
         this.xx := Ceil(this.xx)
         this.yy := Ceil(this.yy)

         ; Draw 1 - Background
         if (_w && _h && _c && (_c & 0xFF000000)) {
            if (_r == 0)
               Gdip_SetSmoothingMode(pGraphics, 1) ; Turn antialiasing off if not a rounded rectangle.
            pBrushBackground := Gdip_BrushCreateSolid(_c)
            Gdip_FillRoundedRectangle(pGraphics, pBrushBackground, _x, _y, _w, _h, _r) ; DRAWING!
            Gdip_DeleteBrush(pBrushBackground)
            if (_r == 0)
               Gdip_SetSmoothingMode(pGraphics, _q) ; Turn antialiasing on for text rendering.
         }

         ; Draw 2 - DropShadow
         if (!d.void) {
            offset2 := d.3 + d.6 + Ceil(0.5*o.1)

            if (d.3) {
               DropShadow := Gdip_CreateBitmap(w + 2*offset2, h + 2*offset2)
               DropShadowG := Gdip_GraphicsFromImage(DropShadow)
               Gdip_SetSmoothingMode(DropShadowG, _q)
               Gdip_SetTextRenderingHint(DropShadowG, q)
               CreateRectF(RC, offset2, offset2, w + 2*offset2, h + 2*offset2)
            } else {
               CreateRectF(RC, x + d.1, y + d.2, w, h)
               DropShadowG := pGraphics
            }

            ; Use Gdip_DrawString if and only if there is a horizontal/vertical offset.
            if (o.void && d.6 == 0)
            {
               pBrush := Gdip_BrushCreateSolid(d.4)
               Gdip_DrawString(DropShadowG, Text, hFont, hFormat, pBrush, RC) ; DRAWING!
               Gdip_DeleteBrush(pBrush)
            }
            else ; Otherwise, use the below code if blur, size, and opacity are set.
            {
               ; Draw the outer edge of the text string.
               DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
               DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                                  , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)
               pPen := Gdip_CreatePen(d.4, 2*d.6 + o.1)
               DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)
               DllCall("gdiplus\GdipDrawPath", "ptr",DropShadowG, "ptr",pPen, "ptr",pPath)
               Gdip_DeletePen(pPen)

               ; Fill in the outline. Turn off antialiasing and alpha blending so the gaps are 100% filled.
               pBrush := Gdip_BrushCreateSolid(d.4)
               Gdip_SetCompositingMode(DropShadowG, 1) ; Turn off alpha blending
               Gdip_SetSmoothingMode(DropShadowG, 3)   ; Turn off anti-aliasing
               Gdip_FillPath(DropShadowG, pBrush, pPath)
               Gdip_DeleteBrush(pBrush)
               Gdip_DeletePath(pPath)
               Gdip_SetCompositingMode(DropShadowG, 0)
               Gdip_SetSmoothingMode(DropShadowG, _q)
            }

            if (d.3) {
               Gdip_DeleteGraphics(DropShadowG)
               this.GaussianBlur(DropShadow, d.3, d.5)
               Gdip_SetInterpolationMode(pGraphics, 5) ; NearestNeighbor
               Gdip_SetSmoothingMode(pGraphics, 3) ; Turn off anti-aliasing
               Gdip_DrawImage(pGraphics, DropShadow, x + d.1 - offset2, y + d.2 - offset2, w + 2*offset2, h + 2*offset2) ; DRAWING!
               Gdip_SetSmoothingMode(pGraphics, _q)
               Gdip_DisposeImage(DropShadow)
            }
         }

         ; Draw 3 - Text Outline
         if (!o.void) {
            ; Convert our text to a path.
            CreateRectF(RC, x, y, w, h)
            DllCall("gdiplus\GdipCreatePath", "int",1, "uptr*",pPath)
            DllCall("gdiplus\GdipAddPathString", "ptr",pPath, "ptr", A_IsUnicode ? &text : &wtext, "int",-1
                                               , "ptr",hFamily, "int",style, "float",s, "ptr",&RC, "ptr",hFormat)

            ; Create a glow effect around the edges.
            if (o.3) {
               Gdip_SetClipPath(pGraphics, pPath, 3) ; Exclude original text region from being drawn on.
               pPenGlow := Gdip_CreatePen(Format("0x{:02X}",((o.4 & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(o.4 & 0x00FFFFFF)), 1)
               DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPenGlow, "uint",2)

               loop % o.3
               {
                  DllCall("gdiplus\GdipSetPenWidth", "ptr",pPenGlow, "float",o.1 + 2*A_Index)
                  DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPenGlow, "ptr",pPath) ; DRAWING!
               }
               Gdip_DeletePen(pPenGlow)
               Gdip_ResetClip(pGraphics)
            }

            ; Draw outline text.
            if (o.1) {
               pPen := Gdip_CreatePen(o.2, o.1)
               DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPen, "uint",2)
               DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath) ; DRAWING!
               Gdip_DeletePen(pPen)
            }

            ; Fill outline text.
            pBrush := Gdip_BrushCreateSolid(c)
            Gdip_SetCompositingMode(pGraphics, SourceCopy)
            Gdip_FillPath(pGraphics, pBrush, pPath) ; DRAWING!
            Gdip_SetCompositingMode(pGraphics, 0)
            Gdip_DeleteBrush(pBrush)
            Gdip_DeletePath(pPath)
         }

         ; Draw Text if outline is not are not specified.
         if (text != "" && o.void) {
            CreateRectF(RC, x, y, w, h)
            pBrushText := Gdip_BrushCreateSolid(c)
            Gdip_SetCompositingMode(pGraphics, SourceCopy)
            Gdip_DrawString(pGraphics, A_IsUnicode ? text : wtext, hFont, hFormat, pBrushText, RC) ; DRAWING!
            Gdip_SetCompositingMode(pGraphics, 0)
            Gdip_DeleteBrush(pBrushText)
         }

         ; Delete Font Objects.
         Gdip_DeleteStringFormat(hFormat)
         Gdip_DeleteFont(hFont)
         Gdip_DeleteFontFamily(hFamily)

         return (pGraphics == "") ? this : ""
      }

      dropShadow(d, x_simulated, y_simulated, font_size) {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid := "(?i)^\s*(\-?\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         if IsObject(d) {
            d.1 := (d.1) ? d.1 : (d.horizontal != "") ? d.horizontal : d.h
            d.2 := (d.2) ? d.2 : (d.vertical   != "") ? d.vertical   : d.v
            d.3 := (d.3) ? d.3 : (d.blur       != "") ? d.blur       : d.b
            d.4 := (d.4) ? d.4 : (d.color      != "") ? d.color      : d.c
            d.5 := (d.5) ? d.5 : (d.opacity    != "") ? d.opacity    : d.o
            d.6 := (d.6) ? d.6 : (d.size       != "") ? d.size       : d.s
         } else if (d != "") {
            _ := RegExReplace(d, ":\s+", ":")
            _ := RegExReplace(_, "\s+", " ")
            _ := StrSplit(_, " ")
            _.1 := ((___ := RegExReplace(d, q1    "(h(orizontal)?)"    q2, "${value}")) != d) ? ___ : _.1
            _.2 := ((___ := RegExReplace(d, q1    "(v(ertical)?)"      q2, "${value}")) != d) ? ___ : _.2
            _.3 := ((___ := RegExReplace(d, q1    "(b(lur)?)"          q2, "${value}")) != d) ? ___ : _.3
            _.4 := ((___ := RegExReplace(d, q1    "(c(olor)?)"         q2, "${value}")) != d) ? ___ : _.4
            _.5 := ((___ := RegExReplace(d, q1    "(o(pacity)?)"       q2, "${value}")) != d) ? ___ : _.5
            _.6 := ((___ := RegExReplace(d, q1    "(s(ize)?)"          q2, "${value}")) != d) ? ___ : _.6
            d := _
         }
         else return {"void":true, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0}

         for key, value in d {
            if (key = 4) ; Don't mess with color data.
               continue
            d[key] := (d[key] ~= valid) ? RegExReplace(d[key], "\s", "") : 0 ; Default for everything is 0.
            d[key] := (d[key] ~= "i)(pt|px)$") ? SubStr(d[key], 1, -2) : d[key]
            d[key] := (d[key] ~= "i)vw$") ? RegExReplace(d[key], "i)vw$", "") * this.vw : d[key]
            d[key] := (d[key] ~= "i)vh$") ? RegExReplace(d[key], "i)vh$", "") * this.vh : d[key]
            d[key] := (d[key] ~= "i)vmin$") ? RegExReplace(d[key], "i)vmin$", "") * this.vmin : d[key]
         }

         d.1 := (d.1 ~= "%$") ? SubStr(d.1, 1, -1) * 0.01 * x_simulated : d.1
         d.2 := (d.2 ~= "%$") ? SubStr(d.2, 1, -1) * 0.01 * y_simulated : d.2
         d.3 := (d.3 ~= "%$") ? SubStr(d.3, 1, -1) * 0.01 * font_size : d.3
         d.4 := this.color(d.4, 0xFFFF0000) ; Default color is red.
         d.5 := (d.5 ~= "%$") ? SubStr(d.5, 1, -1) / 100 : d.5
         d.5 := (d.5 <= 0 || d.5 > 1) ? 1 : d.5 ; Range Opacity is a float from 0-1.
         d.6 := (d.6 ~= "%$") ? SubStr(d.6, 1, -1) * 0.01 * font_size : d.6
         return d
      }

      font(f, default := "Arial"){

      }

      outline(o, font_size, font_color) {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid_positive := "(?i)^\s*(\d+(?:\.\d*)?)\s*(%|pt|px|vh|vmin|vw)?\s*$"

         if IsObject(o) {
            o.1 := (o.1) ? o.1 : (o.stroke != "") ? o.stroke : o.s
            o.2 := (o.2) ? o.2 : (o.color  != "") ? o.color  : o.c
            o.3 := (o.3) ? o.3 : (o.glow   != "") ? o.glow   : o.g
            o.4 := (o.4) ? o.4 : (o.tint   != "") ? o.tint   : o.t
         } else if (o != "") {
            _ := RegExReplace(o, ":\s+", ":")
            _ := RegExReplace(_, "\s+", " ")
            _ := StrSplit(_, " ")
            _.1 := ((___ := RegExReplace(o, q1    "(s(troke)?)"        q2, "${value}")) != o) ? ___ : _.1
            _.2 := ((___ := RegExReplace(o, q1    "(c(olor)?)"         q2, "${value}")) != o) ? ___ : _.2
            _.3 := ((___ := RegExReplace(o, q1    "(g(low)?)"          q2, "${value}")) != o) ? ___ : _.3
            _.4 := ((___ := RegExReplace(o, q1    "(t(int)?)"          q2, "${value}")) != o) ? ___ : _.4
            o := _
         }
         else return {"void":true, 1:0, 2:0, 3:0, 4:0}

         for key, value in o {
            if (key = 2) || (key = 4) ; Don't mess with color data.
               continue
            o[key] := (o[key] ~= valid_positive) ? RegExReplace(o[key], "\s", "") : 0 ; Default for everything is 0.
            o[key] := (o[key] ~= "i)(pt|px)$") ? SubStr(o[key], 1, -2) : o[key]
            o[key] := (o[key] ~= "i)vw$") ? RegExReplace(o[key], "i)vw$", "") * this.vw : o[key]
            o[key] := (o[key] ~= "i)vh$") ? RegExReplace(o[key], "i)vh$", "") * this.vh : o[key]
            o[key] := (o[key] ~= "i)vmin$") ? RegExReplace(o[key], "i)vmin$", "") * this.vmin : o[key]
         }

         o.1 := (o.1 ~= "%$") ? SubStr(o.1, 1, -1) * 0.01 * font_size : o.1
         o.2 := this.color(o.2, font_color) ; Default color is the text font color.
         o.3 := (o.3 ~= "%$") ? SubStr(o.3, 1, -1) * 0.01 * font_size : o.3
         o.4 := this.color(o.4, o.2) ; Default color is outline color.
         return o
      }

      grayscale(sRGB){
         static rY := 0.212655
         static gY := 0.715158
         static bY := 0.072187

         c1 := 255 & ( sRGB >> 16 )
         c2 := 255 & ( sRGB >> 8 )
         c3 := 255 & ( sRGB )

         loop 3 {
            c%A_Index% := c%A_Index% / 255
            c%A_Index% := (c%A_Index% <= 0.04045) ? c%A_Index%/12.92 : ((c%A_Index%+0.055)/(1.055))**2.4
         }

         v := rY*c1 + gY*c2 + bY*c3
         v := (v <= 0.0031308) ? v * 12.92 : 1.055*(v**(1.0/2.4))-0.055
         return Round(v*255)
      }

      x1() {
         return this.x
      }

      y1() {
         return this.y
      }

      x2() {
         return this.xx
      }

      y2() {
         return this.yy
      }

      width() {
         return this.xx - this.x
      }

      height() {
         return this.yy - this.y
      }
   } ; End of Subtitle class.
}