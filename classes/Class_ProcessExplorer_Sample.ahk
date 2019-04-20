; GLOBAL SETTINGS ===============================================================================================================

#NoEnv
#SingleInstance Force

SetBatchLines -1

global app := { name: "AHK_ProcessExplorer", version: "2017.10.00011", author: "jNizM", licence: "MIT" }

global LV_Header := "Process Name|CPU|Private Bytes|Working Set|PID|User Name|Handles|Threads|Peak Working Set|PagefileUsage|PeakPagefileUsage|KernelTime|UserTime"
global LV_Size   := ["170", "50 Right", "80 Right", "80 Right", "50 Right", "225", "60 Right", "60 Right", "90 Right", "90 Right", "90 Right", "90 Right", "90 Right"]


; GUI ===========================================================================================================================

Gui, +hWndhMainGui
Gui, Margin, 7, 7
Gui, Color, F1F5FB

Gui, Add, ListView, xm ym w1250 h600 hWndhMainLv01, % LV_Header
SetWindowTheme(hMainLv01)
for i, v in LV_Size
    LV_ModifyCol(i, v)

Gui, Add, Edit, xm y+7 w200 h21 hWndhMainEdt01 vMainEdt01
EM_SETCUEBANNER(hMainEdt01, "Process name here...")

Gui, Add, Button, x+6 yp-1 w95 gSTART_EXPLORER, % "START"
Gui, Add, StatusBar
SB_SetParts(125, 125, 125, 125, 150, 150)
Gui, Show, AutoSize, % app.name
SET_HIDEFOCUS(hMainGui)
WinSet, Redraw
PE := new ProcessExplorer()
return


; WINDOW EVENTS =================================================================================================================

GuiClose:
    if (hClrBtn)
        DllCall("gdi32\DeleteObject", "ptr", hClrBtn)
    ExitApp
return


; SCRIPT ========================================================================================================================

START_EXPLORER:
    Gui, Submit, NoHide

    PE.SetDebugPrivilege()
    WTS := PE.WTSEnumerateProcessesEx()
    GPI := PE.GetPerformanceInfo()
    LV_Delete()
    loop % WTS.MaxIndex()
    {
        if (InStr(WTS[A_Index, "ProcessName"], MainEdt01))
        {
            LV_Add("", WTS[A_Index, "ProcessName"]
                     , ""
                     , PE.GetProcessMemoryInfo(ProcessID := WTS[A_Index, "ProcessId"]).PrivateUsage " K"
                     , WTS[A_Index, "WorkingSetSize"] " K"
                     , ProcessID
                     , (WTS[A_Index, "UserName"] = "") ? "" : WTS[A_Index, "DomainName"] "/" WTS[A_Index, "UserName"]
                     , WTS[A_Index, "HandleCount"]
                     , WTS[A_Index, "NumberOfThreads"]
                     , WTS[A_Index, "PeakWorkingSetSize"] " K"
                     , WTS[A_Index, "PagefileUsage"] " K"
                     , WTS[A_Index, "PeakPagefileUsage"] " K"
                     , WTS[A_Index, "KernelTime"]
                     , WTS[A_Index, "UserTime"] )
        }
    }
    SB_SetText("CPU Usage: ... %", 1)
    SB_SetText("Processes: " GPI.ProcessCount, 2)
    SB_SetText("Threads: " GPI.ThreadCount,  3)
    SB_SetText("Handles: " GPI.HandleCount,  4)
    SB_SetText("Physical Usage: " PE.GlobalMemoryStatusEx().MemoryLoad "%", 5)
    SB_SetText("Up time: " PE.GetTickCount64(), 6)
return


; FUNCTIONS =====================================================================================================================

WM_CTLCOLORBTN()                                                ; https://msdn.microsoft.com/en-us/library/bb761849(v=vs.85).aspx
{
    global hClrBtn
    static init := OnMessage(0x0135, "WM_CTLCOLORBTN")

    if !(hClrBtn)
        hClrBtn := DllCall("gdi32\CreateSolidBrush", "uint", 0xFBF5F1, "uptr")
    return hClrBtn
}

EM_SETCUEBANNER(handle, string)                                 ; https://msdn.microsoft.com/en-us/library/bb761639(v=vs.85).aspx
{
    static ECM_FIRST       := 0x1500 
    static EM_SETCUEBANNER := ECM_FIRST + 1
    if (DllCall("user32\SendMessage", "ptr", handle, "uint", EM_SETCUEBANNER, "int", true, "str", string, "int"))
        return true
    return false
}

SetWindowTheme(handle)                                          ; https://msdn.microsoft.com/en-us/library/bb759827(v=vs.85).aspx
{
    if (DllCall("GetVersion") & 0xff >= 10) {
        VarSetCapacity(ClassName, 1024, 0)
        if (DllCall("user32\GetClassName", "ptr", handle, "str", ClassName, "int", 512, "int"))
            if (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
                if !(DllCall("uxtheme\SetWindowTheme", "ptr", handle, "wstr", "Explorer", "ptr", 0))
                    return true
    }
    return false
}

SET_HIDEFOCUS(wParam, lParam := "", Msg := "", handle := "")    ; https://msdn.microsoft.com/en-us/library/ms646361(v=vs.85).aspx
{
    static Affected         := []
    static WM_UPDATEUISTATE := 0x0128
    static UIS_SET          := 0x1
    static UISF_HIDEFOCUS   := 0x1
    static SET_HIDEFOCUS    := UIS_SET << 16 | UISF_HIDEFOCUS
    static init             := OnMessage(WM_UPDATEUISTATE, Func("SET_HIDEFOCUS"))

    if (Msg = WM_UPDATEUISTATE) {
        if (wParam = SET_HIDEFOCUS)
            Affected[handle] := true
        else if Affected[handle]
            DllCall("user32\PostMessage", "ptr", handle, "uint", WM_UPDATEUISTATE, "ptr", SET_HIDEFOCUS, "ptr", 0)
    }
    else if (DllCall("IsWindow", "ptr", wParam, "uint"))
        DllCall("user32\PostMessage", "ptr", wParam, "uint", WM_UPDATEUISTATE, "ptr", SET_HIDEFOCUS, "ptr", 0)
}


; INCLUDES ======================================================================================================================

#Include Class_ProcessExplorer.ahk


; ===============================================================================================================================