; ===============================================================================================================================
; Make the windows 10 taskbar translucent (blur)
; https://autohotkey.com/boards/viewtopic.php?f=6&t=26752
; ===============================================================================================================================

/*
TaskBar_SetAttr(option, color)

option -> 0 = off
          1 = gradient    (+color)
          2 = transparent (+color)
          3 = blur
color  -> ABGR (alpha | blue | green | red) 0xffd7a78f
*/

TaskBar_SetAttr(accent_state := 0, gradient_color := "0x01000000")
{
    static init, hTrayWnd, ver := DllCall("GetVersion") & 0xff < 10
    static pad := A_PtrSize = 8 ? 4 : 0, WCA_ACCENT_POLICY := 19

    if !(init) {
        if (ver)
            throw Exception("Minimum support client: Windows 10", -1)
        if !(hTrayWnd := DllCall("user32\FindWindow", "str", "Shell_TrayWnd", "ptr", 0, "ptr"))
            throw Exception("Failed to get the handle", -1)
        init := 1
    }

    accent_size := VarSetCapacity(ACCENT_POLICY, 16, 0)
    NumPut((accent_state > 0 && accent_state < 4) ? accent_state : 0, ACCENT_POLICY, 0, "int")

    if (accent_state >= 1) && (accent_state <= 2) && (RegExMatch(gradient_color, "0x[[:xdigit:]]{8}"))
        NumPut(gradient_color, ACCENT_POLICY, 8, "int")

    VarSetCapacity(WINCOMPATTRDATA, 4 + pad + A_PtrSize + 4 + pad, 0)
    && NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
    && NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
    && NumPut(accent_size, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    if !(DllCall("user32\SetWindowCompositionAttribute", "ptr", hTrayWnd, "ptr", &WINCOMPATTRDATA))
        throw Exception("Failed to set transparency / blur", -1)
    return true
}

; ===============================================================================================================================

TaskBar_SetAttr(1, 0xc1e3c791)    ; <- Set gradient    with color 0xd7a78f ( rgb = 0x91c7e3 ) and alpha 0xc1
sleep 3000
TaskBar_SetAttr(2, 0xa1e3c791)    ; <- Set transparent with color 0xd7a78f ( rgb = 0x91c7e3 ) and alpha 0xa1
sleep 3000
TaskBar_SetAttr(2)                ; <- Set transparent
sleep 3000
TaskBar_SetAttr(3)                ; <- Set blur
sleep 3000
TaskBar_SetAttr(0)                ; <- Set standard value
ExitApp

/*
Since clicking on Win-Start will reset the taskbar, it will be the best solution to use a SetTimer with x ms to set the Attribute

#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines -1

SetTimer, UPDATE_TASKBAR, 100
return

UPDATE_TASKBAR:
    TaskBar_SetAttr(3)
return
*/


; ===============================================================================================================================

/*
Shell_TrayWnd             -> Main TaskBar
Shell_SecondaryTrayWnd    -> 2nd  TaskBar (on multiple monitors)
*/

/* C++ ==========================================================================================================================

BOOL GetWindowCompositionAttribute(
    _In_    HWND hWnd,
    _Inout_ WINDOWCOMPOSITIONATTRIBDATA* pAttrData
);

BOOL SetWindowCompositionAttribute(
    _In_    HWND hWnd,
    _Inout_ WINDOWCOMPOSITIONATTRIBDATA* pAttrData
);


typedef struct _WINDOWCOMPOSITIONATTRIBDATA {
    WINDOWCOMPOSITIONATTRIB Attrib;
    PVOID                   pvData;
    SIZE_T                  cbData;
} WINDOWCOMPOSITIONATTRIBDATA;


typedef enum _WINDOWCOMPOSITIONATTRIB {
    WCA_UNDEFINED = 0,
    WCA_NCRENDERING_ENABLED = 1,
    WCA_NCRENDERING_ENABLED = 1,
    WCA_NCRENDERING_POLICY = 2,
    WCA_TRANSITIONS_FORCEDISABLED = 3,
    WCA_ALLOW_NCPAINT = 4,
    WCA_CAPTION_BUTTON_BOUNDS = 5,
    WCA_NONCLIENT_RTL_LAYOUT = 6,
    WCA_FORCE_ICONIC_REPRESENTATION = 7,
    WCA_EXTENDED_FRAME_BOUNDS = 8,
    WCA_HAS_ICONIC_BITMAP = 9,
    WCA_THEME_ATTRIBUTES = 10,
    WCA_NCRENDERING_EXILED = 11,
    WCA_NCADORNMENTINFO = 12,
    WCA_EXCLUDED_FROM_LIVEPREVIEW = 13,
    WCA_VIDEO_OVERLAY_ACTIVE = 14,
    WCA_FORCE_ACTIVEWINDOW_APPEARANCE = 15,
    WCA_DISALLOW_PEEK = 16,
    WCA_CLOAK = 17,
    WCA_CLOAKED = 18,
    WCA_ACCENT_POLICY = 19,
    WCA_FREEZE_REPRESENTATION = 20,
    WCA_EVER_UNCLOAKED = 21,
    WCA_VISUAL_OWNER = 22,
    WCA_LAST = 23
} WINDOWCOMPOSITIONATTRIB;


typedef struct _ACCENT_POLICY {
    ACCENT_STATE AccentState;
    DWORD        AccentFlags;
    DWORD        GradientColor;
    DWORD        AnimationId;
} ACCENT_POLICY;


typedef enum _ACCENT_STATE {
    ACCENT_DISABLED = 0,
    ACCENT_ENABLE_GRADIENT = 1,
    ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
    ACCENT_ENABLE_BLURBEHIND = 3,
    ACCENT_INVALID_STATE = 4
} ACCENT_STATE;


_ACCENT_FLAGS {
    DrawLeftBorder = 0x20,
    DrawTopBorder = 0x40,
    DrawRightBorder = 0x80,
    DrawBottomBorder = 0x100,
    DrawAllBorders = (DrawLeftBorder | DrawTopBorder | DrawRightBorder | DrawBottomBorder)
}

============================================================================================================================== */