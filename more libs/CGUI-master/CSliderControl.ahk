/*
Class: CSliderControl
A Slider control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CSliderControl Extends CControl
{
	static registration := CGUI.RegisterControl("Slider", CSliderControl)

	SliderMoved := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Slider"
		this._.Insert("ControlStyles", {Vertical : 0x2, Left : 0x4, Center : 0x8, AutoTicks : 0x1, Thick : 0x40, NoThumb : 0x80, NoTicks : 0x10, Tooltips : 0x100})
		;TODO: Range in options is not parsed but could potentially be set by the user
		this._.Insert("Min", 0)
		this._.Insert("Max", 100)
		this._.Insert("Invert", InStr(Options, "Invert"))
		; this._.Insert("Messages", {0x004E : "Notify"}) ;This control uses WM_NOTIFY with NM_SETFOCUS and NM_KILLFOCUS
		this._.Insert("Events", ["SliderMoved"])
	}
	
	/*
	Property: Value
	The value of the Slider control. Relative offsets are possible by adding a sign when assigning it, i.e. Slider.Value := "+10". Slider.Value += 10 is also possible but less efficient.
	
	Property: Min
	The minimum value of the Slider control.
	
	Property: Max
	The maximum value of the Slider control.
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
			else if(Name = "Invert")
				Value := this._.Invert
			else if(Name = "Line")
				Value := this._.Line
			else if(Name = "Page")
				Value := this._.Page
			else if(Name = "TickInterval")
				Value := this._.TickInterval
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
			else if(Name = "Line")
			{
				GuiControl, % this.GUINum ":+Line" Value, % this.ClassNN
				this._.Line := Value
			}
			else if(Name = "Page")
			{
				GuiControl, % this.GUINum ":+Page" Value, % this.ClassNN
				this._.Page := Value
			}
			else if(Name = "TickInterval")
			{
				GuiControl, % this.GUINum ":+TickInterval" Value, % this.ClassNN
				this._.TickInterval := Value
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
	
	Event: SliderMoved()
	Invoked when the user clicked on the control. This control does not implement all the advanced Slider events yet. Should be easy to implement though if there is any demand.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("SliderMoved")
	}
}