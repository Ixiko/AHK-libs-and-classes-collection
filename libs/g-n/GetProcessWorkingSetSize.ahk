/*
    Recupera el tamaño mínimo y máximo del espacio de trabajo del proceso especificado.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
    Return:
        -2       = Ha ocurrido un error al intentar abrir el proceso.
        -1       = Ha ocurrido un error al intentar recuperar la información del proceso.
        [object] = Si tuvo éxito devuelve un objeto con las siguientes claves:
            MinimumWorkingSetSize = Tamaño mínimo del espacio de trabajo del proceso.
            MaximumWorkingSetSize = Tamaño máximo del espacio de trabajo del proceso.
    Acceso Requerido:
        0x1000 = PROCESS_QUERY_LIMITED_INFORMATION.
*/
GetProcessWorkingSetSize(hProcess)
{
    If (Type(hProcess) == 'Integer')
    {
        Local MinimumWorkingSetSize, MaximumWorkingSetSize

        If (!DllCall('Kernel32.dll\GetProcessWorkingSetSize', 'Ptr', hProcess, 'UPtrP', MinimumWorkingSetSize, 'UPtrP', MaximumWorkingSetSize))
            Return (-1)

        Return ({MinimumWorkingSetSize: MinimumWorkingSetSize, MaximumWorkingSetSize: MaximumWorkingSetSize})
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := GetProcessWorkingSetSize(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms683226(v=vs.85).aspx
