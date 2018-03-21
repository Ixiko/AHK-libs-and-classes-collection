/*	Title:	ComboX

			Impose ComboBox like behavior on arbitrary control.
			:
			To create ComboX control, first create any kind of control and initialize it using <Set> function.
			After that, control will be stay visible only from the moment it is shown (via <Show> or <Toggle>)
			until it losses focus. You can optionally create trigger button for the ComboX control that will be used
			for showing and positioning of the control.

			(see ComboX.png)

	Dependency:
			Win 1.24++
*/

/*
 Function:	Hide
			Hide ComboX control.
 
 Parameters:
			hCombo	- Handle of the control.
 */
ComboX_Hide( HCtrl ) {
 	Win_Show( HCtrl, false )
	handler := ComboX(HCtrl "Handler")
	if handler !=
		%handler%(HCtrl, "Hide")
}

/*
 Function:	Set
			Initializes control as a ComboX control.
 
 Parameters:
			HCtrl	- Handle of the control to be affected.
			Handler	- Notification handler. Optional.
			Options	- Space separated list of options, see below. Optional, by default "Esc Enter".

 Options:
			Space, Esc, Enter, Click	- Specifing one or more of these keys controls when to hide ComboX control.
			Hwnd	- Handle of the glue control in integer format. This control represents the "arrow button" in normal ComboBox control. When ComboX control is shown,
					  it will be positioned relative to the glue control.			
			PHW		- Letters specifying how control is positioned relative to the glue control. P specifies on which corner of glue control to bind (1..4), 
					  W how width is expanded L (left) R(right), H how height is expanded U (up) D (down).  
					  For instance 4LD mimic standard ComboBox control.

 Handler:
  >			OnComboX( Hwnd, Event )
			
			Hwnd	- Handle of the control that triggered event.
			Event	- "Show", "Hide" or "Select". Space and Enter will trigger "Select" event after control is hidden. Esc and loosing focus will triger "Hide" event after control is hidden.
					  "Show" event is triggered before control is shown as a call to <Show> or <Toggle> functions.
 
 Remarks:
			Some controls may have their g labels not working after being set as ComboX control.
 */
ComboX_Set( HCtrl, Options="", Handler="") {
	ifEqual, Options,,SetEnv, Options, esc enter

	HCtrl += 0
	Win_Show(HCtrl, false)
	oldParent := Win_SetParent(HCtrl, 0, true)
	Win_Subclass(HCtrl, "ComboX_wndProc")
	
	RegExMatch(Options, "S)[\d]+(?=$|[ ])", out)
	ComboX( HCtrl "HButton", out+0)

	RegExMatch(Options, "Si)[1-4][LR][UD]", out)
	ComboX( HCtrl "Pos", out)
	ComboX( HCtrl "Options", Options)
	if IsFunc(Handler)
		ComboX(	HCtrl "Handler", Handler)

	Win_SetOwner( HCtrl, oldParent )
}

/*
 Function:	Show
			Show ComboX control. Sets ComboX_Active to currently shown control.
 
 Parameters:
			HCtrl	- Handle of the control.
			X,Y,W,H	- Optional screen coordinates on which to show control and its width and height.
 */
ComboX_Show( HCtrl, X="", Y="", W="", H="" ) {
   HCtrl += 0
   ComboX("", HCtrl ")Handler HButton Pos", handler, hBtn, pos)

   if (X Y = "") {
      if (hBtn != "")
         ComboX_setPosition(HCtrl, pos, hBtn, W, H)
   }
   else Win_Move(HCtrl, X, Y, W, H)

   if handler !=
      %handler%(HCtrl, "Show")
   Win_Show(HCtrl)
}


/*
 Function:	Toggle
			Toggle ComboX control.
 
 Parameters:
			HCtrl	- Handle of the control.
 */
ComboX_Toggle(HCtrl) {
	return Win_Is(HCtrl, "visible") ? ComboX_Hide(HCtrl) : ComboX_Show(HCtrl)
}

;==================================== PRIVATE ===================================

ComboX_wndProc(Hwnd, UMsg, WParam, LParam){ 
	static WM_KEYDOWN = 0x100, WM_KILLFOCUS=8, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202,        VK_ESCAPE=27, VK_ENTER=13, VK_SPACE=32

	critical		;safe, always in new thread

	res := DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", Hwnd, "UInt", UMsg, "UInt", WParam, "UInt", LParam) 

	ComboX("", Hwnd ")Handler Options HButton", handler, op, hBtn)

	if (UMsg = WM_KILLFOCUS) 
		return ComboX_Hide(Hwnd)
	
	if (UMsg = WM_KEYDOWN)
		if (WParam = VK_ESCAPE) && InStr(op, "esc")
			ComboX_Hide(Hwnd)
		else if ((WParam = VK_ENTER) && InStr(op, "enter")) || ((WParam = VK_SPACE) && InStr(op, "space"))
			goto %A_ThisFunc%

	if (Umsg = WM_LBUTTONUP) && InStr(op, "click")
		goto %A_ThisFunc%

	return res  

 ComboX_wndProc:
		ComboX_Hide(Hwnd)
		if handler !=
			%handler%(Hwnd, "Select")	
 return
}

ComboX_setPosition( HCtrl, Pos, Hwnd, W="", H="" ) {
   ifEqual, Pos, , SetEnv, Pos, 4LD
   StringSplit, p, Pos

   Win_Get(Hwnd, "Rxywh", x, y, w, h)
   Win_Get(HCtrl, "Rwh", cw, ch)      ;4LU

   cx := (p1=1 || p1=3 ? x : x + w) + (p2="R" ? 0 : -cw)
   cy := (p1=1 || p1=2 ? y : y + h) + (p3="D" ? 0 : -ch)
   Win_Move(HCtrl, cx, cy, W, H)
}

;Storage
ComboX(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}


#include *i Win.ahk
#include *i inc\Win.ahk


/* Group: About
	o Ver 2.02 by majkinetor.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>
 */