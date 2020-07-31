; Link:   	https://autohotkey.com/board/topic/59528-double-click-for-controlclick/
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; Retrieves the control at the specified point. 
; X         [in]    X-coordinate relative to the top-left of the window. 
; Y         [in]    Y-coordinate relative to the top-left of the window. 
; WinTitle  [in]    Title of the window whose controls will be searched. 
; WinText   [in] 
; cX        [out]   X-coordinate relative to the top-left of the control. 
; cY        [out]   Y-coordinate relative to the top-left of the control. 
; ExcludeTitle [in] 
; ExcludeText  [in] 
; Return Value:     The hwnd of the control if found, otherwise the hwnd of the window. 
ControlFromPoint(X, Y, WinTitle="", WinText="", ByRef cX="", ByRef cY="", ExcludeTitle="", ExcludeText="") 
{ 
    static EnumChildFindPointProc=0 
    if !EnumChildFindPointProc 
        EnumChildFindPointProc := RegisterCallback("EnumChildFindPoint","Fast") 
    
    if !(target_window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)) 
        return false 
    
    VarSetCapacity(rect, 16) 
    DllCall("GetWindowRect","uint",target_window,"uint",&rect) 
    VarSetCapacity(pah, 36, 0) 
    NumPut(X + NumGet(rect,0,"int"), pah,0,"int") 
    NumPut(Y + NumGet(rect,4,"int"), pah,4,"int") 
    DllCall("EnumChildWindows","uint",target_window,"uint",EnumChildFindPointProc,"uint",&pah) 
    control_window := NumGet(pah,24) ? NumGet(pah,24) : target_window 
    DllCall("ScreenToClient","uint",control_window,"uint",&pah) 
    cX:=NumGet(pah,0,"int"), cY:=NumGet(pah,4,"int") 
    return control_window 
} 

; Ported from AutoHotkey::script2.cpp::EnumChildFindPoint() 
EnumChildFindPoint(aWnd, lParam) 
{ 
    if !DllCall("IsWindowVisible","uint",aWnd) 
        return true 
    VarSetCapacity(rect, 16) 
    if !DllCall("GetWindowRect","uint",aWnd,"uint",&rect) 
        return true 
    pt_x:=NumGet(lParam+0,0,"int"), pt_y:=NumGet(lParam+0,4,"int") 
    rect_left:=NumGet(rect,0,"int"), rect_right:=NumGet(rect,8,"int") 
    rect_top:=NumGet(rect,4,"int"), rect_bottom:=NumGet(rect,12,"int") 
    if (pt_x >= rect_left && pt_x <= rect_right && pt_y >= rect_top && pt_y <= rect_bottom) 
    { 
        center_x := rect_left + (rect_right - rect_left) / 2 
        center_y := rect_top + (rect_bottom - rect_top) / 2 
        distance := Sqrt((pt_x-center_x)**2 + (pt_y-center_y)**2) 
        update_it := !NumGet(lParam+24) 
        if (!update_it) 
        { 
            rect_found_left:=NumGet(lParam+8,0,"int"), rect_found_right:=NumGet(lParam+8,8,"int") 
            rect_found_top:=NumGet(lParam+8,4,"int"), rect_found_bottom:=NumGet(lParam+8,12,"int") 
            if (rect_left >= rect_found_left && rect_right <= rect_found_right 
                && rect_top >= rect_found_top && rect_bottom <= rect_found_bottom) 
                update_it := true 
            else if (distance < NumGet(lParam+28,0,"double") 
                && (rect_found_left < rect_left || rect_found_right > rect_right 
                 || rect_found_top < rect_top || rect_found_bottom > rect_bottom)) 
                 update_it := true 
        } 
        if (update_it) 
        { 
            NumPut(aWnd, lParam+24) 
            DllCall("RtlMoveMemory","uint",lParam+8,"uint",&rect,"uint",16) 
            NumPut(distance, lParam+28, 0, "double") 
        } 
    } 
    return true 
}