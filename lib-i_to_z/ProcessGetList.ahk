; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	Flipeador
; Date:   	2019-07-14
; for:     	AHK_L

/*
    List := ""
TmpFile := A_Temp . "\~ahktmp.txt"  ; Archivo temporal.

for Each, Item in ProcessGetList()
    List .= Format("ProcessId:{9}{1}`nThreads:{9}{2}`nParentProcessId:{7}{3}`nBasePriority:{8}{4}`nExeFile:{9}{5}{6}"
                 ,   Item.ProcessId,  Item.ThreadCount,  Item.ParentProcessId,  Item.BasePriority,   Item.ProcessName
                 ,   "`n-----------------------------------------------------------`n",   "`t",   "`t`t",   "`t`t`t")

FileOpen(TmpFile, "w-wd", "UTF-8").Write(List)
Run(TmpFile)

*/

/*
    Retrieves a list with information for each process object running in the system.
    Return value:
        If the function succeeds, the return value is an array of associative objects (Map) with the following keys:
            ProcessName        The name of the executable file associated with the process (its process's image name).
            ProcessId          The process identifier that uniquely identifies the process.
            ParentProcessId    The identifier of the process that created this process (its parent process).
            BasePriority       The base priority of the process, which is the starting priority for threads created within the associated process.
            ThreadCount        The number of execution threads started by the process.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessGetList()
{
    local hSnapshot := DLLCall("Kernel32.dll\CreateToolhelp32Snapshot", "UInt", 0x00000002  ; DWORD dwFlags. TH32CS_SNAPPROCESS.
                                                                      , "UInt", 0           ; DWORD th32ProcessID.
                                                                      , "Ptr")              ; HANDLE.
    if (hSnapshot == -1)  ; INVALID_HANDLE_VALUE == ((HANDLE)(LONG_PTR)-1).
        return 0

    local ProcessList    := [ ]                                ; An array of associative objects containing information from each process.
    local PROCESSENTRY32 := BufferAlloc(A_PtrSize==4?556:568)  ; https://docs.microsoft.com/en-us/windows/win32/api/tlhelp32/ns-tlhelp32-tagprocessentry32.
    NumPut("UInt", PROCESSENTRY32.Size, PROCESSENTRY32)        ; DWORD dwSize (sizeof PROCESSENTRY32 structure).

    if DllCall("Kernel32.dll\Process32FirstW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    {
        local Ptr := { cntThreads         : PROCESSENTRY32.Ptr + (A_PtrSize==4?20:28)
                     , th32ParentProcessID: PROCESSENTRY32.Ptr + (A_PtrSize==4?24:32)
                     , pcPriClassBase     : PROCESSENTRY32.Ptr + (A_PtrSize==4?28:36)
                     , szExeFile          : PROCESSENTRY32.Ptr + (A_PtrSize==4?36:44) }
        loop
        {
            ProcessList.Push( { ProcessId      : NumGet(PROCESSENTRY32         ,   "UInt")      ; DWORD th32ProcessID.
                              , ThreadCount    : NumGet(Ptr.cntThreads         ,   "UInt")      ; DWORD cntThreads.
                              , ParentProcessId: NumGet(Ptr.th32ParentProcessID,   "UInt")      ; DWORD th32ParentProcessID.
                              , BasePriority   : NumGet(Ptr.pcPriClassBase     ,   "UInt")      ; LONG  pcPriClassBase.
                              , ProcessName    : StrGet(Ptr.szExeFile          , "UTF-16") } )  ; CHAR  szExeFile[MAX_PATH].
        }
        until !DllCall("Kernel32.dll\Process32NextW", "Ptr", hSnapshot, "Ptr", PROCESSENTRY32)
    }

    DllCall("Kernel32.dll\CloseHandle", "Ptr", hSnapshot)
    return ProcessList.Length() ? ProcessList : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-createtoolhelp32snapshot