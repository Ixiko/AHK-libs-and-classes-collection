; ===============================================================================================================================
; Formats a number string as a number string customized for a locale specified by identifier.
; ===============================================================================================================================

GetNumberFormat(VarIn, locale := 0x0400) {
    if !(size := DllCall("GetNumberFormat", "UInt", locale, "UInt", 0, "Ptr", &VarIn, "Ptr", 0, "Ptr", 0, "Int", 0))
        throw Exception("GetNumberFormat", -1)
    VarSetCapacity(buf, size * (A_IsUnicode ? 2 : 1), 0)
    if !(DllCall("GetNumberFormat", "UInt", locale, "UInt", 0, "Ptr", &VarIn, "Ptr", 0, "Str", buf, "Int", size))
        throw Exception("GetNumberFormat", -1)
    return buf
}

; ===============================================================================================================================

;~ MsgBox % GetNumberFormat(1149.99)                  ; ==> 1.149,99         ( LANG_USER_DEFAULT | SUBLANG_DEFAULT    )
;~ MsgBox % GetNumberFormat(1149.99, 0x0409)          ; ==> 1,149.99         ( LANG_ENGLISH      | SUBLANG_ENGLISH_US )
;~ MsgBox % GetNumberFormat(1149.99, 0x0809)          ; ==> 1,149.99         ( LANG_ENGLISH      | SUBLANG_ENGLISH_UK )
;~ MsgBox % GetNumberFormat(1149.99, 0x0407)          ; ==> 1.149,99         ( LANG_GERMAN       | SUBLANG_GERMAN     )