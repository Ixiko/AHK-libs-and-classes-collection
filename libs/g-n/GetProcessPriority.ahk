/*
    Recupera la clase de prioridad para el proceso especificado.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
        Priority: Recibe la prioridad del proceso como una palabra (solo si la función tuvo éxito). Puede ser una de las siguientes palabras:
            Low         = Prioridad baja.
            BelowNormal = Prioridad por debajo de lo normal.
            Normal      = Prioridad normal.
            AboveNormal = Prioridad por arriba de lo normal.
            High        = Prioridad alta.
            RealTime    = Prioridad tiempo real.
    Return:
        -2     = Ha ocurrido un error al intentar abrir el proceso.
        -1     = Ha ocurrido un error al intentar recuperar la prioridad del proceso.
        0x40   = Prioridad baja.
        0x4000 = Prioridad por debajo de lo normal.
        0x20   = Prioridad normal.
        0x8000 = Prioridad por arriba de lo normal.
        0x80   = Prioridad alta.
        0x100  = Prioridad tiempo real.
    Acceso Requerido:
        0x1000 = PROCESS_QUERY_LIMITED_INFORMATION.
    Observaciones:
        Si la función falla, 'Priority' no se establece.
    Ejemplo:
        MsgBox('Explorer.exe: ' . GetProcessPriority('explorer.exe', Priority) . ' (' . Priority . ')')
*/
GetProcessPriority(hProcess, ByRef Priority := '')
{
    If (Type(hProcess) == 'Integer')
    {
        Local P

        If (!(P := DllCall('Kernel32.dll\GetPriorityClass', 'Ptr', hProcess, 'UInt')))
            Return (-1)

        If (IsByRef(Priority))
            Priority := {0x40: 'Low', 0x4000: 'BelowNormal', 0x20: 'Normal', 0x8000: 'AboveNormal', 0x80: 'High', 0x100: 'RealTime'}[P]

        Return (P)
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := GetProcessPriority(hProcess, Priority)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms683211(v=vs.85).aspx
