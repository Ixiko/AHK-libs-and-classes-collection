; AHK v2
; ==========================================================
;
; Inspired by user "just me"s post here: https://www.autohotkey.com/boards/viewtopic.php?p=121483#p121483
;
; JSON serializer: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=74799&p=323348#p323348
;
; Example for usage with JSON serializer:
;
; To load tree data from disk:
;       
;       Gui, TreeView, MyTreeName               ; ensure TreeView is active
;       FileRead, myVar, json-tree-data.txt     ; load JSON text to var
;       myObj := jxon_load(myVar)               ; convert var to array/object
;       LoadTree(TV,myObj)                      ; now your tree is recreated
;
; To save tree data to disk:
;
;       Gui, TreeView, MyTreeName               ; ensure TreeView is active
;       myArray := SaveTree(TV)                 ; dump tree to array
;       myVar := jxon_dump(myArray)             ; convert array to JSON text
;       FileAppend, %myVar%, json-tree-data.txt ; save data to file
;
;
; Using arrays in this way, you can save TreeView data to another settings array, or
; keep the TreeView data separate, according to your needs.
;
; Note, when saving icon index, it is actually 0 based.  So items that don't have an
; icon will still return index 0 (which translates to index 1 for AHK).
;
; ==========================================================
; EXAMPLE
; ==========================================================

; Global testArray:="", treeHwnd, imgListID, g

; g := Gui()
; g.OnEvent("close",GuiClose)

; g.Add("Button","xm yp","Clear").OnEvent("click",Clear)
; g.Add("Button","x+0 yp","To Tree").OnEvent("click",ArrayToTree)
; g.Add("Button","x+0 yp","RePopulate").OnEvent("click",RePop)

; g.Add("Checkbox","x+10 yp+4 vMyCheck","Include Icons")
; g["MyCheck"].Value := 1
; TV := g.Add("TreeView","xs y+16 w600 r17 Checked vMyTreeName")
; treeHwnd := TV.hwnd
; g.Show()

; populate(true)

; populate(icon:=false) {
    ; Global imgListID := 0
    
    ; TV := g["MyTreeName"]
    ; If !icon {
        ; IL_Destroy(imgListID)
        ; TV.Opt("-ImageList -Icon")
    ; } Else {
        ; makeImgList()
    ; }
    
    ; icon := icon ? " Icon1" : ""
    ; i1 := TV.Add("Item 01",,"Expand" icon) ; icon index is 0 based on retrieval
        ; icon := icon ? " Icon2" : ""
        ; i4 := TV.Add("Item 04",i1,"Expand" icon)
            ; icon := icon ? " Icon3" : ""
            ; i13 := TV.Add("Item 13",i4,"" icon)
            ; icon := icon ? " Icon4" : ""
            ; i16 := TV.Add("Item 15",i4,"" icon)
    ; icon := icon ? " Icon1" : ""
    ; TV.Add("Item 05",i1,"" icon)
    ; icon := icon ? " Icon2" : ""
    ; TV.Add("Item 06",i1,""  icon)
    ; icon := icon ? " Icon3" : ""

    ; i2 := TV.Add("Item 02",,"Bold Expand" icon)
    ; icon := icon ? " Icon4" : ""
        ; i7 := TV.Add("Item 07",i2,"Bold Check Expand" icon)
        ; icon := icon ? " Icon1" : ""
            ; TV.Add("Item 14",i7,"Check" icon)
            ; icon := icon ? " Icon2" : ""
    ; TV.Add("Item 08",i2,"Bold" icon)
    ; icon := icon ? " Icon3" : ""
    ; TV.Add("Item 09",i2,"Bold" icon)
    ; icon := icon ? " Icon4" : ""

    ; i3 := TV.Add("Item 03",,"Check Expand" icon)
    ; icon := icon ? " Icon1" : ""
        ; i10 := TV.Add("Item 10",i3,"Check Expand" icon)
        ; icon := icon ? " Icon2" : ""
            ; TV.Add("Item 16",i10, icon)
            ; icon := icon ? " Icon1" : ""
    ; TV.Add("Item 11",i3,"Check" icon)
    ; icon := icon ? " Icon3" : ""
    ; TV.Add("Item 12",i3,"Check" icon)
    ; icon := icon ? " Icon4" : ""
; }

; makeImgList() {
    ; Global imgListID
    ; imgListID := IL_Create(4)
    ; IL_Add(imgListID,"shell32.dll",128)
    ; IL_Add(imgListID,"shell32.dll",132)
    ; IL_Add(imgListID,"shell32.dll",133)
    ; IL_Add(imgListID,"shell32.dll",131)
    ; g["MyTreeName"].SetImageList(imgListID)
; }

; RePop(ctl,info) {
    ; Msgbox "This recreates the tree from scratch, with or without icons."
    ; g["MyTreeName"].Delete()
    ; myCheck := g["MyCheck"].Value
    ; populate(MyCheck)
; }

; ArrayToTree(ctl,info) {
    ; Global testArray
    
    ; If (!testArray) {
        ; Msgbox "You have not yet saved the tree data.  Click the 'Clear' button to save the tree data and clear the TreeView control."
        ; return
    ; } Else
        ; Msgbox "This reloads the tree from the Global 'testArray' var."
    
    ; TV := g["MyTreeName"]
    ; LoadTree(TV,testArray)
; }

; Clear(ctl,info) {
    ; Global testArray
    ; testArray := SaveTree(ctl.gui["MyTreeName"],true) ; true = save icons
    ; ctl.gui["MyTreeName"].Delete()
    ; Msgbox "Tree saved to array, and cleared."
; }

; GuiClose(*) { ; GUI close event
    ; ExitApp ; do this otherwise the script keeps running after the GUI closes
; }

; ==========================================================================
; Library functions
; ==========================================================================

SaveTree(TV,icons:=false) {
    baseObj := Array(), ID := TV.GetNext()
    
    While ID {
        e := TV.Get(ID,"E"), c := TV.Get(ID,"C"), b := TV.Get(ID,"B")
        s := (TV.GetSelection()=ID) ? 1 : 0
        t := TV.GetText(ID)
        
        icon := TreeGetIconIndex(treeHwnd,ID)
        
        If icons
            baseObj.Push(Map("text",t, "expanded",e, "checked",c, "bold",b, "id",ID, "selected",s, "icon",icon+1, "parent",TV.GetParent(ID)))
        Else
            baseObj.Push(Map("text",t, "expanded",e, "checked",c, "bold",b, "id",ID, "selected",s, "parent",TV.GetParent(ID)))
        
        ID := TV.GetNext(ID,"Full")
    }
    
    TreeGetIconIndex(hCtl,hItem:=0) {    ; support function
        If (!hItem) {                   ; thanks to user "just me" for his LV_EX_ lib for ideas to make this code
            result := SendMessage(0x110A, 0x9, 0,, "ahk_id " hCtl) ; 0x110A TVM_GETNEXTITEM ; 0x9 current selection
            hItem := (result And result != "FAIL") ? result : ""
            If hItem = ""
                return ""
        }
        
        vPIs64 := (A_PtrSize=8) ; determine system arch
        vPtrType := vPIs64?"Int64":"Int" ; set data type
        vSize1 := vPIs64?56:40 ; set pointer size
        
        TVITEM := BufferAlloc(vSize1, 0) ; make variable/structure
        NumPut("UInt", 0x2, TVITEM, 0) ;mask ;TVIF_IMAGE := 0x2 ; define that we want the img index
        
        vMsg := StrLen(Chr(0xFFFF))?0x113E:0x110C ;TVM_GETITEMW := 0x113E ;TVM_GETITEMA := 0x110C ; define msg according to IsUnicode
        
        NumPut("Int", 0, TVITEM, vPIs64?36:24) ;iImage
        NumPut(vPtrType, hItem, TVITEM, vPIs64?8:4) ;hItem ; put item handle into structure
        
        SendMessage vMsg, 0, TVITEM,, "ahk_id " hCtL ;TVM_GETITEMW := 0x113E ;TVM_GETITEMA := 0x110C ; get TV item info struct
        vImageIndex := NumGet(TVITEM, vPIs64?36:24, "Int") ;iImage ; extract img index from structure
        
        return vImageIndex
    }
    
    return baseObj
}

LoadTree(TV,a) { ; TV = TreeView GuiObject   /   a = input array
    id_trans := Map() ; for translating parent IDs
    sel_id := 0
    
    For i, item in a {
        CurID := item["id"], pID := item["parent"]
        icon := (item.Has("icon") ? item["icon"] : 0)
        
        attr := (item["expanded"] ? "Expand" : "")
        attr .= (item["checked"] ? " Check" : "")
        attr .= (item["bold"] ? " Bold" : "")
        attr .= (item.Has("icon") ? " Icon" icon : "")
        
        new_id := !pID ? TV.Add(item["text"],,attr) : new_id := TV.Add(item["text"],id_trans[pID],attr)
        sel_id := (item["selected"] ? new_id : sel_id)
        
        id_trans[CurID] := new_id ; record new parent ID, linked to old ID
    }
    id_trans := "", a := "" ; free arrays
    
    If sel_id
        TV.Modify(sel_id,"Select")
}
