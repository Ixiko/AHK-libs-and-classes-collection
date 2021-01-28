;************************
; Edit Control Functions
;************************
;
; Standard parameters:
;   Control, WinTitle   If WinTitle is not specified, 'Control' may be the
;                       unique ID (hwnd) of the control.  If "A" is specified
;                       in Control, the control with input focus is used.
;
; Standard/default return value:
;   true on success, otherwise false.


Edit_Standard_Params(ByRef Control, ByRef WinTitle) {  ; Helper function.
    if (Control="A" && WinTitle="") { ; Control is "A", use focused control.
        ControlGetFocus, Control, A
        WinTitle = A
    } else if (Control+0!="" && WinTitle="") {  ; Control is numeric, assume its a ahk_id.
        WinTitle := "ahk_id " . Control
        Control =
    }
}

; Returns true if text is selected, otherwise false.
;
Edit_TextIsSelected(Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    return Edit_GetSelection(start, end, Control, WinTitle) and (start!=end)
}

; Gets the start and end offset of the current selection.
;
Edit_GetSelection(ByRef start, ByRef end, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    VarSetCapacity(start, 4), VarSetCapacity(end, 4)
    SendMessage, 0xB0, &start, &end, %Control%, %WinTitle%  ; EM_GETSEL
    if (ErrorLevel="FAIL")
        return false
    start := NumGet(start), end := NumGet(end)
    return true
}

; Selects text in a text box, given absolute character positions (starting at 0.)
;
; start:    Starting character offset, or -1 to deselect.
; end:      Ending character offset, or -1 for "end of text."
;
Edit_Select(start=0, end=-1, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    SendMessage, 0xB1, start, end, %Control%, %WinTitle%  ; EM_SETSEL
    return (ErrorLevel != "FAIL")
}

; Selects a line of text.
;
; line:             One-based line number, or 0 to select the current line.
; include_newline:  Whether to also select the line terminator (`r`n).
;
Edit_SelectLine(line=0, include_newline=false, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    
    ControlGet, hwnd, Hwnd,, %Control%, %WinTitle%
    if (!WinExist("ahk_id " hwnd))
        return false
    
    if (line<1)
        ControlGet, line, CurrentLine
    
    SendMessage, 0xBB, line-1, 0  ; EM_LINEINDEX
    offset := ErrorLevel

    SendMessage, 0xC1, offset, 0  ; EM_LINELENGTH
    lineLen := ErrorLevel

    if (include_newline) {
        WinGetClass, class
        lineLen += (class="Edit") ? 2 : 1 ; `r`n : `n
    }
    
    ; Select the line.
    SendMessage, 0xB1, offset, offset+lineLen  ; EM_SETSEL
    return (ErrorLevel != "FAIL")
}

; Deletes a line of text.
;
; line:     One-based line number, or 0 to delete current line.
;
Edit_DeleteLine(line=0, Control="", WinTitle="") {
    Edit_Standard_Params(Control, WinTitle)
    ; Select the line.
    if (Edit_SelectLine(line, true, Control, WinTitle))
    {   ; Delete it.
        ControlSend, %Control%, {Delete}, %WinTitle%
        return true
    }
    return false
}

; Returns true if text is copied to the clipboard, otherwise false.
;
Edit_CopySelected(Control="",WinTitle="") {
    Edit_Standard_Params(Control,WinTitle)
    if Edit_TextIsSelected(Control,WinTitle)
        {
        SendMessage 0x301,0,0,%Control%, %WinTitle%  ; WM_COPY
        return true
        }

    return false
    }

; Returns true if text is copied to the clipboard, otherwise false.
;
Edit_CutSelected(Control="",WinTitle="") {
    Edit_Standard_Params(Control,WinTitle)
    if Edit_TextIsSelected(Control,WinTitle)
        {
        SendMessage 0x300,0,0,%Control%,%WinTitle%  ; WM_CUT
        return true
        }

    return false
    }

; Returns true if text is pasted from the clipboard, otherwise false.
;
Edit_Paste(Control="",WinTitle="")  {
    Edit_Standard_Params(Control,WinTitle)
    if StrLen(Clipboard)
        {
        SendMessage 0x302,0,0,%Control%,%WinTitle%  ; WM_PASTE
        return true
        }

    return false
    }

; Returns true if selected text is cleared (deleted), otherwise false.
; Note: Undo can be used to reverse this action.
;
Edit_Clear(Control="",WinTitle="")  {
    Edit_Standard_Params(Control,WinTitle)
    if Edit_TextIsSelected(Control,WinTitle)
        {
        SendMessage 0x303,0,0,%Control%,%WinTitle%  ; WM_CLEAR
        return true
        }

    return false
    }

; Returns true if undo action was successful, otherwise false.
;
Edit_Undo(Control="",WinTitle="")  {
    Edit_Standard_Params(Control,WinTitle)
    SendMessage 0x304,0,0,%Control%,%WinTitle%  ; WM_UNDO
    return ErrorLevel
    }
