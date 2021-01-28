/*
    Determina si el Token está elevado. Puede utilizar esta función para determinar si un proceso tiene permisos administrativos.
    Parámetros:
        hToken: El token de acceso.
    Return:
        -1 = Ha ocurrido un error al llamar a GetTokenInformation.
         0 = El Token no tiene privilegis administrativos.
         1 = El Token tiene privilegis administrativos.

    Acceso requerido:
        0x0008 = TOKEN_QUERY
*/
TokenIsElevated(hToken)
{
    Local TokenIsElevated, ReturnLength
    Return DllCall("Advapi32.dll\GetTokenInformation", "Ptr", hToken, "Int", 20, "UIntP", TokenIsElevated, "UInt", 4, "UIntP", ReturnLength) ? TokenIsElevated : -1
}
