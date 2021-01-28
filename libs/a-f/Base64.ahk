/*
    Codifica una cadena o datos binarios en base 64.
    Parámetros:
        Binary: La cadena de caracteres o la direccion de memoria con los datos binarios.
        Length: La longitud de Binary. Este parámetro es opcional si Binary es una cadena.
    Return:
        Si tuvo éxito devuelve la cadena codificada, caso contrario devuelve una cadena vacía.
    Ejemplo 1:
        String  := '<Hola Mundo!>'
        Encoded := Base64Encode(String)
        Decoded := Base64Decode(Encoded)
        MsgBox('String: ' . String . '`nEncoded: ' . Encoded . '`nDecoded: ' . Decoded)
    Ejemplo 2:
        File := FileOpen(FileSelect(3), 'r')
        File.RawRead(Binary, File.Length)
        FileOpen(A_Desktop . '\~e_tmp.txt', 'w').Write(Base64Encode(&Binary, File.Length))
        File.Close()
        Enc  := FileOpen(A_Desktop . '\~e_tmp.txt', 'r').Read()
        Base64Decode(Enc, Binary, Size)
        FileOpen(A_Desktop . '\~d_tmp.txt', 'w').RawWrite(&Binary, Size)
        File.Close()
*/
Base64Encode(Binary, Length := 0)
{
    Local Size, BASE_64, R, Buffer

    If (Type(Binary) == 'String')
    {
        If (Binary == '')
            Return ('')

        If (Length)
            Binary := SubStr(Binary, 1, Length)

        VarSetCapacity(Buffer
                     , Length := StrPut(Binary, 'UTF-8') - 1)

        StrPut(Binary, &Buffer, Length, 'UTF-8')
        Binary := &Buffer
    }

    DllCall('Crypt32.dll\CryptBinaryToStringW', 'UPtr', Binary  ;pbBinary
                                              , 'UInt', Length  ;cbBinary
                                              , 'UInt', 0x1     ;dwFlags    --> CRYPT_STRING_BASE64
                                              , 'Ptr' , 0       ;pszString
                                              , 'UIntP', Size)  ;pcchString

    If (!VarSetCapacity(BASE_64, Size * 2))
        Return ('')

    R := DllCall('Crypt32.dll\CryptBinaryToStringW', 'UPtr', Binary         ;pbBinary
                                                   , 'UInt', Length         ;cbBinary
                                                   , 'UInt', 0x1|0x40000000 ;dwFlags    --> CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
                                                   , 'UPtr', &BASE_64       ;pszString
                                                   , 'UIntP', Size)         ;pcchString

    Return (R ? StrGet(&BASE_64, Size, 'UTF-16') : '')
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa379887(v=vs.85).aspx




/*
    Decodifica una cadena codificada en base 64.
    Parámetros:
        String: La cadena codificada en base 64 a decodificar.
        Binary: Devuelve los datos binarios decodificados. Si no se utiliza este parámetro, la función devuelve los datos decodificados como una cadena.
        Size  : Devuelve el tamaño de Binary, en bytes.
    Return:
        Si Binary no se utiliza, devuelve la cadena decodificada si tuvo éxito o una cadena vacía si hubo un error.
        Caso contrario devuelve 1 si tuvo éxito o 0 si hubo un error.
*/
Base64Decode(String, ByRef Binary := '', ByRef Size := '')
{
    Local R

    DllCall('Crypt32.dll\CryptStringToBinaryW', 'UPtr' , &String ;pszString
                                              , 'UInt' , 0       ;cchString
                                              , 'UInt' , 0x1     ;dwFlags   --> CRYPT_STRING_BASE64
                                              , 'Ptr'  , 0       ;pbBinary
                                              , 'UIntP', Size    ;pcbBinary
                                              , 'UIntP', 0       ;pdwSkip
                                              , 'UIntP', 0)      ;pdwFlags

    If (!VarSetCapacity(Binary, Size))
        Return (IsByRef(Binary) ? FALSE : '')

    R := DllCall('Crypt32.dll\CryptStringToBinaryW', 'UPtr' , &String ;pszString
                                                   , 'UInt' , 0       ;cchString
                                                   , 'UInt' , 0x1     ;dwFlags   --> CRYPT_STRING_BASE64
                                                   , 'UPtr' , &Binary ;pbBinary
                                                   , 'UIntP', Size    ;pcbBinary
                                                   , 'UIntP', 0       ;pdwSkip
                                                   , 'UIntP', 0)      ;pdwFlags

    Return (IsByRef(Binary) ? R : StrGet(&Binary, Size, 'UTF-8'))
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa380285(v=vs.85).aspx




/*
    Convierte una cadena codificada en base 64 a un SafeArray para usar con COM.
    Parámetros:
        String: La cadena codificada en base 64 a convertir.
        ArrayObj: Devuelve un objeto que contiene el SafeArray.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
*/
Base64ToArrayObj(String, ByRef ArrayObj)
{ 
    Local Size, R

    R := DllCall('Crypt32.dll\CryptStringToBinaryW', 'UPtr' , &String ;pszString
                                                   , 'UInt' , 0       ;cchString
                                                   , 'UInt' , 0x1     ;dwFlags   --> CRYPT_STRING_BASE64
                                                   , 'Ptr'  , 0       ;pbBinary
                                                   , 'UIntP', Size    ;pcbBinary
                                                   , 'UIntP', 0       ;pdwSkip
                                                   , 'UIntP', 0)      ;pdwFlags

    If (!R)
        Return (FALSE)

    ArrayObj := ComObjArray(0x11  ;VarType --> VT_UI1 (8-bit unsigned int)
                          , Size) ;CountN  --> (size of each dimension)

    R := DllCall('Crypt32.dll\CryptStringToBinaryW', 'UPtr' , &String                                        ;pszString
                                                   , 'UInt' , 0                                              ;cchString
                                                   , 'UInt' , 0x1                                            ;dwFlags   --> CRYPT_STRING_BASE64
                                                   , 'UPtr' , NumGet(ComObjValue(ArrayObj) + 8 + A_PtrSize)  ;pbBinary
                                                   , 'UIntP', Size                                           ;pcbBinary
                                                   , 'UIntP', 0                                              ;pdwSkip
                                                   , 'UIntP', 0)                                             ;pdwFlags

    Return (R)
} ;Credits: By SKAN - https://msdn.microsoft.com/en-us/library/windows/desktop/aa380285(v=vs.85).aspx
