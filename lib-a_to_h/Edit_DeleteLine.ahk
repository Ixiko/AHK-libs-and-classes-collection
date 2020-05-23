;-----------------------------
;
; Function: Edit_DeleteLine
;
; Description:
;
;   Deletes the specified zero-based line.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_LineIdx - The zero-based index of the line to delete. [Optional]  Use
;        -1 (the default) to delete the current line.
;
; Returns:
;
;   TRUE if the requested line is deleted, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_Clear>
; * <Edit_SelectLine> (Add-On)
;
; Remarks:
;
; - Undo can be used to reverse this action.
;
;-------------------------------------------------------------------------------
Edit_DeleteLine(hEdit,p_LineIdx=-1)
    {
    if Edit_SelectLine(hEdit,p_LineIdx,True)
        {
        Edit_Clear(hEdit)
        Return True
        }

    Return False
    }
