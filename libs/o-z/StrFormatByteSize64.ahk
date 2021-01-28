; ===============================================================================================================================
; Converts a numeric value into a string that represents the number expressed as a size value in bytes, kilobytes,
; megabytes, or gigabytes, depending on the size.
; ===============================================================================================================================

StrFormatByteSizeEx(int) {
    static size := StrLen(buf := "0123456789ABCDEF")
    if !(pstr := DllCall("shlwapi.dll\StrFormatByteSize64A", "int64", int, "str", buf, "uint", size, "astr"))
        throw Exception("StrFormatByteSize64 failed: " pstr, -1)
    return pstr
}

; ===============================================================================================================================

;MsgBox % StrFormatByteSizeEx(2400016)         ; -> 2.28 MB

; 2400016 / 1024 / 1024  ->  2.28883361816