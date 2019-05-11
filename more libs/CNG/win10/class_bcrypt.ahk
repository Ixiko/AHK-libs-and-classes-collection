MsgBox % bcrypt.hash("The quick brown fox jumps over the lazy dog", "MD5")
; ==> 9e107d9d372bb6826bd81d3542a419d6
MsgBox % bcrypt.hash("The quick brown fox jumps over the lazy dog", "SHA512")
; ==> 07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6

MsgBox % bcrypt.hmac("The quick brown fox jumps over the lazy dog", "Secret Salt", "MD5")
; ==> ad8af8953b9f7f880887ab3bd7a7674a
MsgBox % bcrypt.hmac("The quick brown fox jumps over the lazy dog", "Secret Salt", "SHA512")
; ==> 8ba0777b278b406b07df08150b98d2c57c68f83a980088e3011f76ea8e6d26b84244a678218408e97066d8dfe8aee20569044d214131327b016ea69a487ef471

MsgBox % bcrypt.file("C:\Windows\notepad.exe", "SHA1")
; ==> 40f2e778cf1effa957c719d2398e641eff20e613
MsgBox % bcrypt.file("C:\Windows\notepad.exe", "SHA256")
; ==> da0acee8f60a460cfb5249e262d3d53211ebc4c777579e99c8202b761541110a

MsgBox % bcrypt.pbkdf2("The quick brown fox jumps over the lazy dog", "Secret Salt", "SHA1",   2048, 20)
; ==> e6a412953bd433ba982fb77051f130af94c10304
MsgBox % bcrypt.pbkdf2("The quick brown fox jumps over the lazy dog", "Secret Salt", "SHA256", 4096, 32)
; ==> 70497e570c8cbe1c486e7f6ce755df4f5535dbe16e84337eb04946b1267b0d9d



class bcrypt
{
    static BCRYPT_HASH_LENGTH          := "HashDigestLength"
    static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
    static hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr")

    hash(String, AlgID)
    {
        AlgID       := this.CheckAlgorithm(AlgID)
        ALG_HANDLE  := this.BCryptOpenAlgorithmProvider(AlgID)
        HASH_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        this.BCryptHash(ALG_HANDLE, String, HASH_LENGTH, HASH_DATA)
        hash := this.CalcHash(HASH_DATA, HASH_LENGTH)
        this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
        return hash
    }

    hmac(String, Salt, AlgID)
    {
        AlgID       := this.CheckAlgorithm(AlgID)
        ALG_HANDLE  := this.BCryptOpenAlgorithmProvider(AlgID, this.BCRYPT_ALG_HANDLE_HMAC_FLAG)
        HASH_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        this.BCryptHmac(ALG_HANDLE, String, Salt, HASH_LENGTH, HMAC_DATA)
        hmac := this.CalcHash(HMAC_DATA, HASH_LENGTH)
        this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
        return hmac
    }

    file(FileName, AlgID)
    {
        AlgID       := this.CheckAlgorithm(AlgID)
        ALG_HANDLE  := this.BCryptOpenAlgorithmProvider(AlgID)
        HASH_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_HASH_LENGTH, 4)
        if !(IsObject(f := FileOpen(FileName, "r", "UTF-8")))
            throw Exception("Failed to open file: " FileName, -1)
        f.Seek(0)
        while (DATAREAD := f.RawRead(DATA, 262144))
            this.BCryptFile(ALG_HANDLE, DATA, DATAREAD, HASH_LENGTH, HASH_DATA)
        f.Close()
        hash := this.CalcHash(HASH_DATA, HASH_LENGTH)
        this.BCryptCloseAlgorithmProvider(ALG_HANDLE)
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
    ; BCryptHash                                                  https://msdn.microsoft.com/en-us/library/mt633798(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptHash(BCRYPT_ALG_HANDLE, STRING, cbOutput, ByRef pbOutput)
    {
        VarSetCapacity(pbOutput, cbOutput, 0)
        VarSetCapacity(pbInput, StrPut(STRING, "UTF-8"), 0) && cbInput := StrPut(STRING, &pbInput,  "UTF-8") - 1
        if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr",  BCRYPT_ALG_HANDLE
                                                    , "ptr",  0
                                                    , "uint", 0
                                                    , "ptr",  &pbInput
                                                    , "uint", cbInput
                                                    , "ptr",  &pbOutput
                                                    , "uint", cbOutput) != 0)
            throw Exception("BCryptHash: " NT_STATUS, -1)
        return true
    }

    BCryptHmac(BCRYPT_ALG_HANDLE, STRING, SALT, cbOutput, ByRef pbOutput)
    {
        VarSetCapacity(pbOutput, cbOutput, 0)
        VarSetCapacity(pbSecret, StrPut(SALT, "UTF-8"), 0)   && cbSecret := StrPut(SALT,   &pbSecret, "UTF-8") - 1
        VarSetCapacity(pbInput,  StrPut(STRING, "UTF-8"), 0) && cbInput  := StrPut(STRING, &pbInput,  "UTF-8") - 1
        if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr",  BCRYPT_ALG_HANDLE
                                                    , "ptr",  &pbSecret
                                                    , "uint", cbSecret
                                                    , "ptr",  &pbInput
                                                    , "uint", cbInput
                                                    , "ptr",  &pbOutput
                                                    , "uint", cbOutput) != 0)
            throw Exception("BCryptHash: " NT_STATUS, -1)
        return true
    }

    BCryptFile(BCRYPT_ALG_HANDLE, pbInput, cbInput, cbOutput, ByRef pbOutput)
    {
        VarSetCapacity(pbOutput, cbOutput, 0)
        if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr",  BCRYPT_ALG_HANDLE
                                                    , "ptr",  0
                                                    , "uint", 0
                                                    , "ptr",  &pbInput
                                                    , "uint", cbInput
                                                    , "ptr",  &pbOutput
                                                    , "uint", cbOutput) != 0)
            throw Exception("BCryptHash: " NT_STATUS, -1)
        return true
    }

    ; ===========================================================================================================================
    ; BCryptDeriveKeyPBKDF2                                                 https://msdn.com/en-us/library/dd433795(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptDeriveKeyPBKDF2(BCRYPT_ALG_HANDLE, PASS, SALT, cIterations, cbDerivedKey, ByRef pbDerivedKey)
    {
        VarSetCapacity(pbDerivedKey, cbDerivedKey, 0)
        VarSetCapacity(pbPassword, cbPassword := StrPut(PASS, "UTF-8"), 0) && StrPut(PASS, &pbPassword, "UTF-8"), cbPassword--
        VarSetCapacity(pbSalt,     cbSalt     := StrPut(SALT, "UTF-8"), 0) && StrPut(SALT, &pbSalt,     "UTF-8"), cbSalt--
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