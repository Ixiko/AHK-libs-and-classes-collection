File_Hash(sFile, SID = "CRC32")
{
	nSize:=	File_WriteMemory(sFile, sBuffer)
	Return	Crypt_Hash(&sBuffer, nSize, SID)
}

File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
{
	If	!(1 + hFileFr := File_CreateFile(sFileFr, 3, 0x80000000, 1))
	Return	"File not found!"
	nSize := File_GetFileSize(hFileFr),	VarSetCapacity(sBuffer, nSize + (bEncrypt ? 16 : 0))
	File_ReadFile(hFileFr,&sBuffer,nSize),	File_CloseHandle(hFileFr)
	If	!(1 + hFileTo := File_CreateFile(sFileTo, 2, 0x40000000, 1))
	Return	"File not created/opened!"
	nSize := Crypt_AES(&sBuffer, nSize, sPassword, SID, bEncrypt)
	File_WriteFile(hFileTo,&sBuffer,nSize),	File_CloseHandle(hFileTo)
	Return	nSize
}

File_ReadMemory(sFile, pBuffer, nSize = 512, bAppend = False)
{
	If	!(1 + hFile := File_CreateFile(sFile, 4, 0x40000000, 1))
	Return	"File not created/opened!"
	File_SetFilePointer(hFile, bAppend ? 2 : 0)
	nSize := File_WriteFile(hFile, pBuffer, nSize)
	File_SetEndOfFile(hFile)
	File_CloseHandle(hFile)
	Return	nSize
}

File_WriteMemory(sFile, ByRef sBuffer, nSize = 0)
{
	If	!(1 + hFile := File_CreateFile(sFile, 3, 0x80000000, 1))
	Return	"File not found!"
	VarSetCapacity(sBuffer, nSize += nSize ? 0 : File_GetFileSize(hFile))
	nSize := File_ReadFile(hFile, &sBuffer, nSize)
	NumPut(0, sBuffer, nSize, "char")
	VarSetCapacity(sBuffer, -1)
	File_CloseHandle(hFile)
	Return	nSize
}

File_CreateFile(sFile, nCreate = 3, nAccess = 0x1F01FF, nShare = 3, bFolder = False)
{
/*
	CREATE_NEW    = 1
	CREATE_ALWAYS = 2
	OPEN_EXISTING = 3
	OPEN_ALWAYS   = 4

	GENERIC_READ    = 0x80000000
	GENERIC_WRITE   = 0x40000000
	GENERIC_EXECUTE = 0x20000000
	GENERIC_ALL     = 0x10000000 

	FILE_SHARE_READ   = 1
	FILE_SHARE_WRITE  = 2
	FILE_SHARE_DELETE = 4
*/
	Return	DllCall("CreateFile", "Uint", &sFile, "Uint", nAccess, "Uint", nShare, "Uint", 0, "Uint", nCreate, "Uint", bFolder ? 0x02000000 : 0, "Uint", 0)
}

File_DeleteFile(sFile)
{
	Return	DllCall("DeleteFile", "Uint", &sFile)
}

File_ReadFile(hFile, pBuffer, nSize = 1024)
{
	DllCall("ReadFile", "Uint", hFile, "Uint", pBuffer, "Uint", nSize, "UintP", nSize, "Uint", 0)
	Return	nSize
}

File_WriteFile(hFile, pBuffer, nSize = 1024)
{
	DllCall("WriteFile", "Uint", hFile, "Uint", pBuffer, "Uint", nSize, "UintP", nSize, "Uint", 0)
	Return	nSize
}

File_GetFileSize(hFile)
{
	DllCall("GetFileSizeEx", "Uint", hFile, "int64P", nSize)
	Return	nSize
}

File_SetEndOfFile(hFile)
{
	Return	DllCall("SetEndOfFile", "Uint", hFile)
}

File_SetFilePointer(hFile, nPos = 0, nMove = 0)
{
/*
	FILE_BEGIN   = 0
	FILE_CURRENT = 1
	FILE_END     = 2
*/
	Return	DllCall("SetFilePointerEx", "Uint", hFile, "int64", nMove, "Uint", 0, "Uint", nPos)
}

File_CloseHandle(Handle)
{
	Return	DllCall("CloseHandle", "Uint", Handle)
}


File_InternetOpen(sAgent = "AutoHotkey", nType = 4)
{
	If Not	DllCall("GetModuleHandle", "str", "wininet")
		DllCall("LoadLibrary"    , "str", "wininet")
	Return	DllCall("wininet\InternetOpenA", "str", sAgent, "Uint", nType, "Uint", 0, "Uint", 0, "Uint", 0)
}

File_InternetOpenUrl(hInet, sUrl, nFlags = 0, pHeaders = 0)
{
	Return	DllCall("wininet\InternetOpenUrlA", "Uint", hInet, "Uint", &sUrl, "Uint", pHeaders, "Uint", -1, "Uint", nFlags | 0x80000000, "Uint", 0)   ; INTERNET_FLAG_RELOAD = 0x80000000
}

File_InternetReadFile(hFile, pBuffer, nSize = 1024)
{
	DllCall("wininet\InternetReadFile", "Uint", hFile, "Uint", pBuffer, "Uint", nSize, "UintP", nSize)
	Return	nSize
}

File_InternetWriteFile(hFile, pBuffer, nSize = 1024)
{
	DllCall("wininet\InternetWriteFile", "Uint", hFile, "Uint", pBuffer, "Uint", nSize, "UintP", nSize)
	Return	nSize
}

File_InternetSetFilePointer(hFile, nPos = 0, nMove = 0)
{
	Return	DllCall("wininet\InternetSetFilePointer", "Uint", hFile, "Uint", nMove, "Uint", 0, "Uint", nPos, "Uint", 0)
}

File_InternetCloseHandle(Handle)
{
	Return	DllCall("wininet\InternetCloseHandle", "Uint", Handle)
}
