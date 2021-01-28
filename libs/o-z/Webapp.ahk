; Webapp.ahk
; -------------------------------------------------------
; "Webapps made easy!"
; Library for developing web-based apps with AutoHotkey.
; Released under the MIT License
; More info here: https://github.com/joedf/Webapp.ahk 
; -------------------------------------------------------
; 
; AutoHotkey Tested Version: 1.1.24.03
; Dev Platform:   Windows 10 x64
; Author:         Joe DF  |  http://joedf.ahkscript.org  |  joedf@ahkscript.org
; Date:           15:40 2016/11/19
; Revision:       2

#NoEnv
SetWorkingDir %A_ScriptDir%

; https://autohotkey.com/board/topic/62512-permanently-turn-off-that-annoying-hotkey-limit/
#MaxHotkeysPerInterval 500
#UseHook

__Webapp_jsonf := "webapp.json"
FileRead,data,%__Webapp_jsonf%
j:=JSON_ToObj(data)

try {
	__Webapp_Name := __Webapp_DefaultVar(j.name,"My App")
	__Webapp_Width := __Webapp_DefaultVar(j.width,640)
	__Webapp_height := __Webapp_DefaultVar(j.height,480)
	__Webapp_protocol := __Webapp_DefaultVar(j.protocol,"app")
	__Webapp_Nav_sounds := __Webapp_DefaultVar(j.Nav_sounds,0)
	__Webapp_FullScreen := __Webapp_DefaultVar(j.fullscreen,0)
	__Webapp_DPI_Aware := __Webapp_DefaultVar(j.DPI_Aware,1)
	__Webapp_ZoomLevel := __Webapp_DefaultVar(j.ZoomLevel,100)
	__Webapp_AllowZoomLevelChange := __Webapp_DefaultVar(j.AllowZoomLevelChange,1)
	__Webapp_protocol_call := __Webapp_DefaultVar(j.protocol_call,"app_call")
		if !IsFunc(__Webapp_protocol_call)
			throw "Function Name '" . __Webapp_protocol_call . "' does not exist."
		__Webapp_protocol_call:=Func(__Webapp_protocol_call)
	__Webapp_NavComplete_call := __Webapp_DefaultVar(j.NavComplete_call,"app_page")
		if !IsFunc(__Webapp_NavComplete_call)
			throw "Function Name '" . __Webapp_NavComplete_call . "' does not exist."
		__Webapp_NavComplete_call:=Func(__Webapp_NavComplete_call)
	__Webapp_html_url := __Webapp_DefaultVar(j.html_url,"index.html")
		if !FileExist(__Webapp_html_url)
			throw "File '" . __Webapp_html_url . "' does not exist."
		__Webapp_html_url := getFileFullPath(__Webapp_html_url)
} catch e {
	err:= e . "`nPlease verify the '" . __Webapp_jsonf . "' file."
	if (A_LastError)
		err .= "`n" . Trim(GetErrorMessage(A_LastError),"`r`n") . "`nA_LastError = " . A_LastError
	ErrorExit(err)
}



OnExit,__Webapp_GuiClose
Gui __Webapp_:New
Gui __Webapp_:Margin, 0, 0
if (!__Webapp_DPI_Aware)
	Gui __Webapp_:-DPIScale
Gui __Webapp_:+LastFound +Resize +Hwnd__Webapp_GuiHwnd

; Register Messages
OnMessage(WM_KEYDOWN := 0x100, "gui_KeyDown", 2)
if (!__Webapp_AllowZoomLevelChange) {
	OnMessage(WM_MOUSEWHEEL = 0x20A, "gui_WheelScroll")
	
	Hotkey, IfWinActive, ahk_id %__Webapp_GuiHwnd%
		Hotkey, ^WheelDown, __Webapp_DoNothing
		Hotkey, ^WheelUp, __Webapp_DoNothing
	Hotkey, If
}

Gui __Webapp_:Add, ActiveX, v__Webapp_wb w%__Webapp_Width% h%__Webapp_height%, Shell.Explorer
SetWBClientSite()
__Webapp_wb.silent := true ;Surpress JS Error boxes
;__Webapp_wb.Navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible' content='IE=edge'>")
__Webapp_wb.Navigate("file://" . __Webapp_html_url)

if (InStr(__Webapp_Nav_sounds,"false") || __Webapp_Nav_sounds==0) {
	; Thanks MrBubbles
	; https://autohotkey.com/boards/viewtopic.php?p=117029#p117029
	DllCall("urlmon\CoInternetSetFeatureEnabled"
			,"Int",  21 ; FEATURE_DISABLE_NAVIGATION_SOUNDS
			,"UInt", 0x00000002 ; SET_FEATURE_ON_PROCESS
			,"Int", 1)
}

ComObjConnect(__Webapp_wb, __Webapp_wb_events)
__Webapp_w := __Webapp_wb.Document.parentWindow
__Webapp_wf := Func("JS_AHK")
__Webapp_w.AHK := __Webapp_wf
;Wait for IE to load the page, before we connect the event handlers
while __Webapp_wb.readystate != 4 or __Webapp_wb.busy
	sleep 10

Gui __Webapp_:Show, w%__Webapp_Width% h%__Webapp_height%, %__Webapp_Name%
Gui __Webapp_:Default
GroupAdd, __Webapp_windows, ahk_id %__Webapp_GuiHwnd%

setZoomLevel( __Webapp_ZoomLevel )

if (__Webapp_FullScreen) {
	setFullscreen(__Webapp_FullScreen)
}
goto,__Webapp_AppStart
return

~LButton:: ;//cheap fix to reattach JS_AHK
gosub,__Webapp_JS_AHK_Attach
return

__Webapp_JS_AHK_Attach:
	 __Webapp_wb.Document.parentWindow.AHK := __Webapp_wf
return

__Webapp_GuiSize:
	GuiControl, __Webapp_:Move, __Webapp_wb, W%A_GuiWidth% H%A_GuiHeight%
return

__Webapp_GuiEscape:
	MsgBox 0x34, Webapp.ahk, Are you sure you want to quit?
	IfMsgBox No
		return
__Webapp_GuiClose:
	;make sure taskbar is back on exit
	WinShow, ahk_class Shell_TrayWnd
	WinShow, Start ahk_class Button
	Gui __Webapp_:Destroy
	ExitApp
return

__Webapp_DoNothing:
return

class __Webapp_wb_events
{
	;for more events and other, see http://msdn.microsoft.com/en-us/library/aa752085
	
	 ;blocked all navigation, we want our own stuff happening
	NavigateComplete2(wb, NewURL) {
		; wb.Stop() ;not needed in this one.
		global __Webapp_NavComplete_call
		__Webapp_NavComplete_call.call(NewURL)
	}
	DownloadComplete(wb, NewURL) {
		wb.Stop()
	}
	DocumentComplete(wb, NewURL) {
		wb.Stop()
	}
	NavigateError(wb, NewURL) {
		wb.Stop()
	}
	
	BeforeNavigate2(wb, NewURL)
	{
		wb.Stop() ;blocked all navigation, we want our own stuff happening
		
		global __Webapp_protocol
		global __Webapp_protocol_call
		
		;parse the url
		if (__Webapp_protocol == "*") ;if * then all goes to the function call, ie #nofilter ;)
			__Webapp_protocol_call.call(NewURL)
		else {
			if (InStr(NewURL,__Webapp_protocol "://")==1) { ;if url starts with "myapp://"
				what := SubStr(NewURL,Strlen(__Webapp_protocol)+4) ;get stuff after "myapp://"
				__Webapp_protocol_call.call(what)
			}
		}
		;else do nothing
	}
}

/* Autoconnect inputs by Phatricko - https://autohotkey.com/boards/viewtopic.php?p=102421#p102421
loop % wb.document.getElementsByTagName("input").length{
    ;ComObjConnect needs a unique variable for each iteration for all to work
    button%a_index% := wb.document.getElementsByTagName("input")[A_Index-1]
    id := button%a_index%.id
    ComObjConnect(button%a_index%, id . "_")
}
*/

__Webapp_DefaultVar(a,b) {
	if Instr(a,"false",false)
		return false
	if !StrLen(a)
		return b
	return a
}

;javascript:AHK('Func') --> Func()
JS_AHK(func, prms*) {
	wb := getDOM()
	; Stop navigation prior to calling the function, in case it uses Exit.
	wb.Stop()
	return %func%(prms*)
}

getWindow() {
	wb := getDOM()
	return wb.document.parentWindow
}

getDOM(){
	global __Webapp_wb
	return __Webapp_wb
}

setAppName(n) {
	global __Webapp_Name
	__Webapp_Name := __Webapp_DefaultVar(n,"My App")
	Gui, __Webapp_:Show, , %__Webapp_Name%
}

setFullscreen(bool) {
	global __Webapp_GuiHwnd
	global __Webapp_Width
	global __Webapp_height
	global __Webapp_FullScreen

	if (bool) {
		;Save old GUI values
		WinGetPos,nFS_x,nFS_y,__Webapp_Width,__Webapp_height,ahk_id %__Webapp_GuiHwnd%

		;Set New GUI Values
		SysGet, caption, 31
		SysGet, borderH, 32
		SysGet, borderV, 33
		FS_x := 0 - (borderH)
		FS_y := 0 - (caption) - (borderV)
		FS_w := A_ScreenWidth + (borderH*2)
		FS_h := A_ScreenHeight + (caption) + (borderV*2)
		
		;hide taskbar
		;WinSet,AlwaysOnTop,On,ahk_id %__Webapp_GuiHwnd%
		WinHide, ahk_class Shell_TrayWnd
		WinHide, Start ahk_class Button

		WinMove,ahk_id %__Webapp_GuiHwnd%,,%FS_x%,%FS_y%,%FS_w%,%FS_h%
		WinActivate,ahk_id %__Webapp_GuiHwnd% ;avoid bug
		__Webapp_FullScreen:=true ;FULLSCREEN = TRUE
	} else {
		nFS_x := (A_ScreenWidth//2) - (__Webapp_Width//2)
		nFS_y := (A_ScreenHeight//2) - (__Webapp_height//2)
		nFS_w := __Webapp_Width
		nFS_h := __Webapp_height
		WinMove,ahk_id %__Webapp_GuiHwnd%,,%nFS_x%,%nFS_y%,%nFS_w%,%nFS_h%

		;show taskbar
		;WinSet,AlwaysOnTop,Off,ahk_id %__Webapp_GuiHwnd%
		WinShow, ahk_class Shell_TrayWnd
		WinShow, Start ahk_class Button

		WinActivate,ahk_id %__Webapp_GuiHwnd% ;avoid bug
		__Webapp_FullScreen:=false ;FULLSCREEN = FALSE
	}
}

setZoomLevel(z) {
	global __Webapp_DPI_Aware
	
	; https://stackoverflow.com/a/738254/883015
	OLECMDID_OPTICAL_ZOOM := 63
	OLECMDID_OPTICAL_GETZOOMRANGE := 64
	OLECMDEXECOPT_DONTPROMPTUSER :=  2 ;?  https://social.msdn.microsoft.com/Forums/ie/en-US/21d2bc41-d182-4af6-81e9-6e06793058b9
	wb := getDOM()
	
	if (__Webapp_DPI_Aware) {
		DPI_Scale := A_ScreenDPI/96
		z := z * DPI_Scale
	}
	
	; ensure INT
	z := z & 0xFFFFFFFF
	
	wb.ExecWB( OLECMDID_OPTICAL_ZOOM, OLECMDEXECOPT_DONTPROMPTUSER, z, 0)
}

ErrorExit(errMsg) {
	MsgBox 16, Webapp.ahk, %errMsg%
	ExitApp 1
}

;{ other stuff

GetErrorMessage(error_code="") {
	VarSetCapacity(buf, 1024) ; Probably won't exceed 1024 chars.
	if DllCall("FormatMessage", "uint", 0x1200, "ptr", 0, "int", error_code!=""
		? error_code : A_LastError, "uint", 1024, "str", buf, "uint", 1024, "ptr", 0)
	return buf
}

getFileFullPath(f) {
	Loop, Files, %f%
	{
		if (A_LoopFileLongPath)
			return A_LoopFileLongPath    
	}
}

/*  Complex workaround to override "Active scripting" setting
 *  and ensure scripts can run within the WebBrowser control.
 */

global WBClientSite

SetWBClientSite()
{
	interfaces := {
	(Join,
		IOleClientSite: [0,3,1,0,1,0]
		IServiceProvider: [3]
		IInternetSecurityManager: [1,1,3,4,8,7,3,3]
	)}
	unkQI      := RegisterCallback("WBClientSite_QI", "Fast")
	unkAddRef  := RegisterCallback("WBClientSite_AddRef", "Fast")
	unkRelease := RegisterCallback("WBClientSite_Release", "Fast")
	WBClientSite := {_buffers: bufs := {}}, bufn := 0, 
	for name, prms in interfaces
	{
		bufn += 1
		bufs.SetCapacity(bufn, (4 + prms.MaxIndex()) * A_PtrSize)
		buf := bufs.GetAddress(bufn)
		NumPut(unkQI,       buf + 1*A_PtrSize)
		NumPut(unkAddRef,   buf + 2*A_PtrSize)
		NumPut(unkRelease,  buf + 3*A_PtrSize)
		for i, prmc in prms
			NumPut(RegisterCallback("WBClientSite_" name, "Fast", prmc+1, i), buf + (3+i)*A_PtrSize)
		NumPut(buf + A_PtrSize, buf + 0)
		WBClientSite[name] := buf
	}
	wb := getDOM()
	if pOleObject := ComObjQuery(wb, "{00000112-0000-0000-C000-000000000046}")
	{   ; IOleObject::SetClientSite
		DllCall(NumGet(NumGet(pOleObject+0)+3*A_PtrSize), "ptr"
			, pOleObject, "ptr", WBClientSite.IOleClientSite, "uint")
		ObjRelease(pOleObject)
	}
}

WBClientSite_QI(p, piid, ppvObject)
{
	static IID_IUnknown := "{00000000-0000-0000-C000-000000000046}"
	static IID_IOleClientSite := "{00000118-0000-0000-C000-000000000046}"
	static IID_IServiceProvider := "{6d5140c1-7436-11ce-8034-00aa006009fa}"
	iid := _String4GUID(piid)
	if (iid = IID_IOleClientSite || iid = IID_IUnknown)
	{
		NumPut(WBClientSite.IOleClientSite, ppvObject+0)
		return 0 ; S_OK
	}
	if (iid = IID_IServiceProvider)
	{
		NumPut(WBClientSite.IServiceProvider, ppvObject+0)
		return 0 ; S_OK
	}
	NumPut(0, ppvObject+0)
	return 0x80004002 ; E_NOINTERFACE
}

WBClientSite_AddRef(p)
{
	return 1
}

WBClientSite_Release(p)
{
	return 1
}

WBClientSite_IOleClientSite(p, p1="", p2="", p3="")
{
	if (A_EventInfo = 3) ; GetContainer
	{
		NumPut(0, p1+0) ; *ppContainer := NULL
		return 0x80004002 ; E_NOINTERFACE
	}
	return 0x80004001 ; E_NOTIMPL
}

WBClientSite_IServiceProvider(p, pguidService, piid, ppvObject)
{
	static IID_IUnknown := "{00000000-0000-0000-C000-000000000046}"
	static IID_IInternetSecurityManager := "{79eac9ee-baf9-11ce-8c82-00aa004ba90b}"
	if (_String4GUID(pguidService) = IID_IInternetSecurityManager)
	{
		iid := _String4GUID(piid)
		if (iid = IID_IInternetSecurityManager || iid = IID_IUnknown)
		{
			NumPut(WBClientSite.IInternetSecurityManager, ppvObject+0)
			return 0 ; S_OK
		}
		NumPut(0, ppvObject+0)
		return 0x80004002 ; E_NOINTERFACE
	}
	NumPut(0, ppvObject+0)
	return 0x80004001 ; E_NOTIMPL
}

WBClientSite_IInternetSecurityManager(p, p1="", p2="", p3="", p4="", p5="", p6="", p7="", p8="")
{
	if (A_EventInfo = 5) ; ProcessUrlAction
	{
		if (p2 = 0x1400) ; dwAction = URLACTION_SCRIPT_RUN
		{
			NumPut(0, p3+0)  ; *pPolicy := URLPOLICY_ALLOW
			return 0 ; S_OK
		}
	}
	return 0x800C0011 ; INET_E_DEFAULT_ACTION
}

_String4GUID(pGUID)
{
	VarSetCapacity(String,38*2)
	DllCall("ole32\StringFromGUID2", "ptr", pGUID, "str", String, "int", 39)
	Return	String
}


/*  Fix keyboard shortcuts in WebBrowser control.
 *  References:
 *    http://www.autohotkey.com/community/viewtopic.php?p=186254#p186254
 *    http://msdn.microsoft.com/en-us/library/ms693360
 */

gui_KeyDown(wParam, lParam, nMsg, hWnd) {
	global __Webapp_AllowZoomLevelChange
	
	wb := getDOM()
	
	if (Chr(wParam) ~= "[A-Z]" || wParam = 0x74) ; Disable Ctrl+O/L/F/N and F5.
		return

	; joedf: optionally disable ctrl zooming
	if (!__Webapp_AllowZoomLevelChange) {
		if(GetKeyState("CTRL") && (wParam=187 || wParam=189)) ;CTRL+ CTRL-
			return
	}
	
	pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
	VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
	, NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
	, NumPut(nMsg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
	Loop 2
	r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
	; Loop to work around an odd tabbing issue (it's as if there
	; is a non-existent element at the end of the tab order).
	until wParam != 9 || wb.Document.activeElement != ""
	ObjRelease(pipa)
	if r = 0 ; S_OK: the message was translated to an accelerator.
		return 0
}

gui_WheelScroll(wParam, lParam) {
	if(GET_KEYSTATE_WPARAM(wParam)==8)
		return 1
}

GET_KEYSTATE_WPARAM(wparam) {
	return (wparam & 0xFFFF)
}

;}

;-----end-----