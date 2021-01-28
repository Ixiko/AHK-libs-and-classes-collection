/*
    Vuelve a dibujar la ventana especificada. Agrega un rectángulo a la región de actualización de la ventana especificada. La región de actualización representa la porción del área de cliente de las ventanas que se debe dibujar.
    Parámetros:
        hWnd : El identificador de la ventana. Si se espesifica 0, se aplica a todas las ventanas, no solo las creadas por el script (no recomendado).
        Rect : Un objeto con el rectángulo del área de la ventana a redibujar. Especificar una cadena vacía para redibujar toda el área de la ventana.
        Erase: Determina si el fondo dentro de la región de actualización ha de ser borrado cuando se procesa la región de actualización.
        Force: Determina si se debe forzar el redibujado. Puede ser 0, 1 o 2. El método 2 solo es necesario cuando se modifican ciertos estilos.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Ejemplo:
        MsgBox(RedrawWindow(WinExist('A'), 0, TRUE, 2))
*/
RedrawWindow(hWnd := 0, Rect := 0, Erase := TRUE, Force := FALSE)
{
    Local pRect := 0

    If (IsObject(Rect))
    {
        Local Buffer
        VarSetCapacity(Buffer, 16), pRect := &Buffer
        NumPut(Rect.X         , pRect     , 'Int')
        NumPut(Rect.Y         , pRect + 4 , 'Int')
        NumPut(Rect.W + Rect.X, pRect + 8 , 'Int')
        NumPut(Rect.H + Rect.Y, pRect + 12, 'Int')
    }

    If (!DllCall('User32.dll\InvalidateRect', 'Ptr', hWnd, 'UPtr', pRect, 'Int', Erase))
        Return (FALSE)

    If (Force)
    {
        DllCall('User32.dll\UpdateWindow', 'Ptr', hWnd)

        If (Force == 2)
            DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'UInt', 0x2 | 0x1 | 0x4 | 0x20)
    }
    
    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/dd145002(v=vs.85).aspx
