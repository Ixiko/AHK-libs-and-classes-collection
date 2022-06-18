StringReverse(str) {
    static rev := A_IsUnicode ? "_wcsrev" : "_strrev"
    DllCall("msvcrt.dll\" rev, "Ptr", &str, "CDECL")
    return str
}

;MsgBox % StringReverse("01234 56789")        ; ==> 98765 43210