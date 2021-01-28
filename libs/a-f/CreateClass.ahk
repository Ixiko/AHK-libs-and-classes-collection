; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=76103
; Author:
; Date:
; for:     	AHK_L

/*


*/

AppName := "Autohotkey"

setbatchlines -1
CreateClass("Windows.UI.Notifications.Management.UserNotificationListener", IUserNotificationListenerStatics := "{FF6123CF-4386-4AA3-B73D-B804E5B63B23}", UserNotificationListenerStatics)
DllCall(NumGet(NumGet(UserNotificationListenerStatics+0)+6*A_PtrSize), "ptr", UserNotificationListenerStatics, "ptr*", listener)   ; get_Current
DllCall(NumGet(NumGet(listener+0)+6*A_PtrSize), "ptr", listener, "int*", accessStatus)   ; RequestAccessAsync
WaitForAsync(accessStatus)
if (accessStatus != 1){
   msgbox AccessStatus Denied
   exitapp
}
loop{
   DllCall(NumGet(NumGet(listener+0)+10*A_PtrSize), "ptr", listener, "int", 1, "ptr*", UserNotificationReadOnlyList)   ; GetNotificationsAsync
   WaitForAsync(UserNotificationReadOnlyList)
   DllCall(NumGet(NumGet(UserNotificationReadOnlyList+0)+7*A_PtrSize), "ptr", UserNotificationReadOnlyList, "int*", count)   ; count
   loop % count
   {
      DllCall(NumGet(NumGet(UserNotificationReadOnlyList+0)+6*A_PtrSize), "ptr", UserNotificationReadOnlyList, "int", A_Index-1, "ptr*", UserNotification)   ; get_Item
      DllCall(NumGet(NumGet(UserNotification+0)+8*A_PtrSize), "ptr", UserNotification, "uint*", id)   ; get_Id
      if InStr(idList, "|" id "|")
      {
         ObjRelease(UserNotification)
         Continue
      }
      idList .= "|" id "|"
      if !DllCall(NumGet(NumGet(UserNotification+0)+7*A_PtrSize), "ptr", UserNotification, "ptr*", AppInfo)   ; get_AppInfo
      {
         DllCall(NumGet(NumGet(AppInfo+0)+8*A_PtrSize), "ptr", AppInfo, "ptr*", AppDisplayInfo)   ; get_DisplayInfo
         DllCall(NumGet(NumGet(AppDisplayInfo+0)+6*A_PtrSize), "ptr", AppDisplayInfo, "ptr*", hText)   ; get_DisplayName
         buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
         text := StrGet(buffer, "UTF-16")
         DeleteHString(hText)
         ObjRelease(AppDisplayInfo)
         ObjRelease(AppInfo)
         if (text != AppName)
         {
            ObjRelease(UserNotification)
            Continue
         }
      }
      else
      {
         ObjRelease(UserNotification)
         Continue
      }
      DllCall(NumGet(NumGet(UserNotification+0)+6*A_PtrSize), "ptr", UserNotification, "ptr*", Notification)   ; get_Notification
      DllCall(NumGet(NumGet(Notification+0)+8*A_PtrSize), "ptr", Notification, "ptr*", NotificationVisual)   ; get_Visual
      DllCall(NumGet(NumGet(NotificationVisual+0)+8*A_PtrSize), "ptr", NotificationVisual, "ptr*", NotificationBindingList)   ; get_Bindings
      DllCall(NumGet(NumGet(NotificationBindingList+0)+7*A_PtrSize), "ptr", NotificationBindingList, "int*", count)   ; count
      loop % count
      {
         DllCall(NumGet(NumGet(NotificationBindingList+0)+6*A_PtrSize), "ptr", NotificationBindingList, "int", A_Index-1, "ptr*", NotificationBinding)   ; get_Item
         DllCall(NumGet(NumGet(NotificationBinding+0)+11*A_PtrSize), "ptr", NotificationBinding, "ptr*", AdaptiveNotificationTextReadOnlyList)   ; GetTextElements
         DllCall(NumGet(NumGet(AdaptiveNotificationTextReadOnlyList+0)+7*A_PtrSize), "ptr", AdaptiveNotificationTextReadOnlyList, "int*", count)   ; count
         loop % count
         {
            DllCall(NumGet(NumGet(AdaptiveNotificationTextReadOnlyList+0)+6*A_PtrSize), "ptr", AdaptiveNotificationTextReadOnlyList, "int", A_Index-1, "ptr*", AdaptiveNotificationText)   ; get_Item
            DllCall(NumGet(NumGet(AdaptiveNotificationText+0)+6*A_PtrSize), "ptr", AdaptiveNotificationText, "ptr*", hText)   ; get_Text
            buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
            if (A_Index = 1)
               text := StrGet(buffer, "UTF-16")
            else
               text .= "`n" StrGet(buffer, "UTF-16")
            DeleteHString(hText)
            ObjRelease(AdaptiveNotificationText)
         }
         ObjRelease(AdaptiveNotificationTextReadOnlyList)
         ObjRelease(NotificationBinding)
         msgbox % text
      }
      ObjRelease(NotificationBindingList)
      ObjRelease(NotificationVisual)
      ObjRelease(Notification)
      ObjRelease(UserNotification)
   }
   ObjRelease(UserNotificationReadOnlyList)
   DllCall("psapi.dll\EmptyWorkingSet", "ptr", -1)
   sleep 50
}


CreateClass(string, interface, ByRef Class){
   CreateHString(string, hString)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
   result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class, "uint")
   if (result != 0)
   {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      ExitApp
   }
   DeleteHString(hString)
}

CreateHString(string, ByRef hString){
   DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}

DeleteHString(hString){
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(ByRef Object){
   AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
   loop
   {
      DllCall(NumGet(NumGet(AsyncInfo+0)+7*A_PtrSize), "ptr", AsyncInfo, "uint*", status)   ; IAsyncInfo.Status
      if (status != 0)
      {
         if (status != 1)
         {
            DllCall(NumGet(NumGet(AsyncInfo+0)+8*A_PtrSize), "ptr", AsyncInfo, "uint*", ErrorCode)   ; IAsyncInfo.ErrorCode
            msgbox AsyncInfo status error: %ErrorCode%
            ExitApp
         }
         ObjRelease(AsyncInfo)
         break
      }
      sleep 10
   }
   DllCall(NumGet(NumGet(Object+0)+8*A_PtrSize), "ptr", Object, "ptr*", ObjectResult)   ; GetResults
   ObjRelease(Object)
   Object := ObjectResult
}