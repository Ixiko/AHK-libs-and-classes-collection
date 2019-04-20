/*
    Calcular la suma de verificación CRC32 de un bloque de bytes o de una cadena.
    Parámetros:
        Binary: Una dirección de memoria a un bloque de bytes o una cadena.
        Length: La longitud de Binary. Este parámetro es opcional si Binary es una cadena.
    Return:
        Si tuvo éxito devuelve un valor de tipo entero mayor que 0, caso contrario devuelve 0.
    Ejemplo:
        MsgBox(Format('0x{:X}', CRC32('<Hola Mundo!>')))
*/
CRC32(Binary, Length := 0)
{
    Local Buffer

    If (Type(Binary) == 'String')
    {
        If (Binary == '')
            Return (0)

        If (Length)
            Binary := SubStr(Binary, 1, Length)

        VarSetCapacity(Buffer
                     , Length := StrPut(Binary, 'UTF-8') - 1)

        StrPut(Binary, &Buffer, Length, 'UTF-8')
        Binary := &Buffer
    }

    Return (DllCall('Ntdll.dll\RtlComputeCrc32', 'UInt', 0       ;dwInitial
                                               , 'UPtr', Binary  ;pData
                                               , 'Int' , Length  ;iLen
                                               , 'UInt'))        ;ReturnType
} ;https://source.winehq.org/WineAPI/RtlComputeCrc32.html
