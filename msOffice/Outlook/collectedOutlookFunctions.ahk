; functions to use with outlook - more examples than real useable functions


OutlookConnect() {
    try olApp := ComObjActive("Outlook.Application")
    catch
        throw Exception("Unable to connect to Outlook.")
    return olApp
}

OutlookSendMail(to, cc, subject, text, ImageAttachment) {

	; References:
	;   - https://autohotkey.com/boards/viewtopic.php?f=5&t=28166 -- This thread shows more examples of HtmlBody, and also has links
	;       to the WinClip() method.
	;   - https://www.mrexcel.com/forum/excel-questions/708544-visual-basic-applications-copy-excel-into-outlook.html#post3496819 --
	;       This post shows a VBA example that uses the Word editor; Word is usually the editor that is used internally by Outlook to
	;       compose emails. HtmlBody is also used in another post in this thread.
	;   - https://autohotkey.com/boards/viewtopic.php?p=119403#p119403 -- This post also uses the Word editor. It pastes a chart from
	;       Excel into the email; the same process can be used for images.

	; Constants
	olMailItem := 0
	olByValue := 1

	SplitPath, ImageAttachment, ImageName  ; Get the file name from the path.

	olApp := OutlookConnect()  ; Create an application object.
	olMail             	:= olApp.CreateItem(olMailItem)  ; Create a new email.
	olMail.To      	:= to
	olMail.CC     	:= cc
	olMail.Subject	:= subject
	olMail.Body   	:= text
	olMail.Attachments.Add(ImageAttachement, olByValue, 0)  ; Add an attachment.
	olMail.HTMLBody := olMail.HTMLBody "<br><B>Embedded Image:</B><br>"  ; Include the image in the body of the email.
					. "<img src='cid:" ImageName "' width='500' height='400'><br>"
					. "<br>Best regards, <br>Someone</font></span>"
	olMail.Display
	;~ olMail.Send

}

OutlookRestricted() {

	; This script loops through all unread messages in the inbox and asks the user if they want to reply.

	; Constants
	olFolderInbox := 6

		olApp := OutlookConnect()  ; Create an application object.
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
}

;-------- from https://github.com/mslonik/Autohotkey-scripts/blob/d2114a65c2615b5e48cd86cbf175152f78405444/MicrosoftOutlook/Outlook.ahk
AddAttachments() {


	global oOutlook, ClipSaved, ClipVar
	ClipSaved := Clipboard
	Clipboard := ""
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments
		FileSelectFile, files, M3  ; M3 = Multiselect existing files.
		Loop, parse, files, `n
		{
			if (A_Index = 1)
			{
				path := A_LoopField
			}
			else if (A_Index = 2)
			{
				fullpath = %path%\%A_LoopField%
				myAttachments.Add(fullpath)
				ClipVar := % fullpath
				Clipboard := ClipVar
			}
			else
			{
				fullpath = %path%\%A_LoopField%
				myAttachments.Add(fullpath)
				ClipVar := % Clipboard . "<br>" . fullpath
				Clipboard := ClipVar
			}
		}
		ClipVar := Clipboard
		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

SaveAttachments(path) {

	global oOutlook, ClipSaved, ClipVar

	ClipSaved    	:= Clipboard
	ClipVar         	:= ""
	Clipboard     	:= "Deleted attachments: `"
	oOutlook     	:= ComObjActive("Outlook.Application")
	myInspector 	:= oOutlook.Application.ActiveInspector
	VarType         	:= ComObjType(myInspector, "Name")

	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments

		MsgBox, 4, ,Do you want to save and delete attachments?
		IfMsgBox No
			return

		cnt := myAttachments.Count
		if (cnt < 1)
		{
			MsgBox, There are no attachments in the message.
			return
		}
		i := cnt

		while (i > 0)
		{
			AttachmentName := myAttachments.Item(i).FileName

			if !FileExist(path)
				FileCreateDir, % path

			path = %path%%AttachmentName%
				myAttachments.Item(i).SaveAsFile(path)
			i := i-1
		}
		k := 1
		while (k <= cnt)
		{
			AttachmentName := myAttachments.Item(k).FileName
			ClipVar = % Clipboard . " `" . AttachmentName
			Clipboard := ClipVar
			if (k != cnt)
			{
				ClipVar = %Clipboard%,
				Clipboard := ClipVar
			}
			k := k+1
		}
		ClipVar = % Clipboard . "<br>" . "Attachments saved in location C:\temp1\Załączniki." . "<br>"
		Clipboard := ClipVar

		ClipVar := Clipboard
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")

		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText

		j := cnt
		while(j > 0)
		{
			myAttachments.Remove(j)
			j := j-1
		}
		myItem.Save
		myItem.Close(0)
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

DeleteAttachments() {

	global oOutlook, ClipSaved, ClipVar
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")
	ClipSaved := Clipboard
	Clipboard := ""
	ClipVar := ""
	if (VarType = "_Inspector")
	{
		myItem := myInspector.CurrentItem
		myAttachments := myItem.Attachments
		i := 1

		MsgBox, 4, ,Czy chcesz usunąć załączniki?
		IfMsgBox No
			return

		cnt := myAttachments.Count

		if (cnt < 1)
		{
			MsgBox, Brak załączników w wiadomości.
			return
		}

		Clipboard := "Deleted attachments: `"

		while (i <= cnt)
		{
			AttachmentName := myAttachments.Item(i).FileName
			ClipVar = % Clipboard . " `" . AttachmentName
			Clipboard := ClipVar
			if (i != cnt)
			{
				ClipVar = %Clipboard%,
				Clipboard := ClipVar
			}
			i := i+1
		}

		ClipVar := Clipboard
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")

		HText := myItem.HTMLBody
		AText = <HTML><BODY><font face="calibri" size="2" color="red">%ClipVar%</font></BODY></HTML>
		HText = %AText%%HText%
		myItem.HTMLBody := HText

		j := cnt
		while(j > 0)
		{
			myAttachments.Remove(j)
			j := j-1
		}
		myItem.Save
		myItem.Close(0)
	}
	oOutlook := ""
	Clipboard := ClipSaved
}

ShowHide() {

	global oOutlook
	oOutlook := ComObjActive("Outlook.Application")
	myInspector := oOutlook.Application.ActiveInspector
	VarType := ComObjType(myInspector, "Name")

	if (VarType = "_Inspector")
	{
		try
			myInspector.CommandBars.ExecuteMso("EditMessage")
		oDoc := myInspector.WordEditor
		ShowAll := oDoc.Windows(1).View.ShowAll
		if (ShowAll = 0)
			oDoc.Windows(1).View.ShowAll := -1
		else
			oDoc.Windows(1).View.ShowAll := 0
	}
	oOutlook := ""
}

;https://github.com/CfKu/autohotkey/blob/2d045c15f4f9c798876da768a6b668e0631ff4c3/apps/ms_outlook.ahk
AppointmentsBack() {

        olMail := 43
        olAppointment := 26
        olSelection := 74
        olMeetingRequest := 53
        olFree := 0
        olMeetingDeclined := 4
        olMeetingTentative := 2
        olMeetingResponseNegative := 55
        olMeetingResponsePositive := 56
        olMeetingResponseTentative := 57

	; evtl.1 send decline (prevent from deleting), 2. change free, no reminder, 3. delete manually
        try {
            ; get current selected olMeetingRequest
			selection := ComObjActive("Outlook.Application").ActiveExplorer.Selection
            if selection.Count == 1 {
                selected_item := selection.Item(1)
                appointment_item := ""
                ; proceed if olMeetingRequest
                if selected_item.Class == olMeetingRequest {
                    appointment_item := selected_item.GetAssociatedAppointment(True)
                ; proceed if selected appointment in calendar
                } else if (selected_item.Class == olAppointment) {
                    appointment_item := selected_item
                }

                if (appointment_item != "") {
                    appointment_item.Subject := "CfK-DECLINED: " appointment_item.Subject
                    appointment_item.BusyStatus := olFree
                    appointment_item.ReminderSet := False
                    appointment_item.Save()
                }
            }
        }

return
}

AddTravelTimeToAppointment() {

        olAppointmentItem := 1
        olAppointment := 26

        ; try {
            app := ComObjActive("Outlook.Application")
            ; get current selected olMeetingRequest
			selection := app.ActiveExplorer.Selection
            if selection.Count == 1 {
                selected_item := selection.Item(1)
                ; proceed if olAppointment
                if selected_item.Class == olAppointment {
                    InputBox, travel_time, Travel time in minutes, Please enter the travel time in minutes., , 200, 150
                    ; if entered something, continue
                    if (!ErrorLevel) {
                        ; cast string to integer
                        travel_time := travel_time + 0
                        ; WORKAROUND (split datetime string), in ahk_v2 DateParse() or DateAdd()
                        ;                  1234567890123456789
                        ; DateTime Format: dd.MM.yyyy hh:mm:ss
                        selected_start_date := selected_item.Start
                        start_dd := SubStr(selected_start_date, 1, 2)
                        start_Mon := SubStr(selected_start_date, 4, 2)
                        start_yyyy := SubStr(selected_start_date, 7, 4)
                        start_hh := SubStr(selected_start_date, 12, 2)
                        start_min := SubStr(selected_start_date, 15, 2)
                        start_ss := SubStr(selected_start_date, 18, 2)
                        before_start_date_ahk := start_yyyy . start_Mon . start_dd . start_hh . start_min . start_ss
                        before_start_date_ahk += -1 * travel_time, minutes
                        FormatTime, before_start_date, %before_start_date_ahk%, dd.MM.yyyy hh:mm:ss

                        ; BEFORE
                        item_before := app.CreateItem(olAppointmentItem)
                        item_before.Start := before_start_date
                        item_before.Duration := travel_time
                        item_before.Subject := "TRAVEL TIME | " selected_item.Subject
                        item_before.BusyStatus := selected_item.BusyStatus
                        item_before.Categories := selected_item.Categories
                        item_before.Sensitivity := selected_item.Sensitivity
                        item_before.ReminderSet := True
                        item_before.ReminderMinutesBeforeStart := 0
                        item_before.Save()

                        ; AFTER
                        item_after := app.CreateItem(olAppointmentItem)
                        item_after.Start := selected_item.End
                        item_after.Duration := travel_time
                        item_after.Subject := "TRAVEL TIME | " selected_item.Subject
                        item_after.BusyStatus := selected_item.BusyStatus
                        item_after.Categories := selected_item.Categories
                        item_after.Sensitivity := selected_item.Sensitivity
                        item_after.ReminderSet := True
                        item_after.ReminderMinutesBeforeStart := 0
                        item_after.Save()
                    }
                }
            }
        ; }

    return
}
;--------

objOL := ComObjActive("Outlook.Application").ActiveInspector.CurrentItem
Sub := objOL.Subject

; https://github.com/omsai/andorian-hotkeys/blob/978bbc875816913b26db11057f7d693f02ca07f1/lib/common.ahk
get_contact_name_from_outlook_subject() {
  _MailItems := ComObjActive("Outlook.Application").ActiveExplorer.Selection
  _MailItem := _MailItems.Item(1)
  _contact_name := _MailItem.SenderName
  if (_contact_name = "")
  {
    global NONE_VALUE
    return NONE_VALUE ; No match found
  }
  else
    return _contact_name
}

get_contact_email_from_outlook_subject() {

	  _MailItems := ComObjActive("Outlook.Application").ActiveExplorer.Selection
	  _MailItem := _MailItems.Item(1)
	  _contact_type := _MailItem.SenderEmailType
	  _contact_email := _MailItem.SenderEmailAddress
	  if (_contact_type = "EX")
	  {
		_Recipient := _MailItem.Application.Session.CreateRecipient(_MailItem.SenderEmailAddress)
		_contact_alias := _Recipient.AddressEntry.GetExchangeUser().Alias
		_contact_email = %_contact_alias%@andor.com
	  }
	  else {
		if (_contact_email = "")
		{
		  global NONE_VALUE
		  _contact_email := NONE_VALUE ; No match found
		}
	  }
  return _contact_email
}

; from https://github.com/AshetynW/AHK_Outlook_Inbox_Parser/blob/c328441167f0482f0e386c25f164c2c881643422/outlookEmailParse.ahk
display_unread() {

    oOutlook := ComObjActive("Outlook.Application")	; Initial com

    ; Open the inbox folder
		oNameSpace := oOutlook.GetNamespace("MAPI")	; This just has to be here
   ; folder := oNameSpace.GetDefaultFolder(olFolderInbox := 6)
		folder := oNameSpace.GetDefaultFolder(6)		;.folders("CHANGEME")	; As it sits, this line will search through all unread inbox emails for Outlook. You can uncomment and change the folder name to search through specific folders if an account has a "rule" set up.

    ; Loop through items in the inbox folder
    ; oldest first
    For item In folder.Items
        If (item.Class = (olMail := 43 )) And (item.UnRead)
	    {
		    item.Display()	; Open the first unread
				SetTitleMatchMode, 2
		Loop
		{
			ifwinexist, Message (HTML)	; Wait until the message is open to continue
				break
		}

		Winwait, Message (HTML)

	; below are the outlook object's elements such as the sender's name and the subject lines.
		objOL 				:= ComObjActive("Outlook.Application").ActiveInspector.CurrentItem
		From 				:= objOL.SenderName
		To   				 	:= objOL.To						; From
		CC   				 	:= objOL.CC						; CC'd on it
		BCC  				:= objOL.BCC					; Blind CC'd on it
		Subject 			:= objOL.Subject				; Subject
		Body 				:= objOL.Body					;The actual message
		CreationTime 	:= objOL.CreationTime	; Useful for date-specific stuff
		Msgbox %FROM% %to% %CC% %BCC% %CreationTime% %Subject% %Body%

}
}

; https://github.com/MrSimonC/Everyday-Helper/blob/5bddbc1a11bb7bd874c1e95be8c70d92dafb4f05/general%20functions.ahk
Email(Send, To, Subject, BodyClearText, BodyHTML="", BodyFormat=2, From="", CC="", Bcc="", ReplyRecipients="", FlagText="", ReminderTFalse=False, ReminderDateTime="", Importance=1, ReadReceipt=False, DeferredDeliveryDateTime="", AccountToSendFrom="")	{	;Sends an email. Returns: True/False.

	/*
		;use ComObjActive if Outlook is always Open, but check with:
		If !WinExist("ahk_class rctrl_renwnd32")	;if Outlook is closed, Exit
			Return False
	*/
	Item := ComObjCreate(OutlookPIDName).CreateItem(olMailItem:=0)		;olMailItem:=0=="0". Will work even with outlook closed. .14 is Outlook 2010 on Windows 7
	Item.To := To
	Item.Subject := Subject
 	If BodyClearText !=	;default signature is kept if you don't change the .Body property
 		Item.Body := BodyClearText
	If BodyHTML !=
		Item.HTMLBody := BodyHTML
	Item.BodyFormat := BodyFormat	;1=plain text, 2=html, 3=rich text
	Item.SentOnBehalfOfName := 	From		;sets the "From" field. "" is ok as Outlook just uses default account
	Item.CC := CC		;== Recipient1 := sacComObjectReply.Recipients.Add("a@a.com") then Recipient1.Type := 2 ;To=1 Cc=2 Bcc=3
	Item.BCC := Bcc
	Item.FlagRequest := FlagText 	;sets follow up flag *for recipients*! very cool. "" is ok
	Item.ReplyRecipientNames := ReplyRecipients		;sac, depreciated, should use Item.ReplyRecipients.Add("simon crouch")
	If ReminderDateTime !=
		Item.ReminderTime := ReminderDateTime
	Item.ReminderSet := ReminderTFalse
	Item.ReadReceiptRequested := ReadReceipt
	Item.Importance := Importance	;2=high, 1=med, 0=low
	If DeferredDeliveryDateTime !=
		Item.DeferredDeliveryTime := DeferredDeliveryDateTime
	If AccountToSendFrom !=
		Item.SendUsingAccount := Item.Application.Session.Accounts.Item(AccountToSendFrom)	;sac- this took me ages. You can also use a #
	If Send
		Item.Send
	Else
		Item.Display
	Return True
}

;---------

olEmail := ComObjActive("Outlook.Application").ActiveWindow.CurrentItem	; Expects an Email to be open
olEmail.MarkAsTask(2) ; olMarkThisWeek := 2
olEmail.TaskDueDate := DatePlusDays(3)
olEmail.FlagRequest := "Call " olEmail.SenderName
olEmail.ReminderSet := true
olEmail.ReminderTime  := DatePlusDays(2)
olEmail.Save

;----------


olApp := ComObjCreate("Outlook.Application")
olNameSpace := olApp.GetNamespace("MAPI")
olDestFolder := olNameSpace.Folders("BaseFolderName@Email.com").Folders("Deleted Items")

olEmails := olApp.ActiveExplorer.Selection
   	For olEmail in olEmails
		olEmail.Move(olDestFolder)



