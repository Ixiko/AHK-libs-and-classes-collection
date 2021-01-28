; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Opens a handle to an existing local process object and sets the access rights to this object.
    Parameters:
        Process:
            The identifier or name of the local process to be opened.
            If the specified process is the System Process (0), the function fails and the last error code is 0x00000057 (ERROR_INVALID_PARAMETER).
            If the specified process is the Idle process or one of the CSRSS processes, this function fails and the last error code is 0x00000005 (ERROR_ACCESS_DENIED) because their access restrictions prevent user-level code from opening them.
            If the specified process is the current process (-1), a "real" handle to itself is created.
        DesiredAccess:
            The access to the process object.
            This access right is checked against the security descriptor for the process.
            This parameter can be one or more of the process access rights: https://docs.microsoft.com/en-us/windows/win32/procthread/process-security-and-access-rights.
            If the caller has enabled the SeDebugPrivilege privilege, the requested access is granted regardless of the contents of the security descriptor.
            0x1F0FFF    PROCESS_ALL_ACCESS
            0x000040    PROCESS_DUP_HANDLE
            0x000400    PROCESS_QUERY_INFORMATION
            0x001000    PROCESS_QUERY_LIMITED_INFORMATION
            0x000200    PROCESS_SET_INFORMATION
            0x000100    PROCESS_SET_QUOTA
            0x000800    PROCESS_SUSPEND_RESUME
            0x000001    PROCESS_TERMINATE
            0x000008    PROCESS_VM_OPERATION
            0x000010    PROCESS_VM_READ
            0x000020    PROCESS_VM_WRITE
            0x100000    SYNCHRONIZE
        Attributes:
            0x00   The processes created by this process do not inherit the handle.
            0x02   The processes created by this process will inherit the handle.
    Return value:
        If the function succeeds, the return value is an IProcess class object instance.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    Remarks:
        To open a handle to another local process and obtain full access rights, you must enable the SeDebugPrivilege privilege.
        When all references to the returned object are released, the process handle will be closed.
*/
ProcessOpen(Process := -1, DesiredAccess := 0x1F0FFF, Attributes := 0)
{
    Process := Process       ==        -1 ? ProcessExist()  ; Current process.
             : Type(Process) == "Integer" ? Process         ; Process identifier.
             : ProcessExist(Process)                        ; Process name.

    return new IProcess(Process, DesiredAccess, Attributes)
}





class IProcess
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Handle      := 0
    CloseHandle := TRUE


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ProcessId, DesiredAccess, Attributes := 0, SecurityDescriptor := 0)
    {
        local OBJECT_ATTRIBUTES := BufferAlloc(6*A_PtrSize)  ; https://docs.microsoft.com/en-us/windows/win32/api/ntdef/ns-ntdef-_object_attributes.
        NumPut("UInt", OBJECT_ATTRIBUTES.Size, OBJECT_ATTRIBUTES)  ; ULONG           Length.
        NumPut("UPtr", 0                                           ; HANDLE          RootDirectory.
             , "UPtr", 0                                           ; PUNICODE_STRING ObjectName.
             , "UInt", Attributes, OBJECT_ATTRIBUTES, A_PtrSize)   ; ULONG           Attributes. OBJ_INHERIT = 2 (InheritHandle).
        NumPut("UPtr", SecurityDescriptor                          ; PVOID           SecurityDescriptor.
             , "UPtr", 0, OBJECT_ATTRIBUTES, 4*A_PtrSize)          ; PVOID           SecurityQualityOfService.
             
        local CLIENT_ID := BufferAlloc(2*A_PtrSize)  ; https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-tsts/a11e7129-685b-4535-8d37-21d4596ac057.
        NumPut("UPtr", ProcessId      ; HANDLE UniqueProcess.
             , "UPtr", 0, CLIENT_ID)  ; HANDLE UniqueThread.

        local hProcess := 0  ;  Unique process identifier.
        local NtStatus := DllCall("Ntdll.dll\NtOpenProcess", "UPtrP", hProcess               ; (out)PHANDLE       ProcessHandle.
                                                           ,  "UInt", DesiredAccess          ; ACCESS_MASK        DesiredAccess.
                                                           ,  "UPtr", OBJECT_ATTRIBUTES.Ptr  ; POBJECT_ATTRIBUTES ObjectAttributes.
                                                           ,  "UPtr", CLIENT_ID.Ptr          ; PCLIENT_ID         ClientId.
                                                           ,  "UInt")                        ; NTSYSAPI NTSTATUS  NTAPI.

        if (hProcess == 0)
            return !(A_LastError := NtStatus)
        this.Handle := hProcess
    } ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntddk/nf-ntddk-ntopenprocess


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    class FromHandle extends IProcess
    {
        ; ===================================================================================================================
        ; CONSTRUCTOR
        ; =================================================================================================================== 
        __New(hProcess)
        {
            ; Checks if the handle is valid.
            this.Handle := ProcessCheckHandle(hProcess)
            if (this.Handle == 0)
                return 0
        }
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        if (this.Handle && this.CloseHandle)
            DllCall("Kernel32.dll\CloseHandle", "Ptr", this.Handle)
    } ; https://docs.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Retrieves the termination status of this process.
        The handle must have the PROCESS_QUERY_LIMITED_INFORMATION access right.
        Return value:
            If the function succeeds, the return value is the process termination status.
            If the function fails, the return value is <0. To get extended error information, check A_LastError (WIN32).
    */
    GetExitCode()
    {
        local ExitCode := 0
        return DllCall("Kernel32.dll\GetExitCodeProcess", "Ptr", this.Handle, "UIntP", ExitCode)
             ? ExitCode : -A_LastError
    } ; https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getexitcodeprocess

    /*
        Terminates this process and all of its threads.
        The handle must have the PROCESS_TERMINATE access right.
        Parameters:
            ExitCode:
                The exit code to be used by the process and threads terminated as a result of this call.
        Return value:
            If the function succeeds, the return value is nonzero.
            If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    */
    Terminate(ExitCode := 0)
    {
        A_LastError := DllCall("Ntdll.dll\NtTerminateProcess", "UPtr", this.Handle
                                                             , "UInt", ExitCode
                                                             , "UInt")
        return A_LastError == 0 ? TRUE : FALSE
    } ; https://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FNT%20Objects%2FProcess%2FNtTerminateProcess.html
}





/*
    Opens the next process in relation to the specified process.
    Parameters:
        Process:
            A handle to the process.
            This parameter can be zero to start from the first process.
        DesiredAccess / HandleAttributes:
            See the ProcessOpen function.
    Return value:
        If the function succeeds, the return value is an IProcess class object.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessGetNext(Process, DesiredAccess, HandleAttributes := 0, Flags := 0)
{
    local hProcess := 0
    A_LastError := DllCall("Ntdll.dll\NtGetNextProcess",  "UPtr", IsObject(Process) ? Process.Handle : Process
                                                       ,  "UInt", DesiredAccess
                                                       ,  "UInt", HandleAttributes
                                                       ,  "UInt", Flags
                                                       , "UPtrP", hProcess
                                                       ,  "UInt")
    return hProcess ? new IProcess.FromHandle(hProcess) : 0
}





/*
    Checks whether the specified handle belongs to a process.
    Parameters:
        Handle:
            The handle to be checked.
    Return value:
        If the handle is valid, the return value is the process handle. Otherwise, it is zero.
*/
ProcessCheckHandle(Handle)
{
    return DllCall("Kernel32.dll\GetExitCodeProcess",  "UPtr", Handle := Integer(IsObject(Handle)?Handle.Handle:Handle)
                                                    , "UIntP", 0)
        || A_LastError !== 0x00000006  ; ERROR_INVALID_HANDLE = 0x00000006.
         ? Handle : 0
}





/*
    Retrieves the process identifier of the specified process.
    Parameters:
        A handle to the process.
        The handle must have the PROCESS_QUERY_LIMITED_INFORMATION access right.
    Return value:
        If the handle is valid and the process still exists, the return value is the process identifier. Otherwise, it is zero.
    Remarks:
        Until a process terminates, its process identifier uniquely identifies it on the system.
*/
ProcessGetID(Process)
{
    return DllCall("Kernel32.dll\GetProcessId", "Ptr", IsObject(Process)?Process.Handle:Process, "UInt")
} ; https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-getprocessid