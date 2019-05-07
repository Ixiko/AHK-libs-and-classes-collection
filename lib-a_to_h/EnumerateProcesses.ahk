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
            List .= Obj.ProcessName . " [" . Obj.ProcessId . "]`n"
        MsgBox(List)
*/
EnumerateProcesses()
{
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682489(v=vs.85).aspx
    Local hSnapshot := 0
    If ((hSnapshot := DLLCall("Kernel32.dll\CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0, "Ptr")) == -1)    ; TH32CS_SNAPPROCESS = 2 | INVALID_HANDLE_VALUE = -1
        Return -1
    
    Local PROCESSENTRY32
    NumPut(VarSetCapacity(PROCESSENTRY32, A_PtrSize == 4 ? 556 : 568), &PROCESSENTRY32, "UInt")
    
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684834(v=vs.85).aspx
    Local OutputVar := []
    If (DllCall("Kernel32.dll\Process32FirstW", "Ptr", hSnapshot, "UPtr", &PROCESSENTRY32))
        Loop
            OutputVar[A_Index] := {       ProcessId: NumGet(&PROCESSENTRY32 +                          8,   "UInt")
                                  , ParentProcessId: NumGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 24 : 32),   "UInt")
                                  ,     ProcessName: StrGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 36 : 44), "UTF-16")
                                  ,         Threads: NumGet(&PROCESSENTRY32 + (A_PtrSize == 4 ? 20 : 28),   "UInt") }
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684836(v=vs.85).aspx
        Until (!DllCall("Kernel32.dll\Process32NextW", "Ptr", hSnapshot, "UPtr", &PROCESSENTRY32))
    
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hSnapshot)

    Return ObjLength(OutputVar) ? OutputVar : FALSE
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684834(v=vs.85).aspx





/*
    typedef struct tagPROCESSENTRY32W
    {
        DWORD   dwSize;
        DWORD   cntUsage;
        DWORD   th32ProcessID;          // this process
        ULONG_PTR th32DefaultHeapID;
        DWORD   th32ModuleID;           // associated exe
        DWORD   cntThreads;
        DWORD   th32ParentProcessID;    // this process's parent process
        LONG    pcPriClassBase;         // Base priority of process's threads
        DWORD   dwFlags;
        WCHAR   szExeFile[MAX_PATH];    // Path
    } PROCESSENTRY32W;

    
    MAX_PATH = 260 bytes (520 bytes UTF-16)


    32-bit
        -- TYPE -    ------ NAME -------    -- SIZE -    - TOTAL -
            DWORD                 dwSize      4 bytes      4 bytes    #1
            DWORD               cntUsage      4 bytes      8 bytes    #2
            DWORD          th32ProcessID      4 bytes     12 bytes    #3
        ULONG_PTR      th32DefaultHeapID      4 bytes     16 bytes    #4
            DWORD           th32ModuleID      4 bytes     20 bytes    #5
            DWORD             cntThreads      4 bytes     24 bytes    #6
            DWORD    th32ParentProcessID      4 bytes     28 bytes    #7
             LONG         pcPriClassBase      4 bytes     32 bytes    #8
            DWORD                dwFlags      4 bytes     36 bytes    #9
            WCHAR    szExeFile[MAX_PATH]    520 bytes    556 bytes


    64-bit
        -- TYPE -    ------ NAME -------    -- SIZE -    - TOTAL -
            DWORD                 dwSize      4 bytes      4 bytes    #1
            DWORD               cntUsage      4 bytes      8 bytes    #1
            DWORD          th32ProcessID      4 bytes     12 bytes    #2
          PADDING                             4 bytes     16 bytes    #2
        ULONG_PTR      th32DefaultHeapID      8 bytes     24 bytes    #3
            DWORD           th32ModuleID      4 bytes     28 bytes    #4
            DWORD             cntThreads      4 bytes     32 bytes    #4
            DWORD    th32ParentProcessID      4 bytes     36 bytes    #5
             LONG         pcPriClassBase      4 bytes     40 bytes    #5
            DWORD                dwFlags      4 bytes     44 bytes    #6
          PADDING                             4 bytes     48 bytes    #6
            WCHAR    szExeFile[MAX_PATH]    520 bytes    568 bytes
*/
