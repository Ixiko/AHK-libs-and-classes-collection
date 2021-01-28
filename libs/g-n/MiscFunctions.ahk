;This file contains various functions for all kinds of things. YAY!

#include *i %A_ScriptDir%\lib\Array.ahk

;Gets a localized string from a resource file.
;usage example:
;x := TranslateMUI("shell32.dll",31236)
TranslateMUI(resDll, resID) {
	VarSetCapacity(buf, 256) 
	hDll := DllCall("LoadLibrary", "str", resDll, "Ptr") 
	Result := DllCall("LoadString", "Ptr", hDll, "uint", resID, "str", buf, "int", 128)
	return buf
}

;Finds the path of the Shell32.dll.mui file
LocateShell32MUI()
{
	VarSetCapacity(buffer, 85*2)
	length:=DllCall("GetUserDefaultLocaleName","UIntP",buffer,"UInt",85)
	if(A_IsUnicode)
		locale := StrGet(buffer)
	shell32MUIpath := A_WinDir "\winsxs\*_microsoft-windows-*resources*" locale "*" ;\x86_microsoft-windows-shell32.resources_31bf3856ad364e35_6.1.7600.16385_de-de_b08f46c44b512da0\shell32.dll.mui
	loop %shell32MUIpath%,2,0
		if(FileExist(A_LoopFileFullPath "\shell32.dll.mui"))
			return A_LoopFileFullPath "\shell32.dll.mui"
}

;Splits a command into command and arguments
SplitCommand(fullcmd, ByRef cmd, ByRef args)
{
	if(InStr(fullcmd, """") = 1)
	{
		pos := InStr(fullcmd, """" , 0, 2)
		cmd := SubStr(fullcmd, 2,pos - 2)
		args := SubStr(fullcmd, pos + 1)
		args := strTrim(args, " ")
	}
	else if(pos:=InStr(fullcmd, " " , 0, 1))
	{
		cmd := SubStr(fullcmd, 1, pos-1)
		args := SubStr(fullcmd, pos+1)
		args := strTrim(args, " ")
	}
	else
	{
		cmd := fullcmd
		args := ""
	}
}

;Gets a free gui number.
/* Group: About
	o v0.81 by majkinetor.
	o Licenced under BSD <http://creativecommons.org/licenses/BSD/> 
*/
GetFreeGuiNum(start, prefix = ""){
	loop
	{
		Gui %prefix%%start%:+LastFoundExist
		IfWinNotExist
			return prefix start
		start++
		if(start = 100)
			return 0
	}
	return 0
}

;Checks if a specific window is under the cursor.
IsWindowUnderCursor(hwnd)
{
	MouseGetPos, , , win
	if hwnd is number
		return win = hwnd
	else
		return InStr(WinGetClass("ahk_class " win), hwnd)
}

;Checks if a specific control is under the cursor and returns its ClassNN if it is.
IsControlUnderCursor(ControlClass)
{
	MouseGetPos, , , , control
	if(InStr(Control, ControlClass))
		return control
	return false
}

;Sets window event hook
API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
   return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "Ptr", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags, "Ptr") 
} 

;Unhooks window event hook
API_UnhookWinEvent( hWinEventHook ) { 
   return DllCall("UnhookWinEvent", "Ptr", hWinEventHook) 
} 

;disables or restores original minimize anim setting
DisableMinimizeAnim(disable)
{
	static original,lastcall	
	if(disable && !lastcall) ;Backup original value if disabled is called the first time after a restore call
	{
		lastcall := 1
		RegRead, original, HKCU, Control Panel\Desktop\WindowMetrics , MinAnimate
	}
	else if(!disable) ;this is a restore call, on next disable backup may be created again
		lastcall := 0
	;Disable Minimize/Restore animation
	VarSetCapacity(struct, 8, 0)	
	NumPut(8, struct, 0, "UInt")
	if(disable || !original)
		NumPut(0, struct, 4, "Int")
	else
		NumPut(1, struct, 4, "UInt")
	DllCall("SystemParametersInfo", "UINT", 0x0049,"UINT", 8,"Ptr", &struct,"UINT", 0x0003) ;SPI_SETANIMATION            0x0049 SPIF_SENDWININICHANGE 0x0002
}

/* 
Performs a hittest on the window under the mouse and returns the WM_NCHITTEST Result
#define HTERROR             (-2) 
#define HTTRANSPARENT       (-1) 
#define HTNOWHERE           0 
#define HTCLIENT            1 
#define HTCAPTION           2 
#define HTSYSMENU           3 
#define HTGROWBOX           4 
#define HTSIZE              HTGROWBOX 
#define HTMENU              5 
#define HTHSCROLL           6 
#define HTVSCROLL           7 
#define HTMINBUTTON         8 
#define HTMAXBUTTON         9 
#define HTLEFT              10 
#define HTRIGHT             11 
#define HTTOP               12 
#define HTTOPLEFT           13 
#define HTTOPRIGHT          14 
#define HTBOTTOM            15 
#define HTBOTTOMLEFT        16 
#define HTBOTTOMRIGHT       17 
#define HTBORDER            18 
#define HTREDUCE            HTMINBUTTON 
#define HTZOOM              HTMAXBUTTON 
#define HTSIZEFIRST         HTLEFT 
#define HTSIZELAST          HTBOTTOMRIGHT 
#if(WINVER >= 0x0400) 
#define HTOBJECT            19 
#define HTCLOSE             20 
#define HTHELP              21 
*/ 
MouseHitTest()
{
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY, WindowUnderMouseID 
	WinGetClass, winclass , ahk_id %WindowUnderMouseID%
	if winclass in BaseBar,D2VControlHost,Shell_TrayWnd,WorkerW,ProgMan  ; make sure we're not doing this on the taskbar
		return -2
	; WM_NCHITTEST 
	SendMessage, 0x84,, ( (MouseY&0xFFFF) << 16 )|(MouseX&0xFFFF),, ahk_id %WindowUnderMouseID%
	return ErrorLevel
}

;Returns true if there is an available internet connection
IsConnected(URL="http://code.google.com/p/7plus/")
{
	return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
}

/*! TheGood (modified a bit by Fragman)
    Checks if a window is in fullscreen mode. 
    ______________________________________________________________________________________________________________ 
    sWinTitle       - WinTitle of the window to check. Same syntax as the WinTitle parameter of, e.g., WinExist(). 
    bRefreshRes     - Forces a refresh of monitor data (necessary if resolution has changed) 
    UseExcludeList  - returns false if window class is in FullScreenExclude (explorer, browser etc)
    UseIncludeList  - returns true if window class is in FullScreenInclude (applications capturing gamepad input)
    Return value    o If window is fullscreen, returns the index of the monitor on which the window is fullscreen. 
                    o If window is not fullscreen, returns False. 
    ErrorLevel      - Sets ErrorLevel to True if no window could match sWinTitle 
    
        Based on the information found at http://support.microsoft.com/kb/179363/ which discusses under what 
    circumstances does a program cover the taskbar. Even if the window passed to IsFullscreen is not the 
    foreground application, IsFullscreen will check if, were it the foreground, it would cover the taskbar. 
*/ 
IsFullscreen(sWinTitle = "A", UseExcludeList = true, UseIncludeList=true) { 
    Static 
    Local iWinX, iWinY, iWinW, iWinH, iCltX, iCltY, iCltW, iCltH, iMidX, iMidY, iMonitor, c, D, iBestD 
    ErrorLevel := False
	;Without admin mode processes launched with admin permissions aren't detectable, so better treat all windows as non-fullscreen.
	if(!A_IsAdmin)
		return false
		
    ;Get the active window's dimension 
    hWin := WinExist(sWinTitle) 
    If Not hWin { 
        ErrorLevel := True 
        Return False 
    }
    
    ;Make sure it's not desktop 
    WinGetClass, c, ahk_id %hWin% 
    If (hWin = DllCall("GetDesktopWindow", "Ptr") Or (c = "Progman") Or (c = "WorkerW")) 
        Return False 
    ;Fullscreen include list
    if(UseIncludeList)
	{
		FullscreenInclude := Settings.Misc.FullScreenInclude
    	if c in %FullscreenInclude%
			return true
	}
    ;Fullscreen exclude list
    if(UseExcludeList)
	{
		FullscreenExclude := Settings.Misc.FullScreenExclude
    	if c in %FullscreenExclude%
			return false
	}
    ;Resolution change would only need to be detected every few seconds or so, but since it doesn't add anything notably to cpu usage, just do it always
    SysGet, Mon0, MonitorCount 
    SysGet, iPrimaryMon, MonitorPrimary 
    Loop %Mon0% { ;Loop through each monitor 
        SysGet, Mon%A_Index%, Monitor, %A_Index% 
        Mon%A_Index%MidX := Mon%A_Index%Left + Ceil((Mon%A_Index%Right - Mon%A_Index%Left) / 2) 
        Mon%A_Index%MidY := Mon%A_Index%Top + Ceil((Mon%A_Index%Top - Mon%A_Index%Bottom) / 2) 
    }    
			
    ;Get the window and client area, and style 
    VarSetCapacity(iWinRect, 16), VarSetCapacity(iCltRect, 16) 
    DllCall("GetWindowRect", "Ptr", hWin, "Ptr", &iWinRect) 
	DllCall("GetClientRect", "Ptr", hWin, "Ptr", &iCltRect)
    WinGet, iStyle, Style, ahk_id %hWin% 
    
    ;Extract coords and sizes 
    iWinX := NumGet(iWinRect, 0), iWinY := NumGet(iWinRect, 4) 
    iWinW := NumGet(iWinRect, 8) - NumGet(iWinRect, 0) ;Bottom-right coordinates are exclusive 
    iWinH := NumGet(iWinRect, 12) - NumGet(iWinRect, 4) ;Bottom-right coordinates are exclusive 
    iCltX := 0, iCltY := 0 ;Client upper-left always (0,0) 
    iCltW := NumGet(iCltRect, 8), iCltH := NumGet(iCltRect, 12) 
    ; outputdebug iCltW %iCltW% iCltH %iCltH%
    ;Check in which monitor it lies 
    iMidX := iWinX + Ceil(iWinW / 2) 
    iMidY := iWinY + Ceil(iWinH / 2) 
    
   ;Loop through every monitor and calculate the distance to each monitor 
   iBestD := 0xFFFFFFFF 
    Loop % Mon0 { 
      D := Sqrt((iMidX - Mon%A_Index%MidX)**2 + (iMidY - Mon%A_Index%MidY)**2) 
      If (D < iBestD) { 
         iBestD := D
         iMonitor := A_Index 
      } 
   } 
	
    ;Check if the client area covers the whole screen 
    bCovers := (iCltX <= Mon%iMonitor%Left) And (iCltY <= Mon%iMonitor%Top) And (iCltW >= Mon%iMonitor%Right - Mon%iMonitor%Left) And (iCltH >= Mon%iMonitor%Bottom - Mon%iMonitor%Top) 
    If(bCovers)
		Return True
    ;Check if the window area covers the whole screen and styles 
    bCovers := (iWinX <= Mon%iMonitor%Left) And (iWinY <= Mon%iMonitor%Top) And (iWinW >= Mon%iMonitor%Right - Mon%iMonitor%Left) And (iWinH >= Mon%iMonitor%Bottom - Mon%iMonitor%Top) 
    If (bCovers) ;WS_THICKFRAME or WS_CAPTION 
	{
        bCovers &= Not (iStyle & 0x00040000) Or Not (iStyle & 0x00C00000) 
		Return bCovers ? iMonitor : False 
    } 
	Else 
		Return False 
}

;Returns the workspace area covered by the active monitor
GetActiveMonitorWorkspaceArea(ByRef MonLeft, ByRef MonTop, ByRef MonW, ByRef MonH,hWndOrMouseX, MouseY = "")
{
	mon := GetActiveMonitor(hWndOrMouseX, MouseY)
	if(mon>=0)
	{
		SysGet, Mon, MonitorWorkArea, %mon%
		MonW := MonRight - MonLeft
		MonH := MonBottom - MonTop
	}
}

;Returns the monitor the mouse or the active window is in
GetActiveMonitor(hWndOrMouseX, MouseY = "")
{
	if(MouseY="")
	{
		WinGetPos,x,y,w,h,ahk_id %hWndOrMouseX%
		if(!x && !y && !w && !h)
		{
			MsgBox GetActiveMonitor(): invalid window handle!
			return -1
		}
		x := x + Round(w/2)
		y := y + Round(h/2)
	}
	else
	{
		x := hWndOrMouseX
		y := MouseY
	}
	;Loop through every monitor and calculate the distance to each monitor 
	iBestD := 0xFFFFFFFF 
	SysGet, Mon0, MonitorCount
	Loop %Mon0% { ;Loop through each monitor 
        SysGet, Mon%A_Index%, Monitor, %A_Index% 
        Mon%A_Index%MidX := Mon%A_Index%Left + Ceil((Mon%A_Index%Right - Mon%A_Index%Left) / 2) 
        Mon%A_Index%MidY := Mon%A_Index%Top + Ceil((Mon%A_Index%Top - Mon%A_Index%Bottom) / 2) 
    }
    Loop % Mon0 { 
      D := Sqrt((x - Mon%A_Index%MidX)**2 + (y - Mon%A_Index%MidY)**2) 
      If (D < iBestD) { 
         iBestD := D 
         iMonitor := A_Index 
      } 
   }
   return iMonitor
}
;Returns the (signed) minimum of the absolute values of x and y 
absmin(x,y)
{
	return abs(x) > abs(y) ? y : x
}

;Returns the (signed) maximum of the absolute values of x and y
absmax(x,y)
{
	return abs(x) < abs(y) ? y : x
}

;Returns 1 if x is positive or 0 and -1 if x is negative
sign(x)
{
	return x < 0 ? -1 : 1
}

;returns the maximum of xdir and y, but with the sign of xdir
dirmax(xdir,y)
{
	if(xdir = 0)
		return 0
	if(abs(xdir) > y)
		return xdir
	return xdir / abs(xdir) * abs(y)
}

;returns the maximum of xdir and y, but with the sign of xdir
dirmin(xdir,y)
{
	if(xdir = 0)
		return 0
	if(abs(xdir) < y)
		return xdir
	return xdir / abs(xdir) * abs(y)
}

;Formats a number in hexadecimal
DecToHex( ByRef var ) 
{ 
	f := A_FormatInteger
   SetFormat, Integer, Hex 
   var += 0
   ; SetFormat, Integer, %f%
   return var
}

;Determines if a string starts with another string. NOTE: It's a bit faster to simply use InStr(string, start) = 1
strStartsWith(string,start)
{	
	return InStr(string, start) = 1
}

;Determines if a string ends with another string
strEndsWith(string, end)
{
	return strlen(end) <= strlen(string) && Substr(string, -strlen(end) + 1) = end
}

;Removes all occurences of trim at the beginning and end of string
;trim can be an array of strings that should be removed.
strTrim(string, trim)
{
	return strTrimLeft(strTrimRight(string, trim), trim)
}

;Removes all occurences of trim at the beginning of string
;trim can be an array of strings that should be removed.
strTrimLeft(string, trim)
{
	if(!IsObject(trim))
		trim := [trim]
	for index, trimString in trim
	{
		len := strLen(trimString)
		while(InStr(string, trimString) = 1)
			StringTrimLeft, string, string, %len%
	}
	return string
}

;Removes all occurences of trim at the end of string
;trim can be an array of strings that should be removed.
strTrimRight(string, trim)
{
	if(!IsObject(trim))
		trim := [trim]
	for index, trimString in trim
	{
		len := strLen(trimString)
		while(strEndsWith(string, trimString))
			StringTrimRight, string, string, %len%
	}
	return string
}

;Finds the first window matching specific criterias.
FindWindow(title, class="", style="", exstyle="", processname="", allowempty = false)
{
	WinGet, id, list,,, Program Manager
	Loop, %id%
	{
		this_id := id%A_Index%
		WinGetClass, this_class, ahk_id %this_id%
		if(class && class!=this_class)
			Continue
		WinGetTitle, this_title, ahk_id %this_id%
		if(title && title!=this_title)
			Continue
		WinGet, this_style, style, ahk_id %this_id%
		if(style && style!=this_style)
			Continue
		WinGet, this_exstyle, exstyle, ahk_id %this_id%
		if(exstyle && exstyle!=this_exstyle)
			Continue			
		WinGetPos ,,,w,h,ahk_id %this_id%
		if(!allowempty && (w=0 || h=0))
			Continue		
		WinGet, this_processname, processname, ahk_id %this_id%
		if(processname && processname!=this_processname)
			Continue
		return this_id
	}
	return 0
}


;Gets the process name from a window handle.
GetProcessName(hwnd)
{
	WinGet, ProcessName, processname, ahk_id %hwnd%
	return ProcessName
}

;Gets the path of a process by its pid
GetModuleFileNameEx(pid) 
{ 
   if A_OSVersion in WIN_95,WIN_98,WIN_ME 
   { 
      MsgBox, This Windows version (%A_OSVersion%) is not supported. 
      return 
   } 

   /* 
      #define PROCESS_VM_READ           (0x0010) 
      #define PROCESS_QUERY_INFORMATION (0x0400) 
   */ 
   h_process := DllCall("OpenProcess", "uint", 0x10|0x400, "int", false, "uint", pid, "Ptr") 
   if (ErrorLevel || h_process = 0) 
   { 
      outputdebug [OpenProcess] failed. PID = %pid%
      return 
   } 
    
   name_size := A_IsUnicode ? 510 : 255 
   VarSetCapacity(name, name_size) 
    
   result := DllCall("psapi.dll\GetModuleFileNameEx", "Ptr", h_process, "uint", 0, "str", name, "uint", name_size) 
   if(ErrorLevel || result = 0) 
      outputdebug [GetModuleFileNameExA] failed 
    
   DllCall("CloseHandle", "Ptr", h_process)
   return name 
}

; Extract an icon from an executable, DLL or icon file. 
ExtractIcon(Filename, IconNumber = 0, IconSize = 64) 
{ 
    ; LoadImage is not used.. 
    ; ..with exe/dll files because: 
    ;   it only works with modules loaded by the current process, 
    ;   it needs the resource ordinal (which is not the same as an icon index), and 
    ; ..with ico files because: 
    ;   it can only load the first icon (of size %IconSize%) from an .ico file. 
    
    ; If possible, use PrivateExtractIcons, which supports any size of icon. 
	; r:=DllCall("PrivateExtractIcons" , "str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize, "Ptr*", h_icon, "PTR*", 0, "uint", 1, "uint", 0, "int") 
	;if !ErrorLevel 
	;	return h_icon 
	r := DllCall("Shell32.dll\SHExtractIconsW", "str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize, "Ptr*", h_icon, "Ptr*", pIconId, "uint", 1, "uint", 0, "int")
	If (!ErrorLevel && r != 0)
    	return h_icon
    return 0
}

;Gets the visible window at a screen coordinate
GetVisibleWindowAtPoint(x, y, IgnoredWindow)
{
	DetectHiddenWindows,off
	WinGet, id, list,,,
	Loop, %id%
	{
	    this_id := id%A_Index%
	    ;WinActivate, ahk_id %this_id%
	    WinGetClass, this_class, ahk_id %this_id%
	    WinGetPos , WinX, WinY, Width, Height, ahk_id %this_id%
	    if(IsInArea(x, y, WinX, WinY, Width, Height) && this_class != IgnoredWindow)
	    {
	    	DetectHiddenWindows, on
	    	return this_class
	    }
	}
	DetectHiddenWindows,on
}

;checks if a point is in a rectangle
IsInArea(px, py, x, y, w, h)
{
	return (px > x && py > y && px < x + w && py < y + h)
}

;Checks if two rectangles overlap
RectsOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
{
	Union := RectUnion(x1, y1, w1, h1, x2, y2, w2, h2)
	return Union.w && Union.h
}

;Checks if two rectangles are separate
RectsSeparate(x1, y1, w1, h1, x2, y2, w2, h2)
{
	Union := RectUnion(x1, y1, w1, h1, x2, y2, w2, h2)
	return Union.w = 0 && Union.h = 0
}

;Check if the first rectangle includes the second one
RectIncludesRect(x1, y1, w1, h1, ix, iy, iw, ih)
{
	Union := RectUnion(x1, y1, w1, h1, ix, iy, iw, ih)
	return Union.x = ix && Union.y = iy && Union.w = iw && Union.h = ih
}

;Calculates the union of two rectangles
RectUnion(x1, y1, w1, h1, x2, y2, w2, h2)
{
	x3 := ""
	y3 := ""
	
	;X Axis
	if(x1 > x2 && x1 < x2 + w2)
		x3 := x1
	else if(x2 > x1 && x2 < x1 + w1)
		x3 := x2
		
	if(y1 > y2 && y1 < y2 + h2)
		y3 := y1
	else if(y2 > y1 && y2 < y1 + h1)
		y3 := y2
	
	if(x3 != x1 && x3 != x2) ;Not overlapping
		w3 := 0
	else
		w3 := w1 - (x3 - x1) < w2 - (x3 - x2) ? w1 - (x3 - x1) : w2 - (x3 - x2) ;Choose the smaller width
	if(y3 != y1 && y3 != y2) ;Not overlapping
		h3 := 0
	else
		h3 := h1 - (y3 - y1) < h2 - (y3 - y2) ? h1 - (y3 - y1) : h2 - (y3 - y2) ;Choose the smaller height
	if(w3 = 0)
		h3 := 0
	else if(h3 = 0)
		w3 := 0
	return Object("x", x3, "y", y3, "w", w3, "h", h3)
}

;Gets window position using workspace coordinates (-> no taskbar)
WinGetPlacement(hwnd, ByRef x="", ByRef y="", ByRef w="", ByRef h="", ByRef state="") 
{ 
    VarSetCapacity(wp, 44), NumPut(44, wp) 
    DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", &wp) 
    x := NumGet(wp, 28, "int") 
    y := NumGet(wp, 32, "int") 
    w := NumGet(wp, 36, "int") - x 
    h := NumGet(wp, 40, "int") - y
	state := NumGet(wp, 8, "UInt")
	;outputdebug get x%x% y%y% w%w% h%h% state%state%
}

;Sets window position using workspace coordinates (-> no taskbar)
WinSetPlacement(hwnd, x="",y="",w="",h="",state="")
{
	WinGetPlacement(hwnd, x1, y1, w1, h1, state1)
	if(x = "")
		x := x1
	if(y = "")
		y := y1
	if(w = "")
		w := w1
	if(h = "")
		h := h1
	if(state = "")
		state := state1
	VarSetCapacity(wp, 44), NumPut(44, wp)
	if(state = 6)
		NumPut(7, wp, 8) ;SW_SHOWMINNOACTIVE
	else if(state = 1)
		NumPut(4, wp, 8) ;SW_SHOWNOACTIVATE
	else if(state = 3)
		NumPut(3, wp, 8) ;SW_SHOWMAXIMIZED and/or SW_MAXIMIZE
	else
		NumPut(state, wp, 8)
	NumPut(x, wp, 28, "Int")
    NumPut(y, wp, 32, "Int")
    NumPut(x+w, wp, 36, "Int")
    NumPut(y+h, wp, 40, "Int")
	DllCall("SetWindowPlacement", "Ptr", hwnd, "Ptr", &wp) 
}

;Checks if the current LClick hotkey comes from a double click
IsDoubleClick()
{	
	return A_TimeSincePriorHotkey < DllCall("GetDoubleClickTime") && A_ThisHotkey=A_PriorHotkey
}

;Checks if a specific control class is active. Matches by start of ClassNN.
IsControlActive(controlclass)
{
	if(WinVer >= WIN_7)
		ControlGetFocus active, A
	else
		active := XPGetFocussed()
	if(InStr(active, controlclass))
		return true
	return false
}

; This script retrieves the ahk_id (HWND) of the active window's focused control. 
; This script requires Windows 98+ or NT 4.0 SP3+. 
/*
typedef struct tagGUITHREADINFO {
  DWORD cbSize;
  DWORD flags;
  HWND  hwndActive;
  HWND  hwndFocus;
  HWND  hwndCapture;
  HWND  hwndMenuOwner;
  HWND  hwndMoveSize;
  HWND  hwndCaret;
  RECT  rcCaret;
} GUITHREADINFO, *PGUITHREADINFO;
*/
GetFocusedControl() 
{ 
   guiThreadInfoSize := 8 + 6 * A_PtrSize + 16
   VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0) 
   NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
   ; DllCall("RtlFillMemory" , "PTR", &guiThreadInfo, "UInt", 1 , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed 
   If(DllCall("GetGUIThreadInfo" , "UInt", 0   ; Foreground thread 
         , "PTR", &guiThreadInfo) = 0) 
   { 
      ErrorLevel := A_LastError   ; Failure 
      Return 0 
   } 
   focusedHwnd := NumGet(guiThreadInfo,8+A_PtrSize, "Ptr") ; *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24) 
   Return focusedHwnd 
} 

; Force kill program on Alt+F5 and on right click close button
CloseKill(hwnd)
{
	WinGet, pid, pid, ahk_id %hwnd%
	WinKill ahk_id %hwnd%
	if(WinExist("ahk_id " hwnd))
		Process, close, %pid%
}

/*
Converts a string list with separators to an array. It also removes and splits at quotes
To be parsed:

file a
file b

"file a"
"file b"

"file a" "file b"

"file a"|"file b"

file a|file b

*/
ToArray(SourceFiles, ByRef Separator = "`n", ByRef wasQuoted = 0)
{
	if(IsArray(SourceFiles))
		return SourceFiles
	files := Array()
	pos := 1
	wasQuoted := 0
	Loop
	{
		if(pos > strlen(SourceFiles))
			break
			
		char := SubStr(SourceFiles, pos, 1)
		if(char = """" || wasQuoted) ;Quoted paths
		{
			file := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos) + 1, InStr(SourceFiles, """", 0, pos + 1) - pos - 1)
			if(!wasQuoted)
			{
				wasQuoted := 1
				Separator := SubStr(SourceFiles, InStr(SourceFiles, """", 0, pos + 1) + 1, InStr(SourceFiles, """", 0, InStr(SourceFiles, """", 0, pos + 1) + 1) - InStr(SourceFiles, """", 0, pos + 1) - 1)
			}
			if(file)
			{
				files.Insert(file)
				pos += strlen(file) + 3
				continue
			}
			else
				Msgbox Invalid source format %SourceFiles%
		}
		else
		{
			file := SubStr(SourceFiles, pos, max(InStr(SourceFiles, Separator, 0, pos + 1) - pos, 0)) ; separator
			if(!file)
				file := SubStr(SourceFiles, pos) ;no quotes or separators, single file
			if(file)
			{
				files.Insert(file)
				pos += strlen(file) + strlen(Separator)
				continue
			}
			else
				Msgbox Invalid source format
		}
		pos++ ;Shouldn't happen
	}
	return files
}

;Flattens an array to a list with separators
ArrayToList(array, separator = "`n", quote = 0)
{
	Loop % array.MaxIndex()
		result .= (A_Index != 1 ? separator : "") (quote ? """" : "") array[A_Index] (quote ? """" : "")
	return result
}

;Compares two (already separated) version numbers. Returns 1 if 1st is greater, 0 if equal, -1 if second is greater
CompareVersion(major1,major2,minor1,minor2,bugfix1,bugfix2)
{
	if(major1 > major2)
		return 1
	else if(major1 = major2 && minor1 > minor2)
		return 1
	else if(major1 = major2 && minor1 = minor2 && bugfix1 > bugfix2)
		return 1
	else if(major1 = major2 && minor1 = minor2 && bugfix1 = bugfix2)
		return 0
	else
		return -1
}

;Returns true if x is a number
IsNumeric(x)
{
   If x is number 
      Return 1 
   Return 0 
}

;Performs quote unescaping of a string. Transforms \" to " and \\ to \
StringUnescape(String)
{
	return StringReplace(StringReplace(StringReplace(String, "\\", Chr(1), 1), "\""", """", 1), Chr(1), "\", 1)
}
;Performs quote escaping of a string. Transforms " to \" and \ to \\
StringEscape(String)
{
	return StringReplace(StringReplace(String, "\", "\\", 1), """", "\""", 1)
}
;Decodes a URL
uriDecode(str) { 
   Loop 
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex) 
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All 
      Else Break 
   Return, str 
}

; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(str, Enc = "UTF-8")
{
	try
	{
	    oSC := ComObjCreate("ScriptControl")
	    oSC.Language := "JScript"
	    Script := "var Encoded = encodeURIComponent(""" . str . """)"
	    oSC.ExecuteStatement(Script)
	    encoded := oSC.Eval("Encoded")
	    Return encoded
	}
	catch e
	{
		StrPutVar(str, Var, Enc)
		f := A_FormatInteger
		SetFormat, IntegerFast, H
		Loop
		{
			Code := NumGet(Var, A_Index - 1, "UChar")
			If (!Code)
				Break
			If (Code >= 0x30 && Code <= 0x39 ; 0-9
			 || Code >= 0x41 && Code <= 0x5A ; A-Z
			 || Code >= 0x61 && Code <= 0x7A) ; a-z
				Res .= Chr(Code)
			Else
				Res .= "%" . SubStr(Code + 0x100, -1)
		}
		SetFormat, IntegerFast, %f%
		Return, Res
	}
}

StrPutVar(Str, ByRef Var, Enc = "")
{
   Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
   VarSetCapacity(Var, Len, 0)
   Return, StrPut(Str, &Var, Enc)
}

;Old function for codepage conversions. AHK_L can do this now.
Unicode2Ansi(ByRef wString, ByRef sString, CP = 0) 
{ 
	nSize := DllCall("WideCharToMultiByte" , "Uint", CP, "Uint", 0 , "UintP", wString , "int",  -1 , "Uint", 0 , "int",  0 , "Uint", 0 , "Uint", 0) 
	VarSetCapacity(sString, nSize) 
	DllCall("WideCharToMultiByte" , "Uint", CP , "Uint", 0 , "UintP", wString , "int",  -1 , "str",  sString , "int",  nSize , "Uint", 0 , "Uint", 0) 
}

;Old function for codepage conversions. AHK_L can do this now.
Ansi2Unicode(ByRef sString, ByRef wString, CP = 0) 
{ 
	nSize := DllCall("MultiByteToWideChar" , "Uint", CP , "Uint", 0 , "UintP", sString , "int",  -1 , "Uint", 0 , "int",  0) 
	VarSetCapacity(wString, nSize * 2) 
	DllCall("MultiByteToWideChar" , "Uint", CP , "Uint", 0 , "UintP",  sString , "int",  -1 , "UintP", wString , "int",  nSize) 
}

;Performs a fuzzy search for string2 in string1.
;return values range from 0.0 = identical to 1.0 = completely different. 0.4 seems appropriate
FuzzySearch(longer, shorter, UseFuzzySearch = false)
{
	if(longer = shorter)
		return 1

	lenl := StrLen(longer)
	lens := StrLen(shorter)

	if(lens > lenl)
		return 0

	;Check if the shorter string is a substring of the longer string
	Contained := InStr(longer, shorter)
	if(Contained)
		return Contained = 1 ? 1 : 0.8

	;Check if string can be matched by omitting characters
	if(lens < 5)
	{
		pos := 0
		matched := 0
		Loop % lens
		{
			char := SubStr(shorter, A_Index, 1)
			StringUpper, char, char
			Loop % lenl - pos
			{
				if(SubStr(longer, pos + A_Index, 1) == char)
				{
					pos := A_Index
					matched++
					break
				}
				else
					continue
			}
		}
		if(matched = lens)
			return 0.9 ;Slightly worse than direct matches
	}
	;Calculate fuzzy string difference
	if(UseFuzzySearch)
	{
		max := 0
		Loop % lenl - lens + 1
		{
			distance := 1 - StringDifference(shorter, SubStr(longer, A_Index, lens))
			if(distance < max)
				max := distance
		}
		return max
	}
	return 0
}
;By Toralf:
;basic idea for SIFT3 code by Siderite Zackwehdex 
;http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html 
;took idea to normalize it to longest string from Brad Wood 
;http://www.bradwood.com/string_compare/ 
;Own work: 
; - when character only differ in case, LSC is a 0.8 match for this character 
; - modified code for speed, might lead to different results compared to original code 
; - optimized for speed (30% faster then original SIFT3 and 13.3 times faster than basic Levenshtein distance) 
;http://www.autohotkey.com/forum/topic59407.html 
StringDifference(string1, string2, maxOffset=3) {    ;returns a float: between "0.0 = identical" and "1.0 = nothing in common" 
  If (string1 = string2) 
    Return (string1 == string2 ? 0/1 : 0.2/StrLen(string1))    ;either identical or (assumption:) "only one" char with different case 
  If (string1 = "" OR string2 = "") 
    Return (string1 = string2 ? 0/1 : 1/1) 
  StringSplit, n, string1 
  StringSplit, m, string2 
  ni := 1, mi := 1, lcs := 0 
  While((ni <= n0) AND (mi <= m0)) { 
    If (n%ni% == m%mi%) 
      EnvAdd, lcs, 1 
    Else If (n%ni% = m%mi%) 
      EnvAdd, lcs, 0.8 
    Else{ 
      Loop, %maxOffset%  { 
        oi := ni + A_Index, pi := mi + A_Index 
        If ((n%oi% = m%mi%) AND (oi <= n0)){ 
            ni := oi, lcs += (n%oi% == m%mi% ? 1 : 0.8) 
            Break 
        } 
        If ((n%ni% = m%pi%) AND (pi <= m0)){ 
            mi := pi, lcs += (n%ni% == m%pi% ? 1 : 0.8) 
            Break 
        } 
      } 
    } 
    EnvAdd, ni, 1 
    EnvAdd, mi, 1 
  } 
  Return ((n0 + m0)/2 - lcs) / (n0 > m0 ? n0 : m0) 
}

;Returns true if the string is in URL format. Use CouldBeURL() for weaker checks.
IsURL(string)
{
	return RegexMatch(strTrim(string, " "), "(?:(?:ht|f)tps?://|www\.).+\..+") > 0
}
;Returns true if the string could be a URL. Use IsURL() to be sure.
CouldBeURL(string)
{
	return RegexMatch(strTrim(string, " "), "(?:(?:ht|f)tps?://|www\.)?.+\..+") > 0
}

;Tests for write access to a specific file
WriteAccess( F ) {
	if(FileExist(F))
		Return ((h := DllCall("_lopen", AStr, F, Int, 1, "Ptr")) > 0 ? 1 : 0) (DllCall("_lclose", "Ptr", h) + NULL) 
	else
	{
		SplitPath, F,,Dir
		F := FindFreeFilename(Dir)
		FileAppend, x, %F%
		Success := !ErrorLevel
		FileDelete, %F%
		return !ErrorLevel
	}
}

;Generates MD5 value of a file
FileMD5(sFile´= "", cSz = 4 )
{ ; www.autohotkey.com/forum/viewtopic.php?p=275910#275910 
	cSz := (cSz < 0 || cSz > 8) ? 2 ** 22 : 2 ** (18 + cSz)
	VarSetCapacity(Buffer, cSz, 0) 
	hFil := DllCall("CreateFile", Str, sFile, UInt, 0x80000000, Int, 1, Int, 0, Int, 3, Int, 0, Int, 0, "Ptr") 
	if(hFil < 1)
		return hFil
	DllCall("GetFileSizeEx", Ptr, hFil, Ptr, &Buffer)
	fSz := NumGet(Buffer, 0, "Int64")
	VarSetCapacity(MD5_CTX, 104, 0)
	DllCall("advapi32\MD5Init", PTR, &MD5_CTX)
	Loop % (fSz // cSz + !!Mod(fSz, cSz))
	DllCall("ReadFile", PTR, hFil, PTR, &Buffer, UInt, cSz, UIntP, bytesRead, UInt, 0)
	DllCall("advapi32\MD5Update", PTR, &MD5_CTX, PTR, &Buffer, UInt,bytesRead)
	DllCall("advapi32\MD5Final", PTR, &MD5_CTX )
	DllCall("CloseHandle", PTR, hFil)
	Loop % StrLen(Hex := "123456789ABCDEF0")
	{
		N := NumGet(MD5_CTX, 87 + A_Index, "Char")
		MD5 .= SubStr(Hex, N >> 4, 1) SubStr(Hex, N & 15, 1)
	}
	return MD5
}

;Formats a file size in bytes to a human-readable size string
FormatFileSize(Bytes, Decimals = 1, Prefixes = "B,KB,MB,GB,TB,PB,EB,ZB,YB")
{
	StringSplit, Prefix, Prefixes, `,
	Loop, Parse, Prefixes, `,
		if(Bytes < e := 1024 ** A_Index)
			return % Round(Bytes / (e / 1024), decimals) Prefix%A_Index%
}

;Returns a string containing the formatted object keys and values
ExploreObj(Obj, NewRow = "`n", Equal = "  =  ", Indent = "`t", Depth = 12, CurIndent = "")
{
    for k,v in Obj
        ToReturn .= CurIndent k (IsObject(v) && depth > 1 ? NewRow ExploreObj(v, NewRow, Equal, Indent, Depth - 1, CurIndent Indent) : Equal v) NewRow
    return RTrim(ToReturn, NewRow)
}


GetFullPathName(SPath)
{
	VarSetCapacity(lPath,A_IsUnicode ? 520 : 260, 0)
	DllCall("GetLongPathName", Str, SPath, Str, lPath, UInt, 260)
	Return lPath 
}

;This function calls a function of an event on every key in it
objDeepPerform(obj, function, Event)
{
	if(!IsFunc(function))
		return
	if(obj.HasKey("base"))
		objDeepPerform(obj.base, function, Event)
	enum := obj._newenum() 
	while enum[key, value] 
	{
		if(IsObject(value))
			objDeepPerform(value, function, Event)
		else
			obj[key] := %function%(Event, value)
	}
}

;Finds a non-existing filename for Filepath by appending a number in brackets to the name
FindFreeFileName(FilePath)
{
	SplitPath, FilePath,, dir, extension, filename
	Testpath := FilePath ;Return path if it doesn't exist
	i := 1
	while FileExist(TestPath)
	{
		i++
		Testpath := dir "\" filename " (" i ")" (extension = "" ? "" : "." extension)
	}
	return TestPath
}

;Attaches a window as a tool window to another window from a different process. QUESTION: Is this still needed?
AttachToolWindow(hParent, GUINumber, AutoClose)
{
	global ToolWindows
	outputdebug AttachToolWindow %GUINumber% to %hParent%
	if(!IsObject(ToolWindows))
		ToolWindows := Object()
	if(!WinExist("ahk_id " hParent))
		return false
	Gui %GUINumber%: +LastFoundExist
	if(!(hGui := WinExist()))
		return false
	;SetWindowLongPtr is defined as SetWindowLong in x86
	if(A_PtrSize = 4)
		DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
	else
		DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
	ToolWindows.Insert(Object("hParent", hParent, "hGui", hGui,"AutoClose", AutoClose))
	Gui %GUINumber%: Show, NoActivate
	return true
}

DeAttachToolWindow(GUINumber)
{
	global ToolWindows
	Gui %GUINumber%: +LastFoundExist
	if(!(hGui := WinExist()))
		return false
	Loop % ToolWindows.MaxIndex()
	{
		if(ToolWindows[A_Index].hGui = hGui)
		{
			;SetWindowLongPtr is defined as SetWindowLong in x86
			if(A_PtrSize = 4)
				DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
			else
				DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
			DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0)
			ToolWindows.Remove(A_Index)
			break
		}
	}
}

;Adds a tooltip to a control.
AddToolTip(con, text, Modify = 0)
{
	Static TThwnd,GuiHwnd
	l_DetectHiddenWindows := A_DetectHiddenWindows
	If(!TThwnd)
	{
		Gui, +LastFound
		GuiHwnd := WinExist()
		TThwnd := CreateTooltipControl(GuiHwnd)
		Varsetcapacity(TInfo, 6 * 4 + 6 * A_PtrSize, 0)
		Numput(6 * 4 + 6 * A_PtrSize, TInfo, "UInt")
		Numput(1 | 16, TInfo, 4, "UInt")
		Numput(GuiHwnd, TInfo, 8, "PTR")
		Numput(GuiHwnd, TInfo, 8 + A_PtrSize, "PTR")
		;Numput(&text,TInfo,36)
		Detecthiddenwindows, on
		Sendmessage, 1028, 0, &TInfo, , ahk_id %TThwnd%
		SendMessage, 1048, 0, 300, , ahk_id %TThwnd%
	}
	Varsetcapacity(TInfo, 6 * 4 + 6 * A_PtrSize, 0)
	Numput(6 * 4 + 6 * A_PtrSize, TInfo, "UInt")
	Numput(1 | 16, TInfo, 4, "UInt")
	Numput(GuiHwnd, TInfo, 8, "PTR")
	Numput(con, TInfo, 8 + A_PtrSize, "PTR")
	VarSetCapacity(ANSItext, StrPut(text, ""))
    StrPut(text, &ANSItext, "")
	Numput(&ANSIText, TInfo, 6 * 4 + 3 * A_PtrSize, "PTR")

	Detecthiddenwindows, on
	if(Modify)
		SendMessage, 1036, 0, &TInfo, , ahk_id %TThwnd%
	else
	{
		Sendmessage, 1028, 0, &TInfo, , ahk_id %TThwnd%
		SendMessage, 1048, 0, 300, , ahk_id %TThwnd%
	}
	DetectHiddenWindows %l_DetectHiddenWindows%
}
CreateTooltipControl(hwind)
{
	Ret := DllCall("CreateWindowEx"
	,"Uint", 0
	,"Str", "TOOLTIPS_CLASS32"
	,"PTR", 0
	,"Uint", 2147483648 | 3
	,"Uint", -2147483648
	,"Uint", -2147483648
	,"Uint", -2147483648
	,"Uint", -2147483648
	,"PTR", hwind
	,"PTR", 0
	,"PTR", 0
	,"PTR", 0, "PTR")
	return Ret
}

;Gets width of all screens combined. NOTE: Single screens may have different vertical resolutions so some parts of the area returned here might not belong to any screens!
GetVirtualScreenCoordinates(ByRef x, ByRef y, ByRef w, ByRef h)
{
	SysGet, x, 76 ;Get virtual screen coordinates of all monitors
	SysGet, y, 77
	SysGet, w, 78
	SysGet, h, 79
}
;Determines if a window is visible completely on the screen. Returns 1 if it is, 2 if it's partially on a screen (also if between monitors) and 0 if it's outside of all screens.
IsWindowOnScreen(hwnd)
{
	if(IsObject(hwnd))
	{
		x := hwnd.x
		y := hwnd.y
		w := hwnd.w
		h := hwnd.h
	}
	else
		WinGetPos, x, y, w, h, ahk_id %hwnd%
	Monitors := GetMonitors()
	for index, Monitor in Monitors
	{
		if(RectIncludesRect(Monitor.x, Monitor.y, Monitor.w, Monitor.h, x, y, w, h))
			return 1
		if(RectsOverlap(Monitor.x, Monitor.y, Monitor.w, Monitor.h, x, y, w, h))
			return 2
	}
	return 0
}
GetMonitors()
{
	Monitors := []
	SysGet, Mon0, MonitorCount
	;Loop through each monitor
    Loop %Mon0%
    { 
        SysGet, Mon, Monitor, %A_Index%
        Monitor := {}
        Monitor.X := MonLeft
        Monitor.Y := MonTop
        Monitor.Width := MonRight - Monitor.X
        Monitor.Height := MonBottom - Monitor.Y
        Monitors.Insert(Monitor)
    }
    return Monitors
}
GetMonitorWorkAreas()
{
	Monitors := []
	SysGet, Mon0, MonitorCount
	;Loop through each monitor
    Loop %Mon0%
    { 
        SysGet, Mon, MonitorWorkArea, %A_Index%
        Monitor := {}
        Monitor.X := MonLeft
        Monitor.Y := MonTop
        Monitor.Width := MonRight - Monitor.X
        Monitor.Height := MonBottom - Monitor.Y
        Monitors.Insert(Monitor)
    }
    return Monitors
}
;WinGetPos function wrapper
WinGetPos(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
{
	WinGetPos, x, y, w, h, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return Object("x", x, "y", y, "w", w, "h", h)
}

;WinMove function wrapper
WinMove(WinTitle, Rect, WinText = "", ExcludeTitle = "", ExcludeText = "")
{
	WinMove, %WinTitle%, %WinText%, % Rect.x, % Rect.y, % Rect.w, % Rect.h, %ExcludeTitle%, %ExcludeText%
}

;Returns true if a window is visible in Alt+Tab list
IsAltTabWindow(hwnd)
{
	if(!hwnd)
		return false
	WinGet, ExStyle, ExStyle, ahk_id %hwnd%
	if(ExStyle & 0x80) ;WS_EX_TOOLWINDOW
		return false
	hwndWalk := DllCall("GetAncestor", "PTR", hwnd, "INT", 3, "PTR")

	; See if we are the last active visible popup
	while((hwndTry := DllCall("GetLastActivePopup", "PTR", hwndWalk, "PTR")) != hwndWalk)
	{
		if(DllCall("IsWindowVisible", "PTR", hwndTry)) 
			break
		hwndWalk := hwndTry
	}
	return hwndWalk = hwnd
}

;Gets ClassNN from hwnd
HWNDToClassNN(hwnd)
{
	win := DllCall("GetParent", "PTR", hwnd, "PTR")
	WinGet ctrlList, ControlList, ahk_id %win%
	; Built an array indexing the control names by their hwnd 
	Loop Parse, ctrlList, `n 
	{
		ControlGet hwnd1, Hwnd, , %A_LoopField%, ahk_id %win%
		if(hwnd1=hwnd)
			return A_LoopField
	}
}

;Gets focused control in XP to prevent blocking double clicks like with ControlGetFocus
XPGetFocussed()
{
  WinGet ctrlList, ControlList, A 
  ctrlHwnd:=GetFocusedControl()
  ; Built an array indexing the control names by their hwnd 
  Loop Parse, ctrlList, `n 
  {
    ControlGet hwnd, Hwnd, , %A_LoopField%, A 
    hwnd += 0   ; Convert from hexa to decimal 
    if(hwnd=ctrlHwnd)
      return A_LoopField
  } 
}

;Watches a directory/file for file changes
;By HotKeyIt
;Docs: http://www.autohotkey.com/forum/viewtopic.php?p=398565#398565
WatchDirectory(p*){ 
   global _Struct 
   ;Structures 
   static FILE_NOTIFY_INFORMATION:="DWORD NextEntryOffset,DWORD Action,DWORD FileNameLength,WCHAR FileName[1]" 
   static OVERLAPPED:="ULONG_PTR Internal,ULONG_PTR InternalHigh,{struct{DWORD offset,DWORD offsetHigh},PVOID Pointer},HANDLE hEvent" 
   ;Variables 
   static running,sizeof_FNI=65536,WatchDirectory:=RegisterCallback("WatchDirectory","F",0,0) ;,nReadLen:=VarSetCapacity(nReadLen,8)
   static timer,ReportToFunction,LP,nReadLen:=VarSetCapacity(LP,(260)*(A_PtrSize/2),0) 
   static @:=Object(),reconnect:=Object(),#:=Object(),DirEvents,StringToRegEx="\\\|.\.|+\+|[\[|{\{|(\(|)\)|^\^|$\$|?\.?|*.*" 
   ;ReadDirectoryChanges related 
   static FILE_NOTIFY_CHANGE_FILE_NAME=0x1,FILE_NOTIFY_CHANGE_DIR_NAME=0x2,FILE_NOTIFY_CHANGE_ATTRIBUTES=0x4 
         ,FILE_NOTIFY_CHANGE_SIZE=0x8,FILE_NOTIFY_CHANGE_LAST_WRITE=0x10,FILE_NOTIFY_CHANGE_CREATION=0x40 
         ,FILE_NOTIFY_CHANGE_SECURITY=0x100 
   static FILE_ACTION_ADDED=1,FILE_ACTION_REMOVED=2,FILE_ACTION_MODIFIED=3 
         ,FILE_ACTION_RENAMED_OLD_NAME=4,FILE_ACTION_RENAMED_NEW_NAME=5 
   static OPEN_EXISTING=3,FILE_FLAG_BACKUP_SEMANTICS=0x2000000,FILE_FLAG_OVERLAPPED=0x40000000 
         ,FILE_SHARE_DELETE=4,FILE_SHARE_WRITE=2,FILE_SHARE_READ=1,FILE_LIST_DIRECTORY=1 
   If p.MaxIndex(){ 
      If (p.MaxIndex()=1 && p.1=""){ 
         for i,folder in # 
            DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent) 
            ,@.Remove(folder) 
         #:=Object() 
         DirEvents:=new _Struct("HANDLE[1000]") 
         DllCall("KillTimer","Uint",0,"Uint",timer) 
         timer= 
         Return 0 
      } else { 
         if p.2 
            ReportToFunction:=p.2 
         If !IsFunc(ReportToFunction) 
            Return -1 ;DllCall("MessageBox","Uint",0,"Str","Function " ReportToFunction " does not exist","Str","Error Missing Function","UInt",0) 
         RegExMatch(p.1,"^([^/\*\?<>\|""]+)(\*)?(\|.+)?$",dir) 
         if (SubStr(dir1,0)="\") 
            StringTrimRight,dir1,dir1,1 
         StringTrimLeft,dir3,dir3,1 
         If (p.MaxIndex()=2 && p.2=""){ 
            for i,folder in # 
               If (dir1=SubStr(folder,1,StrLen(folder)-1)) 
                  Return 0 ,DirEvents[i]:=DirEvents[#.MaxIndex()],DirEvents[#.MaxIndex()]:=0 
                           @.Remove(folder),#[i]:=#[#.MaxIndex()],#.Remove(i) 
            Return 0 
         } 
      } 
      if !InStr(FileExist(dir1),"D") 
         Return -1 ;DllCall("MessageBox","Uint",0,"Str","Folder " dir1 " does not exist","Str","Error Missing File","UInt",0) 
      for i,folder in # 
      { 
         If (dir1=SubStr(folder,1,StrLen(folder)-1) || (InStr(dir1,folder) && @[folder].sD)) 
               Return 0 
         else if (InStr(SubStr(folder,1,StrLen(folder)-1),dir1 "\") && dir2){ ;replace watch 
            DllCall("CloseHandle","Uint",@[folder].hD),DllCall("CloseHandle","Uint",@[folder].O.hEvent),reset:=i 
         } 
      } 
      LP:=SubStr(LP,1,DllCall("GetLongPathName","Str",dir1,"Uint",&LP,"Uint",VarSetCapacity(LP))) "\" 
      If !(reset && @[reset]:=LP) 
         #.Insert(LP) 
      @[LP,"dir"]:=LP 
      @[LP].hD:=DllCall("CreateFile","Str",StrLen(LP)=3?SubStr(LP,1,2):LP,"UInt",0x1,"UInt",0x1|0x2|0x4 
                  ,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0) 
      @[LP].sD:=(dir2=""?0:1) 

      Loop,Parse,StringToRegEx,| 
         StringReplace,dir3,dir3,% SubStr(A_LoopField,1,1),% SubStr(A_LoopField,2),A 
      StringReplace,dir3,dir3,%A_Space%,\s,A 
      Loop,Parse,dir3,| 
      { 
         If A_Index=1 
            dir3= 
         pre:=(SubStr(A_LoopField,1,2)="\\"?2:0) 
         succ:=(SubStr(A_LoopField,-1)="\\"?2:0) 
         dir3.=(dir3?"|":"") (pre?"\\\K":"") 
               . SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ) 
               . ((!succ && !InStr(SubStr(A_LoopField,1+pre,StrLen(A_LoopField)-pre-succ),"\"))?"[^\\]*$":"") (succ?"$":"") 
      } 
      @[LP].FLT:="i)" dir3 
      @[LP].FUNC:=ReportToFunction 
      @[LP].CNG:=(p.3?p.3:(0x1|0x2|0x4|0x8|0x10|0x40|0x100)) 
      If !reset { 
         @[LP].SetCapacity("pFNI",sizeof_FNI) 
         @[LP].FNI:=new _Struct(FILE_NOTIFY_INFORMATION,@[LP].GetAddress("pFNI")) 
         @[LP].O:=new _Struct(OVERLAPPED) 
      } 
      @[LP].O.hEvent:=DllCall("CreateEvent","Uint",0,"Int",1,"Int",0,"UInt",0) 
      If (!DirEvents) 
         DirEvents:=new _Struct("HANDLE[1000]") 
      DirEvents[reset?reset:#.MaxIndex()]:=@[LP].O.hEvent 
      DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI 
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0) 
      Return timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory) 
   } else { 
      Sleep, 0 
      for LP in reconnect 
      { 
         If (FileExist(@[LP].dir) && reconnect.Remove(LP)){ 
            DllCall("CloseHandle","Uint",@[LP].hD) 
            @[LP].hD:=DllCall("CreateFile","Str",StrLen(@[LP].dir)=3?SubStr(@[LP].dir,1,2):@[LP].dir,"UInt",0x1,"UInt",0x1|0x2|0x4 
                  ,"UInt",0,"UInt",0x3,"UInt",0x2000000|0x40000000,"UInt",0) 
            DllCall("ResetEvent","UInt",@[LP].O.hEvent) 
            DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI 
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0) 
         } 
      } 
      if !( (r:=DllCall("MsgWaitForMultipleObjectsEx","UInt",#.MaxIndex() 
               ,"UInt",DirEvents[],"UInt",0,"UInt",0x4FF,"UInt",6))>=0 
               && r<#.MaxIndex() ){ 
         return 
      } 
      DllCall("KillTimer", UInt,0, UInt,timer) 
      LP:=#[r+1],DllCall("GetOverlappedResult","UInt",@[LP].hD,"UInt",@[LP].O[],"UIntP",nReadLen,"Int",1) 
      If (A_LastError=64){ ; ERROR_NETNAME_DELETED - The specified network name is no longer available. 
         If !FileExist(@[LP].dir) ; If folder does not exist add to reconnect routine 
            reconnect.Insert(LP,LP) 
      } else 
         Loop { 
            FNI:=A_Index>1?(new _Struct(FILE_NOTIFY_INFORMATION,FNI[]+FNI.NextEntryOffset)):(new _Struct(FILE_NOTIFY_INFORMATION,@[LP].FNI[])) 
            If (FNI.Action < 0x6){ 
               FileName:=@[LP].dir . StrGet(FNI.FileName[""],FNI.FileNameLength/2,"UTF-16") 
               If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME) 
                     FileFromOptional:=FileName 
               If (@[LP].FLT="" || RegExMatch(FileName,@[LP].FLT) || FileFrom) 
                  If (FNI.Action=FILE_ACTION_ADDED){ 
                     FileTo:=FileName 
                  } else If (FNI.Action=FILE_ACTION_REMOVED){ 
                     FileFrom:=FileName 
                  } else If (FNI.Action=FILE_ACTION_MODIFIED){ 
                     FileFrom:=FileTo:=FileName 
                  } else If (FNI.Action=FILE_ACTION_RENAMED_OLD_NAME){ 
                     FileFrom:=FileName 
                  } else If (FNI.Action=FILE_ACTION_RENAMED_NEW_NAME){ 
                     FileTo:=FileName 
                  } 
          If (FNI.Action != 4 && (FileTo . FileFrom) !="") 
                  @[LP].Func(FileFrom=""?FileFromOptional:FileFrom,FileTo) 
            } 
         } Until (!FNI.NextEntryOffset || ((FNI[]+FNI.NextEntryOffset) > (@[LP].FNI[]+sizeof_FNI-12))) 
      DllCall("ResetEvent","UInt",@[LP].O.hEvent) 
      DllCall("ReadDirectoryChangesW","UInt",@[LP].hD,"UInt",@[LP].FNI[],"UInt",sizeof_FNI 
               ,"Int",@[LP].sD,"UInt",@[LP].CNG,"UInt",0,"UInt",@[LP].O[],"UInt",0) 
      timer:=DllCall("SetTimer","Uint",0,"UInt",timer,"Uint",50,"UInt",WatchDirectory) 
      Return 
   } 
   Return 
}

;Clamps a value
Clamp(value, min, max)
{
	if(value < min)
		value := min
	else if(value > max)
		value := max
	return value
}

;Generates 7plus version string
VersionString(Short = 0)
{
	global
	if(Short)
		return MajorVersion "." MinorVersion "." BugfixVersion
	else
		return MajorVersion "." MinorVersion "." BugfixVersion "." PatchVersion
}

;Generates an UUID
uuid(c = false) { ; v1.1 - by Titan 
   static n = 0, l, i 
   f := A_FormatInteger, t := A_Now, s := "-" 
   SetFormat, Integer, H 
   t -= 1970, s 
   t := (t . A_MSec) * 10000 + 122192928000000000 
   If !i and c { 
      Loop, HKLM, System\MountedDevices 
      If i := A_LoopRegName 
         Break 
      StringGetPos, c, i, %s%, R2 
      StringMid, i, i, c + 2, 17 
   } Else { 
      Random, x, 0x100, 0xfff 
      Random, y, 0x10000, 0xfffff 
      Random, z, 0x100000, 0xffffff 
      x := 9 . SubStr(x, 3) . s . 1 . SubStr(y, 3) . SubStr(z, 3) 
   } t += n += l = A_Now, l := A_Now 
   SetFormat, Integer, %f% 
   Return, SubStr(t, 10) . s . SubStr(t, 6, 4) . s . 1 . SubStr(t, 3, 3) . s . (c ? i : x) 
}

;Extracted from HotkeyIts WatchDirectory function
ConvertFilterStringToRegex(FilterString)
{
	StringToRegEx := "\\\|.\.|+\+|[\[|{\{|(\(|)\)|^\^|$\$|?\.?|*.*"
	Loop,Parse,StringToRegEx,|
		StringReplace,FilterString,FilterString,% SubStr(A_LoopField,1,1),% SubStr(A_LoopField,2),A
	StringReplace,FilterString,FilterString,%A_Space%,\s,A
	return "i)" FilterString
}

;Gets client area of a window
GetClientRect(hwnd)
{
	VarSetCapacity(rc, 16)
	result := DllCall("GetClientRect", "PTR", hwnd, "PTR", &rc, "UINT")
	return {x : NumGet(rc, 0, "int"), y : NumGet(rc, 4, "int"), w : NumGet(rc, 8, "int"), h : NumGet(rc, 12, "int")}
}

;Gets the selected text by copying it to the clipboard.
;OnClipboardChange ignores this due to MuteClipboardList flag, however, calling this function changes the clipboard owner to AHK.
GetSelectedText()
{
	global MuteClipboardList
	MuteClipboardList := true
	clipboardbackup := clipboardall
	clipboard := ""
	WaitForEvent("ClipboardChange", 100)
	Send ^c
	WaitForEvent("ClipboardChange", 100)
	result := clipboard
	clipboard := clipboardbackup
	WaitForEvent("ClipboardChange", 100)
	MuteClipboardList := false
	return result
}

;Gets all kind of window information of open windows.
GetWindowInfo()
{
	global WindowList
	WS_EX_CONTROLPARENT :=0x10000
	WS_EX_DLGMODALFRAME :=0x1
	WS_CLIPCHILDREN :=0x2000000
	WS_EX_APPWINDOW :=0x40000
	WS_EX_TOOLWINDOW :=0x80
	WS_DISABLED :=0x8000000
	WS_VSCROLL :=0x200000
	WS_POPUP :=0x80000000
	
	windows := Array()
	DetectHiddenWindows, Off
	WinGet, Window_List, List ; Gather a list of running programs
	hInstance := GetModuleHandle(0)
	order := 0
	Loop, %Window_List%
	{
		wid := Window_List%A_Index%
		WinGetTitle, wid_Title, ahk_id %wid%
		WinGet, Style, Style, ahk_id %wid%

		If ((Style & WS_DISABLED) or ! (wid_Title)) ; skip unimportant windows ; ! wid_Title or 
			Continue

		WinGet, es, ExStyle, ahk_id %wid%
		Parent := Parent := GetParent(wid)
		WinGet, Style_parent, Style, ahk_id %Parent%
		Owner := Owner := GetWindow(wid, 4) ; GW_OWNER = 4
		WinGet, Style_Owner, Style, ahk_id %Owner%

		If (((es & WS_EX_TOOLWINDOW)  and !(Parent)) ; filters out program manager, etc
		or ( !(es & WS_EX_APPWINDOW)
		and (((Parent) and ((Style_parent & WS_DISABLED) =0)) ; These 2 lines filter out windows that have a parent or owner window that is NOT disabled -
		or ((Owner) and ((Style_Owner & WS_DISABLED) =0))))) ; NOTE - some windows result in blank value so must test for zero instead of using NOT operator!
			continue
		if(wid_Title = CAccessor.Instance.GUI.Title)
			continue
		if(WindowList.HasKey(wid))
			Exe_Name := WindowList[wid].Executable
		else
			WinGet, Exe_Name, ProcessName, ahk_id %wid%
		WinGet, PID, PID, ahk_id %wid%
		FullPath := GetModuleFileNameEx(PID)
		WinGetClass, Win_Class, ahk_id %wid%
		hw_popup := hw_popup := DllCall("GetLastActivePopup", "Ptr", wid)

		Dialog := 0 ; init/reset
		If (Parent and ! Style_parent)
			CPA_file_name := GetCPA_file_name( wid ) ; check if it's a control panel window
		Else
			CPA_file_name =
		If (CPA_file_name or (Win_Class ="#32770") or ((style & WS_POPUP) and (es & WS_EX_DLGMODALFRAME)))
			Dialog =1 ; found a Dialog window
		If (CPA_file_name)
			hIcon := ExtractIcon(hInstance, CPA_file_name, 1)
		Else
			hIcon := GetWindowIcon(wid, 1) ; (window id, whether to get large icons)
		order++
		windows.Insert(Object("hwnd",wid,"Title", wid_Title, "Class", Win_Class, "Style", Style, "ExStyle", es, "ExeName", Exe_Name, "Path", FullPath, "OnTop", (es&0x8 > 0 ? "On top" : ""), "PID", PID, "Order", order, "Type", "Window", "Icon", hIcon))
	}
	return windows
}

; (window id, whether to get large icons)
GetWindowIcon(wid, LargeIcons)
{
	Local NR_temp, h_icon, Responding
	; check status of window - if window is responding or "Not Responding"
	NR_temp =0 ; init
	h_icon =
	Responding := DllCall("SendMessageTimeout", "Ptr", wid, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", NR_temp) ; 150 = timeout in millisecs
	If (Responding)
	{
		; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2
		If LargeIcons =1
		{
			SendMessage, 0x7F, 1, 0,, ahk_id %wid%
			h_icon := ErrorLevel
		}
		If ( ! h_icon )
		{
			SendMessage, 0x7F, 2, 0,, ahk_id %wid%
			h_icon := ErrorLevel
			If ( ! h_icon )
			{
				SendMessage, 0x7F, 0, 0,, ahk_id %wid%
				h_icon := ErrorLevel
				If ( ! h_icon )
				{
					If LargeIcons =1
						h_icon := DllCall( "GetClassLong" (A_PtrSize = 8 ? "Ptr" : ""), "Ptr", wid, "int", -14, UPtr) ; GCL_HICON is -14
					If ( ! h_icon )
					{
						h_icon := DllCall( "GetClassLong" (A_PtrSize = 8 ? "Ptr" : ""), "Ptr", wid, "int", -34, UPtr) ; GCL_HICONSM is -34
						If ( ! h_icon )
							h_icon := DllCall( "LoadIcon", "Ptr", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
					}
				}
			}
		}
	}
	If ! ( h_icon = "" or h_icon = "FAIL") ; Add the HICON directly to the icon list
		return h_icon
	Else	; use a generic icon
		return Accessor.GenericIcons.Application
}
; retrives Control Panel applet icon
GetCPA_file_name( p_hw_target )
{
   WinGet, pid_target, PID, ahk_id %p_hw_target%
   hp_target := DllCall( "OpenProcess", "uint", 0x18, "int", false, "uint", pid_target, "Ptr")
   hm_kernel32 := GetModuleHandle("kernel32.dll")
   pGetCommandLine := DllCall( "GetProcAddress", "Ptr", hm_kernel32, "Astr", A_IsUnicode ? "GetCommandLineW"  : "GetCommandLineA")
   buffer_size := 6
   VarSetCapacity( buffer, buffer_size )
   DllCall( "ReadProcessMemory", "Ptr", hp_target, "uint", pGetCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
   loop, 4
      ppCommandLine += ( ( *( &buffer+A_Index ) ) << ( 8*( A_Index-1 ) ) )
   buffer_size := 4
   VarSetCapacity( buffer, buffer_size, 0 )
   DllCall( "ReadProcessMemory", "Ptr", hp_target, "uint", ppCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
   loop, 4
      pCommandLine += ( ( *( &buffer+A_Index-1 ) ) << ( 8*( A_Index-1 ) ) )
   buffer_size := 260
   VarSetCapacity( buffer, buffer_size, 1 )
   DllCall( "ReadProcessMemory", "Ptr", hp_target, "uint", pCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )
   DllCall( "CloseHandle", "Ptr", hp_target )
   IfInString, buffer, desk.cpl ; exception to usual string format
     return, "C:\WINDOWS\system32\desk.cpl"

   ix_b := InStr( buffer, "Control_RunDLL" )+16
   ix_e := InStr( buffer, ".cpl", false, ix_b )+3
   StringMid, CPA_file_name, buffer, ix_b, ix_e-ix_b+1
   if ( ix_e )
      return, CPA_file_name
   else
      return, false
}

;gets CPU Usage
GetSystemTimes()    ;Total CPU Load
{
   Static oldIdleTime, oldKrnlTime, oldUserTime
   Static newIdleTime, newKrnlTime, newUserTime

   oldIdleTime := newIdleTime
   oldKrnlTime := newKrnlTime
   oldUserTime := newUserTime

   DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
   Return (1 - (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)) * 100
}

;Starts a timer that can call functions and object methods
SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) { 
 Static current,tmrs:=Object() ;current will hold timer that is currently running
 If IsFunc( Function ) || IsObject( Function ){
    if IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
       ret := DllCall( "KillTimer", UInt,0, UInt, tmr.tmr)
       , DllCall("GlobalFree", UInt, tmr.CBA)
       , tmrs.Remove(Function) 
    if (Period = 0 || Period ? "off")
       return ret ;Return as we want to turn off timer
    ; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
    tmr:=tmrs[Function]:=Object("func",Function,"Period",Period="on" ? 250 : Period,"Priority",Priority
                        ,"OneTime",(Period<0),"params",IsObject(ParmObject)?ParmObject:Object()
                        ,"Tick",A_TickCount)
    tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
    return !!(tmr.tmr  := DllCall("SetTimer", UInt,0, UInt,0, UInt
                        , (Period && Period!="On") ? Abs(Period) : (Period := 250)
                        , UInt,tmr.CBA)) ;Create Timer and return true if a timer was created
            , tmr.Tick:=A_TickCount
 }
 tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information
 if IsObject(tmr) {
    DllCall("KillTimer", UInt,0, UInt,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
    If (!tmr.active && tmr.Priority<(current.priority ? current.priority : 0)) ;Timer with higher priority is already current so return
       Return (tmr.tmr:=DllCall("SetTimer", UInt,0, UInt,0, UInt, 100, UInt,tmr.CBA)) ;call timer again asap
    current:=tmr
    tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
    func := tmr.func.(tmr.params*) ;call function
    current= ;reset timer
    if (tmr.OneTime) ;One time timer, deactivate and delete it
       return DllCall("GlobalFree", UInt,tmr.CBA)
             ,tmrs.Remove(tmr.func)
    tmr.tmr:= DllCall("SetTimer", UInt,0, UInt,0, UInt ;reset timer
            ,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), UInt,tmr.CBA)
 }
}

;Duplicates an icon. The copy needs to be deleted with DestroyIcon.
DuplicateIcon(hIcon)
{
	return DllCall("Shell32.dll\DuplicateIcon", "PTR", 0, "Ptr", hIcon, "PTR")
}

;Returns an object containing the area of the monitor in pixels where the mouse cursor currently is
FindMonitorFromMouseCursor()
{
	CoordMode, Mouse, Screen
    MouseGetPos, x, y
	SysGet, Mon0, MonitorCount
    Loop %Mon0%
    { ;Loop through each monitor 
        SysGet, Mon%A_Index%, Monitor, %A_Index% 
        if(x >= Mon%A_Index%Left && x < Mon%A_Index%Right && y >= Mon%A_Index%Top && y < Mon%A_Index%Bottom)
        	return {Index : A_Index, Left : Mon%A_Index%Left, Top : Mon%A_Index%Top, Right : Mon%A_Index%Right, Bottom : Mon%A_Index%Bottom}
    }
}

;Determines if this script is running as 32bit version in a 64bit OS
IsWow64Process()
{
	ThisProcess := DllCall("GetCurrentProcess")
	; If IsWow64Process() fails or can not be found,
	; assume this process is not running under wow64.
	; Otherwise, use the value returned in IsWow64Process.
	if !DllCall("IsWow64Process", "PTR", ThisProcess, "PTR*", IsWow64Process)
	    IsWow64Process := false
    return IsWow64Process
}

;Shows icon picker dialog. Returns true if OK is pressed, false if cancelled.
PickIcon(ByRef sIconPath, ByRef nIndex)
{
	VarSetCapacity(IconPath, 260 * 2, 0)
	nIndex--
	DllCall("shell32\PickIconDlg", "Ptr", 0, "str", IconPath, "Uint", 260, "PTRP", nIndex)
	if(IconPath)
	{
		sIconPath := IconPath
		nIndex++
		return true
	}
	nIndex++
	return false
}


;Append two paths together and treat possibly double or missing backslashes
AppendPaths(BasePath, RelativePath)
{
	if(!BasePath)
		return RelativePath
	if(!RelativePath)
		return BasePath
	return strTrimRight(BasePath, "\") "\" strTrimLeft(RelativePath, "\")
}

;Add quotes around a string if necessary
Quote(string, once = 1)
{
	if(once)
	{
		if(InStr(string, """") != 1)
			string := """" string
		if(!strEndsWith(string, """"))
			string := string """"
		return string
	}
	return """" string """"
}

;Remove quotes from a string if necessary
UnQuote(string)
{
	if(InStr(string, """") = 1 && strEndsWith(string, """"))
		return strTrim(string, """")
	return string
}

;This function separates a list of file paths into two lists,
;where one contains the files that have one of the extensions specified in extensions and one (SplitFiles) that doesn't
SplitByExtension(ByRef files, ByRef SplitFiles, extensions)
{
	;Init string incase it wasn't resetted before or so
	SplitFiles := Array()
	newFiles := Array()
	for index, file in files
	{ 
		SplitPath, file , , , OutExtension
		if (InStr(extensions, OutExtension) && OutExtension != "")
			SplitFiles.Insert(file)
		else
			newFiles.Insert(file)
	}
	files := newFiles
	return
}

;This function makes an absolute path relative to a base path
MakeRelativePath(AbsolutePath, BasePath)
{
	if(InStr(AbsolutePath, BasePath) != 1)
	{
		MsgBox MakeRelativePath: %AbsolutePath% doesn't start with %BasePath%
		return ""
	}
	RelativePath := SubStr(AbsolutePath, StrLen(BasePath) + 1)
	RelativePath := strTrimLeft(RelativePath, ["\", "/"])
	return RelativePath


}

;These two functions are used to convert an icon resource id (as those used in the registry) to icon index(as used by ahk)
;By Lexikos http://www.autohotkey.com/community/viewtopic.php?p=168951
IndexOfIconResource(Filename, ID)
{
    hmod := DllCall("GetModuleHandle", "str", Filename, "PTR")
    ; If the DLL isn't already loaded, load it as a data file.
    loaded := !hmod
        && hmod := DllCall("LoadLibraryEx", "str", Filename, "PTR", 0, "uint", 0x2)
    
    enumproc := RegisterCallback("IndexOfIconResource_EnumIconResources","F")
    VarSetCapacity(param,12,0)
    NumPut(ID,param,0)
    ; Enumerate the icon group resources. (RT_GROUP_ICON=14)
    DllCall("EnumResourceNames", "uint", hmod, "uint", 14, "uint", enumproc, "PTR", &param)
    DllCall("GlobalFree", "PTR", enumproc)
    
    ; If we loaded the DLL, free it now.
    if loaded
        DllCall("FreeLibrary", "PTR", hmod)
    
    return NumGet(param,8) ? NumGet(param,4) : 0
}

IndexOfIconResource_EnumIconResources(hModule, lpszType, lpszName, lParam)
{
    NumPut(NumGet(lParam+4)+1, lParam+4)

    if (lpszName = NumGet(lParam+0))
    {
        NumPut(1, lParam+8)
        return false    ; break
    }
    return true
}
;Tries to read from HKCU and then from HKLM if not found
RegReadUser(Key, Name)
{
	RegRead, value, HKCU, %Key%, %Name%
	if(ErrorLevel)
		RegRead, value, HKLM, %Key%, %Name%
	return value
}


;Expand path placeholders like %ProgramFiles% or %TEMP%.
;It's basically ExpandEnvironmentStrings() with some additional directories
ExpandPathPlaceholders(InputString)
{
	static Replacements := {  "Desktop" : 			GetFullPathName(A_Desktop)
							, "MyDocuments" :		GetFullPathName(A_MyDocuments)
							, "StartMenu" :			GetFullPathName(A_StartMenu)
							, "StartMenuCommon" : 	GetFullPathName(A_StartMenuCommon)
							, "7plusDrive" : 		""
							, "7plusDir" :			A_ScriptDir
							, "ImageEditor"	:		""
							, "TextEditor" :		""}
	if(!Replacements.7plusDrive)
	{
		SplitPath, A_ScriptDir,,,,,s7plusDrive
		Replacements.7plusDrive := s7plusDrive
	}
	Replacements.ImageEditor := Settings.Misc.DefaultImageEditor
	Replacements.TextEditor := Settings.Misc.DefaultTextEditor

	for Placeholder, Replacement in Replacements
		while(InStr(InputString, Placeholder) && A_Index < 10)
			StringReplace, InputString, InputString, % "%" Placeholder "%", % Replacement, All
	
	; get the required size for the expanded string
	SizeNeeded := DllCall("ExpandEnvironmentStrings", "Str", InputString, "PTR", 0, "Int", 0)
	if(SizeNeeded == "" || SizeNeeded <= 0)
		return InputString ; unable to get the size for the expanded string for some reason

	ByteSize := SizeNeeded * 2 + 2
	VarSetCapacity(TempValue, ByteSize, 0)

	; attempt to expand the environment string
	if(!DllCall("ExpandEnvironmentStrings", "Str", InputString, "Str", TempValue, "Int", SizeNeeded))
		return InputString ; unable to expand the environment string
	return TempValue
}

;Gets (and sets) LoWord of first parameter (to the value of the second parameter)
LoWord(value*)
{
	if(value.MaxIndex() = 1)
		return value[1] & 0x0000FFFF
	else if(value.MaxIndex() = 2)
		return (value[1] & 0xFFFF0000) + (value[2] & 0x0000FFFF)
}
;Gets (and sets) HiWord of first parameter (to the value of the second parameter)
HiWord(value*)
{
	if(value.MaxIndex() = 1)
		return value[1] & 0xFFFF0000
	else if(value.MaxIndex() = 2)
		return (value[1] & 0x0000FFFF) + (value[2] << 16)
}
HighWord(value*)
{
	return value & 0xFFFF0000
}
#include <CGUI>
#include <ObjectTools>
Class CInputWindow extends CGUI
{
	editText := this.AddControl("Edit", "editText", "x10 y10 w300", "")
	btnOK := this.AddControl("Button", "btnOK", "x180 y+10 Default w50", "&OK")
	btnCancel := this.AddControl("Button", "btnCancel", "x+10 w70", "&Cancel")
	static EM_SETSEL := 0x00B1
	__new(Text)
	{
		this.ActiveControl := this.editText
		this.editText.Text := Text
		this.DestroyOnClose := true
		this.CloseOnEscape := true
	}

	WaitForInput()
	{
		this.Show()
		SendMessage, this.EM_SETSEL, 0, -1, , % "ahk_id " this.editText.hwnd
		while(!this.IsDestroyed)
			Sleep 10
		return result
	}
	WaitForInputAsync(OnCloseHandler)
	{
		this.Show()
		SendMessage, this.EM_SETSEL, 0, -1, , % "ahk_id " this.editText.hwnd
		this.OnClose.Handler := OnCloseHandler
	}
	btnCancel_Click()
	{
		this.Close()
	}
	btnOK_Click()
	{
		this.result := this.editText.Text
		this.Close()
	}
}

New(Obj, Params*)
{
	return value := new Obj(Params*)
}

;Loads an icon from a path and returns the hIcon. Needs to be freed afterwards with DestroyIcon()
LoadIcon(Path)
{
	return DllCall("LoadImage", "PTR", 0, "str", Path, "uint", IMAGE_ICON := 1, "int", 0, "int", 0, "uint", LD_LOADFROMFILE := 0x00000010, "PTR")
}
;Supports paths, icon handles and hBitmaps
GetBitmapFromAnything(Anything)
{
	if(FileExist(Anything))
	{
		pBitmap := Gdip_CreateBitmapFromFile(Anything)
		;hBitmap := Gdip_CreateHBitmapFromBitmap(pBitmap)
		;Gdip_DisposeImage(pBitmap)
	}
	else if(DllCall("GetObjectType", "PTR", hBitmap) = (OBJ_BITMAP := 7)) ;Tread as icon
	{
		hBitmap := Anything
		pBitmap := Gdip_CreateBitmapFromHBitmap(hBitmap)
		DeleteObject(hBitmap)
	}
	else if(Anything != "")
	{
		pBitmap := Gdip_CreateBitmapFromHICON(Anything)
		;hBitmap := Gdip_CreateHBitmapFromBitmap(pBitmap)
		;Gdip_DisposeImage(pBitmap)
	}
	else
		return 0
	return pBitmap
}

LookupFileInPATH(filename)
{
	SplitPath, filename,,path
	if(path)
		return filename
	VarSetCapacity(Path, 600, 0) ;Greater than (MAS_PATH + 1) * 2 and some extra to be sure
	res := DllCall("SearchPath", PTR, 0, str, filename, PTR, 0, UINT, 300, str, Path, PTR, 0, "UINT")
	if(res != 0)
		return Path
}

ToSingleLine(String)
{
	StringReplace, String, String, `n, ``n, All
	StringReplace, String, String, `r`n, ``r``n, All
	return String
}
/*
Title: ILButton
Version: 1.1
Author: tkoi <http://www.autohotkey.net/~tkoi>
License: GNU GPLv3 <http://www.opensource.org/licenses/gpl-3.0.html>

Function: ILButton()
    Creates an imagelist and associates it with a button.
Parameters:
    hBtn   - handle to a buttton
    images - a pipe delimited list of images in form "file:zeroBasedIndex"
               - file must be of type exe, dll, ico, cur, ani, or bmp
               - there are six states: normal, hot (hover), pressed, disabled, defaulted (focused), and stylushot
                   - ex. "normal.ico:0|hot.ico:0|pressed.ico:0|disabled.ico:0|defaulted.ico:0|stylushot.ico:0"
               - if only one image is specified, it will be used for all the button's states
               - if fewer than six images are specified, nothing is drawn for the states without images
               - omit "file" to use the last file specified
                   - ex. "states.dll:0|:1|:2|:3|:4|:5"
               - omitting an index is the same as specifying 0
               - note: within vista's aero theme, a defaulted (focused) button fades between images 5 and 6
    cx     - width of the image in pixels
    cy     - height of the image in pixels
    align  - an integer between 0 and 4, inclusive. 0: left, 1: right, 2: top, 3: bottom, 4: center
    margin - a comma-delimited list of four integers in form "left,top,right,bottom"

Notes:
    A 24-byte static variable is created for each IL button
    Tested on Vista Ultimate 32-bit SP1 and XP Pro 32-bit SP2.

Changes:
  v1.1
    Updated the function to use the assume-static feature introduced in AHK version 1.0.48
*/

ILButton(hBtn, images, cx=16, cy=16, align=4, margin="1,1,1,1")
{
	static
	static i = 0
	local himl, v0, v1, v2, v3, ext, hbmp, hicon
	i++

	himl := DllCall("ImageList_Create", "Int",cx, "Int",cy, "UInt",0x20, "Int",1, "Int",5, "UPtr")
	Loop, Parse, images, |
	{
		Pos := InStr(A_LoopField, ":", false, 3)
		if(pos)
		{
			v1 := SubStr(A_LoopField, 1, pos - 1)
			v2 := SubStr(A_LoopField, pos + 1)
		}
		else
			v1 := A_LoopField
		SplitPath, v1, , , ext
		if(ext = "bmp")
		{
			hbmp := DllCall("LoadImage", "UInt",0, "Str",v1, "UInt",0, "UInt",cx, "UInt",cy, "UInt",0x10, "UPtr")
			DllCall("ImageList_Add", "Ptr",himl, "Ptr",hbmp, "Ptr",0)
			DllCall("DeleteObject", "Ptr", hbmp)
		}
		else
		{
			DllCall("PrivateExtractIcons", "Str",v1, "Int",v2, "Int",cx, "Int",cy, "PtrP",hicon, "UInt",0, "UInt",1, "UInt",0)
			msgbox hicon %hicon% v1 %v1% v2 %v2%
			DllCall("ImageList_AddIcon", "Ptr",himl, "Ptr",hicon)
			DllCall("DestroyIcon", "Ptr", hicon)
		}
	}
	; Create a BUTTON_IMAGELIST structure
	VarSetCapacity(struct%i%, A_PtrSize + (5 * 4) + (A_PtrSize - 4), 0)
	NumPut(himl, struct%i%, 0, "Ptr")
	Loop, Parse, margin, `,
	NumPut(A_LoopField, struct%i%, A_PtrSize + ((A_Index - 1) * 4), "Int")
	NumPut(align, struct%i%, A_PtrSize + (4 * 4), "UInt")
	; BCM_FIRST := 0x1600, BCM_SETIMAGELIST := BCM_FIRST + 0x2
	PostMessage, 0x1602, 0, &struct%i%, , ahk_id %hBtn%
	Sleep 1 ; workaround for a redrawing problem on WinXP
}