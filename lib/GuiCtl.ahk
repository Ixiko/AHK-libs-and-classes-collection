class GuiCtl
{
	static Type := ""
	
	__New(gui, args*)
	{
		Gui, %gui%:+LastFoundExist
		if !WinExist()
			throw Exception("GUI does not exist.", -1, gui)

		CtlType := this.Type ? this.Type : ObjRemoveAt(args, 1)
		options := args[1], text := args[2]
		Gui, %gui%:Add, %CtlType%, %options% HwndhCtl, %text%
		this.__Handle := hCtl + 0
		this.__Gui := gui
	}

	Handle {
		get {
			return this.__Handle + 0
		}
		set {
			throw Exception("This property is read-only", -1, "Handle")
		}
	}

	Gui {
		get {
			return this.__Gui
		}
		set {
			throw Exception("This property is read-only", -1, "Gui")
		}
	}

	Value {
		set {
			gui := this.Gui, hCtl := this.Handle
			GuiControl, %gui%:, %hCtl%, %value%
			return value
		}
		get {
			gui := this.Gui, hCtl := this.Handle
			GuiControlGet, value, %gui%:, %hCtl%
			return value
		}
	}

	Pos[arg:=""] {
		get {
			gui := this.Gui, hCtl := this.Handle
			GuiControlGet, pos, %gui%:Pos, %hCtl%
			return arg ? pos%arg% : { X:posX, Y:posY, W:posW, H:posH }
		}
	}

	Listener {
		set {
			gui := this.Gui, hCtl := this.Handle
			if value
			{
				if IsObject(value)
					GuiControl, %gui%:+g, %hCtl%, %value%
				else
					GuiControl, %gui%:+g%value%, %hCtl%
			}
			else
				GuiControl, %gui%:-g, %hCtl%

			return value
		}
	}

	SetFocus()
	{
		gui := this.Gui, hCtl := this.Handle
		GuiControl, %gui%:Focus, %hCtl%
	}

	Move(X:="", Y:="", W:="", H:="", redraw:=false)
	{
		gui := this.Gui
		hCtl := this.Handle

		pos := ""
		Loop, Parse, % "xywh"
			if (%A_LoopField% != "")
				pos .= " " . A_LoopField . %A_LoopField%

		Move := redraw ? "MoveDraw" : "Move"
		GuiControl, %gui%:%Move%, %hCtl%, %pos%
	}

	MoveDraw(X:="", Y:="", W:="", H:="")
	{
		this.Move(X, Y, W, H, true)
	}

	Hide(hide:=true)
	{
		gui := this.Gui, hCtl := this.Handle
		GuiControl, %gui%:Hide%hide%, %hCtl%
	}
}