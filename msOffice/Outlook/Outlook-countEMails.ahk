#singleinstance force

; all selected-emails in Outlook
Selected_Emails := COMObjActive("Outlook.Application").ActiveExplorer.Selection

; count them
counter := Selected_Emails.count	
crlf:=chr(13) chr(10)

; loop through
loop, %counter%
{
	test1:=Selected_Emails.Item(a_index).creationtime	
	test2:=Selected_Emails.Item(a_index).subject
	output:=output test1 ";" test2 crlf
}

msgbox, %output%
return