;-----------------------------
;
; Function: Edit_Duplicate
;
; Description:
;
;   Duplicate selected text.  If nothing is selected, the entire line is
;   duplicated.
;
; Type:
;
;   Add-on function.
;
; Calls To Other Functions:
;
; * <Edit_GetSel>
; * <Edit_GetSelText>
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
; * <Edit_LineScroll>
; * <Edit_ReplaceSel>
; * <Edit_ScrollCaret>
; * <Edit_SetSel>
;
; Remarks:
;
; * Undo can be used to reverse this action.
;
; * If the selection includes end-of-line (EOL) characters, i.e. the selection
;   and the caret are on more than one line, the text will be reselected (if
;   necessary) to include the entire line(s).
;
; * If duplicating lines, this function may not work correctly if word wrap is
;   enabled unless all affected lines are not wrapped.
;
;-------------------------------------------------------------------------------
Edit_Duplicate(hEdit)
    {
    ;-- Initialize
    l_LastSelectedLineIncludesEOL:=False

    ;[===============]
    ;[  Preliminary  ]
    ;[===============]
    ;-- Get user's select positions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)

    ;-- Get line indexes of the beginning and end of the selection
    l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
    l_LastSelectedLine :=Edit_LineFromChar(hEdit,l_EndSelPos)

    ;-- Get first character index of the first selected line
    l_FirstPosOfFirstSelectedLine:=Edit_LineIndex(hEdit,l_FirstSelectedLine)

    ;-- Decrement l_LastSelectedLine if selection ends with EOL
    if (l_FirstSelectedLine<>l_LastSelectedLine)
        if (l_EndSelPos=Edit_LineIndex(hEdit,l_LastSelectedLine))
            {
            l_LastSelectedLine--
            l_LastSelectedLineIncludesEOL:=True
            }

    ;-- Determine last character index of affected lines
    l_LastPosOfLastSelectedLine:=Edit_LineIndex(hEdit,l_LastSelectedLine)+Edit_LineLength(hEdit,l_LastSelectedLine)

    ;[=============]
    ;[  Reselect?  ]
    ;[=============]
    ;-- Nothing originally selected?
    if (l_StartSelPos=l_EndSelPos)
        {
        ;-- Select entire line
        Edit_SetSel(hEdit
                   ,l_FirstPosOfFirstSelectedLine
                   ,l_LastPosOfLastSelectedLine)

        l_LastSelectedLineIncludesEOL:=True
        }
     else
        ;-- If duplicating more than one line or if the only line selected
        ;   includes EOL characters, reselect if the user selection does not
        ;   start at the beginning of the line or does not end at the end of the
        ;   line
        if (l_FirstSelectedLine<>l_LastSelectedLine)
        or l_LastSelectedLineIncludesEOL
            if (l_StartSelPos<>l_FirstPosOfFirstSelectedLine)
            or (l_EndSelPos<>l_LastPosOfLastSelectedLine)
                Edit_SetSel(hEdit
                           ,l_FirstPosOfFirstSelectedLine
                           ,l_LastPosOfLastSelectedLine)

    ;-- Get selected text
    l_SelectedText:=Edit_GetSelText(hEdit)

    ;[=============]
    ;[  Duplicate  ]
    ;[=============]
    if (l_FirstSelectedLine<>l_LastSelectedLine)
    or l_LastSelectedLineIncludesEOL
        l_NewText:=l_SelectedText . "`r`n" . l_SelectedText
     else
        l_NewText:=l_SelectedText . l_SelectedText

    ;-- Replace selected text with new text
    Edit_ReplaceSel(hEdit,l_NewText)

    ;[============]
    ;[  Reselect  ]
    ;[============]
    ;-- Calculate reselect positions
     if (l_StartSelPos=l_EndSelPos)
        {
        l_NewStartSelPos:=l_StartSelPos
        l_NewEndSelPos:=  l_EndSelPos
        }
      else
         if (l_FirstSelectedLine=l_LastSelectedLine)
        and not l_LastSelectedLineIncludesEOL
            {
            l_NewStartSelPos:=l_StartSelPos
            l_NewEndSelPos:=  l_StartSelPos+StrLen(l_SelectedText)
            }
         else
            {
            l_NewStartSelPos:=l_FirstPosOfFirstSelectedLine
            l_NewEndSelPos  :=l_FirstPosOfFirstSelectedLine+StrLen(l_SelectedText)
            if (l_EndSelPos>l_LastPosOfLastSelectedLine)
                l_NewEndSelPos += l_EndSelPos-l_LastPosOfLastSelectedLine
            }

    Edit_SetSel(hEdit
             ,l_NewStartSelPos
             ,l_NewEndSelPos)

    ;[==============]
    ;[  Reposition  ]
    ;[==============]
    Edit_ScrollCaret(hEdit)
        ;-- This keeps the original selection in view

    Edit_LineScroll(hEdit,"Left")
        ;-- Fixes a display problem that sometimes occurs if adding lines that
        ;   are wider than the control
    }
