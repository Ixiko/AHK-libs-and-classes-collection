/*
Class: CLinkControl
A link control that can be used for hyperlinks. It uses HTML-like markup language for links, e.g. <a href="http://www.url.com">URL Text</a>.
href tags are attempted to be executed directly, while id tags are solely handled in script.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CLinkControl Extends CControl
{
	static registration := CGUI.RegisterControl("Link", CLinkControl)

	Click := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Link"
		this._.Insert("Events", ["Click", "DoubleClick"])
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
	
	Event: Click(URLOrID, Index)
	Invoked when the user clicked on a link.
	*/
	HandleEvent(Event)
	{
		this.CallEvent("Click", Event.ErrorLevel, Event.EventInfo)
	}
}