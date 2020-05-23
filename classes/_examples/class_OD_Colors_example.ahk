#NoEnv
SetBatchLines, -1
; ----------------------------------------------------------------------------------------------------------------------
; DDL styles
OD_DDL := "+0x0210" ; CBS_OWNERDRAWFIXED = 0x0010, CBS_HASSTRINGS = 0x0200
; ListBox styles
OD_LB  := "+0x0050" ; LBS_OWNERDRAWFIXED = 0x0010, LBS_HASSTRINGS = 0x0040
; Liste
Items := "Eins|Zwei|Drei|Vier|Fünf|Sechs|Sieben|Acht|Neun|Zehn"
; ----------------------------------------------------------------------------------------------------------------------
Gui, Margin, 20, 20
Gui, Add, Text, xm w200, Owner-Drawn DropDownList:
Gui, Add, Text, x+20 yp wp, Owner-Drawn ListBox:
Gui, Add, Text, x+20 yp wp, Common ListBox:
Gui, Font, % (FontOptions := "s10"), % (FontName := "Arial")
OD_Colors.SetItemHeight(FontOptions, FontName)
Gui, Add, DDL, xm y+5 w200 r6 hwndHDDL Choose4 %OD_DDL%, %Items%
Gui, Add, ListBox, x+20 yp wp r6 hwndHLB cGreen %OD_LB%, %Items%
Gui, Add, ListBox, x+20 yp wp r6, %Items%
Gui, Show, , OD_Colors
OD_Colors.Attach(HDDL, {T: 0x000080, B: 0xF0F0F0, 4: {T: 0xFFFFFF, B: 0xFF0000}, 6: {T: 0xFFFFFF, B: 0xFF0000}})
OD_Colors.Attach(HLB, {4: {T: 0xFFFFFF, B: 0x000080}, 6: {T: 0xFFFFFF, B: 0x008000}})
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
#Include %A_ScriptDir%\..\Class_OD_Colors.ahk