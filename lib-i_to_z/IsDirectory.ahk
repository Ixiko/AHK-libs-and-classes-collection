/*
    Determina si el directorio especificado existe y si está vacío o no.
    Parámetros:
        DirName: La ruta del directorio a comprobar.
    Return:
        0 = El directorio no existe.
        1 = El directorio existe y contiene por lo menos un archivo o un directorio.
        2 = El directorio existe y esta vacío.
*/ 
IsDirectory(DirName)
{
    Return (DllCall('Shlwapi.dll\PathIsDirectoryEmptyW', 'UPtr', &DirName) ? 2 : (A_LastError == 3 ? 0 : 1))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/bb773623(v=vs.85).aspx
