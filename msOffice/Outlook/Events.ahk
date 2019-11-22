; This script demonstrates handling events of the Outlook Application object. Other types of objects will have different
; events.

; Usage:
; With Outlook open, run this script. Then try to send an email. The script will prevent the email from being sent and
; will display a message box.


#Persistent

; Instantiate the event handler class.
OlEvents := new OutlookApplicationEvents()

return  ; End of Auto-execute section.


; Basic Outlook events class. Can be connected to an Outlook Application object.
class OutlookApplicationEvents
{
    __New(olApp := "")
    {
        ; If nothing was passed to this method, then use the active instance of Outlook. This will throw an error if
        ; Outlook is not running.
        if (olApp = "")
            olApp := ComObjActive("Outlook.Application")
        
        ; Store Outlook application object for later use (optional).
        this.olApp := olApp
        
        ; Connect Outlook Application object events to this instance.
        ComObjConnect(this.olApp, this)
    }
    
    ; Responds to non-implemented events in a generic manner.
    ; Possible Outlook (2010) Application events:
    ; | Event Name                  | Implemented   | Params
    ; | ----------------------------|---------------|-------------------------------------------------------------------
    ; | AdvancedSearchComplete      | No            | SearchObject As Search
    ; | AdvancedSearchStopped       | No            | SearchObject As Search
    ; | BeforeFolderSharingDialog   | No            | FolderToShare As Folder, Cancel As Boolean
    ; | ItemLoad                    | No            | Item As Object
    ; | ItemSend                    | Yes           | Item As Object, Cancel As Boolean
    ; | MAPILogonComplete           | No            | -
    ; | NewMail                     | No            | -
    ; | NewMailEx                   | No            | EntryIDCollection As String
    ; | OptionsPagesAdd             | No            | Pages As PropertyPages
    ; | Quit                        | Yes           | -
    ; | Reminder                    | No            | Item As Object
    ; | Startup                     | No            | -
    __Call(Event, Args*)
    {
        if !IsFunc( this[Event] ) {             ; If this event does not correspond to a method...
            ToolTip, % Event, 0, 0              ; Display the event name.
            SetTimer, RemoveTT, -4000           ; Remove the tooltip in 4 seconds.
        }
    }
    
    ; Occurs whenever an Outlook item is sent.
    ItemSend(Item, Cancel, olApp)
    {
        MsgBox
            , 48
            , Send Cancelled
            , % "This email will not be sent.`n`n"
            . "To: " Item.To "`n"
            . "Subject: " Item.Subject
        
        ; Change the value of Cancel to true to prevent sending. -1 is True in VB.
        ;   "[Cancel is] False [(0)] when the event occurs. If the event procedure sets this argument to True [(-1)], 
        ;    the send action is not completed and the inspector is left open."
        NumPut(-1, ComObjValue(Cancel), "Short")
    }
    
    ; Occurs when Outlook begins to close. 
    Quit(olApp)
    {
        ComObjConnect(olApp)                    ; Disconnect application events.
        ExitApp                                 ; Exit this script.
    }
}

RemoveTT() {
    ToolTip
}

^Esc::ExitApp                                   ; Ctrl+Escape will exit this script.
