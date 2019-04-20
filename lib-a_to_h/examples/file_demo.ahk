; #Include Crypt.ahk
; #Include File.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; http://www.autohotkey.com/forum/viewtopic.php?p=151228#151228
sFileOriginl   := A_AhkPath    ; Specify the real file path here!
sPassword   := "AutoHotkey"    ; Specify your own password here!

SID := 128   ; 128bit AES
sFileEncrypt := A_Temp . "\encrypt" . SID . ".bin"    ; Specify encrypted file path.
sFileDecrypt := A_Temp . "\decrypt" . SID . ".exe"    ; Specify decrypted file path.
File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)    ; Encryption
File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)   ; Decryption

SID := 192   ; 192bit AES
sFileEncrypt := A_Temp . "\encrypt" . SID . ".bin"
sFileDecrypt := A_Temp . "\decrypt" . SID . ".exe"
File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)    ; Encryption
File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)   ; Decryption

SID := 256   ; 256bit AES
sFileEncrypt := A_Temp . "\encrypt" . SID . ".bin"
sFileDecrypt := A_Temp . "\decrypt" . SID . ".exe"
File_AES(sFileOriginl, sFileEncrypt, sPassword, SID, True)    ; Encryption
File_AES(sFileEncrypt, sFileDecrypt, sPassword, SID, False)   ; Decryption

MsgBox, % "CRC32:`t"   . File_Hash(sFileOriginl, "CRC32")   . "`n"
   . "MD5:`t"   . File_Hash(sFileOriginl, "MD5")   . "`n"
   . "SHA1:`t"   . File_Hash(sFileOriginl, "SHA1")   . "`n"