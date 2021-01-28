/*
    Recupera la ruta del proceso.
    Parámetros:
        hProcess: El identificador (HANDLE) del proceso, el /pid del proceso o el nombre del proceso.
    Return:
        -2       = Ha ocurrido un error al intentar abrir el proceso.
        -1       = Hubo un error al intentar recuperar la ruta del proceso.
        [string] = Devuelve la ruta del proceso si tuvo éxito.
    Acceso Requerido:
        0x1000 = PROCESS_QUERY_LIMITED_INFORMATION.
*/
GetProcessPath(hProcess)
{
    If (Type(hProcess) == 'Integer')
    {
        Local Buffer, R
            , Length := 2024

        VarSetCapacity(Buffer, Length * 2)
        R := DllCall('Kernel32.dll\QueryFullProcessImageNameW', 'Ptr', hProcess, 'UInt', 0, 'UPtr', &Buffer, 'UIntP', Length)

        Return (R && Length ? StrGet(&Buffer, Length, 'UTF-16') : -1)
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := GetProcessPath(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684919(v=vs.85).aspx
