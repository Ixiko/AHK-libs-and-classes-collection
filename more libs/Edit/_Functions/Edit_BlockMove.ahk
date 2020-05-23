;-----------------------------
;
; Function: Edit_BlockMove
;
; Description:
;
;   Move selected text (one or more lines) up or down in a multiline edit
;   control.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_Command - Command to perform.  Use "Up" or "Down" to move the current or
;       selected line(s) up/down 1 line.
;
; Returns:
;
;   TRUE if the move was performed, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetLine>
; * <Edit_GetLineCount>
; * <Edit_GetSel>
; * <Edit_GetSelText>
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineScroll>
; * <Edit_ReplaceSel>
; * <Edit_SetSel>
;
; Remarks:
;
; - Undo can be used to reverse this action.
;
; - This function does not work correctly if Word Wrap is enabled unless all
;   affected lines are not wrapped.
;
;-------------------------------------------------------------------------------
Edit_BlockMove(hEdit,p_Command="")
    {
    StringUpper p_Command,p_Command,T  ;-- Just in case StringCaseSense is On

    ;[===============]
    ;[  Preliminary  ]
    ;[===============]
    l_LastLine:=Edit_GetLineCount(hEdit)-1

    ;-- Get user's select positions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Get line indexes of the beginning and end of the selection
    l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
    l_LastSelectedLine :=Edit_LineFromChar(hEdit,l_EndSelPos)

    ;-- Get first character index of the first selected line
    l_FirstPosOfFirstSelectedLine:=Edit_LineIndex(hEdit,l_FirstSelectedLine)

    ;-- Decrement l_LastSelectedLine if selection ends with EOL
    if (l_FirstSelectedLine<>l_LastSelectedLine) ;-- On more than one line
        if (l_EndSelPos=Edit_LineIndex(hEdit,l_LastSelectedLine))
            l_LastSelectedLine--

    ;-- Determine last character index of affected lines
    l_FirstPosOfLastSelectedLine:=Edit_LineIndex(hEdit,l_LastSelectedLine)
    l_LastSelectedLineLen       :=Edit_LineLength(hEdit,l_LastSelectedLine)
    l_LastPosOfLastSelectedLine :=l_FirstPosOfLastSelectedLine+l_LastSelectedLineLen

    ;-- If move is not possible, stop here
    if p_Command in U,Up
        {
        ;-- Already at the top?
        if (l_FirstSelectedLine=0)
            {
            SoundPlay *-1  ;-- System default sound
            Return False
            }
        }
     else
        ;-- Already at the bottom?
        if (l_LastSelectedLine=l_LastLine)
            {
            SoundPlay *-1  ;-- System default sound
            Return False
            }

    ;[============]
    ;[  Reselect  ]
    ;[============]
    ;-- Reselect if the user selection does not start at the beginning of the
    ;   line or does not end at the end of the line
    if (l_StartSelPos<>l_FirstPosOfFirstSelectedLine)
    or (l_EndSelPos<>l_LastPosOfLastSelectedLine)
        Edit_SetSel(hEdit
                 ,l_FirstPosOfFirstSelectedLine
                 ,l_LastPosOfLastSelectedLine)

    ;-- Get selected text
    l_SelectedText:=Edit_GetSelText(hEdit)

    ;[===========]
    ;[  Process  ]
    ;[===========]
    if p_Command in U,Up
        {
        ;[===========]
        ;[  Move Up  ]
        ;[===========]
        ;-- Get the line just before the selected text
        l_FirstPosOfTargetLine:=Edit_LineIndex(hEdit,l_FirstSelectedLine-1)
        l_TargetText          :=Edit_GetLine(hEdit,l_FirstSelectedLine-1)

        ;-- Determine the length of the target line's EOL char(s)
        l_LenOfTargetLineEOL:=l_FirstPosOfFirstSelectedLine
                           - (l_FirstPosOfTargetLine+StrLen(l_TargetText))

        ;-- Reselect to include the target line
        Edit_SetSel(hEdit
                 ,l_FirstPosOfTargetLine
                 ,l_LastPosOfLastSelectedLine)

        ;-- Replace selected text with new pattern
        Edit_ReplaceSel(hEdit,l_SelectedText . "`r`n" . l_TargetText)

        ;-- Reselect to the user's original positions
        l_NewStartSelPos:=l_StartSelPos-(StrLen(l_TargetText)+l_LenOfTargetLineEOL)
        l_NewEndSelPos  :=l_EndSelPos  -(StrLen(l_TargetText)+l_LenOfTargetLineEOL)

        if (l_EndSelPos>l_LastPosOfLastSelectedLine)
            l_NewEndSelPos:=l_NewEndSelPos
                      - ((l_EndSelPos-l_LastPosOfLastSelectedLine)-2)

        Edit_SetSel(hEdit,l_NewStartSelPos,l_NewEndSelPos)
        }
     else
        {
        ;[=============]
        ;[  Move Down  ]
        ;[=============]
        ;-- Get the line just after the selected text
        l_FirstPosOfTargetLine:=Edit_LineIndex(hEdit,l_LastSelectedLine+1)
        l_TargetText          :=Edit_GetLine(hEdit,l_LastSelectedLine+1)

        ;-- Determine the length of the last selected line's EOL char(s)
        l_LenOfLastSelectedLineEOL:=l_FirstPosOfTargetLine
                                  - l_FirstPosOfLastSelectedLine
                                  - l_LastSelectedLineLen

        ;-- Get the length of EOL char(s) after target line (if any)
        if (l_LastSelectedLine+2>l_LastLine)
            l_LenOfTargetLineEOL:=0
         else
            l_LenOfTargetLineEOL:=Edit_LineIndex(hEdit,l_LastSelectedLine+2)
                                - l_FirstPosOfTargetLine
                                - StrLen(l_TargetText)

        ;-- Reselect to include the target line
        Edit_SetSel(hEdit
                 ,l_FirstPosOfFirstSelectedLine
                 ,l_FirstPosOfTargetLine+StrLen(l_TargetText))

        ;-- Replace selected text with new pattern
        Edit_ReplaceSel(hEdit,l_TargetText . "`r`n" . l_SelectedText)

        ;-- Reselect to the user's original positions or to the end of the
        ;   control
        l_NewStartSelPos:=l_StartSelPos+StrLen(l_TargetText)+2
        l_NewEndSelPos  :=l_EndSelPos  +StrLen(l_TargetText)+2

        if (l_EndSelPos>l_LastPosOfLastSelectedLine)
            l_NewEndSelPos:=l_NewEndSelPos
                          - l_LenOfLastSelectedLineEOL
                          + l_LenOfTargetLineEOL

        Edit_SetSel(hEdit,l_NewStartSelPos,l_NewEndSelPos)
        }

    ;[==============]
    ;[  Reposition  ]
    ;[==============]
    Edit_LineScroll(hEdit,"Left")
        ;-- Fixes a display problem that sometimes occurs if moving lines that
        ;   are wider than the control

    ;-- Return to sender
    Return True
    }
