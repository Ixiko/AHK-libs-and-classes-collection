StrGet(Address, Length=-1, Encoding=0)
{
    if A_IsUnicode
    {
        MsgBox %A_ThisFunc% does not support Unicode. Use the AutoHotkey_L (revision 46+) built-in version instead. The script will now exit.
        ExitApp
    }
    
    ; Flexible parameter handling:
    if Length is not integer
        Encoding := Length,  Length := -1
    
    ; Check for obvious errors.
    if (Address+0 < 1024)
        return
    
    ; Ensure 'Encoding' contains a numeric identifier.
    if Encoding = UTF-16
        Encoding = 1200
    else if Encoding = UTF-8
        Encoding = 65001
    else if SubStr(Encoding,1,2)="CP"
        Encoding := SubStr(Encoding,3)
    
    if !Encoding ; "" or 0
    {
        ; No conversion necessary, but we might not want the whole string.
        if (Length == -1)
            Length := DllCall("lstrlen", "uint", Address)
        VarSetCapacity(String, Length)
        DllCall("lstrcpyn", "str", String, "uint", Address, "int", Length + 1)
    }
    else if Encoding = 1200 ; UTF-16
    {
        char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "uint", 0, "uint", 0, "uint", 0, "uint", 0)
        VarSetCapacity(String, char_count)
        DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", Length, "str", String, "int", char_count, "uint", 0, "uint", 0)
    }
    else if Encoding is integer
    {
        ; Convert from target encoding to UTF-16 then to the active code page.
        char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", 0, "int", 0)
        VarSetCapacity(String, char_count * 2)
        char_count := DllCall("MultiByteToWideChar", "uint", Encoding, "uint", 0, "uint", Address, "int", Length, "uint", &String, "int", char_count * 2)
        String := StrGet(&String, char_count, 1200)
    }
    return String
}