; Uncomment this if MI.ahk is not in your function library:
;#include %A_ScriptDir%\MI.ahk

#NoEnv

; Sample menu items.
Menu, M, Add, 16x16 Icon, ItemClick
Menu, M, Add, 32x32 Icon, ItemClick
Menu, M, Add, 48x48 Icon, ItemClick

; Set item 1's icon to shell32.dll, icon 4, 16x16.
MI_SetMenuItemIcon("M", 1, "shell32.dll", 4, 16)
; Set item 2's icon to shell32.dll, icon 4, 32x32.
MI_SetMenuItemIcon("M", 2, "shell32.dll", 4, 32)
; Windows 2000 or later required (supports sizes other than 16x16 and 32x32):
MI_SetMenuItemIcon("M", 3, "shell32.dll", 4, 48)
; Usually looks better:
MI_SetMenuStyle("M", 0x4000000)

; Note: This menu is shown automatically after setting up the tray menu.


;
; Icons in the Tray menu!
;
; Refer to a menu by handle for efficiency.
hTM := MI_GetMenuHandle("Tray")

if (A_OSVersion != "WIN_VISTA")
{   ; It is necessary to hook the tray icon for owner-drawing to work.
    ; (Owner-drawing is not used on Windows Vista.)
    OnMessage(0x404, "AHK_NOTIFYICON")
    OnMessage(0x111, "WM_COMMAND") ; To track "pause" status.
    MI_SetMenuStyle(hTM, 0x4000000) ; MNS_CHECKORBMP (optional)
}

SplitPath, A_AhkPath,, SpyPath
SpyPath = %SpyPath%\AU3_Spy.exe

MI_SetMenuItemIcon(hTM, 1, A_AhkPath, 1, 16) ; open
MI_SetMenuItemIcon(hTM, 2, A_WinDir "\hh.exe", 1, 16) ; help
;-
MI_SetMenuItemIcon(hTM, 4, SpyPath,   1, 16) ; spy
; reload - icon needed!
MI_SetMenuItemIcon(hTM, 6, A_AhkPath, 2, 16) ; edit
;-
MI_SetMenuItemIcon(hTM, 8, A_AhkPath, 3, 16) ; suspend
MI_SetMenuItemIcon(hTM, 9, A_AhkPath, 4, 16) ; pause
MI_SetMenuItemBitmap(hTM, 10, 8) ; exit


MI_ShowMenu("M")
return

ItemClick:
return


AHK_NOTIFYICON(wParam, lParam)
{
    global hTM, M_IsPaused
    if (lParam = 0x205) ; WM_RBUTTONUP
    {
        ; Update "Suspend Script" and "Pause Script" checkmarks.
        DllCall("CheckMenuItem","uint",hTM,"uint",65305,"uint",A_IsSuspended ? 8:0)
        DllCall("CheckMenuItem","uint",hTM,"uint",65306,"uint",M_IsPaused ? 8:0)
        ; Show menu to allow owner-drawing.
        MI_ShowMenu(hTM)
        return 0
    }
}

WM_COMMAND(wParam, lParam, Msg, hwnd)
{
    Critical
    global M_IsPaused
    id := wParam & 0xFFFF
    if id in 65306,65403  ; tray pause, file menu pause
    {
        ; When the script is not paused, WM_COMMAND() is called once for
        ; AutoHotkey --** and once for OwnerDrawnMenuMsgWin **--.
        DetectHiddenWindows, On
        WinGetClass, cl, ahk_id %hwnd%
        if cl != AutoHotkey
            return
       
        ; This will become incorrect if "pause" is used from the script.
        M_IsPaused := ! M_IsPaused
    }
}