; ===============================================================================================================================
; Converts a numeric value into a string that represents the number in bytes, kilobytes, megabytes, or gigabytes,
; depending on the size. Extends StrFormatByteSizeW by offering the option to round to the nearest displayed digit
; or to discard undisplayed digits.
; ===============================================================================================================================

StrFormatByteSizeEx(int, flags := 0x2) {
    size := VarSetCapacity(buf, 0x0104, 0)
    if (DllCall("shlwapi.dll\StrFormatByteSizeEx", "int64", int, "int", flags, "str", buf, "uint", size) != 0)
        throw Exception("StrFormatByteSizeEx failed", -1)
    return buf
}

; ===============================================================================================================================

;~ MsgBox % StrFormatByteSizeEx(2400016)         ; -> 2.28 MB
;~ MsgBox % StrFormatByteSizeEx(2400016, 0x1)    ; -> 2.29 MB

; 2400016 / 1024 / 1024  ->  2.28883361816