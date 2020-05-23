ResourceIdOfIcon(Filename, IconIndex)
{
    hmod := DllCall("GetModuleHandle", "str", Filename)
    ; If the DLL isn't already loaded, load it as a data file.
    loaded := !hmod
        && hmod := DllCall("LoadLibraryEx", "str", Filename, "uint", 0, "uint", 0x2)

    if !hmod
        return

    enumproc := RegisterCallback("_EnumIconResources","F")
    VarSetCapacity(param,12,0), NumPut(IconIndex,param,0)
    ; Enumerate the icon group resources. (RT_GROUP_ICON=14)
    DllCall("EnumResourceNames", "uint", hmod, "uint", 14, "uint", enumproc, "uint", ¶m)
    DllCall("GlobalFree", "uint", enumproc)

    ; If we loaded the DLL, free it now.
    if loaded
        DllCall("FreeLibrary", "uint", hmod)

    return NumGet(param,8) ? NumGet(param,4) : ""
}

_EnumIconResources(hModule, lpszType, lpszName, lParam)
{
    index := NumGet(lParam+4)
    if (index = NumGet(lParam+0))
    {   ; for named resources, lpszName might not be valid once we return (?)
        ; if (lpszName >> 16 == 0), lpszName is an integer resource ID.
        NumPut(lpszName, lParam+4)
        NumPut(1, lParam+8)
        return false    ; break
    }
    NumPut(index+1, lParam+4)
    return true
}