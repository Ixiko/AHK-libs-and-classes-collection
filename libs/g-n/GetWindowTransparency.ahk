/*
    Recupera el nivel de transparencia de la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
             -2 = Ha ocurrido un error al intentar recuperar la información.
             -1 = La transparencia se encuentra deshabilitada en esta ventana.
        [0-255] = Valor entre 0 y 255 (inclusive) que indica el nivel de transparencia. 0 es transparente total. 255 es opaco.
*/
GetWindowTransparency(hWnd)
{
    Local Alpha, Flags
    
    If (!DllCall('User32.dll\GetLayeredWindowAttributes', 'Ptr', hWnd, 'Ptr', 0, 'IntP', Alpha, 'UIntP', Flags))
        Return (A_LastError == 87 ? -1 : -2)

    Return (Flags & 0x2 ? Alpha : -1)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633508(v=vs.85).aspx
