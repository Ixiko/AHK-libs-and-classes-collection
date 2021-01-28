/*
    Mueve una de las barras de desplazamiento de la ventana especificada hacia arriba o hacia abajo.
    Parámetros:
        hWnd     : El identificador de la ventana.
        Value    : Especificar el número de posiciones que debe moverse la barra, un número negativo indica que la barra debe moverse hacia arriba, y un número positivo hacia abajo.
        ScrollBar: 0 para la barra horizontal, 1 para la barra vertical.
    Ejemplo:
        F1::MouseGetPos(X, Y, W, C, 2) ScrollWindow(C, -5)
*/
ScrollWindow(hWnd, Value, ScrollBar := 1)
{
    Flags   := SubStr(Value, 1, 1) != '-'
    Loop (Abs(Value))
        DllCall('User32.dll\PostMessageW', 'Ptr', hWnd, 'UInt', 0x0114 + !!ScrollBar, 'Int', Flags, 'Ptr', 0)
}
