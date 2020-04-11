; This script will change bullets to a check marks in the selected row(s) of text.

; Usage:
;   - With PowerPoint active select text that is part of an existing bullet(s).
;   - Press Ctrl+1.
;   - The bullet on the selected line(s) will be changed to a check mark.

#IfWinActive ahk_class PPTFrameClass

^1::  ; Ctrl+1 hotkey
    ; Gets a reference to the active Powerpoint application object.
    pptApp := ComObjActive("Powerpoint.Application")

    ; If text is not selected return.
    if (pptApp.ActiveWindow.Selection.Type != 3) ; ppSelectionText = 3
        return

    ; Get the existing bullet format object from the selected text range.
    MyBulletFormat := pptApp.ActiveWindow.Selection.TextRange.ParagraphFormat.Bullet

    ; Change the bullet type to unnumbered
    MyBulletFormat.Type := 1  ; ppBulletUnnumbered = 1

    ; BulletFormat.Character - Returns or sets the Unicode character value that is used for bullets in the specified text.
    MyBulletFormat.Character := 0x2713  ; Unicode Character 'CHECK MARK' (U+2713)
    
    ; Or use a Wingdings check mark.
    ;~ MyBulletFormat.Character := 252
    ;~
    ;~ ; Set the font.
    ;~ MyBulletFormat.Font.Name := "Wingdings"
return

#If  ; Turn off context sensitive hotkeys.
Esc::ExitApp  ; Press escape to exit this script

; References:
;   https://autohotkey.com/board/topic/149354-ppt-change-bullets-script/#entry732175
;   BulletFormat Object (PowerPoint) - https://msdn.microsoft.com/en-us/library/office/ff745570.aspx
