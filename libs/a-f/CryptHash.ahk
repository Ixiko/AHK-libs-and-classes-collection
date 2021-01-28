/*
    Encripta datos en el algoritmo especificado.
    Parámetros:
        Binary   : Una dirección de memoria o una cadena.
        Length   : La longitud de Binary. Este parámetro puede ser 0 si Binary es una cadena.
        Algorithm: El algoritmo utilizado para encriptar los datos. Este parámetro puede ser una de las siguientes cadenas:
            MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512 (https://msdn.microsoft.com/en-us/library/windows/desktop/aa375534(v=vs.85).aspx)
        MAC      : El proveedor realizará el algoritmo de código de autenticación de mensajes basado en hash (HMAC) con el algoritmo de hash especificado. Si este valor es de tipo entero y es 0, no se utiliza.
    Return:
        Si la función falla, devuelve una cadena vacía y ErrorLevel se establece en el código de error.
    Códigos de error:
        https://msdn.microsoft.com/en-us/library/cc704588.aspx.
    Ejemplos:
        MsgBox(CryptHash('Hola Mundo!', 0, 'SHA512'))
        MsgBox(CryptHash(&(B:=FileRead('*c ' . (F:=FileSelect()))), FileGetSize(F), 'MD5'))
*/
CryptHash(Binary, Length, Algorithm, MAC := 0)
{
    Local R, hAlgorithm, ObjectLength, BytesCopied, HashObject, Secret, Buffer, HashDigestLength, Data, Hash
        , pSecret := sSecret := 0
        , UseMAC  := Type(MAC) == 'Integer' && MAC == 0 ? FALSE : TRUE

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375479(v=vs.85).aspx
    R := DllCall('Bcrypt.dll\BCryptOpenAlgorithmProvider', 'PtrP', hAlgorithm                ;phAlgorithm
                                                         , 'Str' , Format('{:U}', Algorithm) ;pszAlgId
                                                         , 'Ptr' , 0                         ;pszAlgId
                                                         , 'UInt', UseMAC ? 8 : 0            ;pszImplementation --> BCRYPT_ALG_HANDLE_HMAC_FLAG : 0
                                                         , 'UInt')                           ;ReturnType
    If (R)
    {
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375464(v=vs.85).aspx
    R := DllCall('Bcrypt.dll\BCryptGetProperty', 'Ptr'  , hAlgorithm     ;hObject
                                               , 'Str'  , 'ObjectLength' ;pszProperty
                                               , 'UIntP', ObjectLength   ;pbOutput
                                               , 'UInt' , 4              ;cbOutput
                                               , 'UIntP', BytesCopied    ;pcbResult
                                               , 'UInt' , 0              ;dwFlags
                                               , 'UInt')                 ;ReturnType
    If (R)
    {
        DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375383(v=vs.85).aspx
    VarSetCapacity(HashObject, ObjectLength)
    If (UseMAC)
    {
        VarSetCapacity(Secret, sSecret := StrPut(MAC, 'UTF-8') - 1)
        StrPut(MAC, pSecret := &Secret, sSecret, 'UTF-8')
    }
    R := DllCall('Bcrypt.dll\BCryptCreateHash', 'Ptr' , hAlgorithm   ;hAlgorithm
                                              , 'PtrP', hHash        ;phHash
                                              , 'UPtr', &HashObject  ;pbHashObject
                                              , 'UInt', ObjectLength ;cbHashObject
                                              , 'Ptr' , pSecret      ;pbSecret
                                              , 'UInt', sSecret      ;cbSecret
                                              , 'UInt', 0            ;dwFlags
                                              , 'UInt')              ;ReturnType
    If (R)
    {
        DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375468(v=vs.85).aspx
    If (Type(Binary) == 'String')
    {
        If (Binary == '')
        {
            DllCall('Bcrypt.dll\BCryptDestroyHash', 'Ptr', hHash)
            DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
            ErrorLevel := -1
            Return ('')
        }

        If (Length)
            Binary := SubStr(Binary, 1, Length)

        VarSetCapacity(Buffer
                     , Length := StrPut(Binary, 'UTF-8') - 1)

        StrPut(Binary, &Buffer, Length, 'UTF-8')
        Binary := &Buffer
    }
    R := DllCall('Bcrypt.dll\BCryptHashData', 'Ptr' , hHash  ;hHash
                                            , 'UPtr', Binary ;pbInput
                                            , 'UInt', Length ;cbInput
                                            , 'UInt', 0      ;dwFlags
                                            , 'UInt')        ;ReturnType
    If (R)
    {

        DllCall('Bcrypt.dll\BCryptDestroyHash', 'Ptr', hHash)
        DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375464(v=vs.85).aspx
    R := DllCall('Bcrypt.dll\BCryptGetProperty', 'Ptr'  , hAlgorithm         ;hObject
                                               , 'Str'  , 'HashDigestLength' ;pszProperty
                                               , 'UIntP', HashDigestLength   ;pbOutput
                                               , 'UInt' , 4                  ;cbOutput
                                               , 'UIntP', BytesCopied        ;pcbResult
                                               , 'UInt' , 0                  ;dwFlags
                                               , 'UInt')                     ;ReturnType
    If (R)
    {

        DllCall('Bcrypt.dll\BCryptDestroyHash', 'Ptr', hHash)
        DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa375443(v=vs.85).aspx
    VarSetCapacity(Data, HashDigestLength)
    R := DllCall('Bcrypt.dll\BCryptFinishHash', 'Ptr' , hHash             ;hHash
                                              , 'UPtr', &Data             ;pbOutput
                                              , 'UInt', HashDigestLength  ;cbOutput
                                              , 'UInt', 0                 ;dwFlags
                                              , 'UInt')                   ;ReturnType
    If (R)
    {

        DllCall('Bcrypt.dll\BCryptDestroyHash', 'Ptr', hHash)
        DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
        ErrorLevel := Format('0x{:08X}', R)
        Return ('')
    }

    Loop (HashDigestLength)
        Hash .= Format('{:02X}', NumGet(&Data + A_Index - 1, 'UChar'))
    
    DllCall('Bcrypt.dll\BCryptDestroyHash', 'Ptr', hHash)
    DllCall('Bcrypt.dll\BCryptCloseAlgorithmProvider', 'Ptr', hAlgorithm, 'UInt', 0)
    
    ErrorLevel := 0
    Return (Hash)
}
