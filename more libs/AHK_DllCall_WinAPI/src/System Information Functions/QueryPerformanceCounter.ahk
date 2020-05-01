; ===============================================================================================================================
; Function......: QueryPerformanceCounter
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........:
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/ms644904.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/ms644904.aspx
; ===============================================================================================================================
QueryPerformanceCounter()
{
    if !(DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", PerformanceCount))
        return DllCall("kernel32.dll\GetLastError")
    return PerformanceCount
}
; ===============================================================================================================================

MsgBox % QueryPerformanceCounter()


DllCall("kernel32.dll\QueryPerformanceFrequency", "Int64*", F)
DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", S)
loop 10000000
    i++
DllCall("kernel32.dll\QueryPerformanceCounter", "Int64*", E)
MsgBox % (E - S) / F





/* C++ ==========================================================================================================================
BOOL WINAPI QueryPerformanceCounter(                                                 // UInt
    _Out_  LARGE_INTEGER *lpPerformanceCount                                         // Int64*
);
============================================================================================================================== */