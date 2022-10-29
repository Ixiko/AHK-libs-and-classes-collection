; ===================================================================================
; AHK Version ...: AHK_L 1.1.09.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Script ........: En-Decrypt.ahk
; Description ...: Encrypt & Decrypt Data
; ===================================================================================

; GLOBAL SETTINGS ===================================================================

#NoEnv
#SingleInstance force

#Include ..\class_Crypt.ahk
#Include ..\class_CryptConst.ahk
#Include ..\..\libs\a-f\CryptFoos.ahk

; SCRIPT ============================================================================

Gui, Margin, 10, 10
Gui, Font, s10, Tahoma

Gui, Add, Edit, xm ym w300 h120 vStr, En-/DeCrypt
Gui, Add, Edit, xm y+5 w300 vStr2, Password
Gui, Add, Edit, xm y+10 w300 h120 vEnDeCrypt ReadOnly
Gui, Add, DropDownList, xm y+5 w300 AltSubmit vEncryption, RC4 (Rivest Cipher)
																							|RC2 (Rivest Cipher)
																							|3DES (Data Encryption Standard)
																							|3DES 112 (Data Encryption Standard)
																							|AES 128 (Advanced Encryption Standard)
																							|AES 192 (Advanced Encryption Standard)
																							|AES 256 (Advanced Encryption Standard)||
Gui, Add, Button, xm-1 y+5 w100, Encrypt
Gui, Add, Button, xm+201 yp w100, Decrypt

Gui, Show,, En-/DeCrypt
Return

ButtonEncrypt:
	GuiControlGet, Str
	GuiControlGet, Str2
	GuiControlGet, Encryption
	MsgBox, % Encryption
	GuiControl,, EnDeCrypt, % Crypt.Encrypt.StrEncrypt(Str, Str2, Encryption, 6)
Return

ButtonDecrypt:
	GuiControlGet, Str
	GuiControlGet, Str2
	GuiControlGet, Encryption
	GuiControl,, EnDeCrypt, % Crypt.Encrypt.StrDecrypt(Str, Str2, Encryption, 6)
Return

; EXIT ==============================================================================

GuiClose:
GuiEscape:
ExitApp

; LEGEND ============================================================================