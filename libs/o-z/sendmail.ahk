;this file is built from an example in the ahk forums and made into a function for including 
;using #include c:\pathtofile\sendmail.ahk

SendMail(SMTPServer, SMTPPort, USESSL, Sender, Receiver, Subject, TextBody, Attachments="", SendUserName="username", SendPassword="password", SendUsing=2, SMTPAuthenticate=1, SMTPTimeout=60, ReplyTo=FALSE)
{
pmsg := ComObjCreate("CDO.Message")
pmsg.From := Sender
pmsg.ReplyTo := Sender
pmsg.To := Receiver
pmsg.BCC := ""
pmsg.CC := ""
pmsg.Subject := Subject
pmsg.TextBody := TextBody
sAttach	 := Attachments

fields := Object()
fields.smtpserver := SMTPServer ; specify your SMTP server
fields.smtpserverport := SMTPPort ; 25
fields.smtpusessl := USESSL ; False
fields.sendusing := SendUsing ; cdoSendUsingPort
fields.smtpauthenticate := SMTPAuthenticate ; cdoBasic
fields.sendusername := SendUserName ; if required
fields.sendpassword := SendPassword ; if required
fields.smtpconnectiontimeout := SMTPTimeout
schema := "http://schemas.microsoft.com/cdo/configuration/"

pfld := pmsg.Configuration.Fields
For field,value in fields
pfld.Item(schema . field) := value
pfld.Update()

;Add attachments
Loop, Parse, sAttach, |, %A_Space%%A_Tab%
pmsg.AddAttachment(A_LoopField)

;send the msg
pmsg.Send()
return
}