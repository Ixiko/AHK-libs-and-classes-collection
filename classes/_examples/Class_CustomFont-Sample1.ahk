#Include Class_CustomFont.ahk
font1 := New CustomFont("CHOCD TRIAL___.otf")

Gui, Margin, 30, 10
Gui, Color, DECFB2
Gui, Font, s100 c510B01, Chocolate Dealer
Gui, Add, Text, w400, Chocolate
Gui, Show
Return

GuiClose:
ExitApp