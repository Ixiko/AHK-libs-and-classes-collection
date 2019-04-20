; #Include Win.ahk
; #Include Splitter.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

    w := 500, h := 600, sep := 5
    w1 := w//3, w2 := w-w1 , h1 := h // 2, h2 := h // 3

    Gui, Margin, 0, 0
    Gui, Add, Edit, HWNDc11 w%w1% h%h1%
    Gui, Add, Edit, HWNDc12 w%w1% h%h1%
    hSepV := Splitter_Add( "x+0 y0 h" h " w" sep )
    Gui, Add, Monthcal, HWNDc21 w%w2% h%h2% x+0
    Gui, Add, ListView, HWNDc22 w%w2% h%h2%, c1|c2|c3
    Gui, Add, ListBox,  HWNDc23 w%w2% h%h2% , 1|2|3

    sdef = %c11% %c12% | %c21% %c22% %c23%          ;vertical splitter.
    Splitter_Set( hSepV, sdef )

    Gui, show, w%w% h%h%
return

GuiClose:
ExitApp
