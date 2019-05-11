/*
Class: CButtonControl
A button control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CButtonControl Extends CControl
{
	static registration := CGUI.RegisterControl("Button", CButtonControl)

	Click := new EventHandler()
	__New(Name, Options, Text, GUINum)
	{
		Options .= " +0x4000" ;BS_NOTIFY to allow receiving BN_SETFOCUS and BN_KILLFOCUS notifications in CGUI
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Button"
		this._.Insert("ControlStyles", {Center : 0x300, Left : 0x100, Right : 0x200, Default : 0x1, Wrap : 0x2000, Flat : 0x8000})
		this._.Insert("Events", ["Click"])
		this._.Insert("Messages", {7 : "KillFocus", 6 : "SetFocus" }) ;Used for automatically registering message callbacks
	}
	
	PostCreate()
	{
		this.Style := "+0x4000" ;BS_NOTIFY to allow receiving BN_SETFOCUS and BN_KILLFOCUS notifications in CGUI
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
	
	Event: Click()
	Invoked when the user clicked on the button.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("Click")
	}
}