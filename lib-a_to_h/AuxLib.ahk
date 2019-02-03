; Window functions *****************************************************

GetWindowPlacement(hWnd) {
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
    Result := {}
    Result.x := NumGet(WINDOWPLACEMENT, 28, "Int")
    Result.y := NumGet(WINDOWPLACEMENT, 32, "Int")
    Result.w := NumGet(WINDOWPLACEMENT, 36, "Int") - Result.x
    Result.h := NumGet(WINDOWPLACEMENT, 40, "Int") - Result.y
    Result.showCmd := NumGet(WINDOWPLACEMENT, 8, "UInt") ; 1 = normal, 2 = minimized, 3 = maximized
    Return Result
}

SetWindowPlacement(hWnd, x, y, w, h, showCmd) {
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    NumPut(x, WINDOWPLACEMENT, 28, "Int")
    NumPut(y, WINDOWPLACEMENT, 32, "Int")
    NumPut(w + x, WINDOWPLACEMENT, 36, "Int")
    NumPut(h + y, WINDOWPLACEMENT, 40, "Int")
    NumPut(showCmd, WINDOWPLACEMENT, 8, "UInt")
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
}

GetWindowInfo(hWnd) {
    NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO, 0, "UInt")
    DllCall("GetWindowInfo", "Ptr", hWnd, "Ptr", &WINDOWINFO)
    wi := Object()
    wi.WindowX := NumGet(WINDOWINFO, 4, "Int")
    wi.WindowY := NumGet(WINDOWINFO, 8, "Int")
    wi.WindowW := NumGet(WINDOWINFO, 12, "Int") - wi.WindowX
    wi.WindowH := NumGet(WINDOWINFO, 16, "Int") - wi.WindowY
    wi.ClientX := NumGet(WINDOWINFO, 20, "Int")
    wi.ClientY := NumGet(WINDOWINFO, 24, "Int")
    wi.ClientW := NumGet(WINDOWINFO, 28, "Int") - wi.ClientX
    wi.ClientH := NumGet(WINDOWINFO, 32, "Int") - wi.ClientY
    wi.Style   := NumGet(WINDOWINFO, 36, "UInt")
    wi.ExStyle := NumGet(WINDOWINFO, 40, "UInt")
    wi.Active  := NumGet(WINDOWINFO, 44, "UInt")
    wi.BorderW := NumGet(WINDOWINFO, 48, "UInt")
    wi.BorderH := NumGet(WINDOWINFO, 52, "UInt")
    ;wi.Atom    := NumGet(WINDOWINFO, 56, "UShort")
    ;wi.Version := NumGet(WINDOWINFO, 58, "UShort")
    Return wi
}

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "int")
    Height := NumGet(RECT, 12, "int")
}

SetWindowPos(hWnd, x, y, w, h, hWndInsertAfter := 0, uFlags := 0x40) { ; SWP_SHOWWINDOW
    Return DllCall("SetWindowPos", "Ptr", hWnd, "Ptr", hWndInsertAfter, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", uFlags)
}

IsWindow(hWnd) {
    Return DllCall("IsWindow", "Ptr", hWnd)
}

IsWindowVisible(hWnd) {
    Return DllCall("IsWindowVisible", "Ptr", hWnd)
}

ShowWindow(hWnd, nCmdShow := 1) {
    DllCall("ShowWindow", "Ptr", hWnd, "UInt", nCmdShow)
}

MoveWindow(hWnd, x, y, w, h, bRepaint) {
    DllCall("MoveWindow", "Ptr", hWnd, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", bRepaint)
}

GetActiveWindow() {
    Return DllCall("GetActiveWindow", "Ptr")
}

SetActiveWindow(hWnd) {
    Return DllCall("SetActiveWindow", "Ptr", hWnd)
}

DestroyWindow(hWnd) {
    Return DllCall("DestroyWindow", "Ptr", hWnd)
}

GetParent(hWnd) {
    Return DllCall("GetParent", "Ptr", hWnd, "Ptr")
}

; Flag: GA_PARENT = 1, GA_ROOT = 2, GA_ROOTOWNER = 3
GetAncestor(hWnd, Flag := 2) {
    Return DllCall("GetAncestor", "Ptr", hWnd, "UInt", Flag, "Ptr")
}

SetParent(hWndChild, hWndNewParent) {
    Return DllCall("SetParent", "Ptr", hWndChild, "Ptr", hWndNewParent)
}

GetFocus() {
    Return DllCall("GetFocus", "Ptr")
}

SetFocus(hWnd) {
    Return DllCall("SetFocus", "Ptr", hWnd)
}

SetWindowIcon(hWnd, Filename, Index := 1) {
    Local hIcon := LoadPicture(Filename, "w16 Icon" . Index, ErrorLevel)
    SendMessage 0x80, 0, hIcon,, ahk_id %hWnd% ; WM_SETICON
    Return ErrorLevel
}

; Menu functions *******************************************************

GetMenu(hWnd) {
    Return DllCall("GetMenu", "Ptr", hWnd, "Ptr")
}

GetSubMenu(hMenu, nPos) {
    Return DllCall("GetSubMenu", "Ptr", hMenu, "UInt", nPos, "Ptr")
}

GetMenuItemID(hMenu, nPos) {
    Return DllCall("GetMenuItemID", "Ptr", hMenu, "UInt", nPos)
}

GetMenuItemCount(hMenu) {
    Return DllCall("GetMenuItemCount", "Ptr", hMenu)
}

GetMenuString(hMenu, uIDItem) {
    ; uIDItem: the zero-based relative position of the menu item
    Local lpString, MenuItemID
    VarSetCapacity(lpString, 4096)
    If !(DllCall("GetMenuString", "Ptr", hMenu, "UInt", uIDItem, "Str", lpString, "UInt", 4096, "UInt", 0x400)) {
        MenuItemID := GetMenuItemID(hMenu, uIDItem)
        If (MenuItemID > -1) {
            Return "SEPARATOR"
        } Else {
            Return (GetSubMenu(hMenu, uIDItem)) ? "SUBMENU" : "ERROR"
        }
    }
    Return lpString
}

CheckMenuRadioItem(hMenu, nPos, nFirst := 0, nLast := 0) {
    Return DllCall("CheckMenuRadioItem", "Ptr", hMenu, "UInt", nFirst , "UInt", nLast, "UInt", nPos, "UInt", 0x400)
}

DeleteMenu(hMenu, uPosition, uFlags := 0x400) { ; By position
    Return DllCall("DeleteMenu", "Ptr", hMenu, "UInt", uPosition, "UInt", uFlags)
}

; Misc functions *******************************************************

GetSysColor(nIndex) {
    Return DllCall("GetSysColor", "UInt", nIndex)
}

IfBetween(ByRef Var, LowerBound, UpperBound) {
    If Var Between %LowerBound% And %UpperBound%
        Return True
}

IfNotBetween(ByRef Var, LowerBound, UpperBound) {
    If Var Not Between %LowerBound% And %UpperBound%
        Return True
}

GetClassName(hWnd) {
    WinGetClass Class, ahk_id %hWnd%
    Return Class
}

; Temp
GetClassNN(hCtrl) {
    WinGet ClassNNList, ControlList, ahk_id %hChildWnd%
    Loop Parse, ClassNNList, `n
    {
        GuiControlGet hWnd, %Child%: hWnd, %A_LoopField%
        If (hWnd == hCtrl) {
            Return A_LoopField
        }
    }
}

ToHex(x) {
    Return Format("0x{:X}", x)
}

ToDec(x) {
    Return Format("{:d}", x)
}

RoundTo(Value, RoundTo) {
    Return Floor(Value/RoundTo) * RoundTo
}

GetFileIcon(File, SmallIcon := 1) {
    VarSetCapacity(SHFILEINFO, cbFileInfo := A_PtrSize + 688)
    If (DllCall("Shell32.dll\SHGetFileInfoW"
        , "WStr", File
        , "UInt", 0
        , "Ptr" , &SHFILEINFO
        , "UInt", cbFileInfo
        , "UInt", 0x100 | SmallIcon)) { ; SHGFI_ICON
        Return NumGet(SHFILEINFO, 0, "Ptr")
    }
}

CvtClr(Color) {
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16)
}

Edit_ShowBalloonTip(hEdit, Text, Title := "", Icon := 0) {
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(&Title, EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(&Text, EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

; Unsigned int to int
Int(x) {
    Return x << 32 >> 32
}

; Types: 0 = bitmap, 1 = icon, 2 = cursor
LoadImage(File, Width, Height, Type, Flags := 0x10) {
    Return DllCall("LoadImage", "Int", 0
    , "Str", File
    , "Int", Type
    , "Int", Width, "Int", Height
    , "UInt", Flags, "Ptr") ; LR_LOADFROMFILE
}

SetExplorerTheme(hWnd) {
    Return DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "WStr", "Explorer", "Ptr", 0)
}
