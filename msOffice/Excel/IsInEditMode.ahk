; This script tests if Excel is in edit mode. Many actions are forbidden while Excel is in edit-mode. They will generate
; warning messages instead of performing the requested action.

F7::  ; Press F7 to check if Excel is in edit mode. One (and only one) instance of Excel must be running. 
    xlApp := ComObjActive("Excel.Application")
    if (IsInEditMode(xlApp))
        MsgBox, 64, Edit Mode, Excel is in edit mode.
    else
        MsgBox, 64, Edit Mode, Excel is not in edit mode.
return

Esc::ExitApp  ; Press Escape to exit this script.

; IsInEditMode returns true if Excel is in edit mode, and false otherwise.
; App is the specified Excel applicaiton object
IsInEditMode(App) {   
    try return !App.Interactive
    catch
        return true
}

; References
;   Excel_Get.ahk - https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Excel_Get.ahk
;   GetActiveWorkbook.ahk
;       - https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/GetActiveWorkbook.ahk
