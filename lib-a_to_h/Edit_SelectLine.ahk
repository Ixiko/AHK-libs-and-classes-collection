;-----------------------------
;
; Function: Edit_SelectLine
;
; Description:
;
;   Selects the specified zero-based line.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_LineIdx - The zero-based index of the line to select. [Optional]  Use
;        -1 (the default) to select the current line.
;
;   p_IncludeEOL - Include end-of-line (EOL) characters. [Optional]  If set to
;       TRUE, the EOL characters (CR+LF) after the line are also selected if
;       they exist.
;
; Returns:
;
;   TRUE if the requested line is selected, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetLineCount>
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
; * <Edit_SetSel>
;
; Remarks:
;
;   This function may not work as expected if word wrap is used or if selecting
;   a very long (>1024) line.
;
;-------------------------------------------------------------------------------
Edit_SelectLine(hEdit,p_LineIdx=-1,p_IncludeEOL=False)
    {
    if (p_LineIdx<0)
        p_LineIdx:=Edit_LineFromChar(hEdit,Edit_LineIndex(hEdit))

    l_MaxLine:=Edit_GetLineCount(hEdit)-1
    if (p_LineIdx>l_MaxLine)
        Return False

    l_StartSelPos:=Edit_LineIndex(hEdit,p_LineIdx)
    l_EndSelPos  :=l_StartSelPos+Edit_LineLength(hEdit,p_LineIdx)
    if p_IncludeEOL
        if (p_LineIdx<l_MaxLine)
            l_EndSelPos+=2

    Edit_SetSel(hEdit,l_StartSelPos,l_EndSelPos)
    Return True
    }
