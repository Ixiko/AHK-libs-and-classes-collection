ExtractOutlookAttachments(Location,EmailSubject,attachmentname,PathToSaveTo)
{
	attachmentname := "i)" attachmentname
	outlook := ComObjActive("Outlook.Application")
	outlooknamespace := outlook.GetNameSpace("MAPI")
	
	loop, parse, Location, `\
	{
		if( a_index = 1)
			folder := outlooknamespace.Folders(A_LoopField)
		else
			folder := folder.Folders(A_LoopField) 
	}
	
	for email in folder.items
		if(InStr(email.Subject, EmailSubject))
			for thisattachment in email.Attachments 
				if RegExMatch(thisattachment.DisplayName , attachmentname )
				{
					Fullpath := pathtosaveto "\" thisattachment.DisplayName
					thisattachment.SaveAsFile(FullPath)
					return thisattachment.DisplayName ; disable this line and it will extract every attachments and same name attachment get renames, 
				}
	msgbox, no email found Having Subject = %EmailSubject% `n or having attachment with name = %attachmentname%
}
