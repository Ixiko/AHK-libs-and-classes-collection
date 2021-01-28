/*
    Establece las coordenadas y dimensiones de la ventana especificada.
    Parámetros:
        hWnd: El identificador de la ventana.
        X     : La coordenada X. Una cadena vacía mantiene la posición. Si especifica un objeto debe tener las claves X,Y,W y/o H. O puede ser una de las siguientes palabras:
            Bottom   = Coloca la ventana en la parte inferior del orden Z. Si el parámetro hWnd identifica una ventana superior, la ventana pierde su estado superior y se coloca en la parte inferior de todas las demás ventanas.
            Top      = Coloca la ventana en la parte superior de la orden Z.
            TopMost  = Coloca la ventana sobre todas las ventanas superiores. La ventana mantiene su posición más alta incluso cuando está desactivada.
            -TopMost = Coloca la ventana sobre todas las ventanas no superiores (es decir, detrás de todas las ventanas superiores).
        Y     : La coordenada Y. Una cadena vacía mantiene la posición.
        Width : El ancho. Una cadena vacía mantiene el ancho.
        Height: La altura. Una cadena vacía mantiene la altura.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Observaciones:
        Si el parámetro 'X' es un objeto o una cadena con una de las palabras claves especificadas, los parámetros 'Y, Width y Height' no tienen efecto.
*/
SetWindowPos(hWnd, X := '', Y := '', Width := '', Height := '')
{
    If (X = 'Bottom')
        Return (DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr',  1, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'UInt', 19))
    Else If (X = 'Top')
        Return (DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr',  0, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'UInt', 19))
    Else If (X = 'TopMost')
        Return (DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr', -1, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'UInt', 19))
    Else If (X = '-TopMost')
        Return (DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr', -2, 'Int', 0, 'Int', 0, 'Int', 0, 'Int', 0, 'UInt', 19))

    Local RECT
    VarSetCapacity(RECT, 16, 0)
    If (!DllCall('User32.dll\GetWindowRect', 'Ptr', hWnd, 'Ptr', &RECT))
        Return (FALSE)

    If (!IsObject(X))
        X := {X: X, Y: Y, W: Width, H: Height}

    Loop Parse, 'X|Y|W|H', '|'
        If (!ObjHasKey(X, A_LoopField) || X[A_LoopField] == '')
            X[A_LoopField] := NumGet(&RECT + (A_Index - 1) * 4, 'Int') - (A_Index > 2 ? NumGet(&RECT + (A_Index - 3) * 4, 'Int') : 0)
    
    Return (DllCall('User32.dll\SetWindowPos', 'Ptr', hWnd, 'Ptr', 0, 'Int', X.X, 'Int', X.Y, 'Int', X.W, 'Int', X.H, 'UInt', 0x221C))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms633545(v=vs.85).aspx
