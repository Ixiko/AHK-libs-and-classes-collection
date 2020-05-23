Class WinAPIWrapper 
{
    Win {
        get {
            return WinAPIWindowFuncs
        }
    }
    Mouse {
        get {
            return WinAPIMouseFuncs
        }
    }
    KB {
        get {
            return WinAPIKBFuncs
        }
    }
}

class WinAPIWindowFuncs
{
    AllowSetForegroundWindow(dwProcessId) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632668(v=vs.85).aspx
    {
        return DllCall("AllowSetForegroundWindow", "int", dwProcessId)
    }   
    AnimateWindow(hWnd,dwTime,dwFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632669(v=vs.85).aspx
    {
        return DllCall("AnimateWindow", "int", hWnd, "int", dwTime, "int", dwFlags)
    }
    AnyPopup() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632670(v=vs.85).aspx
    {
        return DllCall("AnyPopup")
    }
    ArrangeIconicWindows(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632671(v=vs.85).aspx
    {
        return DllCall("ArrangeIconicWindows", "int", hWnd)
    }
    BeginDeferWindowPos(nNumWindows) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632672(v=vs.85).aspx
    {
        return DllCall("BeginDeferWindowPos", "int", nNumWindows)
    }
    BringWindowToTop(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632673(v=vs.85).aspx
    {
        return DllCall("BringWindowToTop", "int", hWnd)
    }
    ChildWindowFromPoint(hWnd,x,y) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632676(v=vs.85).aspx
    {
        return DllCall("ChildWindowFromPoint", "int", hWnd, "int", x, "int", y)
    }
    ChildWindowFromPointEx(hWnd,x,y,uFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632677(v=vs.85).aspx
    {
        return DllCall("ChildWindowFromPointEx", "int", hWnd, "int", x, "int", y, "uint", uFlags)
    }
    CloseWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632678(v=vs.85).aspx
    {
        return DllCall("CloseWindow", "int", hWnd)
    }
    DeferWindowPos(hWinPosInfo,hWnd,hWndInsertAfter,x,y,cx,cy,uFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632681(v=vs.85).aspx
    {
        return DllCall("DeferWindowPos", "int", hWinPosInfo, "int", hWnd, "int", hWndInsertAfter, "int", x, "int", y, "int", cx, "int", cy, "uint", uFlags)
    }
    DestroyWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms632682(v=vs.85).aspx
    {
        return DllCall("DestroyWindow", "int", hWnd)
    }
    EndDeferWindowPos(hWinPosInfo) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633440(v=vs.85).aspx
    {
        return DllCall("EndDeferWindowPos", "int", hWinPosInfo)
    }
    EndTask(hWnd,fShutDown,fForce) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633492(v=vs.85).aspx
    {
        return DllCall("EndTask", "int", hWnd, "int", fShutDown, "int", fForce)
    }
    FindWindow(lpClassName, lpszWindowName) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633499(v=vs.85).aspx
    {
        return DllCall("FindWindow", "AStr", lpClassName, "AStr", lpszWindowName)
    }
    FindWindowEx(hwndParent, hwndChildAfter, lpClassName, lpszWindowName) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633500(v=vs.85).aspx
    {
        return DllCall("FindWindowEx", "int", hwndParent, "int", hwndChildAfter, "AStr", lpClassName, "AStr", lpszWindowName)
    }
    GetAncestor(hWnd,gaFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633502(v=vs.85).aspx
    {
        return DllCall("GetAncestor", "int", hWnd, "uint", gaFlags)
    }
    GetDesktopWindow() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633504(v=vs.85).aspx
    {
        return DllCall("GetDesktopWindow")
    }
    GetForegroundWindow() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633505(v=vs.85).aspx
    {
        return DllCall("GetForegroundWindow")
    }
    GetLastActivePopup(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633507(v=vs.85).aspx
    {
        return DllCall("GetLastActivePopup", "int", hWnd)
    }
    GetNextWindow(hWnd,wCmd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633509(v=vs.85).aspx
    {
        return DllCall("GetNextWindow", "int", hWnd, "uint", wCmd)
    }
    GetParent(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633510(v=vs.85).aspx
    {
        return DllCall("GetParent", "int", hWnd)
    }
    GetShellWindow() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633512(v=vs.85).aspx
    {
        return DllCall("GetShellWindow")
    }
    ;not a win func
    GetSysColor(nIndex) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724371(v=vs.85).aspx
    {
        return DllCall("GetSysColor", "int", nIndex)
    }
    GetTopWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633514(v=vs.85).aspx
    {
        return DllCall("GetTopWindow", "int", hWnd)
    }
    GetWindow(hWnd,uCmd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633515(v=vs.85).aspx
    {
        return DllCall("IsChild", "int", hWnd, "uint", uCmd)
    }
    IsChild(hWndParent,hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633524(v=vs.85).aspx
    {
        return DllCall("IsChild", "int", hWndParent, "int", hWnd)
    }
    IsHungAppWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633526(v=vs.85).aspx
    {
        return DllCall("IsHungAppWindow", "int", hWnd)
    }
    IsIconic(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633527(v=vs.85).aspx
    {
        return DllCall("IsIconic", "int", hWnd)
    }
    IsWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633528(v=vs.85).aspx
    {
        return DllCall("IsWindow", "int", hWnd)
    }
    IsWindowUnicode(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633529(v=vs.85).aspx
    {
        return DllCall("IsWindowUnicode", "int", hWnd)
    }
    IsWindowVisible(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
    {
        return DllCall("IsWindowVisible", "int", hWnd)
    }
    IsZoomed(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633531(v=vs.85).aspx
    {
        return DllCall("IsZoomed", "int", hWnd)
    }
    MoveWindow(hWnd,x,y,nWidth,nHeight,bRepaint) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633534(v=vs.85).aspx
    {
        return DllCall("MoveWindow", "int", hWnd, "int", x, "int", y, "int", nWidth, "int", nHeight, "int", bRepaint)
    }
    OpenIcon(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633535(v=vs.85).aspx
    {
        return DllCall("OpenIcon", "int", hWnd)
    }
    RealChildWindowFromPoint(hWnd,x,y) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633537(v=vs.85).aspx
    {
        return DllCall("RealChildWindowFromPoint", "int", hWnd, "int", x, "int", y)
    }
    SetForegroundWindow(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633539(v=vs.85).aspx
    {
        return DllCall("SetForegroundWindow", "int", hWnd)
    }
    SetLayeredWindowAttributes(hWnd,hWndInsertAfter,crKey,bAlpha,dwFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633540(v=vs.85).aspx
    {
        return DllCall("SetLayeredWindowAttributes", "int", hWnd, "uint", crKey, "UChar",bAlpha, "uint", dwFlags)
    }
    SetParent(hWndChild,hWndNewParent) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633541(v=vs.85).aspx
    {
        return DllCall("SetParent", "int", hWndChild, "int", hWndNewParent)
    }
    SetWindowPos(hWnd,hWndInsertAfter,x,y,cx,cy,uFlags) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633545(v=vs.85).aspx
    {
        return DllCall("SetWindowPos", "int", hWnd, "int", hWndInsertAfter, "int", x, "int", y, "int", cx, "int", cy, "uint", uFlags)
    }
    SetWindowText(hWnd,lpString) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633546(v=vs.85).aspx
    {
        return DllCall("SetWindowText", "int", hWnd, "AStr", lpString)
    }
    ShowOwnedPopups(hWnd,fShow) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633547(v=vs.85).aspx
    {
        return DllCall("ShowOwnedPopups", "int", hWnd, "int", fShow)
    }
    ShowWindow(hWnd,nCmdShow) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
    {
        return DllCall("ShowWindow", "int", hWnd, "int", nCmdShow)
    }
    ShowWindowAsync(hWnd,nCmdShow) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633549(v=vs.85).aspx
    {
        return DllCall("ShowWindowAsync", "int", hWnd, "int", nCmdShow)
    }
    ;not a window func
    SoundSentry() ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa969269(v=vs.85).aspx
    {
        return DllCall("SoundSentry")
    }
    SwitchToThisWindow(hWnd,fAltTab) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633553(v=vs.85).aspx
    {
        return DllCall("SwitchToThisWindow", "int", hWnd, "int", fAltTab)
    }
    WindowFromPhysicalPoint(x,y) ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa969270(v=vs.85).aspx
    {
        return DllCall("WindowFromPhysicalPoint", "int", x, "int", y)
    }
    WindowFromPoint(x,y) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633558(v=vs.85).aspx
    {
        return DllCall("WindowFromPoint", "int", x, "int", y)
    }
    
}

Class WinAPIMouseFuncs
{
    DragDetect(hWnd,x,y) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646256(v=vs.85).aspx
    {
        return DllCall("DragDetect", "int", hWnd, "int", x, "int", y)
    }
    GetCapture() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646257(v=vs.85).aspx
    {
        return DllCall("GetCapture")
    }
    GetDoubleClickTime() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646258(v=vs.85).aspx
    {
        return DllCall("GetDoubleClickTime")
    }
    mouse_event(dwFlags, dx, dy, dwData) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646260(v=vs.85).aspx
    {
        DllCall("mouse_event", "UInt", dwFlags, "Int", dx, "Int", dy, "UInt", dwData, "UPtr", 0)  
    }
    ReleaseCapture() ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646261(v=vs.85).aspx
    {
        return DllCall("ReleaseCapture")
    }
    SetCapture(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646262(v=vs.85).aspx
    {
        return DllCall("SetCapture", "int", hWnd)
    }
    SetDoubleClickTime(uInterval) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646263(v=vs.85).aspx 
    {
        return DllCall("SetDoubleClickTime", "uint", uInterval)
    }
    SwapMouseButton(fSwap) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646264(v=vs.85).aspx
    {
        return DllCall("SwapMouseButton", "int", fSwap)
    }
}

Class WinAPIKBFuncs
{
    EnableWindow(hWnd,bEnable) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646291(v=vs.85).aspx
    {
        return DllCall("EnableWindow", "int", hWnd, "int", bEnable)
    }
    GetAsyncKeyState(vKey) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646293(v=vs.85).aspx
    {
        return DllCall("GetAsyncKeyState", "int", vKey)
    }
    GetKeyboardType(nTypeFlag) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724336(v=vs.85).aspx
    {
        return DllCall("GetKeyboardType", "int", nTypeFlag)
    }
    GetKeyState(nVirtKey) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646301(v=vs.85).aspx
    {
        return DllCall("GetKeyState", "int", nVirtKey)
    }
    IsWindowEnabled(hWnd) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646303(v=vs.85).aspx
    {
        return DllCall("IsWindowEnabled", "int", hWnd)
    }
    VkKeyScan(ch) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646332(v=vs.85).aspx
    {
        return DllCall("VkKeyScan", "UChar", ch)
    }
    VkKeyScanEx(ch, dwhkl) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646332(v=vs.85).aspx
    {
        return DllCall("VkKeyScanEx", "UChar", ch, "uint", dwhkl)
    }
}