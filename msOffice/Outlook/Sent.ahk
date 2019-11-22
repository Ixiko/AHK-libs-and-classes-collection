; This script determines if an email is displayed in "Read" or "Edit" mode. That is to say, if a new email is being
; composed then the user can edit the text within the Inspector window. By contrast, if the user has sent the email or
; if the user is the recipient of the email, then the text within the Inspector window is read-only.

; Constants
olInspector := 35
msoFalse := 0
msoTrue := -1

olApp := ComObjActive("Outlook.Application")  ; Get a reference to the application object. Outlook must be running.
Window := olApp.ActiveWindow  ; Get a reference to the active window.
if (Window.Class = olInspector)  ; If the active window is an Inspector (ie: the email is open in its own window)...
{
    IsSent := Window.CurrentItem.Sent  ; Returns a Boolean value that indicates if a message has been sent.
    if (IsSent = msoFalse)  ; .Sent = False
        s := "Edit mode."
    else if (IsSent = msoTrue)  ; .Sent = True
        s := "Read mode."
    else  ; It should not be possible to reach this; the expected 'IsSent' values are only 0 or -1.
        s := ""
}
else
    s := "Not detected."
MsgBox, 64, Inspector State, % s
return

; References
;   https://autohotkey.com/boards/viewtopic.php?f=5&t=16266
