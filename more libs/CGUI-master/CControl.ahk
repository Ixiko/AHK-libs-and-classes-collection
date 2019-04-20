#include EventHandler.ahk
#include Delegate.ahk
/*
Class: CControl
Basic control class from which all controls extend.
*/
Class CControl ;Never created directly
{
	OnValidate := new EventHandler()
	ContextMenu := new EventHandler()
	
	__New(Name, Options, Text, GUINum) ;Basic constructor for all controls. The control is created in CGUI.AddControl()
	{
		this.Insert("Name", Name)
		this.Insert("Options", Options)
		this.Insert("Content", Text)
		this.Insert("GUINum", GUINum) ;Store link to gui for GuiControl purposes (and possibly others later
		this.Insert("_", {}) ;Create proxy object to enable __Get and __Set calls for existing keys (like ClassNN which stores a cached value in the proxy)
		this.Insert("Font", new CFont(GUINum))
		this._.Insert("RegisteredEvents", {})
	}
	PostCreate()
	{
		this.Font._.hwnd := this.hwnd
	}

	/*
	Function: Autosize
	Resizes the control to fit its contents
	*/
	AutoSize() ; www.autohotkey.com/forum/viewtopic.php?p=465438#465438 By SKAN and SEAN, merged by Fragman
	{
		SendMessage 0x31, 0, 0, , % "ahk_id " this.hwnd ; WM_GETFONT
		if(ErrorLevel = "FAIL")
			return
		hFont := Errorlevel

		hDC := DllCall("GetDC", "PTR", 0)
		if(hFont && hDC)
		{
			;Store old font
			hFold := DllCall("SelectObject", "PTR", hDC, "PTR", hFont)

			DllCall("GetTextExtentPoint32", "PTR", hDC, "Str", this.Text, "Int", StrLen(this.Text), "PTR", (size := new _Struct("LONG width, LONG height"))[""])

			;Restore old font
			DllCall("SelectObject", "PTR", hDC, "PTR", hFold)
			DllCall("ReleaseDC", "PTR", 0, "PTR", hDC)
		}
		else
			return
		this.Size := {Width : size.width, Height : size.height}
	}

	/*
	Function: Show
	Shows the control if it was previously hidden.
	*/
	Show()
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		GuiControl, % this.GUINum ":Show",% this.hwnd
	}
	
	/*
	Function: Hide
	Hides the control if it was previously visible.
	*/
	Hide()
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		GuiControl, % this.GUINum ":Hide",% this.hwnd
	}
	
	/*
	Function: Enable
	Enables the control if it was previously diisabled.
	*/
	Enable()
	{
		GuiControl, % this.GUINum ":Enable",% this.hwnd
	}
	
	/*
	Function: Disable
	Disables the control if it was previously enabled.
	*/
	Disable()
	{
		GuiControl, % this.GUINum ":Disable",% this.hwnd
	}
	
	/*
	Function: Focus
	Sets the focus to this control.
	*/
	Focus()
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ControlFocus,,% "ahk_id " this.hwnd
	}
	/*
	Function: Redraw
	Redraws the control. This can sometimes fix drawing issues.
	*/
	Redraw()
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		GuiControl, % this.GUINum ":MoveDraw",% this.hwnd
	}
	;~ Font(Options, Font="")
	;~ {
		;~ if(CGUI.GUIList[this.GUINum].IsDestroyed)
			;~ return
		;~ Gui, % this.GUINum ":Font", %Options%, %Font%
		;~ GuiControl, % this.GUINum ":Font", % this.ClassNN
		;~ Gui, % this.GUINum ":Font", % CGUI.GUIList[this.GUINum].Font.Options, % CGUI.GUIList[this.GUINum].Font.Font ;Restore current font
	;~ }
	
	
	/*
	Validates the text value of this control by calling a <Control.OnValidate> event function which needs to return the validated (or same) value.
	This value is then used as text for the control if it differs.
	*/
	Validate()
	{
		output := this.CallEvent("OnValidate", this.Text)
		if(output.Handled && output.Result != this.Text)
			this.Text := output.result
	}
	/*
	Function: RegisterEvent
	
	Attention! This function is deprecated!	It is suggest to use event handlers instead.
	Simply use the following with one of the options in the brackets:
	control.EventName.Handler := ["HandlingFunction",Func("HandlingFunction"),new Delegate(object,"Member function").
	The function that handles the event will receive an additional first parameter which contains the control that sent the event.
	
	Assigns (or unassigns) a function to a specific event of this control so that the function will be called when the event occurs.
	This is normally not necessary because functions in the GUI class with the name ControlName_EventName()
	will be called automatically without needing to be registered. However this can be useful if you want to handle
	multiple events with a single function, e.g. for a group of radio controls. Right now only one registered function per event
	is supported, let me know if you need more.
	
	Parameters:
		Type - The event name for which the function should be registered. If a control normally calls "GUI.ControlName_TextChanged()", specify "TextChanged" here.
		FunctionName - The name of the function specified in the window class that is supposed to handle the event. Specify only the name of the function, skip the class.
	*/
	RegisterEvent(Type, FunctionName)
	{
		if(FunctionName)
		{
			;Make sure function name is valid (or tell the developer about it)
			if(CGUI_Assert(IsFunc(this[FunctionName]) || IsFunc( (CGUI.GUIList[this.GUINum])[FunctionName]), "Invalid function name passed to CControl.RegisterEvent()"), -2)
				this._.RegisteredEvents[Type] := FunctionName
		}
		else
			this._.RegisteredEvents.Remove(Type)
	}
	
	/*
	Calls an event with a specified name by looking up a possibly registered event handling function or calling the function with the default name.
	Returns an object with Handled and Result keys, where Handled indicates if the function was successfully called and Result is the return value of the function.
	*/
	CallEvent(Name, Params*)
	{
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		this[Name].(this, Params*)
		if(this._.RegisteredEvents.HasKey(Name))
		{
			if(IsFunc(this[this._.RegisteredEvents[Name]]))
				return {Handled : true, Result : this[this._.RegisteredEvents[Name]](CGUI.GUIList[this.GUINum], Params*)}
			else if(IsFunc( (CGUI.GUIList[this.GUINum])[this._.RegisteredEvents[Name]]))
				return {Handled : true, Result : (CGUI.GUIList[this.GUINum])[this._.RegisteredEvents[Name]](Params*)}
		}
		else if(IsFunc(this[Name]))
			return {Handled : true, Result : this[Name](CGUI.GUIList[this.GUINum], Params*)}
		else if(IsFunc((CGUI.GUIList[this.GUINum])[this.Name "_" Name]))
			return {Handled : true, Result : (CGUI.GUIList[this.GUINum])[this.Name "_" Name](Params*)}
		else
			return {Handled : false}
	}
	/*
	Changes the state of controls assigned to an item of another control, making them (in)visible or (de)activating them.
	The parameters are the previously selected item object (containing a controls array of controls assigned to it and the new selected item object.
	*/
	ProcessSubControlState(From, To)
	{
		if(From != To && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			if(From)
				for index, Control in From.Controls
				{
					if(Control._.UseEnabledState)
						Control.Disable()
					else
						Control.Hide()
				}
			if(To)
			{
				for index, Control in To.Controls
					if(Control._.UseEnabledState)
						Control.Enable()
					else
						Control.Show()
			}
		}
	}
	
	IsValidatableControlType()
	{
		return CGUI_IndexOf(["Edit", "ComboBox"], this.Type)
	}
	/*
	Property: x
	x-Position of the control.
	
	Property: y
	y-Position of the control.
	
	Property: width
	Width of the control.
	
	Property: height
	Height of the control.
	
	Property: Position
	An object containing the x and y values. They can not be set separately through this object, only both at once.
	
	Property: Size
	An object containing the width and height values. They can not be set separately through this object, only both at once.
	
	Property: Text
	The text of the control. Some controls don't support this property.
	
	Property: ClassNN
	The control class together with a number identify the control.
	
	Property: Enabled
	Determines wether this control can be interacted with.
	
	Property: Visible
	Determines wether this control is currently visible.
	
	Property: Style
	The style of the control.
	
	Property: ExStyle
	The extended style of the control.
	
	Property: Focused
	True if the control currently has the focus. It's also possible to focus it by setting this value to true.
	
	Property: Tooltip
	If a text is set for this value, this control will show a tooltip when the mouse hovers over it.
	Text and Picture controls require that you define a g-label for them to make this work.
	
	Property: Menu
	If this variable contains an instance of <CMenu> and there is no ContextMenu() event handler for this control, this menu will be shown when the user right clicks on this control or presses the AppsKey while this control has focus.
	
	Property: Left
	The control left-aligns its text. This is the default setting.
	
	Property: Center
	The control center-aligns its text.
	
	Property: Right
	The control right-aligns its text.
	
	Property: TabStop
	If set to false, this control will not receive the focus when pressing tab to cycle through all controls.
	
	Property: Wrap
	If enabled, the control will use word-wrapping for its text.
	
	Property: HScroll
	Provides a horizontal scroll bar for this control if appropriate.
	
	Property: VScroll
	Provides a vertical scroll bar for this control if appropriate.
	
	Property: BackgroundTrans
	Uses a transparent background, which allows any control that lies behind a Text, Picture, or GroupBox control to show through.
	
	Property: Background
	If disable, the control uses the standard background color rather than the one set by the CGUI.Color() function.
	
	Property: Border
	Provides a thin-line border around the control.
	
	Property: hParentControl
	If this control is a subcontrol of another control, this variable contains the window handle of the parent control.
	
	Property: DisableNotifications
	If true, this control will not call any of its notification functions. This is useful when the controls of a window are first created and change handlers should not be called.
	*/
	__Get(Name, Params*)
    {
        if(this.__GetEx(Result, Name, Params*) )
            return Result
    }
	
	__GetEx(ByRef Result, Name, Params*)
    {
		Handled := false
		if Name not in base,_,GUINum
			if(!CGUI.GUIList[this.GUINum].IsDestroyed)
			{
				DetectHidden := A_DetectHiddenWindows
				DetectHiddenWindows, On
				Handled := true
				if(Name = "Text")
					GuiControlGet, Result,% this.GuiNum ":", % this.hwnd
					;~ ControlGetText, Result,, % "ahk_id " this.hwnd
				else if(Name = "GUI")
					Result := CGUI.GUIList[this.GUINum]
				else if(Name = "x" || Name = "y"  || Name = "width" || Name = "height")
				{
					GuiControlGet, Result, % this.GUINum ":Pos", % this.hwnd
					Name := {x : "x", y : "y", width : "w", height : "h"}[Name]
					Result := Result%Name%
				}
				else if(Name = "Position")
				{
					GuiControlGet, Result, % this.GUINum ":Pos", % this.hwnd
					Result := {x : ResultX, y : ResultY}
				}
				else if(Name = "Size")
				{
					GuiControlGet, Result, % this.GUINum ":Pos", % this.hwnd
					Result := {width : ResultW, height : ResultH}
				}
				else if(Name = "ClassNN")
				{
					if(this._.ClassNN != "" && this.hwnd && WinExist("ahk_class " this._.ClassNN) = this.hwnd) ;Check for cached Result first
						return this._.ClassNN
					else
					{
						win := DllCall("GetParent", "PTR", this.hwnd, "PTR")
						WinGet ctrlList, ControlList, ahk_id %win%
						Loop Parse, ctrlList, `n
						{
							ControlGet hwnd, Hwnd, , %A_LoopField%, ahk_id %win%
							if(hwnd=this.hwnd)
							{
								Result := A_LoopField
								break
							}
						}
						this._.ClassNN := Result
					}
				}
				else if(Name = "Enabled")
					ControlGet, Result, Enabled,,,% "ahk_id " this.hwnd
				else if(Name = "Visible")
					ControlGet, Result, Visible,,,% "ahk_id " this.hwnd
				else if(Name = "Style")
					ControlGet, Result, Style,,,% "ahk_id " this.hwnd
				else if(Name = "ExStyle")
					ControlGet, Result, ExStyle,,,% "ahk_id " this.hwnd
				else if(Name = "Focused")
				{
					ControlGetFocus, Result, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
					ControlGet, Result, Hwnd,, %Result%, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
					Result := Result = this.hwnd
				}
				else if(key := {Left : "Left", Center : "Center", Right : "Right", TabStop : "TabStop", Wrap : "Wrap", HScroll : "HScroll", VScroll : "VScroll", BackgroundTrans : "BackgroundTrans", Background : "Background", Border : "Border"}[Name])
					GuiControl, % this.GUINum ":", (Result ? "+" : "-") key
				else if(Name = "Color")
					GuiControl, % this.GUINum ":", "+c" Result
				else if(this._.HasKey("ControlStyles") && Style := this._.ControlStyles[Name])
				{
					if(SubStr(Style, 1,1) = "-")
					{
						Negate := true
						Style := SubStr(Style, 2)
					}
					ControlGet, Result, Style,,,% "ahk_id " this.hwnd
					Result := Result & Style > 0
					if(Negate)
						Result := !Result
				}
				else if(this._.HasKey("ControlExStyles") && ExStyle := this._.ControlExStyles[Name])
				{
					if(SubStr(ExStyle, 1,1) = "-")
					{
						Negate := true
						ExStyle := SubStr(ExStyle, 2)
					}
					ControlGet, Result, ExStyle,,,% "ahk_id " this.hwnd
					Result := Result & ExStyle > 0
					if(Negate)
						Result := !Result
				}
				else if(Name = "Tooltip")
					Result := this._.Tooltip
				else
					Handled := false
				if(!DetectHidden)
					DetectHiddenWindows, Off
			}
		return Handled
    }
	
    __Set(Name, Params*)
    {
		if(Name != "_" && !CGUI.GUIList[this.GUINum].IsDestroyed)
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
			if(Name = "Text")
				GuiControl, % this.GUINum ":",% this.hwnd, %Value% ;Use GuiControl because of line endings
			else if(Name = "x" || Name = "y" || Name = "width" || Name = "height")
			{
				Name := {x : "x", y : "y", width : "w", height : "h"}[Name]
				GuiControl, % this.GUINum ":Move", % this.hwnd, % Name Value
			}
			else if(Name = "Position")
				GuiControl, % this.GUINum ":Move", % this.hwnd, % "x" Value.x " y" Value.y
			else if(Name = "Size")
				GuiControl, % this.GUINum ":Move", % this.hwnd, % "w" Value.width " h" Value.height
			else if(Name = "Enabled" && Value)
				this.Enable()
			else if(Name = "Enabled" && !Value)
				this.Disable()
			else if(Name = "Visible" && Value)
				this.Show()
			else if(Name = "Visible" && !Value)
				this.Hide()
			else if(Name = "Style")
				Control, Style, %Value%,,% "ahk_id " this.hwnd
			else if(Name = "ExStyle")
				Control, ExStyle, %Value%,,% "ahk_id " this.hwnd
			else if(Name = "DisableNotifications")
				GuiControl, % this.GUINum (Value ? ":-g" : ":+gCGUI_HandleEvent" ), % this.hwnd
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else if(this._.HasKey("ControlMessageStyles") && IsObject(Style := this._.ControlMessageStyles[Name]))
			{
				State := Value ? "On" : "Off"
				SendMessage, % Style.Message, % Style[State].W, % Style[State].L, , % "ahk_id" this.hwnd
			}
			else if(this._.HasKey("ControlStyles") && Style := this._.ControlStyles[Name]) ;Generic control styles which are only of boolean type can be handled simply by a list of name<->value assignments. Prepending "-" to a value in such a list inverts the behaviour here.
			{
				if(SubStr(Style, 1,1) = "-")
				{
					Value := !Value
					Style := SubStr(Style, 2)
				}
				Style := (Value ? "+" : "-") Style
				Control, Style, %Style%,, % "ahk_id " this.hwnd
			}
			else if(this._.HasKey("ControlExStyles") && ExStyle := this._.ControlExStyles[Name])
			{
				if(SubStr(ExStyle, 1,1) = "-")
				{
					Value := !Value
					ExStyle := SubStr(ExStyle, 2)
				}
				ExStyle := (Value ? "+" : "-") ExStyle
				Control, ExStyle, %ExStyle%,, % "ahk_id " this.hwnd
			}
			else if(Name = "Tooltip") ;Thanks art http://www.autohotkey.com/forum/viewtopic.php?p=452514#452514
			{
				TThwnd := CGUI.GUIList[this.GUINum]._.TThwnd
				Guihwnd := CGUI.GUIList[this.GUINum].hwnd
				Controlhwnd := [this.hwnd]
				if(this.type = "ComboBox") ;'ComboBox' = Drop-Down button + Edit
				{
					/*
					typedef struct tagCOMBOBOXINFO {
					  DWORD cbSize;
					  RECT  rcItem;
					  RECT  rcButton;
					  DWORD stateButton;
					  HWND  hwndCombo;
					  HWND  hwndItem;
					  HWND  hwndList;
					} COMBOBOXINFO, *PCOMBOBOXINFO, *LPCOMBOBOXINFO;
					*/
					VarSetCapacity(CBBINFO, 40 + 3 * A_PtrSize, 0)
					NumPut(40 + 3 * A_PtrSize, CBBINFO, 0, "UINT")
					result := DllCall("GetComboBoxInfo", "UInt", Controlhwnd[1], "PTR", &CBBINFO)
					Controlhwnd.Insert(Numget(CBBINFO, 40 + A_PtrSize))
				}
				else if(this.type = "ListView")
					Controlhwnd.Insert(DllCall("SendMessage", "UInt", Controlhwnd[1], "UInt", 0x101f, "PTR", 0, "PTR", 0))
				; - 'Text' and 'Picture' Controls requires a g-label to be defined.
				if(!TThwnd){
					; - 'ListView' = ListView + Header       (Get hWnd of the 'Header' control using "ControlGet" command).
					TThwnd := CGUI.GUIList[this.GUINum]._.TThwnd := DllCall("CreateWindowEx", "Uint", 0, "Str", "TOOLTIPS_CLASS32", "Uint", 0, "Uint", 2147483648 | 3, "Uint", -2147483648
									, "Uint", -2147483648, "Uint", -2147483648, "Uint", -2147483648, "Ptr", GuiHwnd, "Uint", 0, "Uint", 0,"Uint", 0, "PTR")
					DllCall("uxtheme\SetWindowTheme", "Ptr", TThwnd, "Ptr", 0, "UintP", 0)   ; TTM_SETWINDOWTHEME
				}
				for index, chwnd in Controlhwnd
				{
					/*
					typedef struct {
					  UINT      cbSize;
					  UINT      uFlags;
					  HWND      hwnd;
					  UINT_PTR  uId;
					  RECT      rect;
					  HINSTANCE hinst;
					  LPTSTR    lpszText;
					#if (_WIN32_IE >= 0x0300)
					  LPARAM    lParam;
					#endif 
					#if (_WIN32_WINNT >= Ox0501)
					  void      *lpReserved;
					#endif 
					} TOOLINFO, *PTOOLINFO, *LPTOOLINFO;
					*/
					Varsetcapacity(TInfo, 24 + 6 * A_PtrSize, 0)
					Numput(24 + 6 * A_PtrSize, TInfo, "UINT")
					Numput(1|16, TInfo, 4, "UINT")
					Numput(GuiHwnd, TInfo, 8, "PTR")
					Numput(chwnd, TInfo, 8 + A_PtrSize, "PTR")
					Numput(&Value, TInfo, 24 + 3 * A_PtrSize, "PTR")
					if(!this._.Tooltip)
					{
						DllCall("SendMessage", "Ptr", TThwnd, "Uint", 1028, "Ptr", 0, Ptr, &TInfo, "Ptr")         ; TTM_ADDTOOL = 1028 (used to add a tool, and assign it to a control)
						DllCall("SendMessage", "Ptr", TThwnd, "Uint", 1048, "Ptr", 0, Ptr, A_ScreenWidth, "PTR")      ; TTM_SETMAXTIPWIDTH = 1048 (This one allows the use of multiline tooltips)
					}
					DllCall("SendMessage", "Ptr", TThwnd, "UInt", (A_IsUnicode ? 0x439 : 0x40c), "Ptr", 0, "Ptr", &TInfo, "Ptr")   ; TTM_UPDATETIPTEXT (OLD_MSG=1036) (used to adjust the text of a tip)
				}
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
	
	Event: ContextMenu
	Invoked when the user right clicks on the control or presses the AppsKey while this control has focus. If this event is not handled a static context menu can be shown by setting the Menu variable of this control to an instance of <CMenu>.
	
	Event: OnValidate
	Invoked when the control is asked to validate its (textual) contents. This event is only valid for controls containing text, which are only Edit and ComboBox controls as of now.
	
	Parameters:
		Text - The current text of the control that should be validated. The function can return this value if it is valid or another valid value.
	*/
	
	/*
	Class: CImageListManager
	This class is used internally to manage the ImageLists of ListView/TreeView/Tab controls. Does not need to be used directly.
	*/
	Class CImageListManager
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.hwnd := hwnd
			this._.IconList := {}
		}
		__set(Name, Value)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this._.hwnd]
			if(Name = "LargeIcons" &&  Control.Type = "ListView")
			{
				GUI, % this._.GUINum ":Default"
				if(Control.Type = "ListView")
					GUI, ListView, % Control.ClassNN
				LV_SetImageList(this._.IconList.LargeIL_ID, Value = 1)
				this._.LargeIcons := Value = 1
				return Value = 1
			}
		}
		__get(Name)
		{
			if(Name = "LargeIcons")
				return this._.LargeIcons
		}
		Clear()
		{
			SmallIL_ID := this._.IconList.SmallIL_ID
			LargeIL_ID := this._.IconList.LargeIL_ID
			this._.IconList := {}
			if(SmallIL_ID)
			{
				this._.IconList.SmallIL_ID := IL_Create(5, 5, 0)
				old := LV_SetImageList(this._.IconList.SmallIL_ID, 0)
				IL_Destroy(old)
			}
			if(LargeIL_ID)
			{
				this._.IconList.LargeIL_ID := IL_Create(5, 5, 1)
				old := LV_SetImageList(this._.IconList.LargeIL_ID, this._.LargeIcons = 1)
				IL_Destroy(old)
			}
		}
		SetIcon(ID, PathOrhBitmap, IconNumber, SetIcon = true)
		{
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this._.hwnd]
			GUI, % this._.GUINum ":Default"
			if(Control.Type = "ListView")
				GUI, ListView, % Control.ClassNN
			else if(Control.Type = "TreeView")
				Gui, TreeView, % Control.ClassNN
			if(!this._.IconList.SmallIL_ID)
			{
				if(Control.Type = "ListView") ;Listview also has large icons
				{
					this._.IconList.LargeIL_ID := IL_Create(5, 5, 1)
					LV_SetImageList(this._.IconList.LargeIL_ID, this._.LargeIcons = 1)
				}
				this._.IconList.SmallIL_ID := IL_Create(5, 5, 0)
				if(Control.Type = "ListView" && !this._.LargeIcons)
					LV_SetImageList(this._.IconList.SmallIL_ID)
				else if(Control.Type = "TreeView")
				{
					SendMessage, 0x1109, 0, this._.IconList.SmallIL_ID, % Control.ClassNN, % "ahk_id " GUI.hwnd  ; 0x1109 is TVM_SETIMAGELIST
					if ErrorLevel  ; The TreeView had a previous ImageList.
						IL_Destroy(ErrorLevel)
				}
				else if(Control.Type = "Tab")
					SendMessage, 0x1303, 0, this._.IconList.SmallIL_ID, % Control.ClassNN, % "ahk_id " GUI.hwnd  ; 0x1109 is TVM_SETIMAGELIST
			}
			if(FileExist(PathorhBitmap))
			{
				;Icon IDs are identical in both lists so it's enough to look it up in one list
				Loop % this._.IconList.MaxIndex()
					if(this._.IconList[A_Index].Path = PathorhBitmap && this._.IconList[A_Index].IconNumber = IconNumber)
					{
						Icon := this._.IconList[A_Index]
						break
					}
				
				if(!Icon)
				{
					IID := IL_Add(this._.IconList.SmallIL_ID, PathorhBitmap, IconNumber, 1)
					if(Control.Type = "ListView")
						IID := IL_Add(this._.IconList.LargeIL_ID, PathorhBitmap, IconNumber, 1)
					this._.IconList.Insert(Icon := {Path : PathorhBitmap, IconNumber : IconNumber, ID : IID})
				}
			}
			else
			{
				;Icon IDs are identical in both lists so it's enough to look it up in one list
				Loop % this._.IconList.MaxIndex()
					if(this._.IconList[A_Index].Path = PathorhBitmap)
					{
						Icon := this._.IconList[A_Index]
						break
					}
				if(!Icon)
				{
					if(PathOrhBitmap)
					{
						IID := DllCall("ImageList_ReplaceIcon", "Ptr", this._.IconList.SmallIL_ID, Int, -1, "Ptr", PathorhBitmap) + 1
						if(Control.Type = "ListView")
							IID := DllCall("ImageList_ReplaceIcon", "Ptr", this._.IconList.LargeIL_ID, Int, -1, "Ptr", PathorhBitmap) + 1
					}
					else
						IID := -1
					this._.IconList.Insert(Icon := {Path : PathorhBitmap, IconNumber : 1, ID : IID})
				}
			}
			if(SetIcon)
			{
				if(Control.Type = "ListView")
					LV_Modify(ID, "Icon" (Icon ? Icon.ID : -1))
				else if(Control.Type = "TreeView")
					TV_Modify(ID, "Icon" (Icon ? Icon.ID : -1))
				else if(Control.Type = "Tab")
				{
					VarSetCapacity(TCITEM, 20 + 2 * A_PtrSize, 0)
					NumPut(2, TCITEM, 0, "UInt") ;State mask TCIF_IMAGE
					NumPut(Icon.ID - 1, TCITEM, 16 + A_PtrSize, "UInt") ;ID of icon in image list
					SendMessage, 0x1306, ID - 1, &TCITEM, % Control.ClassNN, % "ahk_id " GUI.hwnd ;TCM_SETITEM
				}
			}
			return Icon ? Icon.ID : -1
		}
	}
}

#include CTextControl.ahk
#include CEditControl.ahk
#include CButtonControl.ahk
#include CCheckboxControl.ahk
#include CChoiceControl.ahk
#include CListViewControl.ahk
#include CLinkControl.ahk
#include CPictureControl.ahk
#include CGroupBoxControl.ahk
#include CStatusBarControl.ahk
#include CTreeViewControl.ahk
#include CTabControl.ahk
#include CProgressControl.ahk
#include CSliderControl.ahk
#include CHotkeyControl.ahk
#include CActiveXControl.ahk
