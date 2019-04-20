class bcrypt
{
    static BCRYPT_OBJECT_LENGTH        := "ObjectLength"
    static BCRYPT_HASH_LENGTH          := "HashDigestLength"
    static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
    static hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr")

    hash(String, AlgID)
    {
        AlgID         := this.CheckAlgorithm(AlgID)
        ALG_HANDLE    := this.BCryptOpenAlgorithmProvider(AlgID)
        OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
        HASH_LENGTH   := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        HASH_HANDLE   := this.BCryptCreateHash(ALG_HANDLE, HASH_OBJECT, OBJECT_LENGTH)
        this.BCryptHashData(HASH_HANDLE, STRING)
        HASH_LENGTH   := this.BCryptFinishHash(HASH_HANDLE, HASH_LENGTH, HASH_DATA)
        hash          := this.CalcHash(HASH_DATA, HASH_LENGTH)
        this.DestroyHash(HASH_HANDLE)
        this.CloseAlgorithmProvider(ALG_HANDLE)
        return hash
    }

    hmac(String, Hmac, AlgID)
    {
        AlgID         := this.CheckAlgorithm(AlgID)
        ALG_HANDLE    := this.BCryptOpenAlgorithmProvider(AlgID, this.BCRYPT_ALG_HANDLE_HMAC_FLAG)
        OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
        HASH_LENGTH   := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        HASH_HANDLE   := this.BCryptCreateHmac(ALG_HANDLE, HMAC, HASH_OBJECT, OBJECT_LENGTH)
        this.BCryptHashData(HASH_HANDLE, STRING)
        HASH_LENGTH   := this.BCryptFinishHash(HASH_HANDLE, HASH_LENGTH, HASH_DATA)
        hash          := this.CalcHash(HASH_DATA, HASH_LENGTH)
        this.DestroyHash(HASH_HANDLE)
        this.CloseAlgorithmProvider(ALG_HANDLE)
        return hash
    }

    file(FileName, AlgID)
    {
        AlgID         := this.CheckAlgorithm(AlgID)
        ALG_HANDLE    := this.BCryptOpenAlgorithmProvider(AlgID)
        OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
        HASH_LENGTH   := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        HASH_HANDLE   := this.BCryptCreateHash(ALG_HANDLE, HASH_OBJECT, OBJECT_LENGTH)
        if !(IsObject(f := FileOpen(FileName, "r", "UTF-8")))
            throw Exception("Failed to open file: " FileName, -1)
        f.Seek(0)
        while (DATAREAD := f.RawRead(DATA, 262144))
            this.BCryptHashFile(HASH_HANDLE, DATA, DATAREAD)
        f.Close()
        HASH_LENGTH   := this.BCryptFinishHash(HASH_HANDLE, HASH_LENGTH, HASH_DATA)
        hash          := this.CalcHash(HASH_DATA, HASH_LENGTH)
        this.DestroyHash(HASH_HANDLE)
        this.CloseAlgorithmProvider(ALG_HANDLE)
        return hash
    }

    pbkdf2(Password, Salt, AlgID, Iterations := 1024, KeySize := 16)
    {
        AlgID       := this.CheckAlgorithm(AlgID)
        ALG_HANDLE  := this.BCryptOpenAlgorithmProvider(AlgID, this.BCRYPT_ALG_HANDLE_HMAC_FLAG)
        this.BCryptDeriveKeyPBKDF2(ALG_HANDLE, Password, Salt, Iterations, KeySize, PBKDF2_DATA)
        pbkdf2 := this.CalcHash(PBKDF2_DATA, KeySize)
        this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
        return pbkdf2
    }


    ; ===========================================================================================================================
    ; BCryptOpenAlgorithmProvider                                 https://msdn.microsoft.com/en-us/library/aa375479(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptOpenAlgorithmProvider(ALGORITHM, FLAGS := 0)
    {
        if (NT_STATUS  := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", BCRYPT_ALG_HANDLE
                                                                      , "ptr",  &ALGORITHM
                                                                      , "ptr",  0
                                                                      , "uint", FLAGS) != 0)
            throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)
        return BCRYPT_ALG_HANDLE
    }

    ; ===========================================================================================================================
    ; BCryptGetProperty                                           https://msdn.microsoft.com/en-us/library/aa375464(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptGetProperty(BCRYPT_HANDLE, PROPERTY, cbOutput)
    {
        if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr",   BCRYPT_HANDLE
                                                           , "ptr",   &PROPERTY
                                                           , "uint*", pbOutput
                                                           , "uint",  cbOutput
                                                           , "uint*", cbResult
                                                           , "uint",  0) != 0)
            throw Exception("BCryptGetProperty: " NT_STATUS, -1)
        return pbOutput
    }

    ; ===========================================================================================================================
    ; BCryptCreateHash                                            https://msdn.microsoft.com/en-us/library/aa375383(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptCreateHash(BCRYPT_ALG_HANDLE, ByRef pbHashObject, cbHashObject)
    {
        VarSetCapacity(pbHashObject, cbHashObject, 0)
        if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr",  BCRYPT_ALG_HANDLE
                                                          , "ptr*", BCRYPT_HASH_HANDLE
                                                          , "ptr",  &pbHashObject
                                                          , "uint", cbHashObject
                                                          , "ptr",  0
                                                          , "uint", 0
                                                          , "uint", 0) != 0)
            throw Exception("BCryptCreateHash: " NT_STATUS, -1)
        return BCRYPT_HASH_HANDLE
    }

    BCryptCreateHmac(BCRYPT_ALG_HANDLE, HMAC, ByRef pbHashObject, cbHashObject)
    {
        VarSetCapacity(pbHashObject, cbHashObject, 0)
        VarSetCapacity(pbSecret, StrPut(hmac, "UTF-8"), 0) && cbSecret := StrPut(hmac, &pbSecret, "UTF-8") - 1
        if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr",  BCRYPT_ALG_HANDLE
                                                          , "ptr*", BCRYPT_HASH_HANDLE
                                                          , "ptr",  &pbHashObject
                                                          , "uint", cbHashObject
                                                          , "ptr",  &pbSecret
                                                          , "uint", cbSecret
                                                          , "uint", 0) != 0)
            throw Exception("BCryptCreateHash: " NT_STATUS, -1)
        return BCRYPT_HASH_HANDLE
    }

    ; ===========================================================================================================================
    ; BCryptHashData                                              https://msdn.microsoft.com/en-us/library/aa375468(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptHashData(BCRYPT_HASH_HANDLE, STRING)
    {
        VarSetCapacity(pbInput, StrPut(string, "UTF-8"), 0) && cbInput := StrPut(string, &pbInput, "UTF-8") - 1
        if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr",  BCRYPT_HASH_HANDLE
                                                        , "ptr",  &pbInput
                                                        , "uint", cbInput
                                                        , "uint", 0) != 0)
            throw Exception("BCryptHashData: " NT_STATUS, -1)
        return true
    }

    BCryptHashFile(BCRYPT_HASH_HANDLE, pbInput, cbInput)
    {
        if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr",  BCRYPT_HASH_HANDLE
                                                        , "ptr",  &pbInput
                                                        , "uint", cbInput
                                                        , "uint", 0) != 0)
            throw Exception("BCryptHashData: " NT_STATUS, -1)
        return true
    }

    ; ===========================================================================================================================
    ; BCryptFinishHash                                            https://msdn.microsoft.com/en-us/library/aa375443(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptFinishHash(BCRYPT_HASH_HANDLE, cbOutput, ByRef pbOutput)
    {
        VarSetCapacity(pbOutput, cbOutput, 0)
        if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr",  BCRYPT_HASH_HANDLE
                                                          , "ptr",  &pbOutput
                                                          , "uint", cbOutput
                                                          , "uint", 0) != 0)
            throw Exception("BCryptFinishHash: " NT_STATUS, -1)
        return cbOutput
    }

    ; ===========================================================================================================================
    ; BCryptDeriveKeyPBKDF2                                                 https://msdn.com/en-us/library/dd433795(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptDeriveKeyPBKDF2(BCRYPT_ALG_HANDLE, PASS, SALT, cIterations, cbDerivedKey, ByRef pbDerivedKey)
    {
        VarSetCapacity(pbDerivedKey, cbDerivedKey, 0)
        VarSetCapacity(pbPassword, StrPut(PASS, "UTF-8"), 0) && cbPassword := StrPut(PASS, &pbPassword, "UTF-8") - 1
        VarSetCapacity(pbSalt,     StrPut(SALT, "UTF-8"), 0) && cbSalt :=     StrPut(SALT, &pbSalt,     "UTF-8") - 1
        if (NT_STATUS := DllCall("bcrypt\BCryptDeriveKeyPBKDF2", "ptr",   BCRYPT_ALG_HANDLE
                                                               , "ptr",   &pbPassword
                                                               , "uint",  cbPassword
                                                               , "ptr",   &pbSalt
                                                               , "uint",  cbSalt
                                                               , "int64", cIterations
                                                               , "ptr",   &pbDerivedKey
                                                               , "uint",  cbDerivedKey
                                                               , "uint",  0) != 0)
            throw Exception("BCryptDeriveKeyPBKDF2: " NT_STATUS, -1)
        return true
    }

    ; ===========================================================================================================================
    ; BCryptDestroyHash                                           https://msdn.microsoft.com/en-us/library/aa375399(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptDestroyHash(BCRYPT_HASH_HANDLE)
    {
        if (NT_STATUS := DllCall("bcrypt\BCryptDestroyHash", "ptr", BCRYPT_HASH_HANDLE) != 0)
            throw Exception("BCryptDestroyHash: " NT_STATUS, -1)
        return true
    }

    ; ===========================================================================================================================
    ; BCryptCloseAlgorithmProvider                                https://msdn.microsoft.com/en-us/library/aa375377(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptCloseAlgorithmProvider(BCRYPT_ALG_HANDLE)
    {
        if (NT_STATUS := DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr",  BCRYPT_ALG_HANDLE
                                                                      , "uint", 0) != 0)
            throw Exception("BCryptCloseAlgorithmProvider: " NT_STATUS, -1)
        return true
    }


    ; ===========================================================================================================================
    ; For Internal Use Only
    ; ===========================================================================================================================
    CheckAlgorithm(ALGORITHM)
    {
        static HASH_ALGORITHM := ["MD2", "MD4", "MD5", "SHA1", "SHA256", "SHA384", "SHA512"]
        for index, value in HASH_ALGORITHM
            if (value = ALGORITHM)
                return this.CharUpper(ALGORITHM)
        throw Exception("Invalid hash algorithm", -1, ALGORITHM)
    }

    CharUpper(lpsz)
    {
        DllCall("user32.dll\CharUpper", "str", lpsz, "str")
        return lpsz
    }

    CalcHash(Byref HASH_DATA, HASH_LENGTH)
    {
        loop % HASH_LENGTH
            HASH .= Format("{:02x}", NumGet(HASH_DATA, A_Index - 1, "uchar"))
        return HASH
    }
}