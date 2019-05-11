/*
Class: CHotkeyControl
A Hotkey control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CHotkeyControl Extends CControl
{
	static registration := CGUI.RegisterControl("Hotkey", CHotkeyControl)

	HotkeyChanged := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Hotkey"
		;Hotkey control does not support FocusEnter and FocusLeave events
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
	
	Event: HotkeyChanged()
	Invoked when the user clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("HotkeyChanged")
	}
}