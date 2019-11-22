; This script resolves an exchange user's display name to a SMTP address.
; An email is open in an Inspector window for this example.

olApp := ComObjActive("Outlook.Application")  ; Outlook must be running.

; 'ActiveInspector' gets a reference to the active inspector window, if one exists. 'Inspector' means that the email is
; open in its own window (not the main Outlook window).
ActiveMailItem := olApp.ActiveInspector.CurrentItem

SenderName := ActiveMailItem.SenderName  ; Get the sender name.
MsgBox 64, Sender Name, % SenderName  ; Display sender name.

EmailAddress := ActiveMailItem.SenderEmailAddress  ; Get the sender email address.
MsgBox 64, Sender Email Address, % EmailAddress  ; Display sender email address.

; If the sender is an exchange user, you may notice that the previous MsgBox did not display the actual email address.
; If the sender name does not match the sender email address, this attempts to resolve the name to an address.
if (SenderName != EmailAddress)
    EmailAddress := ResolveDisplayNameToSMTP(ActiveMailItem)
MsgBox 64, Sender Email Address (2), % EmailAddress
return

; If the sender is an exchange user, this resolves an exchange user's display name to an SMTP address.
ResolveDisplayNameToSMTP(MailItem) {
    Recip := MailItem.Application.Session.CreateRecipient(MailItem.SenderName)
    Recip.Resolve
    if (Recip.Resolved) {
        UserType := Recip.AddressEntry.AddressEntryUserType
        if (UserType = 0 || UserType = 10)  ; olExchangeUserAddressEntry or olOutlookContactAddressEntry
            if (Recip.AddressEntry.GetExchangeUser != "")
                return Recip.AddressEntry.GetExchangeUser.PrimarySmtpAddress
        else if (UserType = 1)  ; olExchangeDistributionListAddressEntry
            if (Recip.AddressEntry.GetExchangeDistributionList != "")
                return Recip.AddressEntry.GetExchangeDistributionList.PrimarySmtpAddress
    }
    else
        return MailItem.SenderEmailAddress
}

; References
;   http://answers.microsoft.com/en-us/office/forum/office_2007-customize/need-vba-to-obtain-smtp-address-of-exchange-user/97833c7c-18e3-4b8d-923a-606b81c9ecd1?auth=1
;   https://autohotkey.com/board/topic/71335-mickers-outlook-com-msdn-for-ahk-l/page-3#entry731838
