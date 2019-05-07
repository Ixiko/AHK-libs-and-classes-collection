sFileOriginl   := A_ScriptFullPath
sPassword   := "AutoHotkey"

SID := 256   ; 128 for 128bit, 192 for 192bit AES
sFileEncrypt := A_ScriptDir . "\encrypt" . SID . ".bin"
sFileDecrypt := A_ScriptDir . "\decrypt" . SID . ".ahk"

StrPutVar(Password, sPassword, "UTF-8") ;Change encoding to be consistent in Ansi or Unicode builds

File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)   ; Encryption
;File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)   ; Decryption

File_AES(sFileFr, sFileTo, sPassword, SID = 256, bEncrypt = True)
{
   hFileFr := FileOpen(sFileFr,"r -r")
   if not hFileFr
      Return   "File not found!"
   nSize := hFileFr.Length
   VarSetCapacity(sData, nSize + (bEncrypt ? 16 : 0))
   hFileFr.Seek(0)
   hFileFr.RawRead(sData, nSize)
   hFileFr.Close()
   hFileTo := FileOpen(sFileTo,"w -r")
   if not hFileTo
      Return   "File not created/opened!"
   nSize := Crypt_AES(&sData, nSize, sPassword, SID, bEncrypt)
   hFileTo.RawWrite(sData, nSize)
   hFileTo.Close()
      Return   nSize
}

Crypt_AES(pData, nSize, sPassword, SID = 256, bEncrypt = True)
{
   CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E
   CALG_SHA1 := 1 + CALG_MD5 := 0x8003
   DllCall("advapi32\CryptAcquireContext", "UPtr*", hProv, "UPtr", 0, "UPtr", 0, "UPtr", 24, "UPtr", 0xF0000000)
   DllCall("advapi32\CryptCreateHash", "UPtr", hProv, "UPtr", CALG_SHA1, "UPtr", 0, "UPtr", 0, "UPtr*", hHash)
   DllCall("advapi32\CryptHashData", "UPtr", hHash
   , "UPtr", &sPassword
   , "UPtr", StrLen(sPassword)*2, "UPtr", 0)
   DllCall("advapi32\CryptDeriveKey", "UPtr", hProv, "UPtr", CALG_AES_%SID%, "UPtr", hHash, "UPtr", SID<<16, "UPtr*", hKey)
   DllCall("advapi32\CryptDestroyHash", "UPtr", hHash)
   bEncrypt
   ? DllCall("advapi32\CryptEncrypt", "UPtr", hKey, "UPtr", 0, "UPtr", True, "UPtr", 0, "UPtr", pData, "UPtr*", nSize, "UPtr", nSize+16)
   : DllCall("advapi32\CryptDecrypt", "UPtr", hKey, "UPtr", 0, "UPtr", True, "UPtr", 0, "UPtr", pData, "UPtr*", nSize)
   DllCall("advapi32\CryptDestroyKey", "UPtr", hKey)
   DllCall("advapi32\CryptReleaseContext", "UPtr", hProv, "UPtr", 0)
   Return   nSize
}

StrPutVar(string, ByRef var, encoding)
{
    VarSetCapacity( var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    return StrPut(string, &var, encoding)
}