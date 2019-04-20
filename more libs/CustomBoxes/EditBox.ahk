


;-------------------------------------------------------------------------------
EditBox(VarName, X := "", Y := "", Width := 400, Height := 200) {
;-------------------------------------------------------------------------------
    ; display a variable in an edit box
    ; no return value
    ;---------------------------------------------------------------------------
    ; VarName is the name of the variable to show
    ; VarName is also the title for the GUI
    ; X       is the initial x coord of the GUI
    ; Y       is the initial y coord of the GUI
    ; Width   is the initial width of the GUI
    ; Height  is the initial height of the GUI


    ; create GUI
    Saved := A_DefaultGui
    Gui, EditBox: New,, %VarName%
    Gui, +Resize -MinimizeBox -MaximizeBox
    Gui, Margin, 0, 0
    Gui, Font, s12, Fixedsys Excelsior 3.01
    Gui, Add, Edit, w%Width% h%Height% Multi, % %VarName% ; dynamic reference
    Gui, Show, % (X = "" ? "" : "x" X) (Y = "" ? "" : " y" Y)
    Gui, %Saved%: Default

    ; main wait loop
    Gui, EditBox: +LastFound
    SendMessage, 0xB1, -1,, Edit1 ; EM_SETSEL
    WinWaitClose

return


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    EditBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    EditBoxGuiEscape: ; {Esc} pressed
        Gui, Destroy
    return

    EditBoxGuiSize:
        GuiControl, Move, Edit1, w%A_GuiWidth% h%A_GuiHeight%
    return
}
