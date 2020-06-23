; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves a list with information for each process object running in the system.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName               The name of the executable file associated with the process (its process's image name).
            ProcessId                 The process identifier that uniquely identifies the process.
            ParentProcessId           The identifier of the process that created this process (its parent process).
            BasePriority              The base priority of the process, which is the starting priority for threads created within the associated process.
            ThreadCount               The number of execution threads started by the process.
            HandleCount               The total number of handles being used by the process in question.
            SessionId                 The session identifier for the session associated with the process.
            WorkingSetSize            The size, in bytes, of the current working set of the process.
            PeakWorkingSetSize        The peak size, in bytes, of the working set of the process.
            VirtualSize               The current size, in bytes, of virtual memory used by the process.
            PeakVirtualSize           The peak size, in bytes, of the virtual memory used by the process.
            PagefileUsage             The number of bytes of page file storage in use by the process.
            PeakPagefileUsage         The maximum number of bytes of page-file storage used by the process.
            PrivatePageCount          The number of memory pages allocated for the use of this process.
            QuotaPagedPoolUsage       The current quota charged to the process for paged pool usage, in bytes.
            QuotaNonPagedPoolUsage    The current quota charged to the process for nonpaged pool usage, in bytes.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessGetList2()
{
    local Buffer   := BufferAlloc(1000000)  ; 1MB - I think it's enough space, we avoid two calls to NtQuerySystemInformation.
    local NtStatus := DllCall("Ntdll.dll\NtQuerySystemInformation", "Int", 5, "Ptr", Buffer, "UInt", Buffer.Size, "UIntP", 0, "UInt")

    if (NtStatus == 0)  ; STATUS_SUCCESS = 0.
    {
        local ProcessList     := []          ; An array of associative objects containing information from each process.
        local Ptr             := Buffer.Ptr  ; Pointer to structure SYSTEM_PROCESS_INFORMATION / SYSTEM_PROCESSES_INFORMATION (same data).
        local NextEntryOffset := 0           ; The start of the next item in the array is the address of the previous item plus the value in the NextEntryOffset member.

        loop
        {
            ProcessList.Push( { ThreadCount           : NumGet(Ptr, 4, "UInt")                                       ; ULONG     NumberOfThreads.
                              , ProcessName           : StrGet(NumGet(Ptr,56+A_PtrSize),NumGet(Ptr+56,"UShort")//2)  ; ImageName.Buffer (UNICODE_STRING structure).
                              , BasePriority          : NumGet(Ptr, 56+2*A_PtrSize, "UInt")                          ; KPRIORITY BasePriority.
                              , ProcessId             : NumGet(Ptr, 56+3*A_PtrSize, "UPtr")                          ; HANDLE    UniqueProcessId.
                              , ParentProcessId       : NumGet(Ptr, 56+4*A_PtrSize, "UPtr")                          ; PVOID     Reserved2/InheritedFromUniqueProcessId.
                              , HandleCount           : NumGet(Ptr, 56+5*A_PtrSize, "UInt")                          ; ULONG     HandleCount.
                              , SessionId             : NumGet(Ptr, 60+5*A_PtrSize, "UInt")                          ; ULONG     SessionId.
                              , PeakVirtualSize       : NumGet(Ptr, 64+6*A_PtrSize, "UPtr")                          ; SIZE_T    PeakVirtualSize.
                              , VirtualSize           : NumGet(Ptr, 64+7*A_PtrSize, "UPtr")                          ; SIZE_T    VirtualSize.
                              , PeakWorkingSetSize    : NumGet(Ptr, 64+9*A_PtrSize, "UPtr")                          ; SIZE_T    PeakWorkingSetSize.
                              , WorkingSetSize        : NumGet(Ptr, 64+10*A_PtrSize, "UPtr")                         ; SIZE_T    WorkingSetSize.
                              , QuotaPagedPoolUsage   : NumGet(Ptr, 64+12*A_PtrSize, "UPtr")                         ; SIZE_T    QuotaPagedPoolUsage.
                              , QuotaNonPagedPoolUsage: NumGet(Ptr, 64+14*A_PtrSize, "UPtr")                         ; SIZE_T    QuotaNonPagedPoolUsage.
                              , PagefileUsage         : NumGet(Ptr, 64+15*A_PtrSize, "UPtr")                         ; SIZE_T    PagefileUsage.
                              , PeakPagefileUsage     : NumGet(Ptr, 64+16*A_PtrSize, "UPtr")                         ; SIZE_T    PeakPagefileUsage.
                              , PrivatePageCount      : NumGet(Ptr, 64+17*A_PtrSize, "UPtr") } )                     ; SIZE_T    PrivatePageCount.
        }
        until (  (Ptr += (NextEntryOffset:=NumGet(Ptr,"UInt")))  ==  (Ptr-NextEntryOffset)  )                        ; ULONG     NextEntryOffset.
    }

    return (A_LastError := NtStatus) ? 0 : ProcessList
} ; https://docs.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntquerysysteminformation