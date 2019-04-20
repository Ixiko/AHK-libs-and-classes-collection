/*
    Recupera los tributos de un archivo, directorio o unidad.
    Parámetros:
        Path: La ruta al archivo, directorio o unidad.
        Attributes: Devuelve una cadena con los atributos. Comprobar el valor de retorno para saber si la función tuvo éxito o no.
    Return:
        Si tuvo éxito devuelve un número entero positivo que identifica a los atributos, caso contrario devuelve -1.
        Los valores válidos son los siguientes:
            0x1     (R) = Solo lectura.
            0x2     (H) = Oculto.
            0x4     (S) = Sistema.
            0x10    (D) = Directorio.
            0x20    (A) = Archivo / Modificado.
            0x80    (N) = Normal.
            0x100   (T) = Temporal.
            0x800   (C) = Comprimido.
            0x1000  (O) = Fuera de línea.
            0x2000  (I) = No debe ser indexado por el servicio de indexación de contenido.
            0x4000  (E) = Encriptado.
            0x10000 (V) = Virtual.
    Ejemplo:
        MsgBox(GetFileAttributes(A_ComSpec, Attrib) . ' (' . Attrib . ')')
*/
GetFileAttributes(Path, ByRef Attributes := '')
{
    Local Attrib, Each, Value

    If ((Attrib := DllCall('Kernel32.dll\GetFileAttributesW', 'Str', StrLen(Path) < 4 ? SubStr(Path, 1, 1) . ':' : '\\?\' . Path, 'UInt')) == 0xFFFFFFFF)
        Return (-1)

    If (IsByRef(Attributes))
    {
        Attributes := ''
        For Each, Value in {A: 0x20, C: 0x800, D: 0x10, E: 0x4000, H: 0x2, I: 0x2000, N: 0x80, O: 0x1000, R: 0x1, S: 0x4, T: 0x100, V: 0x10000}
            If (Attrib & Value)
                Attributes .= Each
    }

    Return (Attrib)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa364944(v=vs.85).aspx
