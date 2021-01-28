; 1) Disable drawing with "WS_Visible", "LockWindowUpdate" or "WM_SETREDRAW"
; 2) Execute ur code
; 3) Enable drawing with "WS_Visible", "LockWindowUpdate" or "WM_SETREDRAW"
; 4) Call RedrawDB(hWnd) where hWnd is handle to window
; IMPORTANT!
; 5)Turn off composition by Ctrl+Shift+a or disable aero effects manually. If you use hotkey then after script close or reload composition will be returned so i reccomend to manually disable aero effects.
;https://autohotkey.com/board/topic/95930-window-double-buffering-redraw-gdi-avoid-flickering/

^+a::  ; Control+Shift+A to Toggle On and Off
if toggle := !toggle
   DllCall("dwmapi\DwmEnableComposition", "uint", 0) ; DllCall For Windows Decomposition ; On
else
   DllCall("dwmapi\DwmEnableComposition", "uint", 1) ; DllCall For Windows Decomposition ; Off
return

RedrawDB(hWnd) {
    ;==========================================================================
    ; Get required coordinates
    ;==========================================================================
    Static SizeOfWINDOWINFO := 60
    VarSetCapacity(WINDOWINFO, SizeOfWINDOWINFO, 0)
    NumPut(SizeOfWINDOWINFO, WINDOWINFO, "UInt")
    DllCall("GetWindowInfo", "Ptr",hWnd, "Ptr",&WINDOWINFO, "UInt")
    WindowX := NumGet(WINDOWINFO,  4, "Int")                    ; X coordinate of the window
    WindowY := NumGet(WINDOWINFO,  8, "Int")                    ; Y coordinate of the window
    WindowW := NumGet(WINDOWINFO, 12, "Int") - WindowX            ; Width of the window
    WindowH := NumGet(WINDOWINFO, 16, "Int") - WindowY            ; Height of the window
    ClientX := NumGet(WINDOWINFO, 20, "Int")                    ; X coordinate of the client area
    ClientY := NumGet(WINDOWINFO, 24, "Int")                    ; Y coordinate of the client area
    ClientW := NumGet(WINDOWINFO, 28, "Int") - ClientX            ; Width of the client area
    ClientH := NumGet(WINDOWINFO, 32, "Int") - ClientY            ; Height of the client area
    
    ;==========================================================================
    ; Create Buffer
    ;==========================================================================
    hdcDest :=         DllCall("GetDC", "Ptr",hWnd)
    hdcSrc :=         DllCall("CreateCompatibleDC", "Ptr",hdcDest)  ; buffer
    hbm_buffer :=     DllCall("CreateCompatibleBitmap", "Ptr",hdcDest, "Int",WindowW, "Int",WindowH)
                    DllCall("SelectObject", "Ptr",hdcSrc, "Ptr",hbm_buffer)
    
    ;==========================================================================
    ; Capture - PrintWindow
    ;==========================================================================
    DllCall("PrintWindow", "Ptr",hwnd, "Ptr",hdcSrc, "uint",0) ; PW_CLIENTONLY bugged on XP so GetWindowInfo() or MapWindowPoints() required to capture client area.
    
    ;==========================================================================
    ; Draw - StretchBlt
    ;==========================================================================    
    DllCall("StretchBlt"
    , "Ptr", hdcDest
    , "Int", 0
    , "Int", 0
    , "Int", ClientW
    , "Int", ClientH
    , "Ptr", hdcSrc
    , "Int", ClientX - WindowX
    , "Int", ClientY - WindowY
    , "Int", ClientW
    , "Int", ClientH
    ,"UInt", 0xCC0020) ; SRCCOPY  
    
    ;==========================================================================
    ; Clear
    ;==========================================================================
    DllCall("DeleteDC", "Ptr",hdcDest)
    DllCall("DeleteDC", "Ptr",hdcSrc)
    DllCall("DeleteObject", "Ptr",hbm_buffer)
Return TRUE
}