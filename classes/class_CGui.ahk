#Include <CGuiCtrl>

class CGui
{
  app := ""
	n := ""
	options := ""
	title := ""
  titleId := ""
	controls := []
  controlsByNames := {}
	
	visible := false
	created := false
	enabled := false
	
	fontName := ""
	fontOptions := ""
	
	windowColor := ""
	controlColor := ""
	
	marginX := ""
	marginY := ""
	
	menu := ""
	
	windowState := ""
	
	isFlashing := false
	
	isDefault := false
  
  isLocalizable := true
	
	owner := ""
	disableOwner := false
	
	__New(app, n = "", options = "", title = "", isLocalizable = true)
	{
;     OutputDebug Gui.__New(%app%, %n%, %options%, %title%,%isLocalizable%)
		this.app := app
		this.n := n
		this.options := options      
    this.isLocalizable := isLocalizable
    this.titleId := title
    if(isLocalizable)
		  this.title := _t(this.titleId)
    else
      this.title := this.titleId
		this.DetectOwner()
    
    if(!InStr(this.options, "+Label"))
      this.AddOption("Label" this.n "Gui")
    
;     OutputDebug % "Gui, " this.GetCmdPrefix() "New, " this.options ", " this.title
		Gui, % this.GetCmdPrefix() "New", % this.options, % this.title
	}
  
  Create()
  {
    this.CreateControls()
  }
  
  CreateControls()
  {
    for i, ctrl in this.controls
    {
;       OutputDebug % "Creating control " ctrl.GetName()
      ctrl.Create()
    }
    this.created := true
  }
	
	DetectOwner()
	{
		pos := RegExMatch(this.options, "O)\+Owner([\S]+)", match)
		if(pos)
			this.owner := this.app.Forms[match.Value(1)]
;     OutputDebug % "owner " this.owner.n " pos " pos
	}
	
	GetCmdPrefix()
	{
		if(this.n)
			return this.n ":"
		else
			return ""
	}
	
	AddControl(Type, options = "", text ="", tabControl = "", tabPage = 0, isLocalizable = true)
	{
;     OutputDebug Adding control %Type%, %options%, %text%, %tabControl%, %tabPage%, %isLocalizable%
    
    ctrl := new CGuiCtrl(this, Type, Options, Text, tabControl, tabPage, isLocalizable)

		this.controls.insert(ctrl)
    if(tabControl && tabPage)
    {
      this.controls[tabControl.GetName()].controls.insert(ctrl)
    }
    this.controlsByNames[ctrl.GetName()] := ctrl
    
    return ctrl
	}
  
  AddButton(options = "", text ="OK", tabControl = "", tabPage = 0, isLocalizable = true)
  {
    if(!options)
      options := "w75 h25"
    return this.AddControl("Button", options, text, tabControl, tabPage, isLocalizable)
  }
  
  AddOkButton(options = "", text ="OK", tabControl = "", tabPage = 0, isLocalizable = true)
  {
    if(!text)
      text := "OK"
      
    btn := this.AddButton(options, text, tabControl, tabPage, isLocalizable)    
    btn.options .= " gAppGuiSubmit"
      
    return btn
  }
  
  AddCancelButton(options = "", text ="", tabControl = "", tabPage = 0, isLocalizable = true)
  {
    if(!text)
      text := "Cancel"

    btn := this.AddButton(options, text, tabControl, tabPage, isLocalizable)   
    
    btn.options .= " gAppGuiCancel"
      
    return btn
  }
	
	Show(disableOwner = false, options = "", title = "")
	{
		this.options := options
    
    if(title)
    {
      this.titleId := title
  		if(isLocalizable)
  		  this.title := _t(this.titleId)
      else
        this.title := this.titleId
    }
    
;     OutputDebug % "Gui, " this.GetCmdPrefix()  "Show, " this.options ", " this.title
		Gui, % this.GetCmdPrefix()  "Show", % this.options, % this.title
		this.visible := true
    
		if(disableOwner)
		{
			this.owner.Disable()
			this.disableOwner := true
		}
		
		if(InStr(this.options, "Minimize"))
			this.windowState := "Minimized"
		else if(InStr(this.options, "Maximize"))
			this.windowState := "Maximized"
		else if(InStr(this.options, "Restore"))
			this.windowState := "Restored"
		
		if(InStr(this.options, "NoActivate"))
			this.windowState := "Restored"
		
;     OutputDebug % this.n ".Show(): IsBound() = " this.IsBound()
    if(this.IsBound())
    {
      for i, ctrl in this.controls
      {
        if(ctrl.IsBound())
        {
          ctrl.UpdateValue()
        }
      }
    }
			
		this.enabled := true
	}
	
	Submit(NoHide = true)
	{
		if(NoHide)
			Gui, % this.GetCmdPrefix()  "Submit", NoHide
		else
		{
			Gui, % this.GetCmdPrefix()  "Submit"
			this.visible := false
		}
	}
	
	Cancel()
	{
		if(this.disableOwner)
		{
			this.owner.Enable()
			this.disableOwner := false
		}
			
		Gui, % this.GetCmdPrefix() "Cancel"
		this.visible := false
	}
	
	Destroy()
	{
		if(this.disableOwner)
		{
			this.owner.Enable()
			this.disableOwner := false
		}
		
		Gui, % this.GetCmdPrefix() "Destroy"
		this.visible := false
		this.created := false
	}
	
	Font(options = "", fontName = "")
	{
		Gui, % this.GetCmdPrefix() "Font", %options%, %fontName%
		this.fontName := fontName
		this.fontOptions := options
	}
	
	Color(WindowColor = "", ControlColor = "")
	{
		Gui, % this.GetCmdPrefix() "Color", %WindowColor%, %ControlColor%
		this.windowColor := WindowColor
		this.controlColor := ControlColor
	}
	
	Margin(x = "", y = "")
	{
		Gui, % this.GetCmdPrefix() "Margin", %x%, %y%
		this.marginX := x
		this.marginY := y
	}
	
	AddOption(option)
	{
		if(!InStr(this.options, option))
		{
			this.options .= " +" option
			Gui, % this.GetCmdPrefix()  "+" option
      if(InStr(option, "Owner"))
        this.DetectOwner()
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
		
		Gui, % this.GetCmdPrefix()  "-" option
	}
	
	Enable()
	{
		this.RemoveOption("Disabled")
		this.enabled := true
	}
	
	Disable()
	{
		this.AddOption("Disabled")
		this.enabled := false
	}
	
	MenuBar(menu = "")
	{
		if(menu)
		{
			Gui, % this.GetCmdPrefix()  "Menu", % menu.name
			this.menu := menu
		}
		else
		{
			Gui, % this.GetCmdPrefix()  "Menu"
			this.menu := ""
		}
	}
	
	Hide()
	{
		if(this.disableOwner)
		{
			this.owner.Enable()
			this.disableOwner := false
		}
		
		Gui, % this.GetCmdPrefix()  "Hide"
		this.visible := false
	}
	
	Minimize()
	{
		Gui, % this.GetCmdPrefix()  "Minimize"
		this.windowState := "Minimized"
	}
	
	Maximize()
	{
		Gui, % this.GetCmdPrefix()  "Maximize"
		this.windowState := "Maximized"
	}
	
	Restore()
	{
		Gui, % this.GetCmdPrefix()  "Restore"
		this.windowState := "Restored"
	}
	
	Flash(Off = false)
	{
		if(Off)
		{
			Gui, % this.GetCmdPrefix()  "Flash", Off
			this.isFlashing := false
		}
		else
		{
			Gui, % this.GetCmdPrefix()  "Flash"
			this.isFlashing := true
		}
	}
	
	Default()
	{
		Gui, % this.GetCmdPrefix()  "Default"
		this.isDefault := true
	}
  
  Localize()
  {
    for i, ctrl in this.controls
    {
      ctrl.Localize()
    }
    this.title := _t(this.titleId)
    if(!this.visible)
    {
      Gui, % this.GetCmdPrefix() "Show",Hide, % this.title
    }
    else
    {
      Gui, % this.GetCmdPrefix() "Show",NoActivate, % this.title
    }
  }
}
