ExtractArractmentcoutlook("Inspection Reports","337597","1543387", a_desktop)
return

ExtractAttactmentcoutlook(folderName,EmailSubject,attachmentname,PathToSaveTo)
{
	attachmentname := "i)" attachmentname
	outlook := ComObjActive("Outlook.Application")
	outlooknamespace := outlook.GetNameSpace("MAPI")
	folder := outlooknamespace.Folders(folderName)
	Loop % folder.items.count
	{
		email := folder.items.Item(A_Index)
		if(InStr(email.Subject, EmailSubject))
		{
			attachments := email.Attachments
			Loop % Attachments.Count
			{
				thisattachment := attachments.Item(A_Index)
				if RegExMatch(thisattachment.DisplayName , attachmentname )
				{
					Fullpath := pathtosaveto "\" thisattachment.DisplayName
					thisattachment.SaveAsFile(FullPath)
					return thisattachment.DisplayName ; disable this line and it will extract every attachments and same name attachment get renames, 
				}
			}
		}
	}
	msgbox, no email found Having Subject = %EmailSubject% `n specially having attachment with name = %attachmentname%
}
