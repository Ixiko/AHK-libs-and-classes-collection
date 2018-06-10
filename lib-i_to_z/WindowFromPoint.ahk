/*
    Recupera el identificador de la ventana que coincide con el punto especificado.
    Parámetros:
        X       : El punto X.
        Y       : El punto Y.
        ParentID: El identificador de la ventana padre. Si se utiliza, la función busca por una ventana hija (ej. un control) y los puntos X e Y son relativos a esta ventana.
        Hidden  : Si se establece en TRUE, busca tambien por ventanas ocultas.
        Disabled: Si se establece en TRUE, busca tambien por ventanas deshabilitadas. 
    Return:
              0 = No se ha encontrado ninguna ventana en el punto especificado o ParentID no existe (si ParentID != 0).
        [array] = Devuelve un array con el identificador de cada ventana encontrada en el punto especificado.
    Ejemplo:
        Gui := GuiCreate()
        LV  := Gui.AddListView('x0 y0 w500 h400', 'Hwnd|Title|ClassName')

        For Each, WindowID in WindowFromPoint(100, 100)
            LV.Add(, WindowID, WinGetTitle('ahk_id' . WindowID), WinGetClass('ahk_id' . WindowID))

        Loop (2)
            LV.ModifyCol(A_Index, 'AutoHdr')

        Gui.Show('w500 h400')
        WinWaitClose('ahk_id' . Gui.hWnd)
        ExitApp
*/
WindowFromPoint(X, Y, ParentID := 0, Hidden := FALSE, Disabled := FALSE)
{
    If (ParentID && !DllCall('User32.dll\IsWindow', 'Ptr', ParentID))
        Return (FALSE)

    Local RECT
    VarSetCapacity(RECT, 16)

    Local Info           := {X: X, Y: Y, ParentID: ParentID, Hidden: Hidden, Disabled: Disabled, pRect: &RECT}
        , pInfo          := &Info
        , pEnumChildProc := RegisterCallback('WindowFromPoint_EnumChildProc',,, pInfo)
        , Data           := []

    DllCall('User32.dll\EnumChildWindows', 'Ptr', ParentID, 'UPtr', pEnumChildProc, 'UPtr', &Data)
    DllCall('Kernel32.dll\GlobalFree', 'UPtr', pEnumChildProc, 'UPtr')

    Return (Data.Length() ? Data : 0)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633493(v=vs.85).aspx




WindowFromPoint_EnumChildProc(hWnd, pData)
{
    Local Info := Object(A_EventInfo)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633530(v=vs.85).aspx
    If (!Info.Hidden && !DllCall('User32.dll\IsWindowVisible', 'Ptr', hWnd))
        Return (TRUE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646303(v=vs.85).aspx
    If (!Info.Disabled && !DllCall('User32.dll\IsWindowEnabled', 'Ptr', hWnd))
        Return (TRUE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms633519(v=vs.85).aspx
    DllCall('User32.dll\GetWindowRect', 'Ptr', hWnd, 'UPtr', Info.pRect)
    Local X := NumGet(Info.pRect     , 'Int')
        , Y := NumGet(Info.pRect +  4, 'Int')
        , W := NumGet(Info.pRect +  8, 'Int') - X
        , H := NumGet(Info.pRect + 12, 'Int') - Y

    If (Info.ParentID)
    {
        DllCall('User32.dll\ScreenToClient', 'Ptr', Info.ParentID, 'UPtr', Info.pRect)
        X := NumGet(Info.pRect    , 'Int')
        Y := NumGet(Info.pRect + 4, 'Int')
    }

    If (Info.X >= X && Info.X <= X+W && Info.Y >= Y && Info.Y <= Y+H)
        Object(pData).Push(hWnd)

    Return (TRUE)
}
