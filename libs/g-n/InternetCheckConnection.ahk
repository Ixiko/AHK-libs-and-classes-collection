/*
    Comprueba si se puede establecer una conexión a Internet en un URL específico.
    Parámetros:
        Url: El Url deseado. Si este valor es -1, se comprueba en 3 sitios WEB diferentes para comprobar si hay conexión a internet.
    Return:
        Si la conexión se realiza con éxito devuelve 1, o 0 en caso contrario.
*/
InternetCheckConnection(Url := -1)
{
    If (Url != -1)
        Return (DllCall('WinINet.dll\InternetCheckConnectionW', 'UPtr', &Url, 'UInt', 1, 'UInt', 0))

    Loop Parse, 'https://www.google.com/|https://www.facebook.com/|https://www.microsoft.com/', '|'
        If (!DllCall('WinINet.dll\InternetCheckConnectionW', 'Str', A_LoopField, 'UInt', 1, 'UInt', 0))
            Return (FALSE)

    Return (TRUE)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa384346(v=vs.85).aspx
