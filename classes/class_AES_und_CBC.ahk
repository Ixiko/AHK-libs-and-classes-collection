
/*
MsgBox % crypt := bcrypt.encrypt("Doc", "1234567890123456", "1234567890123456")      ; -> M2cFdiHmDWH4GOQkOkJ8SAhvctZtGEKFIlDH8WMGgXM=
MsgBox % bcrypt.decrypt(crypt, "1234567890123456", "1234567890123456")                            ; -> abcdefghijklmnop

MsgBox % crypt := bcrypt.encrypt("abcdefghijklmnop", "1234567890123456", "6543210987654321")      ; -> SI2m575ae8OfJuJhsF8cqNGKhWJDGRynqWAIglrusBI=
MsgBox % bcrypt.decrypt(crypt, "1234567890123456", "6543210987654321")                            ; -> abcdefghijklmnop
*/

class bcrypt {
    static BCRYPT_AES_ALGORITHM   := "AES"
    static BCRYPT_OBJECT_LENGTH   := "ObjectLength"
    static BCRYPT_BLOCK_LENGTH    := "BlockLength"
    static BCRYPT_CHAINING_MODE   := "ChainingMode"
    static BCRYPT_CHAIN_MODE_CBC  := "ChainingModeCBC"
    static BCRYPT_OPAQUE_KEY_BLOB := "OpaqueKeyBlob"
    static BCRYPT_BLOCK_PADDING   := 0x00000001
    static hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr")

    encrypt(string, iv, key)
    {
        ALG_HANDLE    := this.BCryptOpenAlgorithmProvider(this.BCRYPT_AES_ALGORITHM)
        OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
        BLOCK_LENGTH  := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_BLOCK_LENGTH, 4)
        this.BCryptSetProperty(ALG_HANDLE, this.BCRYPT_CHAINING_MODE, this.BCRYPT_CHAIN_MODE_CBC)
        KEY_HANDLE    := this.BCryptGenerateSymmetricKey(ALG_HANDLE, KEY, KEY_OBJECT, OBJECT_LENGTH)
        CIPHER_LENGTH := this.BCryptEncrypt(KEY_HANDLE, STRING, IV, BLOCK_LENGTH, CIPHER_DATA)
		encryption    := this.b64Encode(CIPHER_DATA, CIPHER_LENGTH)
        this.BCryptDestroyKey(KEY_HANDLE)
        this.CloseAlgorithmProvider(ALG_HANDLE)
        return encryption
    }

    decrypt(string, iv, key)
    {
        ALG_HANDLE    := this.BCryptOpenAlgorithmProvider(this.BCRYPT_AES_ALGORITHM)
        OBJECT_LENGTH := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_OBJECT_LENGTH, 4)
        BLOCK_LENGTH  := this.BCryptGetProperty(ALG_HANDLE, this.BCRYPT_BLOCK_LENGTH, 4)
        this.BCryptSetProperty(ALG_HANDLE, this.BCRYPT_CHAINING_MODE, this.BCRYPT_CHAIN_MODE_CBC)
        KEY_HANDLE    := this.BCryptGenerateSymmetricKey(ALG_HANDLE, KEY, KEY_OBJECT, OBJECT_LENGTH)
		len := this.b64Decode(string, buf)
        CIPHER_LENGTH := this.BCryptDecrypt(KEY_HANDLE, buf, len, IV, BLOCK_LENGTH, CIPHER_DATA)
        this.BCryptDestroyKey(KEY_HANDLE)
        this.CloseAlgorithmProvider(ALG_HANDLE)
        return StrGet(&CIPHER_DATA, CIPHER_LENGTH /= 2, "utf-16")
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
    ; BCryptSetProperty                                           https://msdn.microsoft.com/en-us/library/aa375504(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptSetProperty(BCRYPT_HANDLE, PROPERTY, pbInput)
    {
        if (NT_STATUS := DllCall("bcrypt\BCryptSetProperty", "ptr",  BCRYPT_HANDLE
                                                           , "ptr",  &PROPERTY
                                                           , "ptr",  &pbInput
                                                           , "uint", StrLen(pbInput)
                                                           , "uint", 0) != 0)
            throw Exception("BCryptSetProperty: " NT_STATUS, -1)
        return true
    }

    ; ===========================================================================================================================
    ; BCryptGenerateSymmetricKey                                  https://msdn.microsoft.com/en-us/library/aa375453(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptGenerateSymmetricKey(BCRYPT_ALG_HANDLE, KEY, ByRef pbKeyObject, cbKeyObject)
    {
        VarSetCapacity(pbKeyObject, cbKeyObject, 0)
        VarSetCapacity(pbSecret, cbSecret := StrPut(KEY, "UTF-8"), 0) && StrPut(KEY, &pbSecret, "UTF-8"), cbSecret--
        if (NT_STATUS := DllCall("bcrypt\BCryptGenerateSymmetricKey", "ptr",  BCRYPT_ALG_HANDLE
                                                                    , "ptr*", BCRYPT_KEY_HANDLE
                                                                    , "ptr",  &pbKeyObject
                                                                    , "uint", cbKeyObject
                                                                    , "ptr",  &pbSecret
                                                                    , "uint", cbSecret
                                                                    , "uint", 0) != 0)
            throw Exception("BCryptGenerateSymmetricKey: " NT_STATUS, -1)
        return BCRYPT_KEY_HANDLE
    }

    ; ===========================================================================================================================
    ; BCryptEncrypt                                               https://msdn.microsoft.com/en-us/library/aa375421(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptEncrypt(BCRYPT_KEY_HANDLE, STRING, IV, cbIV, ByRef pbOutput)
    {
        VarSetCapacity(pbInput, cbInput := StrLen(STRING) << 1, 0)
        DllCall("msvcrt\memcpy", "ptr", &pbInput, "ptr", &STRING, "ptr", cbInput)

        VarSetCapacity(pbIV, cbIV, 0)
        DllCall("msvcrt\memcpy", "ptr", &pbIV, "ptr", &IV, "ptr", cbIV)

        if (NT_STATUS := DllCall("bcrypt\BCryptEncrypt", "ptr",   BCRYPT_KEY_HANDLE
                                                       , "ptr",   &pbInput
                                                       , "uint",  cbInput
                                                       , "ptr",   0
                                                       , "ptr",   &pbIV
                                                       , "uint",  cbIV
                                                       , "ptr",   0
                                                       , "uint",  0
                                                       , "uint*", cbOutput
                                                       , "uint",  BCRYPT_BLOCK_PADDING) != 0)
            throw Exception("BCryptEncrypt: " NT_STATUS, -1)
        VarSetCapacity(pbOutput, cbOutput, 0)
        if (NT_STATUS := DllCall("bcrypt\BCryptEncrypt", "ptr",   BCRYPT_KEY_HANDLE
                                                       , "ptr",   &pbInput
                                                       , "uint",  cbInput
                                                       , "ptr",   0
                                                       , "ptr",   &pbIV
                                                       , "uint",  cbIV
                                                       , "ptr",   &pbOutput
                                                       , "uint",  cbOutput
                                                       , "uint*", cbOutput
                                                       , "uint",  BCRYPT_BLOCK_PADDING) != 0)
            throw Exception("BCryptEncrypt: " NT_STATUS, -1)
        return cbOutput
    }

    ; ===========================================================================================================================
    ; BCryptDecrypt                                               https://msdn.microsoft.com/en-us/library/aa375391(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptDecrypt(BCRYPT_KEY_HANDLE, ByRef STRING, cbInput, IV, cbIV, ByRef pbOutput)
    {
        VarSetCapacity(pbInput, cbInput, 0)
        DllCall("msvcrt\memcpy", "ptr", &pbInput, "ptr", &STRING, "ptr", cbInput)

        VarSetCapacity(pbIV, cbIV, 0)
        DllCall("msvcrt\memcpy", "ptr", &pbIV, "ptr", &IV, "ptr", cbIV)

        if (NT_STATUS := DllCall("bcrypt\BCryptDecrypt", "ptr",   BCRYPT_KEY_HANDLE
                                                       , "ptr",   &pbInput
                                                       , "uint",  cbInput
                                                       , "ptr",   0
                                                       , "ptr",   &pbIV
                                                       , "uint",  cbIV
                                                       , "ptr",   0
                                                       , "uint",  0
                                                       , "uint*", cbOutput
                                                       , "uint",  BCRYPT_BLOCK_PADDING) != 0)
            throw Exception("BCryptDecrypt: " NT_STATUS, -1)
        VarSetCapacity(pbOutput, cbOutput, 0)
        if (NT_STATUS := DllCall("bcrypt\BCryptDecrypt", "ptr",   BCRYPT_KEY_HANDLE
                                                       , "ptr",   &pbInput
                                                       , "uint",  cbInput
                                                       , "ptr",   0
                                                       , "ptr",   &pbIV
                                                       , "uint",  cbIV
                                                       , "ptr",   &pbOutput
                                                       , "uint",  cbOutput
                                                       , "uint*", cbOutput
                                                       , "uint",  BCRYPT_BLOCK_PADDING) != 0)
            throw Exception("BCryptDecrypt: " NT_STATUS, -1)
        return cbOutput
    }

    ; ===========================================================================================================================
    ; BCryptDestroyKey                                            https://msdn.microsoft.com/en-us/library/aa375404(v=vs.85).aspx
    ; ===========================================================================================================================
    BCryptDestroyKey(BCRYPT_KEY_HANDLE)
    {
        if (NT_STATUS := DllCall("bcrypt.dll\BCryptDestroyKey", "ptr", BCRYPT_KEY_HANDLE) != 0)
            throw Exception("BCryptDestroyKey: " NT_STATUS, -1)
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
    b64Encode(ByRef string, len)
    {
        DllCall("crypt32\CryptBinaryToString", "ptr", &string, "uint", len, "uint", 0x40000001, "ptr", 0, "uint*", size)
        VarSetCapacity(buf, size << 1, 0)
        DllCall("crypt32\CryptBinaryToString", "ptr", &string, "uint", len, "uint", 0x40000001, "ptr", &buf, "uint*", size)
        return StrGet(&buf, size << 1, "UTF-16")
    }

    b64Decode(ByRef string, ByRef buf)
    {
        DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0)
        VarSetCapacity(buf, size, 0)
        DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0)
        return size
    }
}