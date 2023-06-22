#Include %A_ScriptDir%\WinEvents.ahk
#NoEnv
#Persistent

; Must exist notepad opened ( notepad.exe )
; Must exist calculator opened ( calc.exe )

aiProcessIDs := []
WinGet, iProcessIDByTitle, PID, ahk_exe notepad.exe                  ; Retrieve the notepad.exe Process ID and store it in iProcessIDByTitle
aiProcessIDs[0] := iProcessIDByTitle                                 ; Store the notepad.exe Process ID in the element 0 of the aiProcessIDs array
WinGet, iProcessIDByTitle, PID, ahk_exe calc.exe                     ; Retrieve the calc.exe Process ID and store it in iProcessIDByTitle
aiProcessIDs[1] := iProcessIDByTitle                                 ; Store the calc.exe Process ID in the element 1 of the aiProcessIDs array
asEventHook := HookEvent( "CloseExecution", [ EVENT_OBJECT_DESTROY ], aiProcessIDs )

Exit


CloseExecution(hHook, iEvent, hWnd, iIDObject, iIDChild, iEventThread, dwmsEventTime)
{
	UnHookEvent( "CloseExecution", iEvent, iIDObject )               ; If no put this line like FIRST line will receive many other calls about many objects destroyed with the window distruction

    MsgBox, "WindowClosed; UnHook( ... ) execution and exit program."

	UnHookEvent()                                                    ; This is no necessary; only to example

	ExitApp
}
