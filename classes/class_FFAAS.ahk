; FFAAS.ahk
;==============================================================
; Flicker Free and Anti Shake by szujeq
; v0.9 BETA

; This class prevent from any flicker during user resize window. It also eliminate shaking client area content for example when window is resizing by top border.
; Currently window may blind only twice, when start resizing and/or at end when user hold up mouse
; The only cost for that is little bit slower render (depend on window size) and window frame won't resize instantly after mouse move. If window is very large then laso high CPU load

; It work for any window in current scirpt excluding child window's

; How to use:
; FFAAS.Enable(State)  - Enable/Disable Class. State - If 1 or omitted then enable class, if 0 then disable.
; FFAAS.Exclude(hwnd) - exclude window from being process by this class. hwnd - handle to window
; FFAAS.Include(hwnd) - Include window again to being process. hwnd - handle to window

; DO NOT OVERWRITE FFAAS and _FFAAS variables

; Tested platform:
;	 AutoHotkey v1.1.16.03
;	 *Windows 7 Ultimate x86 - AHK_U32, AHK_ANSI
;	 *Windows 7 Ultimate x64 - AHK_U32, AHK_U64, AHK_ANSI
;	 In any case Aero/Composition was toggled

; Not sure is this will work properly on XP and Win8
;==============================================================
goto _FFAAS_EndScript ; prevent from execute labels in this script when #include is in execute section
Class FFAAS
{
	
	_OnMessage(){
		This.dhwnd := DllCall("GetDesktopWindow")
		WM_SIZE              := 0x0005
		WM_SIZING            := 0x0214
		WM_EXITSIZEMOVE      := 0x0232
		WM_ENTERSIZEMOVE     := 0x231
		WM_WINDOWPOSCHANGING := 0x0046
		WM_NCLBUTTONDOWN     := 0x00A1
		WM_NCCALCSIZE        := 0x0083

		; loop,% 0x038F
		; {
			; OnMessage(A_Index, "__msg")
		; }
		if not This.Active
		{
			OnMessage(WM_WINDOWPOSCHANGING, "")
			OnMessage(WM_SIZING           , "")
			OnMessage(WM_EXITSIZEMOVE     , "")
			OnMessage(WM_ENTERSIZEMOVE    , "")
			OnMessage(WM_NCLBUTTONDOWN    , "")
			OnMessage(WM_NCCALCSIZE       , "")
			return
		}
		if This.IsComp
		{
			OnMessage(WM_NCCALCSIZE       , "")
			OnMessage(WM_WINDOWPOSCHANGING, "FFAAS_WM_WINDOWPOSCHANGING")
			OnMessage(WM_SIZING           , "FFAAS_WM_SIZING")
			OnMessage(WM_EXITSIZEMOVE     , "FFAAS_WM_EXITSIZEMOVE")
			OnMessage(WM_ENTERSIZEMOVE    , "FFAAS_WM_ENTERSIZEMOVE")
			OnMessage(WM_NCLBUTTONDOWN    , "FFAAS_WM_NCLBUTTONDOWN")
			; OnMessage(WM_SIZE             , "__msg")
		}
		else
		{
			OnMessage(WM_WINDOWPOSCHANGING, "FFAAS_WM_WINDOWPOSCHANGING")
			OnMessage(WM_SIZING           , "FFAAS_WM_SIZING")
			OnMessage(WM_EXITSIZEMOVE     , "FFAAS_WM_EXITSIZEMOVE")
			OnMessage(WM_ENTERSIZEMOVE    , "FFAAS_WM_ENTERSIZEMOVE")
			OnMessage(WM_NCLBUTTONDOWN    , "FFAAS_WM_NCLBUTTONDOWN")
			OnMessage(WM_NCCALCSIZE       , "FFAAS_WM_NCCALCSIZE")
			; OnMessage(WM_SIZE             , "__msg")
		}
	}
	
	Include(hwnd){
		This._Exclude[hwnd].Remove(hwnd,"") 
	}
	
	Exclude(hwnd){
		This._Exclude[hwnd] := 0
	}
	
	_CheckComposition()
	{
		This.IsComp := _FFAAS_IsComposition()
		This._OffScreenPos()
		This.SetAero()
		; This.SetAero(0)
		This._OnMessage()
	}
	
	Enable(State=1)
	{
		global _FFAAS
		; _ := FFAAS
		_FFAAS := FFAAS
		this.Active := State
		This._Exclude := {}
		This.ChildList := {}
		This._CheckComposition()
		This.SyncMode()
		
		; This.SyncMode("Manual")
		; global gui8, gui6
		; This.AddChild(gui6)
		; This.AddChild(gui8)
		; tooltip,% DllCall("GetDesktopWindow")
	}
	
	; AddChild(hwnd){
		; This.ChildList[hwnd] := 0
	; }
	
	_OffScreenPos(){
	global _FFAAS
	maxw := _FFAAS_GetSystemMetrics(78) ; SM_CXVIRTUALSCREEN
		if not This.IsComp
			_FFAAS.osx := 0
		else
		{
			; _FFAAS.osx := -1500
			; _FFAAS.osx := -2500
			_FFAAS.osx := -(maxw*5)
		}
	}
	
	SetAero(state=1){
		if not This.IsComp
			This.Aero := 0
		else
			This.Aero := state
	}
	
	SyncMode(Mode="ASync", Timer = 30){
		global _FFAAS
		if (Mode = "ASync")
		{
			_FFAAS.ASync := 1
			_FFAAS.Timer := Timer
		}
		else if (Mode = "Manual")
		{
			_FFAAS.ASync := 0
			_FFAAS.Timer := "Off"
		}
	}
	
	
	
	Redraw(hWnd){
		; if this._ChildList.MaxIndex()          ; Alternative sync mode
		; {                                     
			; this._ChildList.Remove(hwnd,"")   
			; if this._ChildList.MaxIndex()     
				; return                        
		; }                                     
		; if (this.ResizeHWND !="NULL")
		; This.RedrawDB_Aero(this.ResizeHWND)
		This.RedrawDB_Aero(hWnd)
	}
	
	RedrawDB_Aero(hwnd){ ; hwnd to ResizeHWND
	Critical
	global _FFAAS
	
		_FFAAS_GetWindowInfo(hWnd,wx,wy,ww,wh,cx,cy,cw,ch)
		hdcSrc := DllCall("GetWindowDC", "Ptr",hWnd)
		hdcBuf  := DllCall("CreateCompatibleDC", "Ptr",hdcSrc)  ; buffer
		Static bmw, bmh, hbmBuf
		if (ww > bmw) or (wh > bmh) ; Create new bitmap only while new one is bigger ; --> create on entersizemove
		{
			DllCall("DeleteObject", "Ptr",hbmBuf)
			hbmBuf := DllCall("CreateCompatibleBitmap", "Ptr",hdcSrc, "Int",ww, "Int",wh)
			bmw := ww, bmh := wh
		}
		obmBuf  := DllCall("SelectObject", "Ptr",hdcBuf, "Ptr",hbmBuf)
		_FFAAS_WM_SETREDRAW(hwnd,1)
		
		
		if not _FFAAS.IsComp && not This.Aero
		{
			DllCall("RedrawWindow", "Ptr", _FFAAS.dhwnd, "UInt", 0, "UInt", _FFAAS.hrgn, "UInt", 0x585) ; erase old frame from desktop ; hwnd must be to desktop othervise sidebar gadget won't be redraw properly
		}
		
		if This.Aero
		{
			_FFAAS_RedrawWindow(hwnd,0,0,0x585) ; RDW_ERASE|RDW_FRAME|RDW_INVALIDATE|RDW_UPDATENOW|RDW_ALLCHILDREN
			_FFAAS_UpdateLayeredWindow(_FFAAS.hLayer, hdcSrc, wx-_FFAAS.osx, wy, wW, wH)
		}
		else
		{
			DllCall("PrintWindow", "Ptr",hwnd, "Ptr",hdcBuf, "uint",0) ; force redraw NC area (only composition)
			_FFAAS_UpdateLayeredWindow(_FFAAS.hLayer, hdcBuf, wx-_FFAAS.osx, wy, wW, wH)
		}
		
		_FFAAS_DeleteObject(_FFAAS.hrgn)
		_FFAAS_ReleaseDC(hdcSrc)
		DllCall("SelectObject", "Ptr",hdcBuf, "Ptr",obmBuf)
		DllCall("DeleteDC", "Ptr",hdcBuf)
	}

	DuplicateWindow(hwndSrc){
	global _FFAAS
	Static GWL_STYLE   := -16
	Static GWL_EXSTYLE := -20

	Static WM_SETFONT  := 0x0030
	Static WM_GETFONT  := 0x0031

	Static WM_SETICON  := 0x0080
	Static WM_GETICON  := 0x007F

	Static WM_SETTEXT  := 0x000C
	Static WM_GETTEXT  := 0x000D

	Static WS_EX_LAYERED     := 0x00080000
	Static WS_EX_TRANSPARENT := 0x00000020
	static WS_VISIBLE        := 0x10000000
	static WS_EX_TOPMOST     := 0x00000008
	static WS_EX_TOOLWINDOW  := 0x00000080
	CW_USEDEFAULT := 0x80000000
	WS_POPUP := 0x80000000
	WS_CHILD := 0x40000000
		Style   := DllCall("GetWindowLong", "Ptr", hwndSrc, "Int", GWL_STYLE,   "UInt")
		ExStyle := DllCall("GetWindowLong", "Ptr", hwndSrc, "Int", GWL_EXSTYLE, "UInt")
		; maxw := _GetSystemMetrics(78) ; SM_CXVIRTUALSCREEN
		; maxh := _GetSystemMetrics(79) ; SM_CYVIRTUALSCREEN
		; Style   &= ~WS_VISIBLE ; no composition
			; Style   |= WS_POPUP           ; co composition ??
			; Style   &= ~0x00040000           ; co composition ??
		
		
		if This.Aero
		{
			; h := _CreateWindowEx(ExStyle|WS_EX_TOPMOST, "#32770", "", Style, _FFAAS.osx,0, 0,0)
			h := _FFAAS_CreateWindowEx(ExStyle, "#32770", "", Style, _FFAAS.osx,0, 0,0)
			DllCall("ShowWindow", "Ptr", h, "UInt",0)
			ExStyleAdd := WS_EX_LAYERED|WS_EX_TRANSPARENT
			DllCall("SetWindowLong", "Ptr", h, "Int", GWL_EXSTYLE, "UInt", ExStyle|ExStyleAdd) ; from some unknown reason ExStyle (WS_EX_LAYERED|WS_EX_TRANSPARENT) must be set after create otherwise window will lost them frame (aero glass)
			
		}
		else if not This.Aero
		{
			h := _FFAAS_CreateWindowEx(WS_EX_LAYERED, "#32770", "", WS_POPUP, _FFAAS.osx,0, 0,0)  ; no composition
			DllCall("ShowWindow", "Ptr", h, "UInt",0)
		}
		
		_TextLen := 1024, VarSetCapacity(_Text, _TextLen*8, 0)
		_Font := DllCall("SendMessage",  "Ptr", hwndSrc, "Int", WM_GETFONT, "Int", 0, "Int", 0)
		_Icon := DllCall("SendMessage",  "Ptr", hwndSrc, "Int", WM_GETICON, "Int", 0, "Int", 0)
		         DllCall("SendMessage",  "Ptr", hwndSrc, "Int", WM_GETTEXT, "Int", _TextLen-1, "Int", &_Text)
		
		DllCall("SendMessage",  "Ptr", h, "Int", WM_SETFONT, "Int", _Font, "Int", 1)
		DllCall("SendMessage",  "Ptr", h, "Int", WM_SETICON, "Int", 0, "Int", _Icon)
		DllCall("SendMessage",  "Ptr", h, "Int", WM_SETTEXT, "Int", 0, "Int", &_Text)
		
		_FFAAS.hlayer := h
		This.Copy(hwndSrc)
	}
	
	Copy(hwnd){
	global _FFAAS
	Critical
	if not this.IsComp
		return
		_FFAAS_GetWindowInfo(hWnd,wx,wy,ww,wh,cx,cy,cw,ch)
		hdc := DllCall("GetWindowDC", "Ptr",hWnd)
		_FFAAS_UpdateLayeredWindow(_FFAAS.hLayer, hdc, wx, wy, ww, wh) ; Window must be visible othervise it will lock visible rect that is render
		_FFAAS_ReleaseDC(hdc)
	}
}





__msg(wParam, lParam, msg, hwnd)
{
global
critical
; msg := dec2hex(msg)
; hwnd := dec2hex(hwnd)
; wParam := dec2hex(wParam)
; lparam := dec2hex(lParam)
	; msgbox,% _msg[msg]
	; if (hwnd = gui1)
	; if (hwnd = gui8)
	; {
		; _GetWindowInfo(hWnd,wx,wy,ww,wh,cx,cy,cw,ch)
		; _MSGLIST .= gn[hwnd] ": " _msg[msg] " -==- " wx  " x " wy " ___ " ww " x " wh "`n"
	
	; }
	; k := _msg[msg]
	k := "_" _msg[msg]
	r := %k%(wParam, lParam, msg, hwnd)
	; tooltip,% r
	return r
}

FFAAS_WM_NCLBUTTONDOWN(wParam, lParam, msg, hwnd)
{
global _FFAAS
critical
	; Make sure WM_SIZING is generated only by user sizing
	; It prevent from size effect for example when user try to move maximized window
	
	if not ( 10 <= wparam && wparam <=17) ; click on resizable border only
		exit
	_FFAAS.ResizeParent := _FFAAS_GetParent(hWnd)
	if not (_FFAAS.ResizeParent == 0) ; window must be desktop window
		exit
	if _FFAAS._Exclude.HasKey(hwnd)
		exit
		
	_FFAAS.ResizeHWND := hWnd
}

; FFAAS_WM_SIZE(wParam, lParam, msg, hwnd) ; Alternative sync mode
; {
; global _FFAAS
; critical
	; if (hwnd != _FFAAS.ResizeHWND) && _FFAAS.SIZING
	; {
		; if _FFAAS.ChildList.HasKey(hwnd)
		; _FFAAS._ChildList[hwnd] := _FFAAS.ResizeHWND
	; }
; }

FFAAS_WM_ENTERSIZEMOVE(wParam, lParam, msg, hwnd)
{
global _FFAAS
critical
if not (hwnd = _FFAAS.ResizeHWND)
	exit
	; Settingup duplicated window before sizing. Mainly for Aero effect's frame
	; tooltip, enter
	_FFAAS._ChildList := {}
	_FFAAS.SIZEMOVE := 1
	settimer, _redraw, off
	_FFAAS_WM_SETREDRAW(hwnd,1)
	_FFAAS._CheckComposition() ; Allow class to working even if user toggle Composition
	
	; tooltip, duplicate
}

FFAAS_WM_SIZING(wParam, lParam, msg, hwnd)
{
global _FFAAS
critical

	if (hwnd = _FFAAS.ResizeHWND) && _FFAAS.SIZEMOVE
	{
		if not _FFAAS.SIZING
		{
			_FFAAS.DuplicateWindow(hwnd)
			; tooltip,% SetForegroundWindow(_FFAAS.hlayer)
		}
		
		; _FFAAS_WM_SETREDRAW(hwnd,0)
		settimer, _redraw, off
		_FFAAS.SIZING := 1 ; Make Sure window is resizing instead moved
		
		_FFAAS.resizing := 0
	}
}

FFAAS_WM_EXITSIZEMOVE(wParam, lParam, msg, hwnd)
{
global _FFAAS
critical

	if (hwnd = _FFAAS.ResizeHWND) 
	&& _FFAAS.SIZING ; prevent from move window if it was not resized
	{
		settimer, _redraw, off
		
		_FFAAS.ResizeHWND := "NULL"
		_FFAAS.SIZEMOVE   := 0
		_FFAAS.SIZING     := 0
		_FFAAS.VISIBLE    := 0
		_FFAAS_WM_SETREDRAW(hwnd,1)
		if _FFAAS.IsComp
		{
			WinGetpos, x,y,w,h,ahk_id %hwnd%
			WinMove,% "ahk_id" hwnd, , x-_FFAAS.osx ; return main window to oryginal position
			sleep 15
			DllCall("DestroyWindow", "Ptr", _FFAAS.hLayer, "UInt", 0)
		}
		else
		{
			_FFAAS_GetWindowInfo(hWnd,wx,wy,ww,wh,cx,cy,cw,ch)
			HRGN := DllCall("gdi32.dll\CreateRectRgn", "int", wx, "int", wy, "int", wx+ww, "int", wy+wh)
			HRGN1 := DllCall("gdi32.dll\CreateRectRgn", "int", cx, "int", cy, "int", cx+cw, "int", cy+ch)
			DllCall("gdi32.dll\CombineRgn", "Ptr", HRGN1, "Ptr", HRGN, "Ptr", HRGN1, "int", 4) ;RGN_AND=1 RGN_OR=2 RGN_XOR=3 RGN_DIFF=4 RGN_COPY=5
			_FFAAS_RedrawWindow(hwnd,0,0,0x585)
			DllCall("DestroyWindow", "Ptr", _FFAAS.hLayer, "UInt", 0)
			_FFAAS_RedrawWindow(_FFAAS.dhwnd,0,HRGN1,0x585) ; redraw only non client area
			_FFAAS_DeleteObject(HRGN)
			_FFAAS_DeleteObject(HRGN1)
			; hdcd := GetDC(0)
			; DllCall("gdi32.dll\FillRgn", "Ptr", hdcd, "Ptr", HRGN1, "Ptr", _br.red)
		}
	}
}
FFAAS_WM_NCCALCSIZE(wParam, lParam, msg, hwnd)
{
global _FFAAS
critical

	if (hwnd = _FFAAS.ResizeHWND)
	; && not _FFAAS.IsComp
	{
		if _FFAAS.resizing ; WM_NCCALCSIZE is call more than once so it prevent from generate wrong HRGN and other things
			exit
		_FFAAS.resizing := 1
		_FFAAS_WM_SETREDRAW(hwnd,0)
		
		1x1 := numget(lParam+0,0, "int")
		1Y1 := numget(lParam+0,4, "int")
		1x2 := numget(lParam+0,8, "int")
		1Y2 := numget(lParam+0,12, "int")
		1W := 1X2-1X1
		1H := 1Y2-1Y1
		2x1 := numget(lParam+0,16, "int")
		2Y1 := numget(lParam+0,20, "int")
		2x2 := numget(lParam+0,24, "int")
		2Y2 := numget(lParam+0,28, "int")
		2W := 2X2-2X1
		2H := 2Y2-2Y1
		
		_FFAAS_DeleteObject(_FFAAS.HRGN) ; Prevent from memory leak
		HRGN0 := DllCall("gdi32.dll\CreateRectRgn", "int", 2x1, "int", 2y1, "int", 2x2, "int", 2y2)
		HRGN1 := DllCall("gdi32.dll\CreateRectRgn", "int", 1x1, "int", 1y1, "int", 1x2, "int", 1y2)
		DllCall("gdi32.dll\CombineRgn", "Ptr", HRGN1, "Ptr", HRGN0, "Ptr", HRGN1, "int", 4) ;RGN_AND=1 RGN_OR=2 RGN_XOR=3 RGN_DIFF=4 RGN_COPY=5
		
		; HRGN  := DllCall("gdi32.dll\CreateRectRgn", "int", 0, "int", 0, "int", 2222, "int", 2222)    ; just for inspection
		; DllCall("gdi32.dll\FillRgn", "Ptr", lw.wHDC, "Ptr", HRGN, "Ptr", _br.grey)                   ; just for inspection
		; DllCall("gdi32.dll\FillRgn", "Ptr", lw.wHDC, "Ptr", HRGN1, "Ptr", _br.red)                   ; just for inspection
		_FFAAS_DeleteObject(HRGN0)
		_FFAAS.HRGN := HRGN1
	}
	
}

FFAAS_WM_WINDOWPOSCHANGING(wParam, lParam, msg, hwnd)
{
global _FFAAS
Static _x_offset := A_PtrSize*2 ; Support for x64 AHK
critical
	if (hwnd = _FFAAS.ResizeHWND) && _FFAAS.SIZING
	{
		if _FFAAS.VISIBLE && _FFAAS.ASync
			FFAAS.Redraw(_FFAAS.ResizeHWND)
			_FFAAS_WM_SETREDRAW(hwnd,0)
		_x := numget(lParam+0,_x_offset, "int") ; Get oryginal x coord
		numput(_x+_FFAAS.osx,lParam+0,_x_offset, "int")      ; Move main window out of screen
		if NOT _FFAAS.VISIBLE ; Show duplicated window if not yet visible
		{
			DllCall("ShowWindow", "Ptr", _FFAAS.hLayer, "UInt",4)
			_FFAAS.VISIBLE := 1
		}
		if _FFAAS.ASync
			settimer, _redraw,% -_FFAAS.Timer
	}
}

_redraw:
; _MSGLIST .= "ASYNC `n"
; tooltip,% A_TickCount
FFAAS.Redraw(_FFAAS.ResizeHWND)
settimer, _redraw,% 100
return

_FFAAS_CreateWindowEx(ExStyle, ClassName, WindowName, Style, x,y, w,h, hWndParent=0, hMenu=0, hInstance=0, lpParam=0){
	return DllCall( "CreateWindowEx"
	, "UInt", ExStyle
	, "Str" , ClassName
	, "Str" , WindowName
	, "UInt", Style
	, "Int" , x
	, "Int" , y
	, "UInt", w
	, "UInt", h
	, "UInt", hWndParent
	, "Int" , hMenu
	, "Int" , hInstance
	, "Int" , lpParam )
}

_FFAAS_UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255, flag=4)
{
critical
Static Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if ((x != "") && (y != ""))
		VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")

	if (w = "") ||(h = "")
		WinGetPos,,, w, h, ahk_id %hwnd%
   
	return DllCall("UpdateLayeredWindow"
	, Ptr,       hwnd                               ; HWND          hwnd
	, Ptr,       0                                  ; HDC           hdcDst
	, Ptr,       ((x = "") && (y = "")) ? 0 : &pt   ; POINT         *pptDst
	, "int64*",  w|h<<32                            ; SIZE          *psize
	, Ptr,       hdc                                ; HDC           hdcSrc
	, "int64*",  0                                  ; POINT         *pptSrc
	, "uint",    0                                  ; COLORREF      crKey
	, "UInt*",   Alpha<<16|1<<24                    ; BLENDFUNCTION *pblend
	, "uint",    flag)                              ; DWORD         dwFlags
}

_FFAAS_GetWindowInfo(hwnd,ByRef wx,ByRef wy,ByRef ww,ByRef wh,ByRef cx,ByRef cy,ByRef cw,ByRef ch){
Static SizeOfWINDOWINFO := 60
	VarSetCapacity(WINDOWINFO, SizeOfWINDOWINFO, 0)
	NumPut(SizeOfWINDOWINFO, WINDOWINFO, "UInt")
	DllCall("GetWindowInfo", "Ptr",hWnd, "Ptr",&WINDOWINFO)
	
	WX := NumGet(WINDOWINFO,  4, "Int")       ; X coordinate of the window
	WY := NumGet(WINDOWINFO,  8, "Int")       ; Y coordinate of the window
	WW := NumGet(WINDOWINFO, 12, "Int") - WX  ; Width of the window
	WH := NumGet(WINDOWINFO, 16, "Int") - WY  ; Height of the window
	CX := NumGet(WINDOWINFO, 20, "Int")       ; X coordinate of the client area
	CY := NumGet(WINDOWINFO, 24, "Int")       ; Y coordinate of the client area
	CW := NumGet(WINDOWINFO, 28, "Int") - CX  ; Width of the client area
	CH := NumGet(WINDOWINFO, 32, "Int") - CY  ; Height of the client area
}

_FFAAS_RedrawWindow(hWnd, lprcUpdate=0, hrgnUpdate=0, flags=0x101) {
; f := 0
; f |= RDW_ERASE:=0x4
; f |= RDW_FRAME:=0x400
; f |= RDW_INTERNALPAINT:=0x2
; f |= RDW_INVALIDATE:=0x1

; f |= RDW_NOERASE:=0x20
; f |= RDW_NOFRAME:=0x800
; f |= RDW_NOINTERNALPAINT:=0x10
; f |= RDW_VALIDATE:=0x8

; f |= RDW_ERASENOW:=0x200
; f |= RDW_UPDATENOW:=0x100

; f |= RDW_ALLCHILDREN:=0x80
; f |= RDW_NOCHILDREN:=0x40

; flags := RDW_ERASE  | RDW_UPDATENOW
return DllCall("RedrawWindow"
	, "Ptr", hWnd			; A handle to the window to be redrawn. If this parameter is NULL, the desktop window is updated.
	, "UInt", lprcUpdate	; A pointer to a RECT structure containing the coordinates, in device units, of the update rectangle. This parameter is ignored if the hrgnUpdate parameter identifies a region.
	, "UInt", hrgnUpdate	; A handle to the update region. If both the hrgnUpdate and lprcUpdate parameters are NULL, the entire client area is added to the update region.
	, "UInt", flags)		; One or more redraw flags. This parameter can be used to invalidate or validate a window, control repainting, and control which windows are affected by RedrawWindow.
}

_FFAAS_GetSystemMetrics(Index){
	return DllCall("GetSystemMetrics", "Int",Index)
}

_FFAAS_IsComposition(){
	hr := DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", Composition)
	if Composition and (hr==0)
		return 1
	Else
		return 0
}

_FFAAS_WM_SETREDRAW(hWnd, state=1){
	return DllCall("SendMessage", "Ptr",hWnd, "UInt",0xB, "UInt",state, "UInt",0)
; Return value
; An application returns zero if it processes this message.
}

_FFAAS_ReleaseDC(hdc, hwnd=0){
Static Ptr := A_PtrSize ? "UPtr" : "UInt"
	return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}

_FFAAS_GetParent(hWnd){
	return DllCall("GetParent", "Ptr", hWnd)
}

_FFAAS_DeleteObject(hObject){
Static Ptr := A_PtrSize ? "UPtr" : "UInt"
   return DllCall("DeleteObject", Ptr, hObject)
}

_FFAAS_BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster=""){
	return DllCall("gdi32\BitBlt", "Ptr", dDC, "int", dx, "int", dy, "int", dw, "int", dh
	, "Ptr", sDC, "int", sx, "int", sy, "uint", Raster ? Raster : 0x00CC0020)
}
_FFAAS_EndScript: