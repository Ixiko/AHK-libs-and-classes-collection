/*
    Recupera la dirección base de la estructura PEB en el proceso especificado.
    Parámetros:
        hProcess: El identificador (HANDLE) del proceso.
    Acceso requerido:
        PROCESS_QUERY_LIMITED_INFORMATION (0x1000).
*/
GetProcessPebAddr(hProcess)
{
    ; NtQueryInformationProcess function
    ; https://msdn.microsoft.com/en-us/library/ms684280%28VS.85%29.aspx
    Local PROCESS_BASIC_INFORMATION
        , Size := A_PtrSize == 4 ? 24 : 48
    VarSetCapacity(PROCESS_BASIC_INFORMATION, Size, 0)
    If (DllCall('Ntdll.dll\NtQueryInformationProcess', 'Ptr'  , hProcess                   ;ProcessHandle
                                                     , 'UInt' , 0                          ;ProcessInformationClass  --> ProcessBasicInformation
                                                     , 'UPtr' , &PROCESS_BASIC_INFORMATION ;ProcessInformation       --> &PROCESS_BASIC_INFORMATION
                                                     , 'UInt' , Size                       ;ProcessInformationLength --> sizeof(PROCESS_BASIC_INFORMATION)
                                                     , 'UIntP', Size                       ;ReturnLength
                                                     , 'UInt'))                            ;ReturnType               --> NTSTATUS success or error code
        Return (FALSE)

    ; PEB structure
    ; https://msdn.microsoft.com/en-us/library/aa813706(v=vs.85).aspx
    Return (NumGet(&PROCESS_BASIC_INFORMATION + A_PtrSize)) ;PROCESS_BASIC_INFORMATION.PebBaseAddress
}
