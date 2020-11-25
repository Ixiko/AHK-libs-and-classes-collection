; This example displays and selects each item in the Inbox in a sorted order.

; Constants
olFolderInbox := 6

olApp := ComObjActive("Outlook.Application")  ; Connect to the existing instance of Outlook.
Inbox := olApp.Session.GetDefaultFolder(olFolderInbox)
olExp := olApp.ActiveExplorer
MyItems := Inbox.Items  ; Get a collection of items.
MyItems.Sort("[Received]", true)  ; Sort 'MyItems'.

; Note: If you do 'MyItems := Inbox.Items' again at this point, it will return a new UNSORTED object. You need to save
; the reference to the sorted object (MyItems) if you want to keep using it.
 
for MailItem, in  MyItems
{
    olExp.ClearSelection
    olExp.AddToSelection(MailItem)  ; Selects the current item.
    MsgBox, 4, Confirm Step, % "Item #: " A_Index "`n"
                             . "Subject: " MailItem.Subject "`n`n"
                             . "Continue?"
    IfMsgBox No
        break
}

; References:
;   https://autohotkey.com/board/topic/71335-mickers-outlook-com-msdn-for-ahk-l/page-3#entry733202
;   https://social.msdn.microsoft.com/Forums/office/en-US/986a7325-4d2c-4c91-8a0e-f4a4b880b7a0/mailitem-collection-order-for-a-folder?forum=outlookdev
;   Explorer.AddToSelection Method (Outlook) - https://msdn.microsoft.com/en-us/library/office/ff868732.aspx#Anchor_1
