/*
    Recupera una lista con información de todos los procesos activos en el sistema.
    Return:
        -2      = Ha ocurrido un error al intentar recuperar una lista de los procesos activos en el sistema.
        -1      = Ha ocurrido un error al intentar recuperar información de los procesos.
        [array] = Devuelve un Array con todos los procesos si tuvo éxito. Cada índice tiene un objeto con las siguientes claves:
            ProcessId       = El identificador único del proceso.
            ParentProcessId = El identificador único del proceso padre de este proceso, si lo tiene.
            ProcessName     = El nombre del proceso.
            Threads         = La cantidad de Threads iniciados por este proceso.
    Ejemplo:
        For Each, Obj In EnumerateProcesses()
            List .= Obj.ProcessName . ' [' . Obj.ProcessId . ']`n'
        MsgBox(List)
*/
EnumerateProcesses()
{
    Local hSnapshot, PROCESSENTRY32, OutputVar, Info

    If ((hSnapshot := DLLCall('Kernel32.dll\CreateToolhelp32Snapshot', 'UInt', 2, 'UInt', 0, 'Ptr')) == -1)
        Return (-2)
    
    NumPut(VarSetCapacity(PROCESSENTRY32, A_PtrSize == 4 ? 556 : 568, 0), &PROCESSENTRY32, 'UInt')
    
    If (DllCall('Kernel32.dll\Process32FirstW', 'Ptr', hSnapshot, 'UPtr', &PROCESSENTRY32))
    {
        OutputVar := []

        Loop
        {
            Info                 := {}
            Info.ProcessId       := NumGet(&PROCESSENTRY32 +                          8, 'UInt')
            Info.ParentProcessId := NumGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 24 : 32), 'UInt')
            Info.ProcessName     := StrGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 36 : 44), 'UTF-16')
            Info.Threads         := NumGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 20 : 28), 'UInt')
            OutputVar[A_Index]   := Info
        }
        Until (!DllCall('Kernel32.dll\Process32NextW', 'Ptr', hSnapshot, 'UPtr', &PROCESSENTRY32))
    }
    
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
    
    Return (OutputVar ? OutputVar : -1)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684834(v=vs.85).aspx




/*
                                              32-bit (A/U)               64-bit (A/U)
    typedef struct tagPROCESSENTRY32 {        size     offset            size     offset
      DWORD     dwSize;                       4        0                 4        0
      DWORD     cntUsage;                     4        4                 4        4
      DWORD     th32ProcessID;                4        8                 4        8
    64-bit alignment                          0        12                4        12          *
      ULONG_PTR th32DefaultHeapID;            4        12                8        16          size = A_PtrSize
      DWORD     th32ModuleID;                 4        16                4        24
      DWORD     cntThreads;                   4        20                4        28
      DWORD     th32ParentProcessID;          4        24                4        32
      LONG      pcPriClassBase;               4        28                4        36
      DWORD     dwFlags;                      4        32                4        40
      TCHAR     szExeFile[MAX_PATH];          260/520  36                260/520  44          MAX_PATH = 260
    64-bit alignment                          0                          4                    ** U only
    } PROCESSENTRY32, *PPROCESSENTRY32;       ---------------            ---------------
*/
