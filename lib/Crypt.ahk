Crypt_Hash(pData, nSize, SID = "CRC32", nInitial = 0)
{
	CALG_SHA := CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	If Not	CALG_%SID%
	{
		FormatI := A_FormatInteger
		SetFormat, Integer, H
		sHash := DllCall("ntdll\RtlComputeCrc32", "Uint", nInitial, "Uint", pData, "Uint", nSize, "Uint")
		SetFormat, Integer, %FormatI%
		StringUpper,	sHash, sHash
		StringReplace,	sHash, sHash, X, 000000
		Return	SubStr(sHash,-7)
	}

	DllCall("advapi32\CryptAcquireContextA", "UintP", hProv, "Uint", 0, "Uint", 0, "Uint", 1, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Uint", hProv, "Uint", CALG_%SID%, "Uint", 0, "Uint", 0, "UintP", hHash)
	DllCall("advapi32\CryptHashData", "Uint", hHash, "Uint", pData, "Uint", nSize, "Uint", 0)
	DllCall("advapi32\CryptGetHashParam", "Uint", hHash, "Uint", 2, "Uint", 0, "UintP", nSize, "Uint", 0)
	VarSetCapacity(HashVal, nSize, 0)
	DllCall("advapi32\CryptGetHashParam", "Uint", hHash, "Uint", 2, "Uint", &HashVal, "UintP", nSize, "Uint", 0)
	DllCall("advapi32\CryptDestroyHash", "Uint", hHash)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)

	FormatI := A_FormatInteger
	SetFormat, Integer, H
	Loop,	%nSize%
		sHash .= SubStr(*(&HashVal + A_Index - 1), -1)
	SetFormat, Integer, %FormatI%
	StringReplace,	sHash, sHash, x, 0, All
	StringUpper,	sHash, sHash
	Return	sHash
}

; Require Windows XP or Higher!
Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)
{
	CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E
	CALG_SHA := CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	DllCall("advapi32\CryptAcquireContextA", "UintP", hProv, "Uint", 0, "Uint", 0, "Uint", 24, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Uint", hProv, "Uint", CALG_SHA1, "Uint", 0, "Uint", 0, "UintP", hHash)
	DllCall("advapi32\CryptHashData", "Uint", hHash, "Uint", &sPassword, "Uint", StrLen(sPassword), "Uint", 0)
	DllCall("advapi32\CryptDeriveKey", "Uint", hProv, "Uint", CALG_AES_%SID%, "Uint", hHash, "Uint", SID<<16, "UintP", hKey)
	DllCall("advapi32\CryptDestroyHash", "Uint", hHash)
	If	bEncrypt
		DllCall("advapi32\CryptEncrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize, "Uint", nSize+16)
	Else	DllCall("advapi32\CryptDecrypt", "Uint", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Uint", pData, "UintP", nSize)
	DllCall("advapi32\CryptDestroyKey", "Uint", hKey)
	DllCall("advapi32\CryptReleaseContext", "Uint", hProv, "Uint", 0)
	Return	nSize
}
