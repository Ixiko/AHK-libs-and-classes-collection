MsgBox % bcrypt_sha512_hmac("The quick brown fox jumps over the lazy dog", "Secret Salt")
; ==> 8ba0777b278b406b07df08150b98d2c57c68f83a980088e3011f76ea8e6d26b84244a678218408e97066d8dfe8aee20569044d214131327b016ea69a487ef471



bcrypt_sha512_hmac(string, hmac)
{
    static BCRYPT_SHA512_ALGORITHM     := "SHA512"
    static BCRYPT_ALG_HANDLE_HMAC_FLAG := 0x00000008
    static BCRYPT_HASH_LENGTH          := "HashDigestLength"

    if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_SHA512_ALGORITHM, "ptr", 0, "uint", BCRYPT_ALG_HANDLE_HMAC_FLAG) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    VarSetCapacity(pbInput,  StrPut(string, "UTF-8"), 0) && cbInput  := StrPut(string, &pbInput,  "UTF-8") - 1
    VarSetCapacity(pbSecret, StrPut(hmac, "UTF-8"), 0)   && cbSecret := StrPut(hmac,   &pbSecret, "UTF-8") - 1
    VarSetCapacity(pbHash, cbHash, 0)
    if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", &pbSecret, "uint", cbSecret, "ptr", &pbInput, "uint", cbInput, "ptr", &pbHash, "uint", cbHash) != 0)
        throw Exception("BCryptHash: " NT_STATUS, -1)

    loop % cbHash
        hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "uchar"))

    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
    DllCall("FreeLibrary", "ptr", hBCRYPT)

    return hash
}