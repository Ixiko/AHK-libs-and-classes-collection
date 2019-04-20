/*
    Recupera el identificador de la ventana padre de la ventana especificada, si la tiene.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
             0 = La ventana especificada no tiene ninguna ventana padre.
        [hwnd] = Devuelve el identificador de la ventana padre.
*/
GetWindowParent(hWnd)
{
    Return (DllCall('User32.dll\GetAncestor', 'Ptr', hWnd, 'UInt', 1, 'Ptr'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633502(v=vs.85).aspx
