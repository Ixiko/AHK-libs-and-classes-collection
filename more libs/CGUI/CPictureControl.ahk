/*
Class: CPictureControl
A picture control.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CPictureControl Extends CControl
{
	static registration := CGUI.RegisterControl("Picture", CPictureControl)

	Click := new EventHandler()
	DoubleClick := new EventHandler()
	
	__New(Name, Options, Text, GUINum)
	{
		if(Text && DllCall("GetObjectType", "PTR", Text) != (OBJ_BITMAP := 7) && !FileExist(Text)) ;If Text is no bitmap or path, assume that it's an icon and add the matching style
			Options .= " +0x3"
		if(InStr(FileExist(Text), "D"))
		{
			Options .= " +0x3"
			VarSetCapacity(Path, 260 * 2) ;MAXPATH
		  	Path := Text
			Text := DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", Path, "UShortP", lpiIcon, "Ptr")
		}
		if Text is Number
			base.__New(Name, Options, Text, GUINum)
		else
			base.__New(Name, Options, Text, GUINum)
		Gdip_GetImageDimensions(pBitmap, w, h)
		this.Type := "Picture"
		this._.Insert("Picture", Text)
		this._.Insert("ControlStyles", {Center : 0x200, ResizeImage : 0x40})
		this._.Insert("Events", ["Click", "DoubleClick"])
	}
	PostCreate()
	{
		base.PostCreate()
		text := this._.Picture
		if text is number
		{
			this._.Picture := ""
			this.SetImageFromHBitmap(text)
		}
	}
	/*
	Property: Picture
	The picture can be changed by assigning a filename to this property.
	If the picture was set by providing a hBitmap in <SetImageFromHBitmap>, this variable will be empty.
	
	Property: PictureWidth
	The width of the currently displayed picture in pixels.
	
	Property: PictureHeight
	The height of the currently displayed picture in pixels.
	*/
	__Get(Name)
    {
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Picture")
				Value := this._.Picture
			else if(Name = "PictureWidth" || Name = "PictureHeight")
			{
				if(!this._.HasKey(Name))
				{
					pBitmap := Gdip_CreateBitmapFromFile(this._.Picture) ;Note: This does not work if the user specifies icon number or other special properties in picture path since these are handled as separate parameters here.
					Gdip_GetImageDimensions(pBitmap, w, h)
					this._.PictureWidth := w
					this._.PictureHeight := h
					Gdip_DisposeImage(pBitmap)
				}
				Value := this._[Name]
			}
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
			if(Name = "Picture")
			{
				Gui, % this.GUINum ":Default"
				GuiControl,, % this.ClassNN, %Value%
				this._.Picture := Value
				this._.Remove("PictureWidth")
				this._.Remove("PictureHeight")
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
	Function: SetImageFromHBitmap
	Sets the image of this control.
	
	Parameters:
		hBitamp - The bitmap handle to which the picture of this control is set. Can also be hIcon if the control has a 0x3 style on creation. This style is added automatically when a hIcon is used as Text on creation.
	*/
	SetImageFromHBitmap(hBitmap, Path = "")
	{
		if(DllCall("GetObjectType", "PTR", hBitmap) = (OBJ_BITMAP := 7))
		{
			SendMessage, STM_SETIMAGE := 0x0172, 0, hBitmap,, % "ahk_id " this.hwnd
			DllCall("gdi32\DeleteObject", "PTR", ErrorLevel)
		}
		else
		{
			SendMessage, STM_SETICON := 0x0170, hBitmap, 0,, % "ahk_id " this.hwnd
			DestroyIcon(ErrorLevel)
		}
		this._.Remove("PictureWidth")
		this._.Remove("PictureHeight")
		this._.Picture := Path
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
	Invoked when the user clicked on the control.
	
	Event: DoubleClick()
	Invoked when the user double-clicked on the control.
	*/
	HandleEvent(Event)
	{
		this.CallEvent(Event.GUIEvent = "DoubleClick" ? "DoubleClick" : "Click")
	}
	

}