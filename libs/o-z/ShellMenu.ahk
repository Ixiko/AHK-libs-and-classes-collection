GetShellContextMenu(sPath, Flags := 0, IDFirst := 1, IDLast := 0x7FFF) {
    Local pidl, IID_IShellFolder, pIShellFolder, pidlChild, IID_IContextMenu, hMenu, e

    If (DllCall("shell32.dll\SHParseDisplayName", "WStr", sPath, "Ptr", 0, "Ptr*", pidl, "UInt", 0, "UInt*", 0)) {
        Return 0
    }

    DllCall("shell32.dll\SHBindToParent", "Ptr", pidl, "Ptr", GUID4String(IID_IShellFolder, "{000214E6-0000-0000-C000-000000000046}"), "Ptr*", pIShellFolder, "Ptr*", pidlChild)

    ; IShellFolder->GetUIObjectOf
    DllCall(VTable(pIShellFolder, 10), "Ptr", pIShellFolder, "Ptr", 0, "UInt", 1, "Ptr*", pidlChild, "Ptr", GUID4String(IID_IContextMenu, "{000214E4-0000-0000-C000-000000000046}"), "Ptr", 0, "Ptr*", g_pIContextMenu)
    ObjRelease(pIShellFolder)

    DllCall("ole32.dll\CoTaskMemFree", "Ptr", pidl)

    hMenu := DllCall("CreatePopupMenu", "Ptr")

    ; IContextMenu->QueryContextMenu
    DllCall(VTable(g_pIContextMenu, 3), "Ptr", g_pIContextMenu, "Ptr", hMenu, "UInt", 0, "UInt", IDFirst, "UInt", IDLast, "UInt", Flags)
    ComObjError(0)
    g_pIContextMenu2 := ComObjQuery(g_pIContextMenu, "{000214F4-0000-0000-C000-000000000046}") ; IID_IContextMenu2
    g_pIContextMenu3 := ComObjQuery(g_pIContextMenu, "{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}") ; IID_IContextMenu3
    e := A_LastError
    ComObjError(1)
    If (e != 0) {
        DestroyShellMenu(hMenu)
        Return 0
    }

    Return hMenu
}

DestroyShellMenu(hMenu) {
    DllCall("DestroyMenu", "Ptr", hMenu)
    ReleaseIContextMenu()
}

ReleaseIContextMenu() {
    ObjRelease(g_pIContextMenu3)
    ObjRelease(g_pIContextMenu2)
    ObjRelease(g_pIContextMenu)
    g_pIContextMenu2 := g_pIContextMenu3 := 0
}

RunShellMenuCommand(pIContextMenu, Cmd, WorkingDir := "", hWnd := 0, X := 0, Y := 0, IDFirst := 1, Verb := False) {
    Local CmdName, Directory, x64 := A_PtrSize == 8

    If (Verb) {
        VarSetCapacity(CmdName, StrPut(Cmd, "UTF-16") * 2, 0)
        StrPut(Cmd, &CmdName, "UTF-16")
        Cmd := &CmdName
    } Else {
        Cmd := Cmd - IDFirst
    }

    Directory := WorkingDir != "" ? &WorkingDir : 0

    ; CMINVOKECOMMANDINFOEX
    NumPut(VarSetCapacity(CMICI, x64 ? 104 : 64, 0), CMICI, 0, "UInt") ; cbSize
    ; Mask flags: CMIC_MASK_UNICODE | CMIC_MASK_ASYNCOK | CMIC_MASK_PTINVOKE
    NumPut(0x4000 | 0x100000 | 0x20000000, CMICI, 4, "UInt") ; fMask
    NumPut(hWnd, CMICI, 8, "UPtr") ; hWnd
    NumPut(1, CMICI, x64 ? 40 : 24, "UInt") ; nShow
    NumPut(Cmd, CMICI, x64 ? 16 : 12, "UPtr") ; lpVerb
    NumPut(Cmd, CMICI, x64 ? 64 : 40, "UPtr") ; lpVerbW
    NumPut(Directory, CMICI, x64 ? 32 : 20, "Ptr") ; lpDirectory
    NumPut(Directory, CMICI, x64 ? 80 : 48, "Ptr") ; lpDirectoryW
    NumPut(X, CMICI, x64 ? 96 : 56, "Int") ; ptInvoke
    NumPut(Y, CMICI, x64 ? 100 : 60, "Int")

    Return DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &CMICI) ; InvokeCommand
}

CreateShellMenuWindow(ClassName := "ShellWnd", WndProc := "ShellWndProc") {
    Local hWnd, WNDCLASS

    VarSetCapacity(WNDCLASS, A_PtrSize == 8 ? 72 : 40, 0)
    NumPut(RegisterCallback(WndProc, "F"), WNDCLASS, A_PtrSize == 8 ? 8 : 4, "Ptr")
    NumPut(&ClassName, WNDCLASS, A_PtrSize == 8 ? 64 : 36, "Ptr")

    If (!DllCall("RegisterClass", "Ptr", &WNDCLASS)) {
        MsgBox 0x10, Error, Failed to register window class.
        Return 0
    }

    hWnd := DllCall("CreateWindowEx", "UInt" , 0, "Str", ClassName, "Str", "", "UInt", 0
         , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")

    If (!hWnd) {
        MsgBox 0x10, Error, Failed to create window.
        Return 0
    }

    Return hWnd
}

ShellWndProc(hWnd, uMsg, wParam, lParam) {
    Global g_pIContextMenu2, g_pIContextMenu3

    If (g_pIContextMenu3) {
        ; IContextMenu3->HandleMenuMsg2
        If !(DllCall(VTable(g_pIContextMenu3, 7), "Ptr", g_pIContextMenu3, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)) {
            Return lResult
        }
    } Else If (g_IContextMenu2) {
        ; IContextMenu2->HandleMenuMsg
        If !(DllCall(VTable(g_pIContextMenu2, 6), "Ptr", g_pIContextMenu2, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)) {
            Return 0
        }
    }

    Return DllCall("DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam, "Ptr")
}

ShowPopupMenu(hMenu, Flags, X, Y, hWnd) {
    Return DllCall("TrackPopupMenuEx", "Ptr", hMenu, "UInt", Flags, "Int", X, "Int", Y, "Ptr", hWnd, "Ptr", 0)
}

VTable(ppv, idx) {
    Return NumGet(NumGet(1 * ppv) + A_PtrSize * idx)
}

GUID4String(ByRef CLSID, String) {
    VarSetCapacity(CLSID, 16, 0)
    Return DllCall("ole32.dll\CLSIDFromString", "WStr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}

GetShellMenuItemVerb(pIContextMenu, ItemID, IDFirst := 1, Unicode := True) { ; GCS_VERBW
    Local Verb
    VarSetCapacity(Verb, 256, 0)

    ; IContextMenu->GetCommandString
    If (DllCall(VTable(pIContextMenu, 5), "Ptr", pIContextMenu, "UPtr", ItemID - IDFirst
    , "UInt", Unicode ? 4 : 0, "UInt", 0, "Str", Verb, "UInt", 256)) {
        Return ""
    }

    Return StrGet(&Verb, 256, Unicode ? "UTF-16" : "CP0")
}

PasteFile(Dir) {
    Local SEI

    If (!InStr(FileExist(Dir), "D", 1)) {
        Return 0
    }

    NumPut(VarSetCapacity(SEI, A_PtrSize == 8 ? 112 : 60, 0), SEI, 0, "UInt") ; SHELLEXECUTEINFO
    NumPut(0x400C, SEI, 4, "UInt") ; fMask (SEE_MASK_UNICODE | SEE_MASK_INVOKEIDLIST)
    NumPut(&Verb := "paste", SEI, A_PtrSize == 8 ? 16 : 12, "Ptr")
    NumPut(&Dir := Dir, SEI, A_PtrSize == 8 ? 24 : 16, "Ptr")
    Return DllCall("Shell32.dll\ShellExecuteExW", "Ptr", &SEI)
}
