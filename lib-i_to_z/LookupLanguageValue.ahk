/*
    Recupera el identificador para la descripción de idioma especificada.
    Parámetros:
        LanguageName: La descripción del lenguaje.
    Return:
        Si tuvo éxito devuelve el identificador del idioma, caso contrario devuelve 0.
    Ejemplo:
        MsgBox(LookupLanguageValue('Español (España, internacional)'))
        MsgBox(LookupLanguageValue('España, internacional'))
        MsgBox(LookupLanguageValue('España'))
        MsgBox(LookupLanguageValue('Español'))
*/
LookupLanguageValue(LanguageName)
{
    Local Buffer, Size, LangCP, LangName
        , List := {}

    VarSetCapacity(Buffer, 500, 0)

    Loop (0x500A)
    {
        If (Size := DllCall('Version.dll\VerLanguageNameW', 'UInt', A_Index, 'UPtr', &Buffer, 'UInt', 250))
        {
            List[A_Index] := StrGet(&Buffer, Size, 'UTF-16')

            If (List[A_Index] = LanguageName)
                Return (Format('0x{:04X}', A_Index))
        }
    }
    
    For LangCP, LangName In List
        If (InStr(LangName, LanguageName))
            Return (Format('0x{:04X}', LangCP))

    Return (0)
}
