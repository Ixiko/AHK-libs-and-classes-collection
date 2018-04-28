/* Title: Panel
		  Panel control. 
 */

/*
 Function:	Add
			Adds new panel.
 
 Parameters:
			HParent		- Handle of the parent.
			X..H		- Placement.
			Style		- White space separated list of panel styles. Additionally, any integer style can be specified among other styles.
			Text		- Text to display.

 Styles:
			HIDDEN, SIMPLE, VCENTER, HCENTER, CENTER, RIGHT, SUNKEN, BLACKFRAME, BLACKRECT, GRAYFRAME, GRAYRECT, WHITEFRAME, WHITERECT.
			
 Returns:
		    Handle of the control or 0 if control couldn't be created.

 Remarks:
			If you <Attach> Panel control to its parent, Panel will disable Attach for itself when it becomes explicitelly hidden and enable itself when you show it latter.
			When Panel doesn't attach, its parent will skip it when performing repositioning of the controls. If Panel itself is attaching its own children, 
			this means that it will also stop attaching them as its own size wont change. However, its children won't be disabled so if you programmatically change the 
			the placement of such Panel, it will still reposition its controls. Hence, if you create Panel with HIDDEN state and used Attach, you should also prefix
			attach defintion string with "-" to set up that Panel initialy disabled. If you don't do that Panel will do attaching in hidden state initially 
			(as it was never hidden explicitelly).

			If you have deep hierarchy of Panels(>10), script may block. Using #MaxThreads, 255 can sometimes help.
 */
Panel_Add(HParent, X, Y, W, H, Style="", Text="") {
	static WS_VISIBLE=0x10000000, WS_CHILD=0x40000000, WS_CLIPCHILDREN=0x2000000, SS_NOTIFY=0x100
		   ,SS_SIMPLE = 0xB, SS_BLACKFRAME = 7, SS_BLACKRECT = 4, SS_CENTER=0x201, SS_VCENTER=0x200, SS_HCENTER = 1, SS_GRAYFRAME = 0x8, SS_GRAYRECT = 0x5, SS_RIGHT = 2, SS_SUNKEN = 0x1000, SS_WHITEFRAME = 9, SS_WHITERECT = 6
		   ,init=0, SS_HIDDEN=0

	if !init
		init := Panel_registerClass()

	hStyle := InStr(" " Style " ", " hidden ") ? 0 : WS_VISIBLE
	loop, parse, Style, %A_Tab%%A_Space%, %A_Tab%%A_Space%
	{
		IfEqual, A_LoopField, , continue
		if A_LoopField is integer
			 hStyle |= A_LoopField
		else hStyle |= SS_%A_LOOPFIELD%
	}

	hCtrl := DllCall("CreateWindowEx" 
	  , "Uint",	  0
	  , "str",    "Panel"	
	  , "str",    text		
	  , "Uint",   WS_CHILD	| WS_CLIPCHILDREN | SS_NOTIFY | hStyle
	  , "int",    X, "int", Y, "int", W, "int",H
	  , "Uint",   HParent
	  , "Uint",   0, "Uint",0, "Uint",0, "Uint") 

	return hCtrl
} 

Panel_wndProc(Hwnd, UMsg, WParam, LParam) { 
	static WM_SIZE:=5, WM_SHOWWINDOW=0x18, redirect = "32,78,273,277,279", anc, attach, init		;WM_SETCURSOR=32,WM_COMMAND=78,WM_NOTIFY=273,WM_HSCROLL=277,WM_VSCROLL=299

	if !init {
		ifEqual, attach, %A_Space%, return
		ifEqual, attach,, SetEnv, attach, % IsFunc("Attach_") ? "Attach_" : A_Space
		init := true
	}

	if UMsg in %redirect%
	{	
		anc := DllCall("GetAncestor", "uint", Hwnd, "uint", 2) ;GWL_ROOT=2
		return DllCall("SendMessage", "uint", anc, "uint", UMsg, "uint", WParam, "uint", LParam)
	}
	
	if (UMsg = WM_SIZE) 
		%attach%(Wparam, LParam, UMsg, Hwnd)
	
	if (Umsg = WM_SHOWWINDOW)
		%attach%(Hwnd, WParam ? "+" : "-", "", "")

	return DllCall("CallWindowProc","uint",A_EventInfo,"uint",Hwnd,"uint",UMsg,"uint",WParam,"uint",LParam)
}

Panel_registerClass() {
    static ClassAtom, ClassName="Panel"
	ifNotEqual, ClassAtom,, return ClassAtom
   
    VarSetCapacity(wcl,40)
    if !DllCall("GetClassInfo","uint",0,"str","Static","uint",&wcl)
        return false

    NumPut(NumGet(wcl)|0x20000,wcl)						; wcl->style |= CS_DROPSHADOW
    NumPut(&ClassName,wcl,36)							; wcl->lpszClassName = &ClassName
    NumPut(DllCall("GetModuleHandle","uint",0),wcl,16)  ; wcl->hInstance = NULL

	; Create a callback for Form_WndProc, passing Static's WindowProc as A_EventInfo. lpfnWndProc := the callback.
    NumPut( RegisterCallback("Panel_WndProc", "",4 ,NumGet(wcl,4)), wcl, 4)    
    return DllCall("RegisterClass","uint",&wcl)
}

Panel_add2Form(hParent, Txt, Opt){
	static parse = "Form_Parse"
	if IsFunc(parse) 
		%parse%(Opt, "x# y# w# h# style hidden?", x, y, w, h, style)
	hCtrl := Panel_Add(hParent, x, y, w, h, style, Txt)	
	return hCtrl
}

/* Group: About
	o Ver 0.1 by majkinetor. 
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/>.
*/