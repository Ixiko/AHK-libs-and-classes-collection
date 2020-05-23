StrPut(String, Address="", Length=-1, Encoding=0)
{
    if A_IsUnicode
    {
        MsgBox %A_ThisFunc% does not support Unicode. Use the AutoHotkey_L (revision 46+) built-in version instead. The script will now exit.
        ExitApp
    }
    
    ; Flexible parameter handling:
    if Address is not integer       ; StrPut(String [, Encoding])
        Encoding := Address,  Length := 0,  Address := 1024
    else if Length is not integer   ; StrPut(String, Address, Encoding)
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
        ; No conversion required.
        char_count := StrLen(String) + 1 ; + 1 because generally a null-terminator is wanted.
        if (Length)
        {
            ; Check for sufficient buffer space.
            if (StrLen(String) <= Length || Length == -1)
            {
                if (StrLen(String) == Length)
                    ; Exceptional case: caller doesn't want a null-terminator.
                    char_count--
                ; Copy the string, including null-terminator if requested.
                DllCall("RtlMoveMemory", "uint", Address, "uint", &String, "uint", char_count)
            }
            else
                ; For consistency with the sections below, don't truncate the string.
                char_count = 0
        }
        ;else: Caller just wants the the required buffer size (char_count), which will be returned below.
    }
    else if Encoding = 1200 ; UTF-16
    {
        ; See the 'else' to this 'if' below for comments.
        if (Length <= 0)
        {
            char_count := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &String, "int", StrLen(String), "uint", 0, "int", 0) + 1
            if (Length == 0)
                return char_count
            Length := char_count
        }
        char_count := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &String, "int", StrLen(String), "uint", Address, "int", Length)
        if (char_count && char_count < Length)
            NumPut(0, Address+0, char_count++*2, "UShort")
    }
    else if Encoding is integer
    {
        ; Convert native ANSI string to UTF-16 first.  NOTE - wbuf_len includes the null-terminator.
        VarSetCapacity(wbuf, 2 * wbuf_len := StrPut(String, "UTF-16")), StrPut(String, &wbuf, "UTF-16")
        
        ; UTF-8 and some other encodings do not support this flag.  Avoid it for UTF-8
        ; (which is probably common) and rely on the fallback behaviour for other encodings.
        flags := Encoding=65001 ? 0 : 0x400  ; WC_NO_BEST_FIT_CHARS
        if (Length <= 0) ; -1 or 0
        {
            ; Determine required buffer size.
            loop 2 {
                char_count := DllCall("WideCharToMultiByte", "uint", Encoding, "uint", flags, "uint", &wbuf, "int", wbuf_len, "uint", 0, "int", 0, "uint", 0, "uint", 0)
                if (char_count || A_LastError != 1004) ; ERROR_INVALID_FLAGS
                    break
                flags := 0  ; Try again without WC_NO_BEST_FIT_CHARS.
            }
            if (!char_count)
                return ; FAIL
            if (Length == 0) ; Caller just wants the required buffer size.
                return char_count
            ; Assume there is sufficient buffer space and hope for the best:
            Length := char_count
        }
        ; Convert to target encoding.
        char_count := DllCall("WideCharToMultiByte", "uint", Encoding, "uint", flags, "uint", &wbuf, "int", wbuf_len, "uint", Address, "int", Length, "uint", 0, "uint", 0)
        ; Since above did not null-terminate, check for buffer space and null-terminate if there's room.
        ; It is tempting to always null-terminate (potentially replacing the last byte of data),
        ; but that would exclude this function as a means to copy a string into a fixed-length array.
        if (char_count && char_count < Length)
            NumPut(0, Address+0, char_count++, "Char")
        ; else no space to null-terminate; or conversion failed.
    }
    ; Return the number of characters copied.
    return char_count
}