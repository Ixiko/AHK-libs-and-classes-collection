var=
(
Email	First_Name	Last_Name
joejunkemail@yahoo.com	Joe	King

Joe@the-Automator.com	Joseph	GLines
)

;*********Use For loop over Var going line by line*********************
for i, row in Loopobj:=StrSplit(var,"`n") { ;Parse Var on each new line
IfEqual, i,1,continue ;Skip header row
;~  IfLessOrEqual,i,4382,continue
IfEqual, row,,continue ;Skip loop if blank

Menu , tray, tip, % i-1 " of " Loopobj.maxindex()-1 " : email is " StrSplit(row,"`t").1 ;Show progress on icon in system tray
;~  MsgBox % StrSplit(row,"`t").1 a_tab StrSplit(row,"`t").2 a_tab StrSplit(row,"`t").3 ;demonstrate values
MailItem := ComObjActive("Outlook.Application").CreateItem(0) ;Create a new MailItem object
MailItem.SendUsingAccount := MailItem.Application.Session.Accounts.Item["Joe@the-Automator.com"] ;Assign which account to use (can also use NameSpace)
MailItem.BodyFormat := 2 ; Outlook Constants: 1=Text 2=HTML  3=RTF
MailItem.TO :=StrSplit(row,"`t").1 ;"Joe@the-Automator.com" ; Seperate by ; if you want ot have multiple
;~  MailItem.CC :="Joe@working-smarter-not-harder.com"
;~  MailItem.BCC :="Joe@working-smarter-not-harder.com"
MailItem.Subject := "Example subject line"

MailItem.Attachments.Add("B:\the-automator\Webinar\Scripts\Outlook\AHK_Ball.jpg")
MailItem.Importance := 2  ;0=Low 1=normal 2=High
MailItem.DeferredDeliveryTime := "1/6/2012 10:40:00 AM"
MailItem.OriginatorDeliveryReportRequested := 1 ;Request a Delivery Reciept
MailItem.ReadReceiptRequested := 1  ;Request a Read Receipt
Name:=StrSplit(row,"`t").2
LastName:=StrSplit(row,"`t").3


Body=
( join comments
<HTML>
  <p>Hi there %Name% %LastName%,</p> ;this is a comment
  <p>Just saying hello</p>
</HTML>
)
;~  MsgBox % body
MailItem.HTMLBody :=Body
MailItem.Display ;
MsgBox pause
}
;~  mailItem.Close(0) ;Creates draft version in default folder
;~  MailItem.Send() ;Sends the email
Return