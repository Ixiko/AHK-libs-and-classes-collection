/*
    Abre el token de acceso asociado con un proceso.
    Parámetros:
        hProcess     : El identificador del proceso.
        DesiredAccess: El tipo de acceso deseado.
            0x0001     = TOKEN_ASSIGN_PRIMARY
            0x0002     = TOKEN_DUPLICATE
            0x0004     = TOKEN_IMPERSONATE
            0x0008     = TOKEN_QUERY
            0x0010     = TOKEN_QUERY_SOURCE
            0x0020     = TOKEN_ADJUST_PRIVILEGES
            0x0040     = TOKEN_ADJUST_GROUPS
            0x0080     = TOKEN_ADJUST_DEFAULT
            0x0100     = TOKEN_ADJUST_SESSIONID
            0x00020000 = STANDARD_RIGHTS_READ
            0x000F0000 = STANDARD_RIGHTS_REQUIRED
    Return:
        0       = Ha ocurrido un error al abrir el token de acceso para este proceso.
        [token] = Si tuvo éxito devuelve el identificador del token de acceso recién abierto.
    Acceso requerido:
        0x400 = PROCESS_QUERY_INFORMATION.
    Accesos:
        https://msdn.microsoft.com/en-us/library/windows/desktop/aa374905(v=vs.85).aspx
*/
OpenProcessToken(hProcess, DesiredAccess)
{
    Local hToken
    DllCall('Advapi32.dll\OpenProcessToken', 'Ptr', hProcess, 'UInt', DesiredAccess, 'PtrP', hToken)
    
    Return (hToken)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa379295(v=vs.85).aspx
