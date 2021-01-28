; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

MsgBox(OpenFolderAndSelectItems(A_WinDir, ["explorer.exe", "hh.exe", "system32"])) ;0 = OK

OpenFolderAndSelectItems(DirName, Files, Flags := 0)
{
    If (!DirExist(DirName))
        Return (-3)
    
    DirName := StrLen(DirName) < 4 ? SubStr(DirName, 1, 1) . ":" : RTrim(DirName, "\")
    Items   := []

    For Each, FileName In (IsObject(Files) ? Files : [Files])
        If (FileExist(DirName . "\" . FileName))
            Items.Push(FileName)

    If (!Items.MaxIndex())
        Return (-2)

    VarSetCapacity(ITEMLIST, Items.MaxIndex() * A_PtrSize)

    For Each, FileName In Items
    {
        DllCall("Shell32.dll\SHParseDisplayName", "Str", DirName . "\" . FileName, "Ptr", 0, "PtrP", PIDL, "UInt", 0, "Ptr", 0)
        NumPut(PIDL, ITEMLIST, (A_Index - 1) * A_PtrSize, "Ptr")
    }
    
    DllCall("Ole32.dll\CoInitializeEx", "Ptr", 0, "UInt", 0)
    DllCall("Shell32.dll\SHParseDisplayName", "Ptr", &DirName, "Ptr", 0, "PtrP", PIDL, "UInt", 0, "Ptr", 0)
    R := DllCall("Shell32.dll\SHOpenFolderAndSelectItems", "Ptr", PIDL, "UInt", Items.MaxIndex(), "Ptr", &ITEMLIST, "UInt", Flags)
    
    DllCall("Ole32.dll\CoTaskMemFree", "Ptr", PIDL)
    Loop (Items.MaxIndex())
        DllCall("Ole32.dll\CoTaskMemFree", "Ptr", NumGet(ITEMLIST, (A_Index - 1) * A_PtrSize, "Ptr"))
    DllCall("Ole32.dll\CoUninitialize")

    Return (R ? -1 : 0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb762232(v=vs.85).aspx