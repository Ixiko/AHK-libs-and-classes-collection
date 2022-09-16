

/*
	======================================================================
	
	Create Outlook Email (With Attachments)
	
	by Casper Harkin - 18/07/2022

	======================================================================
*/

	To := "19leo82@gmail.com"
	Subject := "FW: Dank Memes"
	Attachment := "C:\BlankTextFile.txt"
	Body =
	(
	Hello, 
	
	just wanted to check if this is possible - I select one or multiple files from my Directory Opus file explorer and upon a hotkey, 
	those files should get attached to a new Outlook which I have running on my machine.
	
	If anyone already has this working, could you please share the script?
	
	Thank you. 
	)

	CreateOutlookEmail(To, Subject, Body, Attachment)
	
	Exit ; End of AES
	
	CreateOutlookEmail(To, Subject, Body, Attachment) {
		m :=	ComObjActive("Outlook.Application").CreateItem(0)
		m.Subject := Subject
		m.To :=	To
		m.Display
		myInspector :=	m.GetInspector, myInspector.Activate
		wdDoc :=	myInspector.WordEditor
		wdRange :=	wdDoc.Range(0, wdDoc.Characters.Count)
		wdRange.InsertBefore(Body)
		m.Attachments.Add(Attachment)
	}
