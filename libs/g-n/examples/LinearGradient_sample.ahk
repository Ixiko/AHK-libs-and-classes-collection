; LinearGradient_sample.ahk
#NoEnv
#Include *i Colors.ahk
Gui, Margin, 0, 0
Gui, Add, Pic, w480 h240 hwndHPIC
Colors := [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF]
If !LinearGradient(HPIC, Colors)
   MsgBox, 0, Linear Gradient, Funtion failed:`n%ErrorLevel%
Gui, Font, s144, Tahoma
Gui, Add, Text, xp yp wp hp cNavy Center 0x200 vTX1 BackgroundTrans, AHK
Gui, Show, , Linear Gradient
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
GuiEscape:
ExitApp
#Include LinearGradient.ahk