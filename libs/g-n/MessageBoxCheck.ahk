MessageBoxCheck(Text, Title := "", Options := 0, RegVal := "", Owner := 0) {
    If (DllCall("GetVersion") & 0xFF < 6) {
        hModule := DllCall("GetModuleHandle", "Str", "shlwapi.dll", "Ptr")
        SHMessageBoxCheck := DllCall("GetProcAddress", "Ptr", hModule, "UInt", (A_IsUnicode) ? 191 : 185, "Ptr")
    } Else {
        SHMessageBoxCheck := "Shlwapi\SHMessageBoxCheck"
    }
    
    Ret := DllCall(SHMessageBoxCheck
        , "Ptr" , Owner ? Owner : DllCall("GetDesktopWindow", "Ptr")
        , "Str" , Text
        , "Str" , Title
        , "UInt", Options
        , "int" , 0
        , "Str" , (RegVal != "") ? RegVal : A_ScriptFullPath)

    Return {0: "Suppressed", 1: "OK", 2: "Cancel", 3: "Abort", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again", 11: "Continue"}[Ret]
}