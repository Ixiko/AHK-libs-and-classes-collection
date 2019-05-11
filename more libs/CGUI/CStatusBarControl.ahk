/*
Class: CStatusBarControl
The status bar. Can only be used once per window.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CStatusBarControl Extends CControl
{
	static registration := CGUI.RegisterControl("StatusBar", CStatusBarControl)

	Click := new EventHandler()
	DoubleClick := new EventHandler()
	RightClick := new EventHandler()
	DoubleRightClick := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "StatusBar"
		this._.Insert("ControlStyles", {SizingGrip : 0x100})
		this._.Insert("Events", ["Click", "DoubleClick", "RightClick", "DoubleRightClick"])
	}
	PostCreate()
	{
		Base.PostCreate()
		this._.Parts := new this.CParts(this.GUINum, this.hwnd)
		if(this.Content)
			this._.Parts._.Insert(1, new this.CParts.CPart(Text, 1, "", "", "", "", this.GUINum, this.hwnd))
	}
	/*
	Property: Parts
	An array of status bar parts/segments. See <CStatusBarControl.CParts>
	
	Property: Text
	The text of the first part.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Parts")
			Value := this._.Parts
		else if(Name = "Text")
			Value := this._.Parts[1].Text
		Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
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
		if(Name = "Text") ;Assign text -> assign text of first part
		{
			return this._.Parts[1].Text := Value
		}
		if(Name = "Parts") ;Assign all parts at once
		{
			if(Params[1] >= 1 && Params[1] <= this._.Parts._.MaxIndex()) ;Set a single part
			{
				if(IsObject(Value)) ;Set an object
				{
					Part := new this.CParts.CPart(Value.HasKey("Text") ? Value.Text : "", Params[1], Value.HasKey("Width") ? Value.Width : 50, Value.HasKey("Style") ? Value.Style : "", Value.HasKey("Icon") ? Value.Icon : "", Value.HasKey("IconNumber") ? Value.IconNumber : "", this.GUINum, this.hwnd)
					this._.Parts._.Remove(Params[1])
					this._.Parts._.Insert(Params[1], Part)
					this.RebuildStatusBar()
				}
				else ;Just set text directly
					this._.Parts[Params[1]].Text := Value
				;~ PartNumber := Params.Remove()
				;~ Part := this._.Parts[PartNumber]
				;~ Part := Value ;ASLDIHSVO)UGBOQWFH)=RFZS
				return Value
			}
			else
			{
				Data := Value
				if(!IsObject(Data))
				{
					Data := Object()
					Loop, Parse, Value, |
						Data.Insert({Text : A_LoopField})
				}
				this._.Insert("Parts", new this.CParts(this.GUINum, this.hwnd))
				Loop % Data.MaxIndex()
					this._.Parts._.Insert(new this.CParts.CPart(Data[A_Index].HasKey("Text") ? Data[A_Index].Text : "", A_Index, Data[A_Index].HasKey("Width") ? Data[A_Index].Width : 50, Data[A_Index].HasKey("Style") ? Data[A_Index].Style : "", Data[A_Index].HasKey("Icon") ? Data[A_Index].Icon : "", Data[A_Index].HasKey("IconNumber") ? Data[A_Index].IconNumber : "", this.GUINum, this.hwnd))
				this.RebuildStatusBar()
			}
			return Value
		}
	}
	/*
	Reconstructs the statusbar from the information stored in this.Parts
	*/
	RebuildStatusBar()
	{
		Widths := []
		for index, Part in this._.Parts
			if(index < this._.Parts._.MaxIndex()) ;Insert all but the last one
				Widths.Insert(Part.Width ? Part.Width : 50)
		
		Gui, % this.GUINum ":Default"
		SB_SetParts()
		SB_SetParts(Widths*)
		for index, Part in this._.Parts
		{
			SB_SetText(Part.Text, index, Part.Style)
			;~ if(Part.Icon)
				SB_SetIcon(Part.Icon, Part.IconNumber, index)
		}
	}
	
	/*
	Class: CStatusBarControl.CParts
	An array of StatusBar parts/segments.
	*/
	Class CParts
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", [])
			this.GUINum := GUINum
			this.hwnd := hwnd
		}
		/*
		Property: 1,2,3,4,...
		Individual parts can be accessed by their index. Returns an object of type <CStatusBarControl.CParts.CPart>
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
		Returns the number of parts.
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
					if(Params.MaxIndex() >= 1) ;Set a property of CPart
						(this._[Name])[Params*] := Value
					return Value
				}
			}
		}
		/*
		Function: Add
		Adds a part.
		
		Parameters:
			Text - The text of the part.
			PartNumber - The position at which the new part will appear.
			Width - The width of the new part.
			Style - Style options for the new part. See AHK documentation.
			Icon - An icon filename for the part.
			IconNumber - The index of the icon in a multi-icon file.
		*/
		Add(Text, PartNumber = "", Width = 50, Style = "", Icon = "", IconNumber = "")
		{
			if(PartNumber)
				this._.Insert(PartNumber, new this.CPart(Text, PartNumber, Width, Style, Icon, IconNumber, this.GUINum, this.hwnd))
			else
				this._.Insert(new this.CPart(Text, this._.MaxIndex() + 1, Width, Style, Icon, IconNumber, this.GUINum, this.hwnd))
			Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
			Control.RebuildStatusBar()
		}
		
		/*
		Function: Remove
		Removes a part.
		
		Parameters:
			PartNumber - The index of the part which should be removed.
		*/
		Remove(PartNumber)
		{
			if PartNumber is Integer
			{
				this._.Remove(PartNumber)
				Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
				Control.RebuildStatusBar()
			}
		}
		
		/*
		Class: CStatusBarControl.CParts.CPart
		A single part object.
		*/
		Class CPart
		{
			__New(Text, PartNumber, Width, Style, Icon, IconNumber, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.Text := Text
				this._.PartNumber := PartNumber
				this._.Width := Width
				this._.Style := Style
				this._.Icon := Icon
				this._.IconNumber := IconNumber
				this._.GUINum := GUINum
				this._.hwnd := hwnd
			}
			/*
			Property: Text
			The text of this part.
			
			Property: PartNumber
			The index of this part.
			
			Property: Width
			The width of this part.
			
			Property: Style
			The style of this part. See AHK docs.
			
			Property: Icon
			The path to the icon file assigned to this part.
			
			Property: IconNumber
			The index of the icon in a multi-icon file.
			*/
			__Get(Name)
			{
				if(Name != "_" && this._.HasKey(Name))
					return this._[Name]
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
				Control := CGUI.GUIList[this.GUINum].Controls[this.hwnd]
				if(Name = "Width")
				{
					this._[Name] := Value
					Control.RebuildStatusBar()
					return Value
				}
				else if(Name = "Text" || Name = "Style")
				{
					this._[Name] := Value
					Gui, % this.GUINum ":Default"
					SB_SetText(Name = "Text" ? Value : this._.Text, this._.PartNumber, Name = "Style" ? Value : this._.Style)
					return Value
				}
				else if(Name = "Icon" || Name = "IconNumber")
				{
					this._[Name] := Value
					if(this._.Icon)
					{
						Gui, % this.GUINum ":Default"
						SB_SetIcon(this._.Icon, this._.IconNumber, this._.PartNumber)
					}
					return Value
				}
			}
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
	
	Event: Click(PartIndex)
	Invoked when the user clicked on the control.
	
	Event: DoubleClick(PartIndex)
	Invoked when the user double-clicked on the control.
	
	Event: RightClick(PartIndex)
	Invoked when the user right-clicked on the control.
	
	Event: DoubleRightClick(PartIndex)
	Invoked when the user double-right-clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent({Normal : "Click", DoubleClick : "DoubleClick", Right : "RightClick", R : "DoubleRightClick"}[Event.GUIEvent], Event.EventInfo)
	}
}