/*
Class: CTreeViewControl
A TreeView control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CTreeViewControl Extends CControl
{
	static registration := CGUI.RegisterControl("TreeView", CTreeViewControl)

	EditingStart := new EventHandler()
	DoubleClick := new EventHandler()
	EditingEnd := new EventHandler()
	ItemSelected := new EventHandler()
	Click := new EventHandler()
	RightClick := new EventHandler()
	ItemExpanded := new EventHandler()
	ItemCollapsed := new EventHandler()
	FocusReceived := new EventHandler()
	FocusLost := new EventHandler()
	KeyPress := new EventHandler()

	__New(Name, ByRef Options, Text, GUINum)
	{
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit
			Options .= " AltSubmit"
			
		base.__New(Name, Options, Text, GUINum)
		this._.Insert("ControlStyles", {Checked : 0x100, ReadOnly : -0x8, FullRowSelect : 0x1000, Buttons : 0x1, Lines : 0x2, HScroll : -0x8000, AlwaysShowSelection : 0x20, SingleExpand : 0x400, HotTrack : 0x200})
		this._.Insert("Events", ["DoubleClick", "EditingEnd", "ItemSelected", "Click", "RightClick", "EditingStart", "KeyPress", "ItemExpanded", "ItemCollapsed", "FocusReceived", "FocusLost"])
		; this._.Insert("Messages", {0x004E : "Notify"}) ;This control uses WM_NOTIFY with NM_SETFOCUS and NM_KILLFOCUS
		this.Type := "TreeView"
	}
	
	PostCreate()
	{
		Base.PostCreate()
		this._.ImageListManager := new this.CImageListManager(this.GUINum, this.hwnd)
		this._.Items := new this.CItem(0, this.GUINum, this.hwnd)
		this._.PreviouslySelectedItem := this._.Items
	}
	/*
	Function: FindItem
	Finds an item by its ID.
	
	Parameters:
		ID - The ID of the item.
	*/
	FindItem(ID, Root = "")
	{
		if(!ID) ;Root node
			return this.Items
		if(!IsObject(Root))
			Root := this.Items
		if(ID = Root.ID)
			return Root
		Loop % Root.MaxIndex()
			if(result := this.FindItem(ID, Root[A_Index]))
				return result
		return 0
	}
	
	/*
	Function: FindItemWithText
	Finds an item by its text.
	
	Parameters:
		Text - The text of the item.
	*/
	FindItemWithText(Text, Root = "")
	{
		if(!Text) ;Root node
			return this.Items
		if(!IsObject(Root))
			Root := this.Items
		if(Text = Root.Text)
			return Root
		Loop % Root.MaxIndex()
			if(result := this.FindItemWithText(Text, Root[A_Index]))
				return result
		return 0
	}
	/*
	Property: Items
	Contains the nodes of the tree. Each level can be iterated and indexed. A node is of type <CTreeViewControl.CItem>
	
	Property: SelectedItem
	Contains the node of type <CItem> that is currently selected.
	
	Property: PreviouslySelectedItem
	Contains the node of type <CItem> that was previously selected.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Items")
			Value := this._.Items
		else if(Name = "SelectedItem")
		{
			GUI := CGUI.GUIList[this.GUINum]
			if(GUI.IsDestroyed)
				return
			Gui, % this.GUINum ":Default"
			Gui, TreeView, % this.ClassNN
			Value := this.FindItem(TV_GetSelection())
		}
		else if Name is Number ;Prevent accidentally trying to access the tree items through the control class directly
			throw Exception("Tree Items can't be accessed through the control directly! Use CTreeViewControl.Items[index] instead!", -1)
		Loop % Params.MaxIndex()
			if(IsObject(Value)) ;Fix unlucky multi parameter __GET
				Value := Value[Params[A_Index]]
		if(Value)
			return Value
	}
	
	__Set(Name, Params*)
	{
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
			Value := Params.Remove()
			if(Params.MaxIndex())
			{
				Params.Insert(1, Name)
				Name := Params.Remove()
				return (this[Params*])[Name] := Value
			}
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedItem")
			{
				GUI := CGUI.GUIList[this.GUINum]
				Gui, % this.GUINum ":Default"
				Gui, TreeView, % this.ClassNN
				TV_Modify(Value._.ID)
				this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
				this._.PreviouslySelectedItem := this.SelectedItem
			}
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	/*
	Event: Introduction
	There are currently 3 methods to handle control events:
	
	1)	Use an event handler. Simply use control.EventName.Handler := "HandlingFunction"
		Instead of "HandlingFunction" it is also possible to pass a function reference or a Delegate: control.EventName.Handler := new Delegate(Object, "HandlingFunction")
		If this method is used, the first parameter will contain the control object that sent this event.
		
	2)	Create a function with this naming scheme in your window class: ControlName_EventName(params)
	
	3)	Instead of using ControlName_EventName() you may also call <CControl.RegisterEvent> on a control instance to register a different event function name.
		This method is deprecated since event handlers are more flexible.
		
	The parameters depend on the event and there may not be params at all in some cases.
	
	Event: Click(Item)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(Item)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(Item)
	Invoked when the user right-clicked on the control.
	
	Event: EditingStart(Item)
	Invoked when the user started editing a node.
	
	Event: EditingEnd(Item)
	Invoked when the user finished editing a node.
	
	Event: ItemSelected(Item)
	Invoked when the user selected a node.
	
	Event: ItemExpanded(Item)
	Invoked when the user expanded a node.
	
	Event: ItemCollapsed(Item)
	Invoked when the user collapsed a node.
	
	Event: KeyPress(KeyCode)
	Invoked when the user pressed a key while the control was focused.
	*/
	HandleEvent(Event)
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		;Handle visibility of controls associated with tree nodees
		if(Event.GUIEvent = "S")
			this.ProcessSubControlState(this.PreviouslySelectedItem, SelectedItem := this.Items.ItemByID(Event.EventInfo))
		if(Event.GUIEvent == "E")
			this.CallEvent("EditingStart", this.Items.ItemByID(Event.EventInfo))
		else if(EventName := {DoubleClick : "DoubleClick", e : "EditingEnd", S : "ItemSelected", Normal : "Click", RightClick : "RightClick", "+" : "ItemExpanded", "-" : "ItemCollapsed"}[Event.GUIEvent])
			this.CallEvent(EventName, this.Items.ItemByID(Event.EventInfo))
		else if(EventName = "K")
			this.CallEvent("KeyPress", Event.EventInfo)
		else if(Event.GUIEvent == "F")
			this.CallEvent("FocusReceived")
		else if(Event.GUIEvent == "f")
			this.CallEvent("FocusLost")
		if(Event.GUIEvent = "S")
			this.PreviouslySelectedItem := SelectedItem
	}
	
	/*
	Class: CTreeViewControl.CItem
	A tree node.
	*/
	Class CItem
	{
		__New(ID, GUINum, hwnd)
		{
			this.Insert("_", {})
			this._.Insert("GUINum", GUINum)
			this._.Insert("hwnd", hwnd)
			this._.Insert("ID", ID)
			this._.Insert("Controls", {})
		}
		/*
			Function: Add
			Adds a new item to the TreeView.
			
			Parameters:
				Text - The text of the item.
				Options - Various options, see Autohotkey TreeView documentation
			
			Returns:
			An object of type CItem representing the newly added item.
		*/
		Add(Text, Options = "")
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			ID := TV_Add(Text, this.ID, Options)
			Item := new CTreeViewControl.CItem(ID, this._.GUINum, this._.hwnd)
			;~ Item.Icon := ""
			this.Insert(Item)
			return Item
		}
		
		/*
		Function: AddControl
		Adds a control to this tree node that will be visible only when this node is selected. The parameters correspond to the Add() function of CGUI.
		
		Parameters:
			Type - The type of the control.
			Name - The name of the control.
			Options - Options used for creating the control.
			Text - The text of the control.
			UseEnabledState - If true, the control will be enabled/disabled instead of visible/hidden.
		*/
		AddControl(type, Name, Options, Text, UseEnabledState = 0)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(!this.Selected)
				Options .= UseEnabledState ? " Disabled" : " Hidden"
			Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
			Control._.UseEnabledState := UseEnabledState
			Control.hParentControl := this._.hwnd
			return Control
		}
		
		/*
			Function: Delete
			Deletes an item.
			
			Parameters:
				ObjectOrIndex - The item object or the index of the child item of this.
		*/
		Delete(ObjectOrIndex)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			if(!IsObject(ObjectOrIndex)) ;If index, get object and then handle
				ObjectOrIndex := this[ObjectOrIndex]
			if(ObjectOrIndex.ID = 0) ;Don't delete root node
				return
			if(ObjectOrIndex.Selected)
				WasSelected := true
			p := ObjectOrIndex.Parent
			for Index, Item in ObjectOrIndex.Parent
				if(Item = ObjectOrIndex)
				{
					ObjRemove(ObjectOrIndex.Parent, A_Index)
					break
				}
			TV_Delete(ObjectOrIndex.ID)
			if(WasSelected)
			{
				Control.ProcessSubControlState(ObjectOrIndex, this.SelectedItem)
				Control.PreviouslySelectedItem := ObjectOrIndex ;The node is accessible here even though it does not exist anymore because the user might have stored data in it that might need to be used in _ItemSelected handler.
			}
			if(TV_GetCount() = 0) ;If all TreeView items are deleted, fire a selection changed event
				if(IsFunc(GUI[Control.Name "_ItemSelected"]))
				{
					ErrorLevel := ErrLevel
					GUI[Control.Name "_ItemSelected"](Control.Items)
					if(!Critical)
						Critical, Off
					return
				}
		}
		/*
		Function: Move
		Moves an Item to another position.
		
		Parameters:
			Position - The new (one-based) - position in the child items of Parent.
			Parent - The item will be inserted as child of the Parent item. Leave empty to use its current parent.
		*/
		Move(Position=1, Parent = "")
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			
			;Backup properties which are stored in the TreeList itself
			Text := this.Text
			Bold := this.bold
			Expanded := this.Expanded
			Checked := this.Checked
			Selected := this.Selected
			OldID := this.ID
			
			;If no parent is specified, the item will be moved on the current level
			if(!Parent)
				Parent := this.Parent
			OldParent := this.Parent
			
			;Add new node. At this point there are two nodes.
			NewID := TV_Add(Text, Parent.ID, (Position = 1 ? "First" : Parent[Position-1].ID) " " (Bold ? "+Bold" : "") (Expanded ?  "Expand" : "") (Checked ? "Check" : "") (Selected ? "Select" : ""))
			
			;Collect all child items
			Childs := []
			for index, Item in this
				Childs.Insert(Item)
			
			this._.ID := NewID
			
			;Remove old parent node link and set the new one
			if(OldParent != Parent)
			{
				for Index, Item in OldParent
					if(Item = this)
					{
						OldParent.Remove(A_Index)
						break
					}
				Parent.Insert(Position, this)
			}
			
			if(this.Icon)
				Control._.ImageListManager.SetIcon(this._.ID, this.Icon, this.IconNumber)
			
			;Move child items
			for index, Item in Childs
				Item.Move(index, this)
			
			;Delete old tree node
			TV_Delete(OldID)
		}
		/*
		Function: SetIcon
		Sets the icon of a tree node
		
		Parameters:
			Filename - The filename of the file containing the icon.
			IconNumberOrTransparencyColor - The icon number or the transparency color if the used file has no transparency support.
		*/
		SetIcon(Filename, IconNumberOrTransparencyColor = 1)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Control._.ImageListManager.SetIcon(this._.ID, Filename, IconNumberOrTransparencyColor)
			this._.Icon := Filename
			this._.IconNumber := IconNumberOrTransparencyColor
		}
		/*
		Function: MaxIndex
		Returns the number of child nodes.
		*/
		MaxIndex()
		{
			GUI := CGUI.GUIList[this._.GUINum]
			if(GUI.IsDestroyed)
				return
			Control := GUI.Controls[this._.hwnd]
			Gui, % this._.GUINum ":Default"
			Gui, TreeView, % Control.ClassNN
			current := this._.ID ? TV_GetChild(this._.ID) : TV_GetNext() ;Get first child or first top node
			if(!current)
				return 0 ;No children
			count := 0
			while(current && current := TV_GetNext(current))
				count++
			return count + 1
		}
		
		/*
		Function: ItemByID
		Access a child item by its ID.
		
		Parameters:
			ID - The ID of the child item
		*/
		;Access a child item by its ID
		ItemByID(ID)
		{
			Loop % this.MaxIndex()
			{
				if(this[A_Index]._.ID = ID)
					return this[A_Index]
				else if(Item := this[A_Index].ItemByID(ID))
					return Item
			}
		}
		
		/*
		Function: FindItemWithText
		Finds a child item by its Text.
		
		Parameters:
			Text - The text of the child item
		*/
		FindItemWithText(Text)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this._.hwnd]
			return Control.FindItemWithText(Text, this)
		}
		_NewEnum()
		{
			return new CEnumerator(this)
		}
		
		/*
		Property: 1,2,3,4,...
		The child nodes of a tree node may be accessed by their index, e.g. this.TreeView1.Items[1][2][3].Text := "AHK"
		
		Property: CheckedItems
		An array containing all checked child nodes of type <CTreeViewControl.CItem>.
		
		Property: CheckedIndices
		An array containing all checked child indices.
		
		Property: Parent
		The parent node of this node.
		
		Property: ID
		The ID used internally in the TreeView control.
		
		Property: Icon
		The path of an icon assigned to this node.
		
		Property: IconNumber
		The icon number used when an icon file contains more than one icon.
		
		Property: Count
		The number of child nodes.
		
		Property: HasChildren
		True if there is at least one child node.
		
		Property: Text
		The text of this tree node.
		
		Property: Checked
		True if the tree node is checked.
		
		Property: Selected
		True if the tree node is selected.
		
		Property: Expanded
		True if the tree node is expanded.
		
		Property: Bold
		If true, the text of this node is bold.
		*/
		__Get(Name, Params*)
		{
			if(Name != "_")
			{
				GUI := CGUI.GUIList[this._.GUINum]
				if(!GUI.IsDestroyed)
				{
					;~ if Name is Integer ;get a child node
					;~ {
						;~ if(Name <= this.MaxIndex())
						;~ {
							;~ Control := GUI.Controls[this._.hwnd]
							;~ Gui, % this._.GUINum ":Default"
							;~ Gui, TreeView, % Control.ClassNN
							;~ child := TV_GetChild(this._.ID) ;Find child node id
							;~ Loop % Name - 1
								;~ child := TV_GetNext(child)
							;~ Value := new CTreeViewControl.CItem(child, this._.GUINum, this._.hwnd)
						;~ }
					;~ }
					if(Name = "CheckedItems")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(Item)
					}
					else if(Name = "CheckedIndices")
					{
						Value := []
						for index, Item in this
							if(Item.Checked)
								Value.Insert(index)
					}
					else if(Name = "Parent")
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						VaLue := Control.FindItem(TV_GetParent(this._.ID))
					}
					else if(Name = "ID" || Name = "Icon" || Name = "IconNumber")
						Value := this._[Name]
					else if(Name = "Count")
						Value := this.MaxIndex()
					else if(Name = "HasChildren")
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_GetChild(this._.ID) > 0
					}
					else if(Name = "Text")
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_GetText(Value, this._.ID)
					}
					else if(Name = "Checked" || Name = "Expanded" || Name = "Bold")
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_Get(this._.ID, Name) > 0
					}
					else if(Name = "Selected")
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						Value := TV_GetSelection() = this._.ID
					}
					else if(Name = "Controls")
						Value := this._.Controls
					Loop % Params.MaxIndex()
						if(IsObject(Value)) ;Fix unlucky multi parameter __GET
							Value := Value[Params[A_Index]]
					if(Value)
						return Value
				}
			}
		}
		__Set(Name, Params*)
		{
			;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
			Value := Params.Remove()
			if(Params.MaxIndex())
			{
				Params.Insert(1, Name)
				Name := Params.Remove()
				return (this[Params*])[Name] := Value
			}
			GUI := CGUI.GUIList[this._.GUINum]
			if(!GUI.IsDestroyed)
			{
				if(Name = "Text")
				{
					Control := GUI.Controls[this._.hwnd]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN
					TV_Modify(this._.ID, "", Value)
					return Value
				}
				else if(Name = "Selected") ;Deselecting is not possible it seems
				{
					if(Value = 1)
					{
						Control := GUI.Controls[this._.hwnd]
						Gui, % this._.GUINum ":Default"
						Gui, TreeView, % Control.ClassNN
						TV_Modify(this._.ID)
						Control.ProcessSubControlState(Control._.PreviouslySelectedItem, Control.SelectedItem)
						Control._.PreviouslySelectedItem := Control.SelectedItem
					}
					return Value
				}
				else if(Option := {Checked : "Check", Expanded : "Expand", Bold : "Bold"}[Name]) ;Wee, check and remapping in one step
				{
					Control := GUI.Controls[this._.hwnd]
					Gui, % this._.GUINum ":Default"
					Gui, TreeView, % Control.ClassNN
					TV_Modify(this._.ID, (Value = 1 ? "+" : "-") Option)
				}
				else if(Name = "Icon")
				{
					this.SetIcon(Value, this._.HasKey("IconNumber") ? this._.IconNumber : 1)
					return Value
				}
				else if(Name = "IconNumber")
				{
					this._.IconNumber := Value
					if(this._.Icon)
						this.SetIcon(this.Icon, Value)
					return Value
				}
			}
		}
	}
}