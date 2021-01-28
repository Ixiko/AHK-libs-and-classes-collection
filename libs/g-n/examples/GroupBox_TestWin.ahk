#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#Include %A_ScriptDir%\GroupBox.ahk

GBTHeight:=10
Gui, +LastFound AlwaysOnTop
Gui, Add, Text, vLabel1, A Label
Gui, Add, Text, x162 yMargin vLabel2, Another Label
Gui, Add, Edit, Section vMyEdit1 xMargin, This is a Control
Gui, Add, Edit, vMyEdit2 ys x162, This is a Control
Gui, Add, CheckBox, Section vCheck1 xMargin, CheckBox 1
Gui, Add, CheckBox, vCheck2 ys x160 Checked, CheckBox 2
GroupBox("GB1", "Testing", "Label1|Label2|MyEdit1|MyEdit2|Check1|Check2", 10, GBTHeight)
Gui, Add, Text, Section xMargin, This is un-named
Gui, Add, DropDownList, xMargin vDDL W100, Line 1|Line 2||Line 3
GroupBox("GB2", "Another Test", "This is un-named|DDL", 10, GBTHeight)
Gui, Add, Text, yS, This is a control
Gui, Add, DateTime, vMyDateTime w127
GroupBox("GB3", "Test", "Static4|MyDateTime", 10, GBTHeight)
GroupBox("SideBy", "Side-by-Side Wrapper", "GB2|GB3", 10, GBTHeight)
Gui, Add, Button, xm vButtonT, Button Top
Gui, Add, Text, vMyText xMargin, Some text to read.
Gui, Add, Button, Section x60, Button 1
Gui, Add, Button, ys x+10, Button 2
GroupBox("GB4", "Buttons Too", "Button 1|Button 2", 10, GBTHeight)
GuiControlGet, GB4, Pos
Gui, Add, Button, vButtonR W%GB4W%, Button Right
GroupBox("GB5", "Around Another GroupBox", "MyText|GB4|ButtonR", 10, GBTHeight, 250)
GuiControlGet, GB5, Pos
GuiControl, Move, ButtonT, W%GB5W%
Gui, Add, Button, vButtonB, Button Bottom
GroupBox("GB6", "I added a box!", "ButtonT|ButtonB|GB5", 10, GBTHeight)

GuiControlGet, SideBy, Pos
GuiControl, MoveDraw, GB6, W%SideByW%

Gui, Add, Button,, It's the Final Countdown!
Gui, Show, , GroupBox Test

return

GuiClose:
ExitApp
