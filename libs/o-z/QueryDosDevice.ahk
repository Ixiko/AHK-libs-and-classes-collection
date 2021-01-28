/*
    Recupera información sobre los nombres de dispositivos MS-DOS. La función puede obtener el mapeo actual para un nombre de dispositivo MS-DOS particular.
    Parámetros:
        DeviceName: El nombre del dispositivo MS-DOS. Solo se toma el primer caracter como letra de la partición.
    Return:
        Si tuvo éxito devuelve una cadena con la información, caso contrario devuelve una cadena vacía.
    Ejemplo:
        MsgBox(QueryDosDevice(A_WinDir))
*/
QueryDosDevice(DeviceName)
{
    Local Size, Buffer

    VarSetCapacity(Buffer, 100)
    Size := DllCall('Kernel32.dll\QueryDosDeviceW', 'Str', SubStr(DeviceName, 1, 1) . ':', 'UPtr', &Buffer, 'UInt', 50)

    Return (Size ? StrGet(&Buffer, 'UTF-16') : '')
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa365461(v=vs.85).aspx
