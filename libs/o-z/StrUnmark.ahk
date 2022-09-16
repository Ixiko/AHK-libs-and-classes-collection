; Removes marks from letters.  Requires Windows Vista or later.
StrUnmark(string) {
    len := DllCall("Normaliz.dll\NormalizeString", "int", 2
        , "wstr", string, "int", StrLen(string)
        , "ptr", 0, "int", 0)  ; Get *estimated* required buffer size.
    Loop {
        VarSetCapacity(buf, len * 2)
        len := DllCall("Normaliz.dll\NormalizeString", "int", 2
            , "wstr", string, "int", StrLen(string)
            , "ptr", &buf, "int", len)
        if len >= 0
            break
        if (A_LastError != 122) ; ERROR_INSUFFICIENT_BUFFER
            return
        len *= -1  ; This is the new estimate.
    }
    ; Remove combining marks and return result.
    return RegExReplace(StrGet(&buf, len, "UTF-16"), "\pM")
}