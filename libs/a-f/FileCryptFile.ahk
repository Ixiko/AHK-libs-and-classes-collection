; Title:   	FileCryptFile() : Encrypt/Decrypt files. CNG AES 256 bit CBC
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=88903&view=unread#unread
; Author:	SKAN
; Date:   	02.04.2021
; for:     	AHK_L

/*
     Adapted from RePNG_Crypt(), a helper function of RePNG()
     The function returns error 0 on success or a error message on failure.

     When tested, it took about 32 seconds to encrypt a 2.7 GB movie file with the page size of 512 KiB. But with a 4 MiB page, the time took was only 19 secs.
     It is better to leave it at 512 KiB which is HDD friendly value, especially the older ones.
     You may change it to 4 MiB if you have SSD, but remember that the decryption will fail if same page size was not used for encoding.
     To set page size, replace var nBytes := 524288 with a value that is a multiple of 16.


*/

/*  Example 1

     #NoEnv
     #Warn
     #SingleInstance, Force
     SetWorkingDir, %A_ScriptDir%
     SetBatchLines, -1

     Original  := A_AhkPath . "\..\license.txt"
     Encrypted := "Encrypted.aes"
     Decrypted := "Decrypted.txt"

     FileCryptFile("encrypt", Original,  Encrypted, "SKAN")
     FileCryptFile("decrypt", Encrypted, Decrypted, "SKAN")

     MsgBox Done!

*/

/*  Example 2

     #NoEnv
     #Warn
     #SingleInstance, Force
     SetWorkingDir, %A_ScriptDir%
     SetBatchLines, -1

     Gui, Add, Text, x15 yp+20, File:
     Gui, Add, Edit, xp+40 yp-2 w430 h20 vFile_Path_Set
     Gui, Add, Text, x15 yp+30, Key:
     Gui, Add, Edit, xp+40 yp-2 w430 h20 password vKey_
     Gui, Add, Checkbox, vShowKey gShowKey, Show key
     Gui, Add, Button, xp+25 yp+30 w100 h30 gSelectFile, Select File
     Gui, Add, Button, xp+120 yp w100 h30 gButton_, Encrypt
     Gui, Add, Button, xp+120 yp w100 h30 gButton_, Decrypt
     Gui, Show, w500 h150, Encrypter\Decrypter
     Return

     SelectFile:
     FileSelectFile, File_Path,,, Select your file
     GuiControl,, File_Path_Set, %File_Path%
     Return

     ShowKey:
     GuiControlGet, ShowKey
     If(ShowKey)
         GuiControl, -password, Key_
     Else
         GuiControl, +password, Key_
     Return

     Button_:
     GuiControlGet, Key_
     GuiControlGet, File_Path_Set
     If(!FileExist(File_Path_Set)) {
         MsgBox, 0x0, Error, File not found
         Return
     }
     SplitPath, File_Path_Set, FileName, FilePath, GetExt, GetNoExt

     Original := FilePath . "\" . FileName
     Encrypted := FileName "[Encrypted]" ".aes"

     rmv := SubStr(GetNoExt, 1, InStr(GetNoExt, "[") - 1)
     SplitPath, rmv,,, rmvExt, rmvNoExt
     Decrypted := rmvNoExt "[Decrypted]" "." rmvExt

     If( A_GuiControl = "Encrypt" ) {
         FileCryptFile("encrypt", Original,  Encrypted, Key_)
         MsgBox, 0x0, Encrypt, % nErr = 0 ? "Successful!`nFile Encrypted" : "FAILED"
     } Else If( A_GuiControl = "Decrypt" ) {
         FileCryptFile("decrypt", FileName, Decrypted, Key_)
         MsgBox, 0x0, Decrypt, % nErr = 0 ? "Successful!`nFile Decrypted" : "FAILED"
     } Return

*/

FileCryptFile(Mode, Src, Trg, sKey) {                                     ; v0.55 By SKAN on D442/D443 @ tiny.cc/filecryptfile
Local
  If ( DllCall("Shlwapi.dll\StrSpn"
              ,"Str",sKey
              ,"Str","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") != StrLen(sKey) )
       Return ("Key has invalid characters")

  Mode := (Mode != "Encrypt" ? "Decrypt" : "Encrypt")
  VarSetCapacity(Hash, 48)
  pKey := &Hash,           nKey := 32
  pIni := pKey+nKey,       nIni := 16
  hKey := hAlg := hHash := nErr := 0

  hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr"),
  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","SHA256", "Ptr", 0, "Int",0)
  DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash, "Ptr",0, "Int",0, "Ptr",0, "Int",0, "Int",0)
  DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "AStr",sKey, "Int",StrLen(sKey), "Int",0)
  DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",pKey, "Int",nKey, "Int",0)
  DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
  DllCall("Shlwapi.dll\HashData", "Ptr",pKey, "Int",nKey, "Ptr",pIni, "Int",nIni)

  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","AES", "Ptr",0, "Int",0)
  DllCall("Bcrypt.dll\BCryptSetProperty", "Ptr",hAlg, "WStr","ChainingMode", "WStr","ChainingModeCBC", "Int",15, "Int",0)
  DllCall("Bcrypt.dll\BCryptGenerateSymmetricKey", "Ptr",hAlg, "PtrP",hKey, "Ptr",0, "Int",0, "Ptr",pKey, "Int",nKey, "Int",0)

  nBytes := 524288
  rBytes := (nBytes - (Mode="Encrypt"))
  wBytes := 0

  FileSrc := FileOpen(Src, "r -rwd")
  FileTrg := FileSrc ? FileOpen(Trg, "w -rwd") : 0
  FileSrc.Pos := 0
  VarSetCapacity(Bin, nBytes)

  If ( FileSrc.Length And FileTrg.__handle )
       Loop
       {  rBytes := FileSrc.RawRead(&Bin, rBytes)
          nErr   := DllCall("Bcrypt.dll\BCrypt" . Mode, "Ptr",hKey, "Ptr",&Bin, "Int",rBytes, "Ptr",0,"Ptr"
                                                , pIni, "Int",nIni, "Ptr",&Bin, "Int",nBytes, "UIntP",wBytes, "Int",1, "UInt")
          wBytes := nErr? 0 : FileTrg.RawWrite(&Bin, wBytes)
       }  Until ( nErr Or FileSrc.AtEOF )

  FileSrc.Close()
  FileTrg.Close()
  DllCall("Bcrypt.dll\BCryptDestroyKey", "Ptr",hKey)
  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int", 0)
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)
Return ( nErr ? Format("Bcrypt error: 0x{:08X}", nErr) : wBytes=0 ? "File open Error" : 0 )
}


