
pArr(Array, Parent="",ExpandK="") {
	if !Parent
	{
		Gui, +HwndDefault
		Gui, New, +HwndGuiArray +LabelGuiArray +Resize
		Gui, Margin, 5, 5
		Gui, Add, TreeView, w300 h200
		
		Item := TV_Add("Array", 0, "+Expand")
		pArr(Array, Item, ExpandK)
		
		Gui, Show,, GuiArray
		Gui, %Default%:Default
		
		WinWait, ahk_id%GuiArray%
		WinWaitClose, ahk_id%GuiArray%
		return
	}
	
	For Key, Value in Array
	{
		Item := TV_Add(Key, Parent,(ExpandK) ? "+Expand" : "")
		if (IsObject(Value))
			pArr(Value, Item, ExpandK)
		else
			TV_Add(Value, Item,(ExpandK) ? "+Expand" : "")
	}
	return
	
	GuiArrayClose:
	Gui, Destroy
	return
	
	GuiArraySize:
	GuiControl, Move, SysTreeView321, % "w" A_GuiWidth - 10 " h" A_GuiHeight - 10
	return
}