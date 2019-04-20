#Include GetProcessPebAddr.ahk

/*
    Recupera la línea de comandos que inició al proceso especificado.
    Parámetros:
        hProcess: El identificador (HANDLE) del proceso, el /pid del proceso o el nombre del proceso.
    Referencia:
        https://wj32.org/wp/2009/01/24/howto-get-the-command-line-of-processes/
    Ejemplo:  
        MsgBox(GetProcessCommandLine('/' . ProcessExist()))
*/
GetProcessCommandLine(hProcess)
{
    If (Type(hProcess) == 'Integer')
    {
        Local pPEB, pUPP

        If (!(pPEB := GetProcessPebAddr(hProcess)))
            Return (FALSE)

        If (!(pUPP := RTL_USER_PROCESS_PARAMETERS_From_PEB(hProcess, pPEB)))
            Return (FALSE)

        /*
            typedef struct _UNICODE_STRING
            {
                USHORT Length;
                USHORT MaximumLength;
                PWSTR Buffer;
            } UNICODE_STRING, *PUNICODE_STRING;
        */
        Local Length
        If (!DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr'    , hProcess                                 ;PROCESS_VM_READ
                                                     , 'UPtr'   , pUPP + 16 + A_PtrSize*10 + A_PtrSize * 2 ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Length
                                                     , 'UShortP', Length                                   ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Length
                                                     , 'UPtr'   , 2                                        ;sizeof(RTL_USER_PROCESS_PARAMETERS.CommandLine.Buffer)
                                                     , 'UPtrP'  , 0))                                      ;lpNumberOfBytesRead
            Return (FALSE)

        Local pBuffer
        If (!DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr'  , hProcess                                 ;PROCESS_VM_READ
                                                     , 'UPtr' , pUPP + 16 + A_PtrSize*10 + A_PtrSize * 3 ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Buffer
                                                     , 'UPtrP', pBuffer                                  ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Buffer
                                                     , 'UPtr' , A_PtrSize                                ;sizeof(ptr)
                                                     , 'UPtrP', 0))                                      ;lpNumberOfBytesRead
            Return (FALSE)

        Local CommandLine
        VarSetCapacity(CommandLine, Length)
        If (!DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr'  , hProcess       ;PROCESS_VM_READ
                                                     , 'UPtr' , pBuffer        ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Buffer
                                                     , 'UPtr' , &CommandLine   ;RTL_USER_PROCESS_PARAMETERS.CommandLine.Buffer
                                                     , 'UPtr' , Length         ;sizeof(RTL_USER_PROCESS_PARAMETERS.ImagePathName.Buffer)
                                                     , 'UPtrP', 0))            ;lpNumberOfBytesRead
            Return (FALSE)

        Return (StrGet(&CommandLine, Length, 'UTF-16'))
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000|0x10, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := GetProcessCommandLine(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
}




RTL_USER_PROCESS_PARAMETERS_From_PEB(hProcess, pPEB)
{
    ; RTL_USER_PROCESS_PARAMETERS structure
    ; https://msdn.microsoft.com/en-us/library/aa813741%28v=VS.85%29.aspx
    Local pPRTL_USER_PROCESS_PARAMETERS
    If (!DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr'  , hProcess                          ;hProcess            --> PROCESS_VM_READ
                                                 , 'UPtr' , pPEB + (A_PtrSize == 4 ? 16 : 32) ;lpBaseAddress       --> PEB.ProcessParameters
                                                 , 'UPtrP', pPRTL_USER_PROCESS_PARAMETERS     ;lpBuffer            --> PEB.ProcessParameters
                                                 , 'UPtr' , A_PtrSize                         ;nSize               --> sizeof(ptr)
                                                 , 'UPtrP', 0))                               ;lpNumberOfBytesRead
        Return (FALSE)

    Return (pPRTL_USER_PROCESS_PARAMETERS)
}
