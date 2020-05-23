;-----------------------------
;
; Function: Edit_Sort
;
; Description:
;
;   Sort selected text (one or more lines) using the p_SortOptions options.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_SortOptions - AutoHotkey sort options. [Optional]
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
; * <Edit_SetSel>
;
; Remarks:
;
; * Undo can be used to reverse this action.
;
; * If selecting more than one line, this function may not work correctly if
;   word wrap is enabled unless all selected lines are not wrapped.
;
; * Hint: Don't specify a delimiter if sorting more than one line.
;
;-------------------------------------------------------------------------------
Edit_Sort(hEdit,p_SortOptions="")
    {
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
            l_LastSelectedLine--

    ;-- Determine last character index of affected lines
    l_LastPosOfLastSelectedLine:=Edit_LineIndex(hEdit,l_LastSelectedLine)+Edit_LineLength(hEdit,l_LastSelectedLine)

    ;[=============]
    ;[  Reselect?  ]
    ;[=============]
    ;-- If sorting more than one line, reselect if the user selection does not
    ;   start at the beginning of the line or does not end at the end of the
    ;   line
    if (l_FirstSelectedLine<>l_LastSelectedLine)
        if (l_StartSelPos<>l_FirstPosOfFirstSelectedLine)
        or (l_EndSelPos<>l_LastPosOfLastSelectedLine)
            Edit_SetSel(hEdit
                       ,l_FirstPosOfFirstSelectedLine
                       ,l_LastPosOfLastSelectedLine)

    ;[=====================]
    ;[  Get selected text  ]
    ;[=====================]
    l_SelectedText:=Edit_GetSelText(hEdit)

    ;[========]
    ;[  Sort  ]
    ;[========]
    Sort l_SelectedText,%p_SortOptions%

    ;-- Replace selection with sorted data
    Edit_ReplaceSel(hEdit,l_SelectedText)

    ;[============]
    ;[  Reselect  ]
    ;[============]
    ;-- Calculate reselect positions
    if (l_FirstSelectedLine=l_LastSelectedLine)
        {
        l_NewStartSelPos:=l_StartSelPos
        l_NewEndSelPos:=  l_StartSelPos+StrLen(l_SelectedText)
        }
     else
        {
        l_NewStartSelPos:=l_FirstPosOfFirstSelectedLine
        l_NewEndSelPos  :=l_FirstPosOfFirstSelectedLine+StrLen(l_SelectedText)
        if (l_EndSelPos>l_LastPosOfLastSelectedLine)
            l_NewEndSelPos+=l_EndSelPos-l_LastPosOfLastSelectedLine
        }

    Edit_SetSel(hEdit,l_NewStartSelPos,l_NewEndSelPos)

    ;[==============]
    ;[  Reposition  ]
    ;[==============]
    Edit_LineScroll(hEdit,"Left")
        ;-- Fixes a display problem that sometimes occurs if doing stuff with
        ;   lines that are wider than the control
    }
