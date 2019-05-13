class VirtualDesktopAccessor
{
    __New()
    {
        hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\lib\virtual-desktop-accessor.dll", "Ptr")

        this._goToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
        this._registerPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
        this._unregisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnregisterPostMessageHook", "Ptr")
        this._getCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
        this._getDesktopCountProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetDesktopCount", "Ptr")
        this._isWindowOnDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnDesktopNumber", "Ptr")
        this._moveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
        this._isPinnedWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow", "Ptr")
        this._pinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "PinWindow", "Ptr")
        this._unPinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnPinWindow", "Ptr")
        this._isPinnedAppProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedApp", "Ptr")
        this._pinAppProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "PinApp", "Ptr")
        this._unPinAppProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnPinApp", "Ptr")
    }

    GoToDesktopNumber(index)
    {
        DllCall(this._goToDesktopNumberProc, Int, index)
    }

    RegisterPostMessageHook(listnerHwnd, messageOffset)
    {
        DllCall(this._registerPostMessageHookProc, Int, listnerHwnd, Int, messageOffset)
    }

    UnregisterPostMessageHook(listnerHwnd)
    {
        DllCall(this._unregisterPostMessageHookProc, Int, listnerHwnd)
    }

    GetCurrentDesktopNumber()
    {
        return DllCall(this._getCurrentDesktopNumberProc)
    }

    GetDesktopCount()
    {
        return DllCall(this._getDesktopCountProc)
    }

    IsWindowOnDesktopNumber(windowHwnd, index)
    {
        return DllCall(this._isWindowOnDesktopNumberProc, UInt, windowHwnd, UInt, index)
    }

    MoveWindowToDesktopNumber(windowHwnd, index)
    {
        return DllCall(this._moveWindowToDesktopNumberProc, UInt, windowHwnd, UInt, index)
    }

    IsPinnedWindow(windowHwnd)
    {
        return DllCall(this._isPinnedWindowProc, UInt, windowHwnd)
    }

    PinWindow(windowHwnd)
    {
        DllCall(this._pinWindowProc, UInt, windowHwnd)
    }

    UnPinWindow(windowHwnd)
    {
        DllCall(this._unPinWindowProc, UInt, windowHwnd)
    }

    IsPinnedApp(windowHwnd)
    {
        return DllCall(this._isPinnedAppProc, UInt, windowHwnd)
    }

    PinApp(windowHwnd)
    {
        DllCall(this._pinAppProc, UInt, windowHwnd)
    }

    UnPinApp(windowHwnd)
    {
        DllCall(this._unPinAppProc, UInt, windowHwnd)
    }

}