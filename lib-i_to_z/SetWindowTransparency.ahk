/*
    Establece el nivel de transparencia de la ventana especificada.
    Parámetros:
        hWnd : El identificador de la ventana.
        Value: Un valor entre 0 y 255 que indica el nivel de transparencia. 0 es transparente. 255 es opaco. Si especifica -1, la transparencia se desactiva.
    Return:
        0 = Ha ocurrido un error.
        1 = La transparencia se ha cambiado con éxito.
        2 = No se ha efectuado ningún cambio de transparencia debido a que los valores actuales coinciden con los valores a establecer.
*/
SetWindowTransparency(hWnd, Value := -1)
{
    Local Alpha, Flags

    If (!DllCall('User32.dll\GetLayeredWindowAttributes', 'Ptr', hWnd, 'Ptr', 0, 'IntP', Alpha, 'UIntP', Flags) && A_LastError != 87)
        Return (FALSE)

    If (Value == -1)
    {
        If (!Flags)
            Return (2)
        If (Alpha != 255)
            DllCall('User32.dll\SetLayeredWindowAttributes', 'Ptr', hWnd, 'Ptr', 0, 'Int', 255, 'UInt', 0x2)
        Return (WinSetExStyle('-0x80000', 'ahk_id' . hWnd))
    } 

    If (Alpha == Value)
        Return (2)

    If (!(Flags & 0x2) && !WinSetExStyle('+0x80000', 'ahk_id' . hWnd))
        Return (FALSE)

    Return (DllCall('User32.dll\SetLayeredWindowAttributes', 'Ptr', hWnd, 'Ptr', 0, 'Int', Value, 'UInt', 0x2))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633540(v=vs.85).aspx
