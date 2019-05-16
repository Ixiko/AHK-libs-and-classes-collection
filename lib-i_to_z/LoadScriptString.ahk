;   Type: MAKEINTRESOURCE(10)   RT_RCDATA/Application-defined resource (raw data).

; scriptResource = a text file stored in RCDATA
; if 0
;   FileInstall, script.ahk, Ignore
; LoadScriptString("script.ahk")
LoadScriptString(scriptResource)
{
    lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
    res := DllCall("FindResource", "ptr", lib, "str", scriptResource, "ptr", Type := 10, "ptr")
    DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
    hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
    if (data := DllCall("LockResource", "ptr", hresdata, "ptr"))
        return StrGet(data, DataSize, "UTF-8")    ; Retrieve text, assuming UTF-8 encoding.
    else return 0 

}

/*
Lexikos Original
LoadScriptResource(Name, ByRef DataSize = 0, Type = 10)
{
    lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
    res := DllCall("FindResource", "ptr", lib, "str", Name, "ptr", Type, "ptr")
    DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
    hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
    return DllCall("LockResource", "ptr", hresdata, "ptr")
}
*/