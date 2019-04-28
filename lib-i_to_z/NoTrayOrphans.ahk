NoTrayOrphans() {
    TrayInfo:= TrayIcons(sExeName,"ahk_class Shell_TrayWnd","ToolbarWindow32" . GetTrayBar()) "`n"
        . TrayIcons(sExeName,"ahk_class NotifyIconOverflowWindow","ToolbarWindow321")
    Loop, Parse, TrayInfo, `n
        {
        ProcessName:= StrX(A_Loopfield, "| Process: ", " |")
        ProcesshWnd:= StrX(A_Loopfield, "| hWnd: ", " |")
        ProcessuID := StrX(A_Loopfield, "| uID: ", " |")
        If !ProcessName && ProcesshWnd
            RemoveTrayIcon(ProcesshWnd, ProcessuID)
        }
    }
RemoveTrayIcon(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2) {
    NumPut(VarSetCapacity(ni,444,0), ni)
    NumPut(hWnd , ni, 4)
    NumPut(uID  , ni, 8)
    NumPut(1|2|4, ni,12)
    NumPut(nMsg , ni,16)
    NumPut(hIcon, ni,20)
    Return    DllCall("shell32\Shell_NotifyIconA", "Uint", nRemove, "Uint", &ni)
    }
TrayIcons(sExeName,traywindow,control) {
    DetectHiddenWindows, On
    WinGet,   pidTaskbar, PID, %traywindow%
    hProc:=   DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
    pProc:=   DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
    SendMessage, 0x418, 0, 0, %control%, %traywindow%
    Loop,   %ErrorLevel%
    {
    SendMessage, 0x417, A_Index-1, pProc, %control%, %traywindow%
    VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
    DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
    iBitmap   := NumGet(btn, 0)
    idn   := NumGet(btn, 4)
    Statyle := NumGet(btn, 8)
    If   dwData   := NumGet(btn,12)
    iString   := NumGet(btn,16)
    Else   dwData   := NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
    DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
    If   NumGet(btn,12)
    hWnd   := NumGet(nfo, 0)
    ,   uID   := NumGet(nfo, 4)
    ,   nMsg   := NumGet(nfo, 8)
    ,   hIcon   := NumGet(nfo,20)
    Else   hWnd   := NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8), nMsg:=NumGet(nfo,12), hIcon := NumGet(nfo,24)
    WinGet, pid, PID,			  ahk_id %hWnd%
    WinGet, sProcess, ProcessName, ahk_id %hWnd%
    WinGetClass, sClass,		   ahk_id %hWnd%
    If !sExeName || (sExeName = sProcess) || (sExeName = pid)
    VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
    ,   DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
    ,   DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
    ,   sTrayIcons .= "idx: " . A_Index-1 . " | idn: " . idn . " | Pid: " . pid . " | uID: " . uID . " | MessageID: " . nMsg . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . " | Icon: " . hIcon . " | Tooltip: " . wTooltip . "`n"
    }
    DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
    DllCall("CloseHandle", "Uint", hProc)
    return   sTrayIcons
    }
GetTrayBar() {
    ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
    ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
    Loop {
        ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
        If  Not    hWnd
        Break
        Else If    hWnd = %hChild%
            {
            idxTB := A_Index
            Break
            }
        }
    Return    idxTB
    }

StrX( H,BS="",ES="",Tr=1,ByRef OS=1) {
    return,(SP := InStr(H,BS,0,OS)) && (L := InStr(H,ES,0,SP+StrLen(BS))) && (OS := L + StrLen(ES)) ? SubStr(H,SP := Tr ? SP + StrLen(BS) : SP ,(Tr ? L : L + StrLen(ES))-SP) : ""
    }
