#Include "*i TheArkive_Debug.ahk"
#Include _Iron_Ioolbar.ahk

Global g := "", tb := "", ILA_big, ILA_small

g := Gui.New("","Toolbar Test"), g.OnEvent("close","GuiClose")

; =============================================================================
; Two different ways to use easyMode.  Don't use both at the same time.
tb := Toolbar.New(g,"vMyToolbar","Tooltips DrawDDArrows") ; DrawDDArrows used with DropDown button style below for split button.
; tb := Toolbar.New(g,"vMyToolbar","Tooltips DrawDDArrows",false) ; Disable mixed buttons.
; =============================================================================
; Hard Mode
; tb := Toolbar.New(g,"vMyToolbar","List Flat MixedButtons Tooltips DrawDDArrows",,false) ; Example below is not written for hard mode.
; =============================================================================
; To use "Hard Mode", refer to the Static members at the top of the Toolbar class.  Use those property names for styles and states.
; Pass those property names as text values in a single space-delimited string into sOptions when calling tb.New()

tb.IL_Create("big",["shell32.dll/127","shell32.dll/126","shell32.dll/129","shell32.dll/130","shell32.dll/131","shell32.dll/132","shell32.dll/133"],true) ; big icons
tb.IL_Create("small",["shell32.dll/127","shell32.dll/126","shell32.dll/129","shell32.dll/130","shell32.dll/131","shell32.dll/132","shell32.dll/133"]) ; small icons
tb.SetImageList("big") ; set big icons first

g.Add("Button","x120 y70 w100 vTop","Top").OnEvent("click","guiEvents")
g.Add("Button","xp y+0 w50 vLeft","Left").OnEvent("click","guiEvents")
g.Add("Button","x+0 w50 vRight","Right").OnEvent("click","guiEvents")
g.Add("Button","xp-50 y+0 w100 vBottom","Bottom").OnEvent("click","guiEvents")
g.Add("Button","y+10 w100 vCustomize","Old Customizer").OnEvent("click","guiEvents")
g.Add("Button","y+0 w100 vCustomizer","Customizer").OnEvent("click","guiEvents")
g.Add("Button","y+10 w100 vExIm","Export / Import").OnEvent("click","guiEvents")

g.Add("Button","x+20 y70 w50 vMove Section","Move").OnEvent("click","guiEvents")
g.Add("Text","x+2 yp+4","From:")
g.Add("Edit","x+2 yp-4 w30 Center vMoveFrom","2")
g.Add("Text","x+2 yp+4","To:")
g.Add("Edit","x+2 yp-4 w30 Center vMoveTo","3")

g.Add("Button","xs y+2 w80 vShowText Section","Show Text").OnEvent("click","guiEvents")
g.Add("Button","x+0 w80 vHideText","Hide Text").OnEvent("click","guiEvents")

g.Add("Button","xs y+0 w80 vSmallIcons","Small Icons").OnEvent("click","guiEvents")
g.Add("Button","x+0 w80 vLargeIcons","Large Icons").OnEvent("click","guiEvents")

g.Add("Button","xs y+0 w65 vHide","Hide").OnEvent("click","guiEvents")
g.Add("Button","x+0 w65 vShow","Show").OnEvent("click","guiEvents")
g.Add("Edit","x+0 w30 vHideNum Center",5)

g.Add("Button","xs y+0 w65 vEnable","Enable").OnEvent("click","guiEvents")
g.Add("Button","x+0 w65 vDisable","Disable").OnEvent("click","guiEvents")
g.Add("Edit","x+0 w30 vEnableNum Center",5)

g.Add("Text","x120 y+60","Numbers indicate positions of`r`nbuttons/separators (not zero-based).")

e := g.Add("Edit","x120 y+10 h150 w280 vEdit ReadOnly")
e.SetFont("","Consolas")

g.Show("w600 h500")

tb.Add([{label:"Button 1", icon:-1} ; set icon:-1 to use a text button (automatically applies "ShowText" style)
       ,{label:""}                  ; set label:"" and no other properties to use a separator
       ,{label:"Button 2", icon:2, styles:"ShowText"} ; set icon index and "ShowText" style to have a button with icon and text
       ,{label:""}
       ,{label:"Button 3", icon:3, styles:"WholeDropDown"}  ; DropDown button with arrow NOT split from main button
       ,{label:"Button 4", icon:4, styles:"DropDown"}       ; DropDown split button, requires DrawDDArrows style above
       ,{label:""}
       ,{label:"Button 5", icon:5, styles:"Check CheckGroup"} ; index 8
       ,{label:"Button 6", icon:6, styles:"Check CheckGroup"} ; index 9
       ,{label:""}
       ,{label:"Button 7", icon:7, styles:"Check"}])


; d props: {event:str, eventInt:int                         ; event data
        ; , index:int, idCmd:int, label:str                 ; data for clicked/hovered button
        ; , dims:{x:int, y:int, b:int, w:int, h:int}        ; button x/y/w/y, b = bottom of button y value
        ; , hoverFlags:str, hoverFlagsInt:int               ; more specific hover data
        ; , vKey:int, char:int                              ; when hovering + keystroke, these are populated
        ; , oldIndex:int, oldIdCmd:int, oldLabel:str}       ; for initially dragged button, or previous hot item
           
; events: LClick, LDClick, LDown, RClick, RDClick   ; mouse click events
        ; Char, KeyDown                             ; hover + keystroke events
        ; BeginDrag, DragOut, EndDrag, DragOver     ; drag/drop events
        ; DropDown                                  ; clicking drop-down arrow (on separated drop-down button)
        ; DeletingButton                            ; delete button event
        ; HotItemChange                             ; hover events
        ;
        ; NOTE: I have yet to get the DragOver event to actually fire.
        ;
        ; - These events fire but do not currently populate data in dataObj.
        ; CustomDraw, DupAccelerator, GetDispInfo, GetObject, GetTipInfo, MapAccelerator, ReleasedCapture, ToolTipsCreated, WrapAccelerator, WrapHotItem

; See Static wm_n member for a full list of events.
tbEvent(tb, lParam, dataObj) {
    char := (dataObj.char > 0) ? Chr(dataObj.char) : ""
    
    If InStr(dataObj.event,"hot")
        g["Edit"].Value := "Hot Item:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "index / idCmd / label / checked:`r`n    " dataObj.index " / " dataObj.idCmd " / " dataObj.label " / " dataObj.checked "`r`n`r`n"
                         . "old index / idCmd:     " dataObj.oldIndex " / " dataObj.oldIdCmd "`r`n`r`n"
                         . "flags: " dataObj.hoverFlags " / " Format("0x{:X}",dataObj.hoverFlagsInt) "`r`n"
                         . "RECT X/Y/W/H: " dataObj.dims.X " / " dataObj.dims.Y " / " dataObj.dims.W " / " dataObj.dims.H
    Else If InStr(dataObj.event,"drag")
        g["Edit"].Value := "Drag Info:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "index / idCmd / label / checked:`r`n    " dataObj.index " / " dataObj.idCmd " / " dataObj.label " / " dataObj.checked "`r`n`r`n"
                         . "old index / idCmd:     " dataObj.oldIndex " / " dataObj.oldIdCmd "`r`n`r`n"
                         . "RECT X/Y/W/H: " dataObj.dims.X " / " dataObj.dims.Y " / " dataObj.dims.W " / " dataObj.dims.H
    Else If (dataObj.event = "char") Or (dataObj.event = "KeyDown")
        g["Edit"].Value := "Keyboard Events:`r`n`r`n"
                         . "Event: " dataObj.event "`r`n"
                         . "vKey: " dataObj.vKey "`r`n"
                         . "Char: " dataObj.char " / " char "`r`n"
                         . "index / idCmd / label / checked:`r`n    " dataObj.index " / " dataObj.idCmd " / " dataObj.label " / " dataObj.checked "`r`n`r`n"
    Else If (dataObj.event = "DropDown")
        msgbox "Drop arrow clicked on a split button, or DropDown button with WholeDropDown style clicked."
    
    ; Else If (InStr(dataObj.event,"click")) ; Choose an event to filter by, and if needed, a specific button.
        ; Msgbox dataObj.label " clicked."   ; You can identify buttons by idCmd, index, or label from dataObj.
}

guiEvents(ctl,info) {
    n := ctl.Name
    If (n="top" or n="left" or n="right" or n="bottom")
        tb.Position(n)
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
    }
}

GuiClose(g) {
    ExitApp
}