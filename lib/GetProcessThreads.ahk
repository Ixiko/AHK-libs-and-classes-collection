; ===============================================================================================================================
; Gets a list of threads in a process
; ===============================================================================================================================

GetProcessThreads(ProcessID)
{
    if !(hSnapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x4, "uint", ProcessID))
        throw Exception("CreateToolhelp32Snapshot", -1)

    NumPut(VarSetCapacity(THREADENTRY32, 28, 0), THREADENTRY32, "uint")
    if !(DllCall("Thread32First", "ptr", hSnapshot, "ptr", &THREADENTRY32))
        throw Exception("Thread32First", -1), DllCall("CloseHandle", "ptr", hSnapshot)

    Threads := []
    while (DllCall("Thread32Next", "ptr", hSnapshot, "ptr", &THREADENTRY32))
        if (NumGet(THREADENTRY32, 12, "uint") = ProcessID)
            Threads.Push(NumGet(THREADENTRY32, 8, "uint"))

    return Threads, DllCall("CloseHandle", "ptr", hSnapshot)
}

; ===============================================================================================================================

OwnPID   := DllCall("GetCurrentProcessId")
for k, v in GetProcessThreads(OwnPID)                                             
    MsgBox % "ThreadID:`t`t" v
; ThreadID:     6408    |    7112    |    11052    |    4760