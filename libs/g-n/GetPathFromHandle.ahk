/*
    Recupera la ruta del archivo a partir de un identificador a un archivo.
    Parámetros:
        hFile: El identificador del archivo.
    Return:
        0     = Ha ocurrido un error al intenta recuperar la ruta.
        [str] = Si tuvo éxito devuelve la ruta.
    Ejemplo:
        MsgBox(GetPathFromHandle(FileOpen(A_ComSpec, 'r').__Handle))
*/
GetPathFromHandle(hFile)
{
    Local Buffer
    
    VarSetCapacity(Buffer, 4000)
    If (!DllCall('Kernel32.dll\GetFinalPathNameByHandleW', 'Ptr', hFile, 'UPtr', &Buffer, 'UInt', 2000, 'UInt', 0))
        Return (0)

    Return (LTrim(StrGet(&Buffer, 'UTF-16'), '\\?\'))
} ;https://msdn.microsoft.com/en-us/library/aa364962.aspx
