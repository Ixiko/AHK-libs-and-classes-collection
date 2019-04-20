/*
    Determina si el proceso especificado existe.
    Parámetros:
        Process: El identificador, nombre o ruta del proceso. Si pasa el identificador debe asegurarse de que sea un valor de tipo entero.
    Return:
        -2    = Ha ocurrido un error al intentar recuperar una lista de los procesos activos en el sistema.
        -1    = Ha ocurrido un error al intentar recuperar información de los procesos.
         0    = El proceso no existe.
        [pid] = Si el proceso existe devuelve su identificador.
    Ejemplo:
        MsgBox('ID`t: ' . IsProcess(IsProcess('explorer.exe')) . '`nName`t: ' . IsProcess('explorer.exe') . '`nPath`t: ' . IsProcess(A_WinDir . '\explorer.exe'))
*/
IsProcess(Process)
{
    Local hSnapshot, IsInteger, IsPath, Buffer, PROCESSENTRY32, ProcessId, hProcess

    If ((hSnapshot := DLLCall('Kernel32.dll\CreateToolhelp32Snapshot', 'UInt', 2, 'UInt', 0, 'Ptr')) == -1)
        Return (-2)
    
    If (!(IsInteger := Type(Process) == 'Integer')) ;pid?
        If (IsPath := InStr(Process, ':')) ;path?
         VarSetCapacity(Buffer, 2024 * 2, 0)

    NumPut(VarSetCapacity(PROCESSENTRY32, A_PtrSize == 4 ? 556 : 568, 0), &PROCESSENTRY32, 'UInt')
    
    If (DllCall('Kernel32.dll\Process32FirstW', 'Ptr', hSnapshot, 'UPtr', &PROCESSENTRY32))
    {
        Loop
        {
            If (IsInteger) ;pid
            {
                If (NumGet(&PROCESSENTRY32 + 8, 'UInt') == Process)
                {
                    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
                    Return (Process)
                }
            }
            Else
            {
                If (IsPath) ;path
                {
                    ProcessId := NumGet(&PROCESSENTRY32 + 8, 'UInt')
                    If (hProcess := DllCall('Kernel32.dll\OpenProcess', 'UInt', 0x1000, 'Int', FALSE, 'UInt', ProcessId, 'Ptr'))
                    {
                        If (DllCall('Kernel32.dll\QueryFullProcessImageNameW', 'Ptr', hProcess, 'UInt', 0, 'UPtr', &Buffer, 'UIntP', 2024))
                        {
                            If (StrGet(&Buffer, 'UTF-16') = Process)
                            {
                                DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)
                                DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
                                Return (ProcessId)
                            }
                        }

                        DllCall('Kernel32.dll\CloseHandle', 'Ptr', hProcess)
                    }
                }
                Else If (StrGet(&PROCESSENTRY32 + (A_PtrSize = 4 ? 36 : 44), 'UTF-16') = Process) ;name
                {
                    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
                    Return (NumGet(&PROCESSENTRY32 + 8, 'UInt'))
                }
            } 
        }
        Until (!DllCall('Kernel32.dll\Process32NextW', 'Ptr', hSnapshot, 'UPtr', &PROCESSENTRY32))
    }
    Else
    {
        DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
        Return (-1)
    }
    
    DllCall('Kernel32.dll\CloseHandle', 'Ptr', hSnapshot)
    Return (0)
}
