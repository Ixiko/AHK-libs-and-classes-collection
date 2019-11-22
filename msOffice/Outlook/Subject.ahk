; Get the subject of the active item in Outlook. Works in both the main window and if the email is open in its own window.
olApp := ComObjActive("Outlook.Application")  ; Outlook must be running.
MyWindow := olApp.ActiveWindow  ; Get the active window.
MySubject := ""

; Check the window class to determine whether the active window is an Explorer or Inspector.
if (MyWindow.Class = 34) {  ; 34 = An Explorer object. (The main Outlook window)
    MySelection := MyWindow.Selection
    if (MySelection.Count > 0)
        MySubject := MySelection.Item(1).Subject
}
else if (MyWindow.Class = 35) { ; 35 = An Inspector object. (The email is open in its own window)
    MySubject := MyWindow.CurrentItem.Subject
}

MsgBox, % MySubject
return
