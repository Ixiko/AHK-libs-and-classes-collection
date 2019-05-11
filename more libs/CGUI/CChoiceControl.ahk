/*
Class: CChoiceControl
This class implements DropDownList, ComboBox and ListBox controls.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CChoiceControl Extends CControl ;This class is a ComboBox, ListBox and DropDownList
{
	static registration := CGUI.RegisterControl("DropDownList", CChoiceControl)
						+ CGUI.RegisterControl("ComboBox", CChoiceControl)
						+ CGUI.RegisterControl("ListBox", CChoiceControl)

	SelectionChanged := new EventHandler()
	DoubleClick := new EventHandler()
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		if(Type = "Combobox")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100, Simple : 0x1})
		else if(Type = "DropDownList")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100})
		else if(Type = "ListBox")
			this._.Insert("ControlStyles", {Multi : 0x800, ReadOnly : 0x4000, Sort : 0x2, ToggleSelection : 0x8})
		this._.Insert("Events", ["SelectionChanged"])
		if(Type = "ListBox")
			this._.Insert("Messages", {5 : "KillFocus", 4 : "SetFocus" }) ;Used for automatically registering message callbacks
		else if(Type = "ComboBox" || Type = "DropDownList")
			this._.Insert("Messages", {4 : "KillFocus", 3 : "SetFocus" }) ;Used for automatically registering message callbacks
	}
	PostCreate()
	{
		Base.PostCreate()
		this._.Items := new this.CItems(this.GUINum, this.hwnd)
		Content := this.Content
		Loop, Parse, Content, |
			this._.Items.Insert(new this.CItems.CItem(A_Index, this.GUINum, this.hwnd))
		this._.PreviouslySelectedItem := this.SelectedItem
		this.PreviouslySelectedIndex := this._.SelectedIndex := this.SelectedIndex
	}
	/*
	Property: SelectedItem
	The text of the selected item.
	
	Property: SelectedIndex
	The index of the selected item.
	
	Property: Items
	An array containing all items. See <CChoiceControl.CItems>.
	*/
	__Get(Name, Params*)
    {
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "SelectedItem")
			{
				SendMessage, this.Type != "ListBox" ? 0x147 : 0x188, 0, 0,,% "ahk_id " this.hwnd ;CB_GETCURSEL : LB_GETCURSEL
				ErrorLevel := (ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel)
				if(ErrorLevel >= 0)
					Value := this._.Items[ErrorLevel + 1]
			}
			else if(Name = "Text")
				ControlGet, Value, Choice,,,% "ahk_id " this.hwnd
			else if(Name = "SelectedIndex")
			{
				SendMessage, this.Type != "ListBox" ? 0x147 : 0x188, 0, 0,,% "ahk_id " this.hwnd
				ErrorLevel := (ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel)
				if(ErrorLevel >= 0)
					Value := ErrorLevel + 1
			}
			else if(Name = "Items")
				Value := this._.Items
			else if(Name = "PreviouslySelectedItem")
				Value := this._.PreviouslySelectedItem
			;~ else if(Name = "Items")
			;~ {
				;~ ControlGet, List, List,,, % " ahk_id " this.hwnd
				;~ Value := Array()
				;~ Loop, Parse, List, `n
					;~ Value.Insert(A_LoopField)
			;~ }
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		if(!(GUI := CGUI.GUIList[this.GUINum]).IsDestroyed)
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
				Loop % this.Items.MaxIndex()
					if(this.Items[A_Index] = Value)
						GuiControl, % this.GUINum ":Choose", % this.ClassNN, % Gui._.Delimiter A_Index ;| will trigger g-label
			}
			else if(Name = "SelectedIndex" && Value >= 1 && Value <= this.Items.MaxIndex())
			{
				GuiControl, % this.GUINum ":Choose", % this.ClassNN, % Gui._.Delimiter Value ;| will trigger g-label
			}
			;~ else if(Name = "Items" && !Params[1])
			;~ {
				;~ if(!IsObject(Value))
				;~ {
					;~ if(InStr(Value, Gui._.Delimiter) = 1) ;Overwrite current items
					;~ {
						;~ ;Hide overwritten controls for now (until they can be removed properly).
						;~ for index, item in this.Items
							;~ for index2, control in item.Controls
								;~ control.hide()
						;~ this.Items := new this.CItems(this.GUINum, this.Name)
					;~ }
					;~ Loop, Parse, Value,|
						;~ if(A_LoopField)
							;~ this.Items.Insert(this.Items.MaxIndex() + 1, new this.CItems.CItem(this.Items.MaxIndex() + 1, this.GUINum, this.Name))
				;~ }
				;~ else
				;~ {
					;~ ;Hide overwritten controls for now (until they can be removed properly).
					;~ for index, item in this.Items
						;~ for index2, control in item.Controls
							;~ control.hide()
					;~ this.Items := new this.CItems(this.GUINum, this.Name)
					;~ Loop % Value.MaxIndex()
						;~ this.Items.Insert(A_Index, new this.CItems.CItem(A_Index, this.GUINum, this.Name))
				;~ }
				;~ ItemsString := ""
				;~ Loop % this.Items.MaxIndex()
					;~ ItemsString .= Gui._.Delimiter Items[A_Index]
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ if(!IsObject(Value) && InStr(Value, "||"))
				;~ {
					;~ if(RegExMatch(Value, "(?:^|\|)(..*?)\|\|", SelectedItem))
						;~ Control, ChooseString, %SelectedItem1%,,% "ahk_id " this.hwnd
				;~ }
				;~ for index, item in Items
					;~ this.Items._.Insert(new this.CItems.CItem(A_Index, this.GUINum, this.Name))
			;~ }
			;~ else if(Name = "Items" && Params[1] > 0)
			;~ {
				;~ this._.Items[Params[1]] := Value
				;~ msgbox should not be here
				;~ Items := this.Items
				;~ Items[Params[1]] := Value
				;~ ItemsString := ""
				;~ Loop % Items.MaxIndex()
					;~ ItemsString .= Gui._.Delimiter Items[A_Index]
				;~ SelectedIndex := this.SelectedIndex
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ GuiControl, % this.GUINum ":Choose", % this.ClassNN, %SelectedIndex%
			;~ }
			else if(Name = "Text")
			{
				found := false
				Loop % this.Items.MaxIndex()
					if(this.Items[A_Index].Text = Value)
					{
						SelectedIndex := this.SelectedIndex
						GuiControl, % this.GUINum ":Choose", % this.hwnd, % Gui._.Delimiter A_Index
						if(SelectedIndex != this.SelectedIndex)
						{
							this.PreviouslySelectedIndex := this._.SelectedIndex
							this._.SelectedIndex := SelectedIndex
							this._.PreviouslySelectedItem := this.Items[SelectedIndex]
							this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
						}
						found := true
					}
				if(!found && this.type = "ComboBox")
					ControlSetText, , %Value%, % "ahk_id " this.hwnd
				;~ {
					;~ GuiControl, % this.GUINum ":ChooseString", % this.ClassNN, % Gui._.Delimiter Value
					;~ this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
					;~ this._.PreviouslySelectedItem := this.SelectedItem
				;~ }
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
	
	Event: SelectionChanged(SelectedItem)
	Invoked when the selection was changed.

	Event: DoubleClick(Item)
	Invoked when an item in a ListBox is double-clicked.
	*/
	HandleEvent(Event)
	{
		this._.PreviouslySelectedItem := this.items[this._.SelectedIndex]
		this.PreviouslySelectedIndex := this._.SelectedIndex
		this._.SelectedIndex := this.SelectedIndex
		if(this._.PreviouslySelectedItem != this.SelectedItem)
			this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
		if(Event.GUIEvent = "DoubleClick")
			this.CallEvent("DoubleClick", this.SelectedItem)
		else
			this.CallEvent("SelectionChanged", this.SelectedItem)
	}
	/*
	Class: CChoiceControl.CItems
	An array containing all items of the control.
	*/
	Class CItems
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.hwnd := hwnd
		}
		
		/*
		Property: 1,2,3,4,...
		Individual items can be accessed by their index.
		
		Property: Count
		The number of items in this control.
		*/
		__Get(Name)
		{
			if(this._.HasKey(Name))
				return this._[Name]
			else if(Name = "Count")
				return this.MaxIndex()
		}
		__Set(Name, Value)
		{
			if Name is Integer
				return Value
		}
		
		/*
		Function: Add
		Adds an item at the end of the list.
		
		Parameters:
			Text - The text of the new item.
			Position - The position at which the item will be inserted. Items with indices >= this value will be appended.
			Select - Set to true to select the freshly added item.
		*/
		Add(Text, Position = -1, Select = false)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this._.hwnd]
			Selected := Control.SelectedIndex
			ItemsString := ""
			Pos := 1
			len := !(len := this.MaxIndex())  ? 1 : len + 1
			if(Position = -1 || Position > len)
				Position := len
			Loop % len
			{
				ItemsString .= (Position = A_Index ? Gui._.Delimiter Text : Gui._.Delimiter this[pos].Text)
				if(Position != A_Index)
					pos++
			}
			GuiControl, % this._.GUINum ":", % Control.hwnd, %ItemsString%
			this._.Insert(Position, new this.CItem(Position, this._.GUINum, this._.hwnd)) ;Insert new item object
			for index, item in this ;Move existing indices
				item._.Index := index
			if(Select)
				GuiControl, % this._.GUINum ":Choose", % Control.hwnd, % Gui._.Delimiter Position
			else if(Selected)
				GuiControl, % this._.GUINum ":Choose", % Control.hwnd, % (Selected < Position ? Selected : Selected + 1)
		}

		/*
		Function: Clear
		Deletes all items
		*/
		Clear()
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this.hwnd]
			Loop % this.MaxIndex()
				this._.Remove(A_Index, "")
			GuiControl, % this._.GUINum ":", % Control.hwnd, |
			;Call selection changed event if there are no more items manually
			if(!this.MaxIndex())
				Control.HandleEvent("")
		}
		/*
		Function: Delete
		Deletes an item of the list of choices.
		
		Parameters:
			IndexTextOrItem - The item which should be removed. This can either be an index, the text of the item or the item object stored in the Items array.
		*/
		Delete(IndexTextOrItem)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this.hwnd]
			if(IsObject(IndexTextOrItem))
			{
				Loop % this.MaxIndex()
					if(this[A_Index] = IndexTextOrItem)
						IndexTextOrItem := A_Index
			}
			else if IndexTextOrItem is not Integer
			{
				Loop % this.MaxIndex()
					if(this[A_Index].Text = IndexTextOrItem)
						IndexTextOrItem := A_Index
			}
			if(IndexTextOrItem > 0 && IndexTextOrItem <= this.MaxIndex())
			{
				Selected := Control.SelectedIndex
				this._.Remove(IndexTextOrItem)
				ItemsString := Gui._.Delimiter
				Loop % this.MaxIndex()
					ItemsString .= (A_Index > 1 ? Gui._.Delimiter : "") this[A_Index].Text
				GuiControl, % this._.GUINum ":", % Control.hwnd, %ItemsString%
				if(Selected = IndexTextOrItem)
				{
					if(Selected > this.MaxIndex())
						Selected := this.MaxIndex()
					GuiControl, % this.GUINum ":Choose", % Control.hwnd, % Gui._.Delimiter Selected ;Select next item. | will trigger g-label
				}
				else
					GuiControl, % this.GUINum ":Choose", % Control.ClassNN, % (Selected < IndexTextOrItem ? Selected : Selected - 1)
				;Call selection changed event if there are no more items manually
				if(!this.MaxIndex())
					Control.HandleEvent("")
				for index, item in this
					item._.Index := index
			}
		}
		/*
		Function: MaxIndex
		Returns the number of items in this control.
		*/
		MaxIndex()
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			GUI := CGUI.GUIList[this._.GUINum]
			ControlGet, List, List,,, % "ahk_id " this._.hwnd
			count := 0
			Loop, Parse, List, `n
				count++
			if(!DetectHidden)
				DetectHiddenWindows, Off
			return count
		}
		_NewEnum()
		{
			return new CEnumerator(this)
		}
		/*
		Class: CChoiceControl.CItems.CItem
		A single item of this control.
		*/
		Class CItem
		{
			__New(Index, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.Insert("GUINum", GUINum)
				this._.Insert("hwnd", hwnd)
				this._.Insert("Index", Index)
				this._.Insert("Controls", {})
			}
			/*
			Function: AddControl
			Adds a control to this item that will be visible only when this item is selected. The parameters correspond to the Add() function of CGUI.
			
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
			Property: Selected
			If true, the item is selected.
			
			Property: Text
			The text of the list item.
			*/
			__Get(Name, Params*)
			{
				DetectHidden := A_DetectHiddenWindows
				DetectHiddenWindows, On
				if(Name = "Text")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					ControlGet, List, List,,, % " ahk_id " Control.hwnd
					Loop, Parse, List, `n
						if(A_Index = this._.Index)
						{
							Value := A_LoopField
							break
						}
				}
				else if(Name = "Selected")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					SendMessage, 0x147, 0, 0,,% "ahk_id " Control.hwnd
					ErrorLevel := (ErrorLevel > 0x7FFFFFFF ? -(~ErrorLevel) - 1 : ErrorLevel)
					Value := (this._.Index = ErrorLevel + 1)
				}
				else if(Name = "Controls")
					Value := this._.Controls
				else if(Name = "Index")
					Value := this._.Index
				Loop % Params.MaxIndex()
					if(IsObject(Value)) ;Fix unlucky multi parameter __GET
						Value := Value[Params[A_Index]]
				if(!DetectHidden)
					DetectHiddenWindows, Off
				return Value
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
				if(Name = "Text")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					ItemsString := ""
					SelectedIndex := Control.SelectedIndex
					for index, item in Control.Items
						ItemsString .= Gui._.Delimiter (index = this._.Index ? Value : item.text)
					GuiControl, % this._.GUINum ":", % Control.ClassNN, %ItemsString%
					GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, %SelectedIndex%
					return Value
				}
				else if(Name = "Selected" && Value = 1)
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, % Gui._.Delimiter this._.Index ;| will trigger g-label
					return Value
				}
			}
		}
	}
}