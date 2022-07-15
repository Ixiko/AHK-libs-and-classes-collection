/*
  This script demonstrates showing a very basic toast notification.
*/

#include ..\windows.ahk

; Set an AppUserModelID that uniquely identifies your application.
; For this to work properly, this ID probably needs to match that of a shortcut
; in the Start menu. Code for creating such a shortcut exists in AutoHotkey v2's
; installer (UX\inc\CreateAppShortcut.ahk).
appId := "AutoHotkey.AutoHotkey"

; Create an alias for convenience and performance.
TNM := Windows.UI.Notifications.ToastNotificationManager

; Clear all previous notifications (optional).
TNM.History.Clear appId

; Use a template for simplicity, but note we could use raw XML for more flexibility.
toastXml := TNM.GetTemplateContent('ToastImageAndText02')
toastXml.GetElementsByTagName("text").GetAt(0) ; XmlNodeList implements IVectorView.GetAt
    .InnerText := "Hello, world!"
items := toastXml.GetElementsByTagName("image").Item(0) ; ...and IXmlNodeList.Item
    .SetAttribute("src", A_ScriptDir "\sample.png")

; Create the notification and register (optional) event handlers.
notification := Windows.UI.Notifications.ToastNotification(toastXml)
notification.add_Activated((notification, args) => (
    MsgBox("Toast activated"),
    Persistent(false)
))
notification.add_Dismissed((notification, args) => (
    MsgBox("Toast dismissed: " String(args.Reason)),
    Persistent(false)
))
notification.add_Failed((notification, args) => (
    MsgBox("Toast failed: " args.ErrorCode),
    Persistent(false)
))

; Show the notification.
toastNotifier := TNM.CreateToastNotifier(appId)
toastNotifier.Show(notification)

; Handling toast activation after exit requires implementing a COM server.
; For this example we'll just stay running until the event is raised, but
; note that unlike TrayTip, the notification won't disappear if we exit.
Persistent true
