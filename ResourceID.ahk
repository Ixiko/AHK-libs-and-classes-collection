; https://autohotkey.com/board/topic/27668-how-to-get-the-icon-group-number/
ResourceIdOfIcon(Filename, IconIndex) {

    hMod := DllCall("GetModuleHandle", "Str", Filename, "Ptr")
    ; If the DLL isn't already loaded, load it as a data file.
    Loaded := !hMod
        && hMod := DllCall("LoadLibraryEx", "Str", Filename, "UInt", 0, "UInt", 0x2)
    
    If (!hMod) {
        Return
    }

    EnumProc := RegisterCallback("ResourceIdOfIcon_EnumIconResources", "F")

    VarSetCapacity(Param, 16, 0)
    NumPut(IconIndex, Param, 0)
    ; Enumerate the icon group resources. (RT_GROUP_ICON = 14)
    DllCall("kernel32.dll\EnumResourceNames", "UInt", hMod, "UInt", 14, "UInt", EnumProc, "UInt", &Param)
    DllCall("GlobalFree", "UInt", EnumProc)
    
    If (Loaded) {
        DllCall("FreeLibrary", "UInt", hMod)
    }

    Return NumGet(Param, 0) ? NumGet(Param, A_PtrSize) : ""
}

ResourceIdOfIcon_EnumIconResources(hModule, lpszType, lpszName, lParam) {
    Local Index := NumGet(lParam + A_PtrSize)

    If (Index == NumGet(lParam + 0)) {
        NumPut(lpszName, lParam + A_PtrSize)
        NumPut(1, lParam + 0)
        Return False ; break
    }

    NumPut(Index + 1, lParam + A_PtrSize)
    Return True
}
