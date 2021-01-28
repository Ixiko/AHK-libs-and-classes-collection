/* 
Library of Lateralus138's window functions, objects, and classes for AutoHotkey.
GuiLib also provides a basic screen/window interface, (API you might say)
for better window/window placement and manipulation. Plans to make this as 
universal as possible. Email: faithnomoread@yahoo.com for help, suggestions,
or possible collaboration.
*/


; Functions
GetControls(title,control:=0,posvar:=0){
	If (control && posvar)
		{
			namenum:=EnumVarName(control)
			ControlGetPos,x,y,w,h,%control%,%title%
			pos:=(posvar == "X")?x
			:(posvar == "Y")?y
			:(posvar == "W")?w
			:(posvar == "H")?h
			:(posvar == "X2")?x+w
			:(posvar == "Y2")?Y+H
			:0
			Globals.SetGlobal(namenum posvar,pos)
			Return pos
		}
	Else If !(control && posvar)
		{
			WinGet,a,ControlList,%title%
			Loop,Parse,a,`n
				{
					namenum:=EnumVarName(A_LoopField)
					If namenum
						{
							ControlGetPos,x,y,w,h,%A_LoopField%,%title%
							Globals.SetGlobal(namenum "X",x)
							Globals.SetGlobal(namenum "Y",y)
							Globals.SetGlobal(namenum "W",w)
							Globals.SetGlobal(namenum "H",h)
							Globals.SetGlobal(namenum "X2",x+w)
							Globals.SetGlobal(namenum "Y2",y+h)				
						}
				}
			Return a
		}
}
EnumVarName(control){
	name:=InStr(control,"msctls_p")?"MP"
	:InStr(control,"Static")?"S"
	:InStr(control,"Button")?"B"
	:InStr(control,"Edit")?"E"
	:InStr(control,"ListBox")?"LB"
	:InStr(control,"msctls_u")?"UD"
	:InStr(control,"ComboBox")?"CB"
	:InStr(control,"ListView")?"LV"
	:InStr(control,"SysTreeView")?"TV"
	:InStr(control,"SysLink")?"L"
	:InStr(control,"msctls_h")?"H"
	:InStr(control,"SysDate")?"TD"
	:InStr(control,"SysMonthCal")?"MC"
	:InStr(control,"msctls_t")?"SL"
	:InStr(control,"msctls_s")?"SB"
	:InStr(control,"327701")?"AX"
	:InStr(control,"SysTabC")?"T"
	:0
	num:=(name == "MP")?SubStr(control,18)
	:(name == "S")?SubStr(control,7)
	:(name == "B")?SubStr(control,7)
	:(name == "E")?SubStr(control,5)
	:(name == "LB")?SubStr(control,8)
	:(name == "UD")?SubStr(control,15)
	:(name == "CB")?SubStr(control,9)
	:(name == "LV")?SubStr(control,14)
	:(name == "TV")?SubStr(control,14)
	:(name == "L")?SubStr(control,8)
	:(name == "H")?SubStr(control,16)
	:(name == "TD")?SubStr(control,18)
	:(name == "MC")?SubStr(control,14)
	:(name == "SL")?SubStr(control,18)
	:(name == "SB")?SubStr(control,19)
	:(name == "AX")?SubStr(control,5)
	:(name == "T")?SubStr(control,16)
	:0
	Return name num
}
MouseOver(xa,ya,xb,yb)
{
	MouseGetPos, px, py
	isOver := px >= xa AND px <= xb AND py >= ya AND py <= yb
	Return isOver
}
ShellExec(path,args:=""){
	DllCall("shell32\ShellExecute"
			, "uint",0,"uint",0
			, "str",path,"str",args
			, "uint",0,"int",1)
}
SetParent(child,parent){
	WinGet,chid,ID, % child
	WinGet,did,ID, % parent
	Return DllCall("SetParent","uint",chid,"uint",did)
}
SetTrans(win,trans){
	win:=WinExist(win)
	Return DllCall("SetLayeredWindowAttributes"
					,"uint",win,"uint",0
					,"uchar",trans,"uint",2)
}
ProcExist(x){
	Return WinExist("ahk_exe " x)
}
TaskList(delim:="|",getArray:=0,sort:=0){
	d := delim
	s := 4096  
	Process, Exist  
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")
	DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)  
	NumPut(1, ti, 0, "UInt")  
	DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")  
	r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)  
	DllCall("CloseHandle", "Ptr", h)  
	hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  
	s := VarSetCapacity(a, s)  
	c := 0  
	DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
	Loop, % r // 4  
	{
	   id := NumGet(a, A_Index * 4, "UInt")
	   h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")
	   if !h
		  continue
	   VarSetCapacity(n, s, 0)  
	   e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	   if !e    
		  if e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
			{
				 SplitPath, n, n
			}
	   DllCall("CloseHandle", "Ptr", h)  
	   if (n && e)  
		  l .= n . d, c++
	}
	DllCall("FreeLibrary", "Ptr", hModule)  
	l:=SubStr(l,1,StrLen(l)-1) " " ndir
	If getArray
		{
			proc:=!proc?Object():""
			Loop, Parse, l, |
				proc.Push(A_LoopField)
		}
	If sort
		Sort, l, D%delim%
	Return getArray?proc:l
}

;; Additional functions for tasklister
TT_FADE(state,inc:=8,max:=255,win:="ahk_class tooltips_class32",min:=0){
	c:=InStr(state,"in")?-1
	:InStr(state,"out")?255
	:0
	If (!c || !inc || !max || !WinExist(win)) 
		Return 0
	Loop
		{
			Sleep, 1
			SetTrans(win,c)
			If InStr(state,"in")
				{
					If (c >= max)
						Break
					c+=inc
				}
			Else
				{
					If (c <= -1 && win == "ahk_class tooltips_class32")
						{
							ToolTip
							Break
						}
					If (c <= -1 && win != "ahk_class tooltips_class32")
						{
							SetTrans(win,0)
							If !min
								WinClose, % "ahk_id " WinExist(win)
							Else
								{
									WinMinimize, % "ahk_id " WinExist(win)
									SetTrans(win,255)
									WinShow, % "ahk_id " WinExist(win)
								}
							Break
						}
					c-=inc				
				}
		}
	WinActivate, ahk_class Shell_TrayWnd
	Return 1
}

CloseButton(x,y,lcolor,dcolor,small:=False){
	small:=small?3:4
	big:=small*3
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% x%x% y%y% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp-%big% xp+%big% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp-%small% x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp+%big% xp-%small% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% y+0 x+0 w%small% h%small%, 100
}
MinButton(x,y,lcolor,dcolor,small:=False){
	small:=small?3:4
	big:=small*3
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% x%x% y%y% w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
	Gui, Add, Progress, Background0x%lcolor% c0x%dcolor% yp x+0 w%small% h%small%, 100
}
Spaces(a:=1){
	a:=InStr(a,"tab")?4:a
	Loop, % a
		b.=A_Space
	Return b
}
WM_LBUTTONDOWN(){
	Global
	Local over
	GetControls("Task Lister")
	over:=MouseOver(MP2X,MP7Y,MP7X2,MP2Y2)?7
	:MouseOver(MP7X,MP7Y,MP15X2,MP15Y2)?1
	:MouseOver(S3X,S3Y,S3X2,S3Y2)?6
	:MouseOver(S2X,S2Y,S2X2,S2Y2)?5
	:(MouseOver(S1X,S1Y,S1X2,S1Y2) || MouseOver(MP16X,MP16Y,MP16X2,MP16Y2))?4
	:MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)?3
	:MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)?2
	:MouseOver(MP19X,MP19Y,MP19X2,MP19Y2)?8
	:MouseOver(MP20X,MP20Y,MP20X2,MP20Y2)?9
	:0
	If (over == 8)
		SetTimer, RestartExplorer, -500
	If (over == 9)
		SetTimer, FileOpen, -500
	If (over == 7)
		{
			Gui, Flash
			TT_FADE("Out",,,"ahk_exe Task Lister.exe",1)
		}
	If (over == 1)
		{
			TT_FADE("Out",4,,"ahk_exe Task Lister.exe",1)
			Gosub, GuiClose
		}
	If (over == 6){
			MouseMove,%S2X%,%S2Y2%
			loop, 13
				ToggleSystemCursor(A_Index,true)
			Menu, HelpMenu, Show
		}
	If (over == 5){
			MouseMove,%S2X%,%S2Y2%
			loop, 13
				ToggleSystemCursor(A_Index,true)
			Menu, MainMenu, Show
		}
	If (over == 4)
		PostMessage, 0xA1, 2,,, ahk_id %this_id%
	If (over == 3)
		Gosub, ButtonKillSelectedTask
	If (over == 2)
		Gosub, Open
}
ControlDoubleClick(ctrl,win,bttn:="Left",x:=1,y:=1){
    id:=WinExist(win)?WinExist(win):0
	If bttn IN Left,left,l,L
		a.="0x201",b.="0x202",c.="0x203"
	If bttn IN Right,right,r,R
		a.="0x204",b.="0x205",c.="0x206"
	If bttn IN Middle,middle,m,M
		a.="0x207",b.="0x208",c.="0x209"
    If !(id && a && b && c)
        Return 0
    lParam:=x & 0xFFFF | (y & 0xFFFF) << 16
	WinActivate,ahk_id %id%
	PostMessage,%a%,1,%lParam%,%ctrl%,ahk_id %id%
	PostMessage,%b%, ,%lParam%,%ctrl%,ahk_id %id%
    PostMessage,%c%,1,%lParam%,%ctrl%,ahk_id %id%
    Return id
}
ToggleSystemCursor( p_id, p_hide=false )
{
	/*
	OCR_NORMAL		IDC_ARROW		32512	1
	OCR_IBEAM		IDC_IBEAM		32513	2
	OCR_WAIT		IDC_WAIT		32514	3
	OCR_CROSS		IDC_CROSS		32515	4
	OCR_UP			IDC_UPARROW		32516	5
	OCR_SIZENWSE	IDC_SIZENWSE	32642	6
	OCR_SIZENESW	IDC_SIZENESW	32643	7
	OCR_SIZEWE		IDC_SIZEWE		32644	8
	OCR_SIZENS		IDC_SIZENS		32645	9
	OCR_SIZEALL		IDC_SIZEALL		32646	10
	OCR_NO			IDC_NO			32648	11
	OCR_HAND		IDC_HAND		32649	12
	OCR_APPSTARTING	IDC_APPSTARTING	32650	13
	*/
	
	static	system_cursor_list
	
	if system_cursor_list=
		system_cursor_list = |1:32512|2:32513|3:32514|4:32515|5:32516|6:32642|7:32643|8:32644|9:32645|10:32646|11:32648|12:32649|13:32650|
	
	ix := InStr( system_cursor_list, "|" p_id )
	ix := InStr( system_cursor_list, ":", false, ix )+1
	
	StringMid, id, system_cursor_list, ix, 5
	
	ix_b := ix+6
	ix_e := InStr( system_cursor_list, "|", false, ix )-1
	
	SysGet, cursor_w, 13
	SysGet, cursor_h, 14
	
	if ( cursor_w != 32 or cursor_h != 32 )
	{
		MsgBox, System parameters not supported!
		return
	}
	
	if ( p_hide )
	{
		if ( ix_b < ix_e )
			return

		h_cursor := DllCall( "LoadCursor", "uint", 0, "uint", id )
		
		h_cursor := DllCall( "CopyImage", "uint", h_cursor, "uint", 2, "int", 0, "int", 0, "uint", 0 )
		
		StringReplace, system_cursor_list, system_cursor_list, |%p_id%:%id%, |%p_id%:%id%`,%h_cursor%
		
		VarSetCapacity( AndMask, 32*4, 0xFF )
		VarSetCapacity( XorMask, 32*4, 0 )
		
		h_cursor := DllCall( "CreateCursor"
								, "uint", 0
								, "int", 0
								, "int", 0
								, "int", cursor_w
								, "int", cursor_h
								, "uint", &AndMask
								, "uint", &XorMask )
	}
	else
	{
		if ( ix_b > ix_e )
			return

		StringMid, h_cursor, system_cursor_list, ix_b, ix_e-ix_b+1
		
		StringReplace, system_cursor_list, system_cursor_list, |%p_id%:%id%`,%h_cursor%, |%p_id%:%id% 
	}
	
	result := DllCall( "SetSystemCursor", "uint", h_cursor, "uint", id )
}
ControlClick(ctrl,win,bttn:="Left",x:=1,y:=1){
    id:=WinExist(win)?WinExist(win):0
	If bttn IN Left,left,l,L
		a.="0x201",b.="0x202"
	If bttn IN Right,right,r,R
		a.="0x204",b.="0x205"
	If bttn IN Middle,middle,m,M
		a.="0x207",b.="0x208"
    If !(id && a && b)
		Return 0
    lParam:=x & 0xFFFF | (y & 0xFFFF) << 16
	WinActivate,ahk_id %id%
    PostMessage,%a%,1,%lParam%,%ctrl%,ahk_id %id%
    PostMessage,%b%,0,%lParam%,%ctrl%,ahk_id %id%
    Return id
}
WM_MOUSEHOVER(){
	Global
	Local over
	loop, 13
		ToggleSystemCursor(A_Index)
	SetTimer, RefreshList, Off
	GetControls("Task Lister")
	over:=MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)?1
	:MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)?2
	:MouseOver(MP19X,MP19Y,MP19X2,MP19Y2)?4
	:MouseOver(CB1X,CB1Y,CB1X2,CB1Y2)?3
	:MouseOver(MP20X,MP20Y,MP20X2,MP20Y2)?5
	:0
	If (over == 1){
		SetTimer,TT_OVER_1,-1250
	}
	If (over == 2){
		SetTimer,TT_OVER_2,-1250
	}
	If (over == 4){
		SetTimer,TT_OVER_3,-1250
	}
	If (over == 5){
		SetTimer,TT_OVER_4,-1250
	}		
	If (over != 3)
		ControlSend, ComboBox1,{Right}, ahk_id %this_id%
	If !over {	
		DllCall( "TrackMouseEvent","uint",&tme )
		ToolTip
	}
	SetTimer, RefreshList, 150
}
TT_OVER_1(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP17X,MP17Y,MP17X2,MP17Y2)
						{
							ToolTip % "Alt+K"
							SetTimer, TT_FADE_OUT_SLOW, -3000
							; Sleep, 3000
							; ToolTip
						}		
				}
		}
}
TT_OVER_2(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP18X,MP18Y,MP18X2,MP18Y2)
						{
							ToolTip % "Alt+O"
							SetTimer, TT_FADE_OUT_SLOW, -3000
							; Sleep, 3000
							; ToolTip
						}
				}
		}
}
TT_OVER_3(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP19X,MP19Y,MP19X2,MP19Y2)
						{
							ToolTip % "Alt+R"
							SetTimer, TT_FADE_OUT_SLOW, -3000
							; Sleep, 3000
							; ToolTip
						}
				}
		}
}
TT_OVER_4(){
	Global
	If !WinExist("ahk_class tooltips_class32")
		{
			Static c:=0
			GetControls("Task Lister")
			If Mod(++c,2)
				{
					If MouseOver(MP20X,MP20Y,MP20X2,MP20Y2)
						{
							ToolTip % "Alt+U"
							SetTimer, TT_FADE_OUT_SLOW, -3000
							; Sleep, 3000
							; ToolTip
						}
				}
		}
}
WM_SHOWWINDOW(){
	Global
	Local over
	GetControls("Task Lister")
	over:=MouseOver(CB1X,CB1Y,CB1X2,CB1Y2)?1:0
	If (over != 1)
		ControlSend, ComboBox1,{Right}, ahk_id %this_id%
	DllCall( "TrackMouseEvent","uint",&tme )
}
WM_MOUSELEAVE(){
	ToolTip
}
Button(bc,fc,w,txt,title,txtc:="Black",txts:=9,txtw:=500,font:="Segoe UI"){
	ns:=InStr(txt,"`n")
	h:=!ns?txts*3:txts*4
	vc:=!ns?200:0
	Gui, Font, c%txtc% s%txts% w%txtw%, % font
	Gui, Add, Progress, Background%bc% c%fc% w%w% h%h%, 100
	Gui, Add, Text, xp yp w%w% h%h% 0x%vc% +Center +BackgroundTrans,	%	txt
}
MenuItem(txt,w:=40,h:=20,first:=0){
	xpos:=first?"p":"+0"
	Gui, Add, Text, w%w% h%h% x%xpos% yp +BackgroundTrans +Center 0x200, % txt
}
; Classes
Class Globals { ; my favorite way to set and retrive global tions. Good for
	SetGlobal(name,value=""){ ; setting globals from other tions
		Global
		%name%:=value
		Return
	}
	GetGlobal(name){	
		Global
		Local var:=%name%
		Return var
	}
}
; Main window class, syntax E.g.: 
; windowXPos:=window._x("Window Title") or MsgBox % window._w("ahk_class Shell_TrayWnd")
; or any other way a function or expression can be called/ran/stored. 
Class window {
	_x(title){ 						; Get a windows upper left x position relative to the desktop. This applies 
		WinGetPos,x,,,, %title% 	; to next 3 functions; y, width, and height respectively.
		Return x						; title - can be anything that can be passed to WinGetPos
	}									; E.g.: Window Title, ahk_class Shell_TrayWnd, etc...
	_y(title){
		WinGetPos,,y,,, %title%
		Return y
	}
	_w(title){
		WinGetPos,,,w,, %title%
		Return w
	}
	_h(title){
		WinGetPos,,,,h, %title%
		Return h
	}
	_halfw(title){ 				; Get the half width of a window to use in conjunction with screen._cx()
		WinGetPos,,,w,, %title% 	; to perfectly center a window in the desktop. Formula for a windows
		Return w/2 					; center X pos be WindowX:=screen._cx() - window._halfw("Window Title")
	}
	_halfh(title){
		WinGetPos,,,,h, %title%
		Return h/2
	}
	; Window controls class, syntax E.g.:
	; controlXpos:=window.controls._x("Static1","Window Title") 
	; or MsgBox % window.controls._x2("msctls_progress322","Window Title")
	Class controls {
		_x(control,title){ 								; Get a controls X position relative to the desktop.
			ControlGetPos,x,,,,% control,% title		; This applies to the next 5 functions for y, Width,
			Return x										; Height, x2 position (x+w) and y2 for MouseOver 
		}													; function.
		_y(control,title){
			ControlGetPos,,y,,,% control,% title
			Return y
		}
		_w(control,title){
			ControlGetPos,,,w,,% control,% title
			Return w
		}
		_h(control,title){
			ControlGetPos,,,,h,% control,% title
			Return h
		}
		_x2(control,title){
			ControlGetPos,x,,w,,% control,% title
			Return x+w
		}
		_y2(control,title){
			ControlGetPos,,y,,h,% control,% title
			Return y+h
		}
	}
}
; Get the desktops width and height, syntax E.g.:
; screenWidth:=screen._w() or MsgBox % screen._h() 
Class screen {
	_w(){
		SysGet,w,16
		Return w
	}
	_h(){				; 17 gets the hieght minus the taskbar.
		SysGet,h,17	; using _hbar() for full height.
		Return h
	}
	_hbar(){			; 79 gets height plus the taskbar.
		SysGet,h,79
		Return h	
	}
	_cx(){ 						; Screen center X
		Return (screen._w()/2)		
	}
	_cy(){						; Screen center y minus taskbar
		Return (screen._h()/2)		
	}
	_cybar(){						; Screen center y plus taskbar
		Return (screen._hbar()/2)		
	}
}
