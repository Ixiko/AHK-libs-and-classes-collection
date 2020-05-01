#Persistent

; ################################################################################################
; #############  Notepad Example - Watch for Clicks on Menu Items Undo, Delete, Cut  #############
; ################################################################################################

Global MI_Data
MI := New MenuInterceptor("ahk_class Notepad", "Undo,Delete,Cut", "0x0004", "0x0005")
Exit

Cut(){
	ToolTip % "You Clicked Cut!"
}

Undo() {
	ToolTip % "You Clicked Undo!"
}

Delete() {
	ToolTip % "You Clicked Delete!"
}

Help() {
	ToolTip % "You Clicked View Help!"
}

; ################################################################################################

Class MenuInterceptor {

	__New(WindowClass, MenusToIntercept, Event_Menu_Start, Event_Menu_End) {
		Static

		MI_Data := {}
		MI_Data.WindowClass := WindowClass
		MI_Data.MenusToIntercept := StrSplit(MenusToIntercept,",") 
		MI_Data.Event_Menu_Start := Event_Menu_Start
		MI_Data.Event_Menu_End := Event_Menu_End

		Acc_SetWinEventHook(Event_Menu_Start := "0x0004", Event_Menu_End := "0x0005", pCallback := RegisterCallback("MenuInterceptor.WinEvent"))
	}

	WinEvent(hHook, event, hWnd, idObject, idChild, eventThread, eventTime) {
	Sleep 200 ; This is needed to Drop the click between firing the event and checking text
		if WinActive(MI_Data.WindowClass) {
			If (hHook = "4") {
				KeyWait, LButton, D
				MI_Data.Text := MenuInterceptor.GetInfoUnderCursor()
				For each, Value in MI_Data.MenusToIntercept 
					If InStr(MI_Data.Text, Value)
						%Value%()
			}
		}
	}

	GetInfoUnderCursor() {
		Acc := Acc_ObjectFromPoint(child)
			if !value := Acc.accValue(child)
				value := Acc.accName(child)
					Return value
	}
}

