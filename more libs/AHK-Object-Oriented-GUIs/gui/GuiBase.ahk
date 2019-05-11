
#Include %A_LineFile%\..\IndirectReferenceHolder.ahk
#Include %A_LineFile%\..\Events.ahk

Type(cls) {
	return cls.__Class
}

IsInstance(obj, cls*) {
	base := obj
	Loop {
		for Index, Class in cls
			if (type(base) == type(Class))
				return true
		base := base.base
	} until !base
	return false
}

/*
	maybe indirectreference can handle the "real" reference? when indirref __delete is triggered, just release the only real ref
	
	maybe Controls[] should be put in Properties
*/

Class GuiBase {
	
	static __Author := "RUNIE"
	static __Version := "alpha"
	
	; misc
	#Include %A_LineFile%\..\PositionType.ahk
	#Include %A_LineFile%\..\ImageList.ahk
	
	; controls
	#Include %A_LineFile%\..\controls\ControlType.ahk
	#Include %A_LineFile%\..\controls\ContentControlType.ahk
	#Include %A_LineFile%\..\controls\ChoiceControlType.ahk
	#Include %A_LineFile%\..\controls\Text.ahk
	#Include %A_LineFile%\..\controls\Button.ahk
	#Include %A_LineFile%\..\controls\Edit.ahk
	#Include %A_LineFile%\..\controls\ListView.ahk
	#Include %A_LineFile%\..\controls\DropDownList.ahk
	#Include %A_LineFile%\..\controls\StatusBar.ahk
	
	static Instances := {}
	
	Controls := []
	Properties := {}
	
	__New(Title := "AutoHotkey Window", Options := "", Debug := "") {
		if (type(IndirectReferenceHolder) != "IndirectReferenceHolder")
			throw "Missing dependency: IndirectReferenceHolder"
		
		this.MethodOverrideCheck()
		
		this.Title := Title
		this.Debug := Debug
		
		Gui, New, % "+hwndhwnd " Options, % this.Title
		
		this.hwnd := hwnd
		this.ahk_id := "ahk_id" hwnd
		
		this.DropFilesToggle(false) ; disable drag-drop by default
		this.Position := new GuiBase.WindowPosition(this)
		
		GuiBase.Instances[this.hwnd] := this
		
		this.Init()
		
		this.Print(this.__Class " created")
	}
	
	__Delete() {
		this.Print(this.__Class " released")
	}
	
	Show(Options := "") {
		Gui % this.hwnd ":Show", % Options, % this.TitleValue
	}
	
	Hide(Options := "") {
		Gui % this.hwnd ":Hide", % Options
	}
	
	Destroy() {
		try Gui % this.hwnd ":Destroy"
		
		for Index, Control in this.Controls {
			Control.Gui := ""
			Control.Position := ""
		}
		
		this.Controls := ""
		this.Position := ""
		GuiBase.Instances.Delete(this.hwnd)
	}
	
	Options(Options) {
		Gui % this.hwnd ":" Options
	}
	
	GetControl(hwnd) {
		return this.Controls[hwnd]
	}
	
	SetDefault() {
		if (A_DefaultGui != this.hwnd)
			Gui % this.hwnd ":Default"
	}
	
	SetDefaultListView(ListView) {
		if (A_DefaultListView != ListView.hwnd)
			Gui % this.hwnd ":ListView", % ListView.hwnd
	}
	
	DropFilesToggle(Enable) {
		this.Options((Enable ? "+" : "-") . "E0x10")
	}
	
	GuiControl(Control, Command, ControlParams := "") {
		GuiControl % this.hwnd ":" Command, % Control.hwnd, % ControlParams
	}
	
	ControlGet(Control, Command, Value := "") {
		ControlGet, Output, % Command, % Value,, % "ahk_id" Control.hwnd
		return Output
	}
	
	GuiControlGet(Control, Command, Param := "") {
		GuiControlGet Value, % Command, % Control.hwnd, % Param
		return Value
	}
	
	Margins(x := "", y := "") {
		Gui % this.hwnd ":Margin", % x, % y
	}
	
	Font(Options := "", Font := "") {
		Gui % this.hwnd ":Font", % Options, % Font
	}
	
	Focus() {
		WinActivate % this.ahk_id
	}
	
	Enable() {
		Gui % this.hwnd ":-Disabled"
	}
	
	Disable() {
		Gui % this.hwnd ":+Disabled"
	}
	
	SetIcon(Icon) {
		hIcon := DllCall("LoadImage", UInt,0, Str, Icon, UInt, 1, UInt, 0, UInt, 0, UInt, 0x10)
		SendMessage, 0x80, 0, hIcon ,, % this.ahk_id  ; One affects Title bar and
		SendMessage, 0x80, 1, hIcon ,, % this.ahk_id  ; the other the ALT+TAB menu
	}
	
	
	; ADD CONTROLS
	
	AddText(Options := "", Text := "") {
		return this.AddControl(GuiBase.TextControl, Options, Text)
	}
	
	AddButton(Options := "", Text := "") {
		return this.AddControl(GuiBase.ButtonControl, Options, Text)
	}
	
	AddEdit(Options := "", Text := "") {
		return this.AddControl(GuiBase.EditControl, Options, Text)
	}
	
	AddListView(Options := "", Headers := "") {
		if IsObject(Headers) {
			for Index, Header in Headers
				HeaderText .= "|" Header
			Headers := SubStr(HeaderText, 2)
		}
		return this.AddControl(GuiBase.ListViewControl, Options, Headers)
	}
	
	AddDropDownList(Options := "", Values := "") {
		if IsObject(Values) {
			for Index, Value in Values
				ValueText .= "|" Value
			Values := SubStr(ValueText, 2)
		}
		return this.AddControl(GuiBase.DropDownListControl, Options, Values)
	}
	
	AddStatusBar(Options := "", Text := "") {
		return this.AddControl(GuiBase.StatusBarControl, Options, Text)
	}
	
	AddControl(ControlClass, Options := "", Text := "") {
		Ctrl := new ControlClass(this, Options, Text)
		return this.Controls[Ctrl.hwnd] := Ctrl
	}
	
	; misc
	
	GetControlValues() {
		WinGet, ClassNNList, ControlList, % this.ahk_id
		Loop, Parse, ClassNNList, `n
		{
			ControlGet, hwnd, hwnd,,%A_LoopField%,ahk_id %hWndWindow%
			if (hWnd = hWndControl)
				return A_LoopField
		}
	}
	
	; PROPERTIES
	
	Pos {
		get {
			return this.Position
		}
	}
	
	Visible {
		get {
			DHW := A_DetectHiddenWindows
			DetectHiddenWindows, Off
			exist := WinExist(this.ahk_id)
			DetectHiddenWindows % DHW
			return !!exist
		}
	}
	
	GetTitle() {
		return this.Title
	}
	
	SetTitle(NewTitle) {
		this.Title := NewTitle
	}
	
	Title {
		set {
			WinSetTitle, % this.ahk_id,, % value
			return this.Properties.Title := value
		}
		
		get {
			return this.Properties.Title
		}
	}
	
	; Gui % this.hwnd ":Color", % BackgroundColor, % ControlColor
	
	BackgroundColor {
		set {
			Gui % this.hwnd ":Color", % value
			this.Properties.BackgroundColor := value
		}
		
		get {
			return this.Properties.BackgroundColor
		}
	}
	
	ControlColor {
		set {
			Gui % this.hwnd ":Color",, % value
			this.Properties.ControlColor := value
		}
		
		get {
			return this.Properties.ControlColor
		}
	}
	
	; base
	
	GetGui(hwnd) {
		for Index, Gui in GuiBase.Instances
			if Gui.hwnd = hwnd
				return Gui
	}
	
	Close() {
		this.Destroy()
	}
	
	Escape() {
		this.Close()
	}
	
	; INTERNAL
	
	ControlEvent(Func, hwnd, Param*) {
		if Control := this.Controls[hwnd]
			Func.Call(Control, Param*)
	}
	
	MethodOverrideCheck() {
		Namespace := []
		
		Bases := []
		Bases.Push(base := this.base)
		while (base := base.base)
			Bases.InsertAt(1, base)
		
		for Depth, Obj in Bases {
			for Key in Obj {
				if Namespace.HasKey(Key)
					throw "Class '" type(Obj) "' is overwriting the method '" Key "' from the Gui base class."
				else if (Depth = 1) && !(Key ~= "^(__Class|__Delete|Close|Escape)$")
					Namespace[Key] := ""
			}
		}
	}
	
	Print(Text) {
		this.Debug.Call(text)
	}
}



/*
	
	Tab(num) {
		Gui % this.hwnd ":Tab", % num
	}
	
	ControlGet(Command, Value := "", Control := "") {
		ControlGet, out, % Command, % (StrLen(Value) ? Value : ""), % (StrLen(Control) ? Control : ""), % this.ahk_id
		return out
	}
	
	GuiControlGet(Command := "", Control := "", Param := "") {
		GuiControlGet, out, % (StrLen(Command) ? Command : ""), % (StrLen(Control) ? Control : ""), % (StrLen(Param) ? Param : "")
		return out
	}
	
	
	
	Submit(Hide := false, Options := "") {
		Gui % this.hwnd ":Submit", % (this.IsVisible := !Hide ? "" : "NoHide") " " Options
	}
*/