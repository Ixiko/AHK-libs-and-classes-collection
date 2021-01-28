; https://autohotkey.com/board/topic/20376-invoking-directly-contextmenu-of-files-and-folders/

ShellContextMenu(sPath, hWnd := 0) {
    If (!sPath) {
        Return
    }

    If (!hWnd) {
        Gui SHELL_CONTEXT: New, +hWndhWnd
        Gui Show
    }

    If sPath Is Not Integer
        DllCall("shell32.dll\SHParseDisplayName", "WStr", sPath, "Ptr", 0, "Ptr*", pidl, "UInt", 0, "UInt*", 0)
        ; This function is the preferred method to convert a string to a pointer to an item identifier list (PIDL).
    Else
        DllCall("shell32.dll\SHGetFolderLocation", "Ptr", 0, "Int", sPath, "Ptr", 0, "UInt", 0, "Ptr*", pidl)

    DllCall("shell32.dll\SHBindToParent", "Ptr", pidl, "Ptr", GUID4String(IID_IShellFolder, "{000214E6-0000-0000-C000-000000000046}"), "Ptr*", pIShellFolder, "Ptr*", pidlChild)

    ;IShellFolder->GetUIObjectOf
    DllCall(VTable(pIShellFolder, 10), "Ptr", pIShellFolder, "Ptr", 0, "UInt", 1, "Ptr*", pidlChild, "Ptr", GUID4String(IID_IContextMenu, "{000214E4-0000-0000-C000-000000000046}"), "Ptr", 0, "Ptr*", pIContextMenu)
    ObjRelease(pIShellFolder)

    DllCall("ole32.dll\CoTaskMemFree", "Ptr", pidl)

    hMenu := DllCall("CreatePopupMenu", "Ptr")

    ; IContextMenu->QueryContextMenu
    ; http://msdn.microsoft.com/en-us/library/bb776097%28v=VS.85%29.aspx
    DllCall(VTable(pIContextMenu, 3), "Ptr", pIContextMenu, "Ptr", hMenu, "UInt", 0, "UInt", 3, "UInt", 0x7FFF, "UInt", 0x100) ; CMF_EXTENDEDVERBS
    ComObjError(0)
    Global pIContextMenu2 := ComObjQuery(pIContextMenu, IID_IContextMenu2 := "{000214F4-0000-0000-C000-000000000046}")
    Global pIContextMenu3 := ComObjQuery(pIContextMenu, IID_IContextMenu3 := "{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
    e := A_LastError ; GetLastError()
    ComObjError(1)
    If (e != 0) {
        GoTo StopContextMenu
    }

    Global WPOld := DllCall("SetWindowLongPtr", "Ptr", hWnd, "Int", -4, "Ptr", RegisterCallback("WindowProc"), "UPtr") ; GWL_WNDPROC

    VarSetCapacity(pt, 8, 0)
    DllCall("GetCursorPos", "Int64*", pt)
    ;DllCall("InsertMenu", "Ptr", hMenu, "UInt", 0, "UInt", 0x0400|0x800, "Ptr", 2, "Ptr", 0)
    ;DllCall("InsertMenu", "Ptr", hMenu, "UInt", 0, "UInt", 0x0400|0x002, "Ptr", 1, "Ptr", &sPath)

    idn := DllCall("TrackPopupMenuEx", "Ptr", hMenu, "UInt", 0x0100 | 0x0001, "Int", pt << 32 >> 32, "Int", pt >> 32, "Ptr", hWnd, "UInt", 0)

    /*
    typedef struct _CMINVOKECOMMANDINFOEX {
    DWORD   cbSize;          0
    DWORD   fMask;           4
    HWND    hwnd;            8
    LPCSTR  lpVerb;          8+A_PtrSize
    LPCSTR  lpParameters;    8+2*A_PtrSize
    LPCSTR  lpDirectory;     8+3*A_PtrSize
    int     nShow;           8+4*A_PtrSize
    DWORD   dwHotKey;        12+4*A_PtrSize
    HANDLE  hIcon;           16+4*A_PtrSize
    LPCSTR  lpTitle;         16+5*A_PtrSize
    LPCWSTR lpVerbW;         16+6*A_PtrSize
    LPCWSTR lpParametersW;   16+7*A_PtrSize
    LPCWSTR lpDirectoryW;    16+8*A_PtrSize
    LPCWSTR lpTitleW;        16+9*A_PtrSize
    POINT   ptInvoke;        16+10*A_PtrSize
    } CMINVOKECOMMANDINFOEX, *LPCMINVOKECOMMANDINFOEX;
    https://msdn.microsoft.com/en-us/library/bb773217(v=VS.85).aspx
    */
    NumPut(VarSetCapacity(pici, 16 + 11 * A_PtrSize, 0), pici, 0, "UInt") ; cbSize
    NumPut(0x4000 | 0x20000000 | 0x00100000, pici, 4, "UInt") ; fMask
    NumPut(hWnd, pici, 8, "UPtr") ; hwnd
    NumPut(1, pici, 8 + 4 * A_PtrSize, "UInt") ; nShow
    NumPut(idn - 3, pici, 8 + A_PtrSize,"UPtr") ; lpVerb
    NumPut(idn - 3, pici, 16 + 6 * A_PtrSize, "UPtr") ; lpVerbW
    NumPut(pt, pici, 16 + 10 * A_PtrSize, "UPtr") ; ptInvoke

    DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &pici) ; InvokeCommand

    DllCall("GlobalFree", "Ptr", DllCall("SetWindowLongPtr", "Ptr", hWnd, "Int", -4, "Ptr", WPOld, "UPtr"))
    DllCall("DestroyMenu", "Ptr", hMenu)

    StopContextMenu:
    ObjRelease(pIContextMenu3)
    ObjRelease(pIContextMenu2)
    ObjRelease(pIContextMenu)
    pIContextMenu2:=pIContextMenu3:=WPOld:=0
    Gui SHELL_CONTEXT: Destroy

    Return idn
}

WindowProc(hWnd, nMsg, wParam, lParam) {
    Global pIContextMenu2, pIContextMenu3, WPOld

    If (pIContextMenu3) {
        ; IContextMenu3->HandleMenuMsg2
        If !(DllCall(VTable(pIContextMenu3, 7), "Ptr", pIContextMenu3, "UInt", nMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)) {
            Return lResult
        }
    } Else If (pIContextMenu2) {
        ; IContextMenu2->HandleMenuMsg
        If !(DllCall(VTable(pIContextMenu2, 6), "Ptr", pIContextMenu2, "UInt", nMsg, "Ptr", wParam, "Ptr", lParam)) {
            Return 0
        }
    }

    Return DllCall("user32.dll\CallWindowProcW", "Ptr", WPOld, "Ptr", hWnd, "UInt", nMsg, "Ptr", wParam, "Ptr", lParam)
}

VTable(ppv, idx) {
    Return NumGet(NumGet(1 * ppv) + A_PtrSize * idx)
}

GUID4String(ByRef CLSID, String) {
    VarSetCapacity(CLSID, 16, 0)
    Return DllCall("ole32.dll\CLSIDFromString", "WStr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}
