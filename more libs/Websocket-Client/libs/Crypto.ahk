sha1_encode(string, encoding := "utf-8") {
    static BCRYPT_SHA1_ALGORITHM := "SHA1"
    static BCRYPT_OBJECT_LENGTH  := "ObjectLength"
    static BCRYPT_HASH_LENGTH    := "HashDigestLength"
    
	try
	{
		; loads the specified module into the address space of the calling process
		if !(hBCRYPT := DllCall("LoadLibrary", "str", "bcrypt.dll", "ptr"))
        throw Exception("Failed to load bcrypt.dll", -1)
        
		; open an algorithm handle
		if (NT_STATUS := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", hAlg, "ptr", &BCRYPT_SHA1_ALGORITHM, "ptr", 0, "uint", 0) != 0)
        throw Exception("BCryptOpenAlgorithmProvider: " NT_STATUS, -1)
        
		; calculate the size of the buffer to hold the hash object
		if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlg, "ptr", &BCRYPT_OBJECT_LENGTH, "uint*", cbHashObject, "uint", 4, "uint*", cbData, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)
        
		; allocate the hash object
		VarSetCapacity(pbHashObject, cbHashObject, 0)
		;	throw Exception("Memory allocation failed", -1)
        
		; calculate the length of the hash
		if (NT_STATUS := DllCall("bcrypt\BCryptGetProperty", "ptr", hAlg, "ptr", &BCRYPT_HASH_LENGTH, "uint*", cbHash, "uint", 4, "uint*", cbData, "uint", 0) != 0)
        throw Exception("BCryptGetProperty: " NT_STATUS, -1)
        
		; allocate the hash buffer
		VarSetCapacity(pbHash, cbHash, 0)
		;	throw Exception("Memory allocation failed", -1)
        
		; create a hash
		if (NT_STATUS := DllCall("bcrypt\BCryptCreateHash", "ptr", hAlg, "ptr*", hHash, "ptr", &pbHashObject, "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", 0) != 0)
        throw Exception("BCryptCreateHash: " NT_STATUS, -1)
        
		; hash some data
		VarSetCapacity(pbInput, (StrPut(string, encoding) - 1) * ((encoding = "utf-16" || encoding = "cp1200") ? 2 : 1), 0) && cbInput := StrPut(string, &pbInput, encoding) - 1
		if (NT_STATUS := DllCall("bcrypt\BCryptHashData", "ptr", hHash, "ptr", &pbInput, "uint", cbInput, "uint", 0) != 0)
        throw Exception("BCryptHashData: " NT_STATUS, -1)
        
		; close the hash
		if (NT_STATUS := DllCall("bcrypt\BCryptFinishHash", "ptr", hHash, "ptr", &pbHash, "uint", cbHash, "uint", 0) != 0)
        throw Exception("BCryptFinishHash: " NT_STATUS, -1)
        
    }
	catch exception
	{
		; represents errors that occur during application execution
		throw Exception
    }
	finally
	{
		; cleaning up resources
		if (pbInput)
        VarSetCapacity(pbInput, 0)
		if (hHash)
        DllCall("bcrypt\BCryptDestroyHash", "ptr", hHash)
		;if (pbHash)
        ;	VarSetCapacity(pbHash, 0)
		if (pbHashObject)
        VarSetCapacity(pbHashObject, 0)
		if (hAlg)
        DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
		if (hBCRYPT)
        DllCall("FreeLibrary", "ptr", hBCRYPT)
    }
    
	return [pbHash, cbHash]
}

Base64_encode(pData, Size) {
    if !DllCall("Crypt32\CryptBinaryToString"
    , "Ptr", pData       ; const BYTE *pbBinary
    , "UInt", Size     ; DWORD      cbBinary
    , "UInt", 0x40000001 ; DWORD      dwFlags = CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
    , "Ptr", 0           ; LPWSTR     pszString
    , "UInt*", Base64Length    ; DWORD      *pcchString
    , "UInt") ; BOOL
    throw Exception("Failed to calculate b64 size")
    
    VarSetCapacity(Base64, Base64Length * (1 + A_IsUnicode), 0)
    
    if !DllCall("Crypt32\CryptBinaryToString"
    , "Ptr", pData       ; const BYTE *pbBinary
    , "UInt", Size     ; DWORD      cbBinary
    , "UInt", 0x40000001 ; DWORD      dwFlags = CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
    , "Str", Base64         ; LPWSTR     pszString
    , "UInt*", Base64Length    ; DWORD      *pcchString
    , "UInt") ; BOOL
    throw Exception("Failed to convert to b64")
    
    return Base64
}

XOR(byteArr, keyArr)
{
    keylen := keyArr.length()
    decodedArr := []
    for i, byte in byteArr{
        key :=  keyArr[mod(A_Index - 1, keylen) + 1]
        decodedByte := byte ^ key
        decodedArr.push(decodedByte)
    }
    return decodedArr
}