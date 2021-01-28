; Gets focused control in XP to prevent blocking double clicks like with ControlGetFocus
XPGetFocussed()
{
    WinGet ctrlList, ControlList, A
    ctrlHwnd:=GetFocusedControl()
    ; Built an array indexing the control names by their hwnd
    Loop Parse, ctrlList, `n
    {
        ControlGet hwnd, Hwnd, , %A_LoopField%, A
        hwnd += 0   ; Convert from hexa to decimal
        if (hwnd=ctrlHwnd)
            return A_LoopField
    }
}

; This script retrieves the ahk_id (HWND) of the active window's focused control.
; This script requires Windows 98+ or NT 4.0 SP3+.
/*
typedef struct tagGUITHREADINFO {
  DWORD cbSize;
  DWORD flags;
  HWND  hwndActive;
  HWND  hwndFocus;
  HWND  hwndCapture;
  HWND  hwndMenuOwner;
  HWND  hwndMoveSize;
  HWND  hwndCaret;
  RECT  rcCaret;
} GUITHREADINFO, *PGUITHREADINFO;
*/
GetFocusedControl()
{
    guiThreadInfoSize := 8 + 6 * A_PtrSize + 16
    VarSetCapacity(guiThreadInfo, guiThreadInfoSize, 0)
    NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
    ; DllCall("RtlFillMemory" , "PTR", &guiThreadInfo, "UInt", 1 , "UChar", guiThreadInfoSize)   ; Below 0xFF, one call only is needed
    if (DllCall("GetGUIThreadInfo" , "UInt", 0   ; Foreground thread
        , "PTR", &guiThreadInfo) = 0)
    {
        ErrorLevel := A_LastError   ; Failure
        Return 0
    }
    focusedHwnd := NumGet(guiThreadInfo,8+A_PtrSize, "Ptr") ; *(addr + 12) + (*(addr + 13) << 8) +  (*(addr + 14) << 16) + (*(addr + 15) << 24)
    Return focusedHwnd
}

; Test if a window is a Dialog window
IsDialog(window=0,ListViewSelected = False)
{
    result:=0
    if (window)
        window:="ahk_id " window
    else
        window:="A"
    if (WinGetClass(window)="#32770")
    {
        ; Check for new FileOpen dialog
        ControlGet, hwnd, Hwnd , , DirectUIHWND3, %window%
        if (hwnd)
        {
            ControlGet, hwnd, Hwnd , , SysTreeView321, %window%
            if (hwnd)
            {
                ControlGet, hwnd, Hwnd , , Edit1, %window%
                if (hwnd)
                {
                    ControlGet, hwnd, Hwnd , , Button2, %window%
                    if (hwnd)
                    {
                        ControlGet, hwnd, Hwnd , , ComboBox2, %window%
                        if (hwnd)
                        {
                            ControlGet, hwnd, Hwnd , , ToolBarWindow323, %window%
                            if (hwnd)
                            result:=(!ListViewSelected||IsControlActive("DirectUIHWND2")||IsControlActive("SysTreeView321"))
                        }
                    }
                }
            }
        }
        ; Check for old FileOpen dialog
        if (!result)
        {
            ControlGet, hwnd, Hwnd , , ToolbarWindow321, %window%
            if (hwnd)
            {
                ControlGet, hwnd, Hwnd , , SysListView321, %window%
                if (hwnd)
                {
                    ControlGet, hwnd, Hwnd , , ComboBox3, %window%
                    if (hwnd)
                    {
                        ControlGet, hwnd, Hwnd , , Button3, %window%
                        if (hwnd)
                        {
                            ControlGet, hwnd, Hwnd , , SysHeader321 , %window%
                            if (hwnd)
                            result:=(!ListViewSelected||IsControlActive("DirectUIHWND2")||IsControlActive("SysTreeView321")) ? 2 : 0
                        }
                    }
                }
            }
        }
    }
    return result
}

; Checks if a specific control class is active. Matches by start of ClassNN.
IsControlActive(controlclass)
{
    if (WinVer >= WIN_7)
        ControlGetFocus active, A
    else
        active := XPGetFocussed()
    if (InStr(active, controlclass))
        return true
    return false
}

/*
HWND WINAPI GetParent(
  __in  HWND hWnd
);
*/
GetParent(hWnd)
{
    return DllCall("GetParent", "Ptr", hWnd, "Ptr")
}

; Checks if a context menu is active and has focus
; Need to check if other context menus are active (trillian, browsers,...)
IsContextMenuActive()
{
    GuiThreadInfoSize := 24 + 6 * A_PtrSize
    VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
    NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
    if not DllCall("GetGUIThreadInfo", uint, 0, "Ptr", &GuiThreadInfo)
    {
      ; MsgBox GetGUIThreadInfo() indicated a failure.
      return
  }
  ; GuiThreadInfo contains a DWORD flags at byte 4
  ; Bit 4 of this flag is set if the thread is in menu mode. GUI_INMENUMODE = 0x4
  if (NumGet(GuiThreadInfo, 4) & 0x4)
  return true
  return false
}



; This stuff doesn't properly use COM.ahk yet :(
/*
Executes context menu entries of shell items without showing their menus
Usage:
ShellContextMenu("Desktop",1)            ;Calls "Next Desktop background" in Win7
1st parameter can be "Desktop" for empty selection desktop menu, a path, or an idl
Leave 2nd parameter empty to show context menu and extract idn by clicking on an entry (shows up in debugview)
*/
#include lib\ahklib\CNotification.ahk
ShellContextMenu(sPath,idn=0)
{
    result := DllCall(Settings.DllPath "\Explorer.dll\ExecuteContextMenuCommand", "Str", sPath, "Int", idn, "PTR", A_ScriptHwnd)
    if (Errorlevel != 0)
    Notify("Couldn't execute context menu command!", "Error Calling ExecuteContextMenuCommand() in Explorer.dll!", 5, NotifyIcons.Error)
}

; Checks if a specific window is under the cursor.
IsWindowUnderCursor(hwnd)
{
    MouseGetPos, , , win
    if hwnd is number
    return win = hwnd
    else
    return InStr(WinGetClass("ahk_class " win), hwnd)
}

; Checks if a specific control is under the cursor and returns its ClassNN if it is.
IsControlUnderCursor(ControlClass)
{
    MouseGetPos, , , , control
    if (InStr(Control, ControlClass))
    return control
    return false
}

; Adds a tooltip to a control.
AddToolTip(con, text, Modify = 0)
{
    Static TThwnd,GuiHwnd
    l_DetectHiddenWindows := A_DetectHiddenWindows
    if (!TThwnd)
    {
        Gui, +LastFound
        GuiHwnd := WinExist()
        TThwnd := CreateTooltipControl(GuiHwnd)
        Varsetcapacity(TInfo, 6 * 4 + 6 * A_PtrSize, 0)
        Numput(6 * 4 + 6 * A_PtrSize, TInfo, "UInt")
        Numput(1 | 16, TInfo, 4, "UInt")
        Numput(GuiHwnd, TInfo, 8, "PTR")
        Numput(GuiHwnd, TInfo, 8 + A_PtrSize, "PTR")
        ; Numput(&text,TInfo,36)
        Detecthiddenwindows, on
        Sendmessage, 1028, 0, &TInfo, , ahk_id %TThwnd%
        SendMessage, 1048, 0, 300, , ahk_id %TThwnd%
    }
    Varsetcapacity(TInfo, 6 * 4 + 6 * A_PtrSize, 0)
    Numput(6 * 4 + 6 * A_PtrSize, TInfo, "UInt")
    Numput(1 | 16, TInfo, 4, "UInt")
    Numput(GuiHwnd, TInfo, 8, "PTR")
    Numput(con, TInfo, 8 + A_PtrSize, "PTR")
    VarSetCapacity(ANSItext, StrPut(text, ""))
    StrPut(text, &ANSItext, "")
    Numput(&ANSIText, TInfo, 6 * 4 + 3 * A_PtrSize, "PTR")

    Detecthiddenwindows, on
    if (Modify)
    SendMessage, 1036, 0, &TInfo, , ahk_id %TThwnd%
    else
    {
        Sendmessage, 1028, 0, &TInfo, , ahk_id %TThwnd%
        SendMessage, 1048, 0, 300, , ahk_id %TThwnd%
    }
    DetectHiddenWindows %l_DetectHiddenWindows%
}

CreateTooltipControl(hwind)
{
    Ret := DllCall("CreateWindowEx"
        ,"Uint", 0
        ,"Str", "TOOLTIPS_CLASS32"
        ,"PTR", 0
        ,"Uint", 2147483648 | 3
        ,"Uint", -2147483648
        ,"Uint", -2147483648
        ,"Uint", -2147483648
        ,"Uint", -2147483648
        ,"PTR", hwind
        ,"PTR", 0
        ,"PTR", 0
        ,"PTR", 0, "PTR")
    return Ret
}

; Attaches a window as a tool window to another window from a different process. QUESTION: Is this still needed?
AttachToolWindow(hParent, GUINumber, AutoClose)
{
    global ToolWindows
    WriteDebug("AttachToolWindow " GUINumber " to " hParent, "", "debug", "ExplorerHelpers")
    if (!IsObject(ToolWindows))
    ToolWindows := Object()
    if (!WinExist("ahk_id " hParent))
    return false
    Gui %GUINumber%: +LastFoundExist
    if (!(hGui := WinExist()))
    return false
    ; SetWindowLongPtr is defined as SetWindowLong in x86
    if (A_PtrSize = 4)
    DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
    else
    DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
    ToolWindows.Insert(Object("hParent", hParent, "hGui", hGui,"AutoClose", AutoClose))
    Gui %GUINumber%: Show, NoActivate
    return true
}

DeAttachToolWindow(GUINumber)
{
    global ToolWindows
    Gui %GUINumber%: +LastFoundExist
    if (!(hGui := WinExist()))
    return false
    Loop % ToolWindows.MaxIndex()
    {
        if (ToolWindows[A_Index].hGui = hGui)
        {
            ; SetWindowLongPtr is defined as SetWindowLong in x86
            if (A_PtrSize = 4)
            DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
            else
            DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
            DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0)
            ToolWindows.Remove(A_Index)
            break
        }
    }
}
