/*
    Recupera información sobre el uso de memoria del proceso especificado.
    Parámetros:
        hProcess: El identificador del proceso, el /pid del proceso o el nombre del proceso.
    Return:
        -2       = Ha ocurrido un error al intentar abrir el proceso.
        -1       = Ha ocurrido un error al intentar recuperar la información del proceso.
        [object] = Si tuvo éxito devuelve un objeto con las siguientes claves:
            PageFaultCount             = 
            PeakWorkingSetSize         = 
            WorkingSetSize             = 
            QuotaPeakPagedPoolUsage    = 
            QuotaPagedPoolUsage        = 
            QuotaPeakNonPagedPoolUsage = 
            QuotaNonPagedPoolUsage     = 
            PageFileUsage              = 
            PeakPageFileUsage          = 
            PrivateUsage               = 
    Acceso Requerido:
        0x0400          = PROCESS_QUERY_INFORMATION.
        0x1000 | 0x0010 = PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_VM_READ.
    Ejemplo:
        MsgBox('Explorer.exe: ' . GetProcessMemoryInfo('explorer.exe').WorkingSetSize / 1024**2 . ' MB [memory\WorkingSetSize]')
*/
GetProcessMemoryInfo(hProcess)
{
    If (Type(hProcess) == 'Integer')
    {
        Local PROCESS_MEMORY_COUNTERS_EX
            , Size := 4*2 + 9*A_PtrSize

        NumPut(VarSetCapacity(PROCESS_MEMORY_COUNTERS_EX, Size, 0), &PROCESS_MEMORY_COUNTERS_EX, 'UInt')

        If (!DllCall('Psapi.dll\GetProcessMemoryInfo', 'Ptr', hProcess, 'UPtr', &PROCESS_MEMORY_COUNTERS_EX, 'UInt', Size))
            Return (-1)

        Local Process                      := {}
        Process.PageFaultCount             := NumGet(&PROCESS_MEMORY_COUNTERS_EX +   4              , 'UInt')
        Process.PeakWorkingSetSize         := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4              )
        Process.WorkingSetSize             := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 1*A_PtrSize)
        Process.QuotaPeakPagedPoolUsage    := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 2*A_PtrSize)
        Process.QuotaPagedPoolUsage        := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 3*A_PtrSize)
        Process.QuotaPeakNonPagedPoolUsage := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 4*A_PtrSize)
        Process.QuotaNonPagedPoolUsage     := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 5*A_PtrSize)
        Process.PageFileUsage              := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 6*A_PtrSize)
        Process.PeakPageFileUsage          := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 7*A_PtrSize)
        Process.PrivateUsage               := NumGet(&PROCESS_MEMORY_COUNTERS_EX + 2*4 + 8*A_PtrSize)

        Return (Process)
    }

    hProcess := SubStr(hProcess, 1, 1) == '/' ? SubStr(hProcess, 2) : ProcessExist(hProcess)
    If (!(hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1010, 'Int', FALSE, 'UInt', hProcess, 'Ptr')))
        Return (-2)

    Local OutputVar := GetProcessMemoryInfo(hProcess)
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)

    Return (OutputVar)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms683219(v=vs.85).aspx
