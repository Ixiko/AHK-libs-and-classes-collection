/*
    Determina si un archivo es un archivo ejecutable (.exe) y, en caso afirmativo, qué subsistema ejecuta el archivo ejecutable.
    Parámetros:
        ApplicationName: La ruta completa del archivo cuyo tipo ejecutable debe determinarse.
    Return:
        -1 = El archivo no es un ejecutable.
         0 = SCS_32BIT_BINARY. Una aplicación basada en Windows de 32-Bit.
         1 = SCS_DOS_BINARY.   Una aplicación basada en MS-DOS.
         2 = SCS_WOW_BINARY.   Una aplicación basada en Windows de 16-Bit.
         3 = SCS_PIF_BINARY.   Un archivo PIF que ejecuta una aplicación basada en MS-DOS.
         4 = SCS_POSIX_BINARY. Una aplicación basada en POSIX.
         5 = SCS_OS216_BINARY. Una aplicación basada en 16-Bit OS/2.
         6 = SCS_64BIT_BINARY. Una aplicación basada en Windows de 64-Bit.
    Ejemplo:
        MsgBox(GetBinaryType(FileSelect()))
*/
GetBinaryType(ApplicationName)
{
    Local BinaryType

    Return (DllCall('Kernel32.dll\GetBinaryTypeW', 'UPtr', &ApplicationName, 'UIntP', BinaryType) ? BinaryType : -1)
} ;https://msdn.microsoft.com/en-us/library/aa364819(VS.85).aspx
