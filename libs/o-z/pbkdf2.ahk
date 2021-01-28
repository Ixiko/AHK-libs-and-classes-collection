; AutoHotkey Version: AutoHotkey 1.1
; Language:           English
; Platform:           Win7 SP1
; Author:             Antonio Bueno <user atnbueno at Google's free e-mail service>
; Description:        Implementation of PBKDF2 using MS-CAPI HMACs
; Last Modification:  2014-05-03

; Available hash algorithms and their length in bytes
aHashAlgid := {MD5: 0x8003, SHA1: 0x8004, SHA256: 0x800C, SHA384: 0x800D, SHA512: 0x800E}
aHashLength := {MD5: 16, SHA1: 20, SHA256: 32, SHA384: 48, SHA512: 64}

PBKDF2(sPassword, sSalt, nIterations = 10000, nLength = 0, sAlgo = "SHA1")
; Calculates PBKDF2 for a (password, salt) pair that can be either an UTF-8-encoded string or an hex
; string. Optional parameters are the number of iterations, the output length and the hash algorithm.
; It depends on the functions below (Wide2UTF8, Hex2Bin, RawPBKDF2, and Bin2Hex)
{
	global aHashAlgid, aHashLength
	; Basic error checking
	If (nIterations <= 0)
		Throw "PBKDF2 ERROR: Invalid number of iterations (" nIterations ")"
	If (aHashAlgid[sAlgo] = "")
		Throw "PBKDF2 ERROR: Unknown hash function (" sALgo ")"
	; Prepares parameters for RawPBKDF2
	If (nLength = 0)
		nLength := aHashLength[sAlgo]
	; sPassword and sSalt can be either an UTF-8-encoded string or an hex string
	If (!RegExMatch(sPassword, "i)^([0-9A-F][0-9A-F])+$"))
		nPassword := Wide2UTF8(sPassword, Password)
	else
		nPassword := Hex2Bin(sPassword, Password)
	If (!RegExMatch(sSalt, "i)^([0-9A-F][0-9A-F])+$"))
		nSalt := Wide2UTF8(sSalt, Salt)
	else
		nSalt := Hex2Bin(sSalt, Salt)
	; Calculates PBKDF2
	RawPBKDF2(Password, nPassword, Salt, nSalt, nIterations, Output, nLength, sAlgo)
	; Outputs result in hexadecimal format
	Return Bin2Hex(Output, nLength)
}
RawPBKDF2(ByRef Password, nPassword, ByRef Salt, nSalt, nIterations, ByRef Output, nOutput, sAlgo)
{
	global aHashAlgid, aHashLength
	; MS-CAPI constants used to do HMACs
	CALG_HMAC            := 0x8009
	CALG_RC2             := 0x6602
	CRYPT_IPSEC_HMAC_KEY := 0x0100
	CRYPT_VERIFYCONTEXT  := 0xF0000000
	CUR_BLOB_VERSION     := 0x02
	HP_HASHVAL           := 0x02
	HP_HMAC_INFO         := 0x05
	PLAINTEXTKEYBLOB     := 0x08
	PROV_RSA_FULL        := 0x01
	; Reserves memory for hashing and XORing and storing the final result
	VarSetCapacity(Hash, Ceil(aHashLength[sAlgo] / 8) * 8, 0)
	VarSetCapacity(XORSum, Ceil(aHashLength[sAlgo] / 8) * 8, 0)
	nBlockCount := Ceil(nOutput / aHashLength[sAlgo])
	VarSetCapacity(Output, aHashLength[sAlgo] * nBlockCount, 0)
	; If the output is not longer than the specified hash the following loop does a single iteration
	Loop % nBlockCount
	{
		; The block count must be stored as an INT32_BE (the expression below is OK up to a block count of 255)
		nHash := Hex2Bin(Bin2Hex(Salt, nSalt) "000000" Bin2Hex(Chr(A_Index), 1), Hash)
		VarSetCapacity(HmacInfo, 4 * A_PtrSize, 0) ; HMAC_INFO struct, see http://msdn.com/library/aa382480
		NumPut(aHashAlgid[sAlgo], HmacInfo, 0, "UInt") ; Selects hashing algorithm and default padding
		nKeyBlobSize := 12 + nPassword
		VarSetCapacity(keyBlob, nKeyBlobSize, 0) ; BLOBHEADER struct, see http://msdn.com/library/aa387453
		NumPut(PLAINTEXTKEYBLOB, keyBlob, 0, "Char") ; PLAINTEXTKEYBLOB struct, http://msdn.com/library/jj650836
		NumPut(CUR_BLOB_VERSION, keyBlob, 1, "Char")
		NumPut(CALG_RC2, keyBlob, 4, "UInt")
		NumPut(nPassword, keyBlob, 8, "Char")
		DllCall("RtlMoveMemory", "UInt", &keyBlob + 12, "UInt", &Password, "Int", nPassword) ; see http://msdn.com/library/ff562030
		; See steps at http://msdn.com/library/aa379863 and C++ example at http://msdn.com/library/aa382379
		DllCall("advapi32\CryptAcquireContext", "UIntP", hProv, "UInt", 0, "UInt", 0, "UInt", PROV_RSA_FULL, "UInt", CRYPT_VERIFYCONTEXT)
		DllCall("advapi32\CryptImportKey", "UInt", hProv, "UInt", &keyBlob, "UInt", nKeyBlobSize, "UInt", 0, "UInt", CRYPT_IPSEC_HMAC_KEY, "UIntP", hKey)
		; Iteration zero
		DllCall("advapi32\CryptCreateHash", "UInt", hProv, "UInt", CALG_HMAC, "UInt", hKey, "UInt", 0, "UIntP", hHmacHash)
		DllCall("advapi32\CryptSetHashParam", "UInt", hHmacHash, "UInt", HP_HMAC_INFO, "UInt", &HmacInfo, "UInt", 0)
		DllCall("advapi32\CryptHashData", "UInt", hHmacHash, "UInt", &Hash, "UInt", nHash, "UInt", 0)
		DllCall("advapi32\CryptGetHashParam", "UInt", hHmacHash, "UInt", HP_HASHVAL, "UInt", &XORSum, "UIntP", aHashLength[sAlgo], "UInt", 0)
		DllCall("advapi32\CryptDestroyHash", "UInt", hHmacHash)
		DllCall("RtlMoveMemory", "UInt", &Hash, "UInt", &XORSum, "Int", aHashLength[sAlgo]) ; See http://msdn.com/library/ff562030
		; End of iteration zero
		Loop % nIterations-1
		{
			DllCall("advapi32\CryptCreateHash", "UInt", hProv, "UInt", CALG_HMAC, "UInt", hKey, "UInt", 0, "UIntP", hHmacHash)
			DllCall("advapi32\CryptSetHashParam", "UInt", hHmacHash, "UInt", HP_HMAC_INFO, "UInt", &HmacInfo, "UInt", 0)
			DllCall("advapi32\CryptHashData", "UInt", hHmacHash, "UInt", &Hash, "UInt", aHashLength[sAlgo], "UInt", 0)
			DllCall("advapi32\CryptGetHashParam", "UInt", hHmacHash, "UInt", HP_HASHVAL, "UInt", &Hash, "UIntP", aHashLength[sAlgo], "UInt", 0)
			DllCall("advapi32\CryptDestroyHash", "UInt", hHmacHash)
			; XOR is done in 64-bit (8-byte) blocks (smaller blocks make the XORing significantly slower)
			Loop % Ceil(aHashLength[sAlgo] / 8)
			{
				nOffset := (A_Index - 1) * 8
				NumPut(NumGet(XORSum, nOffset, "Int64") ^ NumGet(Hash, nOffset, "Int64"), &XORSum, nOffset, "Int64")
			}
		}
		DllCall("advapi32\CryptDestroyKey", "UInt", hKey)
		DllCall("advapi32\CryptReleaseContext", "UInt", hProv, "UInt", 0)
		DllCall("RtlMoveMemory", "UInt", &Output+(A_Index-1)*aHashLength[sAlgo], "UInt", &XORSum, "Int", aHashLength[sAlgo])
	}
}
Wide2UTF8(sInput, ByRef Output)
{
	nOutputSize := StrPut(sInput, "UTF-8")
	VarSetCapacity(Output, nOutputSize)
	StrPut(sInput, &Output, nOutputSize, "UTF-8")
	Return nOutputSize-1
}
Bin2Hex(ByRef Input, nInput)
{
	sIntegerFormat := A_FormatInteger
	SetFormat Integer, H
	Loop % nInput
		sOutput .= SubStr(*(&Input + A_Index - 1) + 0x100, -1)
	SetFormat Integer, % sIntegerFormat
	Return sOutput
}
Hex2Bin(sInput, ByRef Output)
{
	VarSetCapacity(Output, StrLen(sInput) // 2)
	Loop % StrLen(sInput) // 2
		NumPut("0x" . SubStr(sInput, 2 * A_Index - 1, 2), Output, A_Index - 1, "Char")
	Return StrLen(sInput) // 2
}
