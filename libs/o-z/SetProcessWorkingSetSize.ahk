/*
    Establece el tamaño mínimo y máximo del espacio de trabajo del proceso especificado.
    Parámetros:
        hProcess             : El identificador del proceso, el /pid del proceso o el nombre del proceso.
        MinimumWorkingSetSize: El mínimo tamaño de conjunto de trabajo para el proceso, en bytes. este parámetro debe ser >0 pero <= que el tamaño máximo del conjunto de trabajo
        MaximumWorkingSetSize: El máximo tamaño del conjunto de trabajo para el proceso, en bytes. debe ser >= a 13 páginas pero < que la de todo el sistema máximo disponible -512 páginas
    Return:
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar establecer la información del proceso.
         0 = La información se estableció correctamente.
    Acceso Requerido:
        0x0100 = PROCESS_SET_QUOTA.
*/
SetProcessWorkingSetSize(hProcess, MinimumWorkingSetSize := -1, MaximumWorkingSetSize := -1)
{
    If (Type(hProcess) == 'Integer')
        Return (DllCall('Kernel32.dll\SetProcessWorkingSetSize', 'Ptr', hProcess, 'UPtr', MinimumWorkingSetSize, 'UPtr', MaximumWorkingSetSize) ? 0 : -1)

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := SetProcessWorkingSetSize(hProcess, MinimumWorkingSetSize, MaximumWorkingSetSize)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms686234(v=vs.85).aspx
