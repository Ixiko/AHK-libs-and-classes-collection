/*
    Establece el título de la ventana especificada.
    Parámetros:
        hWnd   : El identificador de la ventana.
        NewText: El nuevo título de la ventana.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetWindowTitle(hWnd, NewTitle := '')
{
    NewTitle .= ''
    Return (DllCall('User32.dll\SetWindowTextW', 'Ptr', hWnd, 'UPtr', &NewTitle))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633546(v=vs.85).aspx
