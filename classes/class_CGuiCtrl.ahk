; NOTE: Depends on _t()

class CGuiCtrl
{
  controlType := "GuiCtrl"
	; Gui control type
	type := ""
	; Gui control options
	options := ""
	; Text appearing in the control
	text := ""
	; Gui
	gui := ""
  ; Tab control (for a control placed in a Tab2)
	tabControl := ""
	; Tab page number (for a control placed in a Tab2)
	tabPage := 0
  name := ""
  ; List items for ListBox,DropDownList,ComboBox or Tab pages for Tab2 controls
  Items := ""
  ; Child controls for Tab2 and GroupBox
  controls := []
  ; Determines if this control is localizable
  isLocalizable := true
  ; Determines if items in a listView are localizable
  areLVItemsLocalizable := false
  isCreated := false
  ; strId for localizable
  strId := ""
  ; Item strIds for localizable
  ItemStrIds := ""
  ; Action is assigned by action manager
  action := ""
  
  textAddColon := true
  applyDecoration := true
;
; Function: GuiCtrl
; Description:
;		The base class for all Gui controls.
; Syntax: GuiCtrl(Type, Text [, options])
; Parameters:
;		Type - The AHK control type
;		Text - The AHK control text (as in Gui, Add...)
;		Options - (Optional) The AHK control's options (as in Gui, Add...)
; Remarks:
;   To have one of the tabs or list items pre-selected when the window first appears, include two pipe characters after it. Alternatively, include in Options the word Choose followed immediately by the number to pre-select (for Tab2, ListBox, DropDownList, and ComboBox).
;		    Parameters are not checked.
;				Set variable names and labels with caution because they are global and must be unique to avoid assigning the same variable name to multiple controls in different Guis. All global variable names for controls should be stored in the AppController to enable checking.
; Example:
;		MyText := new GuiCtrl("Text", "Name:")
;		MyText := new GuiCtrl("Text", "Name:", "w50")
;
	__New(gui, Type, Options = "", Text = "", tabControl = "", tabPage = 0, isLocalizable = true, setDefaultGlabel = true)
	{		
;     OutputDebug GuiCtrl.__New(%gui%, %Type%, %Options%, %Text%, %tabControl%, %tabPage%, %isLocalizable%)
		this.gui := gui
    ; TODO: add stringlower to menuItem, etc
    StringLower, type, type
		this.type  := Type
    this.isLocalizable := isLocalizable
      
;     OutputDebug % "Text: " this.text
		this.options := Options
    this.tabControl := tabControl
    this.tabPage := tabPage
    
    this.GetName()
    
    if type in edit,updown,checkbox,radio,dropdownlist,combobox,listbox,hotkey,datetime,monthcal,slider
    {
;       OutputDebug setting default label
      if(setDefaultGlabel)
      {
        this.SetDefaultGLabel()
      }
    }
;     OutputDebug % "Creating control named " this.name
    this._SetText(text, true, true, true)
	}

;
; Function: GuiCtrl.GetName
; Description:
;		Gets the control's variable name.
; Syntax: GuiCtrl.GetName()
; Return Value:
; 		Returns the control's variable name (without leading 'v')
; Example:
;		name := MyText.GetName()
;
	GetName()
	{
;     OutputDebug In GuiCtrl.GetName()
    
    if(this.name <> "")
      return this.name

		name := ""
		tmpOptions := % this.options
		
		StringReplace, tmpOptions, tmpOptions, VScroll
		
		namePos := RegExMatch(tmpOptions, "\bv[a-zA-Z_0-9]+\b", match)
    
;     OutputDebug Position of the name in options : %namePos% 
    
		if(namePos)
			name := SubStr(match, 2)
		
    this.name := name
;     OutputDebug Setting name to %name%
		return name
	}
  
  SetName(newName)
	{
		name := ""
		tmpOptions := % this.options
		
		StringReplace, tmpOptions, tmpOptions, VScroll
		
		namePos := RegExMatch(tmpOptions, "\bv[\w_\d]+\b", match)
    
    tmpOptions := % this.options ; to restore VScroll
		if(namePos)
    {
			name := SubStr(match, 2)
      StringReplace, tmpOptions, tmpOptions, v%name%, v%newName%
      this.options := tmpOptions
		}
    else
    {
      this.options .= "v" newName
    }
    this.name := newName
	}
  
  GetEventGroup()
  {
    return this.gui.name
  }

;
; Function: GuiCtrl.GetGLabel
; Description:
;		Gets the control's g-label.
; Syntax: GuiCtrl.GetGLabel()
; Return Value:
; 		Returns the control's g-label (without leading 'g')
; Example:
;		label := MyText.GetGLabel()
;
	GetGLabel()
	{
		glabel := ""
		tmpOptions := % this.options
		
		glabelPos := RegExMatch(tmpOptions, "\bg[\w_\d]+\b", match)
		if(glabelPos)
			glabel := SubStr(match, 2)
		
		return glabel
	}
  
  GetCmdPrefix()
	{
		if(this.gui.n)
			return this.gui.n ":"
		else
			return ""
	}
  
  SetDefaultGLabel()
  {
;     OutputDebug in SetDefaultGLabel
    if(!this.GetName())
      return
      
    glabel := ""
		tmpOptions := % this.options
		
		glabelPos := RegExMatch(tmpOptions, "\bg[\w_\d]+\b", match)
		if(glabelPos)
    {
			glabel := SubStr(match, 2)
      StringReplace, tmpOptions, tmpOptions, %glabel%, gGuiControlEvent
    }
    else
      this.options .= " gGuiControlEvent"
    
    EventManager.RemoveHandler(this.gui.n "." this.name "." glabel)
    
    EventManager.AddHandler(this.gui.n "." this.name ".Normal", "GuiManager.OnGuiCtrlEvent")
  }
  
;
; Function: GuiCtrl.Create
; Description:
;		Adds a Gui control to the Gui that is made default externally.
; Syntax: GuiCtrl.Create()
; Remarks:
;   Child control labels should be placed in a subclass of Gui class in CreateControls method after base.CreateControls()
; Example:
;		MyText := new GuiCtrl("Text", "Name:")
;		Gui, 5: Default
;		MyText.Create()
;
	Create()
	{
		global
		if(this.tabPage)
    {
			Gui, % this.GetCmdPrefix() "Tab", % this.tabPage
    }
    else
    {
      Gui, % this.GetCmdPrefix() "Tab"
    }
    
    if(this.GetGLabel() = "" && !IsEmpty(this.action))
    {
      this.options .= " gGuiControlEvent"
    }
    
    Gui, % this.GetCmdPrefix() "Add", % this.Type, % this.options, % this.text
;     OutputDebug % "Gui, " this.GetCmdPrefix() "Add, " this.Type ", " this.options ", " this.text
    this.isCreated := true
    
	}
  
  Localize()
  {
    if(this.isLocalizable)
    {
;       OutputDebug, % "GuiCtrl: Localizing control " this.GetName()
      type := this.type
      if type in Tab2,ListBox,DropDownList,ComboBox,ListView
      {
;         OutputDebug % "GuiCtrl: Control " this.GetName() " is " this.type "(in Tab2,ListBox,DropDownList,ComboBox)"
        text := this.ItemStrIds
        Loop, Parse, text, |
        {
          ; Skip whitespace between 2 pipes
          if(A_LoopField = "")
            continue
          
          StringReplace, text, text, %A_LoopField%, % _t(A_LoopField)
;           OutputDebug % "Replacing " A_LoopField " with "  _t(A_LoopField)
          this.Items[A_Index] := {strId : A_LoopField
            , text : _t(A_LoopField)}
        }
        if(this.type <> "ListView")
          this.SetValue(text)
        else
          this.LVSetHeaders(text)
      }
      else     
      {
        this.SetText(this.strId)
      }
    }
  }
  
  GetValue()
  {
    if(!this.isCreated)
    {
;       OutputDebug GuiCtrl.GetValue() returns ErrorLevel = 1
      ErrorLevel := 1
      return
    }
    type := this.type
    if type not in listview,treeview 
    {
      GuiControlGet, val,, % this.GetName()
;       OutputDebug GuiCtrl.GetValue() returns %val%
      return val
    }
    else
    {
      throw "GuiCtrl.GetValue() is not implemented for ListView and TreeView"
    }
  }
	
	SetValue(v)
	{
    type := this.type
    if type in Tab2,ListBox,DropDownList,ComboBox
    {
      v := "|" v
    }
;     OutputDebug % "GuiControl, " this.GetCmdPrefix() ", " this.GetName() ", " v
		GuiControl,% this.GetCmdPrefix(), % this.GetName(), %v%
	}
  
  SetText(text)
	{
    this._SetText(text, true, true) 
	}
  
  LVSetHeaders(text)
  {
    this.gui.Default()
    Loop, Parse, text , |
    {
;           OutputDebug Modifying col %A_Index%, %A_LoopField%
      LV_ModifyCol(A_Index, "AutoHdr", A_LoopField)
    }
  }
	
	_SetText(text, localize = true, applyOptions = false, apply = true)
	{
;     OutputDebug In GuiCtrl._SetText(%text%, %localize%, %applyOptions%, %apply%)
    type := this.type
    if type in Tab2,ListBox,DropDownList,ComboBox,ListView
    {
      this.Items := {}
      this.ItemStrIds := text
      Loop, Parse, text, |
      {
        ; Skip whitespace between 2 pipes
        if(A_LoopField = "")
          continue
          
        if(this.isLocalizable)
        {
          StringReplace, text, text, %A_LoopField%, % _t(A_LoopField)
;           OutputDebug % "GuiCtrl._SetText: " this.name " is localizable" 
;           OutputDebug % "Replacing '" A_LoopField "' with '"  _t(A_LoopField) "'"
          this.Items[A_Index] := {strId : A_LoopField
            , text : _t(A_LoopField)}
        }
        else
        {
;           OutputDebug % "GuiCtrl._SetText: " this.name " is NOT localizable" 
          this.Items[A_Index] := {text : A_LoopField}
        }
      }
      this.text := text
    }
    else
		{
      if(localize && this.isLocalizable)
      {
;         OutputDebug % "GuiCtrl._SetText: " this.name " is localizable: " _t(text) 
        this.strId := text
        this.text := _t(text)
      }
      else
      {
;         OutputDebug % "GuiCtrl._SetText: " this.name " is NOT localizable" 
        this.text := text
      }
    }
      
    if(this.applyDecoration && (this.type = "text" && this.textAddColon))
      this.text .= ":"
    
    if(apply && this.isCreated)
    {
      if(type <> "ListView")
        GuiControl, % this.GetCmdPrefix() "Text", % this.GetName(), % this.text
      else
      {
        this.LVSetHeaders(this.text)
      }
    }  
;     OutputDebug % "text = " text ", localized = " this.text  
	}
	
	Move(options)
	{
		GuiControl, % this.GetCmdPrefix() "Move", % this.GetName(), %options%
	}
	
	Redraw()
	{
		GuiControl, % this.GetCmdPrefix() "MoveDraw", % this.GetName()
	}
	
	MoveDraw(options)
	{
		GuiControl, % this.GetCmdPrefix() "MoveDraw", % this.GetName(), %options%
	}
	
	Focus()
	{
		GuiControl, % this.GetCmdPrefix() "Focus", % this.GetName()
	}
	
	Enable()
	{
		GuiControl, % this.GetCmdPrefix() "Enable", % this.GetName()
	}
	
	Disable()
	{
		GuiControl, % this.GetCmdPrefix() "Disable", % this.GetName()
	}
	
	Hide()
	{
		GuiControl, % this.GetCmdPrefix() "Hide", % this.GetName()
	}
	
	Show()
	{
		GuiControl, % this.GetCmdPrefix() "Show", % this.GetName()
	}
	
;
; Function: GuiCtrl.Delete
; Description:
;		Hides and disables the Gui control
; Syntax: GuiCtrl.Delete()
; Remarks:
;		GuiControl, Delete (not yet implemented): This sub-command does not yet exist. As a workaround, use Hide and/or Disable (above), or destroy and recreate the entire window via Gui Destroy.
; Example:
;		MyText.Delete()
;
	Delete()
	{
		this.Hide()
		this.Disable()
	}

;
; Function: GuiCtrl.SelectItemIndex
; Description:
;		Sets the selection in a ListBox, DropDownList, ComboBox, or Tab control to be the Nth entry. N should be 1 for the first entry, 2 for the second, etc (if N is not an integer, the ChooseString method described below will be used instead). 
; Syntax: GuiCtrl.SelectItemIndex(N)
; Parameters:
;		N - The number of an entry to select
; Remarks:
;		Unlike Control Choose, this sub-command will not trigger any g-label associated with the control unless N is preceded by a pipe character (even then, the g-label is triggered only when the new selection is different than the old one, at least for Tab controls). For example: GuiControl, Choose, MyListBox, |3.
; Example:
;		MyList.SelectItemIndex(1)
;
	SelectItemIndex(n)
	{
		GuiControl, % this.GetCmdPrefix() "Choose", % this.GetName(), %N%
	}
	
	SelectItem(text)
	{
		GuiControl, % this.GetCmdPrefix() "ChooseString", % this.GetName(), %text%
	}
	
	Font(fontOptions = "", fontFace = "")
	{
		Gui, % this.GetCmdPrefix() "Font", %fontOptions%, %fontFace%
		GuiControl, % this.GetCmdPrefix() "Font", % this.GetName()
	}
	
	AddOption(option)
	{
		if(!InStr(this.options, option))
		{
			this.options .= " +" option
			GuiControl, % this.GetCmdPrefix() "+" option, % this.GetName()
		}
	}
	
	RemoveOption(option)
	{
		if(InStr(this.options, "+" option))
		{
			options := this.options
			StringReplace, options, options, +%option%, -%option%,All
			this.options := options
		}
		else if(InStr(this.options, option))
		{
			options := this.options
			StringReplace, options, options, %option%, -%option%,All
			this.options := options
		}
		else
			this.options .= " -" option
		
		GuiControl, % this.GetCmdPrefix() "-" option, % this.GetName()
	}
}
