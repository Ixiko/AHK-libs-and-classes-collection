/*
    Copia bytes entre búferes.
    Parámetros:
        Source  : El búfer del que copiar.
        Size    : El número de bytes que se copiará.
        Dest    : El búfer en el que copiar (destino).
        DestSize: El tamaño del búfer de destino, en bytes.
    Return:
        Devuelve cero si se ejecuta correctamente; devuelve un código de error si se produce un error.
    Ejemplo:
        String := "Hola Mundo!"
        Size   := StrLen(String) * 2
        VarSetCapacity(Dest, Size, 0)
        CopyMemory(&String, Size, &Dest)
        MsgBox(StrGet(&Dest, Size, 'UTF-16'))
*/
CopyMemory(Source, Size, Dest, DestSize := 0)
{
    Return (DllCall('msvcrt.dll\memcpy_s', 'UPtr', Dest, 'UPtr', DestSize ? DestSize : Size, 'UPtr', Source, 'UPtr', Size, 'Cdecl'))
} ;https://msdn.microsoft.com/es-ar/library/wes2t00f.aspx
