/*
Class: CProgressControl
A Progress control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CProgressControl Extends CControl
{
	static registration := CGUI.RegisterControl("Progress", CProgressControl)

	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Progress"
		this._.Insert("ControlStyles", {Vertical : 0x4, Smooth : 0x1, Marquee : 0x8})
		;TODO: Range in options is not parsed but could potentially be set by the user
		this._.Insert("Min", 0)
		this._.Insert("Max", 100)
	}
	
	/*
	Property: Value
	The Value of the progress indicator. Relative offsets are possible by adding a sign when assigning it, i.e. Progress.Value := "+10". Progress.Value += 10 is also possible but less efficient.
	
	Property: Min
	The minimum value of the progress indicator.
	
	Property: Max
	The maximum value of the progress indicator.
	*/
	__Get(Name, Params*)
	{
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Value")
				GuiControlGet, Value, % this.GUINum ":", % this.ClassNN
			else if(Name = "Min")
				Value := this._.Min
			else if(Name = "Max")
				Value := this._.Max
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
			if(Name = "Value")
				GuiControl, % this.GUINum ":", % this.ClassNN, %Value%
			else if(Name = "Min")
			{
				GuiControl, % this.GUINum ":+Range" Value "-" this._.Max, % this.ClassNN
				this._.Min := Value
			}
			else if(Name = "Max")
			{
				GuiControl, % this.GUINum ":+Range" this._.Min "-" Value, % this.ClassNN
				this._.Max := Value
			}
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
}