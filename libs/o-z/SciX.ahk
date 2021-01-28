;original functions
;get - retrieve text, get informations
GetSciTEInstance() {
	olderr := ComObjError()
	ComObjError(false)
	scite := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}")
	ComObjError(olderr)
	return IsObject(scite) ? scite : ""
}
Sci_GetCP() {
	; Retrieve active codepage. SCI_GETCODEPAGE
	SendMessage, 2137, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}
Sci_GetCurLine(ByRef uLine) {
	;https://autohotkey.com/board/topic/38186-tillagoto-go-to-functions-labels-hks-in-your-script/page-5
    SendMessage, 2152, 0, 0,, ahk_id %hSci% ;SCI_GETFIRSTVISIBLELINE
    uLine := ErrorLevel
    SendMessage 2008, 0, 0,, ahk_id %hSci% ;SCI_GETCURRENTPOS
    uLine += ErrorLevel << 16
}
Sci_GetCurTextLine() {                                                           	; returns an object with every information about the current text line
	
	sci:= Object()
	Scite:= GetSciTEInstance()
	hScite := GetHex(SciTE.SciTEHandle)
	;ControlGet, hSci, Hwnd,, Scintilla1, ahk_id %hscite%
	hSci:= GetFocusedControl()
	
	sci.hScite          	:= hScite
	sci.hScintilla1   	:= hSci                                                                                                      	; this is the handle we need
	sci.Pos              	:= Sci_GetCurPos(hSci)
	sci.Curline        	:= Sci_LineFromPos(hSci, sci.Pos)
	sci.curText        	:= Sci_GetLine(hSci, sci.curLine)
	sci.Column			:= Sci_GetColumn(hSci, sci.Pos)
	sci.PosFromLine	:= Sci_PosFromLine(hSci, sci.curline)
	sci.PosInStr			:= sci.Pos - sci.PosFromLine + 1
	sci.strL              	:= SubStr(sci.curText, 1, sci.PosInStr - 1)	                                                     	; string in left direction from caret
	sci.strR             	:= SubStr(sci.curText, sci.PosInStr, StrLen(sci.curText) - sci.PosInStr + 1)		; string in right direction from caret
	
return sci
}
Sci_GetCurPos(hSci) {
	; Get the current position. SCI_GETCURRENTPOS
	SendMessage, 2008, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}
Sci_GetColumn(pos) {
	; Get the current column. SCI_GETCOLUMN = 2129
	SendMessage, 2129, % pos, 0,, ahk_id %hSci%
	return ErrorLevel + 1
}
Sci_GetFirstVisibleLine(line) {																											
    	
	 ;--Get the first visible line
    SendMessage, 2152, 0, 0,, ahk_id %hSci%
    
    If (ErrorLevel < line - 1) {
        
        ;Get the number of lines on screen. SCI_LINESONSCREEN
        SendMessage, 2370, 0, 0,, ahk_id %hSci%
        
        ;Go to the line wanted + lines on screen. SCI_GOTOLINE
        ;SendMessage, 2024, line - 1 + ErrorLevel, 0,, ahk_id %hSci%
    }
    
    SendMessage, 2024, line - 1, 0,, ahk_id %hSci%
}
Sci_GetLineEndPosition(line) {
    SendMessage 2136, % line - 1, 0,, ahk_id %hSci%
    Return ErrorLevel
}
Sci_GetLineState(line) {
	SCI_GETLINESTATE:=2093
    SendMessage % SCI_GetlineState, % line, 0,, ahk_id %hSci%
    Return ErrorLevel 
}
Sci_GetMarker(line) {
	SCI_MARKERGET:=2046
    SendMessage % SCI_MARKERGET, % line, 0,, ahk_id %hSci%
    Return ErrorLevel 
}
Sci_GetSelection() {	
	
	;Get length. SCI_GETSELTEXT
	SendMessage, 2161, 0, 0,, ahk_id %hSci%
	iLength := ErrorLevel + 1
	
	;Check if the line is empty
	if iLength = 1
		return
	
	; Open remote buffer
	RemoteBuf_Open(hBuf, hSci, iLength)
	
	; Fill buffer. SCI_GETSELTEXT
	SendMessage, 2161, 0, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Prep var
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength)
	
	; Done
	RemoteBuf_Close(hBuf)
	return StrGet(&sText, "CP" Sci_GetCP())
}
Sci_GetLine(Line) {
	
	; Retrieve line length. SCI_LINELENGTH
	SendMessage, 2350, % Line - 1, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, iLength + 1)
	
	; Fill buffer with text. SCI_GETLINE
	SendMessage, 2153, % Line - 1, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Read buffer
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength + 1)
	
	; We're done with the remote buffer
	RemoteBuf_Close(hBuf)
	
	; Trim off ending characters & return
	return Trim(StrGet(&sText, "CP" Sci_GetCP()), "`r`n")
}
Sci_GetText() {	
	; Retrieve text length. SCI_GETLENGTH
	SendMessage, 2006, 0, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, iLength + 1)
	
	; Fill buffer with text. SCI_GETTEXT
	SendMessage, 2182, iLength + 1, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Read buffer
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength + 1)
	
	; We're done with the remote buffer
	RemoteBuf_Close(hBuf)
	return sText
	;return StrGet(&sText, "CP" Sci_GetCP(hSci))
}
Sci_LineIsVisible(line) {
	SCI_GETLINEVISIBLE:=2228
    SendMessage % SCI_GetlineVisible, 0, 0,, ahk_id %hSci%
    Return ErrorLevel 
}

;get and set position of caret
Sci_CurrentLine() {
    SendMessage 2166, Sci_GetCurPos(), 0,, ahk_id %hSci%
    Return ErrorLevel + 1
}
Sci_GotoLine(line) {                                                             		;GotoLine moves the caret to column 0 in this line 
    SendMessage % Sci_GotoLine, % line - 1, 0,, ahk_id %hSci%
}
Sci_GotoLineEnd(line) {                                                      		;moves caret to the end of line
	Sci_GotoLine(line)
    SendMessage % Sci_LineEnd, 0, 0,, ahk_id %hSci%
}
Sci_GotoLineDown(line, downLines=1) {									;gotoLine and go one or more lines down, prevents accidental unfolding of code, it returns the current line
	
	/*		DESCRIPTION of Sci_GotoLineAndDown()

			Link:					none
			Author:			Ixiko
			Date:				03.11.2018
			for:					AHK_L V1
			Description:		in case of folded lines a goto to the next line will jump inside the folding.
									This function moves the caret without touching the folding. Folded code for example begins at line 100 and ends at line 173.
									Line 101 to 173 are invisible. With a simulated key {Down} Scite will go from line 100 to line 174.
									
	*/
	
	Sci_GotoLine(line)
	Loop, % downLines
			Sci_LineDown()
	return Sci_CurrentLine()
}
Sci_GotoPos(pos) {
	SendMessage % SCI_GotoPos, % pos, 0,, ahk_id %hSci%
}
Sci_LineDown() {
	SendMessage % SCI_LINEDOWN, 0, 0,, ahk_id %hSci%
}
Sci_LineFromPos(pos) {
 	;from TillaGoto
	Global
    ;SCI_LINEFROMPOSITION
    SendMessage 2166, pos - 1, 0,, ahk_id %hSci%
    Return ErrorLevel + 1
}
Sci_LineUp() {
	SendMessage % SCI_LINEUP, 0, 0,, ahk_id %hSci%
}
Sci_PosFromLine(line) {
    SendMessage, 2167, % line - 1, 0,, ahk_id %hSci%
    Return ErrorLevel
}
Sci_SetCurLine(ByRef uLine) {
	; https://autohotkey.com/board/topic/38186-tillagoto-go-to-functions-labels-hks-in-your-script/page-5
    SendMessage, 2025, uLine >> 16, 0,, ahk_id %hSci% ;SCI_GOTOPOS
    SendMessage, 2152, 0, 0,, ahk_id %hSci% ;SCI_GETFIRSTVISIBLELINE
    SendMessage, 2168, 0, (uLine & 0xFFFF) - ErrorLevel,, ahk_id %hSci% ;SCI_LINESCROLL
}
Sci_SetCurPos(pos) {
	; Set the current position. SCI_GOTOPOS
	SendMessage, 2025, pos, 0,, ahk_id %hSci%
	; Ensure the caret is visible. SCI_SCROLLCARET
	;SendMessage, 2169, 0, 0,, ahk_id %hSci%
}

;folding
Sci_ContractedFoldNext(line) {
    SendMessage, 2618, %line%, 0,, ahk_id %hSci%
	return (ErrorLevel + 1)
}
Sci_GetFoldExpanded(line) {
    SendMessage, 2230, %line%, 0,, ahk_id %hSci%
	return (ErrorLevel & 0x0FFF)
}
Sci_GetFoldLevel(line) {
    SendMessage, 2223, %line%, 0,, ahk_id %hSci%
	return ( (ErrorLevel & 0x0FFF) - 1024)
}
Sci_GetFoldParent(line) {
    SendMessage, 2225, %line%, 0,, ahk_id %hSci%
	foldParent:=(ErrorLevel & 0x0FFF) + 1
	return (foldParent=4096) ? 0 : foldParent 
}
Sci_GetLastChild(line) {
	;? this is working correct? I don't know!
    SendMessage, 2224, %line%, 0,, ahk_id %hSci%
	return ErrorLevel
}
Sci_ShowLine(line) {																											
    
	;from TillaGoto
	Global
	 ;--Get the first visible line
    SendMessage, 2152, 0, 0,, ahk_id %hSci%
    
    If (ErrorLevel < line - 1) {
        
        ;Get the number of lines on screen. SCI_LINESONSCREEN
        SendMessage, 2370, 0, 0,, ahk_id %hSci%
        
        ;Go to the line wanted + lines on screen. SCI_GOTOLINE
        SendMessage, 2024, % line - 1 + ErrorLevel, 0,, ahk_id %hSci%
    }
    
    SendMessage, 2024, % line - 1, 0,, ahk_id %hSci%
}

;add, change, delete text
Sci_ClearLine(line) {																		;empty's the given line, doesn't delete the whole line!
	Sci_GotoLine(line)
	endpos:= Sci_GetLineEndPosition(line)
	Sci_SetAnchor(endpos)
	Sci_DeleteBack(2)
}
Sci_DeleteBack(option:= 1) {                                                   	;deletes back with two options 1= one DeleteBack, 2= DeleteBackNotLine
	If (option=1)
		SendMessage % SCI_DeleteBack, 0, 0,, ahk_id %hSci%
	else if (option=2)
		SendMessage % SCI_DeleteBackNotLine, 0, 0,, ahk_id %hSci%
}
Sci_InsertText(sText, pos := -1) {
	
	; Prepare a local buffer for conversion
	sNewLen := StrPut(sText, "CP" (cp := Sci_GetCP()))
	VarSetCapacity(sTextCnv, sNewLen)
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, sNewLen + 1)
	
	; Convert the text to the destination codepage
	StrPut(sText, &sTextCnv, "CP" cp)
	RemoteBuf_Write(hBuf, sTextCnv, sNewLen + 1)
	
	; Call Scintilla to insert the text. SCI_INSERTTEXT
	SendMessage, 2003, pos, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Move the caret to the end of the insertion
	Sci_SetCurPos(Sci_GetCurPos() + sNewLen)
	
	; Done
	RemoteBuf_Close(hBuf)
}  

;selection
Sci_ClearSelections() {
    SendMessage % SCI_CLEARSELECTIONS, 0, 0,, ahk_id %hSci%
}
Sci_SelectWholeLine(line) {															;set selection to the whole line
	Sci_GotoLine(line)
	endpos:= Sci_GetLineEndPosition(line)
	Sci_SetAnchor(endpos)
}
Sci_SetAnchor(pos) {
    SendMessage % SCI_SetAnchor, % pos, 0,, ahk_id %hSci%
}

;others
Sci_CheckTextClick(x, y) {
	
    Local checkPos, checkline, checklinetext, checki
    
    ;SCI_checkPosITIONFROMPOINTCLOSE
    SendMessage, 2023, x, y,, ahk_id %hSci%
    checkPos := ErrorLevel
    
    ;Check for error
    If (checkPos = -1)
        Return False
    Else {
        
        ;SCI_checklineFROMcheckPosITION
        SendMessage, 2166, checkPos, 0,, ahk_id %hSci%
        checkline := ErrorLevel
        
        ;SCI_checkPosITIONFROMcheckline
        SendMessage, 2167, checkline, 0,, ahk_id %hSci%
        checkPos -= ErrorLevel
        
        ;Get checkline text
        checklinetext := Sci_GetLine(checkline)
        
        ;Trim after the first illegal character
        checki := RegExMatch(checklinetext, "[^a-zA-Z0-9#_@\$\?\[\]]", "", checkPos + 1)
        If checki
            StringLeft, checklinetext, checklinetext, checki - 1
        
        ;Trim before the first illegal character
        ;i := RegExMatch(StringReverse(checklinetext), "[^a-zA-Z0-9#_@\$\?\[\]]", "", StrLen(checklinetext) - checkPos + 1)   ################## Problem hier - keine entsprechende Funktion
        If i
            StringTrimLeft, checklinetext, checklinetext, StrLen(checklinetext) - checki + 1
        
        ;Check if it's a clean match
        checklinetext .= "()"
        Loop %sFuncs0% {
            If (checklinetext = sFuncs%A_Index%) {
                Sci_ShowLine(sFuncs%A_Index%_checkline)
                Return True
            }
        }
        
        StringTrimRight, checklinetext, checklinetext, 2
        checklinetext .= ":"
        Loop %sLabels0% {
            If (checklinetext = sLabels%A_Index%) {
                Sci_ShowLine(sLabels%A_Index%_checkline)
                Return True
            }
        }
    }
    
    Return False
}
Sci_LineHistory(bForward, iRecordMode = 0) {
	; https://autohotkey.com/board/topic/38186-tillagoto-go-to-functions-labels-hks-in-your-script/page-5
    Static
    Static iCurLine := 1, iLines0 := 0
    
    ;Check if we just need to record
    If (iRecordMode = 1)    ;Record current line
        Sci_GetCurLine(iLines%iCurLine%)
    Else If (iRecordMode = 2) { ;Record to the next line
        
        iCurLine += 1
        Sci_GetCurLine(iLines%iCurLine%)
        
        ;Set as the new limit
        iLines0 := iCurLine
        
    } Else If bForward {  ;Forward
        
        ;Check if it is possible
        If (iCurLine = iLines0)
            Return
        
        ;Record the line we're on now
        Sci_GetCurLine(iLines%iCurLine%)
        
        ;Show the next line
        iCurLine += 1
        Sci_SetCurLine(iLines%iCurLine%)
        
    } Else {    ;Backward
        
        ;Check if it is possible
        If (iCurLine = 1)
            Return
        
        ;Record the line we're on now
        Sci_GetCurLine(iLines%iCurLine%)
        
        ;Show the previous line
        iCurLine -=1
        Sci_SetCurLine(iLines%iCurLine%)
    }
}
Sci_Send(hwnd, msg:=0, wParam:=0, lParam:=0) {
	
	;https://github.com/RaptorX/scintilla-wrapper/blob/master/SCI.ahk
	/*
			Function : __sendEditor
			Posts the messages used to modify the control's behaviour.
			*This is an internal function and it is not needed in normal situations. Please use the scintilla object to call all functions.
			They call this function automatically*
			Parameters:
			__sendEditor(hwnd, msg, [wParam, lParam])
			hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
						Scintilla components in the same script. The wrapper will remember the last used hwnd,
						so you can specify it once and only specify it again when you want to operate on a different
						component.
						*Note: This is converted internally by the wrapper from the object calling method. It is recommended that you dont use this function.*
			msg     -   The message to be posted, full list can be found here:
						<http://www.scintilla.org/ScintillaDoc.html>
			wParam  -   wParam for the message
			lParam  -   lParam for the message
			Returns:
			Status code of the DllCall performed.
			Examples:
			(Start Code)
			__sendEditor(hSci1, "SCI_SETMARGINWIDTHN",0,40)  ; Set the margin 0 to 40px on the first component.
			__sendEditor(0, "SCI_SETWRAPMODE",1,0)           ; Set wrap mode to true on the last used component.
			__sendEditor(hSci2, "SCI_SETMARGINWIDTHN",0,50)  ; Set the margin 0 to 50px on the second component.
			(End)
	*/
	
    static

    hwnd := !hwnd ? oldhwnd : hwnd, oldhwnd := hwnd, msg := !(msg+0) ? "SCI_" msg : msg

    if !df_%hwnd%
	{
        SendMessage, % SCI_GETDIRECTFUNCTION ,0,0,,ahk_id %hwnd%
        df_%hwnd% := ErrorLevel
        SendMessage, % SCI_GETDIRECTPOINTER ,0,0,,ahk_id %hwnd%
        dp_%hwnd% := ErrorLevel
	}

    if !msg && !wParam && !lParam   ; called only with the hwnd param from SCI_Add
        return                      ; Exit because we did what we needed to do already.

    ; The fast way to control Scintilla
    return DllCall(df_%hwnd%            ; DIRECT FUNCTION
                  ,"UInt" ,dp_%hwnd%    ; DIRECT POINTER
                  ,"UInt" ,!(msg+0) ? %msg% : msg
                  ,"Int"  ,inStr(wParam, "-") ? wParam : (%wParam%+0 ? %wParam% : wParam) ; handles negative ints
                  ,"Int"  ,%lParam%+0 ? %lParam% : lParam)
}


/* more Scintilla Sendmessages and code

		SendMessage, SCI_GETDIRECTFUNCTION,0,0,,ahk_id %hwnd%
			df_%hwnd% := ErrorLevel
        SendMessage, SCI_GETDIRECTPOINTER,0,0,,ahk_id %hwnd%
			dp_%hwnd% := ErrorLevel
			
		SCI_Send("SCI_SETLEXERLANGUAGE",sc,"Int",0,"AStr","ahk1") ;language = ahk1 (from philho's lexer)

		loop,3
		SCI_Send("SCI_SETKEYWORDS",sc,"Int",A_Index-1,"AStr",keywords(a_index))

		loop,20
		SCI_Send("SCI_g.SETFORE",sc,"Int",A_Index-1,"Int",dcolors(a_index))

		SCI_Send("SCI_SETTEXT",sc,,,"AStr",FileOpen(A_ScriptFullPath,"r").Read())	
*/

