; ===============================================================================================================================
; http://aes.online-domain-tools.com/
; Input Text   : Hello World!1234                        (Plaintext)
; Function     : AES
; Mode         : ECB (electronic codebook)
; Key          : 12345678901234567890123456789012        (Plaintext)
; Init. vector : -
; OUTPUT       : 17 C3 BA 4F 85 24 49 DD 7A 6C E9 20 99 EB 70 61 41 98 AB 40 81 48 7C 21 3A 1C 82 BC 40 4A D7 C8
; ===============================================================================================================================

global data := "Hello World!1234"
global key  := "12345678901234567890123456789012"
global iv   := "1234567890123456" ; 31323334353637383930313233343536 (Hex)

MsgBox % Crypt_ECB(data, key)

Crypt_ECB(string, key){
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    blob_size := 12 + key_len := StrLen(key)
    VarSetCapacity(blob, blob_size, 0)
    , NumPut(0x8,        blob, 0, "UChar")
    , NumPut(2,          blob, 1, "UChar")
    , NumPut(0x00006610, blob, 4, "UInt")
    , NumPut(key_len,    blob, 8, "UInt")
    , StrPut(key, &blob + 12, key_len, "CP0")

    DllCall("advapi32.dll\CryptAcquireContext", "UPtr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000)
    DllCall("advapi32.dll\CryptImportKey", "UPtr", hProv, "Ptr", &blob, "UInt", blob_size, "UPtr", 0, "UInt", 0, "UPtr*", hKey)
    ;DllCall("advapi32.dll\CryptSetKeyParam", "UPtr", hKey, "UInt", 4, "UInt*", 2, "UInt", 0)

    buf_len := str_len := (StrPut(string, "UTF-8") - 1)
    DllCall("advapi32.dll\CryptEncrypt", "UPtr", hKey, "UPtr", 0, "UInt", 1, "UInt", 0, "Ptr", 0, "Uint*", buf_len, "UInt", 0)
    buf_size := buf_len, buf_len := str_len
    VarSetCapacity(buffer, buf_size, 0), StrPut(string, &buffer, StrLen(string), "UTF-8")
    DllCall("advapi32.dll\CryptEncrypt", "UPtr", hKey, "UPtr", 0, "UInt", 1, "UInt", 0, "Ptr", &buffer, "Uint*", buf_len, "UInt", buf_size)
    loop % buf_len
    {
        v := NumGet(buffer, A_Index - 1, "UChar")
        o .= h[(v >> 4) + b] h[(v & 0xF) + b]
    }

    DllCall("advapi32.dll\CryptDestroyKey", "UPtr", hKey)
    DllCall("advapi32.dll\CryptDestroyHash", "UPtr", hHash)
    DllCall("advapi32.dll\CryptReleaseContext", "UPtr", hProv, "UInt", 0)
    return o, VarSetCapacity(buffer, -1)
}

; ###############################################################################################################################

; ===============================================================================================================================
; http://aes.online-domain-tools.com/
; Input Text   : Hello World!1234                        (Plaintext)
; Function     : AES
; Mode         : CBC (cipher block chaining)
; Key          : 12345678901234567890123456789012        (Plaintext)
; Init. vector : 31323334353637383930313233343536        (Hex)
; OUTPUT       : 30 30 52 04 41 4A 5E 93 66 45 D3 EE 15 F4 BC 97 9E 8A 0C 3D 2C 0F 69 F6 17 0A CB 63 18 8D D3 A3
; ===============================================================================================================================

MsgBox % Crypt_CBC(data, key, iv)

Crypt_CBC(string, key, iv){
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    blob_size := 12 + key_len := StrLen(key)
    VarSetCapacity(blob, blob_size, 0)
    , NumPut(0x8,        blob, 0, "UChar")
    , NumPut(2,          blob, 1, "UChar")
    , NumPut(0x00006610, blob, 4, "UInt")
    , NumPut(key_len,    blob, 8, "UInt")
    , StrPut(key, &blob + 12, key_len, "CP0")

    DllCall("advapi32.dll\CryptAcquireContext", "UPtr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000)
    DllCall("advapi32.dll\CryptImportKey", "UPtr", hProv, "Ptr", &blob, "UInt", blob_size, "UPtr", 0, "UInt", 0, "UPtr*", hKey)
    VarSetCapacity(vector, StrLen(iv) * 2), StrPut(iv, &vector, StrLen(iv), "UTF-8")
    DllCall("advapi32.dll\CryptSetKeyParam", "UPtr", hKey, "UInt", 1, "Ptr", &vector, "UInt", 0)

    buf_len := str_len := (StrPut(string, "UTF-8") - 1)
    DllCall("advapi32.dll\CryptEncrypt", "UPtr", hKey, "UPtr", 0, "UInt", 1, "UInt", 0, "Ptr", 0, "Uint*", buf_len, "UInt", 0)
    buf_size := buf_len, buf_len := str_len
    VarSetCapacity(buffer, buf_size, 0), StrPut(string, &buffer, StrLen(string), "UTF-8")
    DllCall("advapi32.dll\CryptEncrypt", "UPtr", hKey, "UPtr", 0, "UInt", 1, "UInt", 0, "Ptr", &buffer, "Uint*", buf_len, "UInt", buf_size)
    loop % buf_len
    {
        v := NumGet(buffer, A_Index - 1, "UChar")
        o .= h[(v >> 4) + b] h[(v & 0xF) + b]
    }

    DllCall("advapi32.dll\CryptDestroyKey", "UPtr", hKey)
    DllCall("advapi32.dll\CryptDestroyHash", "UPtr", hHash)
    DllCall("advapi32.dll\CryptReleaseContext", "UPtr", hProv, "UInt", 0)
    return o, VarSetCapacity(buffer, -1)
}