;---------------------------------------------------------------
; CornerNotify.ahk
; http://www.autohotkey.com/board/topic/94458-msgbox-replacement-monolog-non-modal-transparent-message-box-cornernotify/

;---------------------------------------------------------------
; CHANGELOG

; v1.1 2013-06-19
; added optional position argument that calls WinMove function from user "Learning One"
; position argument syntax is to create a string containing the following:
; t=top, vc= vertical center, b=bottom
; l=left, hc=horizontal center, r=right

;---------------------------------------------------------------

CornerNotify(secs, title, message, position="b r") {
	CornerNotify_Create(title, message, position)
	millisec := secs*1000*-1
	SetTimer, CornerNotifyBeginFadeOut, %millisec%
}

CornerNotify_Create(title, message, position="b r") {
	global cornernotify_title, cornernotify_msg, w, curtransp, cornernotify_hwnd
	CornerNotify_Destroy() ; make sure an old instance isn't still running or fading out
	Gui,+AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	cornernotify_hwnd := WinExist()
	WinSet, ExStyle, +0x20 ; WS_EX_TRANSPARENT make the window transparent-to-mouse
	WinSet, Transparent, 160
	curtransp := 160
	Gui,Color, 202020 ;background color
	Gui,Font, c5C5CF0 s17 wbold, Arial
	Gui,Add, Text, x20 y12 w668 vcornernotify_title, %title%
	Gui,Font, cF0F0F0 s15 wnorm
	Gui,Add, Text, x20 y56 w668 vcornernotify_msg, %message%
	Gui,Show, NoActivate W700
	WinMove(cornernotify_hwnd, position)
	Return
}

CornerNotify_ModifyTitle(title) {
	global cornernotify_title
	GuiControl,Text,cornernotify_title, %title%
}

CornerNotify_ModifyMessage(message) {
	global cornernotify_msg
	GuiControl,Text,cornernotify_msg, %message%
}

CornerNotify_Destroy() {
	global curtransp
	curtransp := 0
	Gui, Destroy
	SetTimer, CornerNotify_FadeOut_Destroy, Off
}

CornerNotifyBeginFadeOut:
	SetTimer, CornerNotifyBeginFadeOut, Off
	SetTimer, CornerNotify_FadeOut_Destroy, 10
Return

CornerNotify_FadeOut_Destroy:
	If(curtransp > 0) {
		curtransp := curtransp - 4
		WinSet, Transparent, %curtransp%, ahk_id %cornernotify_hwnd%
	} Else {
		Gui, Destroy
		SetTimer, CornerNotify_FadeOut_Destroy, Off
	}
Return

;---------------------------------------------------------------
; Modification of WinMove function by Learning One (http://www.autohotkey.com/board/topic/72630-gui-bottom-right/#entry461385)

; position argument syntax is to create a string with the following:
; t=top, vc= vertical center, b=bottom
; l=left, hc=horizontal center, r=right

WinMove(hwnd,position) {   ; by Learning one
   SysGet, Mon, MonitorWorkArea
   WinGetPos,ix,iy,w,h, ahk_id %hwnd%
   x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
   y := InStr(position,"t") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"b") ? MonBottom - h : iy
   WinMove, ahk_id %hwnd%,,x,y
}

;---------------------------------------------------------------
