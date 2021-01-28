/*
    Finaliza el proceso especificado y todos sus subprocesos (threads).
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
        ExitCode: El código de salida para ser utilizado por el proceso y los subprocesos finalizados como resultado de esta llamada.
    Return:
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar finalizar el proceso.
         0 = El proceso ha sido finalizado con éxito.
    Acceso Requerido:
        0x0001 = PROCESS_TERMINATE.
    Ejemplo:
        MsgBox(TerminateProcess('Notepad.exe'))
*/
TerminateProcess(hProcess, ExitCode := 0)
{
    If (Type(hProcess) == 'Integer')
        Return (DllCall('Kernel32.dll\TerminateProcess', 'Ptr', hProcess, 'UInt', ExitCode) == 0 ? -1 : 0)

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0001, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := TerminateProcess(hProcess, ExitCode)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms686714(v=vs.85).aspx
