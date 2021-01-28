; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=9&t=85414
; Author:
; Date:
; for:     	AHK_L

/*
    Test := WinExist(" jp2launcher.exe")
    WinActivate, ahk_id %Test%
    ControlGet, g_hWnd, hWnd,,ToolbarWindow321, ahk_id %Test%


        ToolbarItems := GetToolbarItems(g_hWnd)
        For Each, Item in ToolbarItems {
            MsgBox % "Zeilennummer " A_LineNumber  " und Ergebnis :  A_Index: " A_Index " Item.ID: " Item.ID " Item.String: " Item.String

        }

return

*/

GetToolbarItems(hToolbar) {
	WinGet PID, PID, ahk_id %hToolbar%

    If !(hProc := DllCall("OpenProcess", "UInt", 0x438, "Int", False, "UInt", PID, "Ptr")) {
        Return
    }

    If (A_Is64bitOS) {
        Try DllCall("IsWow64Process", "Ptr", hProc, "Int*", Is32bit := true)
    } Else {
        Is32bit := True
    }

    RPtrSize := Is32bit ? 4 : 8
    TBBUTTON_SIZE := 8 + (RPtrSize * 3)

    SendMessage 0x418, 0, 0,, ahk_id %hToolbar% ; TB_BUTTONCOUNT
    ButtonCount := ErrorLevel

    IDs := [] ; Command IDs
    Loop %ButtonCount% {
        Address := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "UPtr", TBBUTTON_SIZE, "UInt", 0x1000, "UInt", 4, "Ptr")

        SendMessage 0x417, % A_Index - 1, Address,, ahk_id %hToolbar% ; TB_GETBUTTON   ; Wird die Reihenfolge der Id's ermiitelt zum A_index
        If (ErrorLevel == 1) {
            VarSetCapacity(TBBUTTON, TBBUTTON_SIZE, 0)
            DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", Address, "Ptr", &TBBUTTON, "UPtr", TBBUTTON_SIZE, "Ptr", 0)
            IDs.Push(NumGet(&TBBUTTON, 4, "Int"))
        }

        DllCall("VirtualFreeEx", "Ptr", hProc, "Ptr", Address, "UPtr", 0, "UInt", 0x8000) ; MEM_RELEASE
    }

    ToolbarItems := []
    Loop % IDs.Length() {
        ButtonID := IDs[A_Index]
        ;~ SendMessage 0x44B, %ButtonID% , 0,, ahk_id %hToolbar% ; TB_GETBUTTONTEXTW
        ;BufferSize := ErrorLevel * 2

        BufferSize := 128

        Address := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "UPtr", BufferSize, "UInt", 0x1000, "UInt", 4, "Ptr")

        SendMessage 0x44B, %ButtonID%, Address,, ahk_id %hToolbar% ; TB_GETBUTTONTEXTW

        VarSetCapacity(Buffer, BufferSize, 0)
        Test := DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", Address, "Ptr", &Buffer, "UPtr", BufferSize, "Ptr", 0)
		MsgBox % "Zeilennummer " A_LineNumber  " und Ergebnis : " Buffer
        ToolbarItems.Push({"ID": IDs[A_Index], "String": Buffer})

        DllCall("VirtualFreeEx", "Ptr", hProc, "Ptr", Address, "UPtr", 0, "UInt", 0x8000) ; MEM_RELEASE
    }

    DllCall("CloseHandle", "Ptr", hProc)


	  For Each, Item in ToolbarItems {
            MsgBox % "Zeilennummer " A_LineNumber  " und Ergebnis :  A_Index: " A_Index " Item.ID: " Item.ID " Item.String: " Item.String
	}
    Return ToolbarItems
}