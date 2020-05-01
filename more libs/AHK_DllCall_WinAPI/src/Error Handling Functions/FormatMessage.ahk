; ===============================================================================================================================
; Function......: FormatMessage
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: FormatMessageW (Unicode) and FormatMessageA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms679351.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms679351.aspx
; ===============================================================================================================================
FormatMessage(MessageId)
{
    static size := 2024, init := VarSetCapacity(buf, size)
    if !(DllCall("kernel32.dll\FormatMessage", "UInt", 0x1000, "Ptr", 0, "UInt", MessageId, "UInt", 0x0800, "Ptr", &buf, "UInt", size, "UInt*", 0))
        return DllCall("kernel32.dll\GetLastError")
    return StrGet(&buf)
}
; ===============================================================================================================================

MsgBox % DeleteFile("C:\Temp\TestFile.txt")

DeleteFile(FileName)
{
    if !(DllCall("kernel32.dll\DeleteFile", "Str", FileName))
        return FormatMessage(DllCall("kernel32.dll\GetLastError"))
    return 1
}





/* C++ ==========================================================================================================================
DWORD WINAPI FormatMessage(                                                          // UInt
    _In_      DWORD dwFlags,                                                         // UInt
    _In_opt_  LPCVOID lpSource,                                                      // Ptr
    _In_      DWORD dwMessageId,                                                     // UInt
    _In_      DWORD dwLanguageId,                                                    // UInt
    _Out_     LPTSTR lpBuffer,                                                       // Ptr
    _In_      DWORD nSize,                                                           // UInt
    _In_opt_  va_list *Arguments                                                     // UInt
);
============================================================================================================================== */