#NoEnv
#SingleInstance, Force
;#Include ..\Class_Rebar.ahk

Gui, Child1:-Caption +hwndhChildWnd1
Gui, Child1:Add, Edit, yp x+10
Gui, Child1:Add, Updown, Range0-100
Gui, Child1:Add, Button, yp-1 x+0 gApply, Apply

Gui, Child2:-Caption +hwndhChildWnd2
Gui, Child2:Add, Edit, yp x+10
Gui, Child2:Add, Updown, Range0-100
Gui, Child2:Add, Button, yp-1 x+0 gApply, Apply

Gui, +Resize
Gui, Add, Custom, ClassReBarWindow32 hwndhRebar -Theme 0x0200 0x0400 0x0040 0x8000
Gui, Show, w300 h80, Multiple controls per band

RB := New Rebar(hRebar)
RB.InsertBand(hChildWnd1, 0, "", 111, "Maximum:")
RB.InsertBand(hChildWnd2, 0, "Break", 112, "Minimum:")
return

Apply:
MsgBox, %A_Gui%
return

GuiSize:
RB.ShowBand(1)
return

GuiClose:
ExitApp