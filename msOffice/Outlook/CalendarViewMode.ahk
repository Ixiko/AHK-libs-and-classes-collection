; This script activates the calendar and changes the view to the month calendar.

; Constants
olFolderCalendar := 9
olCalendarViewMonth := 2

olApp := ComObjCreate("Outlook.Application")  ; Create an application object.
MyExplorer := olApp.ActiveExplorer  ; Get a reference to the explorer window.
MyExplorer.CurrentFolder := olApp.Session.GetDefaultFolder(olFolderCalendar)  ; Switch to the calendar folder.

; Apply view. This is required, for example, if the current callendar view is "List."
; If you try to set CalendarViewMode without a calendar view it will throw an error.
MyExplorer.CurrentFolder.Views.Item("Calendar").Apply

MyExplorer.CurrentView.CalendarViewMode := olCalendarViewMonth
MyExplorer.CurrentView.Save

; References
;   https://autohotkey.com/boards/viewtopic.php?f=5&t=21687&p=104558#p104558
