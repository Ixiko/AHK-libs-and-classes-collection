;msgbox % EnumClipFormats()

EnumClipFormats() {
    DllCall("OpenClipboard"), VarSetCapacity( buf, 256 )

    Loop % DllCall("CountClipboardFormats")
    {
        fmt := DllCall("EnumClipboardFormats", uint, a_index=1?0:fmt )
        DllCall("GetClipboardFormatName", uInt, fmt, str, buf, int, 128 )
        fmts .= ((fNum:=StrGet(&buf))?fNum:fmt) "`n"
    }
    DllCall( "CloseClipboard" )

    return fmts
}