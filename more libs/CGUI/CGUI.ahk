#NoEnv ;Leave this here if you don't want weird ListView icon behavior (and possibly other side effects)
/*
   Class: CGUI
   The main GUI class. User created GUIs need to extend this class and call Base.__New() in their constructor before doing anything related to this class.

   Property: Accessing Controls
   Controls may be accessed by their name by using GUI.Name or by their window handle by using GUI.Controls[hwnd] (assuming Name is a string and hwnd is a variable).
   The difference between these two methods is that controls which are added as sub-controls to other controls are not accessible by their name through the main GUI object. They can either be accessed by hwnd like described above or by GUI.ParentControl.Controls.SubControlName (again assuming that SubControlName is a string).
*/
Class CGUI {
	static GUIList := {}
	static EventQueue := []
	static WindowMessageListeners := []
	static RegisteredControls := {}

	;~ _ := {} ;Proxy object
	/*
	Get only:
	var Controls := {}
	var hwnd := 0
	var GUINum := 0
	MinMax
	Instances ;Returns a list of instances of this window class


	var CloseOnEscape := 0 ;If true, pressing escape will call the PreClose() event function if defined. Otherwise, it will call Escape() if it is defined.
	var DestroyOnClose := 0 ;If true, the gui will be destroyed instead of being hidden when it gets closed by the user.

	Not supported:
	var Label := "CGUI_" ;Labels are handled internally and get rerouted to event functions defined in the class which extends CGUI
	var LastFoundExist := 0 ;This is not needed because the GUI is created anyway when the class gets instantiated.

	Event functions that can be defined in the class that extends CGUI:
	Size(Event) ;Called when window size changes
				;Possible values for Event:
				;0: The window has been restored, or resized normally such as by dragging its edges.
				;1: The window has been minimized.
				;2: The window has been maximized.

	ContextMenu() ;Called when a context menu is about to be invoked. This is mostly useless for now because the control can not get identified properly
	DropFiles() ;Called when files were dropped on the gui. This is mostly useless for now because the control can not get identified properly
	PreClose() ;Called when the window is about to be closed or when Escape was pressed and CloseOnEscape = true. If it returns true, the window is kept open. Otherwise it will be hidden or destroyed depending on the value of DestroyOnClose
	PostDestroy() ;Called when the window was destroyed. Attention: Many variables and functions in this object aren't usable anymore. This function is mostly used to release additional resources or to exit the program.
	Escape() ;Called when escape is pressed and CloseOnEscape = false. The window is not automatically hidden/destroyed when CloseOnEscape = false.
	*/

	;The _Constructor key is never actually assigned (see __Set()). This line simply calls the __New() constructor of CGUI so that window classes deriving from CGUI do not need to call the base constructor.
	_Constructor := this.base.base.__New(this)

	;Used for keeping track of the window size. Until the window is shown for the first time or manual size is set
	;it will keep updating the size of the (invisible) window when new controls are added.
	_Initialized := false

	/*
	Event Handler: OnClose(Source)
	Invoked when the window is closed (hidden or destroyed).

	Event Handler: OnDestroy(Source)
	Invoked when the window is destroyed.
	*/
	OnClose := new EventHandler()
	OnDestroy := new EventHandler()

	__New(instance)
	{
		if(!CGUI_Assert(IsObject(instance) && !instance.HasKey("hwnd"), "CGUI constructor must not be called!"))
			return
		this.Insert("_", {}) ;Create proxy object to store some keys in it and still trigger __Get and __Set
		start := 1
		loop {
			GUINum := instance.__Class start
			Gui %GUINum%:+LastFoundExist
			IfWinNotExist
			{
				instance.GUINum := GUINum
				break
			}
			start++
		}
		if(!instance.GUINum) ;Should not happen unless instance uses a faulty __Set() mechanism
			return
		instance.Controls := {}
		instance.Font := new CFont(instance.GUINum)
		CGUI.GUIList[instance.GUINum] := instance
		GUI, % instance.GUINum ":+LabelCGUI_ +LastFound"
		instance.hwnd := WinExist()
		instance._.Delimiter := "|"
		/*
		Prepare for some HAX!
		The code below enables the user of this library to create subclasses inside the GUI class that represent controls.
		It scans through the object and looks for fitting subclasses.
		Then a an object based on a copy of a subclass is created and a control with the params specified in the subclass is created.
		The base of the copied subclass is changed to the newly created control object so that the functions in the subclass can access the control object through the this keyword.
		Event functions are also preferably routed to subclasses.
		*/
		for key, Value in instance.base
		{
			if(IsObject(Value) && Value.HasKey("__Class") && Value.HasKey("Type") && Value.HasKey("Options")	&& Value.HasKey("Text")) ;Look for classes that define a type property
			{
				;~ if(!CGUI_Assert(Value.Type != "", "Control class definitions must use static properties."))
					;~ continue
				Name := Value.HasKey("Name") ? Value.Name : SubStr(Value.__Class, InStr(Value.__Class, ".") + 1)
				control := instance.AddControl(Value.Type, Name, Value.Options, Value.Text)
				instance[Name] := {base : ObjClone(Value)}
				instance[Name].base.base := control
				instance.Controls[instance[Name].hwnd] := instance[Name]
				if(IsFunc(instance[Name].__New) = 3)
					instance[Name].__New(instance)
				else if(IsFunc(instance[Name].__New) = 2)
					instance[Name].__New()
				if(IsFunc(instance[Name].__Init))
					instance[Name].__Init()
			}
		}

		Gui, % instance.GUINum ":Show", Hide Autosize Center
		;~ WinGetPos, x, y, w, h, % "ahk_id " instance.hwnd
		;~ msgbox % "w " w " h " h
		;Register for WM_COMMAND and WM_NOTIFY messages since they are commonly used for various purposes.
		;~ instance.OnMessage(WM_COMMAND := 0x111, "HandleInternalMessage")
		;~ instance.OnMessage(WM_NOTIFY := 0x004E, "HandleInternalMessage")
	}
	;This class handles window message routing to the instances of window classes that register for a specific window message
	Class WindowMessageHandler
	{
		static WindowMessageListeners := [] ;This object stores instances of this class that are associated with a specific window message. The instances keep records of all windows that listen to this message.
		__New(Message)
		{
			this.Message := Message
			this.Listeners := [] ;Array containing all window classes that listen to Message.
			this.ListenerCount := 0 ;Number of all window class instances that are listening to a message
		}
		/*
		Registers a window instance as a listener to a window message.
		If hwnd is an object, it represents a window object that is handled separately for internal messages.
		*/
		RegisterListener(Message, hwnd, FunctionName)
		{
			;Don't allow calling this function on the contained instances
			if(IsObject(this.base) && this.base.__Class = this.__Class)
				return
			if(hwnd > 0)
				GUI := CGUI.GUIFromHWND(hwnd)
			else if(IsObject(hwnd)) ;Support internal window messages by storing them with a hwnd value of zero.
			{
				GUI := hwnd
				hwnd := 0
			}

			;if parameters are valid and the listener isn't registered yet, add it and possibly set up the OnMessage Callback
			if(Message && GUI && FunctionName && IsFunc(GUI[FunctionName]))
			{
				;If the current message hasn't been registered anywhere
				if(!this.WindowMessageListeners.HasKey(Message))
				{
					this.WindowMessageListeners[Message] := new this(Message)
					OnMessage(Message, "CGUI_WindowMessageHandler")
				}

				Listeners := this.WindowMessageListeners[Message]
				;If this instance isn't already registered for this message, increase listener count for this message
				if(!Listeners.Listeners.HasKey(hwnd))
					Listeners.ListenerCount++

				;Register the message in the listeners list of the CWindowMessageHandler object associated with the current Message
				Listeners.Listeners[hwnd] := FunctionName

			}
			CGUI_Assert(IsFunc(GUI[FunctionName]), "Invalid function definition " GUI[FunctionName] ". Function takes 3 parameters, Msg, wParam and lParam.")
		}
		UnregisterListener(hwnd, Message = "")
		{
			;Don't allow calling this function on the contained instances
			if(this.Base.__Class = this.__Class)
				return
			GUI := CGUI.GUIFromHWND(hwnd)
			if(GUI)
			{
				;Remove one or all registered listeners associated with the window handle
				if(!Message)
				{
					Messages := []
					for Msg, Handler in this.WindowMessageListeners
						Messages.Insert(MSG)
				}
				Else
					Messages := [Message]
				for index, CurrentMessage in Messages ;Process all messages that are affected
				{
					;Make sure the window is actually registered right now so it doesn't get unregistered multiple times if this function happens to be called more than once with the same parameters
					Listeners := this.WindowMessageListeners
					if(Listeners.HasKey(CurrentMessage) && Listeners[CurrentMessage].Listeners.HasKey(hwnd))
					{
						Listeners := Listeners[CurrentMessage]
						;Remove this window from the listener array
						Listeners.Listeners.Remove(hwnd, "")

						;Decrease count of window class instances that listen to this message
						Listeners.ListenerCount --

						;If no more instances listening to a window message, remove the CWindowMessageHandler object from WindowMessageListeners and deactivate the OnMessage callback for the current message
						if(Listeners.ListenerCount = 0)
						{
							this.WindowMessageListeners.Remove(CurrentMessage, "")
							OnMessage(CurrentMessage, "")
						}
					}
				}
			}
		}
	}
	__Delete()
	{
	}

	/*
	Function: OnMessage
	Registers a window instance as a listener for a specific window message.

	Parameters:
		Message - The number of the window message
		FunctionName - The name of the function contained in the instance of the window class that will be called when the message is received.
		To stop listening, skip this parameter or leave it empty. To change to another function, simply specify another name (stopping first isn't required). The function won't be called anymore after the window is destroyed. DON'T USE GUI, DESTROY ON ANY WINDOWS CREATED WITH THIS LIBRARY THOUGH. Instaed use window.Destroy() or window.Close() when window.DestroyOnClose is enabled.
		The function accepts four parameters, Message, wParam, lParam and hwnd (in this order). hwnd can be the window handle of the window or the related control (e.g. for WM_KEYDOWN)
	*/
	OnMessage(Message, FunctionName = "")
	{
		if(this.IsDestroyed)
			return
		if(FunctionName)
			this.WindowMessageHandler.RegisterListener(Message, this.hwnd, FunctionName)
		else
			this.WindowMessageHandler.UnregisterListener(this.hwnd, Message)
	}

	/*
	Function: Destroy

	Destroys the window. Any possible references to this class should be removed so its __Delete() function may get called. Make sure not attempt to use this window anymore!
	*/
	Destroy()
	{
		if(this.IsDestroyed)
			return
		;Remove it from GUI list
		CGUI.GUIList.Remove(this.GUINum) ;make sure not to alter other GUIs here
		this.IsDestroyed := true
		this.WindowMessageHandler.UnregisterListener(this.hwnd) ;Unregister all registered window message listener functions
		;Destroy the GUI
		Gui, % this.GUINum ":Destroy"
		;Call PostDestroy function
		if(IsFunc(this.PostDestroy))
		{
			this.PostDestroy()
			this.OnDestroy.(this)
		}
	}

	/*
	Function: Show

	Shows the window.

	Parameters:

		Options - Same as in Gui, Show command
	*/
	Show(Options="")
	{
		if(this.IsDestroyed)
			return
		if(this.HasKey("_Initialized")) ;Prevent recalculating size after it has been shown the first time
			this.Remove("_Initiliazed")
		Gui, % this.GUINum ":Show",%Options%, % this.Title
	}

	/*
	Function: Activate

	Activates the window.
	*/
	Activate()
	{
		if(this.IsDestroyed)
			return
		WinActivate, % "ahk_id " this.hwnd
	}

	/*
	Function: Close
	Closes the window. Effectively the same as clicking the x in the title bar.
	*/
	Close()
	{
		PostMessage, 0x112, 0xF060,,, % "ahk_id " this.hwnd  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
	}
	/*
	Function: Hide

	Hides the window.
	*/
	Hide()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Hide"
	}

	/*
	Function: Minimize

	Minimizese the window.
	*/
	Minimize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Minimize"
	}

	/*
	Function: Maximize

	Maximizes the window.
	*/
	Maximize()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Maximize"
	}

	/*
	Function: Restore

	Restores the window.
	*/
	Restore()
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Restore"
	}
	/*
	Function: Redraw

	Attempts to redraw the window.
	*/
	Redraw()
	{
		if(this.IsDestroyed)
			return
		WinSet, Redraw,,% "ahk_id " this.hwnd
	}

	/*
	Disable this stuff
	a Function: Font

	Changes the default font used for controls from here on.

	a Parameters:
		Options - Font options, size etc. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
		Fontname - Name of the font. See http://www.autohotkey.com/docs/commands/Gui.htm#Font
	*/
	;~ Font(Options, Fontname)
	;~ {
		;~ if(this.IsDestroyed)
			;~ return
		;~ Gui, % this.GUINum ":Font", %Options%, %Fontname%
	;~ }

	/*
	Function: Color

	Changes the default font used for controls from here on.

	Parameters:
		WindowColor - Color of the window background. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
		ControlColor - Color for controls. See http://www.autohotkey.com/docs/commands/Gui.htm#Color
	*/
	Color(WindowColor, ControlColor)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Color", %WindowColor%, %ControlColor%
	}

	/*
	Function: Margin

	Changes the margin used between controls. Previously added controls are not affected.

	Parameters:
		x - Distance between controls on the x-axis.
		y - Distance between controls on the y-axis.
	*/
	Margin(x, y)
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Margin", %x%, %y%
	}

	/*
	Function: Flash

	Flashes the taskbar button of this window.

	Parameters:
		Off - Leave empty to flash the taskbar. Use "Off" to disable flashing and restore normal state.
	*/
	Flash(Off = "")
	{
		if(this.IsDestroyed)
			return
		Gui, % this.GUINum ":Flash", %Off%
	}

	/*
	Function: AddMenuBar
	Attaches a menu bar to the window. The menu object can be accessed under the "Menu" property of the class instance deriving from CGUI.

	Parameters:
		Menu - An instance of <CMenu> containing the menu information. Leave empty to remove the menu. If the menu object is attached as menu bar, it can not be used as a context menu anymore.
	*/
	AddMenuBar(Menu)
	{
		if(this.IsDestroyed)
			return
		this.Menu := Menu
		Gui, % this.GUINum ":Menu", % Menu.Name
	}

	/*
	Function: ShowMenu
	Shows a menu. This function is the preferred way to show menus that use callback functions inside the gui class that derives from CGUI.

	Paramters:
		Menu - The <CMenu> object which contains the menu information
		X - X position of the menu.
		Y - Y position of the menu.
	*/
	ShowMenu(Menu, X="", Y="")
	{
		Menu.Show(this.GUINum, X, Y)
	}
	/*
	Function: AddControl

	Creates and adds a control to the window.

	Parameters:
		Control - The type of the control. The control needs to be a name that can be translated to a class inheriting from CControl, e.g. "Text" -> "CTextControl". Valid values are:
					- Text
					- Edit
					- Button
					- Checkbox
					- Radio
					- ListView
					- ComboBox
					- DropDownList
					- ListBox
					- TreeView
					- Tab
					- GroupBox
					- Picture
					- Progress
					- ActiveXControl
					- SysLinkControl
		Name - The name of the control. Names must be unique and must not be empty. The returned control object is usually assigned to GUI.ControlName after calling this function and can then be accessed by its name directly from the GUI object, i.e. GUI.MyEdit1 or similar. Otherwise the control can be accessed by window handle through the GUI.Controls array.
		Options - Default options to be used for the control. These are in default AHK syntax according to <http://www.autohotkey.com/docs/commands/Gui.htm#OtherOptions> and <http://www.autohotkey.com/docs/commands/GuiControls.htm>. Do not use GUI variables (v option) and g-labels (g option).
		Text - Text of the control. For some controls, this parameter has a special meaning. It can be a list of items or a collection of column headers separated by "|".

	Returns: The created control object
	*/
	AddControl(Control, Name, Options = "", Text = "", ControlList="", ParentControl = "")
	{
		local hControl, type, testHWND, vName, NeedsGLabel
		if(this.IsDestroyed)
			return
		 ;Validate name.
		if(!CGUI_Assert(Name, "GUI.AddControl() : No name specified. Please supply a proper control name.", -2))
			return
		;Make sure not to add a control with duplicate name.
		if(!CGUI_Assert(!IsObject(ControlList) || !IsObject(ControlList[Name]), "GUI.AddControl(): The control " Name " already exists. Please choose another name!", -2))
			return

		type := Control
		if (CGUI_Assert(CGUI.RegisteredControls.hasKey(Control), "The control " Control " was not found!", -2))
		{
			Control := {base: CGUI.RegisteredControls[Control]}
			Control.__Init()
			if (Control.__New.MinParams > 4)
				hControl := Control.__New(Name, Options, Text, this.GUINum, type)
			else
				hControl := Control.__New(Name, Options, Text, this.GUINum)
			if(!CGUI_Assert(hControl != 0, "Error creating " Type "Control", -2))
				return
		}

		;The __New constructor of a control may return a window handle when it needs to create the control manually.
		if(!hControl)
		{
			;Old: (IsLabel(this.__Class "_" Control.Name) ? "g" this.__Class "_" Control.Name : "")
			NeedsGLabel := Control._.HasKey("Events")

			;Find a free GUI variable. Might need to add an index because there might be controls with the same name that are nested in other controls
			GuiControlGet, testHWND, % this.GUINum ":hwnd", % vName := this.GUINum "_" Control.Name
			while(testHWND)
				GuiControlGet, testHWND, % this.GUINum ":hwnd", % vName := this.GUINum "_" Control.Name A_Index

			;If the control that is added here is a subcontrol of a control in a tab control, we need to set the corresponding tab first and unset it after the control has been added
			if(IsObject(ParentControl) && IsObject(this.Controls[ParentControl.hParentControl]) && this.Controls[ParentControl.hParentControl].Type = "Tab")
				Gui, % this.GUINum ":Tab", % ParentControl.TabNumber, % this.Controls[ParentControl.hParentControl]._.TabIndex

			Gui, % this.GUINum ":Add", % Control.Type, % Control.Options " hwndhControl " (NeedsGLabel ? "gCGUI_HandleEvent " : "") "v" vName, % Control.Content ;Create the control and get its window handle and setup a g-label

			if(IsObject(ParentControl) && IsObject(this.Controls[ParentControl.hParentControl]) && this.Controls[ParentControl.hParentControl].Type = "Tab")
				Gui, % this.GUINum ":Tab"
		}
		Control.Insert("hwnd", hControl) ;Window handle is used for all further operations on this control
		;Call PostCreate to allow the control to do things with itself after it was created. CControl.PostCreate needs to be called anyway, so all controls that handle PostCreate need to add this.base.PostCreate().
		Control.PostCreate()
		Control.Remove("Content")
		if(ControlList)
			ControlList[Control.Name] := Control
		this.Controls[hControl] := Control ;Add to list of controls

		;This will make sure that the window updates its size each time a new control is added until it is shown for the first time
		if(this.HasKey("_Initialized") && !this.Visible)
			Gui, % this.GUINum ":Show", % "Hide Autosize" (this._Initialized ? "" : " Center") ;If _Initialized is true the position was changed manually and mustn't be updated
		return Control
	}

	/*
	Function: Validate
	Validates the contents of controls containing text fields by calling <Control.Validate> for each fitting control.
	The control can then make adjustments to the passed value and return an adjusted or same value which is then used as its text.
	*/
	Validate()
	{
		for hwnd, Control in this.Controls
			if(Control.IsValidatableControlType())
				Control.Validate()
	}
	/*
	Function: ControlFromHWND
	Returns the object that belongs to a control with a specific window handle.
	Parameters:
		HWND - The window handle.
	*/
	ControlFromHWND(hwnd)
	{
		for GUINum, GUI in this.GUIList
			if(GUI.Controls.HasKey(hwnd))
				return GUI.Controls[hwnd]
	}

	/*
	Function: GUIFromHWND
	Returns the GUI object with a specific hwnd
	*/
	GUIFromHWND(hwnd)
	{
		for GUINum, GUI in this.GUIList
			if(GUI.hwnd = hwnd)
				return GUI
	}
	/*
	Function: ControlFromGUINumAndName
	Returns the object that belongs to a window with a specific gui number and a control with a specific name.
	Parameters:
		GUINum - The GUI number
	*/
	ControlFromGUINumAndName(GUINum, Name)
	{
		return this.GUIList[GUINum][Name]
	}

	/*
	Function: RegisterControl
	Registers a new control for use with <AddControl>.
	This is typically called from static variable initializations to make the control available to the user on startup.
	Parameters:
		name - the name the user can use to create a control, such as "Text"
		class - the class object implementing the control, such as CTextControl.
	*/
	RegisterControl(name, class)
	{
		this.RegisteredControls[name] := class
	}

	/*
	Property: RegisteredControls
	This static object contains a mapping of allowed control names and the responsible classes.
	It is used internally to register new controls for use with <AddControl>.

	Property: GUIList
	This static array contains a list of all GUIs created with this library.
	It is maintained automatically and should not need to be used directly.

	Property: IsDestroyed
	True if the window has been destroyed and this object is not usable anymore.

	Property: X
	x-Position of the window (including its border) in screen coordinates.

	Property: Y
	y-Position of the window (including its border) in screen coordinates.

	Property: Width
	Width of the client area of the window.

	Property: Height
	Height of the client area of the window.

	Property: WindowWidth
	Width of the window.

	Property: WindowHeight
	Height of the window.

	Property: Position
	An object containing the X and Y properties. They can not be set separately through this object, only both at once.

	Property: Size
	An object containing the Width and Height values. They can not be set separately through this object, only both at once.

	Property: WindowSize
	An object containing the WindowWidth and WindowHeight values. They can not be set separately through this object, only both at once.

	Property: Title
	The window title.

	Property: Style
	The window style.

	Property: ExStyle
	The window extended style.

	Property: Delimiter
	The delimiter used (mostly internally) for multiple items in a control. The default value is "|", but you can change it to something like "`n" or "`t" if you need to use "|" in the control text.

	Property: Transcolor
	A color that will be made invisible/see-through on the window. Values: RGB|ColorName|Off

	Property: Transparent
	The window style.

	Property: MinMax
	The window state: -1: minimized / 1: maximized / 0: neither. Can not be set this way.

	Property: ActiveControl
	The control object that is focused. Can also be set.

	Property: Enabled
	If false, the user can not interact with this window. Used for creating modal windows.

	Property: Visible
	Sets wether the window is visible or hidden.

	Property: AlwaysOnTop
	If true, the window will be in front of other windows.

	Property: Border
	Provides a thin border around the window.

	Property: Caption
	Set to false to remove the title bar.

	Property: MinimizeBox
	Determines if the window has a minimize button in the title bar.

	Property: MaximizeBox
	Determines if the window has a maximize button in the title bar.

	Property: Resize
	Determines if the window can be resized by the user.

	Property: SysMenu
	If true, the window will show a it's program icon in the title bar and show its system menu there.

	Property: Instances
	A list of all instances of the current window class. If you inherit from CGUI you can use this to find all windows of this type.

	Property: Menu
	If this variable contains an instance of <CMenu> and there is no ContextMenu() event handler for this window, this menu will be shown when the user right clicks on an empty window area.

	Property: MinSize
	Minimum window size when Resize is enabled.

	Property: MaxSize
	Maximum window size when Resize is enabled.

	Property: Theme

	Property: Toolwindow
	Provides a thin title bar.

	Property: Owner
	Assigning a hwnd to this property makes this window owned by another so it will act like a tool window of said window. Supports any window, not just windows from this process.

	Property: OwnerAutoClose
	By enabling this, an owned window (which has its Owner property set to the window handle of its parent window) will automatically close itself when its parent window closes.
	The window can use its PreClose() event to decide if it should really be closed, but the owner status will be removed anyway.
	To archive this behaviour a shell message hook is used. If there is already such a hook present in the script, this library will intercept it and forward any messages to the original callback function.

	Property: OwnDialogs
	Determines if the dialogs that this window shows will be owned by it.

	Property: Region

	Property: WindowColor

	Property: ControlColor

	Property: DestroyOnClose
	If set, the window will be destroyed when it gets closed.

	Property: CloseOnEscape
	If set, the window will close itself when escape is pressed.

	Property: ValidateOnFocusLeave
	If set, <CGUI.Validate> is called each time a text-containing variable loses focus.
	*/
	__Get(Name)
	{
		if Name not in base,_,GUINum
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "IsDestroyed" && this.GUINum) ;Extra check in __Get for this property because it might be destroyed through an old-style Gui, Destroy command
			{
				GUI, % this.GUINum ":+LastFoundExist"
				Value := WinExist() = 0
			}
			else if(Name != "IsDestroyed" && !this.IsDestroyed)
			{
				if Name in width,height
				{
					VarSetCapacity(rc, 16)
					DllCall("GetClientRect", "PTR", this.hwnd, "PTR", &rc, "UINT")
					Value := NumGet(rc, {x : 0, y : 4, width : 8, height : 12}[Name], "int")
				}
				else if Name in X,Y
				{
					WinGetPos, X, Y, , , % "ahk_id " this.hwnd
					return Name = "X" ? X : Y
				}
				else if(Name = "Position")
				{
					WinGetPos, X, Y, , , % "ahk_id " this.hwnd
					Value := {x : X, y : Y}
				}
				else if Name in WindowWidth,WindowHeight
				{
					WinGetPos, , , Width, Height, % "ahk_id " this.hwnd
					return Name = "WindowWidth" ? Width : Height
				}
				else if(Name = "Size")
				{
					VarSetCapacity(rc, 16)
					DllCall("GetClientRect", "PTR", this.hwnd, "PTRP", rc, "UINT")
					Value := {width : NumGet(rc, 8, "int"), height : NumGet(rc, 12, "int")}
				}
				else if(Name = "WindowSize")
				{
					WinGetPos, , , Width, Height, % "ahk_id " this.hwnd
					return {Width : Width, Height : Height}
				}
				else if(Name = "Title")
					WinGetTitle, Value, % "ahk_id " this.hwnd
				else if Name in Style,ExStyle,TransColor,Transparent,MinMax
					WinGet, Value, %Name%, % "ahk_id " this.hwnd
				else if(Name = "ActiveControl") ;Returns the control object that has keyboard focus
				{
					ControlGetFocus, Value, % "ahk_id " this.hwnd
					ControlGet, Value, Hwnd,, %Value%, % "ahk_id " this.hwnd
					if(this.Controls.HasKey(Value))
						Value := this.Controls[Value]
				}
				else if(Name="Enabled")
					Value := !(this.Style & 0x8000000) ;WS_DISABLED
				else if(Name = "Visible")
					Value :=  this.Style & 0x10000000
				else if(Name = "AlwaysOnTop")
					Value := this.ExStyle & 0x8
				else if(Name = "Border")
					Value := this.Style & 0x800000
				else if(Name = "Caption")
					Value := this.Style & 0xC00000
				else if(Name = "MaximizeBox")
					Value := this.Style & 0x10000
				else if(Name = "MinimizeBox")
					Value := this.Style & 0x10000
				else if(Name = "Resize")
					Value := this.Style & 0x40000
				else if(Name = "SysMenu")
					Value := this.Style & 0x80000
			}
			if(Value = "" && Name = "Instances") ;Returns a list of instances of this window class
			{
				Value := []
				for GuiNum,GUI in CGUI.GUIList
					if(GUI.__Class = this.__Class)
						Value.Insert(GUI)
			}
			else if(Value = "" && CGUI_IndexOf(["Delimiter", "MinSize", "MaxSize", "Theme", "ToolWindow", "Owner", "OwnDialogs", "Region", "WindowColor", "ControlColor", "ValidateOnFocusLeave"], Name))
				Value := this._[Name]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		DetectHidden := A_DetectHiddenWindows
		DetectHiddenWindows, On
		Handled := true
		if(!this.IsDestroyed)
		{
			;Fix completely weird __Set behavior. If one tries to assign a value to a sub item, it doesn't call __Get for each sub item but __Set with the subitems as parameters.
			Value := Params.Remove()
			if(Params.MaxIndex())
			{
				Params.Insert(1, Name)
				Name := Params.Remove()
				return (this[Params*])[Name] := Value
			}
			if Name in AlwaysOnTop,Border,Caption,LastFound,LastFoundExist,MaximizeBox,MaximizeBox,MinimizeBox,Resize,SysMenu
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
			else if Name in OwnDialogs,Theme,ToolWindow
			{
				Gui, % this.GUINum ":" (Value = 1 ? "+" : "-") Name
				this._[Name] := Value = 1
			}
			else if Name in MinSize,MaxSize
			{
				Gui, % this.GUINum ":+" Name Value
				if(!IsObject(this._[Name]))
					this._[Name] := {}
				Loop, Parse, Value, x
				{
					if(!A_LoopField)
						this._[Name][A_Index = 1 ? "width" : "height"] := A_Index = 1 ? this.width : this.height
					else
						this._[Name][A_Index = 1 ? "width" : "height"] := A_LoopField
				}
			}
			else if(Name = "Delimiter")
			{
				Gui, % this.GUINum ":+Delimiter" Value
				this._.Delimiter := Value
			}
			else if(Name = "Owner")
			{
				if(Value && WinExist("ahk_id " Value))
				{
					DllCall("SetWindowLong" (A_PtrSize = 4 ? "" : "Ptr"), "Ptr", this.hwnd, "int", -8, "PTR", Value) ;This line actually sets the owner behavior
					this._.hOwner := Value
				}
				else
				{
					DllCall("SetWindowLong" (A_PtrSize = 4 ? "" : "Ptr"), "Ptr", this.hwnd, "int", -8, "PTR", 0) ;Remove tool window behavior
					this._.Remove("hOwner")
				}
			}
			else if(Name = "OwnerAutoClose" && this._.HasKey("hOwner"))
			{
				if(Value = 1)
				{
					if(!CGUI._.ShelllHook)
					{
						DllCall( "RegisterShellHookWindow", "Ptr", A_ScriptHWND)
						CGUI._.ShellHookMsg := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
						CGUI._.ShellHook := OnMessage(CGUI._.ShellHookMsg, "CGUI_ShellMessage")
						if(CGUI._.ShellHook = "CGUI_ShellMessage")
							CGUI._.ShellHook := 1
					}
					this._.OwnerAutoClose := 1
				}
				else
				{
					if(this._.OwnerAutoClose)
					{
						for GUINum, GUI in CGUI.GUIList
							if(GUI.hwnd != this.hwnd && GUI._.OwnerAutoClose)
								found := true
						if(!found)
						{
							OnMessage(CGUI._.ShellHookMsg, (CGUI._.ShellHook && CGUI._.ShellHook != 1) ? CGUI._.ShellHook : "")
							if(!CGUI._.ShellHook)
								DllCall("DeRegisterShellHookWindow", "Ptr", A_ScriptHWND)
							CGUI._.Remove("ShellHook")
						}
					}
					this._.OwnerAutoClose := 0
				}
			}
			else if Name in Style,ExStyle,Transparent,TransColor
				WinSet, %Name%, %Value%, % "ahk_id " this.hwnd
			else if(Name = "Region")
			{
				WinSet, Region, %Value%, % "ahk_id " this.hwnd
				this._.Region := Value
			}
			else if Name in x,y,WindowWidth,WindowHeight
			{
				WinMove,% "ahk_id " this.hwnd,,% Name = "x" ? Value : "", % Name = "y" ? Value : "", % Name = "WindowWidth" ? Value : "", % Name = "WindowHeight" ? Value : ""
				if(Name = "WindowWidth" || Name = "WindowHeight") ;Prevent recalculating size after it has been set manually
					this.Remove("_Initialized")
				else if(this.HasKey("_Initialized")) ;Mark that position was changed manually during recalculation phase
					this._Initialized := true
			}
			else if(Name = "Position")
			{
				WinMove,% "ahk_id " this.hwnd,,% Value.x, % Value.y
				if(this.HasKey("_Initialized")) ;Mark that position was changed manually during recalculation phase
					this._Initialized := true
			}
			else if(Name = "Size")
			{
				Size := this.Size
				WinSize := this.WindowSize
				WinMove, % "ahk_id " this.hwnd,,,, % Value.width + WinSize.Width - Size.Width, % Value.height + WinSize.Height - Size.Height
				this.Remove("_Initialized")
			}
			else if(Name = "WindowSize")
			{
				WinMove, % "ahk_id " this.hwnd,,,, % Value.width, % Value.height
				this.Remove("_Initialized")
			}
			else if(Name = "Title")
				WinSetTitle, % "ahk_id " this.hwnd,,%Value%
			else if(Name = "WindowColor")
				Gui, % this.GUINum ":Color", %Value%
			else if(Name = "ControlColor")
				Gui, % this.GUINum ":Color",, %Value%
			else if(Name = "ActiveControl")
			{
				if(!IsObject(Value) && WinExist("ahk_id " Value))
					Value := this.Controls[Value]
				else if(!IsObject(Value))
					Value := this[Value]
				if(IsObject(Value))
					ControlFocus,,% "ahk_id " Value.hwnd
			}
			else if(Name = "Enabled")
				this.Style := (Value ? "-" : "+") 0x8000000 ;WS_DISABLED
			else if(Name = "Visible")
			{
				this.Style := (Value ? "+" : "-") 0x10000000 ;WS_VISIBLE
				if(Value) ;Prevent recalculating size after it has been shown the first time
					this.Remove("_Initialized")
			}
			else if(Name = "ValidateOnFocusLeave")
				this._[Name] := Value = 1
			else if(Name = "_Constructor") ;_Constructor is just a temporary variable name for automatically calling the CGUI constructor
				Handled := true
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else
				Handled := false
		}
		else
			Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
	}
	/*
	Event: Introduction
	Events are used by implementing the specific event function in the class that extends CGUI. No g-labels are required nor anything else.
	On a related note, you can listen to window messages by calling <CGUI.OnMessage> on a window instance.

	Event: ContextMenu()
	Invoked when the user right clicks on a an empty area in this window. It is possible to show a static context menu without handling this event by assigning the Menu property of this window to an instance of <CMenu>.

	Event: DropFiles()
	Invoked when the user dropped files on the window.

	Event: Escape()
	Invoked when the user pressed Escape. Having the window close itself when escape gets pressed can be easily done by setting CloseOnEscape := 1 and does not need this event.

	Event: PreClose()
	Invoked when the window is about to close. This function can stop the closing of the window by returning true. Otherwise the window will be destroyed or hidden, depending on the setting of DestroyOnClose.

	Event: PostDestroy()
	Invoked when the window was destroyed. It's not possible to interact with the window or its controls anymore so this event should only be used to free possible resources.

	Event: Size(Event)
	Invoked when the window gets resized.
	0: The window has been restored, or resized normally such as by dragging its edges.
	1: The window has been minimized.
	2: The window has been maximized.
	*/

	/*
	Main event rerouting function. It identifies the associated window/control
	and calls the related event function if it is defined. It also handles some things on its own, such as window closing.
	*/
	HandleEvent()
	{
		WasCritical := A_IsCritical
		Critical ;Critical needs to be used to catch all events, especially from ListViews
		if(this.IsDestroyed)
			return
		this.PushEvent(A_ThisLabel, A_Gui, A_GuiControl, ErrorLevel, A_EventInfo, A_GuiEvent)
		if(!WasCritical)
			Critical, Off ;And it also needs to be disabled again, otherwise there can be some handlers that won't run until the window is reactivated (context menu g-label notification from ListView for example)
	}

	;Adds an event to the event queue
	PushEvent(Label, GUINum, vControl = "", lErrorLevel = "", lEventInfo = "", lGUIEvent = "")
	{
		;Unfortunately listview selection change events are fired to rapidly (one for each list entry), so some optimizations are needed
		if(lGUIEvent = "I" && lErrorlevel = "S") ;Check if there is already a listview select event for this control in the queue.
			for index, event in CGUI.EventQueue
				if(event.GuiControl = vControl && event.GuiEvent = "I" && Event.ErrorLevel = "S")
					return
		CGUI.EventQueue.Insert({"Label" : Label, "Errorlevel" : lErrorlevel, "GUI" : GUINum, "EventInfo" : lEventInfo, "GUIEvent" : lGUIEvent, "GUIControl" : vControl})
		SetTimer, CGUI_HandleEventTimer, -1
	}
	/*
	Called by a timer that processes the event queue of all g-label notifications
	and reroutes specific events to gui event functions and control classes
	to allow them to split the g-label notification up into single events.
	*/
	RerouteEvent(Event)
	{
		GUI := CGUI.GUIList[Event.GUI]
		if(IsObject(GUI))
		{
			if(Event.Label != "CGUI_HandleEvent" && InStr(Event.Label, "CGUI_")) ;Handle default gui events (Close, Escape, DropFiles, ContextMenu)
			{
				func := SubStr(Event.Label, InStr(Event.Label, "_") + 1)
				;Call PreClose before closing a window so it can be skipped
				If((func = "Escape" && GUI.CloseOnEscape) || func = "Close")
					func := "PreClose"
				if(func != "ContextMenu")
				{
					if(IsFunc(GUI[func]))
					{
						if(Event.Label = "CGUI_Size")
							result := (GUI)[func](Event.EventInfo)
						else
							result := (GUI)[func]() ;PreClose can return false to prevent closing the window
					}
				}
				else
				{
					MouseGetPos, , , , hControl, 2
					if(hControl)
					{
						Handled := Gui.Controls[hControl].CallEvent(func).Handled
						if(!Handled && CGUI_TypeOf(Gui.Controls[hControl].Menu) = "CMenu")
							Gui.ShowMenu(Gui.Controls[hControl].Menu)
					}
					else if(IsFunc(GUI[func]))
						result := (GUI)[func]()
					else if(CGUI_TypeOf(Gui.Menu) = "CMenu")
						Gui.ShowMenu(Gui.Menu)
				}
				if(!this.IsDestroyed)
				{
					;Call event handler
					if(func = "PreClose")
						this.OnClose.(this)
					if(func = "PreClose" && !result && !GUI.DestroyOnClose) ;Hide the GUI if closing was not aborted and the GUI should not destroy itself on closing
						GUI.Hide()
					else if(func = "PreClose" && !result) ;Otherwise if not aborted destroy the GUI
						GUI.Destroy()
				}
			}
			else ;Forward events to specific controls so they can split the specific g-label cases
			{
				GuiControlGet, ControlHWND, % GUI.GUINum ":hwnd", % Event.GuiControl
				Gui.Controls[ControlHWND].HandleEvent(Event)
			}
		}
	}

	/*
	This function gets called when a window receives internal messages that are handled through the library.
	It is currently handles WM_COMMAND and WM_Notify to check for focus change events.
	*/
	/*
	;This function needed to be disabled because AHK can't keep up with handling WM_NOTIFY messages properly and will fall into some kind of recursion internally.
	;See http://www.autohotkey.com/forum/viewtopic.php?p=481765
	HandleInternalMessage(Msg, wParam, lParam)
	{
		static WM_NOTIFY := 0x004E, WM_COMMAND := 0x111, NM_KILLFOCUS := 0xFFFFFFF8, NM_SETFOCUS := 0xFFFFFFF9
		;~ Critical 1000
		;~ static WM_SETCURSOR := 0x20, WM_MOUSEMOVE := 0x200, h_cursor_hand
		if(Msg = WM_NOTIFY)
		{
			;lParam is a NMHDR structure or one that begins with it: http://msdn.microsoft.com/en-us/library/bb775514(VS.85).aspx
			hwndFrom := NumGet(lParam+0, 0, "UPTR")
			Control := this.Controls[hwndFrom]

			;Forward the function to the control object. Some controls may want to process it and call events.
			if(IsFunc(Control.OnWM_NOTIFY))
				result := Control.OnWM_NOTIFY(wParam, lParam)
			if(!result >= 0)
				return result
			Code := NumGet(lParam+0, 2*A_PtrSize, "INT")
			if(Code = NM_KILLFOCUS)
				Code := "KillFocus"
			else if(Code = NM_SETFOCUS)
				Code := "SetFocus"
		}
		else if(Msg = WM_COMMAND)
		{
			if(lParam = 0) ;Only handle messages from controls
				return

			;WM_COMMAND passes the window handle as lParam directly.
			hwndFrom := lParam
			Control := this.Controls[hwndFrom]

			;Forward the function to the control object. Some controls may want to process it and call events.
			if(IsFunc(Control.OnWM_COMMAND))
				Control.OnWM_COMMAND(wParam, lParam)

			Code := CGUI_HighWord(wParam)
			Code := Control._.Messages[Code] ;Translate to a common message name shared among all controls that support it to map different code numbers with same meaning from different controls to the same name
			if(!Code)
				return
		}
		if(Code = "SetFocus" || Code = "KillFocus")
			this.PushEvent("CGUI_FocusChange", this.GUINum)
		if(Code = "SetFocus")
			Control.CallEvent("FocusReceived")
		else if(Code = "KillFocus")
		{
			Control.CallEvent("FocusLost")
			if(this.ValidateOnFocusLeave && Control.IsValidatableControlType())
				Control.Validate()
		}
		Critical, Off
	}
	*/
	/*
	if(msg = WM_SETCURSOR || msg = WM_MOUSEMOVE) ;Text control Link support, thanks Shimanov!
	{
		if(msg = WM_SETCURSOR)
		{
			If(this._.Hovering)
				Return true
		}
		else if(msg = WM_MOUSEMOVE)
		{
			; MouseGetPos,,,,ControlHWND, 2
			GuiControlGet, ControlHWND, % this.GUINum ":hwnd", % A_GuiControl
			outputdebug hwnd %hwnd%
			if(this.Controls.HasKey(ControlHWND) && this.Controls[ControlHWND].Link)
			{
				if(!this._.Hovering)
				{
					this.Controls[ControlHWND].Font.Options := "cBlue underline"
					this._.LastHoveredControl := this.Controls[ControlHWND].hwnd
					h_cursor_hand := DllCall("LoadCursor", "Ptr", 0, "uint", 32649, "Ptr")
					this._.Hovering := true
				}
				this._.h_old_cursor := DllCall("SetCursor", "Ptr", h_cursor_hand, "Ptr")
			}
			; Mouse cursor doesn't hover URL text control
			else
			{
				if(this._.Hovering)
				{
					if(this.Controls.HasKey(this._.LastHoveredControl) && this.Controls[this._.LastHoveredControl].Link)
					{
						this.Controls[this._.LastHoveredControl].Font.Options := "norm cBlue"
						DllCall("SetCursor", "Ptr", GUI._.h_old_cursor)
						this._.Hovering := false
					}
				}
			}
		}
	}
	*/
}


;Event handlers for gui and control events:
CGUI_Size:
CGUI_ContextMenu:
CGUI_DropFiles:
CGUI_Close:
CGUI_Escape:
CGUI_HandleEvent:
CGUI.HandleEvent()
return

;Events are processed through an event queue and a timer so that no window messages will be missed.
CGUI_HandleEventTimer:
while(CGUI.EventQueue.MaxIndex()) {
	SetTimer, CGUI_HandleEventTimer, Off
	CGUI.GUIList[CGUI.EventQueue[1].GUI].RerouteEvent(CGUI.EventQueue.Remove(1))
	SetTimer, CGUI_HandleEventTimer, -1
}
return
/*
Function: CGUI_ShellMessage
This internal function is used to monitor closing of the parent windows of owned GUIs. It must not need to be called directly by a user of this library.
It is still possible to use a shell message hook as usual in your script as long as it gets initialized before setting GUI.OwnerAutoClose := 1.
This library will intercept all ShellMessage calls and forward it to the previously used ShellMessage callback function.
This callback function will only be used when there are owned windows which have OwnerAutoClose activated. In all other cases it won't be used and can safely be ignored.
*/
CGUI_ShellMessage(wParam, lParam, msg, hwnd) {
   if(wParam = 2) ;Window Destroyed
   {
	  For Index, Entry In CGUI.GUIList
	  {
		 if(Entry._.hOwner = lParam && Entry._.OwnerAutoClose)
		 {
			PostMessage, 0x112, 0xF060,,, % "ahk_id " Entry.hwnd  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE --> this should trigger AHK CGUI_Close label so the GUI class may process the close request
			Entry._.Remove("hOwner")
			Entry._.Remove("OwnerAutoClose")
			for GUINum, GUI in CGUI.GUIList
				if(GUI._.OwnerAutoClose)
					found := true
			if(!found) ;No more tool windows, remove shell hook
			{
				OnMessage(CGUI._.ShellHookMsg, (CGUI._.ShellHook && CGUI._.ShellHook != 1) ? CGUI._.ShellHook : "")
				if(!CGUI._.ShellHook)
					DllCall("DeRegisterShellHookWindow", "Ptr", A_ScriptHWND)
				CGUI._.Remove("ShellHook")
			}
			break
		 }
	  }
   }
   if(IsFunc(CGUI._.ShellHook))
   {
	  ShellHook := CGUI._.ShellHook
	  %ShellHook%(wParam, lParam, msg, hwnd) ;This is allowed even if the function uses less parameters
   }
}

;Global window message handler for CGUI library that reroutes all registered window messages to the window instances.
CGUI_WindowMessageHandler(wParam, lParam, msg, hwnd) {
	GUI := CGUI.GUIFromHWND(hwnd)
	;If no window found, it might be the handle of a control:
	if(!GUI)
		GUI := CGUI.GUIList[CGUI.ControlFromHWND(hwnd).GUINum]
	if(GUI)
	{
		;Internal message handlers are processed first.
		Listeners := CGUI.WindowMessageHandler.WindowMessageListeners[Msg].Listeners
		if(Listeners.HasKey(0))
			result := (GUI.base.base)[Listeners[0]](Msg, wParam, lParam, hwnd)
		result := GUI[Listeners[GUI.hwnd]](Msg, wParam, lParam, hwnd)
		return result
	}
}
/*
Class: CFont
A class managing the font of a gui or a control. As of now, this class can not be used to retrieve the current value of the font before they have been set to a custom value by using the properties of this class.
*/
Class CFont {
	__New(GUINum)
	{
		this.Insert("_", {})
		this._.GUINum := GUINum
		this._.hwnd := hwnd
	}
	/*
	Property: Options
	An options string used for describing the font. Syntax is identical to GUI, Font command in AHK.

	Property: Font
	The name of the font.
	*/
	__Set(Name, Value)
	{
		if(Name = "Options")
		{
			if(this._.hwnd) ;belonging to a control
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI.Controls[this._.hwnd]
				Gui, % this._.GUINum ":Font", %Value%
				GuiControl, % this._.GUINum ":Font", % Control.ClassNN
				Gui, % this._.GUINum ":Font", % GUI.Font.Options ;Restore current font
			}
			else ;belonging to a window
				Gui, % this._.GUINum ":Font", %Value%
			this._[Name] := Value
			return Value
		}
		else if(Name = "Size" && Value > 0)
		{
			return this.Options := "s" Value
		}
		else if(Name = "Font")
		{
			if(this._.hwnd) ;belonging to a control
			{
				GUI := CGUI.GUIList[this._.GUINum]
				Control := GUI.Controls[this._.hwnd]
				Gui, % this._.GUINum ":Font",, %Value%
				GuiControl, % this.GUINum ":Font", % Control.ClassNN
				Gui, % this._.GUINum ":Font",, % GUI.Font.Font ;Restore current font
			}
			else ;belonging to a window
				Gui, % this._.GUINum ":Font",, %Value%
			this._[Name] := Value
			return Value
		}
	}
	__Get(Name)
	{
		if(Name != "_" && this._.HasKey(Name))
			return this._[Name]
	}
}

;Simple assert function
CGUI_Assert(Condition, Message, CallStackLevel = -1){
	if(!Condition)
	{
		E := Exception("", CallStackLevel)
		MsgBox % "Assert failed in " E.File ", line " E.Line ": " Message
	}
	return Condition
}

CGUI_HighWord(Value){
	return (Value & 0xFFFF0000) >> 16
}

CGUI_LowWord(Value){
	return Value & 0xFFFF
}

CGUI_IndexOf(Array, Value){
	Loop % Array.MaxIndex() ;Use a simple loop so that only numeric keys are used (and there is no chance that a key with "" or 0 is returned
		if(Array[A_Index]=Value)
			return A_Index
}

CGUI_TypeOf(Object){
	return Object.__Class
}

CGUI_ScreenToClient(hwnd, ByRef x, ByRef y){
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0)
    NumPut(y, pt, 4)
    DllCall("ScreenToClient", "PTR", hwnd, "PTR", &pt)
    x := NumGet(pt, 0, "int")
    y := NumGet(pt, 4, "int")
}

CGUI_ClientToScreen(hwnd, ByRef x, ByRef y){
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0)
    NumPut(y, pt, 4)
    DllCall("ClientToScreen", "PTR", hwnd, "PTR", &pt)
    x := NumGet(pt, 0, "int")
    y := NumGet(pt, 4, "int")
}

CGUI_WinToClient(hwnd, ByRef x, ByRef y){
    WinGetPos, wx, wy,,, ahk_id %hwnd%
    VarSetCapacity(pt, 8)
    NumPut(x + wx, pt, 0)
    NumPut(y + wy, pt, 4)
    DllCall("ScreenToClient", "PTR", hwnd, "PTR", &pt)
    x := NumGet(pt, 0, "int")
    y := NumGet(pt, 4, "int")
}

CGUI_ClientToWin(hwnd, ByRef x, ByRef y){
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0)
    NumPut(y, pt, 4)
    DllCall("ClientToScreen", "PTR", hwnd, "PTR", &pt)
    WinGetPos, wx, wy,,, ahk_id %hwnd%
    x := NumGet(pt, 0, "int") - wx
    y := NumGet(pt, 4, "int") - wy
}

#include %A_LineFile%\..\gdip.ahk
#include %A_LineFile%\..\EventHandler.ahk
#include %A_LineFile%\..\CControl.ahk
#include %A_LineFile%\..\CFileDialog.ahk
#include %A_LineFile%\..\CFolderDialog.ahk
#include %A_LineFile%\..\CEnumerator.ahk
#include %A_LineFile%\..\CMenu.ahk
