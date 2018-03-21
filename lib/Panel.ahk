/* Title:	Panel
			Control container.
*/

/*	
 Function:	Add
			Adds new panel.
 
 Parameters:
			HParent		- Handle of the parent.
			X..H		- Placement.
			Style		- White space separated list of panel styles. Additionally, any integer style can be specified among other styles. See <SetStyle> for details.
			Text		- Text to display.

 Returns:
		    Handle of the control or error messge if control couldn't be created.

 Remarks:
			If you <Attach> Panel control to its parent, Panel will disable Attach for itself when it becomes explicitelly hidden and enable itself when you show it latter.
			When Panel doesn't attach, its parent will skip it when performing repositioning of the controls. If Panel itself is attaching its own children, 
			this means that it will also stop attaching them as its own size wont change. However, its children won't be disabled so if you programmatically change the 
			the placement of such Panel, it will still reposition its controls. Hence, if you create Panel with HIDDEN state and used Attach, you should also prefix
			attach defintion string with "-" to set up that Panel initialy disabled. If you don't do that Panel will do attaching in hidden state initially 
			(as it was never hidden explicitelly).

			If you have deep hierarchy of Panels(>10), script may block or show some undesired behavior. Using #MaxThreads, 255 can sometimes help.

			Depending on control you want to host inside the Panel, you may need to redifine which messages Panel redirects to the main window.
			This is hardcoded in Panel_wndProc function. For instance it may look like this:

 >			redirect = "32,78,273,276,277"  ;WM_SETCURSOR=32, WM_COMMAND=78, WM_NOTIFY=273, WM_HSCROLL=276, WM_VSCROLL=277
 */
Panel_Add(HParent, X="", Y="", W="", H="", Style="", Text="") {
	static WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000,init=0

	if !init
		if !(init := Panel_registerClass())
			return A_ThisFunc "> Failed to register class."
	
	hCtrl := DllCall("CreateWindowEx" 
	  , "Uint",	  0
	  , "str",    "Panel"	
	  , "str",    Text
	  , "Uint",   WS_CHILD	| WS_CLIPCHILDREN
	  , "int",    X, "int", Y, "int", W, "int", H
	  , "Uint",   HParent
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint")

	Panel_SetStyle(hCtrl, Style)

	IfEqual, hCtrl,0,return A_ThisFunc "> Failed to create control."
	return hCtrl
} 

/*
 Function:	SetStyle
			Set the panel style. 
 
 Parameters:
			Hwnd	- Handle of the parent. If omitted, function returns hStyle in p3 and hExStyle in p4.
			Style	- White space separated list of styles to set. HIDDEN DISABLED VSCROLL HSCROLL SCROLL RESIZE BORDER FRAME SUNKEN STATIC.
					  Any integer is accepted as style. Invalid styles are skipped.
			p3, p4  - If Hwnd is omitted, result is returned in this output variables.

 Remarks:
			Scroll styles require <Scroller> module.
			If you are adding big number of controls into the scrollable Panel, you can greatly improve performance by setting those flags after
			all control are added. Otherwise, after each new control is added to the Panel it will readjust the scrollbars.
			Panel will update scrollbars if you use this function to set any of the scroll styles and after resizing. If you don't have any of that,
			you need to call Scroller_UpdateBars to set up scrollbars initially.

			You can't use border and scroll styles together. You can't use 2 scroll types together. The combination of "vscroll hscroll" should be
			specified just as "scroll".
 */
Panel_SetStyle(Hwnd, Style, ByRef hStyle="", ByRef hExStyle="") {
	static WS_VISIBLE=0x10000000, PS_HIDDEN=0, PS_DISABLED=0x8000000, GWL_USERDATA=-21
		   ,PS_BORDER=0x800000, PS_RESIZE=0x40000, PS_CAPTION=0xC00000, PS_CLOSE=0x80000, PS_MAX=0x10000, PS_MIN=0x20000, PS_TOOL=0x80
		   ,PSEX_FRAME=1, PSEX_SUNKEN=0x200, PSEX_STATIC = 0x20000, PS_SCROLL=0  ;PS_SCROLL=0x300000 PS_VSCROLL=0x200000, PS_HSCROLL=0x100000

	pStyle := " " Style " ", h := InStr(pStyle, " hidden ")
	hStyle := h ? 0 : WS_VISIBLE,  hExStyle := 0

	loop, parse, Style, %A_Tab%%A_Space%
		IfEqual, A_LoopField, , continue
		else if A_LoopField is integer
			 hStyle |= A_LoopField
		else if (v := PS_%A_LOOPFIELD%)
			hStyle |= v
		else if (v := PSEX_%A_LOOPFIELD%)
			hExStyle |= v
		else continue
	
	if (Hwnd) {
		WinSet, Style, +%hStyle%, ahk_id %Hwnd%
		WinSet, ExStyle, +%hExStyle%, ahk_id %Hwnd%

	if h  {
		oldDetect := A_DetectHiddenWindows
		DetectHiddenWindows, on
		WinHide, ahk_id %hwnd%
		DetectHiddenWindows, %oldDetect%
	}
	
	;set custom styles
		if j := InStr(pStyle, "scroll")
		{
			c := SubStr(pStyle, j-1, 1)
			ifEqual, c, h, SetEnv, r, % DllCall("SetWindowLong", "uint", Hwnd, "int", GWL_USERDATA, "Uint", 1)
			ifEqual, c, v, SetEnv, r, % DllCall("SetWindowLong", "uint", Hwnd, "int", GWL_USERDATA, "Uint", 2)
			ifEqual, c, %A_Space%, SetEnv, r, % DllCall("SetWindowLong", "uint", Hwnd, "int", GWL_USERDATA, "Uint", 3)
			SendMessage, 0x127,3,,,ahk_id %Hwnd%	; WM_CHANGEUISTATE=, UIS_INITIALIZE=3
		}
	}
}

Panel_wndProc(Hwnd, UMsg, WParam, LParam) { 
	global hButton
	static	WM_SIZE:=5, WM_SHOWWINDOW=24, WM_CHANGEUISTATE=295, GWL_ROOT=2, GWL_WNDPROC=-4, GWL_USERDATA=-2
			,rootProc, attach, scroller_updatebars, scroller_onscroll, adrGetWindowLong, adrDefWindowProc, hRoot
			,redirect="78,273"  ;WM_COMMAND=78, WM_NOTIFY=273

	critical 100	;will always be started in new thread, so its OK
	if !rootProc {
		rootProc := DllCall("GetWindowLong", "uint", hRoot := DllCall("GetAncestor", "uint", Hwnd, "uint", GWL_ROOT), "uint", GWL_WNDPROC)
		api_suffix := A_IsUnicode ? "W" : "A",  str := A_IsUnicode ? "astr" : "str"
		adrGetWindowLong := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), str, "GetWindowLong" api_suffix)
		adrDefWindowProc := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", "user32"), str, "DefWindowProc" api_suffix)
		attach := "Attach_", scroller_onscroll := "Scroller_onScroll", scroller_updatebars := "Scroller_UpdateBars"
	}

	if UMsg in %redirect%
	{
;		return DllCall(rootProc, "uint", Hwnd, "uint", UMsg, "uint", WParam, "uint", LParam)		;redirection type 1 - transfers hwnd too, doesn't work with Button for example.
;		return DllCall("SendMessage", "uint", hRoot, "uint", UMsg, "uint", WParam, "uint", LParam)  ;redirection type 2	- use root hwnd
		SendMessage, Umsg, Wparam, Lparam, , ahk_id %hRoot%
		return ErrorLevel
	}

	if (UMsg = WM_SIZE) {
		%attach%(Wparam, LParam, UMsg, Hwnd)
		bar := DllCall(adrGetWindowLong, "uint", Hwnd, "int", -21) & 3	
		if (bar)
			%scroller_UpdateBars%(Hwnd, bar)
		return 
	}
		
	if (UMsg = WM_CHANGEUISTATE)		;Panel sends this message to itself when it sets scrollbars style.
		if (bar := DllCall(adrGetWindowLong, "uint", Hwnd, "int", -21)) & 3
			return %scroller_UpdateBars%(Hwnd, bar)
	
	if (Umsg = WM_SHOWWINDOW)
		%attach%(Hwnd, WParam ? "+" : "-", "", "")
	
	if UMsg in 276,277		
		ifNotEqual, LParam, 0, return DllCall(rootProc, "uint", Hwnd, "uint", UMsg, "uint", WParam, "uint", LParam)	 ;scrollbar control.
		else return %scroller_onScroll%(Wparam, LParam, UMsg, Hwnd)
	
	return DllCall(adrDefWindowProc, "uint", Hwnd, "uint", Umsg, "uint", WParam, "uint", LParam)
}

Panel_registerClass() {
	static CS_PARENTDC = 0x80, CS_REDRAW=3, COLOR_WINDOW=5

	clsName := "Panel"
	cursor  := DllCall("LoadCursor", "Uint", 0, "Int", 32512, "Uint")		;ARROW
	procAdr := RegisterCallback("Panel_WndProc")

   VarSetCapacity(WC, 40, 0) 
    , NumPut(CS_REDRAW | CS_PARENTDC, WC, 0)							
    , NumPut(procAdr, WC, 4) 
;    , NumPut(1, WC, 12)				;cbWndExtra
    , NumPut(cursor, WC, 24)		;curcor
    , NumPut(COLOR_WINDOW, WC, 28)	;background 
    , NumPut(&clsName, WC, 36)		;class 

   return DllCall("RegisterClass", "uint", &WC) 
 }

Panel_add2Form(hParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "x# y# w# h# style", x, y, w, h, style)
	hCtrl := Panel_Add(hParent, x, y, w, h, style, Txt)
	return hCtrl
}

/* Group: About
	o Ver 0.21 by majkinetor. 
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
*/