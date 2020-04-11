class Outlook extends OfficeManager{ 
	
	ExeName := ""
	Outlook := ""
	Mail := ""
	flag := false
	iqp := ""
	folder := ""
	sendimage := ""
	__New(){
		base.__New()
		this.ExeName := this.p.getProperty("outlookexe")
		location = %A_ScriptDir%\..\..\Lib\Properties\images.properties
		i := new Properties(location)
		
		this.sendimage := i.getProperty("OutSendmail")
		this.iqp := new IQP() 
	}
	
	Run(){
		;this.log.Write("run outlook")
		Process, Exist, % this.ExeName
		If(!ErrorLevel)
		{
			FileWrite("|OUTLOOK|  outlook wasn't running '")
			this.Outlook := ComObjCreate("Outlook.Application")
			this.folder := this.Outlook.GetNameSpace("MAPI").GetDefaultFolder(6)
			this.folder.Display
		}
		Else
		{
			FileWrite("|OUTLOOK| outlook was running ")
			this.Outlook := ComObjActive("Outlook.Application")
			If !WinExist("ahk_class rctrl_renwnd32")
			{			
				this.folder := this.Outlook.GetNameSpace("MAPI").GetDefaultFolder(6)
				this.folder.Display
			}
		}
		
		WinWait ahk_class rctrl_renwnd32
		WinActivate, ahk_class rctrl_renwnd32
		WinShow, ahk_class rctrl_renwnd32
		WinMaximize ahk_class rctrl_renwnd32
	}
	
	WriteMail(recepient = "", subject = "" , body = ""){
		FileWrite("|OUTLOOK| begin writting mail => recepient{" . recepient . "} subject{" . subject . "} body{" . body . "}")
		this.Mail := this.Outlook.Application.CreateItem(0)
		this.Mail.display
		this.Mail.Recipients.Add(recepient)
		this.Mail.Subject := subject
		this.Mail.body := body
			
	}
	
	AddAttachment(location = "",filename = ""){
		FileWrite("|OUTLOOK| add attachment {" location . "\" . filename . "}")
		path := location . "\" . filename
		this.Mail.Attachments.Add(path)
	}
	
	SendMail(){
		FileWrite("|OUTLOOK| send mail ")
		SetTitleMatchMode, RegEx
		WinWait Message
		WinActivate, Message
		Sleep 500
		found := false
		while !found {
			found := findSearchImg(A_ScriptDir . "\" . this.sendimage)
		}
		if(found){
			clickSearchImg(A_ScriptDir . "\" . this.sendimage)
		}
		WinWaitClose, Message
	}

	SendMailWithAttachment(){
		FileWrite("|OUTLOOK| send mail with attachments")
		SetTitleMatchMode, RegEx
		WinWait Message
		WinActivate, Message
		Sleep 500
		while !found {
			found := findSearchImg(A_ScriptDir . "\" . this.sendimage)
		}
		if(found){
			clickSearchImg(A_ScriptDir . "\" . this.sendimage)
		}
		iqpoo := new IQP()
		iqpoo.WaitIsReady()
		Send {Enter}
		WinWaitClose, Classification
	}

	WaitForMailBySubject(box = "", subject = "")
	{
		FileWrite("|OUTLOOK| waiting for mail .. ")
		Inbox := this.folder
		while Inbox.items(1).Subject <> subject{
			Sleep 10
			ToolTip wait or mail
		}
		FileWrite("|OUTLOOK| mail found ")
		this.Mail := Inbox.items(1)
		this.Mail.display
	}
	CloseMail(){
		FileWrite("|OUTLOOK| close mail viewer ")
		this.Mail.Close()
	}
	
	Close(){
		FileWrite("|OUTLOOK| close Application ")
		this.Outlook.Application.Quit()
		WinWaitClose ahk_class rctrl_renwnd32
	}
	BrowseMailBySubject(box = "" , subject = "")
	{
		FileWrite("|OUTLOOK| looking for mail by subject {" . subject . "}")
		this.flag := false
		if(box = "Inbox")
			Box := this.Outlook.folders(1)
		for Mail in Box.items {
			if (Mail.subject = subject){
				this.Mail := Mail
				this.flag := true
			}
		}
		if(!flag)
			MsgBox % subject . "not found"
	}
	;TODO verif if file exist 
	SaveAttachement(newname = "", location = ""){
	    FileWrite("|OUTLOOK| saving attachment {" . location . "\" . newname . "}")
		path := location . "\" . newname
		MsgBox % path
		this.Mail.Attachments(1).SaveAsFile(path)
	}
}