


;-------------------------------------------------------------------------------
TreeBox(ByRef Obj, Name:="", x:="", y:="", Width:=240, Height:=400) {
;-------------------------------------------------------------------------------
    ; display an object as tree
    ; no return value
    ;---------------------------------------------------------------------------
    ; Obj, Name is the object to show
    ; x       is the initial x coord of the GUI
    ; y       is the initial y coord of the GUI
    ; Width   is the initial width of the GUI
    ; Height  is the initial height of the GUI

    local

    ; create GUI
    Saved := A_DefaultGui
    Gui, TreeBox: New,, TreeBox
    Gui, +Resize -MinimizeBox -MaximizeBox
    Gui, Margin, 0, 0
    Gui, Add, TreeView, w%Width% h%Height%

    ; get the details
    if isCircular(Obj)
        TV_Add("Circular reference", TV_Add(Name,, "Expand"))
    else ; recurse
        PopulateTree(Obj, Name)

    ; main loop
    Gui, Show, % (x = "" ? "" : "x" x) (y = "" ? "" : " y" y)
    Gui, %Saved%: Default

return ; end of function


    ;-----------------------------------
    ; event handlers
    ;-----------------------------------
    TreeBoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    TreeBoxGuiEscape: ; {Esc} pressed
        Gui, Destroy
    return

    TreeBoxGuiSize:
        GuiControl, Move, SysTreeView321, w%A_GuiWidth% h%A_GuiHeight%
    return
}



;-------------------------------------------------------------------------------
PopulateTree(ByRef Obj, Name, ParentID:=0, Key:="") { ; populate the tree
;-------------------------------------------------------------------------------
    local
    static Value := ""
    Root := TV_Add(Key ? Key : Name, ParentID, "Expand")
    for Key, Value in Obj
        if IsObject(Value)
            PopulateTree(Value, "Value", Root, Key)
        else
            TV_Add(Value, TV_Add(Key, Root, "Expand"))
}



;-------------------------------------------------------------------------------
isCircular(Obj, Objs:=0, dummy:=0) { ; return true if Obj is circular
;-------------------------------------------------------------------------------
    local
    if not IsObject(Objs)
        Objs := []
    for each, Value in Obj
        if IsObject(Value)
            if Objs[&Value] or isCircular(Value, Objs, Objs[&Value] := True)
                return True
    return False
}
