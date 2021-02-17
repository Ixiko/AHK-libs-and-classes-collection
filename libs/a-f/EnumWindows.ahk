/*
    Enumera todas las ventanas o solo las ventanas hijas que pertenecen a la ventana padre especificada.
    Parámetros:
        ParentID: El identificador de la ventana padre. Si este valor es 0, se enumeran todas las ventanas.
        Visible : Si este valor es TRUE, solo se enumeran las ventanas visibles.
    Return:
              0 = Ha ocurrido un error. Debido a que la ventana especificada en ParentID no existe (si ParentID != 0).
        [array] = Si tuvo éxito devuelve un array con los identificadores de las ventanas. El array puede estar vacío si no se encontraron ventanas.
    Ejemplo:
        For Each, WindowID in EnumWindows(0, TRUE)
            List .= WinGetTitle('ahk_id' . WindowID) . '`n'
        MsgBox(Trim(Sort(List, 'U')))
*/
EnumWindows(ParentID := 0, Visible := FALSE){
    If (ParentID && !DllCall('User32.dll\IsWindow', 'Ptr', ParentID))
        Return (FALSE)

    Local pEnumChildProc := RegisterCallback('EnumChildProc',,, Visible)
        , Data           := []

    DllCall('User32.dll\EnumChildWindows', 'Ptr', ParentID, 'UPtr', pEnumChildProc, 'UPtr', &Data)
    DllCall('Kernel32.dll\GlobalFree', 'UPtr', pEnumChildProc, 'UPtr')

    Return (Data)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633494(v=vs.85).aspx




EnumChildProc(hWnd, pData){
    If (A_EventInfo && !DllCall('User32.dll\IsWindowVisible', 'Ptr', hWnd))
        Return (TRUE)

    Object(pData).Push(hWnd)

    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633493(v=vs.85).aspx
