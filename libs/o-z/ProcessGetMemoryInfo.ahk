; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves information about the memory usage of the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_LIMITED_INFORMATION and PROCESS_VM_READ access rights.
    Return value:
        If the function succeeds, the return value is an associative object (Map) with the following keys:
            WorkingSetSize                The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize            The peak size, in bytes, of the working set of the process.
            QuotaPagedPoolUsage           The current quota charged to the process for paged pool usage, in bytes.
            QuotaPeakPagedPoolUsage       The peak paged pool usage, in bytes.
            QuotaNonPagedPoolUsage        The current quota charged to the process for nonpaged pool usage, in bytes.
            QuotaPeakNonPagedPoolUsage    The peak nonpaged pool usage, in bytes.
            PagefileUsage                 The number of bytes of page file storage in use by the process.
            PeakPagefileUsage             The maximum number of bytes of page-file storage used by the process.
            PageFaultCount                The number of page faults.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessGetMemoryInfo(Process) {
    local PROCESS_MEMORY_COUNTERS_EX := BufferAlloc(8+9*A_PtrSize)
    NumPut("UInt", PROCESS_MEMORY_COUNTERS_EX.Size, PROCESS_MEMORY_COUNTERS_EX)  ; DWORD  cb.
    if !DllCall("Psapi.dll\GetProcessMemoryInfo", "UPtr", IsObject(Process) ? Process.Handle : Process
                                                , "UPtr", PROCESS_MEMORY_COUNTERS_EX.Ptr
                                                , "UInt", PROCESS_MEMORY_COUNTERS_EX.Size)
        return 0

    local MemoryInfo := { PageFaultCount            : NumGet(PROCESS_MEMORY_COUNTERS_EX,             4, "UInt")    ; DWORD  PageFaultCount.
                        , PeakWorkingSetSize        : NumGet(PROCESS_MEMORY_COUNTERS_EX,             8, "UPtr")    ; SIZE_T PeakWorkingSetSize.
                        , WorkingSetSize            : NumGet(PROCESS_MEMORY_COUNTERS_EX,   8+A_PtrSize, "UPtr")    ; SIZE_T WorkingSetSize.
                        , QuotaPeakPagedPoolUsage   : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+2*A_PtrSize, "UPtr")    ; SIZE_T QuotaPeakPagedPoolUsage.
                        , QuotaPagedPoolUsage       : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+3*A_PtrSize, "UPtr")    ; SIZE_T QuotaPagedPoolUsage.
                        , QuotaPeakNonPagedPoolUsage: NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+4*A_PtrSize, "UPtr")    ; SIZE_T QuotaPeakNonPagedPoolUsage.
                        , QuotaNonPagedPoolUsage    : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+5*A_PtrSize, "UPtr")    ; SIZE_T QuotaNonPagedPoolUsage.
                        , PagefileUsage             : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+6*A_PtrSize, "UPtr")    ; SIZE_T PagefileUsage.
                        , PeakPagefileUsage         : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+7*A_PtrSize, "UPtr")    ; SIZE_T PeakPagefileUsage.
                        , PrivateUsage              : NumGet(PROCESS_MEMORY_COUNTERS_EX, 8+8*A_PtrSize, "UPtr") }  ; SIZE_T PrivateUsage.

    return MemoryInfo
}