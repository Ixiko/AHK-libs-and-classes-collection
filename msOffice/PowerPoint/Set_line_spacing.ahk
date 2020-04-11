; This script changes the line spacing of selected text.

#IfWinActive ahk_class PPTFrameClass

^1::
    ; Gets a reference to the active Powerpoint application object.
    pptApp := ComObjActive("Powerpoint.Application")

    ; If text is not selected return.
    if (pptApp.ActiveWindow.Selection.Type != 3) ; ppSelectionText = 3
    {
        MsgBox, 0x10, Error, No textbox text detected!
        pptApp := ""
        return
    }
    
    ; Get a ParagraphFormat object for the selected text.
    oPrgphFrmt := pptApp.ActiveWindow.Selection.TextRange.ParagraphFormat
    
    ; LineRuleWithin determines whether line spacing between base lines is set to a specific number of points or lines.
    ; msoFalse (0) - Line spacing is set to a specific number of points.
    ; msoTrue (-1) - Line spacing is set to a specific number of lines.
    oPrgphFrmt.LineRuleWithin := -1 ; Set spacing units to lines (not points)
    
    oPrgphFrmt.SpaceWithin := 0.5  ; Set spacing of selected text to 0.5 lines.
    
    ; Clear variables containing COM objects.
    pptApp := "", oPrgphFrmt := ""
return

#If
Esc::ExitApp  ; Press Escape to exit this script.
