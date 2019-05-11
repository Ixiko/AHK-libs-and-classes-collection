MsgBox % bcrypt_md4_file("C:\Windows\notepad.exe")
; ==> 831b14ab0a7dbccb969898dc2b425dd1



bcrypt_md4_file(filename)
{
    static BCRYPT_MD4_ALGORITHM := "MD4"
    static BCRYPT_HASH_LENGTH   := "HashDigestLength"

    if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlgo, "ptr", &BCRYPT_MD4_ALGORITHM, "ptr", 0, "uint", 0) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)

    if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlgo, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbResult, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)

    VarSetCapacity(pbHash, cbHash, 0)
    if !(f := FileOpen(filename, "r", "UTF-8"))
        throw Exception("Failed to open file: " filename, -1)
    f.Seek(0)
    while (dataread := f.RawRead(data, 262144))
        if (NT_STATUS := DllCall("bcrypt\BCryptHash", "ptr", hAlgo, "ptr", 0, "uint", 0, "ptr", &data, "uint", dataread, "ptr", &pbHash, "uint", cbHash) != 0)
            throw Exception("BCryptHash: " NT_STATUS, -1)
    f.Close()

    loop % cbHash
        hash .= Format("{:02x}", NumGet(pbHash, A_Index - 1, "uchar"))

    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlgo, "uint", 0)
    DllCall("FreeLibrary", "ptr", hBCRYPT)

    return hash
}