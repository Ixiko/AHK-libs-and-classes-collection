; This script creates a new document to hold stuff from the clipboard.

; Usage
;   - Highlight something.
;   - Press Ctrl+Alt+X.
;   - Whatever you have highlghted will be copied to the clipboard and then pasted into the Word document.

; Constants
wdMainTextStory := 1

wdApp := ComObjCreate("Word.Application")   ; Create an instance of Word.
wdApp.Visible := true                       ; Make Word visible.
NotesDoc := wdApp.Documents.Add()           ; Add a new document to Word.
return                                      ; End of auto-execute section.

^!x::                   ; Ctrl+Alt+X hotkey.
    Clipboard := ""     ; Clear the clipboard.
    Send, ^c            ; Copy
    ClipWait, 1         ; Wait for the clipboard to contain any data.
    if (ErrorLevel)     ; If error...
        return
    NotesDoc.StoryRanges(wdMainTextStory).InsertAfter("`n")                 ; Add a linefeed to the end of the document.
    NotesDoc.Range( NotesDoc.StoryRanges(wdMainTextStory).End - 1 ).Paste   ; Paste to the end of the document.
return

; References
;   https://autohotkey.com/boards/viewtopic.php?f=5&t=30676
;   Document.StoryRanges - https://msdn.microsoft.com/en-us/library/office/ff197823.aspx
;   Range.InsertAfter - https://msdn.microsoft.com/en-us/library/office/ff192427.aspx
;   Document.Range - https://msdn.microsoft.com/en-us/library/office/ff821608.aspx
;   Range.End - https://msdn.microsoft.com/en-us/library/office/ff840998.aspx
;   Range.Paste - https://msdn.microsoft.com/en-us/library/office/ff845105.aspx
