


;-------------------------------------------------------------------------------
TreeBox(ArrName, X := "", Y := "", Width := 240, Height := 400, Wait := True) {
;-------------------------------------------------------------------------------
    ; display an array as tree, no return value
    ;
    ; ArrName is the name of the array to show
    ; X       is the initial x coord of the GUI
    ; Y       is the initial y coord of the GUI
    ; Width   is the initial width of the GUI
    ; Height  is the initial height of the GUI
    ;---------------------------------------------------------------------------

    Coords := (X = "" ? "" : "x" X) (Y = "" ? "" : " y" Y)

    ; create GUI
    Gui, TreeBox: New, +LastFound, TreeBox
    Gui, +Resize -MinimizeBox -MaximizeBox
    Gui, Margin, 0, 0
    Gui, Add, TreeView, w%Width% h%Height%

    ; get the details
    If IsCircular(%ArrName%)
        TV_Add("Circular reference", TV_Add(ArrName,, "Expand"))
    Else
        PopulateTree(ArrName) ; recursive

    ; main loop
    Gui, Show, %Coords%
    IfEqual, Wait, %True%, WinWaitClose
    Return


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    TreeBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    TreeBoxGuiEscape: ; {Esc} pressed
        Gui, Destroy
    Return

    TreeBoxGuiSize:
        GuiControl, Move, SysTreeView321, w%A_GuiWidth% h%A_GuiHeight%
    Return
}



;-------------------------------------------------------------------------------
PopulateTree(ArrName, ParentID := 0, Key := "") { ; populate the tree
;-------------------------------------------------------------------------------
    static Value

    Root := TV_Add(Key ? Key : ArrName, ParentID, "Expand")
    For Key, Value in %ArrName%
        If IsObject(Value)
            PopulateTree("Value", Root, Key)
        Else
            TV_Add(Value, TV_Add(Key, Root, "Expand"))
}



;-------------------------------------------------------------------------------
IsCircular(oArray, Objs := 0, dummy := 0) { ; return true if oArray is circular
;-------------------------------------------------------------------------------
    If Not Objs
        Objs := {}
    For each, Value in oArray
        If IsObject(Value)
            If Objs[&Value] Or IsCircular(Value, Objs, Objs[&Value] := 1)
                Return, True

    Return, False
}
