


;-------------------------------------------------------------------------------
LV_Box(ByRef Obj, config, x:="", y:="", Width:=400, Height:=240) {
;-------------------------------------------------------------------------------
    ; display an object in an ListView control
    ; no return value
    ;---------------------------------------------------------------------------
    ; Obj       is the object to show
    ; config    describes the columns to show
    ; x         is the initial x-coord of the GUI
    ; y         is the initial y-coord of the GUI
    ; Width     is the initial width of the GUI
    ; Height    is the initial height of the GUI
    ;
    ; Note 1:
    ;           The first column is hard coded to contain the row index.
    ;           The first entry in config may contain any string,
    ;           but to keep the code clear the user should write "A_Index".
    ; Note 2:
    ;           The function automatically adds a final column which makes
    ;           programmatically adjusting the width of the "real" last column
    ;           easy and independent of the GUI's width.

    local

    ;-----------------------------------
    ; config column #2 (headers)
    ;-----------------------------------
    Headers := ""
    for each, Column in config
        Headers .= Trim(Column[2]) "|"


    ; create GUI
    Gui, LV_Box: New,, LV_Box
    Gui, +Resize -MinimizeBox -MaximizeBox
    Gui, Margin, 0, 0
    Gui, Add, ListView, w%Width% h%Height% Grid, %Headers%%A_Space%


    ;-----------------------------------
    ; config column #1 (content)
    ;-----------------------------------
    Col := []
    for each, Column in config
        if (A_Index > 1)
            Col[A_Index] := Trim(Column[1])

    for each, Row in Obj {
        Private := []
        if IsObject(Row)
            Loop, % config.Length() - 1
                Private.Push(Row[Col[A_Index + 1]])
        else
            Private.Push(each, Row)
        LV_Add("", A_Index, Private*)
    }


    ;-----------------------------------
    ; config column #3 (options)
    ;-----------------------------------
    for each, Column in config
        LV_ModifyCol(A_Index, Column[3])


    ; set width of final column to zero
    LV_ModifyCol(LV_GetCount("Col"), 0)

    Gui, Show, % (x = "" ? "" : "x" x) (y = "" ? "" : " y" y)

return ; end of function

    ;-----------------------------------
    ; event handlers
    ;-----------------------------------

    LV_BoxGuiClose:  ; {Alt+F4} pressed, [X] clicked
    LV_BoxGuiEscape: ; {Esc} pressed
        Gui, Destroy
    return

    LV_BoxGuiSize:
        GuiControl, Move, SysListView321, w%A_GuiWidth% h%A_GuiHeight%
    return
}
