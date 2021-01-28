/*
    Recupera o establece el ajuste de retardo de repetición del teclado.
    Parámetros:
        Value: 0, 1, 2 o 3, donde 0 establece el retardo más corto (aproximadamente 250 ms) y 3 establece el retardo más largo (aproximadamente 1 segundo). Vacío para recuperar el valor actual.
        Save : Determina si el nuevo valor establecido debe de ser permanente. De lo contrario, se restaurará al reiniciar el ordenador.
    Nota: El retardo real asociado con cada valor puede variar dependiendo del hardware.
*/
KeyboardDelay(Value := '', Save := FALSE)
{
    If (Value == '')
        Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0017, 'UInt', Value, 'Ptr', 0, 'UInt', !!Save * 3))
    
    Local R
    DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x0016, 'UInt', 0, 'UIntP', R, 'UInt', 0)

    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx




/*
    Recupera o establece el ajuste de velocidad de repetición del teclado.
    Parámetros:
        Value: El valor en el rango de 0 (aproximadamente 2,5 repeticiones por segundo) a 31 (aproximadamente 30 repeticiones por segundo). Vacío para recuperar el valor actual.
        Save : Determina si el nuevo valor establecido debe de ser permanente. De lo contrario, se restaurará al reiniciar el ordenador.
    Notas:
        Las tasas de repetición reales dependen del hardware y pueden variar desde una escala lineal en un 20%.
        Si Value es mayor que 31, el parámetro se establece en 31.
*/
KeyboardSpeed(Value := '', Save := FALSE)
{
    If (Value != '')
        Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x000B, 'UInt', Value, 'Ptr', 0, 'UInt', !!Save * 3))
    
    Local R
    DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x000A, 'UInt', 0, 'UIntP', R, 'UInt', 0)

    Return (R)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx




/*
    Envia distintas pulsaciones de teclas dependiendo el tiempo que se mantuvo presionada una tecla por el usuario.
    Parámetros:
        Keys     : Un array con las diferentes pulsaciones permitidas, en orden. La primera se enviará si el tiempo es menor a el valor especificado en el parámetro 'Interal'. La última se enviará si es mayor a Keys.Length()*Interval.
        Firstlast: Un array. El primer índice indica las teclas a enviar antes. El segudno índice indica las teclas a enviar después. Si se especifica una cadena, indica las teclas a enviar después.
        spkey    : La tecla a esperar que el usuario libere. Si se especifica una cadena vacía, se utiliza la tercera o primer palabra de A_ThisLabel (con prioridad en la tercera, para evitar teclas modificadoras).
        interval : El tiempo que indica el límite entre las diferentes pulsaciones, en milisegundos. Por defecto este valor es 250.
    Ejemplo:
        RAlt & 2::SendT(['“”', '«»'], '{left}')    ; permite utilizar dos tipos de comillas con una misma combinación de teclas, 'alt-derecho y 2'.
*/
SendT(keys, firstlast := '', spkey := '', interval := 250)
{
    Local start := A_TickCount
    KeyWait(spkey == '' ? (StrSplit(A_ThisLabel, A_Space)[3] ? StrSplit(A_ThisLabel, A_Space)[3] : StrSplit(A_ThisLabel, A_Space)[1]) : spkey)
    Local t     := Ceil((A_TickCount - start) / interval)
    keys        := IsObject(keys)      ? keys      : [keys]
    firstlast   := IsObject(firstlast) ? firstlast : ['', firstlast]
    SendInput(firstlast[1] . keys[t > keys.Length() ? keys.Length() : t] . firstlast[2])
}




/*
    Recupera el identificador de configuración regional de entrada activa (anteriormente denominado distribución de teclado).
    Parámetros:
        ThreadId: El identificador del thread a consultar, o 0 para el thread actual.
    Return:
        El valor de retorno es el identificador de locación de entrada para el thread especificado.
        El Low-Word contiene un identificador de idioma para el idioma de entrada. Puede obtenerlo con 'ReturnValue & 0xFFFF'.
        El High-Word contiene un identificador de dispositivo para la disposición física del teclado. Puede obtenerlo con 'ReturnValue >> 16'.
    Referencias:
        Language Identifier Constants and Strings: https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693(v=vs.85).aspx
    Ejemplo:
        MsgBox(Format("{:X}", GetKeyboardLayout() & 0xFFFF))
*/
GetKeyboardLayout(ThreadId := 0)
{
    Return (DllCall('User32.dll\GetKeyboardLayout', 'UInt', ThreadId, 'UInt'))
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646296(v=vs.85).aspx




/*
    Carga un nuevo identificador de configuración regional de entrada (anteriormente denominado distribución de teclado) en el sistema.
    Parámetros:
        LocaleID: El nombre del identificador de la configuración regional de entrada para cargar.
        Flags   : Especifica cómo se debe cargar el identificador de la configuración regional de entrada. Ver link para ver los valores disponibles.
    Return:
        Si la función tiene éxito, el valor de retorno es el identificador de la configuración regional de entrada correspondiente al nombre especificado en LocaleID.
        Si no hay una configuración regional coincidente disponible, el valor de retorno es el idioma predeterminado del sistema.
*/
LoadKeyboardLayout(LocaleID := 0x0800, Flags := 0)
{
    Return (DllCall('User32.dll\LoadKeyboardLayoutW', 'Str', Format('{:08x}', LocaleID), 'UInt', Flags, 'UInt'))
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646305(v=vs.85).aspx




/*
    Establece el idioma de entrada predeterminado para el sistema y las aplicaciones.
    Parámetros:
        LocaleID: El identificador de localización de entrada para el idioma predeterminado.
    Return:
        Si la función tiene éxito, el valor de retorno es un valor distinto de cero.
*/
SetKeyboardLayout(LocaleID)
{
    Local HKL
    VarSetCapacity(HKL, 4)
    NumPut(LocaleID, &HKL, 'UInt')

    Return (DllCall('User32.dll\SystemParametersInfoW', 'UInt', 0x005A, 'UInt', 0, 'UPtr', &HKL, 'UInt', 2))    ; SPI_SETDEFAULTINPUTLANG
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
