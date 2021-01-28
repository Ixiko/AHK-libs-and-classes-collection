/*
    Recupera el identificador de la ventana activa.
    Return:
        Devuelve el identificador de la ventana activa.
*/
GetActiveWindow()
{
    Return (DllCall('User32.dll\GetForegroundWindow', 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633505(v=vs.85).aspx
