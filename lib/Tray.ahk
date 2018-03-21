/* Title:		Tray
				*Tray icon controller*
 :
				Using this module you can totally control Windows notification area. 
				Your script can create any number of tray icons and receive notifications about user actions on them.
				Also, you can get and modify 3thd party tray icons information.
 */

/*Function:		Add
 				Add icon in the system tray.
 
  Parameters:
 				hGui	- Handle of the parent window.
 				Handler	- Notification handler.
 				Icon	- Icon path or handle. Icons allocated by module will be automatically destroyed when <Remove> function
 						  returns. If you pass icon handle, <Remove> will not destroy it. If path is an icon resource, you can 
						  use "path:idx" notation to get the handle of the desired icon by its resource index (0 based).
 				Tooltip	- Tooltip text.
 
  Notifications:
 >				Handler(Hwnd, Event)
 
 				Hwnd	- Handle of the tray icon.
 				Event	- L (Left click), R(Right click), M (Middle click), P (Position - mouse move).
		 				  Additionally, "u" or "d" can follow event name meaning "up" and "doubleclick".
 						  For example, you will be notified on "Lu" when user releases the left mouse button.
 				
  Returns:
 				0 on failure, handle on success.
 */
Tray_Add( hGui, Handler, Icon, Tooltip="") {
	static NIF_ICON=2, NIF_MESSAGE=1, NIF_TIP=4, MM_SHELLICON := 0x500
	static uid=100, hFlags

	if !hFlags
		OnMessage( MM_SHELLICON, "Tray_onShellIcon" ), hFlags := NIF_ICON | NIF_TIP | NIF_MESSAGE 

	if !IsFunc(Handler)
		return A_ThisFunc "> Invalid handler: " Handler

	hIcon := Icon/Icon ? Icon : Tray_loadIcon(Icon, 32)

	VarSetCapacity( NID, 88, 0) 
	 ,NumPut(88,	NID)
	 ,NumPut(hGui,	NID, 4)
	 ,NumPut(++uid,	NID, 8)
	 ,NumPut(hFlags, NID, 12)
	 ,NumPut(MM_SHELLICON, NID, 16)
	 ,NumPut(hIcon, NID, 20)
	 ,DllCall("lstrcpyn", "uint", &NID+24, "str", Tooltip, "int", 64)
	
	if !DllCall("shell32.dll\Shell_NotifyIconA", "uint", 0, "uint", &NID)
		return 0

	Tray( uid "handler", Handler)
	Icon/Icon ? Tray( uid "hIcon", hIcon) :		;save icon handle allocated by Tray module so icon can be destroyed.
	return uid
}

/*
 Function:		Click
 				Click the tray icon.

 Parameters:
				Position	- Position of the tray icon.
				Button		- "L", "R", "M" or "Ld".
 */
Tray_Click(Position, Button="L") {
	static L=513, R=516, M=520, Ld=515

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	Tray_Define(Position, "mhw", msg, htray, hwnd)
	mDown := %Button%, mUp := mDown+1

	PostMessage, msg, hTray, mDown, ,ahk_id %hwnd%
	if Button != Ld
		PostMessage, msg, hTray, mUp, ,ahk_id %hwnd%
	
	DetectHiddenWindows,  %oldDetect%
}

/*Function:		Count
 				Get the number of icons in the notificaiton area.
 */
Tray_Count() {
	static TB_BUTTONCOUNT = 0x418
	tid := Tray_getTrayBar()
	SendMessage,TB_BUTTONCOUNT,,,, ahk_id %tid%
	return ErrorLevel
}

/* Function:	Define
 				Get information about system tray icons.
 
  Parameters:
				Filter  - Contains process name, ahk_pid, ahk_id or 1-based position for which to return information.
						  If you specify position as Filter, you can use output variables to store information.
				pQ		- Query parameter, by default "ihw".
				o1..o4  - Reference to output variables.

  Query:
				h	- Handle.
				i	- PosItion (1 based).
				w	- Parent Window handle.
				p	- Process Pid.
				n	- Process Name.
				m   - Message id.
				o	- IcOn handle.
 
  Returns:
				String containing icon information per line. 
 */
Tray_Define(Filter="", pQ="", ByRef o1="~`a ", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="", ByRef o7=""){
	static TB_BUTTONCOUNT = 0x418, TB_GETBUTTON=0x417, sep="|"
	ifEqual, pQ,, SetEnv, pQ, ihw

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
	tid := Tray_getTrayBar()
	SendMessage,TB_BUTTONCOUNT,,,,ahk_id %tid%
	
	i := bPos ? bPos-1 : 0
	cnt := bPos ?  1 : ErrorLevel
	Loop, %cnt%
	{
		i++
		SendMessage, TB_GETBUTTON, i-1, pProc,, ahk_id %tId%

		VarSetCapacity(BTN,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &BTN, "Uint", 32, "Uint", 0)
		if !(dwData := NumGet(BTN,12))
			dwData := NumGet(BTN,16,"int64")

		VarSetCapacity(NFO,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &NFO, "Uint", 32, "Uint", 0)
		if NumGet(BTN,12)
			 w := NumGet(NFO, 0),		  h	:= NumGet(NFO, 4), m := NumGet(NFO, 8),	 o := NumGet(NFO, 20)
		else w := NumGet(NFO, 0,"int64"), h := NumGet(NFO, 8), m := NumGet(NFO, 12), o := NumGet(NFO, 24)

		WinGet, n, ProcessName, ahk_id %w%
		WinGet, p, PID, ahk_id %w%
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

	DetectHiddenWindows,  %oldDetect%
	return SubStr(res, 1, -1)
}

/*	
	Function:	Disable
 				Disable the notification area.
	
	Remarks:
				The shell must be restarted for the changes to take effect. See <Shell_Restart> for details.
 */
Tray_Disable(bDisable=true) {
	static key="Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	RegWrite,REG_DWORD, HKEY_CURRENT_USER, %key%, NoTrayItemsDisplay, %bDisable%
}

/* Function:	Focus
 				Focus notification icon or window.

   Parameters:
				hGui - Handle of the parent window.
				hTray - Tray icon handle. This icon will be focused. As a consequence, you can use SPACEBAR or ENTER instead left click and
				windows popup keyboard button as rclick. 
				Arrows can be used to select other icons. However, there is no visual representation of selection apart from the tooltip
				that is shown after few moments.

   Remarks:
				If both parameters are missing, function will focus Notification area.
  */
Tray_Focus(hGui="", hTray="") {
	static NIM_SETFOCUS=0x3

	if (hGui hTray = "") {
		hwnd := WinExist("ahk_class Shell_TrayWnd")
		WinActivate, ahk_id %hwnd%
		WinWaitActive, ahk_id %hwnd%
		ControlSend,, ^{TAB}, ahk_class Shell_TrayWnd
		return
	}

	VarSetCapacity( NID, 88, 0) 
	 ,NumPut(88,	NID)
	 ,NumPut(hGui,	NID, 4)	
	 ,NumPut(hTray,	NID, 8)
	
	r := DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_SETFOCUS, "uint", &NID)
}

/* Function:	GetRect
 				Get tray icon rect.

   Parameters:
				Position	- Position of the tray icon. Use negative position to retreive client coordinates.
				x-h			- Refrence to outuptu variables, optional.
	
   Returns:
				String containing all outuput variables.

   Remarks:
				This function can be used to determine if tray icon is hidden. Such tray icons will have string "0 0 0 0" returned.
  */
Tray_GetRect( Position, ByRef x="", ByRef y="", ByRef w="", ByRef h="" ) {
	static TB_GETITEMRECT := 0x41D
	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	If (Position < 0)
		Position := -Position, bClient := true

	tid := Tray_getTrayBar()
	WinGetPos, xp, yp, ,, ahk_id %tid%
	VarSetCapacity(RECT, 16)

	WinGet,	pidTaskbar, PID, ahk_id %tid%
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 16, "Uint", 0x1000, "Uint", 0x4)
	
	SendMessage, TB_GETITEMRECT, Position-1, pProc, , ahk_id %tid%
	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &RECT, "Uint", 16, "Uint", 0)	
	x := NumGet(RECT, 0, "Int"), y := NumGet(RECT, 4, "Int"),  w := NumGet(RECT, 8, "Int")-x,  h := NumGet(RECT, 12, "Int") - y
	if !bClient
		x+=xp, y+=yp

	DetectHiddenWindows,  %oldDetect%
	return x " " y " " w " " h
}

/* Function:	GetTooltip
 				Get tooltip of the tray icon.

   Parameters:
				Position	- Position of the tray icon.
  */
Tray_GetTooltip(Position){
	static TB_GETBUTTON=0x417

	oldDetect := A_DetectHiddenWindows
	DetectHiddenWindows, on

	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	tid := Tray_getTrayBar()
	SendMessage, TB_GETBUTTON, Position-1, pProc, , ahk_id %tid%
	VarSetCapacity(BTN,32), DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &BTN, "Uint", 32, "Uint", 0)
	If	dwData	:= NumGet(BTN,12)
		 iString := NumGet(BTN,16)
	else iString := NumGet(BTN,24,"int64")

	VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,256)
	 ,DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 256, "Uint", 0)
	 ,DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
	 ,DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	 ,DllCall("CloseHandle", "Uint", hProc)

	DetectHiddenWindows,  %oldDetect%
	return sTooltip
}

/*	Function:	Modify
				Modify icon properties.

	Parameters:
				hGui	- Handle of the parent window.
				hTray	- Handle of the tray icon.
				Icon	- Icon path or handle, set to "" to skip.
				Tooltip	- ToolTip text, omit to keep the current tooltip.

	Returns:
				TRUE on success, FALSE otherwise.
 */
Tray_Modify( hGui, hTray, Icon, Tooltip="~`a " ) {
	static NIM_MODIFY=1, NIF_ICON=2, NIF_TIP=4

	VarSetCapacity( NID, 88, 0)
	NumPut(88, NID, 0)

	hFlags := 0
	hFlags |= Icon != "" ?  NIF_ICON : 0
	hFlags |= Tooltip != "" ? NIF_TIP : 0

	if (Icon != "") {
		hIcon := Icon/Icon ? Icon : Tray_loadIcon(Icon)
		DllCall("DestroyIcon", "uint", Tray( hTray "hIcon", "") )
		Icon/Icon ? Tray( hTray "hIcon", hIcon) :
	}

	if (Tooltip != "~`a ")
		DllCall("lstrcpyn", "uint", &NID+24, "str", Tooltip, "int", 64)


	NumPut(hGui,	  NID, 4)
	 ,NumPut(hTray,	  NID, 8)
	 ,NumPut(hFlags,  NID, 12)
	 ,NumPut(hIcon,   NID, 20)
	return DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_MODIFY, "uint", &NID)	
}

/*	Function:	Move
 				Move the tray icons.
 
	Parameters:
				Pos		- Position of the icon to move, 1 based.
				NewPos	- New position of the icon, if omited, icon will be moved to the end.

	Returns:
 				TRUE on success, FALSE otherwise.
 */
Tray_Move(Pos, NewPos=""){
	static TB_MOVEBUTTON = 0x452
	tid := Tray_getTrayBar()

	if (NewPos = "") {
		SendMessage,TB_BUTTONCOUNT,,,, ahk_id %tid%
		NewPos := ErrorLevel
	}

	SendMessage,TB_MOVEBUTTON, Pos-1, NewPos-1,, ahk_id %tid%
}

/* Function:	Remove
 				Removes the tray icon.
 
  Parameters:
 				hGui	- Handle of the parent window.
 				hTray	- Handle of the tray icon. If omited, all icons owned by the hGui will be removed.
 
  Returns:
 				TRUE on success, FALSE otherwise.
 */
Tray_Remove( hGui, hTray="") {
	static NIM_DELETE=2
	
	s := hTray
	if (hTray = "")
		s := Tray_Define("ahk_id " hGui, "h")

	res := 1
	loop, parse, s, `n
	{
		VarSetCapacity( NID, 88, 0), NumPut(88, NID),  NumPut(hGui, NID, 4), NumPut(A_LoopField, NID, 8)
		if hIcon := Tray(A_LoopField "hIcon", "")
			   DllCall("DestroyIcon", "uint", hIcon)
		res &= DllCall("shell32.dll\Shell_NotifyIconA", "uint", NIM_DELETE, "uint", &NID)
	}
}

/*	Function:	Refresh
 				Refresh tray icons.

	Remarks:
				If process exits forcefully, its tray icons wont be removed.
				Call this function to refresh the notification area in such cases.
 
 */
Tray_Refresh(){ 
	static WM_MOUSEMOVE = 0x200

	ControlGetPos,,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd 
	width:=w, hight:=h 
	while ((h:=h-5)>0 and w:=width)
		while ((w:=w-5)>0)
			PostMessage, WM_MOUSEMOVE,0, ((hight-h) >> 16)+width-w, ToolbarWindow321, AHK_class Shell_TrayWnd 
}

;======================================== PRIVATE ====================================

Tray_getTrayBar(){
	ControlGet, h, HWND,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, h, HWND,, ToolbarWindow321, ahk_id %h%
	return h
}


Tray_loadIcon(pPath, pSize=32){
	j := InStr(pPath, ":", 0, 0), idx := 0
	if j > 2
		idx := Substr( pPath, j+1), pPath := SubStr( pPath, 1, j-1)

	DllCall("PrivateExtractIcons"
            ,"str",pPath,"int",idx,"int",pSize,"int", pSize
            ,"uint*",hIcon,"uint*",0,"uint",1,"uint",0,"int")

	return hIcon
}



Tray_onShellIcon(Wparam, Lparam) {
	static EVENT_512="P", EVENT_513="L", EVENT_514="Lu", EVENT_515="Ld", EVENT_516="R", EVENT_517="Ru", EVENT_518="Rd", EVENT_519="M", EVENT_520="Mu", EVENT_521="Md"

	;wparam = uid, ; msg = lparam loword
	handler := Tray(Wparam "handler")  ,event := (Lparam & 0xFFFF)
	return %handler%(Wparam, EVENT_%event%)
}


;storage
Tray(var="", value="~`a ") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
}


/* Group: Example
 (start code)
		Gui,  +LastFound
		hGui := WinExist()
 
		Tray_Add( hGui, "OnTrayIcon", "shell32.dll:1", "My Tray Icon")
	return
 
	OnTrayIcon(Hwnd, Event){
	  	if (Event != "R")		;return if event is not right click
			return
 
		MsgBox Right Button clicked
	}
 (end code)
*/

/* Group: About
	o v2.1 by majkinetor. See <http://www.autohotkey.com/forum/topic26042.html>.
	o Tray_Refresh by HotKeyIt <http://www.autohotkey.com/forum/topic36966.html>.
	o Parts of the code are modifications of the Sean's work <http://www.autohotkey.com/forum/topic17314.html>.
	o MSDN Reference: <http://msdn.microsoft.com/en-us/library/ee330740(VS.85).aspx> .
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> .
 */