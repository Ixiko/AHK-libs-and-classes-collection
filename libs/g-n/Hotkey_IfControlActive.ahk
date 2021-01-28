/*					Facilitates making hotkeys specific to a control or class of control
; AutoHotkey Version: 1.0.47
; Language:       English
; Platform:       Win98/NT
; Author:         Lexikos
;
; Script Function:
;	Facilitates making hotkeys specific to a control or class of control.
;
; Version History:
;   --      Initial release (no version number.)
;   1.1     Function now sets the initial state of the hotkey correctly.
;

; ControlDesc:
;   Control, WinTitle   -- ala ControlGet. Currently, Control cannot contain a comma.
;   Control             -- ClassNN, or any control of this class.
;
; KeyName:
;   Name of the hotkey.
;
; VariantType:
;   Any sub-command supported by Hotkey,IfWin..  ("IfWinActive", "IfWinExist", etc.)
;
; VariantTitle, VariantText:
;   The parameters of the Hotkey,IfWin.. sub-command.
;
; If VariantType, etc. are omitted, the default variant is used.
; If VariantType is an empty string, which variant is used is undefined.
*/

Hotkey_IfControlActive(ControlDesc, KeyName, VariantType="IfWinActive", VariantTitle="", VariantText="") {
    global H_ICA_List
    static hFocusHook
    
    d1:=chr(1), d2:=chr(2), d3:=chr(3) ; delimiters

    if (!KeyName
        or Hotkey_IfControlActive_InStrAny(ControlDesc KeyName VariantType VariantTitle VariantText, d1 d2 d3))
    {   ; Above: Ensures none of the parameters include any of the delimiters.
        ErrorLevel = Params
        return false
    }
    ; Note: ControlDesc may be blank, indicating IfControlActive should
    ;       no longer be applied to it.

    if (!hFocusHook)
    {   ; Hook focus changes system-wide.
        hFocusHook := DllCall("SetWinEventHook"
            , "uint", 0x8005, "uint", 0x8005  ; EVENT_OBJECT_FOCUS
            , "uint", 0
            , "uint", RegisterCallback("Hotkey_IfControlActive_FocusHook")
            , "uint", 0  ; idProcess (0=all)
            , "uint", 0
            , "uint", 0) ; dwflags = WINEVENT_OUTOFCONTEXT
        if (!hFocusHook) {
            ErrorLevel = Hook
            return false
        }
    }

    if (focus_hwnd := Hotkey_IfControlActive_GetFocus())
    {   ; Set initial state of hotkey based on focused control.
        focus_CNN := Hotkey_IfControlActive_GetClassNN(focus_hwnd)
        is_match := Hotkey_IfControlActive_Match(ControlDesc, focus_hwnd, focus_CNN)
        if VariantType
            Hotkey, %VariantType%, %VariantTitle%, %VariantText%
        Hotkey, %KeyName%, % is_match ? "On" : "Off"
    }

    header := d1 ControlDesc d2
    item := KeyName d3 VariantType d3 VariantTitle d3 VariantText

    if (i := InStr(H_ICA_List, header, true))
    {
        i += StrLen(header)
        H_ICA_List := SubStr(H_ICA_List, 1, i-1)
            . item d2
            . SubStr(H_ICA_List, i)
    }
    else
        H_ICA_List .= header . item
    
    return true
}

Hotkey_IfControlActive_FocusChanged(focus, focus_CNN, from, from_CNN) {
    global H_ICA_List
    
    d1:=chr(1), d2:=chr(2), d3:=chr(3) ; delimiters
    
    Loop, Parse, H_ICA_List, %d1%  ; for each unique ControlDesc
    {
        if (A_LoopField="") ; initial delimiter
            continue
        
        i := InStr(A_LoopField, d2)
        if (!i)
            continue
        
        c := SubStr(A_LoopField, 1, i-1)
        is_match := Hotkey_IfControlActive_Match(c, focus, focus_CNN)
        was_match := Hotkey_IfControlActive_Match(c, from, from_CNN)
        
        if (was_match != is_match)
        {
            s := SubStr(A_LoopField, i+1)
            Loop, Parse, s, %d2%  ; for each hotkey
            {
                ; KeyName d3 VariantType d3 VariantTitle d3 VariantText
                StringSplit, s, A_LoopField, %d3%
                
                ; Hotkey, IfWin..
                if s2
                    Hotkey, %s2%, %s3%, %s4%
                
                Hotkey, %s1%, % is_match ? "On" : "Off"
            }
        }
    }
}

Hotkey_IfControlActive_Match(ControlDesc, hwnd, ClassNN) {
    if !(hwnd or classNN)
        return false

    ; ClassNN
    if (ControlDesc = ClassNN)
        return true
    
    ; Exact Class
    WinGetClass, Class, ahk_id %hwnd%
    if (ControlDesc == Class)
        return true
    
    ; Control, WinTitle
    StringSplit, s, ControlDesc, `, %A_Space%%A_Tab%
    ControlGet, this, Hwnd,, %s1%, %s2%
    return (this = hwnd)
}

Hotkey_IfControlActive_InStrAny(str, any) {
    Loop, Parse, str
        if InStr(any, A_LoopField)
            return true
    return false
}

Hotkey_IfControlActive_FocusHook(hHook, event, hwnd, idObject, idChild, evtThread, evtTime) {										; Occurs when focusing a window, control, menu item, ListView item, etc.
    static last_focus, last_focus_CNN
    
    ; Active window may be hidden. For example, when AHK shows a menu,
    ; the AutoHotkey main window is "Active", but still hidden.
    DetectHiddenWindows, On

    if (WinExist("A"))
    {
        ; ControlGetFocus causes problems, maybe because of AttachThreadInput()?
        ;ControlGetFocus, focus_CNN
        
        ; 'hwnd' is sometimes the parent/ancestor of the control with focus.
        if !(focus_hwnd := Hotkey_IfControlActive_GetFocus())
            focus_hwnd := hwnd
        focus_CNN  := Hotkey_IfControlActive_GetClassNN(focus_hwnd)
            
        if (last_focus != focus_hwnd) {
            Hotkey_IfControlActive_FocusChanged(focus_hwnd, focus_CNN, last_focus, last_focus_CNN)
            last_focus := focus_hwnd
            last_focus_CNN := focus_CNN
        }
    }
}

Hotkey_IfControlActive_GetClassNN(hwnd) {
    WinGet, list, ControlList
    Loop, Parse, list, `n
    {
        ControlGet, this, Hwnd,, %A_LoopField%
        if (this = hwnd)
            return A_LoopField
    }
}

Hotkey_IfControlActive_GetFocus() {

	; Min OS: Windows 98, Windows NT 4.0 SP3
	; (SetWinEventHook requires minimum Windows 98 anyway.)

    VarSetCapacity(info, 48, 0)
    NumPut(48, info, 0)
    return (DllCall("GetGUIThreadInfo", "uint", 0, "uint", &info)
            && !(NumGet(info, 4) & 4)) ; ! GUI_INMENUMODE
        ? NumGet(info, 12) : 0  ; hwndFocus
}