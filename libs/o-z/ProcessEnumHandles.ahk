; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Enumerates all open handles in the system.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessId          The process identifier that uniquely identifies the process.
            Handle             The object handle.
            GrantedAccess      Specifies the granted access for the handle.
            Attributes         Bitmask of flags that specify object handle attributes. This member can contain one or more of the following flags:
                0x00000002  OBJ_INHERIT                          This handle can be inherited by child processes of the current process.
                0x00000010  OBJ_PERMANENT                        https://docs.microsoft.com/en-us/windows/win32/api/ntdef/ns-ntdef-_object_attributes
                0x00000020  OBJ_EXCLUSIVE                        //
                0x00000040  OBJ_CASE_INSENSITIVE                 //
                0x00000080  OBJ_OPENIF                           //
                0x00000100  OBJ_OPENLINK                         //
                0x00000200  OBJ_KERNEL_HANDLE                    The handle is created in system process context and can only be accessed from kernel mode.
                0x00000400  OBJ_FORCE_ACCESS_CHECK               The routine that opens the handle should enforce all access checks for the object, even if the handle is being opened in kernel mode.
                0x00000800  OBJ_IGNORE_IMPERSONATED_DEVICEMAP    
                0x00001000  OBJ_DONT_REPARSE                    
                0x00001FF2  OBJ_VALID_ATTRIBUTES
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessEnumHandles()
{
    local NtStatus, Buffer
    while (NtStatus := DllCall("Ntdll.dll\NtQuerySystemInformation",  "Int", 64                                      ; SYSTEM_INFORMATION_CLASS SystemInformationClass. SystemExtendedHandleInformation = 64.
                                                                   ,  "Ptr", Buffer := BufferAlloc(A_Index*0x7A120)  ; (out)PVOID               SystemInformation.
                                                                   , "UInt", Buffer.Size                             ; ULONG                    SystemInformationLength.
                                                                   , "UPtr", 0                                       ; (out)PULONG              ReturnLength.
                                                                   , "UInt")) == 0xC0000004                          ; STATUS_INFO_LENGTH_MISMATCH = 0xC0000004.
        continue

    if (NtStatus == 0x00000000)  ; STATUS_SUCCESS = 0x00000000.
    {
        Buffer := {Buffer:Buffer, Ptr:Buffer.Ptr, Size:Buffer.Size}  ; SYSTEM_HANDLE_INFORMATION_EX structure.
        local HandleList := [ ]  ; An array of associative objects (Map) containing handle information for each process.     
        loop ( NumGet(Buffer) )  ; ULONG_PTR SYSTEM_HANDLE_INFORMATION_EX.NumberOfHandles.
        {
            HandleList.Push( { Object       : NumGet(Buffer,   2*A_PtrSize, "UPtr")      ; PVOID     Object.
                             , ProcessId    : NumGet(Buffer,   3*A_PtrSize, "UPtr")      ; ULONG_PTR UniqueProcessId.
                             , Handle       : NumGet(Buffer,   4*A_PtrSize, "UPtr")      ; ULONG_PTR HandleValue.
                             , GrantedAccess: NumGet(Buffer,   5*A_PtrSize, "UInt")      ; ULONG     GrantedAccess.
                             , Attributes   : NumGet(Buffer, 8+5*A_PtrSize, "UInt") } )  ; ULONG     HandleAttributes.
            Buffer.Ptr += 16 + (3*A_PtrSize)  ; sizeof(SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX).
        }
    }

    A_LastError := NtStatus
    return NtStatus == 0x00000000 ? HandleList : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntquerysysteminformation





/*
    Enumerates all open handles in the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_INFORMATION access right.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            Handle             The object handle.
            HandleCount
            PointerCount
            GrantedAccess      Specifies the granted access for the handle.
            ObjTypeIndex
            Attributes         See the ProcessEnumHandles function.    
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    Remarks:
        This function is only available starting with Windows 8.
*/
ProcessEnumHandles2(Process)  ; WIN_8+
{
    local NtStatus, Buffer
    while (NtStatus := DllCall("Ntdll.dll\NtQueryInformationProcess", "UPtr", IsObject(Process)?Process.Handle:Process  ; HANDLE           ProcessHandle.
                                                                    ,  "Int", 51                                        ; PROCESSINFOCLASS ProcessInformationClass. ProcessHandleInformation = 51.
                                                                    ,  "Ptr", Buffer := BufferAlloc(A_Index*0x30D40)    ; (out)PVOID       ProcessInformation. InitialBufferSize = 0x30D40.
                                                                    , "UInt", Buffer.Size                               ; ULONG            ProcessInformationLength.
                                                                    , "UPtr", 0                                         ; (out)PULONG      ReturnLength.
                                                                    , "UInt")) == 0xC0000004                            ; STATUS_INFO_LENGTH_MISMATCH = 0xC0000004.
        continue

    if (NtStatus == 0x00000000)  ; STATUS_SUCCESS = 0x00000000.
    {
        Buffer := {Buffer:Buffer, Ptr:Buffer.Ptr, Size:Buffer.Size}  ; PROCESS_HANDLE_SNAPSHOT_INFORMATION structure.
        local HandleList := [ ]  ; An array of associative objects (Map) containing handle information for the specified process.
        loop ( NumGet(Buffer) )  ; ULONG_PTR PROCESS_HANDLE_SNAPSHOT_INFORMATION.NumberOfHandles.
        {
            HandleList.Push( { Handle       : NumGet(Buffer,   2*A_PtrSize, "UPtr")      ; ULONG_PTR HandleValue.
                             , HandleCount  : NumGet(Buffer,   3*A_PtrSize, "UPtr")      ; ULONG_PTR HandleCount.
                             , PointerCount : NumGet(Buffer,   4*A_PtrSize, "UPtr")      ; ULONG_PTR PointerCount.
                             , GrantedAccess: NumGet(Buffer,   5*A_PtrSize, "UInt")      ; ULONG GrantedAccess.
                             , ObjTypeIndex : NumGet(Buffer, 4+5*A_PtrSize, "UInt")      ; ULONG ObjectTypeIndex.
                             , Attributes   : NumGet(Buffer, 8+5*A_PtrSize, "UInt") } )  ; ULONG HandleAttributes.
            Buffer.Ptr += 16 + (3*A_PtrSize)  ; sizeof(PROCESS_HANDLE_TABLE_ENTRY_INFO).
        }
    }

    A_LastError := NtStatus
    return NtStatus == 0x00000000 ? HandleList : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntqueryinformationprocess