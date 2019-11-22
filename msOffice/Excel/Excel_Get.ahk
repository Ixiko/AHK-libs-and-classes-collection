; Excel_Get by jethrow (modified)
; Forum:    https://autohotkey.com/boards/viewtopic.php?f=6&t=31840
; Github:   https://github.com/ahkon/MS-Office-COM-Basics/blob/master/Examples/Excel/Excel_Get.ahk
Excel_Get(WinTitle:="ahk_class XLMAIN", Excel7#:=1) {
    static h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
    WinGetClass, WinClass, %WinTitle%
    if !(WinClass == "XLMAIN")
        return "Window class mismatch."
    ControlGet, hwnd, hwnd,, Excel7%Excel7#%, %WinTitle%
    if (ErrorLevel)
        return "Error accessing the control hWnd."
    VarSetCapacity(IID_IDispatch, 16)
    NumPut(0x46000000000000C0, NumPut(0x0000000000020400, IID_IDispatch, "Int64"), "Int64")
    if DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", -16, "Ptr", &IID_IDispatch, "Ptr*", pacc) != 0
        return "Error calling AccessibleObjectFromWindow."
    window := ComObject(9, pacc, 1)
    if ComObjType(window) != 9
        return "Error wrapping the window object."
    Loop
        try return window.Application
        catch e
            if SubStr(e.message, 1, 10) = "0x80010001"
                ControlSend, Excel7%Excel7#%, {Esc}, %WinTitle%
            else
                return "Error accessing the application object."
}

; References
;   https://autohotkey.com/board/topic/88337-ahk-failure-with-excel-get/?p=560328
;   https://autohotkey.com/board/topic/76162-excel-com-errors/?p=484371
;   https://autohotkey.com/boards/viewtopic.php?p=134048#p134048
