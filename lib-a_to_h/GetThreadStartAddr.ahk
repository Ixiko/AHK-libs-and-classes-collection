; ===============================================================================================================================
; Gets the start address of a thread
; ===============================================================================================================================

GetThreadStartAddr(ProcessID)
{
    hModule := DllCall("LoadLibrary", "str", "ntdll.dll", "uptr")

    if !(hSnapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x4, "uint", ProcessID))
        throw Exception("CreateToolhelp32Snapshot", -1)

    NumPut(VarSetCapacity(THREADENTRY32, 28, 0), THREADENTRY32, "uint")
    if !(DllCall("Thread32First", "ptr", hSnapshot, "ptr", &THREADENTRY32))
        throw Exception("Thread32First", -1), DllCall("CloseHandle", "ptr", hSnapshot)

    Addr := {}, index := 1
    while (DllCall("Thread32Next", "ptr", hSnapshot, "ptr", &THREADENTRY32)) {
        if (NumGet(THREADENTRY32, 12, "uint") = ProcessID) {
            hThread := DllCall("OpenThread", "uint", 0x0040, "int", 0, "uint", NumGet(THREADENTRY32, 8, "uint"), "ptr")
            if (DllCall("ntdll\NtQueryInformationThread", "ptr", hThread, "uint", 9, "ptr*", ThreadStartAddr, "uint", A_PtrSize, "uint*", 0) != 0)
                throw Exception("NtQueryInformationThread", -1), DllCall("CloseHandle", "ptr", hThread) && DllCall("FreeLibrary", "ptr", hModule)
            Addr[index, "StartAddr"] := Format("{:#016x}", ThreadStartAddr)
            Addr[index, "ThreadID"]  := NumGet(THREADENTRY32, 8, "uint")
            DllCall("CloseHandle", "ptr", hThread), index++
        }
    }

    return Addr, DllCall("CloseHandle", "ptr", hSnapshot) && DllCall("FreeLibrary", "ptr", hModule)
}

; ===============================================================================================================================

OwnPID   := DllCall("GetCurrentProcessId")
MsgBox % "StartAddr of first Thread:`t" GetThreadStartAddr(OwnPID)[1].StartAddr
; 0x000001400adf08


for k, v in GetThreadStartAddr(OwnPID)                                             
    MsgBox % "ThreadID:`t`t" v.ThreadID "`nStartAddr:`t`t" v.StartAddr
; ThreadID:     14160             |  11544             |  9596              |  2408
; StartAddr:    0x000001400adf08  |  0x007ffa84ec2800  |  0x007ffa84ec2800  |  0x007ffa84ec2800