Class CControl ;Never created directly
{
	__New(Name, Options, Text, GUINum) ;Basic constructor for all controls. The control is created in CGUI.Add()
	{
		this.Name := Name
		this.Options := Options
		this.Content := Text
		this.GUINum := GUINum ;Store link to gui for GuiControl purposes (and possibly others later
		this.Insert("_", {}) ;Create proxy object to enable __Get and __Set calls for existing keys (like ClassNN which stores a cached value in the proxy)
	}
	Show()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Control, Show,,,% "ahk_id " this.hwnd
	}
	Hide()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Control, Hide,,,% "ahk_id " this.hwnd
	}
	Focus()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ControlFocus,,% "ahk_id " this.hwnd
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Text")
				GuiControlGet, Value,% this.GuiNum ":", % this.ClassNN
				;~ ControlGetText, Value,, % "ahk_id " this.hwnd
			;~ else if(Name = "GUI")
				;~ value := CGUI.GUIList[this.GUINum]
			else if(Name = "x" || Name = "y"  || Name = "width" || Name = "height")
			{
				ControlGetPos, x,y,width,height,,% "ahk_id " this.hwnd
				Value := %Name%
			}
			else if(Name = "Position")
			{
				ControlGetPos, x,y,,,,% "ahk_id " this.hwnd
				Value := {x:x, y:y}
			}
			else if(Name = "Size")
			{
				ControlGetPos,,,width,height,,% "ahk_id " this.hwnd
				Value := {width:width, height:height}
			}
			else if(Name = "ClassNN")
			{
				if(this._.ClassNN != "" && this.hwnd && WinExist("ahk_class " this._.ClassNN) = this.hwnd) ;Check for cached value first
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
							Value := A_LoopField
							break
						}
					}
					this._.ClassNN := value
				}
			}
			else if(Name = "Enabled")
				ControlGet, Value, Enabled,,,% "ahk_id " this.hwnd
			else if(Name = "Visible")
				ControlGet, Value, Visible,,,% "ahk_id " this.hwnd
			else if(Name = "Style")
				ControlGet, Value, Style,,,% "ahk_id " this.hwnd
			else if(Name = "ExStyle")
				ControlGet, Value, ExStyle,,,% "ahk_id " this.hwnd
			else if(Name = "Focused")
			{
				ControlGetFocus, Value, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
				ControlGet, Value, Hwnd,, %Value%, % "ahk_id " CGUI.GUIList[this.GUINum].hwnd
				Value := Value = this.hwnd
			}
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
    }
    __Set(Name, Value)
    {
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Text")
				GuiControl, % this.GUINum ":",% this.ClassNN, %Value% ;Use GuiControl because of line endings
			else if(Name = "x" || Name = "y"  || Name = "width" || Name = "height")
				ControlMove,, % (Name = "x" ? Value : ""),% (Name = "y" ? Value : ""),% (Name = "width" ? Value : ""),% (Name = "height" ? Value : ""),% "ahk_id " this.hwnd
			else if(Name = "Position")
				ControlMove,, % Value.x,% Value.y,,,% "ahk_id " this.hwnd
			else if(Name = "Size")
				ControlMove,, % Value.width,% Value.height,% "ahk_id " this.hwnd
			else if(Name = "Enabled")
				Control, % (Value = 0 ? "Disable" : "Enable"),,,% "ahk_id " this.hwnd
			else if(Name = "Visible")
				Control,  % (Value = 0 ? "Hide" : "Show"),,,% "ahk_id " this.hwnd
			else if(Name = "Style")
				Control, Style, %Value%,,,% "ahk_id " this.hwnd
			else if(Name = "ExStyle")
				Control, ExStyle, %Value%,,,% "ahk_id " this.hwnd
			else if(Name = "_") ;Prohibit setting the proxy object
				Handled := true
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
    }
}

;Idea: Link?
Class CTextControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Text"
	}
}
Class CEditControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Edit"
	}	
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_TextChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_TextChanged"]()
		}
	}
}
Class CButtonControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := "Button"
	}	
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_Click"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_Click"]()
		}
	}
}
Class CCheckBoxControl Extends CControl ;This class is a radio control as well
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
				if(Name = "Checked")
					ControlGet, Value, Checked,,,% "ahk_id " this.hwnd
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "Checked")
				GuiControl, % this.GuiNum ":", % this.ClassNN,% (Value = 0 ? 0 : 1)
				;~ Control, % (Value = 0 ? "Uncheck" : "Check"),,,% "ahk_id " this.hwnd ;This lines causes weird problems. Only works sometimes and might change focus
			else
				Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_CheckedChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_CheckedChanged"]()
		}
	}
}
Class CChoiceControl Extends CControl ;This class is a ComboBox, ListBox and DropDownList
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
	}
	__Get(Name)
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "SelectedItem")
				ControlGet, Value, Choice,,,% "ahk_id " this.hwnd
			else if(Name = "SelectedIndex")
			{
				SendMessage, 0x147, 0, 0,,% "ahk_id " this.hwnd
				Value := ErrorLevel + 1
			}
			else if(Name = "Items")
			{
				ControlGet, List, List,,, % " ahk_id " this.hwnd
				Value := Array()
				Loop, Parse, List, `n
					Value.Insert(A_LoopField)			
			}
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedItem")
			{
				Items := this.Items
				Loop % Items.MaxIndex()
					if(Items[A_Index] = Value)
						Control, Choose, %A_Index%,,% "ahk_id " this.hwnd
			}
			else if(Name = "SelectedIndex" && Value >= 1)
				Control, Choose, %Value%,,% "ahk_id " this.hwnd
			else if(Name = "Items")
			{
				Items := this.Items
				if(!IsObject(Value))
				{
					if(InStr(Value, "|") = 1) ;Overwrite current items
						Items := Array()
					Loop, Parse, Value,|
						if(A_LoopField)
							Items.Insert(A_LoopField)
				}
				else
					Loop % Value.MaxIndex()
						Items.Insert(Value[A_Index])
				ItemsString := ""
				Loop % Items.MaxIndex()
					ItemsString .= (A_Index > 1 ? "|" : "") Items[A_Index]
				GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				if(!IsObject(Value) && InStr(Value, "||"))
				{
					if(RegExMatch(Value, "(?:^|\|)(..*?)\|\|", SelectedItem))
						Control, ChooseString, %SelectedItem1%,,% "ahk_id " this.hwnd
				}
			}
			else if(Name = "Text" && this.Type != "ComboBox")
				Handled := false ;Do nothing
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name "_SelectionChanged"]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name "_SelectionChanged"]()
		}
	}
}
Class CListViewControl Extends CControl
{
	__New(Name, ByRef Options, Text, GUINum)
	{
		global CGUI
		Events := ["_Click", "_RightClick", "_ItemActivated", "_MouseLeave", "_EditingStart", "_FocusReceived", "_FocusLost", "_ItemSelected", "_ItemDeselected", "_ItemFocused", "_ItemDefocused", "_ItemChecked",  "_ItemUnChecked", "_SelectionChanged", "_CheckedChanged", "_FocusedChanged"]
		if(!InStr(Options, "AltSubmit")) ;Automagically add AltSubmit when necessary
		{
			for index, function in Events
			{
				if(IsFunc(CGUI.GUIList[GUINum][Name Function]))
				{
					Options .= " AltSubmit"
					break
				}
			}
		}
		base.__New(Name, Options, Text, GUINum)
		this.Insert("_", {}) ;Create proxy object to enable __Get and __Set calls for existing keys
		this._.Insert("Items", new this.CItems(this)) ;"Items" is an example of such a key
		this.Type := "ListView"
	}
	__Delete()
	{
		msgbox delete listview
	}
	ModifyCol(ColumnNumber="", Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_ModifyCol(ColumnNumber, Options, ColumnTitle)
	}
	InsertCol(ColumnNumber, Options="", ColumnTitle="")
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_InsertCol(ColumnNumber, Options, ColumnTitle)
	}
	DeleteCol(ColumnNumber)
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		Gui, % this.GUINum ":Default"
		Gui, ListView, % this.ClassNN
		LV_DeleteCol(ColumnNumber)
	}
	__Get(Name, Params*)
	{
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "Items")
				Value := this._.Items
			else if(Name = "SelectedItems")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := Array()
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1) = A_Index)
						Value.Insert(new this.CItems.CRow(this, A_Index))
			}
			else if(Name = "SelectedIndices")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := Array()
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1) = A_Index)
						Value.Insert(A_Index)
			}
			else if(Name = "CheckedItems")
			{			
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := Array()
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, "Checked") = A_Index)
						Value.Insert(new this.CItems.CRow(this, A_Index))
			}
			else if(Name = "CheckedIndices")
			{			
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := Array()
				Loop % this.Items.Count
					if(LV_GetNext(A_Index - 1, "Checked") = A_Index)
						Value.Insert(A_Index)
			}
			else if(Name = "FocusedItem" || Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Value := LV_GetNext(0, "Focused")
				if(Name = "FocusedItem")
					Value := new this.CItems.CRow(this, Value)
			}
			if(Params.MaxIndex() >= 1 && IsObject(value)) ;Fix unlucky multi parameter __GET
			{
				Value := Value[Params[1]]
				if(Params.MaxIndex() >= 2 && IsObject(value))
					Value := Value[Params[2]]
			}
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value, Params*)
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedIndices" || Name = "CheckedIndices")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				Indices := Value
				if(!IsObject(Value))
				{
					Indices := Array()
					Loop, Parse, Value,|
						if A_LoopField is Integer
							Indices.Insert(A_LoopField)
				}
				LV_Modify(0, Name = "SelectedIndices" ? "-Select" : "-Check")
				Loop % Indices.MaxIndex()
					LV_Modify(Indices[A_Index], Name = "SelectedIndices" ? "Select" : "Check")
			}
			else if(Name = "FocusedIndex")
			{
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				LV_Modify(Value, "Focused")
			}
			else if(Name = "Items" && IsObject(Value) && IsObject(this._.Items))
			{
				;This won't get called while this.Items is defined as key through the constructor. If it isn't and this.Items is dynamically generated,
				;assignments like Listview.Items[1][2] := "test" aren't going to work. Instead workaround like Listview["Items"][1][2] are required then.
				;For now this means that Items will not be assignable directly.
				;~ msgbox set items
				Gui, % this.GUINum ":Default"
				Gui, ListView, % this.ClassNN
				if(!Params.MaxIndex()) ;Directly setting all items
				{
					LV_Delete()
					Loop % Value.MaxIndex()
					{
						Fields := Array()
						Row := Value[A_Index]
						Loop % Row.MaxIndex()
							Fields.Insert(Row[A_Index])
						LV_Add((Row.Checked ? "Checked " : "") (Row.Selected ? " Select" : "") (Row.Focused ? " Focus" : ""), Fields*)
					}
					Value := this._.Items
				}
				else if(Params.MaxIndex() > 0)
				{
					Items := this._.Items
					Items[Params*] := Value
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
	Class CItems
	{
		__New(Control)
		{
			this.Insert("Control", Control)
		}
		_NewEnum()
		{
			global CEnumerator
			return new CEnumerator(this)
		}
		MaxIndex()
		{
			global CGUI
			if(CGUI.GUIList[this.GUINum].IsDestroyed)
				return
			Gui, % this.Control.GUINum ":Default"
			Gui, ListView, % this.Control.ClassNN
			return LV_GetCount()
		}
		AddRow(Options, Fields*)
		{
			global CGUI
			if(CGUI.GUIList[this.GUINum].IsDestroyed)
				return
			Gui, % this.Control.GUINum ":Default"
			Gui, ListView, % this.Control.ClassNN
			result := LV_Add(Options, Fields*)
		}
		InsertRow(RowNumber, Options, Fields)
		{
			global CGUI
			if(CGUI.GUIList[this.GUINum].IsDestroyed)
				return
			Gui, % this.Control.GUINum ":Default"
			Gui, ListView, % this.Control.ClassNN
			LV_Insert(RowNumber, Options, Fields*)
		}
		ModifyRow(RowNumber, Options, Fields)
		{
			global CGUI
			if(CGUI.GUIList[this.GUINum].IsDestroyed)
				return
			Gui, % this.Control.GUINum ":Default"
			Gui, ListView, % this.Control.ClassNN
			LV_Modify(RowNumber, Options, Fields*)
		}
		DeleteRow(RowNumber)
		{
			global CGUI
			if(CGUI.GUIList[this.GUINum].IsDestroyed)
				return
			Gui, % this.Control.GUINum ":Default"
			Gui, ListView, % this.Control.ClassNN
			LV_Delete(RowNumber)
		}
		__Get(Name)
		{
			global CGUI
			if(!CGUI.GUIList[this.Control.GUINum].IsDestroyed)
			{
				if Name is Integer
				{
					if(Name > 0 && Name <= this.Count)
					{
						Row := new this.CRow(this.Control, Name)
						return Row
					}
				}
				else if(Name = "Count")
					return this.MaxIndex()
			}
		}
		__Set(Name, Value)
		{
			global CGUI
			if(!CGUI.GUIList[this.Control.GUINum].IsDestroyed)
			{
				if Name is Integer ;Set a single row
				{
					if(Name <= this.MaxIndex())
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						if(!IsObject(Value))
						{
							Row := Object()
							Loop, Parse, Value, |
								Row.Insert(A_LoopField)
						}
						else
						{
							Checked := Value.Checked
							Row := Object()
							Loop % Value.MaxIndex()
								Row.Insert(Value[A_Index])
						}
						LV_Modify(Name, (Value.Checked ? "Checked " : "") (Value.Selected ? " Select" : "") (Value.Focused ? " Focus" : ""), Row*)
					}
				}
			}
		}
		Class CRow
		{
			__New(Control, RowNumber)
			{
				;~ msgbox new row
				this.Insert("Control", Control)
				this.Insert("RowNumber", RowNumber)
			}
			_NewEnum()
			{
				global CEnumerator
				return new CEnumerator(this)
			}
			MaxIndex()
			{				
				global CGUI
				if(CGUI.GUIList[this.Control.GUINum].IsDestroyed)
					return 0
				Gui, % this.Control.GUINum ":Default"
				Gui, ListView, % this.Control.ClassNN
				Return LV_GetCount("Column")
			}
			__Get(Name)
			{
				global CGUI
				if(!CGUI.GUIList[this.Control.GUINum].IsDestroyed)
				{
					if Name is Integer
					{
						if(Name > 0 && Name <= this.Count) ;Setting default listview is already done by this.Count __Get
						{
							LV_GetText(value, this.RowNumber, Name)
							return value
						}
					}
					else if(Name = "Count")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						Return LV_GetCount("Column")
					}
					else if(Name = "Checked")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						CheckedRow := LV_GetNext(this.RowNumber - 1, "Checked")
						;~ tooltip checkedrow %checkedrow%
						return checkedrow = this.RowNumber
					}
					else if(Name = "Selected")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						return LV_GetNext(this.RowNumber - 1) = this.RowNumber
					}
					else if(Name = "Focused")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						return LV_GetNext(this.RowNumber - 1, "Focused") = this.RowNumber
					}
				}
			}
			__Set(Name, Value)
			{				
				global CGUI
				if(!CGUI.GUIList[this.Control.GUINum].IsDestroyed)
				{
					if Name is Integer
					{
						if(Name <= this.Count) ;Setting default listview is already done by this.Count __Get
							LV_Modify(this.RowNumber, "Col" Name, Value)
						return Value
					}
					else if(Name = "Checked")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						LV_Modify(this.RowNumber, (Value = 0 ? "-" : "") "Check")
						return Value
					}
					else if(Name = "Selected")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						LV_Modify(this.RowNumber, (Value = 0 ? "-" : "") "Select")
						return Value
					}
					else if(Name = "Focused")
					{
						Gui, % this.Control.GUINum ":Default"
						Gui, ListView, % this.Control.ClassNN
						LV_Modify(this.RowNumber, (Value = 0 ? "-" : "") "Focus")
						return Value
					}
				}
			}
		}
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		static events:= object()
		static i := 0
		Critical := A_IsCritical
		Critical, On
		ErrLevel := ErrorLevel
		;~ if(!events)
			;~ events := object()
		;~ events[mod(i,30) +1] := A_GuiEvent " " A_EventInfo " " ErrLevel
		;~ i++
		;~ loop 30
			;~ text .= events[A_Index] "`n"
		;~ tooltip %text%
		Mapping := {DoubleClick : "_DoubleClick", R : "_DoubleRightClick", ColClick : "_ColumnClick", E : "_EditingEnd", Normal : "_Click", RightClick : "_RightClick",  A : "_ItemActivate", E : "_EditingStart", K : "_KeyPress"}
		for Event, Function in Mapping
			if(A_GuiEvent == Event)
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function](A_EventInfo)
					if(!Critical)
						Critical, Off
					return
				}
		Mapping := {C : "_MouseLeave", F : "_FocusReceived", f : "_FocusLost", M : "_Marquee", Sa : "_ScrollingStart", sb : "_ScrollingEnd"} ;Case insensitivity strikes back!
		for Event, Function in Mapping
			if(A_GuiEvent == SubStr(Event, 1, 1))
				if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
				{
					ErrorLevel := ErrLevel
					`(CGUI.GUIList[this.GUINum])[this.Name Function]()
					if(!Critical)
						Critical, Off
					return
				}
		if(A_GuiEvent == "I")
		{
			Mapping := { Sa : "_ItemSelected", sb : "_ItemDeselected", Fa : "_ItemFocused", fb : "_ItemDefocused", Ca : "_ItemChecked", cb : "_ItemUnChecked"} ;Case insensitivity strikes back!
			for Event, Function in Mapping
				if(InStr(ErrLevel, SubStr(Event, 1, 1), true))
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](A_EventInfo)
						if(!Critical)
							Critical, Off
					}
			Mapping := {S : "_SelectionChanged", C : "_CheckedChanged", F : "_FocusedChanged"}
			for Event, Function in Mapping
				if(InStr(ErrLevel, Event, false))
					if(IsFunc(CGUI.GUIList[this.GUINum][this.Name Function]))
					{
						ErrorLevel := ErrLevel
						`(CGUI.GUIList[this.GUINum])[this.Name Function](A_EventInfo)
					}
			if(!Critical)
				Critical, Off
			return
		}
	}
}

Class CPictureControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "Picture"
	}
	/*
	__Get(Name) ;Nothing here for now, delete later if not required
    {
		global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Value) ;Nothing here for now, delete later if not required
	{
		global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			;~ Handled := true
			;~ if(Name = "Checked")
			;~ else
				;~ Handled := false
		if(!DetectHidden)
			DetectHiddenWindows, Off
		if(Handled)
			return Value
		}
	}
	*/
	/*
	Function: SetImageFromHBitmap
	Sets the image of this control.
	
	Parameters:
		hBitamp - The bitmap handle to which the picture of this control is set
	*/
	SetImageFromHBitmap(hBitmap)
	{
		SendMessage, 0x172, 0x0, hBitmap,, % "ahk_id " this.hwnd
		DllCall("gdi32\DeleteObject", "PTR", ErrorLevel)
	}
	HandleEvent()
	{
		global CGUI
		if(CGUI.GUIList[this.GUINum].IsDestroyed)
			return
		ErrLevel := ErrorLevel
		func := A_GUIEvent = "DoubleClick" ? "_DoubleClick" : "Click"
		if(IsFunc(CGUI.GUIList[this.GUINum][this.Name func]))
		{
			ErrorLevel := ErrLevel
			`(CGUI.GUIList[this.GUINum])[this.Name func]()
		}
	}
}
Class CGroupBoxControl Extends CControl
{
	__New(Name, Options, Text, GUINum)
	{
		base.__New(Name, Options, Text, GUINum)
		this.Type := "GroupBox"
	}
}