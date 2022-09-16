#Persistent

; 2022-07-23 (Ixiko): modified to work with different system languages. Complete the respective menu items in your language.
;                            	The original author: 	casperharkin
;                               	link:                       	https://github.com/casperharkin/Menu-Interceptor

; ################################################################################################
; #############  Notepad Example - Watch for Clicks on Menu Items Undo, Delete, Cut  #############
; ################################################################################################

Global MI_Data
MI := New MenuInterceptor("ahk_class Notepad", "Undo,Delete,Cut,Help", "0x0004", "0x0005")
return

Cut(MenuName){
	ToolTip % "You Clicked " MenuName "!"
}

Undo(MenuName) {
	ToolTip % "You Clicked " MenuName "!"
}

Delete(MenuName) {
	ToolTip % "You Clicked " MenuName "!"
}

Help(MenuName) {
	ToolTip % "You Clicked " MenuName "!"
}

; ################################################################################################

Class MenuInterceptor {

	__New(WindowClass, MenusToIntercept, Event_Menu_Start, Event_Menu_End) {
		Static

		lang := GetSystemLanguage()
		MenusToIntercept := lang ~= "i)German" ? "Rückgängig,Löschen,Ausschneiden,Hilfe anzeigen" : MenusToIntercept

		MI_Data                               	:= {}
		MI_Data.WindowClass         	:= WindowClass
		MI_Data.MenusToIntercept 	:= StrSplit(MenusToIntercept      	,",")
		MI_Data.FuncToCall           	:= StrSplit("Undo,Delete,Cut,Help"	,",")
		MI_Data.Event_Menu_Start 	:= Event_Menu_Start
		MI_Data.Event_Menu_End  	:= Event_Menu_End

		Acc_SetWinEventHook(	Event_Menu_Start 	? Event_Menu_Start 	: 0x0004
										, 	Event_Menu_End 	? Event_Menu_End 	: 0x0005
										, 	pCallback := RegisterCallback("MenuInterceptor.WinEvent"))
	}

	WinEvent(hHook, event, hWnd, idObject, idChild, eventThread, eventTime) {
	Critical
	Sleep 200 ; This is needed to Drop the click between firing the event and checking text
		if WinActive(MI_Data.WindowClass) {
			If (hHook = 4) {
				KeyWait, LButton, D
				MI_Data.Text := MenuInterceptor.GetInfoUnderCursor()
				For mNr, Value in MI_Data.MenusToIntercept
					If InStr(MI_Data.Text, Value) {
						cFunc := MI_Data.FuncToCall[mNr]
						%cFunc%(MI_Data.Text)
					}
			}
		}
	}

	GetInfoUnderCursor() {
		Acc := Acc_ObjectFromPoint(child)
		if !(value := Acc.accValue(child))
			value := Acc.accName(child)
		Return value
	}
}

#include ..\libs\a-f\ACC_more.ahk
#include ..\libs\g-n\GetSystemLanguage.ahk

