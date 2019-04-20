/*
    Recupera el título de la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        Devuelve una cadena que representa el título de la ventana. La cadena puede estar vacía.
    ErrorLevel:
        Se establece en 1 si ha ocurrido un error, caso contrario se establece en 0.
*/
GetWindowTitle(hWnd)
{
    Local Size := DllCall('User32.dll\GetWindowTextLengthW', 'Ptr', hWnd)
    If (!Size && ((A_LastError && ErrorLevel := TRUE) || !(ErrorLevel := FALSE)))
        Return ('')

    Local Buffer
    VarSetCapacity(Buffer, Size * 2 + 2)

    ErrorLevel := !DllCall('User32.dll\GetWindowTextW', 'Ptr', hWnd, 'UPtr', &Buffer, 'Int', Size + 2)

    Return (StrGet(&Buffer, 'UTF-16'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633520(v=vs.85).aspx
