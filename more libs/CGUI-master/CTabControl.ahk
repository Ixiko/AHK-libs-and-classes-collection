/*
Class: CTabControl
A tab container control. The controls added to a tab panel can be accessed through this object.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CTabControl Extends CControl
{
	static registration := CGUI.RegisterControl("Tab", CTabControl)

	Click := new EventHandler()
	DoubleClick := new EventHandler()
	RightClick := new EventHandler()
	DoubleRightClick := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Tab2" ;Use Tab2 initially but revert back to Tab in PostCreate to mask the real AHK type of the control.
		this._.Insert("ControlStyles", {Bottom : 0x2, HotTrack : 0x40, Buttons : 0x100, MultiLine : 0x200})
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
		; this._.Insert("Messages", {0x004E : "Notify"})
		CGUI.GUIList[this.GUINum].TabCount := CGUI.GUIList[this.GUINum].TabCount ? CGUI.GUIList[this.GUINum].TabCount + 1 : 1 ;Increase count of tabs in this GUI, required for GUI, Tab command
		this._.Insert("TabIndex", CGUI.GUIList[this.GUINum].TabCount)
	}
	
	PostCreate()
	{
		Base.PostCreate()
		;Make sure future controls don't get added to this tab
		Gui, % this.GUINum ":Tab"
		this.Type := "Tab" ;Fix tab type value
		this._.Insert("ImageListManager", new this.CImageListManager(this.GUINum, this.hwnd))
		this._.Tabs := new this.CTabs(this.GUINum, this.hwnd)
		
		;Add Tabs
		this.Tabs.Add(this.Content)
	}
	/*
	Property: Tabs
	A list of all tabs. Each tab contains a list of controls that belong to it. The returned object is of type <CTabControl.CTabs>
	
	Property: Text
	The text of the first tab.
	
	Property: SelectedItem
	The selected tab item.
	
	Property: SelectedIndex
	The index of the selected tab item.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Tabs")
			Value := this._.Tabs
		else if(Name = "Text")
			Value := this._.Tabs[1].Text
		else if(Name = "SelectedItem")
		{
			ControlGet, Value, Tab, , , % "ahk_id " this.hwnd
			Value := this.Tabs[Value]
		}
		else if(Name = "Selectedndex")
			ControlGet, Value, Tab, , , % "ahk_id " this.hwnd
		if(Params.MaxIndex() >= 1 && IsObject(value)) ;Fix unlucky multi parameter __GET
		{
			Value := Value[Params[1]]
			if(Params.MaxIndex() >= 2 && IsObject(value))
				Value := Value[Params[2]]
		}
		if(Value != "")
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
		Handled := true
		if(Name = "Text") ;Assign text -> assign text of first Tab
			this._.Tabs[1].Text := Value
		else if(Name = "Tabs")
		{
			if(Params[1] >= 1 && Params[1] <= this._.Tabs.MaxIndex()) ;Set a single Tab
			{
				if(IsObject(Value)) ;Set an object
				{
					this._.Tabs[Params[1]].Text := Value.Text
					;Maybe do this later when icons are available?
					;~ Tab := new this.CTabs.CTab(Value.HasKey("Text") ? Value.Text : "", Params[1], this.GUINum, this.Name)
					;~ this._.Tabs._.Remove(Params[1])
					;~ this._.Tabs._.Insert(Params[1], Tab)
				}
				else ;Just set text directly
					this._.Tabs[Params[1]].Text := Value
			}
		}
		else if(Name = "SelectedItem" && CGUI_TypeOf(Value) = "CTabControl.CTabs.CTab")
			GuiControl, % this._.GUINum ":Choose", % this.ClassNN, % Value._.TabNumber
		else if(Name = "SelectedIndex" && CGUI_TypeOf(Value) = "CTabControl.CTabs.CTab")
			GuiControl, % this._.GUINum ":Choose", % this.ClassNN, % Value
		else
			Handled := false
		if(Handled)
			return Value
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
	
	Event: Click(TabItem)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(TabItem)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(TabItem)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(TabItem)
	Invoked when the user double-right-clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent({Normal : "Click", DoubleClick : "DoubleClick", Right : "RightClick", R : "DoubleRightClick"}[Event.GUIEvent], this.SelectedItem)
	}
	/*
	Class: CTabControl.CTabs
	An array of tabs.
	*/
	Class CTabs
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.hwnd := hwnd
		}
		/*
		Property: 1,2,3,4,...
		Individual tabs can be accessed by their index.
		*/
		__Get(Name, Params*)
		{
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1)
						return this._[Name][Params*]
					else
						return this._[Name]
				}
			}
		}
		/*
		Function: MaxIndex
		Returns the number of tabs.
		*/
		MaxIndex()
		{
			return this._.MaxIndex()
		}
		_NewEnum()
		{
			return new CEnumerator(this._)
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
			if Name is Integer
			{
				if(Name <= this._.MaxIndex())
				{
					if(Params.MaxIndex() >= 1) ;Set a property of CTab
					{
						Tab := this._[Name]
						Tab[Params*] := Value
					}
					return Value
				}
			}
		}
		
		/*
		Function: Add
		Adds a tab.
		
		Parameters:
			Text - The text of the new tab. If this parameter contains a pipe character (|), multiple tabs will be created and the return value is an array of CTab objects.
			
		Returns:
			An object of type <CTabControl.CTabs.CTab>. If multiple tabs are created, an array of CTab objects is returned.
		*/
		Add(Text)
		{
			Static TCM_GETITEMCOUNT := 0x1304
			Static TCM_INSERTITEMA  := 0x1307
			Static TCM_INSERTITEMW  := 0x133E
			Static TCM_INSERTITEM := A_IsUnicode ? TCM_INSERTITEMW : TCM_INSERTITEMA
			Static TCITEMSize := (5 * 4) + (2 * A_PtrSize) + (A_PtrSize - 4)
			Static TCIF_TEXT := 0x0001
			Static TEXTPos := (3 * 4) + (A_PtrSize - 4)
			Tabs := []
			Loop, Parse, Text, |
			{
				TabNumber := this._.MaxIndex() ? this._.MaxIndex() + 1 : 1
				Tab := new this.CTab(A_LoopField, TabNumber, this.GUINum, this.hwnd)
				this._.Insert(Tab)
				Tabs.Insert(Tab)
				Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
				;~ GuiControl, % this.GUINum ":", % Control.hwnd, %A_loopField% ;Doesn't work in current AHK_L
				VarSetCapacity(TCITEM, TCITEMSize, 0)
				NumPut(TCIF_TEXT, TCITEM, 0, "UInt")
				txt := A_LoopField
				NumPut(&txt, TCITEM, TEXTPos, "Ptr")
				SendMessage, TCM_INSERTITEM, Control.Tabs.MaxIndex(), &TCITEM,, % "ahk_id " Control.HWND
			}
			return Tabs.MaxIndex() > 1 ? Tabs : Tabs[1]
		}
		;Removing tabs is unsupported for now because the controls will not be removed
		;~ Remove(TabNumber)
		;~ {
		;~ }
		
		/*
		Class: CTabControl.CTabs.CTab
		A single tab object.
		*/
		Class CTab
		{
			__New(Text, TabNumber, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.TabNumber := TabNumber
				this._.GUINum := GUINum
				this._.hwnd := hwnd
				this._.Controls := {}
				if (CGUI.GUIList[GUINum].Controls.HasKey(hwnd))
					GuiControl, %GUINum%:, % CGUI.GUIList[GUINum].Controls[hwnd].ClassNN, %Text%
			}
			
			/*
			Function: AddControl
			Adds a control to this tab. The parameters correspond to the Add() function of CGUI.
			
			Parameters:
				Type - The type of the control.
				Name - The name of the control.
				Options - Options used for creating the control.
				Text - The text of the control.
			*/
			AddControl(type, Name, Options, Text)
			{
				if(type != "Tab")
				{
					GUI := CGUI.GUIList[this.GUINum]
					TabControl := GUI.Controls[this._.hwnd]
					Gui, % this.GUINum ":Tab", % this._.TabNumber, % TabControl._.TabIndex
					Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
					Control.hParentControl := this._.hwnd
					Control.TabNumber := this._.TabNumber
					Gui, % this.GUINum ":Tab"
					return Control
				}
				else
					Msgbox Tabs may not be added in a tab container.
			}
			/*
			Property: Text
			The text of the tab.
			
			Property: Icon
			The filename of the icon associated with this tab.
			
			Property: IconNumber
			The index of the icon in a multi-icon file.
			*/
			__Get(Name, Params*)
			{
				if(Name != "_" && this._.HasKey(Name))
					Value := this._[Name]
				Loop % Params.MaxIndex()
					if(IsObject(Value)) ;Fix unlucky multi parameter __GET
						Value := Value[Params[A_Index]]
				if(Value)
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
					GUI := CGUI.GUIList[this.GUINum]
					Control := GUI.Controls[this.hwnd]
					Tabs := ""
					for index, Tab in Control.Tabs
						if(index != this._.TabNumber)
							Tabs .= GUI._.Delimiter Tab.Text
						else
							Tabs .= GUI._.Delimiter Value
					this._[Name] := Value
					GuiControl, % this.GUINum ":", % Control.ClassNN, %Tabs%
					return Value
				}
				else if(Name = "Icon")
				{
					this.SetIcon(Value, this.IconNumber ? this.IconNumber : 1)
					return Value
				}
				else if(Name = "IconNumber")
				{
					this.IconNumber := Value
					if(this.Icon)
						this.SetIcon(this.Icon, Value)
					return Value
				}
			}
			/*
			Function: SetIcon
			Sets the icon of a tab.
			
			Parameters:
				Filename - The filename of the file containing the icon.
				IconNumber - The icon number in a multi-icon file.
			*/
			SetIcon(Filename, IconNumber = 1)
			{
				this._.Icon := Filename
				this._.IconNumber := IconNumber
				Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
				Control._.ImageListManager.SetIcon(this._.TabNumber, Filename, IconNumber)
			}
		}
	}
}