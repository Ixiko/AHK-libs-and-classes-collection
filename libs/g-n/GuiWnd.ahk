class GuiWnd
{
	static Windows := {}
	
	__New(title:="", options:="", FuncPrefixOrObj:="")
	{
		Gui, New, +LastFound %options% +LabelGWnd_On, %title%
		this.__Handle := WinExist()+0
		this.__FuncPrefixOrObj := FuncPrefixOrObj

		GuiWnd.Windows[this.Handle] := &this
	}

	__Delete()
	{
		if (this.Handle && DlLCall("IsWindow", "Ptr", this.Handle))
			this.Destroy()
	}

	__Call(method, args*)
	{
		if ( InStr(method, "Add")==1 && StrLen(method)>3 )
			return this.Add(SubStr(method, 4), args*)
	}

	Handle {
		get {
			return this.__Handle + 0
		}
		set {
			throw Exception("This property is read-only", -1, "Handle")
		}
	}

	Options {
		set {
			h := this.Handle
			Gui, %h%:%value%
			return value
		}
	}

	Add(CtlType, options:="", text:="")
	{
		global ; for control's associated variable(s)
		local h, hCtl
		h := this.Handle
		Gui, %h%:Add, %CtlType%, %options% +HwndhCtl, %text%
		return hCtl
	}

	Show(options:="", title:="")
	{
		h := this.Handle
		Gui, %h%:Show, %options%, %title%
	}

	Destroy()
	{
		h := this.Handle
		Gui, %h%:Destroy
		ObjDelete(GuiWnd.Windows, h)
		this.__Handle := ""
	}

	SetOptions(options:="")
	{
		h := this.Handle
		Gui, %h%:%options%
	}

	SetFont(FontOptions:="", FontName:="")
	{
		h := this.Handle
		Gui, %h%:Font, %FontOptions%, %FontName%
	}

	BgColor {
		set {
			h := this.Handle
			Gui, %h%:Color, %value%
			return value
		}
	}

	CtlColor {
		set {
			h := this.Handle
			Gui, %h%:Color,, %value%
			return value
		}
	}

	Margin[arg:="XY"] {
		set {
			h := this.Handle
			X := Trim(arg, " `tY")="X" ? value : ""
			Y := Trim(arg, " `tX")="Y" ? value : ""
			Gui, %h%:Margin, %X%, %Y%
			return value
		}
	}

	Menu {
		set {
			h := this.Handle
			Gui, %h%:Menu, %value%
			return value
		}
	}

	Hide()
	{
		h := this.Handle
		Gui, %h%:Hide
	}

	Minimize()
	{
		h := this.Handle
		Gui, %h%:Minimize
	}

	Maximize()
	{
		h := this.Handle
		Gui, %h%:Maximize
	}

	Restore()
	{
		h := this.Handle
		Gui, %h%:Restore
	}

	Flash(flash:=true)
	{
		h := this.Handle
		OnOrOff := (flash && flash!="Off") ? "On" : "Off"
		Gui, %h%:Flash, %OnOrOff%
	}

	SetAsDefault()
	{
		h := this.Handle
		Gui, %h%:Default
	}

	FocusedCtl {
		get {
			h := this.Handle
			GuiControlGet, FocusedCtl, %h%:Focus
			GuiControlGet, hFocusedCtl, %h%:Hwnd, %FocusedCtl%
			return hFocusedCtl+0
		}
	}

	OnClose()
	{
		this.Destroy()
		
		prev_DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
			
			static PID := DllCall("GetCurrentProcessId")
			if !WinExist("ahk_class AutoHotkeyGUI ahk_pid " . PID)
				SetTimer, gwnd_exit, -1
		
		DetectHiddenWindows, %prev_DHW%
		return
	gwnd_exit:
		ExitApp
	}

	_OnEvent(event, args*)
	{
		FuncPrefixOrObj := this.__FuncPrefixOrObj

		; Similar to ComObjConnect
		if IsObject(FuncPrefixOrObj)
			return FuncPrefixOrObj[event](this, args*)

		; +Label<LabelorFuncPrefix>
		else if fn := Func(FuncPrefixOrObj . event)
			return fn.Call(this, args*)

		; Subclassing
		else
			return this[event](args*)
	}

	Pos[arg:="", client:=false] {
		get {
			static RECT
			if !VarSetCapacity(RECT)
				VarSetCapacity(RECT, 16, 0)
			DllCall(client ? "GetClientRect" : "GetWindowRect", "Ptr", this.Handle, "Ptr", &RECT)
				w := NumGet(RECT,  8, "Int") - x := NumGet(RECT,  0, "Int")
				h := NumGet(RECT, 12, "Int") - y := NumGet(RECT,  4, "Int")

			return ((StrLen(arg:=Trim(arg, " `t`r`n"))==1) && InStr("XYWH", arg)) ? %arg% : { X:x, Y:y, W:w, H:h }
		}
	}

	ClientPos[arg:=""] {
		get {
			return this.Pos[arg, true]
		}
	}
}

GWnd_Get(h)
{
	if ( pThis := GuiWnd.Windows[h + 0] )
	&& ( NumGet(pThis+0) == NumGet(&(o := {})) ) ; make sure it's an object pointer
		return Object(pThis)
}

GWnd_OnClose(h)
{
	return GuiWnd._OnEvent.Call(GWnd_Get(h), "OnClose")
}

GWnd_OnEscape(h)
{
	return GuiWnd._OnEvent.Call(GWnd_Get(h), "OnEscape")
}

GWnd_OnSize(h, args*)
{
	return GuiWnd._OnEvent.Call(GWnd_Get(h), "OnSize", args*)
}

GWnd_OnContextMenu(h, args*)
{
	return GuiWnd._OnEvent.Call(GWnd_Get(h), "OnContextMenu", args*)
}

GWnd_OnDropFiles(h, args*)
{
	return GuiWnd._OnEvent.Call(GWnd_Get(h), "OnDropFiles", args*)
}