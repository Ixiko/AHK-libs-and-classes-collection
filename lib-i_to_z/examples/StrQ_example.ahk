#NoEnv
#SingleInstance, Force

MAXQ := 14
Fruits := "Apple|Banana|Cherry|Durian|Fig|Grape|Kumquat|Lychee|Mango|Nectarine|Orange|Papaya|Quince|Yuzu"

Gui, Font, S11, Calibri
Gui, Margin, 5, 5
Gui, Add, Text, xm ym w400, Type a string and press <Enter> 
Gui, Add, ComboBox, xm y+5 wp r14 Simple vChoice, %Fruits%
Gui, Add, Button, xm+10 y+10 w100 h24 Default gSelFruit, Add/Select
Gui, Show,,StrQ() demo
Return

GuiClose:
 ExitApp
 
SelFruit:
 GuiControlGet, Choice
 StringReplace, Choice, Choice, |,, All                        ; Delimiter shouldn't be present in string 
 Fruits := StrQ( Fruits, Choice, MAXQ )
 GuiControl,, Choice, % "|" Fruits 
Return 
