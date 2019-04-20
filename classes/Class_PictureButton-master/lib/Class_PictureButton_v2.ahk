/*! _Ne0n
    _PictureButton - A simple AHK implementation of Winsock.
    https://github.com/Ne0n-git/Class_PictureButton
    Last updated: January 19, 2011






;NOTES:
	-> DoubleClick by default ignored, see line:290 or(find: "NOTE:DoubleClick") in Class_PictureButton_v2.ahk


FUNCTION LIST:


_PictureButton.add(hwnd,options)
________________________________________

Description: Adding new picture button.
Args:
    hwnd - owner window
    options[] - options object
        x     - position X
        y     - position Y
        w     - width
        h     - height
    	AntiAlias - AntiAlias (default:3)
	   		0 - Default
			1 - HighSpeed
			2 - HighQuality
			3 - None
			4 - AntiAlias
        state - state of the button (default:normal)
        	"normal"
        	"hover"
        	"pressed"
        	"disable"
        btn[] - button object (values can be a bitmap or path to file)
            1 - "normal"
            2 - "hover"
            3 - "pressed"
            3 - "disable"
        on_click - function object (callback, use Func("FunctionName"))

Returns:
    0 - there were problems
        or owner window not exist
        or value "options" is not object
        or value "btn" is not object
    N - positive number, id of created button
----------------------------------------





_PictureButton.del(id,removeBitmap=1)
________________________________________

Description: deleting button.
Args:
    id - id of the button
    removeBitmap - removing a bitmap from resources (default:1)

Returns:
    0 - button not exist
    1 - button succesfully deleted
----------------------------------------





_PictureButton.show(id,state=0)
________________________________________

Description: showing button/s.
Args:
    id - id of the button, or -1 - all button
    state - the state of the button
        1 - normal
        2 - hover
        3 - pressed
        3 - disable

Returns:
    0 - button not exist
    1 - button succesfully deleted
NOTE: function returns all the time 1, if id=-1
----------------------------------------





_PictureButton.enable(id)
________________________________________

Description: enabling button.
Args:
    id - id of the button

Returns:
    0 - button not exist
    1 - button succesfully enabled
----------------------------------------





_PictureButton.disable(id)
________________________________________

Description: disabling button.
Args:
    id - id of the button

Returns:
    0 - button not exist
    1 - button succesfully enabled
----------------------------------------
*/


class _PictureButton {
	static id,buttons,TME
			,hovered,pressed
	__New() {
		this.id:=0,this.buttons:={}
		this.states:={"normal":1,"hover":2,"pressed":3,"disable":4}
	}

	;options[x,y,w,h,state,btn,on_click]
	;btn["normal","hover","pressed","disable"]
	add(hwnd,ByRef opt,ByRef reserved_infuture_text="") { 
		var:=A_DetectHiddenWindows
		DetectHiddenWindows, On ;if window created, but not showed
		if(!WinExist("ahk_id" hwnd) || !isObject(opt) || !isObject(btn:=opt.btn))
			return 0
		DetectHiddenWindows, % var

		Gui,%hwnd%:Default

		id:=++this.id
		,x:=opt.x
		,y:=opt.y
		,w:=opt.w
		,h:=opt.h
		,AntiAlias:=opt.AntiAlias?opt.AntiAlias:3
		,state:=(opt.state?opt.state:(btn[1]?"normal":"disable"))
		state:=this.states[state]
		loop % 4 {
			if(!(value:=btn[i:=A_Index]))
				Continue
			if (isNumber(btn[i])) ;pBitmap
				pBitmap:=btn[i]
			else pBitmap:=Gdip_CreateBitmapFromFile(value)
			if(!w || !h)
				w:=Gdip_GetImageWidth(pBitmap),h:=Gdip_GetImageHeight(pBitmap)
			if(i=1) ;normal
				hN:=pBitmap
			else if(i=2) ;hover
				hH:=pBitmap
			else if(i=3) ;pressed
				hP:=pBitmap
			else if(i=4) ;disable
				hD:=pBitmap
		} xy:=(x?" x" x:"") (y?" y" y:"")" "
		wh:=(w?" w" w:"") (h?" h" h:"")" "


		hbm:=CreateDIBSection(w,h),hdc:=CreateCompatibleDC(),obm:=SelectObject(hdc, hbm)
		DeleteObject(hbm)
		G:=Gdip_GraphicsFromHDC(hdc)

		
		Gdip_SetSmoothingMode(G, AntiAlias) ;AntiAlias
		Gui,Add,Picture, % xy wh " hwndhPic"

		this.buttons[id]:={bitmaps:[hN,hH,hP,hD]
							,hdc:hdc,w:w,h:h,G:G,hwnd:hPic
							,state:state,on_click:opt.on_click}

		;<---TrackMouseEvent--->
		this.SetCapacity("TME",16),NumPut(16,(ptr:=this.GetAddress("TME"))+0,0), NumPut(2, ptr+0, 4), NumPut(hwnd,ptr+0,8)
		;<--------------------->
		return id
	}
	del(id,removeBitmap=1) {
		local obj
		if(!isObject(obj:=this.buttons[id]))
			return 0
		if(removeBitmap)
			for i,pBitmap in obj.bitmaps
				Gdip_DisposeImage(pBitmap)
		DeleteDC(obj.hdc)
		Gdip_DeleteGraphics(obj.G)
		PostMessage, 0x10,,,,% "ahk_id " obj.hwnd ;works,but i have doubts. 0x10 or hides control or deletes it
		;GuiControl, Delete,% obj.hwnd ;TO_EDIT -> not supported
		return 1
	}
	show(id,state=0) {
		local i,obj
		if (id=-1) {
			for id in this.buttons
				this.show(id,state)
			return 1
		} else {
			if(!isObject(obj:=this.buttons[id]))
				return 0
			this.buttons[id].state:=(obj.state=4?4:(state?state:1))
			if(!(bitmap:=obj.bitmaps[(state?state:obj.state)]))
				return 0
			Gdip_DrawImage(obj.G,bitmap, 0,0, obj.w,obj.h)
			BitBlt(GetDC(obj.hwnd), 0,0,obj.w,obj.h, obj.hdc,0,0)
			return 1
		}
	}
	enable(id) {
		if(!isObject(this.buttons[id]))
			return 0
		this.buttons[id].state:=1
		return this.show(id,1)
	}
	disable(id) {
		if(!isObject(this.buttons[id]))
			return 0
		this.buttons[id].state:=4
		if(this.pressed=id)
			this.pressed:=0
		if(this.hovered=id)
			this.hovered:=0
		return this.show(id,4)
	}
















	;<--------------HOOKS-------------->
	MOUSEMOVE(hwnd) {
		local id,obj ;conficts with global variables
		TrackMouseEvent(this.GetAddress("TME"))
		for id,obj in this.buttons {
			if(!hwnd)
				break
			if (hwnd=obj.hwnd && (obj.state!=4 && obj.state!=3)) { ;button and not disabled and not pressed
				this.show(id,2)
				this.hovered:=id
				return
			}
		} if(this.hovered)
			this.show(this.hovered,1),this.hovered:=0
	}

	LBUTTONDOWN(hwnd) {
		local id,obj ;conficts with global variables
		for id,obj in this.buttons {
			if(!hwnd || !this.hovered) 
				break
			if (hwnd=obj.hwnd && obj.state!=4) { ;button and not disabled
				this.show(id,3)
				this.pressed:=id
				return
			}
		} this.pressed:=0 ;works with double click
	}
	LBUTTONUP(hwnd) { ;click
		local id,obj ;conficts with global variables
		for id,obj in this.buttons {
			if (!hwnd) { ;when button was pressed and mouse located on another control
				this.pressed:=0
				break
			}
			if (hwnd=obj.hwnd) { ;this.pressed=id and button
				if (!this.pressed) { ;on DoubleClick ;NOTE:DoubleClick
				; 	this.show(id,3)
				; 	sleep 200
					return
				} else if(this.pressed!=id) ;mouse located on another control
					return this.pressed:=0
				if(isObject(obj.on_click))
					obj.on_click.Call(id,obj.hwnd)
				this.show(id,2) ;shows bitmap "hover" or "normal"
				return this.pressed:=0
			}
		}
		if(this.pressed)
			this.show(this.pressed,this.hovered?2:1),this.pressed:=0
	}
}