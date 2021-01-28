/*
    Suspende el proceso especificado.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
    Return:
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar suspender el proceso.
         0 = El proceso se ha suspendido correctamente.
    Acceso Requerido:
        0x0800 = PROCESS_SUSPEND_RESUME.
*/
SuspendProcess(hProcess)
{
    If (Type(hProcess) == 'Integer')
        Return (DllCall('Ntdll.dll\NtSuspendProcess', 'Ptr', hProcess) == 0 ? -1 : 0)
    
    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0800, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := SuspendProcess(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
}
