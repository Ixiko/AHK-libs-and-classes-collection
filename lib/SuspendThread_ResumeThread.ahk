; ===============================================================================================================================
; Suspends and resume the specified thread.
; ===============================================================================================================================


SuspendThread(ThreadID)
{
    if !(hThread := DllCall("OpenThread", "uint", 0x0002, "int", 0, "uint", ThreadID, "ptr"))
        throw Exception("OpenThread", -1)
    if (DllCall("SuspendThread", "ptr", hThread) = -1)
        throw Exception("SuspendThread", -1), DllCall("CloseHandle", "ptr", hThread)
    return true, DllCall("CloseHandle", "ptr", hThread)
}


Wow64SuspendThread(ThreadID)
{
    if !(hThread := DllCall("OpenThread", "uint", 0x0002, "int", 0, "uint", ThreadID, "ptr"))
        throw Exception("OpenThread", -1)
    if (DllCall("Wow64SuspendThread", "ptr", hThread) = -1)
        throw Exception("Wow64SuspendThread", -1), DllCall("CloseHandle", "ptr", hThread)
    return true, DllCall("CloseHandle", "ptr", hThread)
}


ResumeThread(ThreadID)
{
    if !(hThread := DllCall("OpenThread", "uint", 0x0002, "int", 0, "uint", ThreadID, "ptr"))
        throw Exception("OpenThread", -1)
    if (DllCall("ResumeThread", "ptr", hThread) = -1)
        throw Exception("ResumeThread", -1), DllCall("CloseHandle", "ptr", hThread)
    return true, DllCall("CloseHandle", "ptr", hThread)
}