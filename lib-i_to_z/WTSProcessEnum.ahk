; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves information about the active processes on the specified Remote Desktop Session Host (RD Session Host) server or Remote Desktop Virtualization Host (RD Virtualization Host) server.
    Parameters:
        Server:
            A handle to an Remote Desktop Session Host server.
            To indicate the server on which your application is running, specify 0 (WTS_CURRENT_SERVER_HANDLE).
        SessionId:
            The session for which to enumerate processes.
            To enumerate processes for all sessions on the server, specify -2 (WTS_ANY_SESSION).
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName           The name of the executable file associated with the process (its process's image name).
            ProcessId             The process identifier that uniquely identifies the process on the RD Session Host server.
            ThreadCount           The number of execution threads started by the process.
            HandleCount           The total number of handles being used by the process in question.
            SessionId             The Remote Desktop Services session identifier for the session associated with the process.
            UserSid               The user security identifier (SID) in the primary access token of the process (Buffer object).
            WorkingSetSize        The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize    The peak size, in bytes, of the working set of the process.
            PagefileUsage         The number of bytes of page file storage in use by the process.
            PeakPagefileUsage     The maximum number of bytes of page-file storage used by the process.
            UserTime              The amount of time, in milliseconds, the process has been running in user mode.
            KernelTime            The amount of time, in milliseconds, the process has been running in kernel mode.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
    Remarks:
        The caller must be a member of the Administrators group to enumerate processes that are running under another user session.
*/
WTSProcessEnum(Server := 0, SessionId := -2)
{
    local 

    if !DllCall("Wtsapi32.dll\WTSEnumerateProcessesExW",  "UPtr", IsObject(Server) ? Server.Handle : Server  ; HANDLE hServer,
                                                       , "UIntP", Level := 1                                 ; DWORD  *pLevel. WTS_PROCESS_INFO_EX.
                                                       ,  "UInt", SessionId                                  ; DWORD  SessionId.
                                                       , "UPtrP", pWTS_PROCESS_INFO_EX := 0                  ; LPWSTR *ppProcessInfo.
                                                       , "UIntP", Count := 0)                                ; DWORD  *pCount.
        return 0

    ProcessList := [ ]                   ; An array of associative objects containing information from each process.
    Ptr         := pWTS_PROCESS_INFO_EX  ; An array of WTS_PROCESS_INFO_EX structures.
    loop (Count)  ; The number of WTS_PROCESS_INFO_EX structures returned.
    {
        if (pUserSid := NumGet(Ptr,8+A_PtrSize))
            DllCall("Advapi32.dll\CopySid", "UInt", SidSize := DllCall("Advapi32.dll\GetLengthSid", "Ptr", pUserSid)
                                          ,  "Ptr", UserSid := BufferAlloc(SidSize)
                                          , "UPtr", pUserSid)
        ProcessList.Push( { SessionId         : NumGet(Ptr, 0, "UInt")                     ; DWORD         SessionId.
                          , ProcessId         : NumGet(Ptr, 4, "UInt")                     ; DWORD         ProcessId.
                          , ProcessName       : StrGet(NumGet(Ptr,8))                      ; LPSTR         pProcessName.
                          , UserSid           : pUserSid ? UserSid : 0                     ; PSID          pUserSid.
                          , ThreadCount       : NumGet(Ptr, 8+2*A_PtrSize, "UInt")         ; DWORD         NumberOfThreads.
                          , HandleCount       : NumGet(Ptr, 12+2*A_PtrSize, "UInt")        ; DWORD         HandleCount.
                          , PagefileUsage     : NumGet(Ptr, 16+2*A_PtrSize, "UInt")        ; DWORD         PagefileUsage.
                          , PeakPagefileUsage : NumGet(Ptr, 20+2*A_PtrSize, "UInt")        ; DWORD         PeakPagefileUsage.
                          , WorkingSetSize    : NumGet(Ptr, 24+2*A_PtrSize, "UInt")        ; DWORD         WorkingSetSize.
                          , PeakWorkingSetSize: NumGet(Ptr, 28+2*A_PtrSize, "UInt")        ; DWORD         PeakWorkingSetSize.
                          , UserTime          : NumGet(Ptr, 32+2*A_PtrSize, "UInt64")      ; LARGE_INTEGER UserTime.
                          , KernelTime        : NumGet(Ptr, 40+2*A_PtrSize, "UInt64") } )  ; LARGE_INTEGER KernelTime.
        Ptr += 48 + 2*A_PtrSize  ; Next WTS_PROCESS_INFO_EX structure.
    }

    DllCall("Wtsapi32.dll\WTSFreeMemoryExW", "Int", 1, "Ptr", pWTS_PROCESS_INFO_EX, "UInt", Count)
    return ProcessList
} ; https://docs.microsoft.com/en-us/windows/win32/api/wtsapi32/nf-wtsapi32-wtsenumerateprocessesexw