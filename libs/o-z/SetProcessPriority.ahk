/*
    Establece la clase de prioridad para el proceso especificado.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
        Priority: La nueva prioridad para el proceso. Este parámetro puede ser uno de los siguientes valores/palabras:
            0x40   / Low         = Prioridad baja.
            0x4000 / BelowNormal = Prioridad por debajo de lo normal.
            0x20   / Normal      = Prioridad normal.
            0x8000 / AboveNormal = Prioridad por arriba de lo normal.
            0x80   / High        = Prioridad alta.
            0x100  / RealTime    = Prioridad tiempo real.
    Return:
        -2 = Ha ocurrido un error al intentar abrir el proceso.
        -1 = Ha ocurrido un error al intentar cambiar la prioridad del proceso.
         0 = La prioridad se ha establecido correctamente.
    Acceso Requerido:
        0x0200 = PROCESS_SET_INFORMATION.
*/
SetProcessPriority(hProcess, Priority)
{
    If (Type(hProcess) == 'Integer')
    {
        If (Type(Priority) == 'String')
            Priority := {Low: 0x40, BelowNormal: 0x4000, Normal: 0x20, AboveNormal: 0x8000, High: 0x80, RealTime: 0x100}[Priority]

        Return (DllCall('Kernel32.dll\SetPriorityClass', 'Ptr', hProcess, 'UInt', Priority) ? 0 : -1)
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x0200, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := SetProcessPriority(hProcess, Priority)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms686219(v=vs.85).aspx
