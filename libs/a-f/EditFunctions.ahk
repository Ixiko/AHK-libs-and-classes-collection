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
;http://www.autohotkey.com/board/topic/20981-edit-control-functions/


EditFunc_Standard_Params(ByRef Control, ByRef WinTitle) {  ; Helper function.
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
EditFunc_TextIsSelected(Control="", WinTitle="")
{
    EditFunc_Standard_Params(Control, WinTitle)
    return EditFunc_GetSelection(start, end, Control, WinTitle) and (start!=end)
}

; Gets the start and end offset of the current selection.
;
EditFunc_GetSelection(ByRef start, ByRef end, Control="", WinTitle="")
{
    EditFunc_Standard_Params(Control, WinTitle)
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
EditFunc_Select(start=0, end=-1, Control="", WinTitle="")
{
    EditFunc_Standard_Params(Control, WinTitle)
    SendMessage, 0xB1, start, end, %Control%, %WinTitle%  ; EM_SETSEL
    EditFunc_SCROLLCARET(control,wintitle)
    return (ErrorLevel != "FAIL")
}



; Selects a line of text.
;
; line:             One-based line number, or 0 to select the current line.
; include_newline:  Whether to also select the line terminator (`r`n).
;
EditFunc_SelectLine(line=0, include_newline=false, Control="", WinTitle="")
{
    EditFunc_Standard_Params(Control, WinTitle)
    
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
    
    EditFunc_SCROLLCARET(control,wintitle)
    
    return (ErrorLevel != "FAIL")
}

; Deletes a line of text.
;
; line:     One-based line number, or 0 to delete current line.
;
EditFunc_DeleteLine(line=0, Control="", WinTitle="")
{
    EditFunc_Standard_Params(Control, WinTitle)
    ; Select the line.
    if (EditFunc_SelectLine(line, true, Control, WinTitle))
    {   ; Delete it.
        ControlSend, %Control%, {Delete}, %WinTitle%
        return true
    }
    return false
}



EditFunc_GetLine(line=0, Control="", WinTitle=""){
    EditFunc_Standard_Params(Control, WinTitle)
    
    if (line<1)
        ControlGet, line, CurrentLine
    
    controlget,thisLine,line,% line
    
    return thisLine
}

EditFunc_GetFullLine(line=0, include_newline=false, control="",wintitle=""){
    EditFunc_Standard_Params(Control, WinTitle)
    
    line:=floor(line*1)
    
    if (line<1)
        ControlGet, line, CurrentLine,,% control,% wintitle
    
	SendMessage, 0xBB, line-1, 0,% control,% wintitle  ; EM_LINEINDEX
    offset:= ErrorLevel
	
	
	
	controlgettext,alltext,% control,% wintitle
	count:=0
	loop,parse,alltext,`n
		maxCount:=a_index
	loop,parse,allText,`n
	{
		count+=strlen(a_loopfield)+1
		if (count>offset){
			str:=a_loopfield "`n"
			count:=a_index
			break
		}
	}
    
    
	
	if (count=maxCount || !include_newLine)
		return RegExReplace(str,"[\r\n]","")
	else
		return str
	
    controlget,lineCount,LineCount,,% control,% wintitle
    controlget,thisLine,line,% line,% control,% wintitle
    clipboard:=thisLine
    if lineCount=1
        return thisLine
    
    while !regexmatch(thisLine,"(\n|\r)$") && (line+a_index<=lineCount) {
        controlget,addLine,line,% line+a_index,% control,% wintitle
        thisLine.=addLine
    }
    
    while (line-a_index>0) {
        controlget,addLine,line,% line-a_index,% control,% wintitle
        if !regexmatch(addLine,"(\n|\r)$")
            thisLine:=addLine thisLine
        else 
            break
    }

    return thisLine
    
}

EditFunc_InsertText(text,control="",wintitle=""){
    EditFunc_Standard_Params(Control, WinTitle)
    
    EditFunc_getSelection(selStart,selEnd,control,wintitle)
    controlgettext,alltext,% control,% wintitle
    controlsettext,% control,% substr(alltext,1,selStart) text substr(alltext,selEnd+1),% wintitle
    EditFunc_select(selStart+strlen(text),selStart+strlen(text),control,wintitle)
}

EditFunc_SCROLLCARET(control="",wintitle=""){
    SendMessage,0xB7,,,% control,% wintitle
}
