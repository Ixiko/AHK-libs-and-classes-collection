; This script loops through all undread messages in the inbox and asks the user if they want to reply.

; Constants
olFolderInbox := 6

olApp := ComObjCreate("Outlook.Application")  ; Gets or creates an instance of Outlook.
for ThisItem, in olApp.Session.GetDefaultFolder(olFolderInbox).Items.Restrict("[Unread] = true")
{
    MsgBox, 4,, % "Do you want to reply?`n`nSubject: " ThisItem.Subject "`nSent on: " ThisItem.SentOn "`n"
                . "Body:`n" SubStr(ThisItem.Body, 1, 100)  ; Display max. 100 characters from the body.
                . (StrLen(ThisItem.Body) > 100 ? "..." : "")  ; Add "..." if the body is longer than 100 characters.
    IfMsgBox, Yes
    {
        ThisReply := ThisItem.Reply()
        ThisReply.Body := "Hello world!"
        ThisReply.Display()
    }
}
return
