/*
    Determina si el proceso especificado se está ejecutando bajo WOW64, en otras palabras, si el proceso es de 32-bits y el sistema es de 64-bits.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
    Return:
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar recuperar la información del proceso.
         0 = El proceso esta funcionando bajo WOW64 (el proceso es de 32-Bits y el sistema de 64-Bits).
         1 = El proceso no esta funcionando bajo WOW64 (el proceso y el sistema son de 64-Bits) o el sistema es de 32-Bits.
    Acceso Requerido:
        0x1000 = PROCESS_QUERY_LIMITED_INFORMATION.
*/
IsWow64Process(hProcess)
{
    If (Type(hProcess) == 'Integer')
    {
        Local Wow64Process
            , R := DllCall('Kernel32.dll\IsWow64Process', 'Ptr', hProcess, 'IntP', Wow64Process)

        Return (R == 0 ? -1 : (Wow64Process ? 0 : 1))
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := IsWow64Process(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684139(v=vs.85).aspx
