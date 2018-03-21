/* Title:   DockA
			Dock AHK windows.

			Using dock module you can glue windows to an AHK window.
			Docked windows are called Clients and the window that keeps their  position relative to itself is called the Host. 
			Once Clients are connected to the Host, this group of windows will behave like single window - moving, sizing, focusing, hiding and other
			OS events will be handled by the module so that the "composite window" behaves like the single window.

			This module is version of Dock module that supports only AHK hosts (hence A in the name).
			Unlike Dock module, it doesn't uses system hook to monitor windows changes.
*/

/*
	Function:  DockA
 
 	Parameters: 
			HHost	  - Hwnd of the host GUI. This window must be AHK window.
            HClient	  - HWND of the Client GUI. This window can be any window.
            DockDef   - Dock definition, see bellow. To remove dock client pass "-". 
						If you pass empty string, client will be docked to the host according to its current position relative to the host. 

	Dock definition:  
			Dock definition is white space separated combination of parameters which describe Client's position relative to the Host.
			Parameters are grouped into 4 classes - x, y, w & h parameters. Classes and their parameters are optional.
			
 > 		Syntax:		x(hw,cw,dx)  y(hh,ch,dy)  w(hw,dw)  h(hh,dh)


            o The *X* coordinate of the top, left corner of the client window is computed as 
            > x(hw,cw,dx) = HostX + hw*HostWidth + cw*ClientWidth + dx
            o The *Y* coordinate of the top, left corner of the client window is computed as 
            > y(hh,ch,dy) = HostY + hh*HostHeight + ch*ClientHeight + dy
            o The width *W* of the client window is computed as
			> w(hw,dw) = hw*HostWidth + dw
            o The height *H* of the client window is computed as 
			> h(hh,dh) = hh*HostHeight + dh

			If you omit any of the class parameters it will default to 0. So, the following expressions all have the same effect :
 > 		    x(0,0,0) = x(0,0) = x(0,0,) = x(0) = x(0,)= x(0,,) = x() = x(0,,0) = x(,0,0) = x(,,0) = ...
 >			y(0,1,0) = y(0,1) = y(,1) = y(,1,) = y(,1,0) = ...

			Notice that x() is not the same as omitting x entirely. First case is equal to x(0,0,0) so it will set Client's X coordinate to be equal as Host's. 
			In second case, x coordinate of the client will not be affected by the module (client will keep whatever x it has).

	Remarks:
			You can monitor WM_WINDOWPOSCHANGED=0x47 to detect when user move clients (if they are movable) in order to update dock properties
 */
DockA(HHost="", HClient="", DockDef="") {
	DockA_(HHost+0, HClient+0, DockDef, "")
}

DockA_(HHost, HClient, DockDef, Hwnd) {
	static
	
	if HClient && (DockDef != 3)
	{
		If !init 
			init := OnMessage(3, A_ThisFunc) ; WM_MOVE 	;adrSetWindowPos := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), "str", "SetWindowPos")

		HClient += 0, HHost += 0
		if (DockDef="-") 
			if InStr(%HHost%, HClient) {
				StringReplace, %HHost%, %HHost%, %A_Space%%HClient%
				return
			} else return

	   if (DockDef = "") {		;pin
	      WinGetPos hX, hY,,, ahk_id %HHost%
	      WinGetPos cX, cY,,, ahk_id %HClient% 
	      DockDef := "x(0,0," cX - hX ")  y(0,0," cY - hY ")"
	   } 

		%HClient%_x1 := %HClient%_x2 := %HClient%_y1 := %HClient%_y2 := %HClient%_h1 := %HClient%_w1 := %HClient%_x3 := %HClient%_y3 := %HClient%_h2 := %HClient%_w2 := ""
		loop, parse, DockDef, %A_Space%%A_Tab%
		{
			ifEqual, A_LoopField,,continue

			t := A_LoopField, c := SubStr(t,1,1), t := SubStr(t,3,-1)
			StringReplace, t, t,`,,|,UseErrorLevel
			t .= !ErrorLevel ? "||" : (ErrorLevel=1 ? "|" : "")
			loop, parse, t,|,%A_Space%%A_Tab% 
				%HClient%_%c%%A_Index% := A_LoopField ? A_LoopField : 0			
		}
		DllCall("SetWindowLong", "uint", HClient, "int", -8, "uint", hHost)
		return %HHost% .= (%HHost% = "" ? " " : "") HClient " "
	} 
	
	ifEqual, HHost, 0,SetEnv, HHost, %Hwnd%
	ifEqual, %HHost%,,return

	oldDelay := A_WinDelay, oldCritical := A_IsCritical
	SetWinDelay, -1
	critical 100
	
	WinGetPos hX, hY, hW, hH, ahk_id %HHost%
	loop, parse, %HHost%, %A_Space%
	{ 		
		ifEqual, A_LoopField,,continue
		else j := A_LoopField
		WinGetPos cX, cY, cW, cH, ahk_id %j% 
		w := %j%_w1*hW + %j%_w2,  h := %j%_h1*hH + %j%_h2
		, x := hX + %j%_x1*hW + %j%_x2*(w ? w : cW) + %j%_x3
		, y := hY + %j%_y1*hH + %j%_y2*(h ? h : cH) + %j%_y3
		WinMove ahk_id %j%,,x,y, w ? w : "" ,h ? h : ""			;	DllCall(adrSetWindowPos, "uint", hwnd, "uint", 0, "uint", x ? x : cX, "uint", y ? y : cY, "uint", w ? w : cW, "uint", h ? h :cH, "uint", 1044) ;4 | 0x10 | 0x400 
	}
	SetWinDelay, %oldDelay%
	critical %oldCritical%
}

/*
 Group: Presets
		This section contains some common docking setups. You can just copy/paste dock definition strings in your script.

		x(,-1) y()						- top left, own size.
		x(,-1,10) y()					- top left, own size, 10px padding.
		x(,-1)  y() h(1)				- top left, use host's height, keep own width.
		x(,-1,20) y() w(,50) h(1)		- top left, use host's height, set width to 50 and padding to 20px.
		x(,-1)  y(.5,-.5)				- middle left, keep own size.
			
		x(,-1)  y(1,-1) w(,20) h(,20)	- bottom left, fixed width & height to 20px.
		x(,-1)  y(1,-1) h(.5)			- bottom left, keep height half of the Host's height, keep own width.
		x(1,-1) y(1)  w(.25) h(.25)		- bottom right, width and height 1/5 of the Host.
		
		x()	y(1) w(1) h(,100)			- below the host, use host's width, height = 100.
		x()	y(,-1,-5) w(1)   			- above the host, use host's width, keep own height, 5px padding.
		x(.5,-.5) y(,-1) w(,200) h(,30)	- center above the host, width=200, height=30.
		x(.5,-.5) y(1) w(0.3) h(,30)	- center bellow the host, use 1/3 Host's width, height=30.
		
		x(1) y()						- top right, own size.
		x(1) y() w(,40) h(1)			- top right, use host's height, width = 40.
        x(1) y(.5,-.5)					- middle right, keep own size.
 */

/*
 Group: About 
    o Ver 1.0 by majkinetor.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/> 
*/