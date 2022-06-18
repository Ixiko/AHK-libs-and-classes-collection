; How to prevent Gui gLabels to trigger when resetting all controls?
; https://www.autohotkey.com/boards/viewtopic.php?t=57546

;-----------------------------------------------------------------------------------------------------------------------------------------
RegUnReg_F(regHook:="",unregHook:="",Suppress_EN_CHANGE:="",Allow_EN_CHANGE:=""){
;-----------------------------------------------------------------------------------------------------------------------------------------
global
; Update by Lexikos to Control Focus Monitoring by Wolf_II ;https://autohotkey.com/boards/viewtopic.php?f=76&t=57546&p=243839#p243839
	if (regHook)
		hWinEventHook := DllCall("SetWinEventHook","UInt",0x8005,"UInt",0x8005,"Ptr",0,"Ptr",RegisterCallback("WIN_EVENTHOOK","Fast"),"UInt",DllCall("GetCurrentProcessId"),"UInt",0,"UInt",0,"Ptr")
	if (unregHook)
		DllCall("UnhookWinEvent", "ptr", hWinEventHook) ; UnRegister SetWinEventHook ; Lexikos
	if (Suppress_EN_CHANGE)
		OnMessage(0x0111, "Suppress_EN_CHANGE") ; register SUPPRESSION of WM_COMMAND
	if (Allow_EN_CHANGE)
		OnMessage(0x0111, "") ; unregister SUPPRESSION of WM_COMMAND - Just Me
}
;--------------------------------------------------------------------------------------------------------------------------------------------------
Suppress_EN_CHANGE(wParam) { ; suppress g-label calls caused by EN_CHANGE notifications
;--------------------------------------------------------------------------------------------------------------------------------------------------
	If (wParam >> 16) = 0x300 ; EN_CHANGE -Just Me
		Return 0 ; Prevent default processing by returning a NewValue.
}