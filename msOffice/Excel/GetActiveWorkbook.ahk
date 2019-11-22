; This script demonstrates getting a reference to the active workbook if more than one Excel Application is open. 
; The GetActiveObjects function is required. (Paste it into this script or #Include it.)
; GetActiveObjects - http://ahkscript.org/boards/viewtopic.php?f=6&t=6494

; Usage:
;   - Press F7 to display info about the active Excel workbook.
;   - Press F8 to display the full list of objects that GetActiveObjects returns.
;   - Press Escape to exit this script.

F7::  ; F7 hotkey. Press to display info about the active Excel workbook.
    Wbk := GetActiveWorkbook()
    AppCap := Wbk.Application.Caption
    
    MsgBox, % "Active workbook name: <" Wbk.Name    ">`n"
            . "Active workbok path: <"  Wbk.Path    ">`n"
            . "Excel caption: <"        AppCap      ">"
return

F8::  ; F8 Hotkey. Press to display the full list of objects that GetActiveObjects returns.
    list := ""
    for name, obj in GetActiveObjects()
        list .= name " -- " ComObjType(obj, "Name") "`n"
    MsgBox %list%
return

Esc::ExitApp  ; Excape hotkey. Press to exit this script.

; Returns the active Excel workbook. If Excel is not active or if Excel is in edit-mode, this function returns blank.
GetActiveWorkbook()
{
    ; Sometimes AHK reports a blank Wintitle/class/exe. Brief testing shows this happens when more than one Excel 
    ; application is open. If no hwnd exists for the active window, this attempts to activate Excel.
    if !(WinHwnd := WinExist("A"))  
    {
        WinActivate, ahk_class XLMAIN
        WinWaitActive, ahk_class XLMAIN,, 1
        WinHwnd := WinExist("A")
    }
    
    WinGetClass, WinClass, A  ; Get the window class - "XLMAIN" is expected.
    if !(WinClass = "XLMAIN") || !WinHwnd
        return  ; Excel is not active.
    
    for name, obj in GetActiveObjects()  ; For each object returned by GetActiveObjects.
        if (ComObjType(obj, "Name") = "_Workbook")  ; If the current object is a workbook.
            if (obj.Application.hwnd = WinHwnd)  ; If the hwnd matches the active window.
                return obj.Application.ActiveWorkbook  ; Return the active workbook.
}

; GetActiveObjects v1.0 by Lexikos
; http://ahkscript.org/boards/viewtopic.php?f=6&t=6494
; <Paste the GetActiveObjects function definition here>

; References:
;   Excel_Get - https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Excel_Get.ahk
;   Quirks of ComObjActive - https://autohotkey.com/boards/viewtopic.php?p=134048#p134048
;   Is a given workbook open? - https://autohotkey.com/boards/viewtopic.php?p=116315#p116315
;   Difference between ComObjActive and ComObjCreate - https://autohotkey.com/boards/viewtopic.php?p=133855#p133855
;   FanaticGuru example of GetExcel class - https://autohotkey.com/boards/viewtopic.php?p=134876#p134876
