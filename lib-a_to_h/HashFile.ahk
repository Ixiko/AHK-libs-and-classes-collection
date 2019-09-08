; HASH File by Deo
; Current code requires AHK_L, but can be converted for using with common ahk build.
; Link: https://autohotkey.com/board/topic/66139-ahk-l-calculating-md5sha-checksum-from-file/


/*
FilePath := "C:\Windows\notepad.exe"

msgbox % "MD5:`n" HashFile(filePath,2)
msgbox % "SHA:`n" HashFile(filePath,3)
msgbox % "SHA512:`n" HashFile(filePath,6)
*/

/*
HASH types:
1 - MD2
2 - MD5
3 - SHA
4 - SHA256 - not supported on XP,2000
5 - SHA384 - not supported on XP,2000
6 - SHA512 - not supported on XP,2000
*/

HashFile(filePath,hashType=2) {
	PROV_RSA_AES := 24
	CRYPT_VERIFYCONTEXT := 0xF0000000
	BUFF_SIZE := 1024 * 1024 ; 1 MB
	HP_HASHVAL := 0x0002
	HP_HASHSIZE := 0x0004

	HASH_ALG := hashType = 1 ? (CALG_MD2 := 32769) : HASH_ALG
	HASH_ALG := hashType = 2 ? (CALG_MD5 := 32771) : HASH_ALG
	HASH_ALG := hashType = 3 ? (CALG_SHA := 32772) : HASH_ALG
	HASH_ALG := hashType = 4 ? (CALG_SHA_256 := 32780) : HASH_ALG	;Vista+ only
	HASH_ALG := hashType = 5 ? (CALG_SHA_384 := 32781) : HASH_ALG	;Vista+ only
	HASH_ALG := hashType = 6 ? (CALG_SHA_512 := 32782) : HASH_ALG	;Vista+ only

	f := FileOpen(filePath,"r","CP0")
	if !IsObject(f)
		return 0
	if !hModule := DllCall( "GetModuleHandleW", "str", "Advapi32.dll", "Ptr" )
		hModule := DllCall( "LoadLibraryW", "str", "Advapi32.dll", "Ptr" )
	if !dllCall("Advapi32\CryptAcquireContextW"
				,"Ptr*",hCryptProv
				,"Uint",0
				,"Uint",0
				,"Uint",PROV_RSA_AES
				,"UInt",CRYPT_VERIFYCONTEXT )
		Goto,FreeHandles

	if !dllCall("Advapi32\CryptCreateHash"
				,"Ptr",hCryptProv
				,"Uint",HASH_ALG
				,"Uint",0
				,"Uint",0
				,"Ptr*",hHash )
		Goto,FreeHandles

	VarSetCapacity(read_buf,BUFF_SIZE,0)

    hCryptHashData := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "CryptHashData", "Ptr")
	While (cbCount := f.RawRead(read_buf, BUFF_SIZE))
	{
		if (cbCount = 0)
			break

		if !dllCall(hCryptHashData
					,"Ptr",hHash
					,"Ptr",&read_buf
					,"Uint",cbCount
					,"Uint",0 )
			Goto,FreeHandles
	}

	if !dllCall("Advapi32\CryptGetHashParam"
				,"Ptr",hHash
				,"Uint",HP_HASHSIZE
				,"Uint*",HashLen
				,"Uint*",HashLenSize := 4
				,"UInt",0 )
		Goto,FreeHandles

	VarSetCapacity(pbHash,HashLen,0)
	if !dllCall("Advapi32\CryptGetHashParam"
				,"Ptr",hHash
				,"Uint",HP_HASHVAL
				,"Ptr",&pbHash
				,"Uint*",HashLen
				,"UInt",0 )
		Goto,FreeHandles

	SetFormat,integer,Hex
	loop,%HashLen%
	{
		num := numget(pbHash,A_index-1,"UChar")
		hashval .= substr((num >> 4),0) . substr((num & 0xf),0)
	}
	SetFormat,integer,D

FreeHandles:
	f.Close()
	DllCall("FreeLibrary", "Ptr", hModule)
	dllCall("Advapi32\CryptDestroyHash","Ptr",hHash)
	dllCall("Advapi32\CryptReleaseContext","Ptr",hCryptProv,"UInt",0)
	return hashval
}