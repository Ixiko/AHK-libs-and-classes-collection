#Include "*i TheArkive_Debug.ahk"
#Include _Iron_Toolbar.ahk

Global g := "", tb:=""

g := Gui("+Resize","Toolbar Test")
g.OnEvent("close",GuiClose)
g.OnEvent("size",GuiSize)

; =====================================================================================================
; g.Add("Toolbar", "normal_AHK_gui_options", "styles string", MixedButtons:=true, EasyMode:=false)
;
; Styles (asterisk (*) denotes commonly used styles):
;   HELP URL: https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-control-and-button-styles
;
;   AltDrag, CustomErase, *Flat, *List, RegisterDrop, *Tooltips, Transparent, *Wrapable
;   Top, Buttom, Left, Right
;
;        NOTE: Flat style is added automatically to ensure separators can be displayed.
;
; ExStyles (asterisk (*) denotes commonly used exStyles):
;   HELP URL: https://docs.microsoft.com/en-us/windows/win32/controls/toolbar-extended-styles
;
;   DoubleBuffer, *DrawDDArrows, HideClippedButtons, *MixedButtons, MultiColumn, *Vertical
;
;       NOTE: MixedButtons is always applied by default.  It only takes affect when the 
;             "List" style is also applied.  To disable MixedButtons, specify FALSE
;             in the 4th parameter when using Gui.Add()

tb  := g.AddToolbar("vMyToolbar", "Tooltips List DrawDDArrows wrapable ShowText")
tb2 := g.AddToolbar("vMyToolbar2", "Tooltips DrawDDArrows bottom wrapable ShowText")

; Styles used in this example:
;
;   Tooltips          - Ensures specified button text is displayed as a tooltip when the mouse hovers over the button.
;   List              - Displays button text to the right of the icon, if specified.  This style is required for text-only buttons.
;   DrawDDArrows (ex) - Allows the creation of split buttons when specifying DropDown button style.  To use a DropDownButton that
;                       does not have a split use WholeDropDown button style when using this toolbar style.  Otherwise there is no
;                       difference between WholeDropDown and DropDown button styles.
;   Wrapable          - Allows the toolbar to automatically wrap on window resizing.  See GuiSize() function below.
;   Bottom            - Docks the toolbar at the bottom of the window when created.  You can also specify Left or Right.  Top is
;                       the default, so no need to specify it.
;   ShowText          - Not a true toolbar style.  But use this to ensure that specified text is shown on toolbar creation.
;                       Toolbar text can also be toggled with > tb.ShowText(true/false)

; =====================================================================================================
; Adding icons to an ImageList.  With IronToolbar, you actually specify a name for the ImageList too.
; Usage:
;
;   tb.IL_Create("IL_name", [array], LargeIcons:=false)
;
;       IL_name     - A name you specify for the image list.
;       array       - Format: [file_name/index, ...] or each entry can be a path to an image.
;       LargeIcons  - Default is small icons.  Specify true for large icons.
; =====================================================================================================
tb.IL_Create("big",["shell32.dll/127" ; file_Name/icon_index
                   ,"shell32.dll/126"
                   ,"shell32.dll/129"
                   ,"shell32.dll/130"
                   ,"shell32.dll/131"
                   ,"shell32.dll/132"
                   ,"shell32.dll/133"],true) ; big icons

tb.IL_Create("small",["shell32.dll/127"
                     ,"shell32.dll/126"
                     ,"shell32.dll/129"
                     ,"shell32.dll/130"
                     ,"shell32.dll/131"
                     ,"shell32.dll/132"
                     ,"shell32.dll/133"]) ; small icons

tb.SetImageList("big") ; set big icons first

tb2.IL_Create("big",["shell32.dll/127"
                    ,"shell32.dll/126"
                    ,"shell32.dll/129"
                    ,"shell32.dll/130"
                    ,"shell32.dll/131"
                    ,"shell32.dll/132"
                    ,"shell32.dll/133"],true) ; big icons

tb2.IL_Create("small",["shell32.dll/127"
                      ,"shell32.dll/126"
                      ,"shell32.dll/129"
                      ,"shell32.dll/130"
                      ,"shell32.dll/131"
                      ,"shell32.dll/132"
                      ,"shell32.dll/133"]) ; small icons

tb2.SetImageList("big") ; set big icons first

; =====================================================================================================
; Create the GUI - Note that you must not rely on the position of the toolbar for setting the positions
;                  for the rest of the controls in your GUI.
; =====================================================================================================
g.Add("Button","x120 y70 w100 vTop","Top").OnEvent("click",guiEvents)
g.Add("Button","xp y+0 w50 vLeft","Left").OnEvent("click",guiEvents)
g.Add("Button","x+0 w50 vRight","Right").OnEvent("click",guiEvents)
g.Add("Button","xp-50 y+0 w100 vBottom","Bottom").OnEvent("click",guiEvents)
g.Add("Button","y+10 w100 vCustomize","Old Customizer").OnEvent("click",guiEvents)
g.Add("Button","y+0 w100 vCustomizer","Customizer").OnEvent("click",guiEvents)
g.Add("Button","y+10 w100 vExIm","Export / Import").OnEvent("click",guiEvents)

g.Add("Button","x+20 y70 w50 vMove Section","Move").OnEvent("click",guiEvents)
g.Add("Text","x+2 yp+4","From:")
g.Add("Edit","x+2 yp-4 w30 Center vMoveFrom","2")
g.Add("Text","x+2 yp+4","To:")
g.Add("Edit","x+2 yp-4 w30 Center vMoveTo","3")

g.Add("Button","xs y+2 w80 vShowText Section","Show Text").OnEvent("click",guiEvents)
g.Add("Button","x+0 w80 vHideText","Hide Text").OnEvent("click",guiEvents)

g.Add("Button","xs y+0 w80 vSmallIcons","Small Icons").OnEvent("click",guiEvents)
g.Add("Button","x+0 w80 vLargeIcons","Large Icons").OnEvent("click",guiEvents)

g.Add("Button","xs y+0 w65 vHide","Hide").OnEvent("click",guiEvents)
g.Add("Button","x+0 w65 vShow","Show").OnEvent("click",guiEvents)
g.Add("Edit","x+0 w30 vHideNum Center",5)

g.Add("Button","xs y+0 w65 vEnable","Enable").OnEvent("click",guiEvents)
g.Add("Button","x+0 w65 vDisable","Disable").OnEvent("click",guiEvents)
g.Add("Edit","x+0 w30 vEnableNum Center",5)

g.Add("Button","xs y+0 vRemList","Rem Mixed Btns").OnEvent("click",guiEvents)
g.Add("Button","x+0 vAddList","Add Mixed Btns").OnEvent("click",guiEvents)

g.Add("Text","x120 y+60","Numbers indicate positions of`r`nbuttons/separators (not zero-based).")

e := g.Add("Edit","x120 y+10 h150 w280 vEdit ReadOnly")
e.SetFont("","Consolas")

g.Show("w600 h550")

; =====================================================================================================
; Adding buttons:
; With easyMode = true (the default) add buttons like so:
;   NOTE: At a minimum each button entry MUST have a "label" property.
;   Usage:
;
;       tb.Add( [ {button}, {button}, ...] )
;           - Each {button} is an {object} with prop/value pairs.
;           - Properties that can be used:
;               - label, icon, styles, states
; =====================================================================================================

tb.Add([{label:"Button 1", icon:-1} ; Set {icon:-1} to use a text button (automatically applies "ShowText" style)
       ,{label:""}                  ; Set label:"" to use a separator.
       ,{label:"Button 2", icon:2, styles:"ShowText"} ; Set icon index and "ShowText" style to have a button with icon and text.
       ,{label:""}                                    ; ... "ShowText" only applies when using MixedButtons and List toolbar style. See above.
                                                      ; ... MixedButtons is enabled by default, but List is not enabled by default. See above.
       ,{label:"Button 3", icon:3, styles:"WholeDropDown"}    ; DropDown button with arrow NOT split from main button.
       ,{label:"Button 4", icon:4, styles:"DropDown"}         ; DropDown split button, requires DrawDDArrows style above.
       ,{label:""}
       ,{label:"Button 5", icon:5, styles:"Check CheckGroup"} ; Creates a check button and adds it to a group.
       ,{label:"Button 6", icon:6, styles:"Check CheckGroup"} ; Add more like this to add to the group
       ,{label:""}
       ,{label:"Button 5", icon:5, styles:"Check CheckGroup"} ; Specify a separator, or other button to split up groups.
       ,{label:"Button 6", icon:6, styles:"Check CheckGroup"} ; Making another check group...
       ,{label:""}
       ,{label:"Button 7", icon:7, styles:"Check"}])          ; Make a single check button.

tb2.Add([{label:"Button 1", icon:-1}
       ,{label:""}
       ,{label:"Button 2", icon:2, styles:"ShowText"}
       ,{label:""}
       ,{label:"Button 3", icon:3, styles:"WholeDropDown"}
       ,{label:"Button 4", icon:4, styles:"DropDown"}
       ,{label:""}
       ,{label:"Button 5", icon:5, styles:"Check CheckGroup"}
       ,{label:"Button 6", icon:6, styles:"Check CheckGroup"}
       ,{label:""}
       ,{label:"Button 7", icon:7, styles:"Check"}])
; =====================================================================================================
; Using button states is a bit outside the scope of this example, but it's not difficult.  Most states
; can be modified with available toolbar control methods, so directly modifying the states of a button
; is usually not necessary.  See the help files on GitHub for a complete list of methods used to set
; button states, like HIDDEN, ENABLED, CHECKED, etc.
; =====================================================================================================
; Toolbar event callback:  tbEvent(tb, lParam, dataObj)
;
;   The default callback function name is: "tbEvent"
;   To specify a different name, after creating the toolbar, modify the .callback property:
;
;       tb.callback := "my_callback"
;           You can alsoy specify a Func / BoundFunc obj to use instead of a string.

;                  prop:type     prop:type
; dataObj props: {event:str, eventInt:int                         ; event data
;               , index:int, idCmd:int, label:str                 ; data for clicked/hovered button
;               , dims:{x:int, y:int, b:int, w:int, h:int}        ; button x/y/w/h and b=bottom of button y value
;               , hoverFlags:str, hoverFlagsInt:int               ; more specific hover data
;               , vKey:int, char:int                              ; when hovering + keystroke, these are populated
;               , oldIndex:int, oldIdCmd:int, oldLabel:str}       ; for initially dragged button, or previous hot item
           
; events: LClick, LDClick, LDown, RClick, RDClick   ; mouse click events
        ; Char, KeyDown                             ; hover + keystroke events
        ; BeginDrag, DragOut, EndDrag, DragOver     ; drag/drop events
        ; DropDown                                  ; clicking drop-down arrow (or split/separated drop-down button arrow)
        ; DeletingButton                            ; delete button event
        ; HotItemChange                             ; hover events
        ;
        ; NOTE: I have yet to get the DragOver event to actually fire.
        ;
        ; - These events fire but do not currently populate data in dataObj.
        ; CustomDraw, DupAccelerator, GetDispInfo, GetObject, GetTipInfo, MapAccelerator
        ; , ReleasedCapture, ToolTipsCreated, WrapAccelerator, WrapHotItem

; See Static wm_n member in the Toolbar class for a full list of events.
; =====================================================================================================
tbEvent(tb, lParam, dataObj) { ; use tb.name to filter if you have multiple toolbars
    char := (dataObj.char > 0) ? Chr(dataObj.char) : ""
    
    If InStr(dataObj.event,"hot")
        g["Edit"].Value := tb.name " / Hot Item:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "index / idCmd /   label  / checked:`r`n" 
                         . "  " dataObj.index "   / " dataObj.idCmd "  / " dataObj.label " /    " dataObj.checked "`r`n`r`n"
                         . "old index / idCmd:     " dataObj.oldIndex " / " dataObj.oldIdCmd "`r`n`r`n"
                         . "flags: " dataObj.hoverFlags " / " Format("0x{:X}",dataObj.hoverFlagsInt) "`r`n"
                         . "RECT X/Y/W/H: " dataObj.dims.X " / " dataObj.dims.Y " / " dataObj.dims.W " / " dataObj.dims.H
    Else If InStr(dataObj.event,"drag")
        g["Edit"].Value := tb.name " / Drag Info:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "index / idCmd / label / checked:`r`n    "
                         . dataObj.index " / " dataObj.idCmd " / " dataObj.label " / " dataObj.checked "`r`n`r`n"
                         . "old index / idCmd:     " dataObj.oldIndex " / " dataObj.oldIdCmd "`r`n`r`n"
                         . "RECT X/Y/W/H: " dataObj.dims.X " / " dataObj.dims.Y " / " dataObj.dims.W " / " dataObj.dims.H
    Else If (dataObj.event = "char") Or (dataObj.event = "KeyDown")
        g["Edit"].Value := tb.name " / Keyboard Events:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "vKey: " dataObj.vKey "`r`n"
                         . "Char: " dataObj.char " / " char "`r`n"
                         . "index / idCmd / label / checked:`r`n    "
                         . dataObj.index " / " dataObj.idCmd " / " dataObj.label " / " dataObj.checked "`r`n`r`n"
    Else If (dataObj.event = "DropDown") {
        tb.GetPos(&x, &y) ; get toolbar x, y - Important for drop menus!  Add these values to dataObj.dims.x/y to get proper menu position.
        sample_menu(dataObj.dims.x + x, dataObj.dims.b + y) ; dataObj.dims x/y is relative to the toolbar, not the window
    } Else If (dataObj.event = "RClick" And dataObj.idCmd)
        Msgbox "Right-click: " tb.name "`r`n" dataObj.label " / " dataObj.idCmd
}

sample_menu(x,y) {
    m := Menu()
    m.Add("Option 1", menu_events)
    m.Add("Option 2", menu_events)
    m.Add("Option 3", menu_events)
    m.Show(x,y)
}

menu_events(ItemName, ItemPos, Menu) {
    msgbox "You clicked: " ItemName
}

guiEvents(ctl,info) {
    tb := ctl.gui["MyToolbar"]
    n := ctl.Name
    If (n="top" or n="left" or n="right" or n="bottom")
        tb.Position(n), tb.Position(n)
    Else If (n="Move")
        tb.MoveButton(ctl.gui["MoveFrom"].Value,ctl.gui["MoveTo"].Value)
    Else If (n="ShowText")
        tb.ShowText(true)
    Else If (n="HideText")
        tb.ShowText(false)
    Else If (n="SmallIcons")
        tb.SetImageList("small")
    Else If (n="LargeIcons")
        tb.SetImageList("big")
    Else If (n="Hide")
        tb.HideButton(ctl.gui["HideNum"].Value,true)
    Else If (n="Show")
        tb.HideButton(ctl.gui["HideNum"].Value,false)
    Else If (n="Enable")
        tb.EnableButton(ctl.gui["EnableNum"].Value,true)
    Else If (n="Disable")
        tb.EnableButton(ctl.gui["EnableNum"].Value,false)
    Else If (n="Customize")
        tb.OldCustomize()
    Else If (n="Customizer")
        tb.Customizer()
    Else If (n="ExIm") {
        Msgbox "Exporting/Clearing the toolbar...."
        btnLayout := tb.Export()
        tb.ClearButtons()
        MsgBox "Now importing."
        tb.Import(btnLayout)
    } Else If (n="RemList") {
        tb.MixedButtons(false)
    } Else If (n="AddList") {
        tb.MixedButtons(true)
    }
}

GuiClose(g) {
    ExitApp
}

GuiSize(gui, MinMax, _w, _h) {  ; Resize/move toolbar on window resize.
    tb := gui["MyToolbar"]
    tb2 := gui["MyToolbar2"]
    Toolbar.SizeToolbar(tb2, _w, _h)   ; <--- The easy way to make sure your toolbars stay docked where they should.
    Toolbar.SizeToolbar(tb, _w,_h)     ; This works regardless of what position the toolbar is in:  top, bottom, left, right.
}                                      ; Per-Toolbar usage is useful if you want a vertical toolbar in the middle of the GUI
                                       ; as a sort of separator.  In this case you will need to manually control the resizing.

