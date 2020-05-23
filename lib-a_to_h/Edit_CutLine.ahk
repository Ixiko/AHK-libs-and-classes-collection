;-----------------------------
;
; Function: Edit_CutLine
;
; Description:
;
;   Cuts (delete and copy the deleted text to the clipboard) the specified
;   zero-based line.
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
; * <Edit_Cut>
; * <Edit_SelectLine> (Add-On)
;
; Remarks:
;
; - Undo can be used to reverse this action.
;
;-------------------------------------------------------------------------------
Edit_CutLine(hEdit,p_LineIdx=-1)
    {
    if Edit_SelectLine(hEdit,p_LineIdx,True)
        {
        Edit_Cut(hEdit)
        Return True
        }

    Return False
    }
