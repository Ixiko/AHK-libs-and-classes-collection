listview_get_column_clicked(p_lv_hwnd) {

   Static LVM_SUBITEMHITTEST := 0x1039
   VarSetCapacity(point, 8, 0)
   ; Get the current cursor position in screen coordinates
   DllCall("User32.dll\GetCursorPos", "Ptr", &point)
   ; Convert them to client coordinates related to the ListView
   DllCall("User32.dll\ScreenToClient", "Ptr", p_lv_hwnd, "Ptr", &point)
   ; Create a lv_hitesttest_info structure (see above comment)
   VarSetCapacity(lv_hitesttest_info, 24, 0)
   ; Store the relative mouse coordinates
   NumPut(NumGet(point, 0, "Int"), lv_hitesttest_info, 0, "Int")    ; x
   NumPut(NumGet(point, 4, "Int"), lv_hitesttest_info, 4, "Int")    ; y
   SendMessage, LVM_SUBITEMHITTEST, 0, &lv_hitesttest_info, , ahk_id %p_lv_hwnd%
   If (ErrorLevel = -1)
      Return 0
   column_num := NumGet(lv_hitesttest_info, 16, "Int") + 1
   Return column_num
}