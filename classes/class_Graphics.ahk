; Script:    Graphics.ahk
; Author:    iseahound
; License:   GPLv3
; Version:   August 2018 (not for public use.)
; Release:   2019-08-03

#include <Gdip_All>    ; https://goo.gl/rUuEF5


; EqualImage() - Ensures that the pixel vaules of multiple images across mutiple formats are identical.
EqualImage(images*){
   return Graphics.ImageRenderer.Equal(images*)
}

; PreprocessImage() - Converts an image of any type into any new type with cropping and scaling.
PreprocessImage(cotype, image, crop:="", scale:="", terms*){
   return Graphics.ImageRenderer.Preprocess(cotype, image, crop, scale, terms*)
}

; RenderImage() - Displays an image in customizable styles on the screen.
RenderImage(image:="", style:="", polygons:=""){
   return Graphics.ImageRenderer.Render(image, style, polygons)
}

; RenderImageI() - Allows the user to interact with the displayed image.
RenderImageI(image:="", style:="", polygons:="", keybinds:=""){
   return new Graphics.INTERACTIVE(Graphics.ImageRenderer.Render(image, style, polygons), keybinds, 2)
}

; RenderImageS() - Creates a sequence of images that can be interacted with.
RenderImageS(image:="", style:="", polygons:="", keybinds:=""){
   return new Graphics.SEQUENCER(new Graphics.INTERACTIVE(Graphics.ImageRenderer.Render(image, style, polygons), keybinds, 2, true))
}

; RenderPolygon() - Displays polygons in customizable styles on the screen.
RenderPolygon(polygon:="", style:=""){
   return Graphics.PolygonRenderer.Render(polygon, style)
}

; RenderPolygonI() - Allows the user to interact with the displayed polygon.
RenderPolygonI(polygon:="", style:="", keybinds:=""){
   return new Graphics.INTERACTIVE(Graphics.PolygonRenderer.Render(polygon, style), keybinds, 0)
}

; RenderPolygonS() - Creates a sequence of polygons that can be interacted with.
RenderPolygonS(polygon:="", style:="", keybinds:=""){
   return new Graphics.SEQUENCER(new Graphics.INTERACTIVE(Graphics.PolygonRenderer.Render(polygon, style), keybinds, 0, true))
}

; RenderText() - Displays text in customizable styles on the screen.
RenderText(text:="", background_style:="", text_style:=""){
   return Graphics.TextRenderer.Render(text, background_style, text_style)
}

; RenderTextI() - Allows the user to interact with the displayed text.
RenderTextI(text:="", background_style:="", text_style:="", keybinds:=""){
   return new Graphics.INTERACTIVE(Graphics.TextRenderer.Render(text, background_style, text_style), keybinds, 2)
}

; RenderTextS() - Creates a sequence of text that can be interacted with.
RenderTextS(text:="", background_style:="", text_style:="", keybinds:=""){
   return new Graphics.SEQUENCER(new Graphics.INTERACTIVE(Graphics.TextRenderer.Render(text, background_style, text_style), keybinds, 2, true))
}


class Graphics {

   static pToken          ; Pointer to an instance of the GDI+ library.
   static renderers := 0  ; Number of active renderer objects currently being used.

   ; Duality #0 - Loads a local instance of the GDI+ library.
   Startup() {
      global pToken
      if (this.renderers++ <= 0) {
         ; Thanks to jeeswg and majkinetor for showing how to create a custom window class.
         vWinClass := "AutoHotkeyGraphics"
         if (A_AhkVersion < 2) {
            _fn := "RegisterCallback"
            pWndProc := %_fn%(this.callback, "F",,&this)
         } else {
            _fn := "CallbackCreate"
            pWndProc := %_fn%(this.callback, "F")
         }
         hCursor := DllCall("LoadCursor", "ptr",0, "ptr",32512, "ptr") ; IDC_ARROW := 32512

         ; struct tagWNDCLASSEXA - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa
         ; struct tagWNDCLASSEXW - https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexw
         vSize := A_PtrSize=8 ? 80:48
         VarSetCapacity(WNDCLASSEX, vSize, 0)                                ; sizeof(WNDCLASSEX) = 48 or 80
            , NumPut(      vSize, WNDCLASSEX,                   0,   "uint") ; cbSize
            , NumPut(          3, WNDCLASSEX,                   4,   "uint") ; style
            , NumPut(   pWndProc, WNDCLASSEX,                   8,    "ptr") ; lpfnWndProc
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 16:12,    "int") ; cbClsExtra
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 20:16,    "int") ; cbWndExtra
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 24:20,    "ptr") ; hInstance
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 32:24,    "ptr") ; hIcon
            , NumPut(    hCursor, WNDCLASSEX, A_PtrSize=8 ? 40:28,    "ptr") ; hCursor
            , NumPut(         16, WNDCLASSEX, A_PtrSize=8 ? 48:32,    "ptr") ; hbrBackground
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 56:36,    "ptr") ; lpszMenuName
            , NumPut( &vWinClass, WNDCLASSEX, A_PtrSize=8 ? 64:40,    "ptr") ; lpszClassName
            , NumPut(          0, WNDCLASSEX, A_PtrSize=8 ? 72:44,    "ptr") ; hIconSm

         ; Registers a window class for subsequent use in calls to the CreateWindow or CreateWindowEx function.
         DllCall("RegisterClassEx", "ptr",&WNDCLASSEX, "ushort")

         ; Set pToken.
         this.pToken := (pToken) ? pToken : Gdip_Startup()
      }
      return this.pToken
   }

   ; Duality #0 - Releases a local instance of the GDI+ library.
   Shutdown() {
      global pToken
      if (--this.renderers <= 0) {
         DllCall("UnregisterClass", "str","AutoHotkeyGraphics", "ptr",0)
         (pToken) ? pToken : Gdip_Shutdown(this.pToken)
      }
      return
   }

   Callback(uMsg, wParam, lParam) {
      return DllCall("DefWindowProc", "ptr",this, "uint",uMsg, "uptr",wParam, "ptr",lParam, "ptr") ; hWnd := this
   }

   class parse {

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

      dropShadow(d, vw, vh, width, height, font_size) {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid := "(?i)^\s*(\-?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         vmin := (vw < vh) ? vw : vh

         if IsObject(d) {
            d.1 := (d.horizontal != "") ? d.horizontal : (d.h != "") ? d.h : d.1
            d.2 := (d.vertical   != "") ? d.vertical   : (d.v != "") ? d.h : d.2
            d.3 := (d.blur       != "") ? d.blur       : (d.b != "") ? d.h : d.3
            d.4 := (d.color      != "") ? d.color      : (d.c != "") ? d.h : d.4
            d.5 := (d.opacity    != "") ? d.opacity    : (d.o != "") ? d.h : d.5
            d.6 := (d.size       != "") ? d.size       : (d.s != "") ? d.h : d.6
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
            d[key] := (d[key] ~= "i)vw$") ? RegExReplace(d[key], "i)vw$", "") * vw : d[key]
            d[key] := (d[key] ~= "i)vh$") ? RegExReplace(d[key], "i)vh$", "") * vh : d[key]
            d[key] := (d[key] ~= "i)vmin$") ? RegExReplace(d[key], "i)vmin$", "") * vmin : d[key]
         }

         d.1 := (d.1 ~= "%$") ? SubStr(d.1, 1, -1) * 0.01 * width : d.1
         d.2 := (d.2 ~= "%$") ? SubStr(d.2, 1, -1) * 0.01 * height : d.2
         d.3 := (d.3 ~= "%$") ? SubStr(d.3, 1, -1) * 0.01 * font_size : d.3
         d.4 := this.color(d.4, 0xFFFF0000) ; Default color is red.
         d.5 := (d.5 ~= "%$") ? SubStr(d.5, 1, -1) / 100 : d.5
         d.5 := (d.5 <= 0 || d.5 > 1) ? 1 : d.5 ; Range Opacity is a float from 0-1.
         d.6 := (d.6 ~= "%$") ? SubStr(d.6, 1, -1) * 0.01 * font_size : d.6
         return d
      }

      font(f, default := "Arial"){

      }

      grayscale(sRGB) {
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

      margin_and_padding(m, vw, vh, default := "") {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid := "(?i)^\s*(\-?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         vmin := (vw < vh) ? vw : vh

         if IsObject(m) {
            m.1 := (m.top    != "") ? m.top    : (m.t != "") ? m.t : m.1
            m.2 := (m.right  != "") ? m.right  : (m.r != "") ? m.r : m.2
            m.3 := (m.bottom != "") ? m.bottom : (m.b != "") ? m.b : m.3
            m.4 := (m.left   != "") ? m.left   : (m.l != "") ? m.l : m.4
         } else if (m != "") {
            _ := RegExReplace(m, ":\s+", ":")
            _ := RegExReplace(_, "\s+", " ")
            _ := StrSplit(_, " ")
            _.1 := ((___ := RegExReplace(m, q1    "(t(op)?)"           q2, "${value}")) != m) ? ___ : _.1
            _.2 := ((___ := RegExReplace(m, q1    "(r(ight)?)"         q2, "${value}")) != m) ? ___ : _.2
            _.3 := ((___ := RegExReplace(m, q1    "(b(ottom)?)"        q2, "${value}")) != m) ? ___ : _.3
            _.4 := ((___ := RegExReplace(m, q1    "(l(eft)?)"          q2, "${value}")) != m) ? ___ : _.4
            m := _
         } else if (default != "")
            m := {1:default, 2:default, 3:default, 4:default}
         else return {"void":true, 1:0, 2:0, 3:0, 4:0}

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
            m[key] := (m[key] ~= "i)vw$") ? RegExReplace(m[key], "i)vw$", "") * vw : m[key]
            m[key] := (m[key] ~= "i)vh$") ? RegExReplace(m[key], "i)vh$", "") * vh : m[key]
            m[key] := (m[key] ~= "i)vmin$") ? RegExReplace(m[key], "i)vmin$", "") * vmin : m[key]
         }
         m.1 := (m.1 ~= "%$") ? SubStr(m.1, 1, -1) * vh : m.1
         m.2 := (m.2 ~= "%$") ? SubStr(m.2, 1, -1) * (exception ? vh : vw) : m.2
         m.3 := (m.3 ~= "%$") ? SubStr(m.3, 1, -1) * vh : m.3
         m.4 := (m.4 ~= "%$") ? SubStr(m.4, 1, -1) * (exception ? vh : vw) : m.4
         return m
      }

      outline(o, vw, vh, font_size, font_color) {
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"
         static valid_positive := "(?i)^\s*((?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         vmin := (vw < vh) ? vw : vh

         if IsObject(o) {
            o.1 := (o.stroke != "") ? o.stroke : (o.s != "") ? o.s : o.1
            o.2 := (o.color  != "") ? o.color  : (o.c != "") ? o.c : o.2
            o.3 := (o.glow   != "") ? o.glow   : (o.g != "") ? o.g : o.3
            o.4 := (o.tint   != "") ? o.tint   : (o.t != "") ? o.t : o.4
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
            o[key] := (o[key] ~= "i)vw$") ? RegExReplace(o[key], "i)vw$", "") * vw : o[key]
            o[key] := (o[key] ~= "i)vh$") ? RegExReplace(o[key], "i)vh$", "") * vh : o[key]
            o[key] := (o[key] ~= "i)vmin$") ? RegExReplace(o[key], "i)vmin$", "") * vmin : o[key]
         }

         o.1 := (o.1 ~= "%$") ? SubStr(o.1, 1, -1) * 0.01 * font_size : o.1
         o.2 := this.color(o.2, font_color) ; Default color is the text font color.
         o.3 := (o.3 ~= "%$") ? SubStr(o.3, 1, -1) * 0.01 * font_size : o.3
         o.4 := this.color(o.4, o.2) ; Default color is outline color.
         return o
      }
   }

   class filter {

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

   }

   class safe_bitmap {

      outer[p:=""] {
         get {
            static period := ".", _period := (A_AhkVersion < 2) ? period : "period"
            if ((__outer := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop Parse, __outer, %_period%
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return IsObject(outer) ? ((p) ? outer[p] : outer) : ((p) ? %p% : "")
         }
      }

      __New(pBitmap) {
         global pToken
         if !(this.outer.Startup())
            if !(pToken)
               if !(this.pToken := Gdip_Startup())
                  throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

         this.pBitmap := pBitmap
         this.w := this.width := Gdip_GetImageWidth(pBitmap)
         this.h := this.height := Gdip_GetImageHeight(pBitmap)
         this.size := this.width * this.height
      }

      __Delete() {
         Gdip_DisposeImage(this.pBitmap)

         global pToken
         if (this.outer.pToken)
            return this.outer.Shutdown()
         if (pToken)
            return
         if (this.pToken)
            return Gdip_Shutdown(this.pToken)
      }

      Lock() {

               this.isLockBits := true
               Gdip_LockBits(this.pBitmap, 0, 0, this.width, this.height, Stride, Scan0, BitmapData)
               this.BitmapData := BitmapData
               this.Stride := Stride
               this.Scan0 := Scan0+0
            }

      __Get(x, y:="", color:=""){
         static pBitmap, Stride

         if x is integer
         {

            if (y == "" && color == "" && (ARGB := NumGet(pBitmap, x, "uint")))
               return ARGB

            if (color == "" && (ARGB := NumGet(pBitmap, y*Stride + x, "uint")))
               return ARGB

            if (y == "" && color = "alpha" && (ARGB := NumGet(pBitmap, x, "uchar")))
               return ARGB

            if (y == "" && color =   "red" && (ARGB := NumGet(pBitmap, x + 1, "uchar")))
               return ARGB

            if (y == "" && color = "green" && (ARGB := NumGet(pBitmap, x + 2, "uchar")))
               return ARGB

            if (y == "" && color =  "blue" && (ARGB := NumGet(pBitmap, x + 3, "uchar")))
               return ARGB

            if (color = "alpha" && (ARGB := NumGet(pBitmap, y*Stride, "uchar")))
               return ARGB

            if (color =   "red" && (ARGB := NumGet(pBitmap, y*Stride + x + 1, "uchar")))
               return ARGB

            if (color = "green" && (ARGB := NumGet(pBitmap, y*Stride + x + 2, "uchar")))
               return ARGB

            if (color =  "blue" && (ARGB := NumGet(pBitmap, y*Stride + x + 3, "uchar")))
               return ARGB

            if !(pBitmap)
               pBitmap := this.pBitmap

            if !(this.isLockBits)
               throw Exception("idgaf!") ; SET STRIDE, then this.Stride!
            }
      }

      __Get2(x, y:="", color:="") {
         ; Get Bitmap[x,y] returns pixel.
         if (y >= 0) {

            if !(this.isLockBits) {
               this.isLockBits := true
               Gdip_LockBits(this.pBitmap, 0, 0, this.width, this.height, Stride, Scan0, BitmapData)
               this.BitmapData := BitmapData
               this.Stride := Stride
               this.Scan0 := Scan0+0
            }

            return NumGet(this.Scan0, x*4 + y*this.Stride, "uint")

            if !(y ~= "^\d+$") {
               y := x // this.height
               x := mod(x, this.height)
            }

            if !(color)
               return NumGet(this.Scan0, x*4 + y*this.Stride, "uint")

            ARGB := NumGet(this.Scan0, terms.1*4 + terms.2*this.Stride, "uint")

            if !(terms.3)
               return ARGB
            if (terms.3 ~= "i)a(lpha)?")
               return (ARGB & 0xFF000000) >> 24
            if (terms.3 ~= "i)r(ed)?")
               return (ARGB & 0x00FF0000) >> 16
            if (terms.3 ~= "i)g(reen)?")
               return (ARGB & 0x0000FF00) >>  8
            if (terms.3 ~= "i)b(lue)?")
               return (ARGB & 0x000000FF)
         }

         ; Get Bitmap[] or Bitmap.ptr returns pBitmap.
         if (x == "" || x = "ptr") {
            if (this.isLockBits) {
               this.isLockBits := false
               this.Stride := this.Scan0 := ""
               Gdip_UnlockBits(this.pBitmap, this.BitmapData)
            }
            return this.pBitmap
         }
      }

      __Set(terms*) {
         ARGB := terms.pop()

         ; Set Bitmap[x,y] to a pixel.
         if (terms.1 ~= "^\d+$") {
            if !(this.isLockBits) {
               this.isLockBits := true
               Gdip_LockBits(this.pBitmap, 0, 0, this.width, this.height, Stride, Scan0, BitmapData)
               this.Stride := Stride
               this.Scan0 := Scan0
               this.BitmapData := BitmapData
               this.size := this.Stride * this.height
            }

            if !(terms.3)
               NumPut(ARGB, Scan0+0, terms.1*4 + terms.2*this.Stride, "uint")
            if (terms.3 ~= "i)a(lpha)?")
               NumPut(ARGB, Scan0+0, terms.1*4 + terms.2*this.Stride + 0, "uchar")
            if (terms.3 ~= "i)r(ed)?")
               NumPut(ARGB, Scan0+0, terms.1*4 + terms.2*this.Stride + 1, "uchar")
            if (terms.3 ~= "i)g(reen)?")
               NumPut(ARGB, Scan0+0, terms.1*4 + terms.2*this.Stride + 2, "uchar")
            if (terms.3 ~= "i)b(lue)?")
               NumPut(ARGB, Scan0+0, terms.1*4 + terms.2*this.Stride + 3, "uchar")
         }
      }
   }

   class memory {

      __New(width, height){
         this.hbm := CreateDIBSection(this.width := width, this.height := height)
         this.hdc := CreateCompatibleDC()
         this.obm := SelectObject(this.hdc, this.hbm)
         this.gfx := Gdip_GraphicsFromHDC(this.hdc)
         return this
      }

      __Delete(){
         Gdip_DeleteGraphics(this.gfx)
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
         debug := "function: " this.fn.2
            . "`nx: " this.x.2 "`ty: " this.y.2
            . "`nw: " this.w.2 "`th: " this.h.2
            . "`nx2: " this.xx.2 "`ty2: " this.yy.2
            . "`nmx: " this.mx.2 "`tmy: " this.my.2

            . "`nfunction: " this.fn.1
            . "`nx: " this.x.1 "`ty: " this.y.1
            . "`nw: " this.w.1 "`th: " this.h.1
            . "`nx2: " this.xx.1 "`ty2: " this.yy.1
            . "`nmx: " this.mx.1 "`tmy: " this.my.1
         _debug := (A_AhkVersion < 2) ? debug : "debug"
         Tooltip %_debug%
      }
   }

   class renderer {

      ; IO - Capture input and internalize environmental data.
      IO(terms*) {
         static A_Frequency, f := DllCall("QueryPerformanceFrequency", "int64*",A_Frequency)
         DllCall("QueryPerformanceCounter", "int64*",A_PreciseTime)

         this.PreciseTime := A_PreciseTime
         this.TickCount := A_TickCount
         this.Frequency := A_Frequency
         this.ScreenWidth := A_ScreenWidth
         this.ScreenHeight := A_ScreenHeight
         this.IsAdmin := A_IsAdmin
         return this.arg := terms
      }

      ; Duality #1 - Safe wrapper for the GDI+ library during object instantiation.
      __New(terms*) {
         this.IO(terms*)

         global pToken
         if !(this.outer.Startup())
            if !(pToken)
               if !(this.pToken := Gdip_Startup())
                  throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

         return this.CreateWindow(terms*)
      }

      ; Duality #1 - Safe wrapper for the GDI+ library during object garbage collection.
      __Delete() {
         if (this.hwnd)
            this.DestroyWindow()

         global pToken
         if (this.outer.pToken)
            return this.outer.Shutdown()
         if (pToken)
            return
         if (this.pToken)
            return Gdip_Shutdown(this.pToken)
      }

      ; Duality #2 - Creates a window.
      CreateWindow(title := "", window := "", activate := "") {
         ; Retrieve original arguments upon window creation.
         title    := (title != "")    ? title    : this.arg.1
         window   := (window != "")   ? window   : this.arg.2
         activate := (activate != "") ? activate : this.arg.3

         ; Name the window by its inherited class. (Note: A_ThisFunc won't work.)
         title := (title != "") ? title : RegExReplace(this.__class, "(.*\.)*(.*)$", "$2")

         ; Tokenize window styles.
         window := RegExReplace(window, "\s+", " ")
         window := StrSplit(window, " ")
         for i, token in window {
            ;if (token ~= "i)")
         }

         ;window := (window != "") ? window : " +AlwaysOnTop -Caption +ToolWindow"
         ;window .= " +LastFound -DPIScale +E0x80000 +hwndhwnd"

         ; Window Styles - https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles
         ; Extended Window Styles - https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles

         WS_OVERLAPPED             :=        0x0
         WS_TILED                  :=        0x0
         WS_TABSTOP                :=    0x10000
         WS_MAXIMIZEBOX            :=    0x10000
         WS_MINIMIZEBOX            :=    0x20000
         WS_GROUP                  :=    0x20000
         WS_SIZEBOX                :=    0x40000
         WS_THICKFRAME             :=    0x40000
         WS_SYSMENU                :=    0x80000
         WS_HSCROLL                :=   0x100000
         WS_VSCROLL                :=   0x200000
         WS_DLGFRAME               :=   0x400000
         WS_BORDER                 :=   0x800000
         WS_MAXIMIZE               :=  0x1000000
         WS_CLIPCHILDREN           :=  0x2000000
         WS_CLIPSIBLINGS           :=  0x4000000
         WS_DISABLED               :=  0x8000000
         WS_VISIBLE                := 0x10000000
         WS_ICONIC                 := 0x20000000
         WS_MINIMIZE               := 0x20000000
         WS_CHILD                  := 0x40000000
         WS_CHILDWINDOW            := 0x40000000
         WS_POPUP                  := 0x80000000
         WS_CAPTION                :=   0xC00000
         WS_OVERLAPPEDWINDOW       :=   0xCF0000
         WS_TILEDWINDOW            :=   0xCF0000
         WS_POPUPWINDOW            := 0x80880000

         WS_EX_LEFT                :=        0x0
         WS_EX_LTRREADING          :=        0x0
         WS_EX_RIGHTSCROLLBAR      :=        0x0
         WS_EX_DLGMODALFRAME       :=        0x1
         WS_EX_NOPARENTNOTIFY      :=        0x4
         WS_EX_ALWAYSONTOP         :=        0x4 ; custom
         WS_EX_TOPMOST             :=        0x8
         WS_EX_ACCEPTFILES         :=       0x10
         WS_EX_TRANSPARENT         :=       0x20
         WS_EX_MDICHILD            :=       0x40
         WS_EX_TOOLWINDOW          :=       0x80
         WS_EX_WINDOWEDGE          :=      0x100
         WS_EX_CLIENTEDGE          :=      0x200
         WS_EX_CONTEXTHELP         :=      0x400
         WS_EX_RIGHT               :=     0x1000
         WS_EX_RTLREADING          :=     0x2000
         WS_EX_LEFTSCROLLBAR       :=     0x4000
         WS_EX_CONTROLPARENT       :=    0x10000
         WS_EX_STATICEDGE          :=    0x20000
         WS_EX_APPWINDOW           :=    0x40000
         WS_EX_LAYERED             :=    0x80000
         WS_EX_NOINHERITLAYOUT     :=   0x100000
         WS_EX_NOREDIRECTIONBITMAP :=   0x200000
         WS_EX_LAYOUTRTL           :=   0x400000
         WS_EX_COMPOSITED          :=  0x2000000
         WS_EX_NOACTIVATE          :=  0x8000000
         WS_EX_OVERLAPPEDWINDOW    :=      0x300
         WS_EX_PALETTEWINDOW       :=      0x188

         vWinStyle := WS_SYSMENU ; start off hidden with WS_VISIBLE off
         vWinExStyle := WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_LAYERED

         ; The difference between the screen and the bitmap is that the screen defines the viewable area
         ; while the bitmap defines the current size of the memory buffer. In practice the bitmap could be
         ; a small part of the screen. Thus the DrawRaw() operations require the viewport width and height
         ; calculated by 0.01*ScreenWidth and 0.01*ScreenHeight.
         ; NOTE: DrawRaw() does not accept offsets, which are defined by BitmapLeft and BitmapTop.
         this.BitmapLeft := 0
         this.BitmapTop := 0
         this.BitmapWidth := this.ScreenWidth
         this.BitmapHeight := this.ScreenHeight

         this.hwnd := DllCall("CreateWindowEx"
            ,   "uint", vWinExStyle           ; dwExStyle
            ,    "str", "AutoHotkeyGraphics"  ; lpClassName
            ,    "str", this.title            ; lpWindowName
            ,   "uint", vWinStyle             ; dwStyle
            ,    "int", this.BitmapLeft       ; X
            ,    "int", this.BitmapTop        ; Y
            ,    "int", this.BitmapWidth      ; nWidth
            ,    "int", this.BitmapHeight     ; nHeight
            ,    "ptr", 0                     ; hWndParent
            ,    "ptr", 0                     ; hMenu
            ,    "ptr", 0                     ; hInstance
            ,    "ptr", 0                     ; lpParam
            ,    "ptr")

         DllCall("ShowWindow", "ptr",this.hwnd, "int",(this.activateOnAdmin && !this.isDrawable()) ? 1 : 4)

         return this.LoadMemory()
      }

      ; Duality #2 - Destroys a window.
      DestroyWindow() {
         if (this.hdc)
            this.FreeMemory()
         DllCall("DestroyWindow", "ptr",this.hwnd)
         this.hwnd := ""
         return this
      }

      ; Duality #3 - Allocates the memory buffer.
      LoadMemory() {
         ; Creates a memory DC compatible with the application's current screen.
         this.hdc := CreateCompatibleDC()

         ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
         VarSetCapacity(bi, 40, 0)                              ; sizeof(bi) = 40
            , NumPut(                     40, bi,  0,   "uint") ; Size
            , NumPut(       this.BitmapWidth, bi,  4,   "uint") ; Width
            , NumPut(     -this.BitmapHeight, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
            , NumPut(                      1, bi, 12, "ushort") ; Planes
            , NumPut(                     32, bi, 14, "ushort") ; BitCount / BitsPerPixel

         ; Creates a Device Independent Bitmap giving us a pointer to the pixels.
         this.hbm := DllCall("CreateDIBSection", "ptr",this.hdc, "ptr",&bi, "uint",0, "ptr*",pBits, "ptr",0, "uint",0, "ptr")
         this.obm := SelectObject(this.hdc, this.hbm)
         this.gfx := Gdip_GraphicsFromHDC(this.hdc)

         ; IMPORTANT: DIB pixels are pre-multiplied ARGB because that's how they're displayed on the screen.
         ; enum PixelFormat - https://svn.eiffel.com/eiffelstudio/trunk/Src/library/wel/gdi/gdiplus/wel_gdip_pixel_format.e
         this.pBits := pBits
         this.pixelFormat := 0xE200B ; Format32bppPArgb
         this.stride := 4 * this.BitmapWidth
         this.size := this.stride * this.BitmapHeight
         this.layers := {}

         ;global PreciseTime
         ;DllCall("QueryPerformanceCounter", "int64*",A_PreciseTime)
         ;Tooltip % PreciseTime := (A_PreciseTime - this.PreciseTime) / this.Frequency

         return this.Interop()
      }

      ; Duality #3 - Frees the memory buffer.
      FreeMemory() {
         Gdip_DeleteGraphics(this.gfx)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         this.gfx := this.obm := this.pBits := this.hbm := this.hdc := ""
         return this
      }

      Interop(){
         ; Use this.outer to dynamically search for DrawRaw() and Render() functions
         ; of other classes mapping them to this.Draw%classname%. So DrawImage etc.
         return this
      }

      ; BROKEN - create a fixed size flag.
      UpdateMemory(BitmapWidth := 0, BitmapHeight := 0) {
         BitmapWidth := (BitmapWidth) ? BitmapWidth : A_ScreenWidth
         BitmapHeight := (BitmapHeight) ? BitmapHeight : A_ScreenHeight

         if (BitmapWidth == this.BitmapWidth && BitmapHeight == this.BitmapHeight)
            return this

         this.BitmapWidth := BitmapWidth
         this.BitmapHeight := BitmapHeight
         return this.FreeMemory().LoadMemory().Recover()
      }

      CompressMemory() {
         ; Create.
         hdc := CreateCompatibleDC(this.hdc)
         hbm := CreateDIBSection(this.w, -this.h, hdc, 32, pBits)
         obm := SelectObject(hdc, hbm)

         ; Copy.
         BitBlt(hdc, 0, 0, this.w, this.h, this.hdc, this.x, this.y)

         ; Delete.
         Gdip_DeleteGraphics(this.gfx)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)

         ; Replace.
         this.hdc := hdc
         this.hbm := hbm
         this.obm := obm
         this.gfx := Gdip_GraphicsFromHDC(hdc)
         this.pBits := pBits

         ; Update
         this.BitmapLeft := this.x
         this.BitmapTop := this.y
         this.BitmapWidth := this.w
         this.BitmapHeight := this.h

         this.w -= this.x
         this.h -= this.y
         this.x := 0
         this.y := 0
      }

      DumpMemory() {
         VarSetCapacity(pixels, this.size)
         DllCall("RtlMoveMemory", "ptr",&pixels, "ptr",this.pBits, "uptr",this.size)
         return pixels
      }

      DebugMemory() {
         loop {
            pixel := Format("0x{:08x}", NumGet(this.pBits, 4*(A_Index-1), "uint"))
            _pixel := (A_AhkVersion < 2) ? pixel : "pixel"
            MsgBox %_pixel%
         }
      }

      BitmapFromBits() {
         DllCall("gdiplus\GdipCreateBitmapFromScan0", "int",this.BitmapWidth, "int",this.ScreenHeight
            , "int",this.stride, "uint",this.pixelFormat, "ptr",this.pBits, "ptr*",pBitmap)
         return pBitmap
      }

      NewBitmap() {
         DllCall("gdiplus\GdipCreateBitmapFromScan0", "int",this.BitmapWidth, "int",this.BitmapHeight
            , "int",this.stride, "uint",this.pixelFormat, "ptr",this.pBits, "ptr*",pBitmap)
         DllCall("gdiplus\GdipCloneBitmapAreaI", "int",0, "int",0, "int",this.BitmapWidth, "int",this.BitmapHeight
            , "uint",0x26200a, "ptr",pBitmap, "ptr*",pBitmapDest)
         Gdip_DisposeImage(pBitmap)
         return pBitmapDest
      }

      BitmapFromScan0() {
         this.SetCapacity("pixels", this.size)
         this.Scan0 := this.GetAddress("pixels")
         DllCall("RtlMoveMemory", "ptr",this.Scan0, "ptr",this.pBits, "uptr",this.size)
         DllCall("gdiplus\GdipCreateBitmapFromScan0", "int",this.BitmapWidth, "int",this.BitmapHeight
            , "int",this.stride, "uint",this.pixelFormat, "ptr",this.Scan0, "ptr*",pBitmap)
         return pBitmap
      }

      Recover() {
         layers := this.layers.maxIndex()
         _layers := (A_AhkVersion < 2) ? layers : "layers"
         loop %_layers%
            this.Draw(this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3)
         return this
      }

      Draw(data := "", styles*) {
         this.Clear()
         for i, style in styles
            if (style != "") {
               okay := true
               break
            }
         if !(okay)
            styles := this.styles
         this.data := data
         this.styles := styles
         this.layers.push([data, styles*])
         o := this.DrawRaw(this.gfx, this.ScreenWidth, this.ScreenHeight, data, styles*)
         this.t := o.0
         this.x := (this.x == "") ? o.1                : (this.x < o.1)                ? this.x : o.1
         this.y := (this.y == "") ? o.2                : (this.y < o.2)                ? this.y : o.2
         this.w := (this.w == "") ? o.1 + o.3 - this.x : (this.x + this.w > o.1 + o.3) ? this.w : o.1 + o.3 - this.x
         this.h := (this.h == "") ? o.2 + o.4 - this.y : (this.y + this.h > o.2 + o.4) ? this.h : o.2 + o.4 - this.y
         return this
      }

      Clear() {
         if (this.final) {
            DllCall("QueryPerformanceCounter", "int64*",A_PreciseTime)
            this.PreciseTime := A_PreciseTime
            this.TickCount := A_TickCount
            this.layers := {}
            this.x := this.y := this.w := this.h := "" ; not 0! BROKEN
            Gdip_GraphicsClear(this.gfx)
            this.final := "" ; BROKEN - should be right when final changes.
         }

         return this.UpdateMemory()
      }

      CRC32() {
         return Format("0x{:08x}", DllCall("ntdll.dll\RtlComputeCrc32", "uint",0, "ptr",this.pBits, "uint",this.size, "uint"))
      }

      Finalize() {
         this.final := 1
         VarSetCapacity(puuid, 16, 0)
         if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
            if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
               this.final := StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
         return this
      }

      Output(terms*) {
         this.Draw(terms*)

         if (!this.locked)
            UpdateLayeredWindow(this.hwnd, this.hdc, this.BitmapLeft, this.BitmapTop, this.BitmapWidth, this.BitmapHeight)

         this.Finalize()

         if (this.t > 0) {
            blank := ObjBindMethod(this, "blank")
            time := -1 * this.t
            _blank := (A_AhkVersion < 2) ? blank : "blank"
            _time := (A_AhkVersion < 2) ? time : "time"
            SetTimer %_blank%, %_time%
         }

         return this
      }

      Blank() {
         Gdip_GraphicsClear(this.gfx)
         UpdateLayeredWindow(this.hwnd, this.hdc, this.BitmapLeft, this.BitmapTop, this.BitmapWidth, this.BitmapHeight)
         return this
      }

      Wait(time) {
         wait := time - (A_TickCount - this.TickCount)
         _wait := (A_AhkVersion < 2) ? wait : "wait"
         Sleep %_wait%
         return this
      }

      Bitmap(x := "", y := "", w := "", h := "") {
         x := (x != "") ? x : this.x
         y := (y != "") ? y : this.y
         w := (w != "") ? w : this.w
         h := (h != "") ? h : this.h

         pBitmap := Gdip_CreateBitmap(this.BitmapWidth, this.BitmapHeight)
         pGraphics := Gdip_GraphicsFromImage(pBitmap)
         layers := this.layers.maxIndex()
         _layers := (A_AhkVersion < 2) ? layers : "layers"
         loop %_layers%
            this.DrawRaw(pGraphics, this.BitmapWidth, this.BitmapHeight, this.layers[A_Index].1, this.layers[A_Index].2, this.layers[A_Index].3)
         Gdip_DeleteGraphics(pGraphics)
         pBitmapCopy := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
         Gdip_DisposeImage(pBitmap)
         return pBitmapCopy ; Please dispose of this image responsibly.
      }

      Save(filename := "", quality := 90) {
         filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
                  : (filename != "") ? filename ".png" : this.title ".png"
         pBitmap := this.Bitmap()
         Gdip_SaveBitmapToFile(pBitmap, filename, quality)
         Gdip_DisposeImage(pBitmap)
         return this
      }

      ; 3) Just takes a picture of the screen!
      Screenshot(filename := "", quality := 90) {
         filename := (filename ~= "i)\.(bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)$") ? filename
                  : (filename != "") ? filename ".png" : this.title ".png"
         pBitmap := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.w "|" this.h)
         Gdip_SaveBitmapToFile(pBitmap, filename, quality)
         Gdip_DisposeImage(pBitmap)
         return this
      }

      isDrawable(win := "A") {
         static WM_KEYDOWN := 0x100
         static WM_KEYUP := 0x101
         static vk_to_use := 7
         ; Test whether we can send keystrokes to this window.
         ; Use a virtual keycode which is unlikely to do anything:
         _win := (A_AhkVersion < 2) ? win : "win"
         PostMessage WM_KEYDOWN, vk_to_use, 0,, %_win%
         if !ErrorLevel
         {   ; Seems best to post key-up, in case the window is keeping track.
           PostMessage WM_KEYUP, vk_to_use, 0xC0000000,, %_win%
           return true
         }
         return false
      }

      Show(i := 8) {
         DllCall("ShowWindow", "ptr",this.hwnd, "int",i)
         return this
      }

      Hide() {
         DllCall("ShowWindow", "ptr",this.hwnd, "int",0)
         return this
      }

      Activate() {
         DllCall("ShowWindow", "ptr",this.hwnd, "int",1)
         return this
      }

      isVisible() {
         return DllCall("IsWindowVisible", "ptr",this.hwnd)
      }

      ToggleVisible() {
         return (this.isVisible()) ? this.Hide() : this.Show()
      }
      /*
      AlwaysOnTop(s := -1) {
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         _s := (A_AhkVersion < 2) ? s : "s"
         hwnd := "ahk_id" this.hwnd
         _hwnd := (A_AhkVersion < 2) ? hwnd : "hwnd"
         WinSet AlwaysOnTop, %_s%, %_hwnd%
         DetectHiddenWindows %_dhw%
         return this
      }

      Bottom() {
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         hwnd := "ahk_id" this.hwnd
         _hwnd := (A_AhkVersion < 2) ? hwnd : "hwnd"
         WinSet Bottom,, %_hwnd%
         DetectHiddenWindows %_dhw%
         return this
      }

      ClickThrough(s := -1) {
         s := (s = -1) ? "^" : (s = 0) ? "-" : "+"
         s .= "0x20"
         _s := (A_AhkVersion < 2) ? s : "s"
         _dhw := A_DetectHiddenWindows
         DetectHiddenWindows On
         hwnd := "ahk_id" this.hwnd
         _hwnd := (A_AhkVersion < 2) ? hwnd : "hwnd"
         WinSet ExStyle, %_s%, %_hwnd%
         DetectHiddenWindows %_dhw%
         return this
      }
      */
      Rect() {
         x1 := this.x1(), y1 := this.y1(), x2 := this.x2(), y2 := this.y2()
         return (x2 > x1 && y2 > y1) ? [x1, y1, x2, y2] : ""
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
   }

   class ImageRenderer {
   static extends := "renderer"

      _extends := this.__extends()
      __extends(subbundle := "") {
         object := this.outer[this.extends]
         bundle := ((object.haskey("__extends")) ? object.__extends(true) : object)
         (subbundle) ? (this.base := bundle) : (this.base.base := bundle)
         return (subbundle) ? this : ""
      }

      outer[p:=""] {
         get {
            static period := ".", _period := (A_AhkVersion < 2) ? period : "period"
            if ((__outer := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop Parse, __outer, %_period%
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return IsObject(outer) ? ((p) ? outer[p] : outer) : ((p) ? %p% : "")
         }
      }

      Render(terms*) {
         return (this.hwnd) ? this.Output(terms*) : (new this).Output(terms*)
      }

      ; Types of input accepted
      ; Objects: Rectangle Array (Screenshot)
      ; Strings: File, URL, Window Title (ahk_class...), base64
      ; Numbers: hwnd, GDI Bitmap, GDI HBitmap
      DrawRaw(pGraphics, ScreenWidth, ScreenHeight, image := "", style := "", polygons := "") {
         ; Preprocess image to a native GDI bitmap.
         if (image != "") {
            if !(type := this.DontVerifyImageType(image))
               type := this.ImageType(image)
            pBitmap := this.toBitmap(type, image)
         }

         ; Remove excess whitespace for proper RegEx detection.
         style := !IsObject(style) ? RegExReplace(style, "\s+", " ") : style

         ; RegEx help? https://regex101.com/r/xLzZzO/2
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         ; Extract styles to variables.
         if IsObject(style) {
            t  := (style.time != "")        ? style.time        : style.t
            a  := (style.anchor != "")      ? style.anchor      : style.a
            x  := (style.left != "")        ? style.left        : style.x
            y  := (style.top != "")         ? style.top         : style.y
            w  := (style.width != "")       ? style.width       : style.w
            h  := (style.height != "")      ? style.height      : style.h
            m  := (style.margin != "")      ? style.margin      : style.m
            s  := (style.scale != "")       ? style.scale       : style.s
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
            s  := ((___ := RegExReplace(style, q1    "(s(cale)?)"         q2, "${value}")) != style) ? ___ : ""
            c  := ((___ := RegExReplace(style, q1    "(c(olor)?)"         q2, "${value}")) != style) ? ___ : ""
            q  := ((___ := RegExReplace(style, q1    "(q(uality)?)"       q2, "${value}")) != style) ? ___ : ""
         }

         ; Extract the time variable and save it for a later when we Render() everything.
         static times := "(?i)^\s*(\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
         t  := ( t ~= times) ? RegExReplace( t, "\s", "") : 0 ; Default time is zero.
         t  := ((___ := RegExReplace( t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) !=  t) ? ___ *        1 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) !=  t) ? ___ *     1000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) !=  t) ? ___ *    60000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)h(our)?s?$"               , "$1")) !=  t) ? ___ *  3600000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)d(ay)?s?$"                , "$1")) !=  t) ? ___ * 86400000 : t

         ; These are the type checkers.
         static valid := "(?i)^\s*(\-?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*((?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"

         ; Define viewport width and height. This is the visible screen area.
         vw := 0.01 * ScreenWidth         ; 1% of viewport width.
         vh := 0.01 * ScreenHeight        ; 1% of viewport height.
         vmin := (vw < vh) ? vw : vh      ; 1vw or 1vh, whichever is smaller.
         vr := ScreenWidth / ScreenHeight ; Aspect ratio of the viewport.

         ; Get original image width and height.
         width := Gdip_GetImageWidth(pBitmap)
         height := Gdip_GetImageHeight(pBitmap)
         minimum := (width < height) ? width : height
         aspect := width / height

         ; Get width and height.
         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : ""
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * width :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : ""
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * vmin :  h
         h  := ( h ~= "%$") ? RegExReplace( h, "%$", "") * 0.01 * height :  h

         ; Default width and height.
         if (w == "" && h == "")
            w := width, h := height, wh_unset := true
         if (w == "")
            w := h * aspect
         if (h == "")
            h := w / aspect

         ; If scale is "fill" scale the image until there are no empty spaces but two sides of the image are cut off.
         ; If scale is "fit" scale the image so that the greatest edge will fit with empty borders along one edge.
         ; If scale is "harmonic" automatically downscale by the harmonic series. Ex: 50%, 33%, 25%, 20%...
         if (s = "auto" || s = "fill" || s = "fit" || s = "harmonic" || s = "limit") {
            if (wh_unset == true)
               w := ScreenWidth, h := ScreenHeight
            s := (s = "auto" || s = "limit")
               ? ((aspect > w / h) ? ((width > w) ? w / width : 1) : ((height > h) ? h / height : 1)) : s
            s := (s = "fill") ? ((aspect < w / h) ? w / width : h / height) : s
            s := (s = "fit") ? ((aspect > w / h) ? w / width : h / height) : s
            s := (s = "harmonic") ? ((aspect > w / h) ? 1 / (width // w + 1) : 1 / (height // h + 1)) : s
            w := width  ; width and height given were maximum values, not actual values.
            h := height ; Therefore restore the width and height to the image width and height.
         }

         s  := ( s ~= valid) ? RegExReplace( s, "\s", "") : ""
         s  := ( s ~= "i)(pt|px)$") ? SubStr( s, 1, -2) :  s
         s  := ( s ~= "i)vw$") ? RegExReplace( s, "i)vw$", "") * vw / width :  s
         s  := ( s ~= "i)vh$") ? RegExReplace( s, "i)vh$", "") * vh / height:  s
         s  := ( s ~= "i)vmin$") ? RegExReplace( s, "i)vmin$", "") * vmin / minimum :  s
         s  := ( s ~= "%$") ? RegExReplace( s, "%$", "") * 0.01 :  s

         ; If scale is negative automatically scale by a geometric series constant.
         ; Example: If scale is -0.5, then downscale by 50%, 25%, 12.5%, 6.25%...
         ; What the equation is asking is how many powers of -1/s can we fit in width/w?
         ; Then we use floor division and add 1 to ensure that we never exceed the bounds.
         ; While this is only designed to handle negative scales from 0 to -1.0,
         ; it works for negative numbers higher than -1.0. In this case, the 0 to -1 bounded
         ; are the left adjoint, meaning they never surpass the w and h. Higher negative Numbers
         ; are the right adjoint, meaning they never surpass w*-s and h*-s. Weird, huh.
         ; To clarify: Left adjoint: w*-s to w, h*-s to h. Right adjoint: w to w*-s, h to h*-s
         ; LaTex: \frac{1}{\frac{-1}{s}^{Floor(\frac{log(x)}{log(\frac{-1}{s})}) + 1}}
         ; Vertical asymptote at s := -1, which resolves to the empty string "".
         if (s < 0 && s != "") {
            if (wh_unset == true)
               w := ScreenWidth, h := ScreenHeight
            s := (s < 0) ? ((aspect > w / h)
               ? (-s) ** ((log(width/w) // log(-1/s)) + 1) : (-s) ** ((log(height/h) // log(-1/s)) + 1)) : s
            w := width  ; width and height given were maximum values, not actual values.
            h := height ; Therefore restore the width and height to the image width and height.
         }

         ; Default scale.
         if (s == "") {
            s := (x == "" && y == "" && wh_unset == true)         ; shrink image if x,y,w,h,s are all unset.
               ? ((aspect > vr)                                   ; determine whether width or height exceeds screen.
                  ? ((width > ScreenWidth) ? ScreenWidth / width : 1)       ; scale will downscale image by its width.
                  : ((height > ScreenHeight) ? ScreenHeight / height : 1))  ; scale will downscale image by its height.
               : 1                                                ; Default scale is 1.00.
         }

         ; Scale width and height.
         w  := w * s
         h  := h * s

         ; Get anchor. This is where the origin of the image is located.
         a  := RegExReplace( a, "\s", "")
         a  := (a ~= "i)top" && a ~= "i)left") ? 1 : (a ~= "i)top" && a ~= "i)cent(er|re)") ? 2
            : (a ~= "i)top" && a ~= "i)right") ? 3 : (a ~= "i)cent(er|re)" && a ~= "i)left") ? 4
            : (a ~= "i)cent(er|re)" && a ~= "i)right") ? 6 : (a ~= "i)bottom" && a ~= "i)left") ? 7
            : (a ~= "i)bottom" && a ~= "i)cent(er|re)") ? 8 : (a ~= "i)bottom" && a ~= "i)right") ? 9
            : (a ~= "i)top") ? 2 : (a ~= "i)left") ? 4 : (a ~= "i)right") ? 6 : (a ~= "i)bottom") ? 8
            : (a ~= "i)cent(er|re)") ? 5 : (a ~= "^[1-9]$") ? a : 1 ; Default anchor is top-left.

         ; The anchor can be implied and overwritten by x and y (left, center, right, top, bottom).
         a  := ( x ~= "i)left") ? 1+((( a-1)//3)*3) : ( x ~= "i)cent(er|re)") ? 2+((( a-1)//3)*3) : ( x ~= "i)right") ? 3+((( a-1)//3)*3) :  a
         a  := ( y ~= "i)top") ? 1+(mod( a-1,3)) : ( y ~= "i)cent(er|re)") ? 4+(mod( a-1,3)) : ( y ~= "i)bottom") ? 7+(mod( a-1,3)) :  a

         ; Convert English words to numbers. Don't mess with these values any further.
         x  := ( x ~= "i)left") ? 0 : (x ~= "i)cent(er|re)") ? 0.5*ScreenWidth : (x ~= "i)right") ? ScreenWidth : x
         y  := ( y ~= "i)top") ? 0 : (y ~= "i)cent(er|re)") ? 0.5*ScreenHeight : (y ~= "i)bottom") ? ScreenHeight : y

         ; Get x and y.
         x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : ""
         x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
         x  := ( x ~= "i)(%|vw)$") ? RegExReplace( x, "i)(%|vw)$", "") * vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * vmin :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : ""
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * vw :  y
         y  := ( y ~= "i)(%|vh)$") ? RegExReplace( y, "i)(%|vh)$", "") * vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * vmin :  y

         ; Default x and y.
         if (x == "")
            x := 0.5*ScreenWidth, a := 2+((( a-1)//3)*3)
         if (y == "")
            y := 0.5*ScreenHeight, a := 4+(mod( a-1,3))

         ; Modify x and y values with the anchor, so that the image has a new point of origin.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Prevent half-pixel rendering and keep image sharp.
         w  := Round(x + w) - Round(x)    ; Use real x2 coordinate to determine width.
         h  := Round(y + h) - Round(y)    ; Use real y2 coordinate to determine height.
         x  := Round(x)                   ; NOTE: simple Floor(w) or Round(w) will NOT work.
         y  := Round(y)                   ; The float values need to be added up and then rounded!

         ; Get margin.
         m  := this.outer.parse.margin_and_padding(m, vw, vh)

         ; Calculate border using margin.
         _w := w + Round(m.2) + Round(m.4)
         _h := h + Round(m.1) + Round(m.3)
         _x := x - Round(m.4)
         _y := y - Round(m.1)

         ; Save original Graphics settings.
         DllCall("gdiplus\GdipGetPixelOffsetMode",    "ptr",pGraphics, "int*",PixelOffsetMode)
         DllCall("gdiplus\GdipGetCompositingMode",    "ptr",pGraphics, "int*",CompositingMode)
         DllCall("gdiplus\GdipGetCompositingQuality", "ptr",pGraphics, "int*",CompositingQuality)
         DllCall("gdiplus\GdipGetSmoothingMode",      "ptr",pGraphics, "int*",SmoothingMode)
         DllCall("gdiplus\GdipGetInterpolationMode",  "ptr",pGraphics, "int*",InterpolationMode)

         ; Set some general Graphics settings.
         DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",2) ; Half pixel offset.
         DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",1) ; Overwrite/SourceCopy.
         DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",0) ; AssumeLinear
         DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",0) ; No anti-alias.
         DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",7) ; HighQualityBicubic

         ; Begin drawing the image onto the canvas.
         if (image != "") {

            ; Draw border.
            if (!m.void) {
               DllCall("gdiplus\GdipSetPixelOffsetMode",   "ptr",pGraphics, "int",0) ; No pixel offset.
               DllCall("gdiplus\GdipSetCompositingMode",   "ptr",pGraphics, "int",0) ; Blend/SourceOver.
               DllCall("gdiplus\GdipSetSmoothingMode",     "ptr",pGraphics, "int",0) ; No anti-alias.

               c := this.outer.parse.color(c, 0xFF000000) ; Default color is black.
               pBrush := Gdip_BrushCreateSolid(c)
               DllCall("gdiplus\GdipFillRectangleI"
                        ,    "ptr", pGraphics
                        ,    "ptr", pBrush
                        ,    "int", _x
                        ,    "int", _y
                        ,    "int", _w
                        ,    "int", _h)
               Gdip_DeleteBrush(pBrush)
            }

            ; Draw image.
            if (w == width && h == height) {
               ; Get the device context (hdc) associated with the Graphics object.
               ; Allocate a top-down device independent bitmap (hbm) by inputting a negative height.
               ; Pass the existing device context so that CreateDIBSection can determine the pixel format.
               ; Outputs a pointer to the pixel data. Select the new handle to a bitmap onto the cloned
               ; compatible device context. The old bitmap (obm) is a monochrome 1x1 default bitmap that
               ; will be reselected onto the device context (cdc) before deletion.
               ; The following routine is 4ms faster than hbm := Gdip_CreateHBITMAPFromBitmap(pBitmap).
               hdc := Gdip_GetDC(pGraphics)
               hbm := CreateDIBSection(width, -height, hdc, 32, pBits)
               cdc := CreateCompatibleDC(hdc)
               obm := SelectObject(cdc, hbm)

               ; In the below code we do something really interesting to save a call of memcpy().
               ; When calling LockBits the third argument is set to 0x4 (ImageLockModeUserInputBuf).
               ; This means that we can use the pointer to the bits from our memory bitmap (DIB)
               ; as the Scan0 of the LockBits output. While this is not a speed up, this saves memory
               ; because we are (1) allocating a DIB, (2) getting a pBitmap, (3) using a LockBits buffer.
               ; Instead of (3), we can use the allocated buffer from (1) which makes the most sense.
               ; The bottleneck in the code is LockBits(), which takes over 20 ms for a 1920 x 1080 image.
               ; https://stackoverflow.com/questions/6782489/create-bitmap-from-a-byte-array-of-pixel-data
               ; https://stackoverflow.com/questions/17030264/read-and-write-directly-to-unlocked-bitmap-unmanaged-memory-scan0
               VarSetCapacity(Rect, 16, 0)                ; sizeof(Rect) = 16
                  , NumPut(    width, Rect,  8,   "uint") ; Width
                  , NumPut(   height, Rect, 12,   "uint") ; Height
               VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)       ; sizeof(BitmapData) = 24, 32
                  , NumPut(       width, BitmapData,  0,   "uint") ; Width
                  , NumPut(      height, BitmapData,  4,   "uint") ; Height
                  , NumPut(   4 * width, BitmapData,  8,    "int") ; Stride
                  , NumPut(     0xE200B, BitmapData, 12,    "int") ; PixelFormat
                  , NumPut(       pBits, BitmapData, 16,    "ptr") ; Scan0
               DllCall("gdiplus\GdipBitmapLockBits"
                        ,    "ptr", pBitmap
                        ,    "ptr", &Rect
                        ,   "uint", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
                        ,    "int", 0xE200B      ; Format32bppPArgb
                        ,    "ptr", &BitmapData)
               DllCall("gdiplus\GdipBitmapUnlockBits", "ptr",pBitmap, "ptr",&BitmapData)

               ; A good question to ask is why don't we get the pointer to the bits of the hBitmap already
               ; associated with the hdc? Well we need to set the x,y,w,h coordinates of the resulting transposition;
               ; and if a Graphics object associated to a pBitmap via Gdip_GraphicsFromImage() is passed,
               ; there would be no underlying handle to a device independent bitmap, and thus no pBits at all!
               ; So a buffer is still needed, just not two buffers (read the notes above.)
               BitBlt(hdc, x, y, w, h, cdc, 0, 0) ; BitBlt() is the fastest operation for copying pixels.
               SelectObject(cdc, obm)
               DeleteObject(hbm)
               DeleteDC(cdc)
               Gdip_ReleaseDC(pGraphics, hdc)

            } else {
               ; Set InterpolationMode.
               q := (q >= 0 && q <= 7) ? q : 7    ; HighQualityBicubic

               DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",2) ; Half pixel offset.
               DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",1) ; Overwrite/SourceCopy.
               DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",0) ; No anti-alias.
               DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",q)
               DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",0) ; AssumeLinear

               ; WrapModeTile         = 0
               ; WrapModeTileFlipX    = 1
               ; WrapModeTileFlipY    = 2
               ; WrapModeTileFlipXY   = 3
               ; WrapModeClamp        = 4
               ; Values outside this range downgrades from HighQualityBicubic to something horrible.
               ; Downgrading removes the pre-filtering on the algorithm, and the need for edge cases.
               DllCall("gdiplus\GdipCreateImageAttributes", "ptr*",ImageAttr)
               DllCall("gdiplus\GdipSetImageAttributesWrapMode", "ptr",ImageAttr, "int",3)
               DllCall("gdiplus\GdipDrawImageRectRectI"
                        ,    "ptr", pGraphics
                        ,    "ptr", pBitmap
                        ,    "int", x            ; destination rectangle
                        ,    "int", y
                        ,    "int", w
                        ,    "int", h
                        ,    "int", 0            ; source rectangle
                        ,    "int", 0
                        ,    "int", width
                        ,    "int", height
                        ,    "int", 2
                        ,    "ptr", ImageAttr
                        ,    "ptr", 0
                        ,    "ptr", 0)
               DllCall("gdiplus\GdipDisposeImageAttributes", "ptr",ImageAttr)
            }
         }

         ; Begin drawing the polygons onto the canvas.
         if (polygons != "") {
            DllCall("gdiplus\GdipSetPixelOffsetMode",   "ptr",pGraphics, "int",0) ; No pixel offset.
            DllCall("gdiplus\GdipSetCompositingMode",   "ptr",pGraphics, "int",1) ; Overwrite/SourceCopy.
            DllCall("gdiplus\GdipSetSmoothingMode",     "ptr",pGraphics, "int",2) ; Use anti-alias.

            pPen := Gdip_CreatePen(0xFFFF0000, 1)

            for i, polygon in polygons {
               DllCall("gdiplus\GdipCreatePath", "int",1, "ptr*",pPath)
               VarSetCapacity(pointf, 8*polygons[i].polygon.maxIndex(), 0)
               for j, point in polygons[i].polygon {
                  NumPut(point.x*s + x, pointf, 8*(A_Index-1) + 0, "float")
                  NumPut(point.y*s + y, pointf, 8*(A_Index-1) + 4, "float")
               }
               DllCall("gdiplus\GdipAddPathPolygon", "ptr",pPath, "ptr",&pointf, "uint",polygons[i].polygon.maxIndex())
               DllCall("gdiplus\GdipDrawPath", "ptr",pGraphics, "ptr",pPen, "ptr",pPath) ; DRAWING!
            }

            Gdip_DeletePen(pPen)
         }

         ; Restore original Graphics settings.
         DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",PixelOffsetMode)
         DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",CompositingMode)
         DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",CompositingQuality)
         DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",SmoothingMode)
         DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",InterpolationMode)

         ; Dispose of the pre-processed bitmap.
         if (type != "pBitmap")
            Gdip_DisposeImage(pBitmap)

         ; Define bounds.
         t_bound :=  t
         x_bound := _x
         y_bound := _y
         w_bound := _w
         h_bound := _h

         return {0:t_bound, 1:x_bound, 2:y_bound, 3:w_bound, 4:h_bound}
      }

      Preprocess(cotype, image, crop := "", scale := "", terms*) {
         if (!this.hwnd) {
            _renderer := new this(RegExReplace(A_ThisFunc, "^.*(^|\.)(.*?\..*?)$", "$2"))
            _renderer.title := _renderer.title "_" _renderer.hwnd
            DllCall("SetWindowText", "ptr",_renderer.hwnd, "str",_renderer.title)
            fn := RegExReplace(A_ThisFunc, "^.*(^|\.)(.*)$", "$2")
            coimage := _renderer[fn](cotype, image, crop, scale, terms*)
            _renderer.FreeMemory()
            _renderer := ""
            return coimage
         }

         ; Determine the representation (type) of the input image.
         if !(type := this.DontVerifyImageType(image))
            type := this.ImageType(image)
         ; If the type and cotype match, do nothing.
         if (type = cotype && !this.isCropArray(crop) && !(scale ~= "^\d+(\.\d+)?$" && scale != 1))
            return image
         ; Convert the image to a pBitmap (byte array).
         pBitmap := this.toBitmap(type, image)
         ; Crop the image, disposing if type is not pBitmap.
         if this.isCropArray(crop){
            pBitmap2 := this.Gdip_CropBitmap(pBitmap, crop)
            if !(type = "pBitmap" || type = "bitmap")
               Gdip_DisposeImage(pBitmap)
            pBitmap := pBitmap2
         }
         ; Scale the image, disposing if type is not pBitmap.
         if (scale ~= "^\d+(\.\d+)?$" && scale != 1) {
            pBitmap2 := this.Gdip_ScaleBitmap(pBitmap, scale)
            if !(type = "pBitmap" || type = "bitmap" && !this.isCropArray(crop))
               Gdip_DisposeImage(pBitmap)
            pBitmap := pBitmap2
         }
         ; Convert from the pBitmap intermediate to the desired representation.
         coimage := this.toCotype(cotype, pBitmap, terms*)
         ; Delete the pBitmap intermediate, unless the input/output is pBitmap.
         if !(cotype = "pBitmap" || cotype = "bitmap"
            || ((type = "pBitmap" || type = "bitmap")
               && !this.isCropArray(crop) && !(scale ~= "^\d+(\.\d+)?$" && scale != 1)))
                  Gdip_DisposeImage(pBitmap)
         return coimage
      }

      Equal(images*) {
         if (images.Count() == 0)
            return false

         if (images.Count() == 1)
            return true

         ; Activate gdip basically LOL.
         if (!this.hwnd) {
            _renderer := new this(RegExReplace(A_ThisFunc, "^.*(^|\.)(.*?\..*?)$", "$2"))
            _renderer.title := _renderer.title "_" _renderer.hwnd
            DllCall("SetWindowText", "ptr",_renderer.hwnd, "str",_renderer.title)
            fn := RegExReplace(A_ThisFunc, "^.*(^|\.)(.*)$", "$2")
            answer := _renderer[fn](images*)
            _renderer.FreeMemory()
            _renderer := ""
            return answer
         }

         ; Convert the images to pBitmaps (byte arrays).
         for i, image in images {
            if !(type := this.DontVerifyImageType(image))
               try type := this.ImageType(image)
               catch
                  return false

            if (A_Index == 1) {
               pBitmap1 := this.toBitmap(type, image)
               cleanup := type
            } else {
               pBitmap2 := this.toBitmap(type, image)
               result := this.isBitmapEqual(pBitmap1, pBitmap2)
               (type != "pBitmap") ? Gdip_DisposeImage(pBitmap2) : ""
               if (result)
                  continue
               else
                  return false
            }
         }

         if (cleanup = "pBitmap")
            Gdip_DisposeImage(pBitmap1)

         return true
      }

      DontVerifyImageType(ByRef image) {
         ; Check for image type declaration.
         if !IsObject(image)
            return

         if ObjHasKey(image, "screen") {
            image := image.screen
            return "screen"
         }

         if ObjHasKey(image, "clipboard") {
            image := image.clipboard
            return "clipboard"
         }

         if ObjHasKey(image, "object") {
            image := image.object
            return "object"
         }

         if ObjHasKey(image, "bitmap") {
            image := image.bitmap
            return "bitmap"
         }

         if ObjHasKey(image, "screenshot") {
            image := image.screenshot
            return "screenshot"
         }

         if ObjHasKey(image, "file") {
            image := image.file
            return "file"
         }

         if ObjHasKey(image, "url") {
            image := image.url
            return "url"
         }

         if ObjHasKey(image, "window") {
            image := image.window
            return "window"
         }

         if ObjHasKey(image, "hwnd") {
            image := image.hwnd
            return "hwnd"
         }

         if ObjHasKey(image, "pBitmap") {
            image := image.pBitmap
            return "pBitmap"
         }

         if ObjHasKey(image, "hBitmap") {
            image := image.hBitmap
            return "hBitmap"
         }

         if ObjHasKey(image, "base64") {
            image := image.base64
            return "base64"
         }

         return
      }

      ImageType(image) {
         ; Check if image refers to the clipboard.
         if this.isClipboard(image)
            return "clipboard"
         ; Check if image is empty string.
         if (image == "")
            throw Exception("Image data is empty string.")
         ; Check if image is an object with a Bitmap() method.
         if IsObject(image) and IsFunc(image.Bitmap)
            return "object"
         ; Check if image is an instance of safe_bitmap.
         if IsObject(image) and (image.__class = "safe_bitmap")
            return "bitmap"
         ; Check if image is an array of 4 numbers.
         if IsObject(image) and (image.1 ~= "^\d+$" && image.2 ~= "^\d+$" && image.3 ~= "^\d+$" && image.4 ~= "^\d+$")
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
         if (DllCall("gdiplus\GdipGetImageType", "ptr",image, "ptr*",ErrorLevel) == 0)
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
         if (type = "object")
            return image.Bitmap()

         if (type = "bitmap")
            return image[]

         if (type = "clipboard") {
            if DllCall("OpenClipboard", "ptr", 0) {
               hBitmap := DllCall("GetClipboardData", "uint", 2, "ptr")
               DllCall("CloseClipboard")
               pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)
               DeleteObject(hBitmap)
            }
            return pBitmap
         }

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
            BitBlt(chdc, 0, 0, image.3, image.4, hhdc, image.1, image.2, Raster := "")
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
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "ptr*",pBitmap)
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

         if (type = "hBitmap") {
            ; struct BITMAP - https://docs.microsoft.com/en-us/windows/desktop/api/wingdi/ns-wingdi-tagbitmap
            DllCall("GetObject"
                     ,    "ptr", image
                     ,    "int", VarSetCapacity(dib, 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize)
                     ,    "ptr", &dib) ; sizeof(DIBSECTION) = 84, 104
            width  := NumGet(dib, 4, "uint")
            height := NumGet(dib, 8, "uint")
            bpp    := NumGet(dib, 18, "ushort")

            ; Fallback to built-in method if pixels are not ARGB.
            if (bpp != 32)
               return Gdip_CreateBitmapFromHBITMAP(image)

            ; Create a handle to a device context and associate the image.
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, image)

            ; Buffer the image with a top-down device independent bitmap via negative height.
            ; Note that a DIB is an hBitmap, pixels are formatted as pARGB, and has a pointer to the bits.
            cdc := CreateCompatibleDC(hdc)
            hbm := CreateDIBSection(width, -height, cdc, 32, pBits)
            ob2 := SelectObject(cdc, hbm)

            ; Create a new Bitmap (different from an hBitmap) which holds ARGB pixel values.
            pBitmap := Gdip_CreateBitmap(width, height)

            ; Create a Scan0 buffer pointing to pBits. The buffer has pixel format pARGB.
            VarSetCapacity(Rect, 16, 0)                ; sizeof(Rect) = 16
               , NumPut(    width, Rect,  8,   "uint") ; Width
               , NumPut(   height, Rect, 12,   "uint") ; Height
            VarSetCapacity(BitmapData, 16+2*A_PtrSize, 0)       ; sizeof(BitmapData) = 24, 32
               , NumPut(       width, BitmapData,  0,   "uint") ; Width
               , NumPut(      height, BitmapData,  4,   "uint") ; Height
               , NumPut(   4 * width, BitmapData,  8,    "int") ; Stride
               , NumPut(     0xE200B, BitmapData, 12,    "int") ; PixelFormat
               , NumPut(       pBits, BitmapData, 16,    "ptr") ; Scan0
            DllCall("gdiplus\GdipBitmapLockBits"
                     ,    "ptr", pBitmap
                     ,    "ptr", &Rect
                     ,   "uint", 7            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadWrite
                     ,    "int", 0xE200B      ; Format32bppPArgb
                     ,    "ptr", &BitmapData)

            ; Ensure that our hBitmap (image) is top-down by copying it to a top-down bitmap.
            BitBlt(cdc, 0, 0, width, height, hdc, 0, 0)

            ; Convert the pARGB pixels copied into the device independent bitmap (hbm) to ARGB.
            DllCall("gdiplus\GdipBitmapUnlockBits", "ptr",pBitmap, "ptr",&BitmapData)

            ; Cleanup the buffer and device contexts.
            SelectObject(cdc, ob2)
            DeleteObject(hbm)
            DeleteDC(cdc)
            SelectObject(hdc, obm)
            DeleteDC(hdc)

            return pBitmap
         }

         if (type = "base64") {
            image := Trim(image)
            image := RegExReplace(image, "^data:image\/[a-z]+;base64,", "")
            DllCall("crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), "ptr",&image, "uint",0, "uint",1, "ptr",0, "uint*",nSize, "ptr",0, "ptr",0)
            VarSetCapacity(bin, nSize, 0)
            DllCall("crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), "ptr",&image, "uint",0, "uint",1, "ptr",&bin, "uint*",nSize, "ptr",0, "ptr",0)
            hData := DllCall("GlobalAlloc", "uint",0x2, "ptr",nSize)
            pData := DllCall("GlobalLock", "ptr",hData)
            DllCall("RtlMoveMemory", "ptr",pData, "ptr",&bin, "uptr",nSize)
            DllCall("ole32\CreateStreamOnHGlobal", "ptr",hData, "int",false, "ptr*",pStream)
            DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr",pStream, "ptr*",pBitmap)
            pBitmap2 := Gdip_CloneBitmapArea(pBitmap, 0, 0, Gdip_GetImageWidth(pBitmap), Gdip_GetImageHeight(pBitmap))
            Gdip_DisposeImage(pBitmap)
            ObjRelease(pStream)
            DllCall("GlobalUnlock", "ptr",hData)
            DllCall("GlobalFree", "ptr",hData) ; Will delete the original bitmap if not cloned.
            return pBitmap2
         }
      }

      toCotype(cotype, pBitmap, terms*) {
         ; toCotype("clipboard", pBitmap)
         if (cotype = "clipboard") {
            off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
            hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
            DllCall("GetObject", "ptr", hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), "ptr", &oi)
            hdib := DllCall("GlobalAlloc", "uint", 2, "ptr", 40+NumGet(oi, off1, "uint"), "ptr")
            pdib := DllCall("GlobalLock", "ptr", hdib, "ptr")
            DllCall("RtlMoveMemory", "ptr", pdib, "ptr", &oi+off2, "uptr", 40)
            DllCall("RtlMoveMemory", "ptr", pdib+40, "ptr", NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), "ptr"), "uptr", NumGet(oi, off1, "uint"))
            DllCall("GlobalUnlock", "ptr", hdib)
            DllCall("DeleteObject", "ptr", hBitmap)

            DllCall("OpenClipboard", "ptr", 0)
            DllCall("EmptyClipboard")
            DllCall("SetClipboardData", "uint", 8, "ptr", hdib)
            DllCall("CloseClipboard")
         }

         ; toCotype("bitmap", pBitmap)
         if (cotype = "bitmap") {
            return new this.outer.safe_bitmap(pBitmap)
         }

         ; toCotype("screenshot", pBitmap, style)
         if (cotype = "screenshot") {
            renderer := this.Render({"pBitmap":pBitmap}, terms.1)
            return [renderer.x1(), renderer.y1(), renderer.width(), renderer.height()]
         }

         ; toCotype("file", pBitmap, filename, quality)
         if (cotype = "file") {
            filename := (terms.1) ? terms.1 : this.title ".png"
            Gdip_SaveBitmapToFile(pBitmap, filename, terms.2)
            return filename
         }

         ; toCotype("url", ????????????????????????
         if (cotype = "url") {
            ; make a url
         }

         ; toCotype("window", pBitmap)
         if (cotype = "window")
            return "ahk_id " . this.Render({"pBitmap":pBitmap}).AlwaysOnTop().ToolWindow().Caption().hwnd

         ; toCotype("hwnd", pBitmap)
         if (cotype = "hwnd")
            return this.Render({"pBitmap":pBitmap}).hwnd

         ; toCotype("pBitmap", pBitmap)
         if (cotype = "pBitmap")
            return pBitmap

         ; toCotype("hBitmap", pBitmap, alpha)
         if (cotype = "hBitmap")
            return Gdip_CreateHBITMAPFromBitmap(pBitmap, terms.1)

         ; toCotype("base64", pBitmap, extension, quality)
         if (cotype = "base64") { ; Thanks to noname.
            if !(terms.1 ~= "(?i)bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png")
               terms.1 := "png"
            Extension := "." terms.1

            Quality := terms.2

            DllCall("gdiplus\GdipGetImageEncodersSize", "uint*",nCount, "uint*",nSize)
            VarSetCapacity(ci, nSize)
            DllCall("gdiplus\GdipGetImageEncoders", "uint",nCount, "uint",nSize, "ptr",&ci)
            if !(nCount && nSize)
               throw Exception("Could not get a list of image codec encoders on this system.")

            _nCount := (A_AhkVersion < 2) ? nCount : "nCount"
            Loop %_nCount%
            {
               sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
               if InStr(sString, "*" Extension)
                  break
            }

            if !(pCodec := &ci+idx)
               throw Exception("Could not find matching encoder for specified file format.")

            if RegExMatch(Extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$")
            {
               Quality := (Quality < 0) ? 0 : (Quality > 100) ? 90 : Quality ; Default JPEG is 90.
               DllCall("gdiplus\GdipGetEncoderParameterListSize", "ptr",pBitmap, "ptr",pCodec, "uint*",nSize)
               VarSetCapacity(EncoderParameters, nSize, 0)
               DllCall("gdiplus\GdipGetEncoderParameterList", "ptr",pBitmap, "ptr",pCodec, "uint",nSize, "ptr",&EncoderParameters)
               nCount := NumGet(EncoderParameters, "uint")
      			N := (A_AhkVersion < 2) ? nCount : "nCount"
      			Loop %N%
               {
                  elem := (24+A_PtrSize)*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
                  if (NumGet(EncoderParameters, elem+16, "uint") = 1) && (NumGet(EncoderParameters, elem+20, "uint") = 6)
                  {
                     p := elem+&EncoderParameters-pad-4
                     NumPut(Quality, NumGet(NumPut(4, NumPut(1, p+0)+20, "uint")), "uint")
                     break
                  }
               }
            }

            DllCall("ole32\CreateStreamOnHGlobal", "ptr",0, "int",true, "ptr*",pStream)
            DllCall("gdiplus\GdipSaveImageToStream", "ptr",pBitmap, "ptr",pStream, "ptr",pCodec, "uint",p ? p : 0)
            DllCall("ole32\GetHGlobalFromStream", "ptr",pStream, "uint*",hData)
            pData := DllCall("GlobalLock", "ptr",hData, "ptr")
            nSize := DllCall("GlobalSize", "uint",pData)

            VarSetCapacity(bin, nSize, 0)
            DllCall("RtlMoveMemory", "ptr",&bin, "ptr",pData, "uptr",nSize)
            DllCall("GlobalUnlock", "ptr",hData)
            ObjRelease(pStream)
            DllCall("GlobalFree", "ptr",hData)

            ; Using CryptBinaryToStringA saves about 2MB in memory.
            DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",0, "uint*",base64Length)
            VarSetCapacity(base64, base64Length, 0)
            DllCall("Crypt32.dll\CryptBinaryToStringA", "ptr",&bin, "uint",nSize, "uint",0x40000001, "ptr",&base64, "uint*",base64Length)
            VarSetCapacity(bin, 0)

            return StrGet(&base64, base64Length, "CP0")
         }
      }

      Gdip_CropBitmap(pBitmap, crop, width:="", height:="") {
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

         ; Match image dimensions. De Morgan's rules!
         if !(pBitmap1_width == pBitmap2_width && pBitmap1_height == pBitmap2_height)
            return false

         ; Find smaller width and height to match bytes.
         ; Sort of unnecessary due to the above statement, but nice to have.
         width := (pBitmap1_width < pBitmap2_width) ? pBitmap1_width : pBitmap2_width
         height := (pBitmap1_height < pBitmap2_height) ? pBitmap1_height : pBitmap2_height
         E1 := Gdip_LockBits(pBitmap1, 0, 0, width, height, Stride1, Scan01, BitmapData1)
         E2 := Gdip_LockBits(pBitmap2, 0, 0, width, height, Stride2, Scan02, BitmapData2)

         ; RtlCompareMemory preforms an unsafe comparison stopping at the first different byte.
         size := width * height * 4  ; ARGB = 4 bytes
         byte := DllCall("ntdll\RtlCompareMemory", "ptr", Scan01+0, "ptr", Scan02+0, "uptr", size)

         Gdip_UnlockBits(pBitmap1, BitmapData1)
         Gdip_UnlockBits(pBitmap2, BitmapData2)
         return (byte == size) ? true : false
      }

      isClipboard(var) {
         if !(var == ClipboardAll)
            return false

         if DllCall("OpenClipboard", "ptr", 0) {
            _answer := DllCall("IsClipboardFormatAvailable", "uint", 8)
            DllCall("CloseClipboard")
            if (_answer)
               return true
            else ; throw because (ClipboardAll == "") throws in the next line.
               throw Exception("Clipboard does not contain compatible image data.")
         }
      }

      isCropArray(array) {
         if (array.length() != 4)
            return false
         for index, value in array
            if !(value ~= "^\-?\d+(?:\.\d*)?%?$")
               return false
         return true
      }

      isURL(url) {
         regex .= "((https?|ftp)\:\/\/)" ; SCHEME
         regex .= "([a-z0-9+!*(),;?&=\$_.-]+(\:[a-z0-9+!*(),;?&=\$_.-]+)?@)?" ; User and Pass
         regex .= "([a-z0-9-.]*)\.([a-z]{2,3})" ; Host or IP
         regex .= "(\:[0-9]{2,5})?" ; Port
         regex .= "(\/([a-z0-9+\$_-]\.?)+)*\/?" ; Path
         regex .= "(\?[a-z+&\$_.-][a-z0-9;:@&%=+\/\$_.-]*)?" ; GET Query
         regex .= "(#[a-z_.-][a-z0-9+\$_.-]*)?" ; Anchor

         return (url ~= "i)" regex) ? true : false
      }
   } ; End of ImageRenderer class.

   class PolygonRenderer {
   static extends := "renderer"

      _extends := this.__extends()
      __extends(subbundle := "") {
         object := this.outer[this.extends]
         bundle := ((object.haskey("__extends")) ? object.__extends(true) : object)
         (subbundle) ? (this.base := bundle) : (this.base.base := bundle)
         return (subbundle) ? this : ""
      }

      outer[p:=""] {
         get {
            static period := ".", _period := (A_AhkVersion < 2) ? period : "period"
            if ((__outer := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop Parse, __outer, %_period%
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return IsObject(outer) ? ((p) ? outer[p] : outer) : ((p) ? %p% : "")
         }
      }

      activateOnAdmin := true, ScreenWidth := A_ScreenWidth, ScreenHeight := A_ScreenHeight

      __New(title := "", terms*) {
         global pToken
         if !(this.outer.Startup())
            if !(pToken)
               if !(this.pToken := Gdip_Startup())
                  throw Exception("Gdiplus failed to start. Please ensure you have gdiplus on your system.")

         this.CreateWindow()

         this.__screen := new this.outer.memory(this.ScreenWidth, this.ScreenHeight)
         this.state := new this.outer.queue()
         return this
      }

      Destroy() {
         Gdip_DeleteGraphics(this.gfx)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
         this.gfx := this.obm := this.pBits := this.hbm := this.hdc := ""

         this.__screen := ""
         DllCall("DestroyWindow", "ptr",this.hwnd)
         return this
      }

      Render(terms*) {
         if !(this.hwnd)
            return (new this).Render(terms*)

         this.state.new(A_ThisFunc)

         Gdip_GraphicsClear(this.__screen.gfx)

         this.UpdateMemory()
         this.Draw(terms*)

         UpdateLayeredWindow(this.hwnd, this.hdc, 0, 0, this.ScreenWidth, this.ScreenHeight)

         if (this.t) {
            self_destruct := ObjBindMethod(this, "Destroy")
            time := -1 * this.t
            _self_destruct := (A_AhkVersion < 2) ? self_destruct : "self_destruct"
            _time := (A_AhkVersion < 2) ? time : "time"
            SetTimer %_self_destruct%, %_time%
         }

         ; Shift the layers.
         this.state.layers.RemoveAt(1)
         this.state.layers.2 := []

         return this
      }

      Redraw(x, y, w, h) {
         ;this.UpdateMemory()
         Gdip_SetSmoothingMode(this.__screen.gfx, 4) ;Adds one clickable pixel to the edge.
         pBrush := Gdip_BrushCreateSolid(this.color)

         if (this.cache = 0) {
            Gdip_GraphicsClear(this.__screen.gfx)
            Gdip_FillRectangle(this.__screen.gfx, pBrush, x, y, w, h)
         }
         if (this.cache = 1) {
            if (!this.state.identical)
               this.__cache := ""

            if (!this.__cache) {
               this.__cache := new this.outer.memory(w + 1, h + 1)
               Gdip_FillRectangle(this.__cache.gfx, pBrush, 0, 0, w, h)
            }

            Gdip_GraphicsClear(this.__screen.gfx)
            BitBlt(this.__screen.hdc, x, y, w + 1, h + 1, this.__cache.hdc, 0, 0)
         }
         if (this.cache = 2) {
            if (!this.state.identical)
               this.__cache := ""

            if (!this.__cache) {
               this.__cache := new this.outer.memory(w + 1, h + 1)
               Gdip_FillRectangle(this.__cache.gfx, pBrush, 0, 0, w, h)
            }

            Gdip_GraphicsClear(this.__screen.gfx)
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

      Draw(color := "", style := "") {

         ; Note that only the second layer is drawn on. The first layer is the reference layer.
         if (pGraphics == "") {
            if (!this.state.layers.2.MaxIndex())
               this.__buffer := new this.outer.memory(this.ScreenWidth, this.ScreenHeight)
            pGraphics := this.__buffer.gfx
         }


         ; Retrieve last style if omitted. Reduce all whitespace to one space character.
         style := !IsObject(style) ? RegExReplace(style, "\s+", " ") : style
         style := (style == "") ? this.state.layers.2[this.state.layers.2.MaxIndex()].2 : style
         this.state.layers.2.push([color, style, empty])



         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         if IsObject(style) {
            t  := (style.time != "")        ? style.time        : style.t
            x  := (style.left != "")        ? style.left        : style.x
            y  := (style.top != "")         ? style.top         : style.y
            w  := (style.width != "")       ? style.width       : style.w
            h  := (style.height != "")      ? style.height      : style.h
            a  := (style.anchor != "")      ? style.anchor      : style.a
            m  := (style.margin != "")      ? style.margin      : style.m
            s  := (style.size != "")        ? style.size        : style.s
            c  := (style.color != "")       ? style.color       : style.c
            q  := (style.quality != "")     ? style.quality     : (style.q) ? style.q : style.InterpolationMode
         } else {
            t  := ((___ := RegExReplace(style, q1    "(t(ime)?)"          q2, "${value}")) != style) ? ___ : ""
            x  := ((___ := RegExReplace(style, q1    "(x|left)"           q2, "${value}")) != style) ? ___ : ""
            y  := ((___ := RegExReplace(style, q1    "(y|top)"            q2, "${value}")) != style) ? ___ : ""
            w  := ((___ := RegExReplace(style, q1    "(w(idth)?)"         q2, "${value}")) != style) ? ___ : ""
            h  := ((___ := RegExReplace(style, q1    "(h(eight)?)"        q2, "${value}")) != style) ? ___ : ""
            a  := ((___ := RegExReplace(style, q1    "(a(nchor)?)"        q2, "${value}")) != style) ? ___ : ""
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

         static valid := "(?i)^\s*(\-?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*((?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"

         vw := 0.01 * this.ScreenWidth    ; 1% of viewport width.
         vh := 0.01 * this.ScreenHeight   ; 1% of viewport height.
         vmin := (vw < vh) ? vw : vh ; 1vw or 1vh, whichever is smaller.

         ; Default = 0, LowQuality = 1, HighQuality = 2, Bilinear = 3
         ; Bicubic = 4, NearestNeighbor = 5, HighQualityBilinear = 6, HighQualityBicubic = 7
         q := (q >= 0 && q <= 7) ? q : 7       ; Default InterpolationMode is HighQualityBicubic.
         Gdip_SetInterpolationMode(pGraphics, q)

         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : width ; Default width is image width.
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * width :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : height ; Default height is image height.
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * vmin :  h
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
         s  := ( s ~= "i)vw$") ? RegExReplace( s, "i)vw$", "") * vw / width :  s
         s  := ( s ~= "i)vh$") ? RegExReplace( s, "i)vh$", "") * vh / height:  s
         s  := ( s ~= "i)vmin$") ? RegExReplace( s, "i)vmin$", "") * vmin / minimum :  s
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
         x  := ( x ~= "i)(%|vw)$") ? RegExReplace( x, "i)(%|vw)$", "") * vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * vmin :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : 0 ; Default y is 0.
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * vw :  y
         y  := ( y ~= "i)(%|vh)$") ? RegExReplace( y, "i)(%|vh)$", "") * vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * vmin :  y

         ; Modify x and y values with the anchor, so that the image has a new point of origin.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Prevent half-pixel rendering and keep image sharp.
         x := Floor(x)
         y := Floor(y)

         m := this.outer.parse.margin_and_padding(m, vw, vh)

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
            c := this.outer.parse.color(c, 0xFF000000) ; Default color is black.
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
            DllCall("gdiplus\GdipCreatePath", "int",1, "ptr*",pPath)
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

      MouseGetPos(ByRef x_mouse, ByRef y_mouse) {
         _cmm := A_CoordModeMouse
         CoordMode Mouse, Screen
         MouseGetPos x_mouse, y_mouse
         CoordMode Mouse, %_cmm%
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
            ;stabilize x/y coordinates in window spy.

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

      Recover() {
         Gdip_SetSmoothingMode(this.gfx, 4)
         return this
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
   } ; End of PolygonRenderer class.

   class TextRenderer {
   static extends := "renderer"

      _extends := this.__extends()
      __extends(subbundle := "") {
         object := this.outer[this.extends]
         bundle := ((object.haskey("__extends")) ? object.__extends(true) : object)
         (subbundle) ? (this.base := bundle) : (this.base.base := bundle)
         return (subbundle) ? this : ""
      }

      outer[p:=""] {
         get {
            static period := ".", _period := (A_AhkVersion < 2) ? period : "period"
            if ((__outer := RegExReplace(this.__class, "^(.*)\..*$", "$1")) != this.__class)
               Loop Parse, __outer, %_period%
                  outer := (A_Index=1) ? %A_LoopField% : outer[A_LoopField]
            return IsObject(outer) ? ((p) ? outer[p] : outer) : ((p) ? %p% : "")
         }
      }

      Render(terms*) {
         return (this.hwnd) ? this.Output(terms*) : (new this).Output(terms*)
      }

      DrawRaw(pGraphics, ScreenWidth, ScreenHeight, text := "", style1 := "", style2 := "") {
         ; Remove excess whitespace for proper RegEx detection.
         style1 := !IsObject(style1) ? RegExReplace(style1, "\s+", " ") : style1
         style2 := !IsObject(style2) ? RegExReplace(style2, "\s+", " ") : style2

         ; RegEx help? https://regex101.com/r/xLzZzO/2
         static q1 := "(?i)^.*?\b(?<!:|:\s)\b"
         static q2 := "(?!(?>\([^()]*\)|[^()]*)*\))(:\s*)?\(?(?<value>(?<=\()([\s:#%_a-z\-\.\d]+|\([\s:#%_a-z\-\.\d]*\))*(?=\))|[#%_a-z\-\.\d]+).*$"

         ; Extract styles to variables.
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
            _q  := ((___ := RegExReplace(style1, q1    "(q(uality)?)"       q2, "${value}")) != style1) ? ___ : ""
         }

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

         ; Extract the time variable and save it for a later when we Render() everything.
         static times := "(?i)^\s*(\d+)\s*(ms|mil(li(second)?)?|s(ec(ond)?)?|m(in(ute)?)?|h(our)?|d(ay)?)?s?\s*$"
         t  := (_t) ? _t : t
         t  := ( t ~= times) ? RegExReplace( t, "\s", "") : 0 ; Default time is zero.
         t  := ((___ := RegExReplace( t, "i)(\d+)(ms|mil(li(second)?)?)s?$", "$1")) !=  t) ? ___ *        1 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)s(ec(ond)?)?s?$"          , "$1")) !=  t) ? ___ *     1000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)m(in(ute)?)?s?$"          , "$1")) !=  t) ? ___ *    60000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)h(our)?s?$"               , "$1")) !=  t) ? ___ *  3600000 : t
         t  := ((___ := RegExReplace( t, "i)(\d+)d(ay)?s?$"                , "$1")) !=  t) ? ___ * 86400000 : t

         ; These are the type checkers.
         static valid := "(?i)^\s*(\-?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"
         static valid_positive := "(?i)^\s*((?:(?:\d+(?:\.\d*)?)|(?:\.\d+)))\s*(%|pt|px|vh|vmin|vw)?\s*$"

         ; Define viewport width and height. This is the visible screen area.
         vw := 0.01 * ScreenWidth         ; 1% of viewport width.
         vh := 0.01 * ScreenHeight        ; 1% of viewport height.
         vmin := (vw < vh) ? vw : vh      ; 1vw or 1vh, whichever is smaller.
         vr := ScreenWidth / ScreenHeight ; Aspect ratio of the viewport.

         ; Get background width and height.
         _w := (_w ~= valid_positive) ? RegExReplace(_w, "\s", "") : ""
         _w := (_w ~= "i)(pt|px)$") ? SubStr(_w, 1, -2) : _w
         _w := (_w ~= "i)(%|vw)$") ? RegExReplace(_w, "i)(%|vw)$", "") * vw : _w
         _w := (_w ~= "i)vh$") ? RegExReplace(_w, "i)vh$", "") * vh : _w
         _w := (_w ~= "i)vmin$") ? RegExReplace(_w, "i)vmin$", "") * vmin : _w

         _h := (_h ~= valid_positive) ? RegExReplace(_h, "\s", "") : ""
         _h := (_h ~= "i)(pt|px)$") ? SubStr(_h, 1, -2) : _h
         _h := (_h ~= "i)vw$") ? RegExReplace(_h, "i)vw$", "") * vw : _h
         _h := (_h ~= "i)(%|vh)$") ? RegExReplace(_h, "i)(%|vh)$", "") * vh : _h
         _h := (_h ~= "i)vmin$") ? RegExReplace(_h, "i)vmin$", "") * vmin : _h

         ; Save original Graphics settings.
         DllCall("gdiplus\GdipGetPixelOffsetMode",    "ptr",pGraphics, "int*",PixelOffsetMode)
         DllCall("gdiplus\GdipGetCompositingMode",    "ptr",pGraphics, "int*",CompositingMode)
         DllCall("gdiplus\GdipGetCompositingQuality", "ptr",pGraphics, "int*",CompositingQuality)
         DllCall("gdiplus\GdipGetSmoothingMode",      "ptr",pGraphics, "int*",SmoothingMode)
         DllCall("gdiplus\GdipGetInterpolationMode",  "ptr",pGraphics, "int*",InterpolationMode)
         DllCall("gdiplus\GdipGetTextRenderingHint",  "ptr",pGraphics, "int*",TextRenderingHint)

         ; Get Rendering Quality.
         _q := (_q >= 0 && _q <= 4) ? _q : 4          ; Default SmoothingMode is 4 if radius is set. See Draw 1.
         q  := (q >= 0 && q <= 5) ? q : 4             ; Default TextRenderingHint is 4 (antialias).
                                                      ; Anti-Alias = 4, Cleartype = 5 (and gives weird effects.)

         ; Set Graphics settings.
         DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",2) ; Half pixel offset.
         ;DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",1) ; Overwrite/SourceCopy.
         DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",0) ; AssumeLinear
         DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",_q)
         DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",7) ; HighQualityBicubic
         DllCall("gdiplus\GdipSetTextRenderingHint",  "ptr",pGraphics, "int",q)

         ; Get Font size.
         s  := (s ~= valid_positive) ? RegExReplace(s, "\s", "") : "2.23vh"          ; Default font size is 2.23vh.
         s  := (s ~= "i)(pt|px)$") ? SubStr(s, 1, -2) : s                            ; Strip spaces, px, and pt.
         s  := (s ~= "i)vh$") ? RegExReplace(s, "i)vh$", "") * vh : s                ; Relative to viewport height.
         s  := (s ~= "i)vw$") ? RegExReplace(s, "i)vw$", "") * vw : s                ; Relative to viewport width.
         s  := (s ~= "i)(%|vmin)$") ? RegExReplace(s, "i)(%|vmin)$", "") * vmin : s  ; Relative to viewport minimum.

         ; Get Bold, Italic, Underline, NoWrap, and Justification of text.
         style := (b) ? 1 : 0         ; bold
         style += (i) ? 2 : 0         ; italic
         style += (u) ? 4 : 0         ; underline
         style += (strikeout) ? 8 : 0 ; strikeout, not implemented.
         n  := (n) ? 0x4000 | 0x1000 : 0x4000
         j  := (j ~= "i)cent(er|re)") ? 1 : (j ~= "i)(far|right)") ? 2 : 0   ; Left/near, center/centre, far/right.

         ; Later when text x and w are finalized and it is found that x + width exceeds the screen,
         ; then the _redrawBecauseOfCondensedFont flag is set to true.
         static _redrawBecauseOfCondensedFont
         if (_redrawBecauseOfCondensedFont == true)
            f:=z, z:=0, _redrawBecauseOfCondensedFont := false

         ; Create Font.
         f := (f) ? f : "Arial"  ; Default font is Arial.
         hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial") ; Default font is Arial.
         hFont := Gdip_FontCreate(hFamily, s, style)
         hFormat := Gdip_StringFormatCreate(n)
         Gdip_SetStringFormatAlign(hFormat, j)  ; Left = 0, Center = 1, Right = 2

         ; Simulate string width and height. This will get the exact width and height of the text.
         VarSetCapacity(RectF, 16, 0)       ; sizeof(RectF) = 16
         if (_w != "")
            NumPut(_w, RectF,  8,  "float") ; Width
         if (_h != "")
            NumPut(_h, RectF, 12,  "float") ; Height
         DllCall("gdiplus\GdipMeasureString"
                  ,    "ptr", pGraphics
                  ,   "wstr", text
                  ,    "int", -1                 ; string length.
                  ,    "ptr", hFont
                  ,    "ptr", &RectF             ; (in) layout RectF that bounds the string.
                  ,    "ptr", hFormat
                  ,    "ptr", &RectF             ; (out) simulated RectF that bounds the string.
                  ,  "uint*", Chars
                  ,  "uint*", Lines)

         ; Get simulated text width and height.
         width := NumGet(RectF, 8, "float")
         height := NumGet(RectF, 12, "float")
         minimum := (width < height) ? width : height
         aspect := (height != 0) ? width / height : 0

         ; Default background width and height.
         if (_w == "")
            _w := width
         if (_h == "")
            _h := height



         ; Get background anchor. This is where the origin of the image is located.
         _a := RegExReplace(_a, "\s", "")
         _a := (_a ~= "i)top" && _a ~= "i)left") ? 1 : (_a ~= "i)top" && _a ~= "i)cent(er|re)") ? 2
            : (_a ~= "i)top" && _a ~= "i)right") ? 3 : (_a ~= "i)cent(er|re)" && _a ~= "i)left") ? 4
            : (_a ~= "i)cent(er|re)" && _a ~= "i)right") ? 6 : (_a ~= "i)bottom" && _a ~= "i)left") ? 7
            : (_a ~= "i)bottom" && _a ~= "i)cent(er|re)") ? 8 : (_a ~= "i)bottom" && _a ~= "i)right") ? 9
            : (_a ~= "i)top") ? 2 : (_a ~= "i)left") ? 4 : (_a ~= "i)right") ? 6 : (_a ~= "i)bottom") ? 8
            : (_a ~= "i)cent(er|re)") ? 5 : (_a ~= "^[1-9]$") ? _a : 1 ; Default anchor is top-left.

         ; The anchor can be implied from _x and _y (left, center, right, top, bottom).
         _a := (_x ~= "i)left") ? 1+(((_a-1)//3)*3) : (_x ~= "i)cent(er|re)") ? 2+(((_a-1)//3)*3) : (_x ~= "i)right") ? 3+(((_a-1)//3)*3) : _a
         _a := (_y ~= "i)top") ? 1+(mod(_a-1,3)) : (_y ~= "i)cent(er|re)") ? 4+(mod(_a-1,3)) : (_y ~= "i)bottom") ? 7+(mod(_a-1,3)) : _a

         ; Convert English words to numbers. Don't mess with these values any further.
         _x := (_x ~= "i)left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*ScreenWidth : (_x ~= "i)right") ? ScreenWidth : _x
         _y := (_y ~= "i)top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*ScreenHeight : (_y ~= "i)bottom") ? ScreenHeight : _y

         ; Get _x and _y.
         _x := (_x ~= valid) ? RegExReplace(_x, "\s", "") : ""
         _x := (_x ~= "i)(pt|px)$") ? SubStr(_x, 1, -2) : _x
         _x := (_x ~= "i)(%|vw)$") ? RegExReplace(_x, "i)(%|vw)$", "") * vw : _x
         _x := (_x ~= "i)vh$") ? RegExReplace(_x, "i)vh$", "") * vh : _x
         _x := (_x ~= "i)vmin$") ? RegExReplace(_x, "i)vmin$", "") * vmin : _x

         _y := (_y ~= valid) ? RegExReplace(_y, "\s", "") : ""
         _y := (_y ~= "i)(pt|px)$") ? SubStr(_y, 1, -2) : _y
         _y := (_y ~= "i)vw$") ? RegExReplace(_y, "i)vw$", "") * vw : _y
         _y := (_y ~= "i)(%|vh)$") ? RegExReplace(_y, "i)(%|vh)$", "") * vh : _y
         _y := (_y ~= "i)vmin$") ? RegExReplace(_y, "i)vmin$", "") * vmin : _y

         ; Default x and y.
         if (_x == "")
            _x := 0.5*ScreenWidth, _a := 2+(((_a-1)//3)*3)
         if (_y == "")
            _y := 0.5*ScreenHeight, _a := 4+(mod(_a-1,3))

         ; Now let's modify the _x and _y values with the _anchor, so that the image has a new point of origin.
         ; We need our calculated _width and _height for this!
         _x -= (mod(_a-1,3) == 0) ? 0 : (mod(_a-1,3) == 1) ? _w/2 : (mod(_a-1,3) == 2) ? _w : 0
         _y -= (((_a-1)//3) == 0) ? 0 : (((_a-1)//3) == 1) ? _h/2 : (((_a-1)//3) == 2) ? _h : 0

         ; Prevent half-pixel rendering and keep image sharp.
         _w := Round(_x + _w) - Round(_x) ; Use real x2 coordinate to determine width.
         _h := Round(_y + _h) - Round(_y) ; Use real y2 coordinate to determine height.
         _x := Round(_x)                  ; NOTE: simple Floor(w) or Round(w) will NOT work.
         _y := Round(_y)                  ; The float values need to be added up and then rounded!

         ; Get the text width and text height.
         w  := ( w ~= valid_positive) ? RegExReplace( w, "\s", "") : width ; Default is simulated text width.
         w  := ( w ~= "i)(pt|px)$") ? SubStr( w, 1, -2) :  w
         w  := ( w ~= "i)vw$") ? RegExReplace( w, "i)vw$", "") * vw :  w
         w  := ( w ~= "i)vh$") ? RegExReplace( w, "i)vh$", "") * vh :  w
         w  := ( w ~= "i)vmin$") ? RegExReplace( w, "i)vmin$", "") * vmin :  w
         w  := ( w ~= "%$") ? RegExReplace( w, "%$", "") * 0.01 * _w :  w

         h  := ( h ~= valid_positive) ? RegExReplace( h, "\s", "") : height ; Default is simulated text height.
         h  := ( h ~= "i)(pt|px)$") ? SubStr( h, 1, -2) :  h
         h  := ( h ~= "i)vw$") ? RegExReplace( h, "i)vw$", "") * vw :  h
         h  := ( h ~= "i)vh$") ? RegExReplace( h, "i)vh$", "") * vh :  h
         h  := ( h ~= "i)vmin$") ? RegExReplace( h, "i)vmin$", "") * vmin :  h
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

         ; Get text x and y.
         x  := ( x ~= valid) ? RegExReplace( x, "\s", "") : _x ; Default text x is background x.
         x  := ( x ~= "i)(pt|px)$") ? SubStr( x, 1, -2) :  x
         x  := ( x ~= "i)vw$") ? RegExReplace( x, "i)vw$", "") * vw :  x
         x  := ( x ~= "i)vh$") ? RegExReplace( x, "i)vh$", "") * vh :  x
         x  := ( x ~= "i)vmin$") ? RegExReplace( x, "i)vmin$", "") * vmin :  x
         x  := ( x ~= "%$") ? RegExReplace( x, "%$", "") * 0.01 * _w :  x

         y  := ( y ~= valid) ? RegExReplace( y, "\s", "") : _y ; Default text y is background y.
         y  := ( y ~= "i)(pt|px)$") ? SubStr( y, 1, -2) :  y
         y  := ( y ~= "i)vw$") ? RegExReplace( y, "i)vw$", "") * vw :  y
         y  := ( y ~= "i)vh$") ? RegExReplace( y, "i)vh$", "") * vh :  y
         y  := ( y ~= "i)vmin$") ? RegExReplace( y, "i)vmin$", "") * vmin :  y
         y  := ( y ~= "%$") ? RegExReplace( y, "%$", "") * 0.01 * _h :  y

         ; Modify text x and text y values with the anchor, so that the text has a new point of origin.
         ; The text anchor is relative to the text width and height before margin/padding.
         ; This is NOT relative to the background width and height.
         x  -= (mod(a-1,3) == 0) ? 0 : (mod(a-1,3) == 1) ? w/2 : (mod(a-1,3) == 2) ? w : 0
         y  -= (((a-1)//3) == 0) ? 0 : (((a-1)//3) == 1) ? h/2 : (((a-1)//3) == 2) ? h : 0

         ; Get margin.
         m  := this.outer.parse.margin_and_padding( m, vw, vh)
         _m := this.outer.parse.margin_and_padding(_m, vw, vh, (m.void) ? "1vmin" : "") ; Default margin is 1vmin.

         ; Modify _x, _y, _w, _h with margin and padding, increasing the size of the background.
         _w += Round(_m.2) + Round(_m.4) + Round(m.2) + Round(m.4)
         _h += Round(_m.1) + Round(_m.3) + Round(m.1) + Round(m.3)
         _x -= Round(_m.4)
         _y -= Round(_m.1)

         ; If margin/padding are defined in the text parameter, shift the position of the text.
         x  += Round(m.4)
         y  += Round(m.1)

         ; Re-run: Condense Text using a Condensed Font if simulated text width exceeds screen width.
         if (z) {
            if (width + x > ScreenWidth) {
               _redrawBecauseOfCondensedFont := true
               return this.DrawRaw(pGraphics, ScreenWidth, ScreenHeight, text, style1, style2)
            }
         }

         ; Define radius of rounded corners.
         _r := (_r ~= valid_positive) ? RegExReplace(_r, "\s", "") : 0  ; Default radius is 0, or square corners.
         _r := (_r ~= "i)(pt|px)$") ? SubStr(_r, 1, -2) : _r
         _r := (_r ~= "i)vw$") ? RegExReplace(_r, "i)vw$", "") * vw : _r
         _r := (_r ~= "i)vh$") ? RegExReplace(_r, "i)vh$", "") * vh : _r
         _r := (_r ~= "i)vmin$") ? RegExReplace(_r, "i)vmin$", "") * vmin : _r
         ; percentage is defined as a percentage of the smaller background width/height.
         _r := (_r ~= "%$") ? RegExReplace(_r, "%$", "") * 0.01 * ((_w > _h) ? _h : _w) : _r
         ; the radius cannot exceed the half width or half height, whichever is smaller.
         _r := (_r <= ((_w > _h) ? _h : _w) / 2) ? _r : 0

         ; Define color.
         _c := this.outer.parse.color(_c, 0xDD424242) ; Default background color is transparent gray.
         SourceCopy := (c ~= "i)(delete|eraser?|overwrite|sourceCopy)") ? 1 : 0 ; Eraser brush for text.
         if (!c) ; Default text color changes between white and black.
            c := (this.outer.parse.grayscale(_c) < 128) ? 0xFFFFFFFF : 0xFF000000
         c  := (SourceCopy) ? 0x00000000 : this.outer.parse.color( c)

         ; Define outline and dropShadow.
         o := this.outer.parse.outline(o, vw, vh, s, c)
         d := this.outer.parse.dropShadow(d, vw, vh, width, height, s)



         ; Draw 1 - Background
         if (_w && _h && (_c & 0xFF000000)) {
            if (_r == 0)
               Gdip_SetSmoothingMode(pGraphics, 1) ; Turn antialiasing off if not a rounded rectangle.
            pBrush := Gdip_BrushCreateSolid(_c)
            Gdip_FillRoundedRectangle(pGraphics, pBrush, _x, _y, _w, _h, _r) ; DRAWING!
            Gdip_DeleteBrush(pBrush)
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
               DllCall("gdiplus\GdipCreatePath", "int",1, "ptr*",pPath)
               DllCall("gdiplus\GdipAddPathString"
                        ,    "ptr", pPath
                        ,   "wstr", text
                        ,    "int", -1
                        ,    "ptr", hFamily
                        ,    "int", style
                        ,  "float", s
                        ,    "ptr", &RC
                        ,    "ptr", hFormat)
               ;DllCall("gdiplus\GdipWindingModeOutline", "ptr",pPath) ;BROKEN
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
               this.outer.filter.GaussianBlur(DropShadow, d.3, d.5)
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
            DllCall("gdiplus\GdipCreatePath", "int",1, "ptr*",pPath)
            DllCall("gdiplus\GdipAddPathString"
                     ,    "ptr", pPath
                     ,   "wstr", text
                     ,    "int", -1
                     ,    "ptr", hFamily
                     ,    "int", style
                     ,  "float", s
                     ,    "ptr", &RC
                     ,    "ptr", hFormat)

            ; Create a glow effect around the edges.
            if (o.3) {
               Gdip_SetClipPath(pGraphics, pPath, 3) ; Exclude original text region from being drawn on.
               pPenGlow := Gdip_CreatePen(Format("0x{:02X}",((o.4 & 0xFF000000) >> 24)/o.3) . Format("{:06X}",(o.4 & 0x00FFFFFF)), 1)
               DllCall("gdiplus\GdipSetPenLineJoin", "ptr",pPenGlow, "uint",2)

               o3 := o.3
               _o3 := (A_AhkVersion < 2) ? o3 : "o3"
               loop %_o3%
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

         ; Draw text only when outline has not filled in the text.
         if (text != "" && o.void) {
            DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",SourceCopy)

            VarSetCapacity(RectF, 16)               ; sizeof(RectF) = 16
               , NumPut(    x, RectF,  0,  "float") ; Left
               , NumPut(    y, RectF,  4,  "float") ; Top
               , NumPut(    w, RectF,  8,  "float") ; Width
               , NumPut(    h, RectF, 12,  "float") ; Height

            DllCall("gdiplus\GdipMeasureString"
                     ,    "ptr", pGraphics
                     ,   "wstr", text
                     ,    "int", -1                 ; string length.
                     ,    "ptr", hFont
                     ,    "ptr", &RectF             ; (in) layout RectF that bounds the string.
                     ,    "ptr", hFormat
                     ,    "ptr", &RectF             ; (out) simulated RectF that bounds the string.
                     ,  "uint*", Chars
                     ,  "uint*", Lines)

            pBrush := Gdip_BrushCreateSolid(c)
            DllCall("gdiplus\GdipDrawString"
                     ,    "ptr", pGraphics
                     ,   "wstr", text
                     ,    "int", -1
                     ,    "ptr", hFont
                     ,    "ptr", &RectF
                     ,    "ptr", hFormat
                     ,    "ptr", pBrush)
            Gdip_DeleteBrush(pBrush)

            x := NumGet(RectF,  0, "float")
            y := NumGet(RectF,  4, "float")
            w := NumGet(RectF,  8, "float")
            h := NumGet(RectF, 12, "float")
         }

         ; Delete Font Objects.
         Gdip_DeleteStringFormat(hFormat)
         Gdip_DeleteFont(hFont)
         Gdip_DeleteFontFamily(hFamily)

         ; Set Graphics settings.
         ;DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",2) ; Half pixel offset.
         ;DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",1) ; Overwrite/SourceCopy.
         ;DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",0) ; AssumeLinear
         ;DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",_q)
         ;DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",7) ; HighQualityBicubic
         ;DllCall("gdiplus\GdipSetTextRenderingHint",  "ptr",pGraphics, "int",q)

         ; Restore original Graphics settings.
         DllCall("gdiplus\GdipSetPixelOffsetMode",    "ptr",pGraphics, "int",PixelOffsetMode)
         DllCall("gdiplus\GdipSetCompositingMode",    "ptr",pGraphics, "int",CompositingMode)
         DllCall("gdiplus\GdipSetCompositingQuality", "ptr",pGraphics, "int",CompositingQuality)
         DllCall("gdiplus\GdipSetSmoothingMode",      "ptr",pGraphics, "int",SmoothingMode)
         DllCall("gdiplus\GdipSetInterpolationMode",  "ptr",pGraphics, "int",InterpolationMode)

         ; Define bounds. BROKEN!!!!
         t_bound :=  t
         x_bound := _x
         y_bound := _y
         w_bound := _w
         h_bound := _h

         o_bound := Ceil(0.5 * o.1 + o.3)                     ; outline boundary.
         x_bound := (x - o_bound < x_bound)        ? x - o_bound        : x_bound
         y_bound := (y - o_bound < y_bound)        ? y - o_bound        : y_bound
         w_bound := (w + 2 * o_bound > w_bound)    ? w + 2 * o_bound    : w_bound
         h_bound := (h + 2 * o_bound > h_bound)    ? h + 2 * o_bound    : h_bound
         ;Tooltip % x_bound ", " y_bound ", " w_bound ", " h_bound
         d_bound := Ceil(0.5 * o.1 + d.3 + d.6)            ; dropShadow boundary.
         x_bound := (x + d.1 - d_bound < x_bound)  ? x + d.1 - d_bound  : x_bound
         y_bound := (y + d.2 - d_bound < y_bound)  ? y + d.2 - d_bound  : y_bound
         w_bound := (w + 2 * d_bound > w_bound)    ? w + 2 * d_bound    : w_bound
         h_bound := (h + 2 * d_bound > h_bound)    ? h + 2 * d_bound    : h_bound

         return {0:t_bound, 1:x_bound, 2:y_bound, 3:w_bound, 4:h_bound}
      }
   } ; End of TextRenderer class.

   class INTERACTIVE {

      ; BufferMode
      ; None = 0        - No buffer is created. Instead the image is repeatedly rendered to screen.
      ; FixedSize = 1   - The size of the screen and buffer bitmaps are minimized to save memory.
      ;                   Because the bitmap representing the screen does not cover the whole screen,
      ;                   interactions are limited only to movement and other actions which do not
      ;                   change the size of the image to be displayed.
      ; SmallBuffer = 2 - The buffer bitmap contains only the pixels that contain data. The screen
      ;                   bitmap is fullsized. All user interactions can be applied.
      ; FullScreen = 3  - Both the buffer and the screen bitmaps are full and equal in size.
      ;                   This is a special mode that allows the buffer bitmap to be drawn on
      ;                   by EXTERNAL programs. Call .Push() after drawing into the buffer to update
      ;                   the screen.
      __New(efx, keybinds := "", BufferMode := 2, NoTimers := 0) {
         ; efx is the original graphics object.
         this.efx := efx
         this.keybinds := keybinds
         this.key := {}

         ; Derive GDI+ objects from the original graphics object.
         this.hdc := CreateCompatibleDC(this.efx.hdc)
         this.hbm := CreateDIBSection(this.efx.BitmapWidth, -this.efx.BitmapHeight, this.hdc, 32, pBits)
         this.obm := SelectObject(this.hdc, this.hbm)
         this.gfx := Gdip_GraphicsFromHDC(this.hdc)
         this.pBits := pBits

         ; Begin the timer loop that checks for user interactions.
         if !(NoTimers) {
            observe := ObjBindMethod(this, "observe")
            _observe := (A_AhkVersion < 2) ? observe : "observe"
            SetTimer %_observe%, -10
         }

         ; Enumeration of this object.
         ;[efx, final, gfx, hbm, hdc, key, keybinds, obm, pBits, _move, _scale, _x, _y]
         ;[__call, __class, __delete, __new, move, observe, paint, scale]
         return this
      }

      __Delete() {
         Gdip_DeleteGraphics(this.gfx)
         SelectObject(this.hdc, this.obm)
         DeleteObject(this.hbm)
         DeleteDC(this.hdc)
      }

      ; Delegate any unknown calls to the original graphics object.
      __Call(self, terms*) {
         if !(this.base.haskey(self))
            return (this.efx)[self](terms*)
      }

      ; Timer loop that checks for user interactions.
      observe() {
         Critical ; Insure this thread cannot be interrupted.

         ; Pull. "final" is like a certificate of authenticity.
         if (this.final != this.efx.final) {
            ; Extract transformations
            if (this.locked) {
               ;this.x_ := this.dx1 - this.dx0
               ;this.y_ := this.dy1 - this.dy0
            } else {
               this.x_ := (this.x == "") ? 0 : this.x_ + this.x - this.x_save
               this.y_ := (this.y == "") ? 0 : this.y_ + this.y - this.y_save
               this.w_ := (this.w == "") ? 0 : this.w_ + (this.x + this.w) - (this.x_save + this.w_save)
               this.h_ := (this.h == "") ? 0 : this.h_ + (this.y + this.h) - (this.y_save + this.h_save)
            }

            ; Clone
            this.x := this.x_save := this.efx.x
            this.y := this.y_save := this.efx.y
            this.w := this.w_save := this.efx.w
            this.h := this.h_save := this.efx.h

            ; X/y WOrks fine.
            if (this.locked) {
               this.x0 := this.efx.x
               this.y0 := this.efx.y
               this.w0 := this.efx.w
               this.h0 := this.efx.h
            }
            ; Update certificate to prevent this routine from being called again.
            this.final := this.efx.final

            ; Refresh the screen.
            this.Paint()
         }

         ; Get mouse coordinates as dx1, dy1.
         Mouse := "Mouse", Screen := "Screen"
         CoordMode Mouse, Screen
         MouseGetPos dx1, dy1
         this.dx1 := dx1
         this.dy1 := dy1

         ; Get keys states and save them to determine their derivatives.
         this.key.LButton := GetKeyState("LButton", "P")
         this.key.RButton := GetKeyState("RButton", "P")
         this.key.Space   := GetKeyState("Space", "P")
         this.key.Control := GetKeyState("Control", "P")
         this.key.Alt     := GetKeyState("Alt", "P")
         this.key.Shift   := GetKeyState("Shift", "P")

         ; Derive key states. 0 = off, 2 = pressed. 1 & 3 are derivatives.
         this._scale := (this.key.Control && this.key.LButton
            && DllCall("GetForegroundWindow") == this.efx.hwnd)
            ? ((!this._scale) ? 1 : 2) : ((this._scale == 2) ? 3 : 0)

         this._drag := (this.key.Alt && this.key.LButton)
            && !this._scale
            ? ((!this._drag) ? 1 : 2) : ((this._drag == 2) ? 3 : 0)

         this._stretch := (this.key.Shift && this.key.LButton
            && !this._scale
            && !this._drag
            && DllCall("GetForegroundWindow") == this.efx.hwnd)
            ? ((!this._stretch) ? 1 : 2) : ((this._stretch == 2) ? 3 : 0)

         this._move := (this.key.LButton
            && !this._scale && !this._stretch
            && !this._drag
            && DllCall("GetForegroundWindow") == this.efx.hwnd)
            ? ((!this._move) ? 1 : 2) : ((this._move = 2) ? 3 : 0)

         ; Run once when 0 -> 2.
         if (this._scale == 1) {
            this.locked := true
            this.x_locked := this.efx.x
            this.y_locked := this.efx.y
            this.w_locked := this.efx.w
            this.h_locked := this.efx.h
            this.dx0 := this.dx1
            this.dy0 := this.dy1
            this.x0 := this.x
            this.y0 := this.y
            this.w0 := this.w
            this.h0 := this.h
         }

         ; Run continuously.
         if (this._scale == 2) {
            dx := this.dx1 - this.dx0
            dy := this.dy1 - this.dy0
            rx := ((this.w0 < 0) ? -1 : 1)*(this.dx0 - this.x0 - (this.w0 / 2))
            ry := ((this.h0 < 0) ? -1 : 1)*(this.y0 - this.dy0 + (this.h0 / 2))

            if (rx < -1 && ry > 1) {
               r := "top left"
               x := this.x0 + dx
               y := this.y0 + dy
               w := this.w0 - dx
               h := this.h0 - dy
            }
            if (rx >= -1 && ry > 1) {
               r := "top right"
               x := this.x0
               y := this.y0 + dy
               w := this.w0 + dx
               h := this.h0 - dy
            }
            if (rx < -1 && ry <= 1) {
               r := "bottom left"
               x := this.x0 + dx
               y := this.y0
               w := this.w0 - dx
               h := this.h0 + dy
            }
            if (rx >= -1 && ry <= 1) {
               r := "bottom right"
               x := this.x0
               y := this.y0
               w := this.w0 + dx
               h := this.h0 + dy
            }
            this.Scale(x, y, w, h)
         }

         ; Run once when 2 -> 0.
         if (this._scale == 3) {
            this.locked := false
         }

         ; Run once when 0 -> 2.
         if (this._drag == 1) {
            this.locked := true
            this.x_locked := this.efx.x
            this.y_locked := this.efx.y
            this.w_locked := this.efx.w
            this.h_locked := this.efx.h
            this.dx0 := this.dx1
            this.dy0 := this.dy1
            this.x0 := this.x
            this.y0 := this.y
            this.w0 := this.w
            this.h0 := this.h
         }

         ; Run continuously.
         if (this._drag == 2) {
            cx := (this.dx1 > this.dx0) ? true : false
            cy := (this.dy1 > this.dy0) ? true : false

            if (cx && cy) {
               r := "bottom right"
               x := this.dx0
               y := this.dy0
               w := Abs(this.dx1 - this.dx0)
               h := Abs(this.dy1 - this.dy0)
            }
            if (!cx && cy) {
               r := "bottom left"
               x := this.dx1
               y := this.dy0
               w := Abs(this.dx1 - this.dx0)
               h := Abs(this.dy1 - this.dy0)
            }
            if (cx && !cy) {
               r := "top right"
               x := this.dx0
               y := this.dy1
               w := Abs(this.dx1 - this.dx0)
               h := Abs(this.dy1 - this.dy0)
            }
            if (!cx && !cy) {
               r := "top left"
               x := this.dx1
               y := this.dy1
               w := Abs(this.dx1 - this.dx0)
               h := Abs(this.dy1 - this.dy0)
            }
            this.Scale(x, y, w, h)
         }

         ; Run once when 2 -> 0.
         if (this._drag == 3) {
            this.locked := false
         }

         ; Run once when 0 -> 2.
         if (this._stretch == 1) {
            this.locked := true
            this.x_locked := this.efx.x
            this.y_locked := this.efx.y
            this.w_locked := this.efx.w
            this.h_locked := this.efx.h
            this.dx0 := this.dx1
            this.dy0 := this.dy1
            this.x0 := this.x
            this.y0 := this.y
            this.w0 := this.w
            this.h0 := this.h
         }

         ; Run continuously.
         if (this._stretch == 2) {
            dx := this.dx1 - this.dx0
            dy := this.dy1 - this.dy0 ; I don't know why 2 of this.h0 works.
            rx := ((this.h0 < 0) ? -1 : 1)*(this.dx0 - this.x0 - (this.w0 / 2))
            ry := ((this.h0 < 0) ? -1 : 1)*(this.y0 - this.dy0 + (this.h0 / 2))
            m := -(this.h0 / this.w0)                ; slope (dy/dx)

            if (m * rx >= ry && ry > -m * rx) {
               r := "left"
               x := this.x0 + dx
               y := this.y0
               w := this.w0 - dx
               h := this.h0
            }
            if (m * rx < ry && ry > -m * rx) {
               r := "top"
               x := this.x0
               y := this.y0 + dy
               w := this.w0
               h := this.h0 - dy
            }
            if (m * rx < ry && ry <= -m * rx) {
               r := "right"
               x := this.x0
               y := this.y0
               w := this.w0 + dx
               h := this.h0
            }
            if (m * rx >= ry && ry <= -m * rx) {
               r := "bottom"
               x := this.x0
               y := this.y0
               w := this.w0
               h := this.h0 + dy
            }

            this.Scale(x, y, w, h)
         }

         if (this._stretch == 3) {
            this.locked := false
         }

         if (this._move == 1) {
            this.locked := true
            this.x_locked := this.efx.x
            this.y_locked := this.efx.y
            this.w_locked := this.efx.w
            this.h_locked := this.efx.h
            this.dx0 := this.dx1
            this.dy0 := this.dy1
            this.x0 := this.x
            this.y0 := this.y
            this.w0 := this.w
            this.h0 := this.h
         }

         if (this._move == 2) {
            dx := this.dx1 - this.dx0
            dy := this.dy1 - this.dy0
            this.Move(this.x0 + dx, this.y0 + dy)
         }

         if (this._move == 3) {
            this.locked := false
         }

         ;Tooltip % "Mouse:`t" this.dx1 ", " this.dy1
         ;   . "`nInital:`t" this.dx0 ", " this.dy0
         ;   . "`nObject:`t" this.x ", " this.y ", " this.w ", " this.h
         ;   . "`nLast:`t" this.x0 ", " this.y0 ", " this.w0 ", " this.h0

         observe := ObjBindMethod(this, "observe")
         _observe := (A_AhkVersion < 2) ? observe : "observe"
         SetTimer %_observe%, -10
      }

      Move(x, y) {
         this.x := x, this.y := y
         this.Paint()
      }

      Scale(x, y, w, h) {
         this.x := x, this.y := y, this.w := w, this.h := h
         this.Paint()
         ;Gdip_GraphicsClear(this.gfx)
         ;StretchBlt(this.hdc, this.x, this.y, this.w, this.h, this.efx.hdc, this.efx.x, this.efx.y, this.efx.w, this.efx.h)
         ;UpdateLayeredWindow(this.efx.hwnd, this.hdc, this.efx.BitmapLeft, this.efx.BitmapTop, this.efx.BitmapWidth, this.efx.BitmapHeight)
      }

      Paint() {
         Gdip_GraphicsClear(this.gfx)
         if !(this.w == this.efx.w && this.h == this.efx.h)
            StretchBlt(this.hdc, this.x + this.x_ - this.w_/2, this.y + this.y_ - this.h_/2, this.w + this.w_/2, this.h + this.h_/2, this.efx.hdc, this.efx.x, this.efx.y, this.efx.w, this.efx.h)
         else
            BitBlt(this.hdc, this.x + this.x_, this.y + this.y_, this.efx.w, this.efx.h, this.efx.hdc, this.efx.x, this.efx.y)
         UpdateLayeredWindow(this.efx.hwnd, this.hdc, this.efx.BitmapLeft, this.efx.BitmapTop, this.efx.BitmapWidth, this.efx.BitmapHeight)
      }

      ; Mouse
      ; Move
      ; Resize
      ; Scale
      ; Stretch
      ; Rotate

      ; Keys
      ; Rotate90
      ; Rotate180
      ; Move5
      ; Move10
      ; Mirror
      ; Fade
      ; Blur

   } ; End of INTERACTIVE class.

   class SEQUENCER {

   } ; End of SEQUENCER class.

   class SYNTHESIS {
      ; the synthesis class contains all the lower functions.
      ; DrawText(), DrawPolygon(), DrawImage(), DrawVideo()?
      ; QueueText(), QueuePolygon(), QueueImage(), QueueVideo(), Flush()
      ; RenderText(), RenderPolygon(), RenderImage(), RenderVideo()
      ; Render() - which throws if you try to pass any parameters to it.
      ; SYNTHESIS will auto allocate memories.
      ; It will disallow stretching? Might be posible to keep it. Or not.
   } ; End of SYNTHESIS class.
}
