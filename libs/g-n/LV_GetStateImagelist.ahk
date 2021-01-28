; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=71801
; Author:
; Date:
; for:     	AHK_L

/*


*/

; ----------------------------------------------------------------------------------------------------------------------
; Gets the state image list of a list view control.
; If you need to assign the returned image list to multiple list views,
; consider to set the LVS_SHAREIMAGELISTS (0x40) style.
; ----------------------------------------------------------------------------------------------------------------------
LV_GetStateImagelist() {
   ; LVM_GETIMAGELIST = 0x1002, LVM_SETEXTENDEDLISTVIEWSTYLE = 0x1036
   ; LVSIL_STATE = 0x02, LVS_EX_CHECKBOXES = 0x04
   Static HSIL := 0
   If (HSIL = 0) {
      HWND := DllCall("CreateWindowEx", "UInt", 0x0200, "Str", "SysListView32", "Ptr", 0, "UInt", 0x01
                    , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UPtr")
      DllCall("SendMessage", "Ptr", HWND, "UInt", 0x1036, "Ptr", 0x04, "Ptr", 0x04)
      HSIL := DllCall("SendMessage", "Ptr", HWND, "UInt", 0x1002, "Ptr", 2, "Ptr", 0, "UPtr")
   }
   Return HSIL
}