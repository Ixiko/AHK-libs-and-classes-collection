/*
    Recupera las coordenadas y dimensiones de la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
    Return:
        0     = Error.
        [obj] = Si tuvo éxito devuelve un objeto con las claves X,Y,W,H, ClientW y ClientH.
    Ejemplo:
        For Key, Pos in GetWindowPos(WinExist('ahk_class Notepad'))
            Str .= Key . ':`t' . Pos . '`n'
        MsgBox(Str)
*/
GetWindowPos(hWnd)
{
    Local RECT

    VarSetCapacity(RECT, 16, 0)
    If (!DllCall('User32.dll\GetWindowRect', 'Ptr', hWnd, 'UPtr', &RECT))
        Return (FALSE)

    Local Pos   := {}
          Pos.X := NumGet(&RECT     , 'Int')
          Pos.Y := NumGet(&RECT +  4, 'Int')
          Pos.W := NumGet(&RECT +  8, 'Int') - Pos.X
          Pos.H := NumGet(&RECT + 12, 'Int') - Pos.Y

    DllCall('User32.dll\GetClientRect', 'Ptr', hWnd, 'UPtr', &RECT)
    Pos.ClientW := NumGet(&RECT +  8, 'Int')
    Pos.ClientH := NumGet(&RECT + 12, 'Int')

    Return (Pos)
}
