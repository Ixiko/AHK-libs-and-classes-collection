/*
    Establece el estilo de clase de la ventana especificada.
    Parámetros:
        hWnd : El identificador de la ventana.
        Style: Uno de estos valores: https://msdn.microsoft.com/en-us/library/windows/desktop/ff729176(v=vs.85).aspx.
*/
SetWindowClassStyle(hWnd, Style)
{
    A_LastError := 0

    If (A_PtrSize == 4)
        Local R := DllCall('User32.dll\SetClassLongW', 'Ptr', hWnd, 'Int', -26, 'Int', Style)
    Else
        Local R := DllCall('User32.dll\SetClassLongPtrW', 'Ptr', hWnd, 'Int', -26, 'Ptr', Style, 'Ptr')

    Return (!R && A_LastError ? FALSE : TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633589(v=vs.85).aspx
