Subtitle(text:="Alert!", obj1:="", obj2:=""){

   if (text.destroy) {
      Gui, %obj1%: Destroy
      return
   }

   VarSetCapacity(UUID, 16, 0)
   DllCall("rpcrt4.dll\UuidCreate", "ptr", &UUID)
   DllCall("rpcrt4.dll\UuidToString", "ptr", &UUID, "uint*", suuid)
   name := "Subtitle_" A_TickCount "n" SubStr(StrGet(suuid), 1, 8)
   DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)

   Gui, %name%: New, +LastFound +AlwaysOnTop -Caption -DPIScale +E0x80000 +ToolWindow +hwndSecretName, name
   Gui, %name%: Show, NoActivate
   hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
   hdc := CreateCompatibleDC()
   obm := SelectObject(hdc, hbm)
   G := Gdip_GraphicsFromHDC(hdc)
   Gdip_SetSmoothingMode(G, 4)

   self_destruct := Func(A_ThisFunc).Bind({"Destroy":true}, name)

   ; BEGIN
   static q1 := "i)^.*?(?<!-|:|:\s)\b"
   static q2 := "(:\s?)?(?<value>[\da-z\.%]+).*$"

   time := (obj1.t) ? obj1.t : (obj1.time) ? obj1.time
         : (!IsObject(obj1) && (___ := RegExReplace(obj1, q1 "(t(ime)?)" q2, "${value}")) != obj1) ? ___
         : (obj2.t) ? obj2.t : (obj2.time) ? obj2.time
         : (!IsObject(obj2) && (___ := RegExReplace(obj2, q1 "(t(ime)?)" q2, "${value}")) != obj2) ? ___
         : 0

   SetTimer, % self_destruct, % (time) ? -1 * time : "Delete"

   static alpha := "^[A-Za-z]+$"
   static colorRGB := "^0x([0-9A-Fa-f]{6})$"
   static colorARGB := "^0x([0-9A-Fa-f]{8})$"
   static hex6 := "^([0-9A-Fa-f]{6})$"
   static hex8 := "^([0-9A-Fa-f]{8})$"
   static decimal := "^(\-?[\d\.]+)$"
   static integer := "^\d+$"
   static percentage := "^(\-?[\d\.]+)%$"
   static positive := "^[\d\.]+$"

   if IsObject(obj1){
      _x  := (obj1.x)  ? obj1.x  : obj1.left
      _y  := (obj1.y)  ? obj1.y  : obj1.top
      _w  := (obj1.w)  ? obj1.w  : obj1.width
      _h  := (obj1.h)  ? obj1.h  : obj1.height
      _r  := (obj1.r)  ? obj1.r  : obj1.radius
      _c  := (obj1.c)  ? obj1.c  : obj1.color
      _m  := (obj1.m)  ? obj1.m  : obj1.margin
      _p  := (obj1.p)  ? obj1.p  : obj1.padding
   } else {
      _x  := ((___ := RegExReplace(obj1, q1    "(x|left)"               q2, "${value}")) != obj1) ? ___ : ""
      _y  := ((___ := RegExReplace(obj1, q1    "(y|top)"                q2, "${value}")) != obj1) ? ___ : ""
      _w  := ((___ := RegExReplace(obj1, q1    "(w(idth)?)"             q2, "${value}")) != obj1) ? ___ : ""
      _h  := ((___ := RegExReplace(obj1, q1    "(h(eight)?)"            q2, "${value}")) != obj1) ? ___ : ""
      _r  := ((___ := RegExReplace(obj1, q1    "(r(adius)?)"            q2, "${value}")) != obj1) ? ___ : ""
      _c  := ((___ := RegExReplace(obj1, q1    "(c(olor)?)"             q2, "${value}")) != obj1) ? ___ : ""
      _m  := ((___ := RegExReplace(obj1, q1    "(m(argin)?)"            q2, "${value}")) != obj1) ? ___ : ""
      _p  := ((___ := RegExReplace(obj1, q1    "(p(adding)?)"           q2, "${value}")) != obj1) ? ___ : ""
   }

   if IsObject(obj2){
      x  := (obj2.x)  ? obj2.x  : obj2.left
      y  := (obj2.y)  ? obj2.y  : obj2.top
      w  := (obj2.w)  ? obj2.w  : obj2.width
      h  := (obj2.h)  ? obj2.h  : obj2.height
      m  := (obj2.m)  ? obj2.m  : obj2.margin
      f  := (obj2.f)  ? obj2.f  : obj2.font
      s  := (obj2.s)  ? obj2.s  : obj2.size
      c  := (obj2.c)  ? obj2.c  : obj2.color
      b  := (obj2.b)  ? obj2.b  : obj2.bold
      i  := (obj2.i)  ? obj2.i  : obj2.italic
      u  := (obj2.u)  ? obj2.u  : obj2.underline
      j  := (obj2.j)  ? obj2.j  : obj2.justify
      q  := (obj2.q)  ? obj2.q  : obj2.quality
      n  := (obj2.n)  ? obj2.n  : obj2.noWrap
      z  := (obj2.z)  ? obj2.z  : obj2.condensed
   } else {
      x  := ((___ := RegExReplace(obj2, q1    "(x|left)"               q2, "${value}")) != obj2) ? ___ : ""
      y  := ((___ := RegExReplace(obj2, q1    "(y|top)"                q2, "${value}")) != obj2) ? ___ : ""
      w  := ((___ := RegExReplace(obj2, q1    "(w(idth)?)"             q2, "${value}")) != obj2) ? ___ : ""
      h  := ((___ := RegExReplace(obj2, q1    "(h(eight)?)"            q2, "${value}")) != obj2) ? ___ : ""
      m  := ((___ := RegExReplace(obj2, q1    "(m(argin)?)"            q2, "${value}")) != obj2) ? ___ : ""
      f  := ((___ := RegExReplace(obj2, q1    "(f(ont)?)"              q2, "${value}")) != obj2) ? ___ : ""
      s  := ((___ := RegExReplace(obj2, q1    "(s(ize)?)"              q2, "${value}")) != obj2) ? ___ : ""
      c  := ((___ := RegExReplace(obj2, q1    "(c(olor)?)"             q2, "${value}")) != obj2) ? ___ : ""
      b  := ((___ := RegExReplace(obj2, q1    "(b(old)?)"              q2, "${value}")) != obj2) ? ___ : ""
      i  := ((___ := RegExReplace(obj2, q1    "(i(talic)?)"            q2, "${value}")) != obj2) ? ___ : ""
      u  := ((___ := RegExReplace(obj2, q1    "(u(nderline)?)"         q2, "${value}")) != obj2) ? ___ : ""
      j  := ((___ := RegExReplace(obj2, q1    "(j(ustify)?)"           q2, "${value}")) != obj2) ? ___ : ""
      q  := ((___ := RegExReplace(obj2, q1    "(q(uality)?)"           q2, "${value}")) != obj2) ? ___ : ""
      n  := ((___ := RegExReplace(obj2, q1    "(n(oWrap)?)"            q2, "${value}")) != obj2) ? ___ : ""
      z  := ((___ := RegExReplace(obj2, q1    "(z|condensed?)"         q2, "${value}")) != obj2) ? ___ : ""
   }

   ; Simulate string width and height, setting only the variables we need to determine it.
   style += (b) ? 1 : 0    ; bold
   style += (i) ? 2 : 0    ; italic
   style += (u) ? 4 : 0    ; underline
   style += (strike) ? 8 : ; strikeout, not implemented.
   s  := ( s  ~= percentage) ? A_ScreenHeight * RegExReplace( s, percentage, "$1")  // 100 :  s

   ;TextRenderingHintAntiAlias                  = 4,
   ;TextRenderingHintClearTypeGridFit           = 5
   Gdip_SetTextRenderingHint(G, (q >= 0 && q <= 5) ? q : 4)
   hFamily := (___ := Gdip_FontFamilyCreate(f)) ? ___ : Gdip_FontFamilyCreate("Arial")
   hFont := Gdip_FontCreate(hFamily, (s ~= positive) ? s : 36, style)
   hFormat := Gdip_StringFormatCreate((n) ? 0x4000 | 0x1000 : 0x4000)
   Gdip_SetStringFormatAlign(hFormat, (j = "left") ? 0 : (j = "center") ? 1 : (j = "right") ? 2 : 0)

   CreateRectF(RC, 0, 0, 0, 0)
   ReturnRC := Gdip_MeasureString(G, Text, hFont, hFormat, RC)
   ReturnRC := StrSplit(ReturnRC, "|")

   ; Set default dimensions for background, if left blank.
   _x  := (_x  != "") ? _x : "center"
   _y  := (_y  != "") ? _y : "center"
   _w  := (_w) ? _w  : ReturnRC[3]
   _h  := (_h) ? _h  : ReturnRC[4]

   ; Condense Text using a Condensed Font if simulated text width exceeds screen width.
   if (z && ReturnRC[3] > 0.95*A_ScreenWidth){
      hFamily := (___ := Gdip_FontFamilyCreate(z)) ? ___ : Gdip_FontFamilyCreate("Arial Narrow")
      hFont := Gdip_FontCreate(hFamily, (s ~= positive) ? s : 36, style)
      ReturnRC := Gdip_MeasureString(G, Text, hFont, hFormat, RC)
      ReturnRC := StrSplit(ReturnRC, "|")
      _w  := ReturnRC[3]
   }

   ; Relative to A_ScreenHeight or A_ScreenWidth
   _x  := (_x  ~= percentage) ? A_ScreenWidth  * RegExReplace(_x, percentage, "$1")  // 100 : _x
   _y  := (_y  ~= percentage) ? A_ScreenHeight * RegExReplace(_y, percentage, "$1")  // 100 : _y
   _w  := (_w  ~= percentage) ? A_ScreenWidth  * RegExReplace(_w, percentage, "$1")  // 100 : _w
   _h  := (_h  ~= percentage) ? A_ScreenHeight * RegExReplace(_h, percentage, "$1")  // 100 : _h
   _m  := (_m  ~= percentage) ? A_ScreenHeight * RegExReplace(_m, percentage, "$1")  // 100 : _m
   _p  := (_p  ~= percentage) ? A_ScreenHeight * RegExReplace(_p, percentage, "$1")  // 100 : _p

   ; Relative to Background width of height
   _smaller := (_w > _h) ? _h : _w
   _r  := (_r  ~= percentage) ? _smaller * RegExReplace(_r, percentage, "$1")  // 100 : _r
    x  := ( x  ~= percentage) ? _x + (_w * RegExReplace( x, percentage, "$1"))  // 100 : x
    y  := ( y  ~= percentage) ? _y + (_h * RegExReplace( y, percentage, "$1"))  // 100 : y
    w  := ( w  ~= percentage) ? _w * RegExReplace( w, percentage, "$1")  // 100 : w
    h  := ( h  ~= percentage) ? _h * RegExReplace( h, percentage, "$1")  // 100 : h
    m  := ( m  ~= percentage) ? _w * RegExReplace( m, percentage, "$1")  // 100 : m


   ; Resolving ambiguous inputs to non-ambiguous outputs.
   _x  := (_x = "left") ? 0 : (_x ~= "i)cent(er|re)") ? 0.5*(A_ScreenWidth - _w) : (_x = "right") ? A_ScreenWidth - _w : _x
   _y  := (_y = "top") ? 0 : (_y ~= "i)cent(er|re)") ? 0.5*(A_ScreenHeight - _h) : (_y = "bottom") ? A_ScreenHeight - _h : _y
   _c  := (_c  ~= colorRGB) ? "0xff" RegExReplace(_c, colorRGB, "$1") : (_c ~= hex8) ? "0x" _c : (_c ~= hex6) ? "0xff" _c : _c
    c  := ( c  ~= colorRGB) ? "0xff" RegExReplace( c, colorRGB, "$1") : ( c ~= hex8) ? "0x"  c : ( c ~= hex6) ? "0xff"  c :  c
    x  := ( x = "left") ? _x : (x ~= "i)cent(er|re)") ? _x + 0.5*(_w - ReturnRC[3]) : (x = "right") ? _x + _w - ReturnRC[3] : x
    y  := ( y = "top") ? _y : (y ~= "i)cent(er|re)") ? _y + 0.5*(_h - ReturnRC[4]) : (y = "bottom") ? _y + _h - ReturnRC[4] : y

   ; Detecting non-standard inputs (if any) and set them to default values.
   _x  := (_x  ~= decimal) ? _x  : 0
   _y  := (_y  ~= decimal) ? _y  : 0
   _m  := (_m  ~= positive) ? _m  : 0
   _r  := (_r  <= _smaller // 2 && _r ~= positive) ? _r : 0
   _c  := (_c  ~= colorARGB) ? _c  : 0xdd424242
    c  := ( c  ~= colorARGB) ?  c  : 0xffffffff
    m  := ( m  ~= positive) ?  m : 0
    x  := ( x  ~= decimal) ? x : _x + 0.5*(_w - ReturnRC[3])
    y  := ( y  ~= decimal) ? y : _y + 0.5*(_h - ReturnRC[4])
    w  := ( w  ~= positive) ? w : ReturnRC[3]
    h  := ( h  ~= positive) ? h : ReturnRC[4]

   ; Set Margin
   _x  -= m
   _y  -= m
   _w  += 2*m
   _h  += 2*m

   _x  -= _m
   _y  -= _m
   _w  += 2*_m
   _h  += 2*_m

   _x  -= _p
   _y  -= _p
   _w  += 2*_p
   _h  += 2*_p

   ; Draw Background
   pBrushBackground := Gdip_BrushCreateSolid(_c)
   Gdip_FillRoundedRectangle(G, pBrushBackground, _x, _y, _w, _h, _r)
   Gdip_DeleteBrush(pBrushBackground)

   ; Draw Text
   CreateRectF(RC, x, y, w, h)
   pBrushText := Gdip_BrushCreateSolid(c)
   Gdip_DrawString(G, Text, hFont, hFormat, pBrushText, RC)
   Gdip_DeleteBrush(pBrushText)

   ; Complete
   Gdip_DeleteStringFormat(hFormat)
   Gdip_DeleteFont(hFont)
   Gdip_DeleteFontFamily(hFamily)
   ; END

   UpdateLayeredWindow(SecretName, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
   Gdip_DeleteGraphics(G)
   SelectObject(hdc, obm)
   DeleteObject(hbm)
   DeleteDC(hdc)
   return {"Destroy":self_destruct}
}