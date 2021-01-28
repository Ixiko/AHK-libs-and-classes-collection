/*
    Establece la ventana propietaria de la ventana especificada.
    Parámetros:
        hWnd   : El identificador de la ventana.
        OwnerID: El identificador de la nueva ventana propietaria. Si este valor es 0, la ventana no tiene propietario.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetWindowtOwner(hWnd, OwnerID := 0)
{
    A_LastError := 0

    If (A_PtrSize == 4)
        Local R := DllCall('User32.dll\SetWindowLongW', 'Ptr', hWnd, 'Int', -8, 'Int', OwnerID)
    Else
        Local R := DllCall('User32.dll\SetWindowLongPtrW', 'Ptr', hWnd, 'Int', -8, 'Ptr', OwnerID, 'Ptr')

    Return (!R && A_LastError ? FALSE : TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms644898(v=vs.85).aspx
