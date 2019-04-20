/*
    Establce la ventana padre de la ventana especificada.
    Parámetros:
        hWnd    : El identificador de la ventana.
        ParentID: El identificador de la ventana padre. Si este parámetro es 0, la nueva ventana padre pasa a ser el escritorio.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetWindowParent(hWnd := '', ParentID := 0)
{
    If (ParentID)
    {
        WinSetStyle('+0x40000000', 'ahk_id' . hWnd)
        WinSetStyle('-0x80000000', 'ahk_id' . hWnd)
    }

    A_LastError := 0
    Local OldParentID := DllCall('User32.dll\SetParent', 'Ptr', hWnd, 'Ptr', ParentID, 'Ptr')
        , LastError   := A_LastError

    If (!ParentID)
    {
        WinSetStyle('-0x40000000', 'ahk_id' . hWnd)
        WinSetStyle('+0x80000000', 'ahk_id' . hWnd)
    }

    Return (!OldParentID && LastError ? FALSE : TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633541(v=vs.85).aspx
