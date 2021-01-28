; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	Flipeador
; Date:   	2019-07-14
; for:     	AHK_L

/
/*
    Retrieves the process identifier for each process object running in the system.
    Parameters:
        Max:
            The maximum number of processes to retrieve. By default it retrieves the first 500.
    Return value:
        If the function succeeds, the return value is an array of process identifiers (may be empty).
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessEnum(Max := 500) {
    local Buffer := BufferAlloc(4*Max), Size := 0, Processes := [ ]
    if !DllCall("Psapi.dll\EnumProcesses", "Ptr", Buffer, "UInt", Buffer.Size, "UIntP", Size)
        return 0
    loop (Size // 4)
        Processes.Push( NumGet(Buffer,4*(A_Index-1),"UInt") )
    return Processes
} ; https://docs.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-enumprocesses