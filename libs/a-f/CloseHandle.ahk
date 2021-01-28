/*
    Cierra un identificador de objeto abierto.
    Parámetros:
        Handle: Un identificador válido para un objeto abierto.
    Return:
        Si tuvo éxito devuelve un valor distinto de 0, caso contrario devuelve 0. A_LastError contiene detalles del error.
*/
CloseHandle(Handle)
{
    Return (DllCall('Kernel32.dll\CloseHandle', 'Ptr', Handle))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
