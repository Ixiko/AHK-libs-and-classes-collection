


;-------------------------------------------------------------------------------
PictureBox(Title := "", Picture := "", x:="", y:="") {
;-------------------------------------------------------------------------------
    ; show a picture, then wait until user dismisses the GUI
    ; no return value
    ;---------------------------------------------------------------------------
    ; Title is the title for the GUI
    ; Picture is the path\to\picture to display

    ; create GUI
    Gui, PictureBox: New,, %Title%
    Gui, -MinimizeBox
    Gui, Margin, 30, 18
    Gui, Add, Picture,, %Picture%
    Gui, Show, % (x = "" ? "" : "x" x) (y = "" ? "" : " y" y)

    ; main wait loop
    Gui, +LastFound
    WinWaitClose

return ; end of function


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    PictureBoxGuiClose:     ; {Alt+F4} pressed, [X] clicked
    PictureBoxGuiEscape:    ; {Esc} pressed
        Gui, Destroy
    return
}
