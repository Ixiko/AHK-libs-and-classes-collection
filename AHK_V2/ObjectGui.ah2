; Created by AHK_user 2022-05-11
; Based on V1 Array_Gui by Geekdude
; https://www.autohotkey.com/boards/viewtopic.php?t=35124
#Requires AutoHotKey v2.0-beta.3
; #SingleInstance force

; atest := ["test", "tast", 2, 3]
; atest := Object()
; atest.test := "ds"
; aTest := EditGui(aTest)
; ObjectGui(aTest)
; aTest.test := "1"
; MsgBox(aTest[1])
; aTest := EditGui("test")
; MsgBox(aTest)
;; Example code to demonstate
; oarray:= [{Apples: ["Red", "Crunchy", "Lumpy"], Oranges: ["Orange", "Squishy", "Spherical"] },"Test",{test:1},["1","bleu"],Map("sdfs",2,"sdd",{test:5,name:10},"objectExample",["1","3","4"])]
; oarray.prop1 := "test"
; Obj_Gui(oarray)

; myGui := Gui()
; ogcTreeView := myGui.AddTreeView("w300 h200")
; myGui.AddText(,"test")
; myGui.Show()
; Obj_Gui(myGui)

; Displays the content of the variable
ObjectGui(Array, ParentID := "") {
    static ogcTreeView
    if !ParentID{
        Gui_object := Gui()
        Gui_object.Opt("+Resize")
        Gui_object.OnEvent("Size", Gui_Size)
        Gui_object.MarginX := "0", Gui_object.MarginY := "0"
        if (IsObject(Array)){
            ogcTreeView := Gui_object.AddTreeView("w300 h300")
            ogcTreeView.OnEvent("ContextMenu", ContextMenu_TreeView)
            ItemID := ogcTreeView.Add("(" type(Array) ")", 0, "+Expand")
            ObjectGui(Array, ItemID)
        }
        else{
            ogcEdit := Gui_object.AddEdit("w300 h200 +multi", Array)
        }
        Gui_object.Title := "Gui (" Type(Array) ")" 

        ;Reload menu for testing
        ; Menus := MenuBar()
        ; Menus.Add("&Reload", (*) => (Reload()))
        ; myGui.MenuBar := Menus

        Gui_object.Show()
        return
    }
    if (type(Array)="Array"){
        For Key, Value in Array{
            if (IsObject(Value)){
                ItemID := ogcTreeView.Add("[" Key "] (" type(Value) ")", ParentID, "Expand")
                ObjectGui(Value, ItemID)
            }   
            else{
                ogcTreeView.Add("[" Key "] (" type(Value) ")  =  " Value, ParentID, "Expand")
            }  
        }
    }
    if (type(Array) = "Map") {
        For Key, Value in Array {
            if (IsObject(Value)) {
                ItemID := ogcTreeView.Add('["' Key '"] (' type(Value) ')', ParentID, "Expand")
                ObjectGui(Value, ItemID)
            } else {
                ogcTreeView.Add('["' Key '"] (' type(Value) ')  =  ' Value, ParentID, "Expand")
            }
        }
        aMethods := ["Count", "Capacity", "CaseSense", "Default", "__Item"]
        for index, PropName in aMethods {
            try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
        }

    }
    try{
        For PropName, PropValue in Array.OwnProps(){
            if (IsObject(PropValue)){
                ItemID := ogcTreeView.Add("." PropName " (" type(PropValue) ")", ParentID, "Expand")
                ObjectGui(PropValue, ItemID)
            }    
            else{
                ogcTreeView.Add("." PropName " (" type(PropValue) ")  =  " PropValue, ParentID, "Expand")
            } 
        }
    }
    if (type(Array) = "Func"){
        aMethods := ["Name", "IsBuiltIn", "IsVariadic", "MinParams", "MaxParams"]
        for index, PropName in aMethods{
            ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
        }
    }
    if (type(Array) = "Buffer"){
        aMethods := ["Prt","Size"]
        for index, PropName in aMethods{
            try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
        }
    }
    if (type(Array) = "Gui"){
        aMethods := ["BackColor", "FocusedControl", "Hwnd", "MarginX", "MarginY", "Name", "Title"]
        for index, PropName in aMethods{
            try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
        }
        For Hwnd, oCtrl in Array{
            ItemID := ogcTreeView.Add("__Enum[" Hwnd "] (" Type(oCtrl) ")", ParentID, "Expand")
            ObjectGui(oCtrl, ItemID)
        }
    }
    if (SubStr(type(Array),1,4)="Gui."){
        aMethods := ["ClassNN", "Enabled", "Focused", "Hwnd", "Name", "Text", "Type", "Value", "Visible"]
        for index, PropName in aMethods {
            try ogcTreeView.Add("." PropName " (" type(Array.%PropName%) ")  =  " Array.%PropName%, ParentID, "Expand")
        }
        ogcTreeView.Add(".Gui (Gui)", ParentID, "Expand")
    }
    return

    Gui_Size(thisGui, MinMax, Width, Height) {
        if MinMax = -1	; The window has been minimized. No action needed.
            return
        DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
        For Hwnd, GuiCtrlObj in thisGui {
            GuiCtrlObj.GetPos(&cX, &cY, &cWidth, &cHeight)
            GuiCtrlObj.Move(, , Width - cX, Height -cY)
        }
        DllCall("LockWindowUpdate", "Uint", 0)
    }

    ContextMenu_TreeView(GuiCtrlObj , Item, IsRightClick, X, Y){
        SelectedItemID := GuiCtrlObj.GetSelection()
        RetrievedText := GuiCtrlObj.GetText(SelectedItemID)
        Value := RegExReplace(RetrievedText,".*?\)\s\s=\s\s(.*)","$1")
        ItemID := SelectedItemID
        
        ParentText := ""
        ParentItemID := ItemID
        loop{
            if (ParentItemID=0){
                break
            }
            RetrievedParentText := GuiCtrlObj.GetText(ParentItemID)
            ParentText := RegExReplace(RetrievedParentText, "(.*?)\s.*", "$1") ParentText
            ParentItemID := GuiCtrlObj.GetParent(ParentItemID)
        }

        Menu_TV := Menu()
        if(InStr(RetrievedText, ")  =  ")){
            Menu_TV.Add("Copy [" Value "]",(*)=>(A_Clipboard:= Value, Tooltip2("Copied [" Value "]")))
            Menu_TV.SetIcon("Copy [" Value "]", "Shell32.dll", 135)
        }
        Menu_TV.Add("Copy [" ParentText "]", (*) => (A_Clipboard := ParentText, Tooltip2("Copied [" ParentText "]")))
        Menu_TV.SetIcon("Copy [" ParentText "]", "Shell32.dll", 135)
        Menu_TV.Show()
    }

    Tooltip2(Text := "", X := "", Y := "", WhichToolTip := "") {
        ToolTip(Text, X, Y, WhichToolTip)
        SetTimer () => ToolTip(), -3000
    }
}

EditGui(Input){
    Output := Input
    Gui_Edit := Gui()
    Gui_Edit.Opt("+Resize")
    Gui_Edit.OnEvent("Size", Gui_Size)
    Gui_Edit.OnEvent("Close", Gui_Close)
    Gui_Edit.MarginX := "0", Gui_Edit.MarginY := "0"
    if (Type(Input)="Array") {
        ogcEdit := Gui_Edit.AddListView("w300 r" Input.Length+2 " -ReadOnly -Sort -Hdr",["Edit"])
        ogcEdit.OnEvent("ContextMenu", LV_ContextMenu)
        for Index, Value in Input{
            ogcEdit.Add(, Value)
        }
        ogcEdit.ModifyCol(1,300-5)
        
        for PropName, PropValue in Input.OwnProps() {
            if (A_Index=1) {
                ogcEditProp := Gui_Edit.AddListView("w300 r" Input.Length + 2 " -ReadOnly -Sort", ["value", "Property"])
                ; ogcEditProp.OnEvent("ContextMenu", LV_ContextMenu)
                for PropName, PropValue in Input.OwnProps() {
                    ogcEditProp.Add(, PropValue, PropName)
                }
                ogcEditProp.ModifyCol(1)
                ogcEditProp.ModifyCol(2)
            }
        }
         
    } else if (!IsObject(Input)){
        ogcEdit := Gui_Edit.AddEdit("w300 h200 +multi", Input)
    } else{
        for PropName, PropValue in Input.OwnProps() {
            Properties := A_Index
        }
        ogcEditProp := Gui_Edit.AddListView("w300 r" Properties + 2 " -ReadOnly -Sort", ["value", "Property"])
        ; ogcEditProp.OnEvent("ContextMenu", LV_ContextMenu)
        for PropName, PropValue in Input.OwnProps() {
            ogcEditProp.Add(, PropValue, PropName)
        }
        ogcEditProp.ModifyCol(1)
        ogcEditProp.ModifyCol(2)
    }
    Gui_Edit.Title := "Edit Gui (" Type(Input) ")"

    Gui_Edit.Show()
    HotIfWinActive "ahk_id " Gui_Edit.Hwnd
    Hotkey "Delete", ClearRows
    WinWaitClose("ahk_id" Gui_Edit.hwnd)
    Hotkey "Delete", "Off"
    return Output

    Gui_Size(thisGui, MinMax, Width, Height) {
        if MinMax = -1	; The window has been minimized. No action needed.
            return
        DllCall("LockWindowUpdate", "Uint", thisGui.Hwnd)
        if (Type(Input) = "Array"){
            ogcEdit.ModifyCol(1, Width - 4)
        }
        if (IsSet(ogcEditProp)){
            ogcEditProp.ModifyCol(1, (Width/2) - 2)
            ogcEditProp.ModifyCol(2, (Width/2) - 2)
        }
        For Hwnd, GuiCtrlObj in thisGui {
            Controls := A_Index
        }
        For Hwnd, GuiCtrlObj in thisGui {
            if (A_Index=1){
                GuiCtrlObj.GetPos(&cX, &cY, &cWidth, &cHeight)
            }
            yCtrl := (A_Index-1)*Height/2
            GuiCtrlObj.Move(, yCtrl, Width - cX, Height/Controls - cY)
        }
        DllCall("LockWindowUpdate", "Uint", 0)
        return
    }
    Gui_Close(thisGui){
        if (Type(Input) = "Array"){
            Loop ogcEdit.GetCount()
            {
                Output[A_index] := ogcEdit.GetText(A_Index)
            }
        }
        else{
            Output := ogcEdit.text
        }  
        Gui_Edit.Destroy()
        return
    }
    LV_ContextMenu(LV, Item, IsRightClick, X, Y){
        Rows := LV.GetCount()
        Row := LV.GetNext()
        ContextMenu := Menu()
        ContextMenu.Add("Edit", (*) => (PostMessage(LVM_EDITLABEL := 0x1076, Row - 1, 0, , "ahk_id " LV.hwnd)))
        ContextMenu.SetIcon("Edit","shell32.dll", 134)
        ((Rows = 0 or row=0) && ContextMenu.Disable("Edit"))
        ContextMenu.Add()
        ContextMenu.Add("Insert item", (*)=> (LV.Modify(, "-Select -focus"), LV.Insert(Row, "Select", ""), Output.InsertAt(Row,""),PostMessage(LVM_EDITLABEL := 0x1076, Row-1, 0, , "ahk_id " LV.hwnd)))
        ContextMenu.SetIcon("Insert item", "netshell.dll", 98)
        ((Rows = 0 or row = 0) && ContextMenu.Disable("Insert item"))
        ContextMenu.Add("Insert item below", (*)=> (Row:= LV.GetNext() + 1, LV.Modify(, "-Select -focus"),LV.Insert(Row, "Select", ""), Output.InsertAt(Row, ""),PostMessage(LVM_EDITLABEL := 0x1076, Row - 1, 0, , "ahk_id " LV.hwnd)))
        ContextMenu.SetIcon("Insert item below", "comres.dll", 5)
        ContextMenu.Add()
        ContextMenu.Add("Delete", ClearRows)
        ContextMenu.SetIcon("Delete", "Shell32.dll", 132)
        ((Rows = 0 or row = 0) && ContextMenu.Disable("Delete"))
        ContextMenu.Show()
        return
    }
    ClearRows(*) {
        RowNumber := 0	; This causes the first iteration to start the search at the top.
        Loop {
            RowNumber := ogcEdit.GetNext(RowNumber - 1)
            if not RowNumber	; The above returned zero, so there are no more selected rows.
                break
            ogcEdit.Delete(RowNumber)	; Clear the row from the ListView.
            Output.RemoveAt(RowNumber)
        }
        return
    }
}