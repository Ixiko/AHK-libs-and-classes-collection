#NoEnv
SetBatchLines, -1
#Include %A_ScriptDir%\..\Class_ImageButton.ahk
; ----------------------------------------------------------------------------------------------------------------------
Gui, DummyGUI:Add, Pic, hwndHPIC, % A_ScriptDir "\Resources\PIC1.jpg"
SendMessage, 0x0173, 0, 0, , ahk_id %HPIC% ; STM_GETIMAGE
HPIC1 := ErrorLevel
; ----------------------------------------------------------------------------------------------------------------------
; Button states:
; PBS_NORMAL    = 1
; PBS_HOT       = 2
; PBS_PRESSED   = 3
; PBS_DISABLED  = 4
; PBS_DEFAULTED = 5
; PBS_STYLUSHOT = 6 <- used only on tablet computers
; ----------------------------------------------------------------------------------------------------------------------
GuiColor := "Blue"
Gui, Margin, 50, 20
Gui, Font, s10
Gui, Color, %GuiColor%
ImageButton.SetGuiColor(GuiColor)
; Common button --------------------------------------------------------------------------------------------------------
Gui, Add, Button, w200, Common Button
; Unicolored button rounded by half of its height with different colors for states normal, hot and defaulted -----------
Gui, Add, Button, vBT1 w200 hwndHBT1, Button 1`nLine 2
Opt1 := [0, 0x80CF0000, , "White", "H", , "Red", 4]         ; normal flat background & text color
Opt2 := [ , "Red"]                                          ; hot flat background color
Opt5 := [ , , ,"Gray"]                                      ; defaulted text color -> animation
If !ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)
   MsgBox, 0, ImageButton Error Btn1, % ImageButton.LastError
; Vertical bicolored  button with different 3D-style colors for states normal, hot, and pressed ------------------------
Gui, Add, Button, vBT2 w200 h30 hwndHBT2, Button 2
Opt1 := [1, 0xC0E0E0E0, 0xC0B0E0FF, 0x60000000]             ; normal background & text colors
Opt2 := {2: 0xE0E0E0, 3: 0xB0E0FF, 4: "Black"}              ; hot background & text colors (object syntax)
Opt3 := {4: "Red"}                                          ; pressed text color (object syntax)
If !ImageButton.Create(HBT2, Opt1, Opt2, Opt3)
   MsgBox, 0, ImageButton Error Btn2, % ImageButton.LastError
; Raised button with different 3D-style colors for states normal, hot, and disabled ------------------------------------
Gui, Add, Button, vBT3 w200 Disabled hwndHBT3, Button 3
Opt1 := [6, 0x80404040, 0xC0C0C0, "Yellow"]                 ; normal background & text colors
Opt2 := [ , 0x80606060, 0xF0F0F0, 0x606000]                 ; hot background & text colors
Opt4 := [0, 0xC0A0A0A0, , 0xC0606000]                       ; disabled flat background & text colors
If !ImageButton.Create(HBT3, Opt1, Opt2, "", Opt4)
   MsgBox, 0, ImageButton Error Btn3, % ImageButton.LastError
Gui, Font
Gui, Add, CheckBox, xp y+0 w200 gCheck vCheckBox, Enable!
; Image button without caption with different pictures for states normal and hot ---------------------------------------
Gui, Add, Button, vBT4 w200 h30 hwndHBT4
Opt1 := [0, HPIC1]                                          ; normal image
Opt2 := {2: A_ScriptDir "\Resources\PIC2.jpg"}                         ; hot image (object syntax)
If !ImageButton.Create(HBT4, Opt1, Opt2)
   MsgBox, 0, ImageButton Error Btn4, % ImageButton.LastError
; GuiControl, Focus, BT2
Gui, Show, , Image Buttons
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
GuiEscape:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
Check:
   GuiControlGet, CheckBox
   GuiControl, Enable%CheckBox%, BT3
   GuiControl, Text, CheckBox, % (CheckBox ? "Disable!" : "Enable!")
Return
