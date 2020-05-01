; ===============================================================================================================================
; Function......: QueryPerformanceFrequency
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms644905.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms644905.aspx
; ===============================================================================================================================
QueryPerformanceFrequency()
{
    if !(DllCall("kernel32.dll\QueryPerformanceFrequency", "Int64*", Frequency))
        return DllCall("kernel32.dll\GetLastError")
    return Frequency
}
; ===============================================================================================================================

MsgBox % QueryPerformanceFrequency()


DllCall("kernel32.dll\QueryPerformanceFrequency", "Int64*", F)
DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", S)
loop 10000000
    i++
DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", E)
MsgBox % (E - S) / F





/* C++ ==========================================================================================================================
BOOL WINAPI QueryPerformanceFrequency(                                               // UInt
    _Out_  LARGE_INTEGER *lpFrequency                                                // Int64*
);
============================================================================================================================== */