; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Closes an object handle in the specified process.
    Parameters:
        Handle.
            Handle to an object of any type.
        SourceProcess:
             A handle to the source process for the handle being closed.
             If this parameter is zero, specifies that the handle belongs to this process.
    Return value:
        The return value is zero (STATUS_SUCCESS) on success, or the appropriate NTSTATUS error code on failure.
        0xC0000008  STATUS_INVALID_HANDLE         The handle is not valid.
        0xC0000235  STATUS_HANDLE_NOT_CLOSABLE    The calling thread does not have permission to close the handle.
    NTSTATUS Error Code List:
        https://davidvielmetter.com/tips/ntstatus-error-code-list/
*/
HandleClose(Handle, SourceProcess := 0)
{
    return SourceProcess == 0
         ? DllCall("Ntdll.dll\NtClose", "Ptr", Handle, "UInt")
         : DllCall("Ntdll.dll\NtDuplicateObject", "Ptr", SourceProcess, "Ptr", Handle, "Ptr", 0, "Ptr", 0, "UInt", 0, "UInt", 0, "UInt", 1, "UInt")
} ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/ntifs/nf-ntifs-ntclose





/*
    Creates a handle that is a duplicate of the specified source handle.
    Parameters:
        TargetProcess:
            A handle to the target process that is to receive the new handle.
            This parameter can be zero if the DUPLICATE_CLOSE_SOURCE flag is set in Flags.
        SourceProcess:
            A handle to the source process for the handle being duplicated.
        SourceHandle:
            The handle to duplicate.
        DesiredAccess:
            Specifies the desired access for the new handle.
            Reference: https://docs.microsoft.com/windows-hardware/drivers/kernel/access-mask.
        HandleAttributes:
            Specifies the desired attributes for the new handle.
            Reference: https://docs.microsoft.com/windows/desktop/api/ntdef/ns-ntdef-_object_attributes.
        Flags:
            A set of flags to control the behavior of the duplication operation.
            Set this parameter to zero or to the bitwise OR of one or more of the following flags.
            0x00000001  DUPLICATE_CLOSE_SOURCE       Close the source handle. The return value is «SourceHandle» if successful and «TargetProcess» is zero.
            0x00000002  DUPLICATE_SAME_ACCESS        Instead of using the DesiredAccess parameter, copy the access rights from the source handle to the target handle.
            0x00000004  DUPLICATE_SAME_ATTRIBUTES    Instead of using the HandleAttributes parameter, copy the attributes from the source handle to the target handle.
    Return value:
        If the function succeeds, the return value is the new duplicated handle. The duplicated handle is valid in the specified target process.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    To close a handle in a process, call the function as follows:
        ZeroOrSourceHandle     := ObjectDuplicate(            0, SourceProcess, SourceHandle, 0, 0, 0x00000001)  ; Opt #1.
        ZeroOrDuplicatedHandle := ObjectDuplicate(TargetProcess, SourceProcess, SourceHandle, 0, 0, 0x00000001)  ; Opt #2.
        NtStatus               := HandleClose(SourceHandle, SourceProcess)                                       ; Opt #3.
*/
ObjectDuplicate(TargetProcess, SourceProcess, SourceHandle, DesiredAccess := 0, HandleAttributes := 0, Flags := 0)
{
    local TargetHandle := 0
    local NtStatus := DllCall("Ntdll.dll\NtDuplicateObject",  "UPtr", IsObject(SourceProcess) ? SourceProcess.Handle : SourceProcess
                                                           ,  "UPtr", IsObject(SourceHandle)  ? SourceHandle.Handle  : SourceHandle
                                                           ,  "UPtr", IsObject(TargetProcess) ? TargetProcess.Handle : TargetProcess
                                                           , "UPtrP", TargetHandle
                                                           ,  "UInt", DesiredAccess
                                                           ,  "UInt", HandleAttributes
                                                           ,  "UInt", Flags
                                                           ,  "UInt")
    A_LastError := NtStatus
    return (Flags & 0x00000001) ? (NtStatus ? 0 : (TargetProcess?TargetHandle:SourceHandle)) : TargetHandle
}





/*
    Provides information about a supplied object.
    Parameters:
        Handle:
            A handle to the object to obtain information about.
        InformationClass:
            The type of information returned in the «ObjectInformation» buffer.
            0  ObjectBasicInformation
            1  ObjectNameInformation
            2  ObjectTypeInformation
        ObjectInformation:
            A Buffer object that receives the requested information.
        ReturnLength:
            Receives the size, in bytes, of the requested key information.
            If this function returns zero (STATUS_SUCCESS), the variable contains the amount of data returned.
            If this function returns 0x80000005 (STATUS_BUFFER_OVERFLOW) or 0xC0000023 (STATUS_BUFFER_TOO_SMALL), this value can be used to determine the required buffer size.
    Return value:
        If the function succeeds, the return value is «ObjectInformation».
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
            0xC0000022  STATUS_ACCESS_DENIED           There were insufficient permissions to perform this query.
            0xC0000008  STATUS_INVALID_HANDLE          The supplied object handle is invalid.
            0xC0000004  STATUS_INFO_LENGTH_MISMATCH    The info length is not sufficient to hold the data.
*/
ObjectQuery(Handle, InformationClass, ObjectInformation, ByRef ReturnLength := 0)
{
    A_LastError := DllCall("Ntdll.dll\NtQueryObject",  "UPtr", Handle                  ; HANDLE                   Handle.
                                                    ,  "UInt", InformationClass        ; OBJECT_INFORMATION_CLASS ObjectInformationClass.
                                                    ,   "Ptr", ObjectInformation       ; (out)PVOID               ObjectInformation.
                                                    ,  "UInt", ObjectInformation.Size  ; ULONG                    ObjectInformationLength.
                                                    , "UIntP", ReturnLength            ; (out)PULONG              ReturnLength.
                                                    ,  "UInt")                         ; NTSTATUS.
    return A_LastError == 0 ? ObjectInformation : 0
}