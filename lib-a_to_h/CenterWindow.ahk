/*
    Centra la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
        Pos : Opcional. Especificar la posición de la ventana. Puede ser una o dos de las siguientes palabras:
            Top  / Bottom = Arriba    / Abajo
            Left / Right  = Izquierda / Derecha
    Observaciones:
        Si la ventana está maximizada, se modifica el ancho o el alto dependiendo la posicion:
            si se posiciona arriba o abajo, se modifica el alto (A_ScreenHeight/2).
            si se posiciona a la izquierda o a la derecha, se modifica el ancho (A_ScreenWidth/2).
        la ventana se ajusta a la pantalla visible, sin importar la posicion de la barra de tareas (la ventana no es tapada por la barra de tareas).
*/
CenterWindow(hWnd, Pos := '')
{
    Local MONITORINFO
    VarSetCapacity(MONITORINFO, 40)

    If (!DllCall('User32.dll\GetWindowRect', 'Ptr', hWnd, 'UPtr', &MONITORINFO))
        Return (FALSE)
    Local X := NumGet(&MONITORINFO     , 'Int')
        , Y := NumGet(&MONITORINFO +  4, 'Int')
        , W := NumGet(&MONITORINFO +  8, 'Int') - X
        , H := NumGet(&MONITORINFO + 12, 'Int') - Y

    ; https://msdn.microsoft.com/en-us/library/dd144901(v=vs.85).aspx
    NumPut(40, &MONITORINFO, 'UInt')
    hMonitor := DllCall('User32.dll\MonitorFromWindow', 'Ptr', hWnd, 'UInt', 0x00000002, 'Ptr')
    DllCall('User32.dll\GetMonitorInfoW', 'Ptr', hMonitor, 'UPtr', &MONITORINFO)
    Local MX := NumGet(&MONITORINFO + 20, 'Int')
        , MY := NumGet(&MONITORINFO + 24, 'Int')
        , MW := NumGet(&MONITORINFO + 28, 'Int') - MX
        , MH := NumGet(&MONITORINFO + 32, 'Int') - MY

    Local T := InStr(Pos, 'Top')
        , B := InStr(Pos, 'Bottom')
        , L := InStr(Pos, 'Left')
        , R := InStr(Pos, 'Right')
        , C := InStr(Pos, 'Center')

    If (DllCall('User32.dll\IsZoomed', 'Ptr', hWnd))
    {
        W := (L||R) ? (MW/2)-(((MW/2)/100)* 1) : MW
        H := (T||B) ? (MH/2)-(((MH/2)/100)* 1) : MH
    }

    If (T || B || L || R)
        WinMove((L?0:R?(MW-W):C?((MW/2)-(w/2)):X) +MX, (T?0:B?(MH-H):C?((MH/2)-(h/2)):y) +MY, W, H, 'ahk_id' . hWnd)
    Else
        WinMove(((MW/2) - (w/2)) +MX, ((MH/2) - (h/2)) +my, W, H, 'ahk_id' . hWnd)

    Return (TRUE)
}
