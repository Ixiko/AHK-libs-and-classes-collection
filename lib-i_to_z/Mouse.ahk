/*
    Mueve el cursor a las coordenadas especificadas.
    Parámetros:
        X   : La coordenada X.
        Y   : La coordenada Y.
        hWnd: El identificador de una ventana. Si se especifica, las coordenadas son convertidas teniendo en cuenta el área cliente de esta ventana.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetCursorPos(X, Y, hWnd := "")
{
    If (hWnd != "")
    {
        Local POINT := X & 0xFFFFFFFF | Y << 32    ; combina 2 int (4 bytes c/u) en un int64 (8 bytes); la estructura point esta conformada por dos valores de tipo int
        If (!DllCall("User32.dll\ClientToScreen", "Ptr", hWnd, "Int64P", POINT))    ; pasamos un puntero (la dirección de memoria de la variable POINT) a ClientToScreen
            Return (FALSE)
        X := NumGet(&POINT, "Int"), Y := NumGet(&POINT + 4, "Int")
    }
    
    Return DllCall("User32.dll\SetCursorPos", "Int", X, "Int", Y)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648394(v=vs.85).aspx




/*
    Mueve el cursor a las coordenadas especificadas a una determinada velocidad.
    Parámetros:
        X    : La coordenada X.
        Y    : La coordenada Y.
        Speed: La velocidad a la que mover el cursor. Debe ser un valor mayor o igual a 0. 0 es la velocidad más rápida. 1 es la velocidad más lenta.
        hWnd : El identificador de una ventana. Si se especifica, las coordenadas son convertidas teniendo en cuenta el área cliente de esta ventana.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Ejemplo 1:
        MonitorGetWorkArea(, Left, Top, Right, Bottom)
        MoveCursor(Left, Top, 10)
        MoveCursor(Right//2, Bottom//2, 12)
        MoveCursor(Right, Top, 14)
        MoveCursor(Right-15, Bottom, 16)
        MoveCursor(Right//2, Bottom//2, 18)
        MoveCursor(Left, Bottom, 20)
        MoveCursor(Left, Top, 10)
        MoveCursor(Right//2, Bottom//2, 10)
        MoveCursor(Right//2-100, Bottom//2, 5)
        MoveCursor(Right//2, Bottom//2+100, 10)
        MoveCursor(Right//2+100, Bottom//2, 5)
        MoveCursor(Right//2, Bottom//2-100, 10)
        MoveCursor(Right//2-100, Bottom//2, 5)
        MoveCursor(Right//2, Bottom//2, 1)
        ExitApp
    Ejemplo 2:
        Run("Notepad.exe")
        WinWait("ahk_class Notepad")
        WinActivate()
        WinWaitActive()
        WinMove(100, 100, 400, 400)
        MoveCursor(0, 0, 5, WinExist())
        VarSetCapacity(RECT, 16, 0)
        DllCall("User32.dll\GetClientRect", "Ptr", WinExist(), "Ptr", &RECT)
        MoveCursor(NumGet(RECT, 8, "Int"), NumGet(RECT, 12, "Int"), 5, WinExist())
        SendInput("{LButton Down}")
        MoveCursor(NumGet(RECT, 8, "Int")+400, NumGet(RECT, 12, "Int")+50, 4, WinExist())
        SendInput("{LButton Up}")
        ControLSend("{raw}=D =D =D =D =D`n...",, "ahk_class Notepad")
        ExitApp
*/
MoveCursor(X, Y, Speed := 0, hWnd := "")
{
    Local Pos

    If (!(Pos := GetCursorPos(hWnd)))
        Return (FALSE)

    X := X > SysGet(78) ? SysGet(78) : X < 0 ? 0 : X
    Y := Y > SysGet(79) ? SysGet(79) : Y < 0 ? 0 : Y

    While (Pos.X != X || Pos.Y != Y)
    {
        Pos.X := Pos.X < X ? Pos.X + 1 : Pos.X > X ? Pos.X - 1 : Pos.X
        Pos.Y := Pos.Y < Y ? Pos.Y + 1 : Pos.Y > Y ? Pos.Y - 1 : Pos.Y
        
        If (!SetCursorPos(Pos.X, Pos.Y, hWnd))
            Return (FALSE)

        If (Speed && !Mod(A_Index, Speed))
            Sleep(1)
    }

    Return (TRUE)
}




/*
    Mueve el cursor en la cantiad de unidades Mickey especificadas (teniendo en cuenta su posición actual).
    Parámetros:
        X    : La coordenada X.
        Y    : La coordenada Y.
        Speed: La velocidad a la que mover el cursor. Debe ser un valor mayor o igual a 0. 0 es la velocidad más rápida. 1 es la velocidad más lenta.
        hWnd : El identificador de una ventana. Si se especifica, las coordenadas son convertidas teniendo en cuenta el área cliente de esta ventana.
    Return:
        La función no devuelve ningún valor.
    Ejemplo:
        SetCursorPos(A_ScreenWidth//2, A_ScreenHeight//2), Sleep(1000), MoveCursorR(100, 0)
    Observaciones:
        Un mickey es la cantidad de veces que el mouse debe moverse para informar que se ha movido.
*/
MoveCursorR(X, Y)
{
    DllCall("User32.dll\mouse_event", "UInt", 1, "Int", X, "Int", Y, "UInt", 0, "UPtr", 0)
}




/*
    Recupera la posición del cursor.
    Parámetros:
        hWnd: El identificador de una ventana. Si se especifica, las coordenadas son convertidas teniendo en cuenta el área cliente de esta ventana.
    Return:
               0 = Ha ocurrido un error al recuperar la posición actual del cursor.
        [object] = Si tuvo éxito devuele un objeto con las claves X e Y.
*/
GetCursorPos(hWnd := "")
{
    Local POINT := 0
    DllCall("User32.dll\GetCursorPos", "Int64P", POINT)

    If (hWnd != "" && !DllCall("User32.dll\ScreenToClient", "Ptr", hWnd, "Int64P", POINT))
        Return FALSE

    Return {X: NumGet(&POINT, "Int"), Y: NumGet(&POINT + 4, "Int")}
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms648390(v=vs.85).aspx




/*
    Recupera o establece el tiempo de doble clic actual del mouse, en milisegundos.
    Parámetros:
        Value: El número de milisegundos que puede producirse entre el primer y el segundo clic de un doble clic. si se establece en 0, el sistema usa el tiempo predeterminado de 500 milisegundos.
    Notas:
        Un doble clic es una serie de dos clics del botón del ratón, el segundo se produce dentro de un tiempo especificado después del primero.
        El tiempo de doble clic es el número máximo de milisegundos que puede ocurrir entre el primer y segundo clic de un doble clic.
        El tiempo máximo de doble clic es 5000 milisegundos. El tiempo mínimo de doble clic es de 1 milisegundo.
*/
DoubleClickTime(Value := "")
{
    Return (Value == "" ? DllCall("User32.dll\GetDoubleClickTime", "UInt") : DllCall("User32.dll\SetDoubleClickTime", "UInt", Value))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646258(v=vs.85).aspx | https://msdn.microsoft.com/en-us/library/windows/desktop/ms646263(v=vs.85).aspx




/*
    Invierte, restaura o recupera el significado de los botones izquierdo y derecho del ratón.
    Parámetros:
        State: Si es 1, el botón izquierdo genera mensajes de botón derecho y viceversa. Si es 0 restaura los valores originales. Si es -1 recupera el estado actual.
*/
SwapMouseButton(State := -1)
{
    Return (State == -1 ? DllCall("User32.dll\GetSystemMetrics", "Int", 23) : DllCall("User32.dll\SwapMouseButton", "Int", !!State))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms646264(v=vs.85).aspx | https://msdn.microsoft.com/en-us/library/ms724385




/*
    Recupera o establece la velocidad actual del ratón.
    Parámetros:
        Value: Valor entero entre 1 y 20 que identifica la nueva velocidad del ratón. El valor predeterminado es 10. Vacío para recuperar la velocidad actual.
        Save : Determina si el nuevo valor establecido debe de ser permanente. De lo contrario, se restaurará al reiniciar el ordenador.
    Nota: La velocidad del ratón determina la distancia con que se moverá el puntero en función de la distancia que se mueva el ratón.
*/
MouseSpeed(Value := "", Save := FALSE)
{
    Local R

    If (Value != "")
        Return (DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0071, "UInt", 0, "UInt", Value > 20 ? 20 : Value < 1 ? 1 : Value, "UInt", !!Save * 3))
    
    DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0070, "UInt", 0, "UIntP", R, "UInt", 0)
    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx




/*
    Recupera o establece el número de líneas a desplazarse cuando se mueve la rueda vertical del ratón.
    Parámetros:
        Value: Valor entero entre 0 y UINT_MAX que identifica el nuevo número de líneas. El valor predeterminado es 3. Vacío para recuperar el valor actual.
        Save : Determina si el nuevo valor establecido debe ser permanente. De lo contrario, se restaurará al reiniciar el ordenador.
    Notas: 
        El número de líneas es el número sugerido de líneas para desplazarse cuando se desplaza la rueda del ratón sin usar teclas modificadoras.
        Si el número es 0, entonces no debería haber desplazamiento.
        Si el número de líneas a desplazarse es mayor que el número de líneas visibles, la operación debe interpretarse como hacer clic una vez en la página hacia abajo en la barra de desplazamiento.
*/
MouseScrollLines(Value := "", Save := FALSE)
{
    Local R

    If (Value != "")
        Return (DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0069, "UInt", Value, "UInt", 0, "UInt", !!Save * 3))
    
    DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0068, "UInt", 0, "UIntP", R, "UInt", 0)
    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx




/*
    Activa, desactiva o recupera la función Trazados del ratón, que mejora la visibilidad de los movimientos del cursor del ratón, mostrando brevemente una pista de cursores y borrándolos rápidamente.
    Parámetros:
        Value: Si el valor es 0 o 1, la función se deshabilita. espesificar un valor mayor que 1 para indicar el número de cursores dibujados en la ruta.
        Save : Determina si el nuevo valor establecido debe de ser permanente. De lo contrario, se restaurará al reiniciar el ordenador. Vacío para recuperar el valor actual.
    Return: El valor actual. Si el valor es 0 o 1, la función está desactivada. Si el valor es mayor que 1, la función está habilitada y el valor indica el número de cursores dibujados en la ruta.
*/
MouseTrails(Value := "", Save := FALSE)
{
    Local R

    If (Value != "")
        Return (DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x005D, "UInt", Value, "Ptr", 0, "UInt", !!Save * 3))

    DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x005E, "UInt", 0, "UIntP", R, "UInt", 0)
    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx




/*
    Recupera o establece el número de caracteres a desplazarse cuando se mueve la rueda horizontal del ratón.
    Parámetros:
        Value: El número de líneas. El valor predeterminado es 3. Vacío para recuperar el valor actual.
        Save : Determina si el nuevo valor establecido debe de ser permanente. De lo contrario, se restaurará al reiniciar el ordenador.
*/
MouseWheelScrollChars(Value := "", Save := FALSE)
{
    Local R

    If (Value != "")
        Return (DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x006D, "UInt", Value, "Ptr", 0, "UInt", !!Save * 3))
    
    DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x006C, "UInt", 0, "UIntP", R, "UInt", 0)
    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
