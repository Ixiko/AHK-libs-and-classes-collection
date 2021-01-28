/*
    Establece los atributos de un archivo o directorio.
    Parámetros:
        Path      : La ruta al archivo o directorio.
        Attributes: Un valor o una cadena con los atributos. Los valores válidos son los siguientes:
            0x1     (R) = Solo lectura.
            0x2     (H) = Oculto.
            0x4     (S) = Sistema.
            0x20    (A) = Archivo / Modificado.
            0x80    (N) = Normal. No se puede combinar con ningún otro. [este es el valor por defecto]
            0x100   (T) = Temporal.
            0x1000  (O) = Fuera de línea.
            0x2000  (I) = No debe ser indexado por el servicio de indexación de contenido.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
SetFileAttributes(Path, Attributes := 0x80)
{
    Local Each, Value
        , Attrib := Attributes

    If (Type(Attributes) == 'String')
    {
        Attrib := 0
        For Each, Value In {A: 0x20, H: 0x2, I: 0x2000, N: 0x80, O: 0x1000, R: 0x1, S: 0x4, T: 0x100}
            If (InStr(Attributes, Each))
                Attrib |= Value
    }
    
    Return (Attrib ? DllCall('Kernel32.dll\SetFileAttributesW', 'UPtr', &Path, 'UInt', Attrib) : FALSE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa365535(v=vs.85).aspx
