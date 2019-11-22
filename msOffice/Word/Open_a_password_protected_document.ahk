; This script opens a Word document and prompts the user for a password if it is password protected.

; Try to open the Word document using this password. If the document is password protected this password should fail and
; the user will be prompted to enter a password. If the document is not password protected Word will ignore this
; password and open the file normally.
Pass := "?#nonsense@$"

wdApp := ComObjCreate("Word.Application")
wdApp.Visible := true
InputFile := A_ScriptDir "\New Microsoft Word Document.docx"  ; Path to a password protected document.
Loop  ; Try to open the document. Repeat until successful or the user cancels.
{
    try  ; Protect against errors in this block.
    {
        oDoc := wdApp.Documents.Open(InputFile,, False,, Pass)  ; Open the document using the password.
        break  ; If the document was opened without an error break the loop.
    }
    catch, e  ; Error opening the document.
    {
        RegExMatch(e.Message, "^0x[A-F0-9]+", ErrorCode)    ; Find the hex error code number.
        if (ErrorCode & 0x1520 = 0x1520)                    ; If the error is "Incorrect password."
        {
            ; Prompt the user for the password.
            InputBox, OutputVar, Enter Password, The following document requires a password.`n%InputFile%
            if (OutputVar != "")        ; If OutputVar is not blank...
                Pass := OutputVar       ; Try OutputVar as the password next.
            else if (ErrorLevel = 1)    ; Else if the user pressed Cancel...
                return
        }
        else  ; If the error was not "Incorrect Password" throw the error again so it is not blocked.
            throw e
    }
}
return

; References:
; https://autohotkey.com/boards/viewtopic.php?p=117277#p117277
; Skipping Password-Protected Documents in a Batch Process
;   - http://word.mvps.org/faqs/macrosvba/CheckIfPWProtectB4Open.htm
