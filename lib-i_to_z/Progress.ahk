/*
    Recupera información sobre los límites altos y bajos actuales del control Progress especificado.
    Parámetros:
        PB: El objeto control Progress.
    Return:
        Devuelve un objeto con las claves Min|Max.
*/
PB_GetRange(PB)
{
    ; PBRANGE structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760822(v=vs.85).aspx
    Local PBRANGE
    VarSetCapacity(PBRANGE, 8)

    ; PBM_GETRANGE message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760832(v=vs.85).aspx
    Return ({ Max: DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x0407, 'Ptr', 0, 'UPtr', &PBRANGE)
            , Min : NumGet(&PBRANGE, 'Int')                                                                       })
}




/*
    Establece los límites del control Progress especificado.
    Parámetros:
        PB : El objeto control Progress.
        Min: El valor mínimo.
        Max: El valor máximo. Este valor debe ser mayor que Min.
*/
PB_SetRange(PB, Min, Max)
{
    ; PBM_SETRANGE32 message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760848(v=vs.85).aspx
    DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x0406, 'Int', Min, 'Int', Max)
}




/*
    Establece la posición actual del control Progress especificado.
    Parámetros:
        PB : El objeto control Progress.
        Pos: La nueva posición. El valor mínimo y el valor máximo permitido lo establece la función PB_SetRange.
    Return:
        Devuelve la posición anterior.
*/
PB_SetPos(PB, Pos)
{
    ; PBM_SETPOS message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760844(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x0402, 'Int', Pos, 'Ptr', 0))
}




/*
    Recupera la posición actual del control Progress especificado.
    Parámetros:
        PB: El objeto control Progress.
    Return:
        Devuelve la posición actual.
*/
PB_GetPos(PB)
{
    ; PBM_GETPOS message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760830(v=vs.85).aspx
    Return (DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x0408, 'Ptr', 0, 'Ptr', 0))
}




/*
    Recupera el color de la barra de progreso del control Progress especificado.
    Parámetros:
        PB: El objeto control Progress.
    Return:
        Devuelve el color RGB de la barra de progreso.
*/
PB_GetColor(PB)
{
    ; PBM_GETBARCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760826(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x040F, 'Ptr', 0, 'Ptr', 0, 'UInt')
    Return ((Color & 255) << 16 | (Color & 65280) | (Color >> 16))
}




/*
    Establece el color de la barra de progreso del control Progress especificado.
    Parámetros:
        PB   : El objeto control Progress.
        Color: El nuevo color RGB de la barra de progreso.
    Return:
        Devuelve el color RGB anterior de la barra de progreso.
    Observaciones:
        Esta función solo tiene efecto si el control Progress no tiene ningún tema (estilo visual). Para ello, establecer un color cuando cree el control.
*/
PB_SetColor(PB, Color)
{
    ; PBM_SETBARCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760838(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x0409, 'Ptr', 0, 'UInt', Color, 'UInt')
    Return ((Color & 255) << 16 | (Color & 65280) | (Color >> 16))
}




/*
    Recupera el color de fondo del control Progress especificado.
    Parámetros:
        PB: El objeto control Progress.
    Return:
        Devuelve el color RGB del fondo.
*/
PB_GetBkColor(PB)
{
    ; PBM_GETBKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760828(v=vs.85).aspx
    Local Color := DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x040E, 'Ptr', 0, 'Ptr', 0, 'UInt')
    Return ((Color & 255) << 16 | (Color & 65280) | (Color >> 16))
}




/*
    Establece el color de fondo del control Progress especificado.
    Parámetros:
        PB   : El objeto control Progress.
        Color: El nuevo color RGB del fondo.
    Return:
        Devuelve el color RGB anterior del fondo.
    Observaciones:
        Esta función solo tiene efecto si el control Progress no tiene ningún tema (estilo visual). Para ello, establecer un color cuando cree el control.
*/
PB_SetBkColor(PB, Color)
{
    ; PBM_SETBKCOLOR message
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb760840(v=vs.85).aspx
    Color := ((Color & 255) << 16) | (((Color >> 8) & 255) << 8) | (Color >> 16)
    Color := DllCall('User32.dll\SendMessageW', 'Ptr', PB.Hwnd, 'UInt', 0x2001, 'Ptr', 0, 'UInt', Color, 'UInt')
    Return ((Color & 255) << 16 | (Color & 65280) | (Color >> 16))
}
