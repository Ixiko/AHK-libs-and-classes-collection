/* Title:		Taskbar
				*Taskbar monitor and controller*
 :
				Using this module you can monitor and control Windows Taskbar buttons.
				Your script can get information about windows currently displayed in Taskbar
				as well as hide, delete or move its buttons.
 */

/*  
 Function:		Count
				Get the number of buttons in the Taskbar.
 
 Returns:
				Number. This includes hidden buttons. 	
 */

Taskbar_Count() {
	static TB_BUTTONCOUNT=0x418
	h := Taskbar_GetHandle()
	SendMessage,TB_BUTTONCOUNT,,,,ahk_id %h%
	return ErrorLevel
}


/* Function:	Define
 				Get information about Taskbar buttons.
 
  Parameters:
				Filter  - Contains process name, ahk_pid, ahk_id or 1-based position for which to return information.
						  If you specify position as Filter, you can use output variables to store information since only 1 item
						  will be returned in that case. If you omit this parameter, information about all buttons will be returned.
				pQ		- Query parameter, by default "iwt".
				o1..o7  - Reference to output variables.

  Query:
				h	- Handle.
				i	- PosItion (1 based).
				w	- Parent Window handle.
				p	- Process Pid.
				n	- Process Name.
				o	- IcOn handle.
				t	- Title of the parent window.

  Returns:
				String containing icon information per line. 
 */
Taskbar_Define(Filter="", pQ="", ByRef o1="~`a ", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7=""){
	static TB_BUTTONCOUNT = 0x418, TB_GETBUTTON=0x417, sep="|"
	ifEqual, pQ,, SetEnv, pQ, iwt

	if Filter is integer
		 bPos := Filter
	else if Filter contains ahk_pid,ahk_id
		 bPid := InStr(Filter, "ahk_pid"),  bID := !bPid,  Filter := SubStr(Filter, 8)
	else bName := true

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	hctrl := Taskbar_GetHandle()
	SendMessage,TB_BUTTONCOUNT,,,, ahk_id %hctrl%
	
	i := bPos ? bPos-1 : 0
	cnt := bPos ?  1 : ErrorLevel
	Loop, %cnt%
	{
		i++
		SendMessage, TB_GETBUTTON, i-1, pProc,, ahk_id %hctrl%

		VarSetCapacity(BTN,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &BTN, "Uint", 32, "Uint", 0)
		if !(dwData := NumGet(BTN,12))
			dwData := NumGet(BTN,16,"int64")
		
		h := NumGet(BTN, 4)

		VarSetCapacity(NFO,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &NFO, "Uint", 32, "Uint", 0)
		if NumGet(BTN,12)
			 w := NumGet(NFO, 0),		   o := NumGet(NFO, 20)
		else w := NumGet(NFO, 0, "int64"), o := NumGet(NFO, 24)
		ifEqual, w, 0, continue

		WinGet, n, ProcessName, ahk_id %w%
		WinGet, p, PID, ahk_id %w%
		WinGetTitle, t, ahk_id %w%
		
		if !Filter || bPos || (bName && Filter=n) || (bPid && Filter=p) || (bId && Filter=w) {
			loop, parse, pQ
				f := A_LoopField, res .= %f% sep
			res := SubStr(res, 1, -1) "`n"		
		}
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000), DllCall("CloseHandle", "Uint", hProc)
	
	if (bPos)
		loop, parse, pQ
			o%A_Index% := %A_LoopField%

	DetectHiddenWindows, %oldDetect%
	return SubStr(res, 1, -1)
}

/*	
	Function:	Flash
 				Flash the Taskbar button.

	Parameters:
				Hwnd	- Hwnd of the window to flash.
				Options	- White space separated list of flash options.

	Flash options:
				Caption - Flash caption.
				Button  - Flash button. This is default option.
				All     - Flash both.
				Timer   - Flesh until next call of this function with empty Options argument.
				TimerFG - Flash continuously until the window comes to the foreground.
				N.R		- Decimal number. N specifies number of times to flash, by defult 3, R the flash rate (0 means cursor rate, default).
				
	Returns:
				The return value specifies the window's state before the call to the Flash function. 
				If the window caption was drawn as active before the call, the return value is nonzero. 
				Otherwise, the return value is zero.

	Example:
		>		Taskbar_Flash( Taskbar_Define(2, "w"), "10.200 button")		;flash first button 10 times with 200ms rate, only button
 */
Taskbar_Flash( Hwnd=0, Options="" ) { 
	static STOP=0, CAPTION=1, BUTTON=2, ALL=3, TIMER=4, TIMERFG=12
	
	cnt := 0, rate := 0, hFlags := 0
	loop, parse, Options, %A_Space%%A_Tab%,%A_Space%%A_Tab%
	{
		ifEqual, A_LoopField,,continue
		if A_LoopField is number
			 cnt := floor(A_LoopField), rate := (j:=InStr(A_LoopField, ".")) ? SubStr(A_LoopField, j+1) : 0
		else hFlags |= %A_LoopField%
	}
	ifEqual, hFlags, , return A_ThisFunc ">Some of the options are invalid: " Options
	VarSetCapacity(FW, 20), NumPut(20,FW), NumPut(Hwnd,FW,4), NumPut(4,FW,8), NumPut(cnt,FW,12), NumPut(rate,FW,16) 
	Return DllCall( "FlashWindowEx", "UInt", &FW ) 
}

/*	
	Function:	Focus
 				Focus the Taskbar.
	
	Remarks:
				After the Taskbar is focused, you can use {Space} or {Enter} to activate window or
				windows popup button to display system menu.
 */
Taskbar_Focus() {
	h := Taskbar_GetHandle()
	ControlFocus,,ahk_id %h%    ;this is OK but pressing TAB doesn't move to tray, but returns back to quickl.
}

/*	
	Function:	Disable
 				Disable the Taskbar.

	Parameters:
				bDisable	- Set to FALSE to enable Taskbar. By default TRUE.
 */
Taskbar_Disable(bDisable=true){
	tid := Taskbar_GetHandle()
	if bDisable
		 WinHide, ahk_id %tid%
	else WinShow, ahk_id %tid%
}

/*  
 Function:	GetHandle
 			Get the Hwnd of the Taskbar.
 
 Returns:
			Hwnd 	
 */
Taskbar_GetHandle(){
	ControlGet, hParent, HWND,,MSTaskSwWClass1, ahk_class Shell_TrayWnd
	ControlGet, h, HWND,, ToolbarWindow321, ahk_id %hParent%
	return h
}

/* Function:	GetRect
 				Get Taskbar button placement.

   Parameters:
				Position	- Position of the button. Use negative position to retreive client coordinates.
				X..H		- Refrence to output variables, optional.
	
   Returns:
				String containing all outuput variables.

   Remarks:
				This function can be used to determine invisible buttons. Such buttons will have w & h equal to 0.
  */
Taskbar_GetRect( Position, ByRef X="", ByRef Y="", ByRef W="", ByRef H="" ) {
	static TB_GETITEMRECT := 0x41D
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	If (Position < 0)
		Position := -Position, bClient := true

	tid := Taskbar_GetHandle()
	WinGetPos, xp, yp,,,ahk_id %tid%
	VarSetCapacity(RECT, 16)

	WinGet,	pidTaskbar, PID, ahk_id %tid%
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 16, "Uint", 0x1000, "Uint", 0x4)
	
	SendMessage, TB_GETITEMRECT, Position-1, pProc,,ahk_id %tid%
	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &RECT, "Uint", 16, "Uint", 0)	
	X := NumGet(RECT, 0, "Int"), Y := NumGet(RECT, 4, "Int"),  W := NumGet(RECT, 8, "Int")-X,  H := NumGet(RECT, 12, "Int") - Y
	if !bClient
		X+=xp, Y+=yp

	DetectHiddenWindows,  %oldDetect%
	return X " " Y " " W " " H
}

/*  
 Function:	Hide
 			Hide Taskbar button.
 
 Parameters:
 			Position	- Position of the button.
			bHide		- Set to TRUE (default) to hide button. FALSE will show it again.
 
 Returns:
			TRUE if successful, or FALSE otherwise. 	
 */

Taskbar_Hide(Handle, bHide=True){
	static TB_HIDEBUTTON=0x404
	h := Taskbar_GetHandle()
	SendMessage, TB_HIDEBUTTON, Handle, bHide,,ahk_id %h%
	return ErrorLevel
}

/*  
 Function:	Move
 			Move Taskbar button.
 
 Parameters:
 			Pos		- 1-based position of the button to be moved.
 			NewPos	- 1-based postiion where the button will be moved.
 
 Returns:
			TRUE indicates success. FALSE indicates failure.

 Remarks:
			When moving a button this function will also move its hidden button.
 */
Taskbar_Move(Pos, NewPos){
	static TB_MOVEBUTTON=0x452
	h := Taskbar_GetHandle()
	if (NewPos < Pos) {
		SendMessage, TB_MOVEBUTTON,Pos-2, NewPos-2,, ahk_id %h%
		SendMessage, TB_MOVEBUTTON,Pos-1, NewPos-1,, ahk_id %h%
	} else if (NewPos > Pos){
		SendMessage, TB_MOVEBUTTON,Pos-1, NewPos-1,, ahk_id %h%
		SendMessage, TB_MOVEBUTTON,Pos-2, NewPos-2,, ahk_id %h%	
	} else return 1
	return ErrorLevel
}

/*  
 Function:	Remove
 			Remove Taskbar button.
 
 Parameters:
 			Position	- Position of the button.
 
 Returns:
			TRUE indicates success. FALSE indicates failure. 	
 */

Taskbar_Remove(Position){
	static TB_DELETEBUTTON=0x416
	h := Taskbar_GetHandle()
	SendMessage, TB_DELETEBUTTON,Position-1,,,ahk_id %h%
	return ErrorLevel
}

/* Group: Example
	
	Sort buttons on the Taskbar:

 (start code)
    ;requires that there are no grouped buttons
	SortTaskbar(type="R") {
		static WM_SETREDRAW=0xB 
		h := Taskbar_GetHandle()
		SendMessage, WM_SETREDRAW, 0, , , ahk_id %h%
		loop, % Taskbar_Count() // 2 
		{
			s := btns := Taskbar_Define("", "ti") "`n"
			Sort, s, %type%
			s := RegExReplace( s, "([^\n]*+\n){" A_Index-1 "}", "", "", 1 )
			s := SubStr(s, 1, InStr(S, "`n")-1)
			StringSplit, w, s, |

			Taskbar_Move( w2, 2 )
		}
		SendMessage, WM_SETREDRAW, 1, , , ahk_id %h%
	}
  (end code)
*/

/* Group: About
	o v1.0 by majkinetor.
	o Parts of code by Sean. See <http://www.autohotkey.com/forum/topic18652.html>.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> .
 */