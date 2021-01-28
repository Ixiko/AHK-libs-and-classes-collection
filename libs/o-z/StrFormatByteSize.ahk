/*
    Convierte un valor numérico en una cadena que representa el número en bytes, kilobytes, megabytes o gigabytes, dependiendo del tamaño.
    Parámetros:
        Number: El valor numérico que se va a convertir.
        Flags: Especifica si redondear o truncar dígitos no visualizados.
            1 = Redondee al dígito más cercano mostrado.
            2 = Descarte los dígitos no mostrados.
    Ejemplo:
        MsgBox(StrFormatByteSize(1024 ** 2 * 67.7)) ;67.7 MB
*/
StrFormatByteSize(Number, Flags := 1)
{
    Local Buffer
    VarSetCapacity(Buffer, 30 * 2, 0)

    Local R := DllCall('Shlwapi.dll\StrFormatByteSizeEx', 'Int64', Number, 'UInt', Flags, 'UPtr', &Buffer, 'UInt', 30)
    
    Return (R == 0 ? StrGet(&Buffer, 'UTF-16') : '')
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb892884(v=vs.85).aspx
