SendEmail(p_to, p_From, p_subject, p_message, oAttachments := "", user="macro.trainer@adam.com.au", pass="asvhaf32489hjk")
{ 														; username '@adam.com.au' isn't required to receive emails, but it is to SEND!
	SMTP := "mail.adam.com.au"
	port := 25

	if (!p_From || isValidEmail(p_From)) 		; if user puts a weird name function will fail with an error! hence check if valid
		p_From      := "MT_BugReport@FakeAddress.com" 	; Not a Real Address! """AHKUser"" <...@gmail.com>"
														; note test@fake.com.au fails but test@fake.com works
	getSystemTimerResolutions(MinTimer, MaxTimer)
	p_message 	.= "`n`n`n`n"
				. "================================================================ `n"
				. debugData()

	if (oAttachments && isobject(oAttachments))
	{
		for index, attachmentPath in  oAttachments
			sAttach .= attachmentPath ","
	}
	else if oAttachments
		sAttach := oAttachments
	sAttach := Trim(sAttach, "`t `,")

	email_string := "-f " p_From " -server " SMTP " -port " port " -t " p_to 
		. " -s """ p_subject """ -body """ p_message """ -u " user " -pw " pass
	sAttach ? email_string .= " -attach """ sAttach """"

	; inlcude the DLL inside exe
	If 0
		FileInstall, Included Files\email\blat.dll, Ignore this param

	hBlatt := A_IsCompiled ? ResourceLoadLibrary("blatt.dll") : MemoryLoadLibrary("Included Files\email\blat.dll")
	BlattSend := MemoryGetProcAddress(hBlatt,"Send" (A_IsUnicode?"W":"A"))
	DllCall(BlattSend, "Str", email_string)
	MemoryFreeLibrary(hBlatt)

	;msgbox % i " " errorlevel "`n" email_string	
	return 
}

/*  Com Method 
SendEmail(p_to, p_From, p_subject, p_message, oAttachments := "", user="macro.trainer@adam.com.au", pass="asvhaf32489hjk")
{ 														; username '@adam.com.au' isn't required to receive emails, but it is to SEND!
		
		; gmail
		; user="Macro.Trainer@gmail.com", pass="PublicPasswordfwnk322rf28932hjf32809"

	pmsg          := ComObjCreate("CDO.Message") 
	if (p_From && isValidEmail(p_From)) 		; if user puts a weird name function will fail with an error! hence check if valid
		pmsg.From       := p_From 				; i.e. an address which violates email address rules 
	else pmsg.From      := "MT_BugReport@FakeAddress.com" ; Not a Real Address! """AHKUser"" <...@gmail.com>"
	
	pmsg.To       := p_to
	pmsg.BCC       := ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
	pmsg.CC       := "" ; "Somebody@somewhere.com, Other-somebody@somewhere.com"
	pmsg.Subject    := p_subject

	;You can use either Text or HTML body like

	getSystemTimerResolutions(MinTimer, MaxTimer)
	p_message 	.= "`n`n`n`n"
				. "================================================================ `n"
				. debugData()

	pmsg.TextBody := p_message
	;OR
	;pmsg.HtmlBody := "<html><head><title >Hello</title></head><body><h2>Hello</h2><br /><p>Testing!</p></body></html>"


	;sAttach         := "Path_Of_Attachment" ; can add multiple attachments, the delimiter is |


	if (oAttachments && isobject(oAttachments))
	{
		for index, attachmentPath in  oAttachments
			sAttach .= attachmentPath "|"
	}
	else if oAttachments
		sAttach := oAttachments
	sAttach := Trim(sAttach, "`t |")

	fields := Object()
	fields.smtpserver   := 	"securemail.adam.com.au" ;"smtp.gmail.com" ; specify your SMTP server
	fields.smtpserverport  := 465 ; 25
	fields.smtpusessl      := True ; False
	fields.sendusing     := 2   ; cdoSendUsingPort
	fields.smtpauthenticate     := 1   ; cdoBasic
	fields.sendusername := user
	fields.sendpassword := pass
	fields.smtpconnectiontimeout := 60
	schema := "http://schemas.microsoft.com/cdo/configuration/"

	pfld :=   pmsg.Configuration.Fields

	For field,value in fields
		pfld.Item(schema . field) := value
	pfld.Update()

	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
		pmsg.AddAttachment(A_LoopField)
	pmsg.Send()
}
*/