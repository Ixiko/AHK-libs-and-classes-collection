#SingleInstance, force
#NoEnv
SetBatchLines, -1
#Include %A_ScriptDir%\..\Class_ImageButton.ahk
; ----------------------------------------------------------------------------------------------------------------------

ImageButton.DisableFadeEffect()

Gui, New: -dpiscale
Gui, Font, s13
Gui, Margin, 60
Gui, Color, White
ImageButton.SetGuiColor("White")

Gui, Font, s30

cb_style1 := [ { 1:0, 4: 0xAEAEAE, icon:{file:"Resources\switch-off.png", x:310} }
             , { 1:0, 4: 0xAEAEAE, icon:{file:"Resources\switch-off.png", x:310} }
             , { 1:0, 4: 0x239CF8, icon:{file:"Resources\switch-on.png" , x:310} } ]

Gui, Add, CheckBox, w290 h39 Left hwndHBT, Checkbox1
	ImageButton.Create(HBT, cb_style1*)
Gui, Add, CheckBox, w290 h39 Left hwndHBT, Checkbox2
	ImageButton.Create(HBT, cb_style1*)

; ----------------------------------------------------------------------------------------------------------------------
Gui, Font, s13

cb_style2 := [ { 1:0, 4: 0x606000, icon:{file:"Resources\cb-leave.png"}   }
             , { 1:0, 4: "Black" , icon:{file:"Resources\cb-hover.png"}   }
             , { 1:0, 4: "Black" , icon:{file:"Resources\cb-checked.png"} } ]

Gui, Add, CheckBox, w120 h30 Left hwndHBT2, Checkbox3
	ImageButton.Create(HBT2, cb_style2*)

Gui, Add, CheckBox, w120 h30 y+10 Left hwndHBT3, Checkbox4
	ImageButton.Create(HBT3, cb_style2*)
; ----------------------------------------------------------------------------------------------------------------------
Gui, Font, s12

cb_style3 := [ { 1:0, 4: "Black", icon:{file:"Resources\checkbox-leave.png"  , padding: 8}   }
             , { 1:0, 4: "Black" , icon:{file:"Resources\checkbox-hover.png"  , padding: 8}   }
             , { 1:0, 4: "Black" , icon:{file:"Resources\checkbox-checked.png", padding: 8} } ]

Gui, Add, CheckBox, w110 h30 Left hwndHBT Section, Checkbox5
	ImageButton.Create(HBT, cb_style3*)

Gui, Add, CheckBox, w110 h30 Left hwndHBT y+4, Checkbox6
	ImageButton.Create(HBT, cb_style3*)
; ----------------------------------------------------------------------------------------------------------------------
radio_style := [ { 1:0, 4: "Black", icon:{file:"Resources\radio-leave.png"  , padding: 8} }
               , { 1:0, 4: "Black" , icon:{file:"Resources\radio-hover.png"  , padding: 8} }
               , { 1:0, 4: "Black" , icon:{file:"Resources\radio-checked.png", padding: 8} } ]

Gui, Add, Radio, ys x+50 w110 h30 Left hwndHBT Checked, Radio1
	ImageButton.Create(HBT, radio_style*)

Gui, Add, Radio, w110 h30 Left hwndHBT y+4, Radio2
	ImageButton.Create(HBT, radio_style*)
; ----------------------------------------------------------------------------------------------------------------------


Gui, Add, Button, xm Center vBT3 w190 h50 hwndHBT4 y+50, Copy
	Opt1 := { 1:0, 2:0xECEFF3, 7:0xBCC4D0, icon:{file:"Resources\copy.png", x: 60} }
	Opt2 := { 1:0, 2:0xCAD3DE, 7:0xA5AFBF, icon:{file:"Resources\copy.png", x: 40, y: 0} }
	Opt3 := { 1:0, 2:0xC1CAD7, 7:0x99A5B7, icon:{file:"Resources\copy.png", x: 40} }
	ImageButton.Create(HBT4, Opt1, Opt2, Opt3)

Gui, Add, Button, Left vBT4 w95 h50 hwndHBT5, Save
	Opt1 := { 1:0, 2:0xECEFF3, 7:0xBCC4D0, icon:{file:"Resources\save.png", padding: 8} }
	Opt2 := { 1:0, 2:0xCAD3DE, 7:0xA5AFBF, icon:{file:"Resources\save.png", padding: 8} }
	Opt3 := { 1:0, 2:0xC1CAD7, 7:0x99A5B7, icon:{file:"Resources\save.png", padding: 8} }
	ImageButton.Create(HBT5, Opt1, Opt2, Opt3)

Gui, Add, Button, , Normal Button

Gui, Show,, Image Buttons
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
GuiEscape:
ExitApp
