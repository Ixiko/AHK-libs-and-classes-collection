RefreshTray() {                                                                                                	;Remove icons from Tray menu for crashed or terminated scripts\apps
	;Link: https://autohotkey.com/board/topic/33849-refreshtray/
	ControlGetPos,,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd
	width:=w, hight:=h
	While % ((h:=h-5)>0 and w:=width){
		While % ((w:=w-5)>0){
			PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class Shell_TrayWnd
		}
	}
}

GetTrayBar() {
	;Link: https://autohotkey.com/board/topic/33849-refreshtray/
	ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
	Loop	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
		If  Not	hWnd
			Break
		Else If (hWnd = %hChild%) 		{
			idxTB := A_Index
			Break
		}
	}
	Return	idxTB
}

GetTrayIconInfo(TargetPID, ByRef hWnd, ByRef uID, ByRef nMsg, ByRef hIcon, ByRef sTooltip) {

	; Adapted from Sean's TrayIcons()
	; http://www.autohotkey.com/forum/topic17314.html

    TBWnd := GetTrayBarHwnd()
    WinGet, pidTaskbar, PID, ahk_id %TBWnd%

    hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
    pRB := DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 20, "Uint", 0x1000, "Uint", 0x4)

    VarSetCapacity(btn, 20)
    VarSetCapacity(nfo, 24)
    VarSetCapacity(sTooltip, 128)
	VarSetCapacity(wTooltip, 128 * 2)

    SendMessage, 0x418, 0, 0,, ahk_id %TBWnd%  ; TB_BUTTONCOUNT

    IconFound = 0
    uID = 0
    nMsg = 0
    hIcon = 0
    sTooltip =

    Loop, %ErrorLevel%
    {
        SendMessage, 0x417, A_Index - 1, pRB,, ahk_id %TBWnd% ; TB_GETBUTTON

        DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pRB, "Uint", &btn, "Uint", 20, "Uint", 0)

        dwData    := NumGet(btn, 12)
        iString   := NumGet(btn, 16)

        DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 24, "Uint", 0)

        hWnd  := NumGet(nfo, 0)

        WinGet, pid, PID, ahk_id %hWnd%

        If TargetPID = %pid%
        {
            uID   := NumGet(nfo, 4)
            nMsg  := NumGet(nfo, 8)
            hIcon := NumGet(nfo, 20)

            DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128 * 2, "Uint", 0)
			DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)

            IconFound = 1
            break
        }
    }

    DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pRB, "Uint", 0, "Uint", 0x8000)
    DllCall("CloseHandle", "Uint", hProc)

    If IconFound = 0
        hWnd = 0

    return IconFound
}
