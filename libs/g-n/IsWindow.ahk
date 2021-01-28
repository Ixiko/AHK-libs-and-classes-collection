/*
    Determina si existe la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        0 = La ventana especificada no existe.
        1 = La ventana especificada existe.
        2 = La ventana especificada existe pero no responde.
*/
IsWindow(hWnd)
{
    Return (DllCall('User32.dll\IsWindow', 'Ptr', hWnd)
             ? (DllCall('User32.dll\IsHungAppWindow', 'Ptr', hWnd) ? 2 : 1) ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633526(v=vs.85).aspx
             : 0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633528(v=vs.85).aspx




/*
    Determina si la ventana especificada está activa.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        Si la ventana especificada está activa devuelve 1, caso contrario devuelve 0.
*/
IsWindowActive(hWnd)
{
    Return (DllCall('User32.dll\GetForegroundWindow', 'Ptr') == hWnd+0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633505(v=vs.85).aspx
