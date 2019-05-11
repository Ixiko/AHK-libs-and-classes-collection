/*
Class: CCheckboxControl
A checkbox/radio control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CCheckBoxControl Extends CControl ;This class is a radio control as well
{
	static registration := CGUI.RegisterControl("CheckBox", CCheckBoxControl)
						+ CGUI.RegisterControl("Radio", CCheckBoxControl)

	CheckedChanged := new EventHandler()
	__New(Name, Options, Text, GUINum, Type)
	{
		Options .= " +0x4000" ;BS_NOTIFY to allow receiving BN_SETFOCUS and BN_KILLFOCUS notifications in CGUI
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		this._.Insert("ControlStyles", {Center : 0x300, Left : 0x100, Right : 0x200, RightButton : 0x20, Default : 0x1, Wrap : 0x2000, Flat : 0x8000})
		this._.Insert("Events", ["CheckedChanged"])
		this._.Insert("Controls", {})
		this._.Insert("Messages", {7 : "KillFocus", 6 : "SetFocus" }) ;Used for automatically registering message callbacks
	}
	/*
	Property: Checked
	If true, the control is checked.
	*/
	__Get(Name)
    {
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Checked")
				ControlGet, Value, Checked,,,% "ahk_id " this.hwnd
			else if(Name = "Controls")
				Value := this._.Controls
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
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
			if(Name = "Checked")
			{
				GuiControl, % this.GuiNum ":", % this.ClassNN,% (Value = 0 ? 0 : 1)
				;~ Control, % (Value = 0 ? "Uncheck" : "Check"),,,% "ahk_id " this.hwnd ;This lines causes weird problems. Only works sometimes and might change focus
				Group := this.Type = "Radio" ? this.GetRadioButtonGroup() : [this]
				for Index, Control in Group
					Control.ProcessSubControlState(Control.Checked ? "" : Control, Control.Checked ? Control : "")
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
	Function: AddControl
	Adds a control to this control that will be visible/enabled only when this checkbox/radio button is checked. The parameters correspond to the Add() function of CGUI.
	
	Parameters:
		Type - The type of the control.
		Name - The name of the control.
		Options - Options used for creating the control.
		Text - The text of the control.
		UseEnabledState - If true, the control will be enabled/disabled instead of visible/hidden.
	*/
	AddControl(type, Name, Options, Text, UseEnabledState = 0)
	{
		GUI := CGUI.GUIList[this.GUINum]
		if(!this.Checked)
			Options .= UseEnabledState ? " Disabled" : " Hidden"
		Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
		Control._.UseEnabledState := UseEnabledState
		Control.hParentControl := this.hwnd
		return Control
	}
	/*
	Function: GetRadioButtonGroup
	Returns the group of radio buttons this radio button belongs to as an array of controls.
	*/
	GetRadioButtonGroup()
	{
		GUI := CGUI.GUIList[this.GUINum]
		if(GUI.IsDestroyed)
			return []
		Group := [this]
		if(this.type = "Checkbox")
			return Group
		WinGet, style, Style, % "ahk_id " this.hwnd
		;Backtrack all previous controls in the tab order
		if(!(style & 0x00020000)) ;WS_GROUP
		{
			hwnd := this.hwnd
			while(true)
			{
				;Get previous window handle
				hwnd := DllCall("GetWindow", "PTR", hwnd, "UINT", 3, "PTR") ;GW_HWNDPREV
				WinGetClass, class, ahk_id %hwnd%
				WinGet, style, Style, ahk_id %hwnd%
				if(class = "Button" && (style & 0x0004 || style & 0x0009)) ;BS_AUTORADIOBUTTON or BS_RADIOBUTTON
				{
					if(GUI.Controls.HasKey(hwnd))
						Group.Insert(Gui.Controls[hwnd])
					WinGet, style, Style, % "ahk_id " hwnd
					if(style & 0x00020000) ;WS_GROUP
						break
				}
				else
					break
			}
		}
		
		hwnd := this.hwnd
		;Go forward until the next group is found
		while(true)
		{
			;Get next window handle
			hwnd := DllCall("GetWindow", "PTR", hwnd, "UINT", 2, "PTR") ;GW_HWNDNEXT
			WinGetClass, class, ahk_id %hwnd%
			WinGet, style, Style, ahk_id %hwnd%
			if(class = "Button" && (style & 0x0004 || style & 0x0009)) ;BS_AUTORADIOBUTTON or BS_RADIOBUTTON
			{
				WinGet, style, Style, % "ahk_id " hwnd
				if(style & 0x00020000) ;WS_GROUP
					break
				if(GUI.Controls.HasKey(hwnd))
					Group.Insert(Gui.Controls[hwnd])
			}
			else
				break
		}
		return Group
	}
	
	/*
	Function: GetSelectedRadioButton
	Returns the radio button control of the current group which is currently selected. Returns 0 if no button is selected.
	*/
	GetSelectedRadioButton()
	{
		if(this.type = "Checkbox" && !this.Selected)
			return 0
		for index, Control in this.GetRadioButtonGroup()
			if(Control.Selected)
				return Control
		return 0
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
	
	Event: CheckedChanged()
	Invoked when the checkbox/radio value changes.
	*/
	HandleEvent(Event)
	{
		Group := this.Type = "Radio" ? this.GetRadioButtonGroup() : [this]
		for Index, Control in Group
			Control.ProcessSubControlState(Control.Checked ? "" : Control, Control.Checked ? Control : "")
		this.CallEvent("CheckedChanged")
	}
}