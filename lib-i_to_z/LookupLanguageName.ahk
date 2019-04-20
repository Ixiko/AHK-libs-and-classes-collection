/*
    Recupera la descripción para el idioma asociado con un identificador de idioma Microsoft.
    Parámetros:
        LangCP: El identificador del idioma (https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693(v=vs.85).aspx).
    Return:
        Si tuvo éxito devuelve la descripción del idioma especificado, caso contrario devuelve una cadena vacía.
    Ejemplo:
        MsgBox('A_Language (#' . A_Language . '): ' . VerLanguageName('0x' . A_Language) . '`n#1401: ' . VerLanguageName(0x1401))
*/
LookupLanguageName(LangCP)
{
    Local Buffer
    
    VarSetCapacity(Buffer, 500, 0)

    If (!DllCall('Version.dll\VerLanguageNameW', 'UInt', LangCP, 'UPtr', &Buffer, 'UInt', 250))
        Return ('')

    Return (StrGet(&Buffer, 'UTF-16'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms647463(v=vs.85).aspx
