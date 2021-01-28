/*
    Genera un número pseudo-aleatorio de punto flotante en el rango especificado.
    Parámetros:
        Min  : El valor mínimo. Este valor puede ser de punto flotante.
        Max  : El valor máximo. Este valor puede ser de punto flotante.
        Float: Determina la longitud decimal del valor devuelto. 0 indica que se va a devolver un valor de tipo entero. -1 indica la cantidad máxima de decimales.
    Return:
        [str] = Si la función falla devuelve una cadena vacía.
        [num] = Si tuvo éxito devuelve un valor de tipo 'Float' o 'Integer' comprendido entre Min y Max (inclusive).
    Observaciones:
        El valor máximo de Float es 17, el mínimo es 0, y -1 para no utilizar Round.
    Ejemplo 1 (números de tipo Float):
        Loop (10)
            Numbers .= RandomEx(0.5, 1, 17) . '  |  ' . RandomEx(0.5, 1, 17) . '`n'
        MsgBox(Numbers)
    Ejemplo 2 (números enteros):
        Loop (10)
            Numbers .= RandomEx(10, 99, 0) . '  |  ' . RandomEx(10, 99, 0) . '`n'
        MsgBox(Numbers)
    Ejemplo 3 (caracteres):
        Loop (20)
        {
            Numbers .= '|`t'
            Loop (5)
                Numbers .= Chr(RandomEx(65, 90, 0)) . '`t|`t'
            Numbers .= '`n'
        }
        MsgBox(Numbers)
*/
RandomEx(Min, Max, Float := -1)
{
    Local hCryptProv, Buffer
        , Bits  := 52
        , Bytes := Ceil((Bits := 52) / 8)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa379886(v=vs.85).aspx
    If (!DllCall('Advapi32.dll\CryptAcquireContextW', 'PtrP', hCryptProv   ;phProv
                                                    , 'Ptr' , 0            ;pszContainer
                                                    , 'Ptr' , 0            ;pszProvider
                                                    , 'UInt', 1            ;dwProvType
                                                    , 'UInt', 0xF0000040)) ;dwFlags
        Return ('')

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa379942(v=vs.85).aspx
    VarSetCapacity(Buffer, Bytes)
    DllCall('Advapi32.dll\CryptGenRandom', 'Ptr' , hCryptProv ;hProv
                                         , 'UInt', Bytes      ;dwLen
                                         , 'Ptr' , &Buffer)   ;pbBuffer

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa380268(v=vs.85).aspx
    DllCall('Advapi32.dll\CryptReleaseContext', 'Ptr' , hCryptProv ;hProv
                                              , 'UInt', 0)         ;dwFlags (Reserved)

    NumPut(((0xFF >> (7-Mod(Bits-1, 8))) & NumGet(&Buffer, Bytes-1, 'UChar')), &Buffer, Bytes-1, 'UChar')
    Value := ((NumGet(Buffer, 0, 'UInt64') / 0xFFFFFFFFFFFFF) * (Max - Min)) + Min

    Return (Float == -1 ? Value : Round(Value, Float))
} ;http://www.autohotkey.com/board/topic/70530-random-number-crypt-secure-rand-numberbuffer/
