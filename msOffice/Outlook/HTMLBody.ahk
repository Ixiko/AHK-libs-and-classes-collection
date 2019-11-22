; This script creates an email, adds "test.png" as an attachment, then includes the image in the body of the email.

Image := A_ScriptDir "\test.png"  ; The path of the image to include.
SplitPath, Image, ImageName  ; Get the file name from the path.

; Constants
olMailItem := 0
olByValue := 1

olApp := ComObjCreate("Outlook.Application")  ; Create an application object.
olMail := olApp.CreateItem(olMailItem)  ; Create a new email.
olMail.To := "abc@example.com"
olMail.CC := "xyz@example.com"
olMail.Subject := "foo"
olMail.Body := "abc123`n`n"
olMail.Attachments.Add(Image, olByValue, 0)  ; Add an attachment.
olMail.HTMLBody := olMail.HTMLBody "<br><B>Embedded Image:</B><br>"  ; Include the image in the body of the email.
                . "<img src='cid:" ImageName "' width='500' height='400'><br>"
                . "<br>Best regards, <br>Someone</font></span>"
olMail.Display
;~ olMail.Send

; References:
;   - https://autohotkey.com/boards/viewtopic.php?f=5&t=28166 -- This thread shows more examples of HtmlBody, and also has links
;       to the WinClip() method.
;   - https://www.mrexcel.com/forum/excel-questions/708544-visual-basic-applications-copy-excel-into-outlook.html#post3496819 --
;       This post shows a VBA example that uses the Word editor; Word is usually the editor that is used internally by Outlook to 
;       compose emails. HtmlBody is also used in another post in this thread.
;   - https://autohotkey.com/boards/viewtopic.php?p=119403#p119403 -- This post also uses the Word editor. It pastes a chart from
;       Excel into the email; the same process can be used for images.
