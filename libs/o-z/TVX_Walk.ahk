TVX_Walk(WalkHandlerFunc, FirstItem = 0, OnlySubItemsOfFirstItem := False){
  ;check if WalkHandlerFunc exists and has one parameter
  If (IsFunc(WalkHandlerFunc) <> 2){
    If IsFunc(WalkHandlerFunc)
      t = doesn't have one parameter.
    Else
      t = doesn't exist.
    MsgBox, The provided handler function %WalkHandlerFunc%() for the TVX_Walk() function %t%
    Return 
  }
  If (FirstItem = 0)
    If !(FirstItem := TV_GetNext(FirstItem))
      Return   ;the treeview is empty
  If TV_GetText(t, FirstItem)   ;check if FirstItem is an item in the TV
    TVX_Walk_Recursive(WalkHandlerFunc, FirstItem, OnlySubItemsOfFirstItem, RelativeIndentation := 0)
  Else  
    MsgBox, Item %FirstItem% is not an item in the current TreeView
}
TVX_Walk_Recursive(WalkHandlerFunc, FirstItem, OnlySubItemsOfFirstItem, RelativeIndentation){
  ; local Item
  Item := FirstItem
  Loop { ;loop through all syblings
		If (OnlySubItemsOfFirstItem AND !RelativeIndentation AND (Item <> FirstItem))
      Return ;return when back to zero indentation and only subitems should be handled
    TV_GetText(Text, Item)
    Type := (FirstChildItem := TV_GetChild(Item)) ? "Parent" : "Item"  ;check if there is a child
    %WalkHandlerFunc%({type:Type, hwnd:Item, indentLvl:RelativeIndentation, text:Text
                     , expand:(TV_Get(Item, "Expand")?1:0), check:(TV_Get(Item, "Check")?1:0), bold:(TV_Get(Item, "Bold")?1:0)})
    If (type = "Parent") ;recurse into subitems
      %A_ThisFunc%(WalkHandlerFunc, FirstChildItem, OnlySubItemsOfFirstItem, RelativeIndentation + 1)
    i := A_Index
  } Until !(Item := TV_GetNext(Item)) ;until there are no more sybling
}

; F7::  ;Test for TVX_Walk
  ; p := TV_Add("a", 0)
  ; p := TV_Add("d", p)
  ; p := TV_Add("b", 0)
  ; p := TV_Add("c", 0)
  ; p := TV_Add("one", 0)
  ; i := TV_Add("one.one", p)
  ; i := TV_Add("one.two", p)
  ; p := TV_Add("two", 0)
  ; it := TV_Add("two.one", p)
  ; i := TV_Add("two.two", p)
  ; c := TV_Add("two.two.one", i)
  ; c := TV_Add("two.two.two", i)
  ; c := TV_Add("two.two.three", i)
  ; ic := TV_Add("two.three", p)
  ; p := TV_Add("three", 0)
  ; TVX_Walk("F7Handler",i,True)
  ; F7Handler("")
; Return
; F7Handler(oTV){
  ; static t
  ; If isObject(oTV)
    ; t .= JSON.Dump(oTV)
  ; Else {
    ; MsgBox, %t%
    ; t =
  ; }
; }
