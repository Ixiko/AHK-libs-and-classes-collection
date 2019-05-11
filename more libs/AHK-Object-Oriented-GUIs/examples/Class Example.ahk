#SingleInstance force
#NoEnv
SetBatchLines -1
#Include Debug.ahk
Debug.Clear()

#Include ..\gui\GuiBase.ahk

global MyGui := new TestGui("test gui", "+Resize +Border -MinimizeBox", func("p"))

MyGui.Show()

Exit() {
	MyGui.Destroy()
	MyGui := ""
	ExitApp
}

Class TestGui extends GuiBase {
	Init() {
		this.DDL := this.AddDropDownList("w200 AltSubmit", ["first", "second", "third"]).OnEvent(this.DDLEvent.Bind(this))
		
		this.DDL.ChooseString("second")
		
		this.AddButton("w200", "click to change title").OnEvent(this.ChangeTitle.Bind(this))
		this.AddButton("w200", "click to make window 500x500").OnEvent(this.500Window.Bind(this))
		this.AddButton("w200", "click to center window").OnEvent(this.CenterWindow.Bind(this))
		this.AddButton("w200", "click to print the size of this button").OnEvent(this.ButtonSizeClick.Bind(this))
		this.AddButton("w200", "click to destroy and free references").OnEvent(Func("Exit"))
		this.AddEdit("w200", "blah").OnEvent(this.EditEvent.Bind(this))
		
		this.LV := this.AddListView("w200", ["Event", "Row"]).OnEvent(this.ListViewEvent.Bind(this))
		
		this.SB := this.AddStatusBar()
		this.SB.SetText("Statusbar text", 2)
		
		this.removeTooltipFn := this.RemoveTooltip.Bind(this)
	}
	
	EditEvent(Control, Event, a){
		this.ToolTip("Edit Contents: " Control.GetText())
	}

	DDLEvent(Control, Event, a) {
		this.ToolTip("DDL Selected: " Control.ControlGet())
		p(Event, asdf)
	}
	
	ChangeTitle() {
		InputBox, NewTitle
		this.Title := NewTitle
	}
	
	ListViewEvent(Control, Event, Row) {
		Control.Insert(1,, Event, Row)
		Loop 2
			Control.ModifyCol(A_Index, "AutoHDR")
	}
	
	500Window() {
		this.Pos.W := 500
		this.Pos.H := 500
	}
	
	CenterWindow() {
		this.Pos.X := A_ScreenWidth / 2 - this.Pos.W / 2
		this.Pos.Y := A_ScreenHeight / 2 - this.Pos.H / 2
	}
	
	ButtonSizeClick(Control, junk*) {
		m(Control.Position)
	}
	
	Size(EventInfo, Width, Height) {
		this.SB.SetParts(Width / 2, Width / 2)
		this.SB.SetText(EventInfo ", " Width ", " Height, 1)
		
		this.LV.Pos.H := Height - 190
		
		; change width of all buttons
		for Index, Control in this.Controls
			if IsInstance(Control, GuiBase.ButtonControl, GuiBase.ListViewControl, GuiBase.DropDownListControl)
				Control.Pos.W := Width - 20
	}
	
	Escape() {
		this.Close()
	}
	
	Close() {
		Exit()
	}
	
	Tooltip(text){
		ToolTip, % text
		fn := this.removeTooltipFn
		SetTimer, % fn, -1000
	}
	
	RemoveTooltip(){
		ToolTip
	}
}

rc(ptr) {
	count := ObjAddRef(ptr)
	ObjRelease(ptr)
	msgbox % count - 1
}

/*
	; small functional example
	
	global g := new GuiBase("title",, func("p"))
	g.AddButton("w200", "Button!").OnEvent(Func("OnButtonClick"))
	g.Show()
	return
	
	OnButtonClick(Control, Info*) {
		m("Control of type " Control.Type " and hwnd " Control.hwnd " was clicked in Gui with hwnd " Control.Gui.hwnd ".`n`nEvent params:", Info)
	}
*/
#Include ..\gui\controls\DropDownList.ahk
#Include ..\gui\controls\ChoiceControlType.ahk