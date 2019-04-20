/*
    Recupera el identificador de la ventana propietaria de la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        0      = La ventana especificada no tiene propietario.
        [hwnd] = Devuelve el identificador de la ventana propietaria.
*/
GetWindowtOwner(hWnd)
{
    Return (DllCall("User32.dll\GetWindow", "Ptr", hWnd, "UInt", 4, "Ptr"))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633515(v=vs.85).aspx
