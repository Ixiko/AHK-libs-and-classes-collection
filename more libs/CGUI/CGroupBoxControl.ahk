/*
Class: CGroupBoxControl
A GroupBox control. Nothing special.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CGroupBoxControl Extends CControl
{
	static registration := CGUI.RegisterControl("GroupBox", CGroupBoxControl)

	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "GroupBox"
		this.Insert("_", {})
		this._.Insert("Controls", {})
		;No styles here for now, why would you want them?
	}
	/*
	Function: AddControl
	Adds a control to this groupbox. The parameters correspond to the Add() function of CGUI, but the coordinates are relative to the GroupBox.
	
	Parameters:
		Type - The type of the control.
		Name - The name of the control.
		Options - Options used for creating the control. X and Y coordinates are relative to the GroupBox.
		Text - The text of the control.
	*/
	AddControl(type, Name, Options, Text)
	{
		GUI := CGUI.GUIList[this.GUINum]
		Control := GUI.AddControl(type, Name, Options, Text, this._.Controls, this)
		Control.x := Control.x + this.x
		Control.y := Control.y + this.y
		Control.hParentControl := this.hwnd
		return Control
	}
	
	/*
	Property: Controls
	An array of controls added to this groupbox. The controls are accessed by name.
	*/
	__Get(Name, Params*)
	{
		if(Name = "Controls")
			Value := this._.Controls
		if(Params.MaxIndex() >= 1 && IsObject(value)) ;Fix unlucky multi parameter __GET
		{
			Value := Value[Params[1]]
			if(Params.MaxIndex() >= 2 && IsObject(value))
				Value := Value[Params[2]]
		}
		if(Value != "")
			return Value
	}
	
	/*
	Function: Hide
	Hides the groupbox and all of its controls
	*/
	Hide()
	{
		base.Hide()
		for key, control in this.Controls
			control.Hide()
	}
	/*
	Function: Show()
	Shows the groupbox and all of its controls
	*/
	Show()
	{
		base.Show()
		for key, control in this.Controls
			control.Show()
	}
	/*
	Function: Disable
	Disables the groupbox and all of its controls
	*/
	Disable()
	{
		base.Disable()
		for key, control in this.Controls
			control.Disable()
	}
	/*
	Function: Enable()
	Enables the groupbox and all of its controls
	*/
	Enable()
	{
		base.Enable()
		for key, control in this.Controls
			control.Enable()
	}
}