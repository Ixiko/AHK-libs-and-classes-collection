class _PictureButton {
	static id,buttons,TME
			,hovered,pressed
	__New() {
		this.id:=0,this.buttons:={}
	}
	add(hwnd,ByRef opt,ByRef text="") { ;text in future
		var:=A_DetectHiddenWindows
		DetectHiddenWindows, On
		if(!WinExist("ahk_id" hwnd) || !isObject(opt))
			return 0
		DetectHiddenWindows, % var
		if(!isObject(btn:=opt.btn))
			return 0

		Gui,%hwnd%:Default

		id:=++this.id
		,x:=opt.x?opt.x:0
		,y:=opt.y?opt.y:0
		,w:=opt.w
		,h:=opt.h
		,state:=(opt.state?opt.state:(btn[1]?"normal":"disable"))
		;btn:=["normal","hover","pressed","disable"]
		wh:=(w?" w" w?:"") (h?"w" h?:"")" "
		if(btn[4]) ;disable
			Gui,Add,Picture, % "x" x " y" y wh " hwndhD Hidden" (state="disable"?0:1),% btn[4]
		if(btn[1]) ;normal
			Gui,Add,Picture, % "x" x " y" y wh " hwndhN Hidden" (state="normal"?0:1),% btn[1]
		if(btn[2]) ;hover
			Gui,Add,Picture, % "x" x " y" y wh " hwndhH Hidden1",% btn[2]
		if(btn[3]) ;pressed
			Gui,Add,Picture, % "x" x " y" y wh " hwndhP Hidden1",% btn[3]
		this.buttons[id]:={1:hN,2:hH,3:hP,4:hD,state:state,on_click:opt.on_click}
		this.SetCapacity("TME",16),NumPut(16,(ptr:=this.GetAddress("TME"))+0,0), NumPut(2, ptr+0, 4), NumPut(hwnd,ptr+0,8)
		return id
	}
	enable(id) {
		if(!isObject(this.buttons[id]))
			return 0
		this.buttons[id].state:="enabled"
		GuiControl, Show, % this.buttons[id][1]
		GuiControl, Hide, % this.buttons[id][4]
	}
	disable(id) {
		if(!isObject(this.buttons[id]))
			return 0
		this.buttons[id].state:="disabled"
		GuiControl, Hide, % this.buttons[id][1]
		GuiControl, Show, % this.buttons[id][4]
	}
	del(id) {

	}
	MOUSEMOVE(hwnd) {
		TrackMouseEvent(this.GetAddress("TME"))
		for id,btn in this.buttons {
			if(!hwnd)
				break
			if ((hwnd=btn[1] || hwnd=btn[2]) && btn.state!="disabled") { ;normal or hover and not disabled
				GuiControl, % (hwnd=btn[1] || hwnd=btn[2]) ? "Show" : "Hide", % btn[2]
				this.hovered:=id
				return
			}
		} if(this.hovered)
			GuiControl, Hide, % this.buttons[this.hovered][2]
	}

	LBUTTONDOWN(hwnd) {
		if(!hwnd)
			return
		for id,btn in this.buttons {
			if (hwnd=(btn[2]?btn[2]:btn[1]) && btn.state!="disabled") { ;hovered or normal and not disabled
				GuiControl, % (btn[2]?btn[2]:btn[1]) ? "Show" : "Hide", % btn[3]
				this.pressed:=id
			}
		}
	}
	LBUTTONUP(hwnd) { ;click
		if (!hwnd) {
			if(this.pressed)
				GuiControl, Hide, % this.buttons[this.pressed][3]
			return
		} for id,btn in this.buttons { ;next condition works with double click, if u don't need it, replace with if(hwnd=(btn[3]?btn[3]:(btn[2]?btn[2]:btn[1])))
			if (this.pressed && hwnd=btn[3] || hwnd=btn[2] || hwnd=btn[1]) { ;this.pressed and (pressed or hover or normal)   ;very difficulty condition :0
				if(isObject(btn.on_click))
					btn.on_click.Call()
				GuiControl, % "Hide", % btn[3]
			}
		} 
	}
}
