; Link:   	https://autohotkey.com/board/topic/92576-object-cryptwin/
; Author:	Learning one
; Date:
; for:     	AHK_L

/*


*/

/*==Description=========================================================================

[object] CryptWin
Encrypts & Decrypts text. Can store and read from files. Can encrypt or decrypt selected text in any text editor.
Based on idea to put sensitive text data in a few .txt files, and see/edit them quickly and easily via CryptWin.

Author:			Learning one (Boris Mudrinić)
Contact:		https://dl.dropboxusercontent.com/u/171417982/AHK/Learning one contact.png
Thanks to:		Chris Mallett, Lexikos, Deo and others...
Video tutorial:	http://screenr.com/3Sa7
AHK forum:		http://www.autohotkey.com/board/topic/92576-object-cryptwin/
Version:		1.05


=== License ===
You can freely use and distribute (but not sell, rent or similar) part of this product written by me (Learning one) if you
give a credit to me and people mentioned in "Thanks to" section.
You are not allowed to remove or modify comments from this file.
I'm not responsible for any damages arising from the use of this product. Use it at your own risk.
Crypt.ahk, CryptConst.ahk, CryptFoos.ahk are written by Deo. Contact him for usage terms for his code.


=== Credits ===
Thanks to Chris Mallett, Lexikos and others for AutoHotkey; http://www.autohotkey.com
Thanks to Deo for his "Crypt - ahk cryptography class"; http://www.autohotkey.com/board/topic/67155-ahk-l-crypt-ahk-cryptography-class-encryption-hashing/


=== See also ===
Gui Encrypt & Decrypt Text by jNizM; http://www.autohotkey.com/board/topic/90670-encrypt-decrypt-text/


=== Documentation ===
Watch video tutorial first.
CryptWin
- is based on idea to put sensitive text data in a few .txt files, and see/edit them quickly and easily via CryptWin
- depends on Crypt.ahk, CryptConst.ahk, CryptFoos.ahk by Deo, so you have to #Include them or put them in your Standard or User Library
- uses AES_256 crypt algorytm and SHA hash algorytm by default (can be changed)
- is portable
- is encapsulated
- allows you to set/get properties, call methods and monitor CryptWin's events
- can be used as stand-alone script or made part of another larger script without collision
- allows you to make your custom encryption tricks via BeforeDecrypt and AfterEncrypt events
- is not totally finished but most important functionalities are fully developed and working fine
- has reserved prefix: "CryptWin", uses "SafeFileOverwrite" functionality
- supports drag and drop, has resizable window
- can encrypt or decrypt selected text in any text editor
- besides encrypted plain text files, CryptWin can open encrypted MS Word documents and encrypted MS Excel workbooks


=== CryptWin window explained ===
Upper left edit control (password field) is a place where you have to write password. You must have password to open file, decrypt, encrypt and save text.
Big multi-line edit control (text field) is a place where you'll write/see your decrypted/encrypted text.
Switch between decrypted & encrypted radio buttons to see decrypted or encrypted text.
When you are in encrypted view mode, text will be colored in red.
Understand that you are not supposed to write decrypted text while you are in encrypted view mode, and vice versa.
DropDownList can be populated with your frequently used files and always has ">> New" and ">> Open..." items.
Click Save button to save file.
Click Save+Exit button to save file and ExitApp in one click (ExitApp part can be modified via GuiClose event)

Always write (correct) password first, and than do other stuff. You must have password to open file, decrypt, encrypt and save text.
When you are saving your secret text to a file, it will be saved encrypted, no matter if you are currently viewing it in decrypted view mode.
More precisely;
- if you are in decrypted view mode, your secret text will be encrypted first and than saved to a file.
- if you are in encrypted view mode, text which will be saved will be exactly the same as text currently displayed in text field.
CryptWin will ask you "Do you want to save changes?" if you made changes and haven't saved them.
If you click on Save button and nothing happens that means there are no changes in active document - so there's nothing new to save.
CryptWin will warn you if you are trying to save existing file, which was opened and decrypted with one password, with a new, different password.
You can drag and drop file which contain encrypted text on CryptWin window. Window is resizable.
To change font size, put the mouse cursor under the text field, hold control button down and scroll your mouse wheel up or down.


=== Example script 1 - simplest usage ===
	CryptWin()          ; initialise
	CryptWin.GuiShow()  ; show
	return

	#Include CryptWinClass.ahk  ; by Learning one
	#Include CryptFoos.ahk      ; by Deo
	#Include Crypt.ahk          ; by Deo
	#Include CryptConst.ahk     ; by Deo


=== Example script 2 - intermediate ===
	CryptWin()                    ; initialises CryptWin
	CryptWin.GuiSetSize(700, 350) ; sets the size of CryptWin window and centers it on the screen
	CryptWin.Password := "123456" ; sets password
	CryptWin.View := "Encrypted"  ; goes to Encrypted view mode
	CryptWin.Text := "E4278C66A8AB35963EA6C1458E8E0E0D25178AC7869B9FB378DF1199ACCFB96A"	; sets text (note that we switched to encrypted view mode one line above)
	CryptWin.View := "Decrypted"  ; goes to Decrypted view mode - decrypts text above
	CryptWin.FontSize := 22       ; sets font size to 22
	CryptWin.GuiShow()            ; shows window
	MsgBox, % CryptWin.Password   ; gets Password and shows it in MsgBox
	return

	F1::CryptWin.Selection("Encrypt") ; encrypts selected text in any text editor
	F2::CryptWin.Selection("Decrypt") ; decrypts selected text in any text editor

	#Include CryptWinClass.ahk  ; by Learning one
	#Include CryptFoos.ahk      ; by Deo
	#Include Crypt.ahk          ; by Deo
	#Include CryptConst.ahk     ; by Deo


=== Construction ===
CryptWin(Favorites*) is a function which constructs CryptWin object. It's variadic function and parameters are optional.
	It doesn't return anything but constructs super-global "CryptWin" object, which will be "visible/accessible" in all
	functions and classes in your code. You can construct only one CryptWin object per script (derive only one object from CryptWinClass).
	Favorites* is a list of encrypted files (items) which will appear in Favorites DropDownList. They can be:
	1) Filepath. Example: "C:\Encrypted text.txt". Program will extract file's name without extension and put it to the Favorites DropDownList.
		In this example, it would be "Encrypted text"
	2) <Name> Filepath. Example: "<Encrypted text 2> C:\v3sdede.txt". Instead of extracting file name without extension from Filepath,
		program will put name inside <> signs to the Favorites DropDownList. So, instead of "v3sdede", "Encrypted text 2" will appear in the list.
		This is useful if you want you obfuscate file names of your encrypted files.
	Examples:
	CryptWin()						; doesn't put any file in Favorites DropDownList
	CryptWin("C:\File1.txt")		; puts "File1" in Favorites DropDownList
	CryptWin("C:\File1.txt", "C:\qfre3f.txt", "C:\File3.txt")							; puts "File1", "qfre3f" and "File3" in Favorites DropDownList
	CryptWin("<My secret numbers> C:\9vg9x.txt", "<My private messages> C:\f4dx.txt")	; puts "My secret numbers" and "My private messages" in Favorites DropDownList


=== Most important Methods ===
• GuiShow(FocusField="Password")
	Shows CryptWin window. Window is initially invisible, so you must call this method if you want to see it.
	First parameter determines which field will be automotically focused when you call this method. Examples:
		CryptWin.GuiShow()				; Password field will be focused
		CryptWin.GuiShow("Password")	; Password field will be focused
		CryptWin.GuiShow("Text")		; Text field will be focused
		CryptWin.GuiShow(0)				; last focused control will remain focused
• GuiHide()
	Hides CryptWin window. Example: CryptWin.GuiHide()
• GuiSetSize(Width, Height, CenterWin=1)
	Sets the size of CryptWin window and centers it on the screen by default. Example: CryptWin.GuiSetSize(800, 450)
• New()
	Creates new, unsaved document. Example: CryptWin.New()
• Open(FullPath)
	Opens and decrypts file with encrypted text. You must specify password first! Return value:
	if there were no problems, method returns blank value, otherwise it returns a string which contains a short error description.
	Besides encrypted plain text files, CryptWin can open encrypted MS Word documents and encrypted MS Excel workbooks.
	Examples:
		CryptWin.Open("C:\Secret file.txt")
		CryptWin.Open("C:\Secret document.docx")
		CryptWin.Open("C:\Secret workbook.xlsx")
• Selection(Action, ReplaceIt=1, Password="", CryptAlg="", HashAlg="")
	Encrypts or decrypts selected text. Action can be "Encrypt" or "Decrypt". If ReplaceIt=1 (default), selected text will be replaced with new text.
	If Password, CryptAlg, HashAlg are blank (default) last used Password, CryptAlg, HashAlg will apply. If method fails,
	blank value is returned, otherwise, it returns new text. Examples:
		CryptWin.Selection("Encrypt")
		CryptWin.Selection("Decrypt")
• PasswordDialog()
	displays mini enter password dialog without showing main CryptWin window.  Example: CryptWin.PasswordDialog()
• Clear()
	Clears password field, edit field, and creates new, unsaved document without asking "do you want to save changes?" (if any in previous document).



=== Most important Properties ===
• CryptAlg
	Set/Get crypt algorytm. Default: 7 which means AES_256. For more info look below or in Deo's "Crypt - ahk cryptography class"
• HashAlg
	Set/Get hash algorytm. Default: 3 which means SHA. For more info look below or in Deo's "Crypt - ahk cryptography class"
• Password
	Set/Get password text in edit control (password field). Setting is equal as manually writing password in password field.
	Example set: CryptWin.Password := "MyPassword"       Example get: MsgBox % CryptWin.Password
• Text
	Set/Get text in edit control which you want to decrypt/encrypt (text field). Setting is equal as manually writing text in text field.
	Note: before setting the text, switch to appropriate view type first! Do not write decrypted text while you are in encrypted view mode, and vice versa.
• View
	Set/Get view type which can be "Decrypted" or "Encrypted". Note: you must have Password entered to switch view!
	Setting is equal as manually clicking on "Decrypted" or "Encrypted" radio buttons.
• FontSize
	Set/Get font size. Default: 10. Size must be between 2 and 22. You can set apsolute and relative font size. Examples:
		CryptWin.FontSize := 5		; sets font size to 5
		CryptWin.FontSize := 12		; sets font size to 12
		CryptWin.FontSize := "+1"	; sets font size +1 relative to current font size
		CryptWin.FontSize := "-1"	; sets font size -1 relative to current font size
• RootDir
	Set/Get starting directory in FileSelectFile dialog when you'll be saving unsaved, new file or opening a file. Default: blank.
	Example: CryptWin.RootDir := "C:\My encrypted stuff"
• AppendExtensionOnSave
	Set/Get ExtensionOnSave. Default: "txt" which means that program will append .txt extension to unsaved, new file if user didn't
	specified that extension in file name in FileSelectFile dialog. Leave it blank to append nothing or use your own special extension.
	Examples: CryptWin.AppendExtensionOnSave := "", CryptWin.AppendExtensionOnSave := "xyz"
• hGui, hgPassword, hgText
	Get handle (hwnd) to: CryptWin main window, Password field edit control, Text field edit control. Example: MsgBox % CryptWin.hGui
• EnableHotkeys
	Set/Get state of CryptWin's built-in context-sensitive hotkeys. Default: 1 (enabled). Examples: CryptWin.EnableHotkeys := 1, CryptWin.EnableHotkeys := 0
	List of  CryptWin's built-in context-sensitive hotkeys:
		^WheelUp::CryptWin.FontSize := "+1"
		^WheelDown::CryptWin.FontSize := "-1"
		^n::CryptWin.New()
		^o::CryptWin.OpenDialog()
		^s::CryptWin.GuiSaveSelect()
• AskToSaveChanges
	Set/Get. If set to 1 (default), if there are unsaved changes in active document, CryptWin will ask you do you want to save them before active document
	will be closed (which can be triggered via New() and Open() methods and GuiClose() event)
• Version
	Get CryptWin version. Example: MsgBox % CryptWin.Version
• ClearClipboardOnGuiClose
	If set to 1 (default), it will clear clipboard when CryptWin window closes. However, if user is monitoring GuiClose() event, if will not clear
	clipboard but will do what is specified in user's function instead.


=== Events ===
Events can be monitored via reference to user's function. No event is monitored by default. Examples:
CryptWin.Events.GuiClose := Func("CryptWin_GuiClose")	; means I want to monitor GuiClose event via "CryptWin_GuiClose" function which I made somewhere in the code.
CryptWin.Events.GuiClose := ""							; means I will not monitor GuiClose event any more.

Events list:
• GuiClose()
	Fires when CryptWin window is about to close. If not monitored, program will first ask you do you want to save changes (if any) in active document,
	and than ExitApp, otherwise, it will do what is specified in user's function. If CryptWin is part of another larger script,
	you'll usually want that GuiClose calls Clear() and GuiHide() instead of ExitApp.
• GuiSize()
	Fires when CryptWin window is resized, maximized, or restored. It does not fire when window is minimized. If not monitored,
	program will resize controls according to built-in resizing formula, otherwise, it will do what is specified in user's function.
• BeforeDecrypt(ByRef Text)
	Fires before decryption. You can modify text which will be decrypted via this event. Text is ByRef param!
• AfterEncrypt(ByRef Text)
	Fires after encryption. You can modify text which is encrypted via this event. Text is ByRef param!

Note: BeforeDecrypt & AfterEncrypt events will not fire if encrypted/decrypted text is blank.


=== Methods, properties and events demo - append this code to  Example script 1  ===
	F1::
	CryptWin.New()					; creates new, unsaved document
	CryptWin.Password := "123456"	; sets password
	CryptWin.View := "Encrypted"	; goes to Encrypted view mode
	CryptWin.Text := "E4278C66A8AB35963EA6C1458E8E0E0D25178AC7869B9FB378DF1199ACCFB96A"	; sets text (note that we switched to encrypted view mode one line above)
	CryptWin.View := "Decrypted"	; goes to Decrypted view mode - decrypts text above
	CryptWin.FontSize := 22			; sets font size to 22
	Loop, 12
	{
		Sleep, 50
		CryptWin.FontSize := "-1"	; shrinks font size by -1
	}
	CryptWin.GuiSetSize(700, 350)	; sets the size of CryptWin window and centers it on the screen
	MsgBox, % CryptWin.Password "`n" CryptWin.Text	; gets Password and Text and shows them in MsgBox
	CryptWin.Events.GuiClose := Func("CryptWin_GuiClose") ; starts monitoring and handling GuiClose event through CryptWin_GuiClose function
	CryptWin.GuiClose()				; closes CryptWin window (which triggers GuiClose event which we are monitoring)
	CryptWin.Events.GuiClose := ""	; stops monitoring GuiClose event (so if you close CryptWin window now, it will ExitApp)
	return

	CryptWin_GuiClose() {
		Gui CryptWin:+OwnDialogs
		MsgBox, 36, CryptWin, Are you sure you want to ExitApp?
		IfMsgBox, Yes
			ExitApp
	}


=== Events demo 2 - append this code to Example script 1  ===
	; You can combine BeforeDecrypt and AfterEncrypt events to make your top secret encryption tricks :)

	F2::CryptWin.Events.BeforeDecrypt := Func("CryptWin_BeforeDecrypt"), CryptWin.Events.AfterEncrypt := Func("CryptWin_AfterEncrypt") ; start monitoring events
	F3::CryptWin.Events.BeforeDecrypt := "", CryptWin.Events.AfterEncrypt := ""	; stop monitoring events

	CryptWin_BeforeDecrypt(ByRef Text) {	; Text is ByRef param! Text is string which will be decrypted.
		Text := SubStr(Text,2)				; removes first character from text which will be decrypted
	}
	CryptWin_AfterEncrypt(ByRef Text) {		; Text is ByRef param! Text is string which is encrypted.
		Random, ran, 0,9
		Text := ran Text 					; adds one random number as the first character to the encrypted text
	}


=== Example script 3 - when you want to use just selection encrypt/decrypt functionality without showing CryptWin window ====
	CryptWin()         				; initialise
	CryptWin.Password := "123456"	; set password
	return

	F1::CryptWin.Selection("Encrypt")	; encrypts selected text in any text editor
	F2::CryptWin.Selection("Decrypt")	; decrypts selected text in any text editor
	F3::CryptWin.PasswordDialog()		; displays mini enter password dialog without showing main CryptWin window - if you want to change password
	Esc::ExitApp

	#Include CryptWinClass.ahk  ; by Learning one
	#Include CryptFoos.ahk      ; by Deo
	#Include Crypt.ahk          ; by Deo
	#Include CryptConst.ahk     ; by Deo


=== Example script 4 - suggested code setup if CryptWin is part of another larger script ====
	CryptWin(), CryptWin.Events.GuiClose := Func("CryptWin_GuiClose")	; initialise + start monitoring GuiClose event
	return	; larger script's auto-execute section ends here

	#c::CryptWin.GuiShow()	; show CryptWin window hotkey

	CryptWin_GuiClose() {
		if (CryptWin.AskToSaveChangesDialog() = "Cancel")	; user pressed "Cancel" or GuiSaveSelect() failed or was aborted
			return
		else {			; instead of built-in ExitApp, call Clear(), GuiHide() and optionally clear clipboard
			CryptWin.Clear()
			CryptWin.GuiHide()
			if (CryptWin.ClearClipboardOnGuiClose=1)
				Clipboard := ""
		}
	}
	#Include CryptWinClass.ahk  ; by Learning one
	#Include CryptFoos.ahk      ; by Deo
	#Include Crypt.ahk          ; by Deo
	#Include CryptConst.ahk     ; by Deo

*/



;===Class===============================================================================
Class CryptWinClass {	; by Learning one
	static Version := 1.05, Author := "Learning one", WebSite := "http://www.autohotkey.com/board/topic/92576-object-cryptwin/"
	static DerivedObjectsCount := 0, Events := {}, LatestFavoriteFile := "", AskToSaveChanges := 1, ClearClipboardOnGuiClose := 1
	static GuiFavorites := [], Active := {}, GuiFavoritesList := "", RootDir:= "", AppendExtensionOnSave := "txt", EnableHotkeys := 1
	static _FontSize := 10
	static FontRendering := 5, FontColorDecrypted := "333333", FontColorEncrypted := "f10000", FontName := "Arial"
	static CryptAlg := 7	; 7 - AES_256
	static HashAlg := 3		; 3 - SHA

	/*
	From Deo's "Crypt - ahk cryptography class" http://www.autohotkey.com/board/topic/67155-ahk-l-crypt-ahk-cryptography-class-encryption-hashing/
	CryptAlg and hmac_alg IDs:
	1 - RC4
	2 - RC2
	3 - 3DES
	4 - 3DES_112
	5 - AES_128 ;not supported for win 2000
	6 - AES_192 ;not supported for win 2000
	7 - AES_256 ;not supported for win 2000
	--------
	HASH and Encryption algorithms currently available:
	HashAlg IDs:
	1 - MD5
	2 - MD2
	3 - SHA
	4 - SHA_256	;Vista+ only
	5 - SHA_384	;Vista+ only
	6 - SHA_512	;Vista+ only
	*/

	__New(Favorites*) {
		/*
		Favorites is a list of encrypted files (items) which will appear in Favorites DropDownList. They can be:
		1) Filepath. Example: "C:\Encrypted text.txt". Program will extract file's name without extension and put it to the Favorites DropDownList.
			In this example, it would be "Encrypted text"
		2) <Name> + Filepath. Example: "<Encrypted text 2> C:\v3sdede.txt". Instead of extracting file name without extension from Filepath,
			program will put name inside <> signs to the Favorites DropDownList. So, instead of "v3sdede", "Encrypted text 2" will appear in the list.
			This is useful if you want you obfuscate file names of your encrypted files.
		*/

		;=== Only 1 derived object per script is allowed  ==
		CryptWinClass.DerivedObjectsCount += 1
		if (CryptWinClass.DerivedObjectsCount > 1) {
			CryptWinClass.DerivedObjectsCount -= 1
			MsgBox, 16, Error, % "You can derive only one object from '" this.__class "' class per script!"
			return
		}

		;=== Favorites ===
		this.GuiFavoritesList := ""
		For k,v in Favorites
		{
			v := Trim(v)	; v exa: 1: "C:\Encrypted text.txt" 2: "<Encrypted text 2> C:\v3sdede.txt"
			RegExMatch(v, "<(.*)>(.*)", Match)	; Match1 = potential item name. Match2 = potential item filepath. Exa: Match1: "Encrypted text 2" Match2: " C:\v3sdede.txt"

			if (Match1 = "") {	; Exa case: "C:\Encrypted text.txt"
				FullPath := v
				if (this.GetPathType(FullPath) = "file") {
					SplitPath, FullPath,,,,NameNoExt
					this.GuiFavoritesList .= NameNoExt "|"
					this.GuiFavorites.Insert([NameNoExt, FullPath])	; Item structure: Name, FullPath
				}
			}
			else {				; Exa case: "<Encrypted text 2> C:\v3sdede.txt"
				NameNoExt := Match1, FullPath := Trim(Match2)
				if (this.GetPathType(FullPath) = "file") {
					this.GuiFavoritesList .= NameNoExt "|"
					this.GuiFavorites.Insert([NameNoExt, FullPath])	; Item structure: Name, FullPath
				}
			}
		}
		this.GuiFavoritesList := RTrim(this.GuiFavoritesList, "|")
		if (this.GuiFavoritesList = "")
			this.GuiFavoritesList .= ">> New|>> Open..."
		else
			this.GuiFavoritesList .= "|>> New|>> Open..."

		;=== Build GUI, pre-select, CueBanner ===
		Gui CryptWin:+HwndhGui +Resize +MinSize410x130
		Gui CryptWin:Add, Edit, x5 y5 w210 h25 Center Password hwndhgPassword,
		Gui CryptWin:Add, Radio, x221 y8 w90 h20 hwndhgDecrypted gCryptWinGuiDecryptedSelect, Decrypted
		Gui CryptWin:Add, Radio, x316 y8 w90 h20 hwndhgEncrypted gCryptWinGuiEncryptedSelect, Encrypted
		Gui CryptWin:Add, Button, x220 y32 w90 h25 hwndhgSaveExit gCryptWinGuiSaveExitSelect, Save + Exit
		Gui CryptWin:Add, Button, x315 y32 w90 h25 hwndhgSave gCryptWinGuiSaveSelect, Save
		Gui CryptWin: Font, s10	; a little bit larger font for DropDownList for more ergonomical selecting
		Gui CryptWin:Add, DropDownList, x5 y33 w210 R10 hwndhgFavorites gCryptWinGuiFavoritesSelect, % this.GuiFavoritesList	; Exa: "Encrypted text|Encrypted text 2|>> New|>> Open..."

		Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
		Gui CryptWin:Add, Edit, x5 y60 w400 h235 WantTab hwndhgText,

		/* ; BACKUP - old CryptWin v1.00 control sizing & positioning - DropDownList was smaller
		Gui CryptWin:+HwndhGui +Resize +MinSize410x130
		Gui CryptWin:Add, Edit, x5 y5 w210 h25 Center Password hwndhgPassword,
		Gui CryptWin:Add, DropDownList, x5 y33 w210 R10 hwndhgFavorites gCryptWinGuiFavoritesSelect, % this.GuiFavoritesList	; Exa: "Encrypted text|Encrypted text 2|>> New|>> Open..."
		Gui CryptWin:Add, Radio, x220 y7 w90 h20 hwndhgDecrypted gCryptWinGuiDecryptedSelect, Decrypted
		Gui CryptWin:Add, Radio, x315 y7 w90 h20 hwndhgEncrypted gCryptWinGuiEncryptedSelect, Encrypted
		Gui CryptWin:Add, Button, x220 y30 w90 h25 hwndhgSaveExit gCryptWinGuiSaveExitSelect, Save + Exit
		Gui CryptWin:Add, Button, x315 y30 w90 h25 hwndhgSave gCryptWinGuiSaveSelect, Save

		Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
		Gui CryptWin:Add, Edit, x5 y60 w400 h235 hwndhgText,
		*/

		GuiControl, CryptWin:, % hgDecrypted, 1			; select Decrypted radio (no this.hgDecrypted yet!)
		this.SetEditCueBanner(hgPassword, "Password")	; set CueBanner (no this.hgPassword yet!)
		; don't set focus to Password field because this window won't be visible until user calls GuiShow
		Gui CryptWin:Show, w410 h300 hide, CryptWin

		;=== Store, Set ===
		this.hGui := hGui
		this.hgPassword := hgPassword
		this.hgFavorites := hgFavorites
		this.hgDecrypted := hgDecrypted
		this.hgEncrypted := hgEncrypted
		this.hgSaveExit := hgSaveExit
		this.hgSave := hgSave
		this.hgText := hgText

		this.Active.Name := "", this.Active.FullPath := "", this.Active.IsDecrypted := 1, this.Active.Password := "", this.Active.EncryptedText := "", this.Active.DecryptedText := ""
	}
	__Get(key) {
		;MsgBox,, __Get, % key
		if (key = "Password") {
			GuiControlGet, Password, CryptWin:, % this.hgPassword	; get Password
			return Password
		}
		else if (key = "Text") {
			GuiControlGet, Text, CryptWin:, % this.hgText	; get Text
			return Text
		}
		else if (key = "View") {
			return (this.Active.IsDecrypted = 1) ? "Decrypted" : "Encrypted"
		}
		else if (key = "FontSize") {
			return this["_" key]	; redirect
		}
	}
	__Set(key, value) {
		;MsgBox,, __Set, % key " = " value
		if (key = "Password") {
			GuiControl, CryptWin:, % this.hgPassword, % value	; set text
			return ""	; do not assign
		}
		else if (key = "Text") {
			GuiControl, CryptWin:, % this.hgText, % value		; set text
			return ""	; do not assign
		}
		else if (key = "View") {
			if (value = "Decrypted")
				this.GuiDecryptedSelect()
			else if (value = "Encrypted")
				this.GuiEncryptedSelect()
			return ""	; do not assign
		}
		else if (key = "FontSize") {	; value is new font size
			value := Trim(value)
			FirstChar := SubStr(value,1,1)	; if FirstChar is "+" or "-" that means user wants to set font size relative to current font size
			if (FirstChar = "+")
				value := this.FontSize + SubStr(value, 2)	; without first char which is +
			else if (FirstChar = "-")
				value := this.FontSize - SubStr(value, 2)	; without first char which is -
			; if FirstChar is NOT "+" or "-" that means user wants to set apsolute font size

			this.PutNumInLimits(value, 2, 22)	; font size must be between 2 and 22. ByRef value

			if (this.Active.IsDecrypted = 1)
				Gui CryptWin: Font, % "s" value " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
			else
				Gui CryptWin: Font, % "s" value " q" this.FontRendering " c" this.FontColorEncrypted, % this.FontName	; Encrypted font
			GuiControl, CryptWin:Font, % this.hgText	; apply on text field
			return this["_" key]:= value		; assign to _key
		}
	}
	PutNumInLimits(ByRef Number, Min, Max) {
		if (Number < Min)
			Number := Min
		else if (Number > Max)
			Number := Max
	}
	HotkeysConditions(Context="Window") {
		if (this.EnableHotkeys != 1)	; hotkeys are disabled, so CryptWin's built-in hotkeys inside #If CryptWin.HotkeysConditions() code block will be blocked
			return
		if (WinExist("A") != this.hGui)	; CryptWin window is not active window
			return

		;=== For which Context ===
		if (Context="Window")	; because window is active - passed check above
			return 1
		else if (Context="Edit") {	;  mouse over edit control
			MouseGetPos,,,, ControlClass
			if ControlClass contains Edit
				return 1
		}
	}
	SetEditCueBanner(HWND, Cue) {  ; You cannot set a cue banner on a multiline edit control or on a rich edit control!
	   Static EM_SETCUEBANNER := (0x1500 + 1)
	   Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
	}
	GetPathType(FullPath) {	; Returns "folder" or "file" or "" it not exist
		Att := FileExist(FullPath)
		return (Att = "") ? "" : (InStr(Att, "D") > 0) ? "folder" : "file"
	}
	CenterWin(WinID) {	; Centers window on screen
		oldDHW := A_DetectHiddenWindows
		DetectHiddenWindows, on
		WinGetPos,,, W, H, ahk_id %WinID%
		SysGet, WA, MonitorWorkArea
		WAWidth := WAright - WAleft, WAHeight := WABottom - WAtop
		WinMove, ahk_id %WinID%,, (WAWidth - w)/2, (WAHeight - h)/2
		DetectHiddenWindows, %oldDHW%
	}
	GuiSize(){
		If (A_EventInfo = 1)  ; The window has been Minimized.  No action needed.
			Return

		if (this.Events.GuiSize != "")	; if user wants to monitor and handle this event
			this.Events.GuiSize.()
		else {							; if user is not monitoring this event GuiSize works according to built-in resizing formula
			gw := A_GuiWidth, gh := A_GuiHeight
			GuiControl, CryptWin:Move, % this.hgText, % "x5 y60 w" gw-10 " h" gh-65
		}
	}
	GuiSetSize(Width, Height, CenterWin=1) {	; Sets the size of CryptWin window and centers it on the screen by default.
		if (DllCall("IsWindowVisible", A_PtrSize ? "Ptr" : "UInt", this.hGui) = 1)	; win is visible
			Gui CryptWin:Show, % "w" Width " h" Height
		else
			Gui CryptWin:Show, % "w" Width " h" Height " hide"
		if (CenterWin=1)
			this.CenterWin(this.hGui)
	}
	GuiDropFiles() {
		StringSplit, File, A_GuiEvent, `n, `r
		this.Open(File1)	; operate just on first selected file
	}
	GuiShow(FocusField="Password") {
		if (FocusField="Password")
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
		else if (FocusField="Text")
			GuiControl, CryptWin:Focus, % this.hgText	; focus Text field
		Gui CryptWin:Show
	}
	GuiHide() {
		Gui CryptWin:Hide
	}
	GuiClose() {
		if (this.Events.GuiClose != "")	; if user wants to monitor and handle this event
			this.Events.GuiClose.()
		else {							; if user is not monitoring this event GuiClose does AskToSaveChangesDialog() + ExitApp
			if (this.AskToSaveChangesDialog() = "Cancel")	; user pressed "Cancel" or GuiSaveSelect() failed or was aborted
				return
			else {
				if (this.ClearClipboardOnGuiClose=1)
					Clipboard := ""
				ExitApp
			}
		}
	}
	GuiFavoritesSelect() {
		GuiControlGet, SelectedFavorite, CryptWin:, % this.hgFavorites	; get selected favorite name
		if (SelectedFavorite = ">> New") {		; user selected to create new, unsaved  encrypted file
			this.New()
		}
		else if (SelectedFavorite = ">> Open...") {
			this.OpenDialog()
		}
		else {									; user selected one of the favorite encrypted files
			For k,v in this.GuiFavorites		; Item structure: Name, FullPath
			{
				if (v.1 = SelectedFavorite) {		; found
					FullPath := v.2, Name := v.1
					break
				}
			}
			this.Open(FullPath, Name)
		}
	}
	PreselectLatestFavoriteFile() {
		if (this.LatestFavoriteFile = "")
			GuiControl, CryptWin:, % this.hgFavorites, % "|" this.GuiFavoritesList	; deselect effect
		else {
			ListToPut := this.PreSelectItem(this.GuiFavoritesList, this.LatestFavoriteFile)
			GuiControl, CryptWin:, % this.hgFavorites, % "|" ListToPut	; overwrite with ListToPut
		}
	}
	Clear() {		; Clears password field, edit field, and creates new, unsaved document without asking "do you want to save changes?" (if any in previous document).
		this.LatestFavoriteFile := ""
		this.Active.Name := "", this.Active.FullPath := "", this.Active.IsDecrypted := 1, this.Active.Password := "", this.Active.EncryptedText := "", this.Active.DecryptedText := ""
		GuiControl, CryptWin:, % this.hgDecrypted, 1	; select Decrypted radio

		GuiControl, CryptWin:, % this.hgPassword,		; empty Edit control (Password field)
		GuiControl, CryptWin:, % this.hgText,			; empty Edit control (Text field)
		Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
		GuiControl, CryptWin:Font, % this.hgText		; apply on text field

		GuiControl, CryptWin:, % this.hgFavorites, % "|" this.GuiFavoritesList	; deselect effect

		if (DllCall("IsWindowVisible", A_PtrSize ? "Ptr" : "UInt", this.hGui) = 1) {	; win is visible
			GuiControl, CryptWin:Focus, % this.hgText		; focus Edit control
			Gui CryptWin:Show,, CryptWin		; clear title
		}
		else
			Gui CryptWin:Show, hide, CryptWin	; clear title but keep it invisible
	}
	New() {		; Creates new, unsaved document.
		if (this.AskToSaveChangesDialog() = "Cancel") {	; user pressed "Cancel"
			this.PreselectLatestFavoriteFile()
			return
		}
		this.LatestFavoriteFile := ""
		this.Active.Name := "", this.Active.FullPath := "", this.Active.IsDecrypted := 1, this.Active.Password := "", this.Active.EncryptedText := "", this.Active.DecryptedText := ""
		GuiControl, CryptWin:, % this.hgDecrypted, 1	; select Decrypted radio

		GuiControl, CryptWin:, % this.hgText,			; empty Edit control
		Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
		GuiControl, CryptWin:Font, % this.hgText		; apply on text field

		GuiControl, CryptWin:, % this.hgFavorites, % "|" this.GuiFavoritesList	; deselect effect

		if (DllCall("IsWindowVisible", A_PtrSize ? "Ptr" : "UInt", this.hGui) = 1) {	; win is visible
			GuiControl, CryptWin:Focus, % this.hgText		; focus Edit control
			Gui CryptWin:Show,, CryptWin		; clear title
		}
		else
			Gui CryptWin:Show, hide, CryptWin	; clear title but keep it invisible
	}
	Open(FullPath, Name="") {	; Opens and decrypts file with encrypted text. You must specify password first! Return value: if there were no problems, method returns blank value, otherwise it returns a string which contains a short error description. Besides encrypted plain text files, CryptWin can open encrypted MS Word documents and encrypted MS Excel workbooks. Name parameter is used internally in GuiFavoritesSelect() method.

		Password := this.IsPasswordBlank()	; if Password is blank, it will display "MsgBox Password is missing!" and return blank value
		if (Password = "") { ; Password is blank
			this.PreselectLatestFavoriteFile()
			return "ERROR: Password is blank"
		}

		if (this.AskToSaveChangesDialog() = "Cancel") {	; user pressed "Cancel"
			this.PreselectLatestFavoriteFile()
			return "ERROR: User pressed Cancel in AskToSaveChangesDialog"
		}

		if (this.GetPathType(FullPath) != "file") {
			this.PreselectLatestFavoriteFile()
			return "ERROR: FullPath is not a file"
		}

		SplitPath, FullPath,,,Extension
		;=== Encrypted MS Word file ===
		if Extension in doc,docx
		{
			this.PreselectLatestFavoriteFile()
			try
				oWord := ComObjActive("Word.Application")
			catch {
				try
					oWord := ComObjCreate("Word.Application"), oWord.Visible := 1
				catch
					return "ERROR: Can't create Word.Application object"
			}
			try
				oDocument := oWord.Documents.Open(FullPath,0,0,0,Password)
			catch
				return "ERROR: Can't open MS Word document"
			if (oWord.ActiveWindow.WindowState = 2)	; wdWindowStateMinimize 2 Minimized
				oWord.ActiveWindow.WindowState := 0	; wdWindowStateNormal 0 Normal
			oWord.Activate
			oDocument.Activate
			return
		}

		;=== Encrypted MS Excel file ===	; Note - it currently doesn't access existing Excel.Application - it always creates new Excel.Application.
		if Extension in xls,xlsx
		{
			this.PreselectLatestFavoriteFile()
			try
				oExcel := ComObjCreate("Excel.Application"), oExcel.Visible := 1
			catch
				return "ERROR: Can't create Excel.Application object"

			m := ComObjMissing()
			try
				oWorkbook := oExcel.Workbooks.Open(FullPath,m,0,m,Password,m,m,m,m,m,m,m,0)
			catch
				return "ERROR: Can't open MS Excel workbook"
			/*
			if (oExcel.ActiveWindow.WindowState = "-4140")	; xlMinimized -4140 Minimized
				oExcel.ActiveWindow.WindowState := "-4143"	; xlNormal -4143 Normal
			*/
			oExcel.ActiveWindow.Activate
			oWorkbook.Activate
			return
		}

		;=== Encrypted plain text file ===
		try
			FileRead, EncryptedText, % FullPath	; get Text
		catch {
			this.PreselectLatestFavoriteFile()
			return "ERROR: Can't read file"
		}
		EncryptedText := Trim(EncryptedText, " `t`n`r")	; trim it because there should not be whitespaces around encrypted text but user maybe put them

		result := this.GuiDecrypt(EncryptedText, Password)	 ; Return value structure: [WasSuccessful, DecryptedText]
		if (result.1 != 1) {	; error
			this.PreselectLatestFavoriteFile()
			return "ERROR: Can't decrypt file"
		}

		;=== If OK ===
		; If all OK, GuiDecrypt() will update gui, focus Edit control and set this.Active.IsDecrypted := 1

		if (Name = "")
			SplitPath, FullPath,,,,Name	; name is NameNoExt

		;= Recognize and select if file is member of GuiFavorites =
		For k,v in this.GuiFavorites		; Item structure: Name, FullPath
		{
			if (v.2 = FullPath) {		; found - FullPaths match
				Name := v.1, FullPath := v.2, this.LatestFavoriteFile := Name, IsMemeberOfGuiFavorites := 1
				this.PreselectLatestFavoriteFile()
				break
			}
		}
		if (IsMemeberOfGuiFavorites != 1) {
			this.LatestFavoriteFile := ""
			GuiControl, CryptWin:, % this.hgFavorites, % "|" this.GuiFavoritesList	; deselect effect
		}

		;= Store, update, Show=
		this.Active.Name := Name, this.Active.FullPath := FullPath, this.Active.IsDecrypted := 1
		this.Active.Password := Password
		this.Active.EncryptedText := EncryptedText, this.Active.DecryptedText := result.2	; result.2 is DecryptedText

		Gui CryptWin:Show,, % "CryptWin - " Name
		; if there were no problems, function returns blank value
	}
	OpenDialog() {	; Displays Open file dialog. You must specify password first! Return value - same as for Open() method
		Gui CryptWin:+OwnDialogs
		Password := this.IsPasswordBlank()	; if Password is blank, it will display "MsgBox Password is missing!" and return blank value
		if (Password = "") { ; Password is blank
			this.PreselectLatestFavoriteFile()
			return "ERROR: Password is blank"
		}

		FileSelectFile, FullPath, 1, % this.RootDir, Open file with encrypted text	; 1: File Must Exist
		if (ErrorLevel = 1) {	; user dismissed the dialog without selecting a file
			this.PreselectLatestFavoriteFile()
			return "ERROR: User dismissed the dialog without selecting a file"
		}

		Result := this.Open(FullPath)
		return Result
	}
	PasswordDialog() {	; displays mini enter password dialog without showing main CryptWin window. Returns new password and automatically sets this.Password := NewPassword if NewPassword is successfully set, otherwise returns blank value.
		; Don't use: Gui CryptWin:+OwnDialogs
		CryptWinShowPasswordDialogAgain:
		InputBox, NewPassword, CryptWin, Enter password, hide, 240, 130
		if (ErrorLevel = 0)	{	; 0 = user clicked OK
			NewPassword := Trim(NewPassword, " `t`n`r")
			if NewPassword is Space	; Password can't be empty or contain only whitespace. Show dialog again.
				goto, CryptWinShowPasswordDialogAgain
			else {
				this.Password := NewPassword	; set new Password
				return NewPassword
			}
		}
	}
	AskToSaveChangesDialog() {	; if AskToSaveChanges = 1 (default) and there are changes in active doc, it will ask user does he want to save changes. If he clicks Yes, that's equal as he clicked "save button". If user pressed "Cancel" or if GuiSaveSelect() failed or was aborted method returns "Cancel", otherwise blank value is returned.
		if (this.AskToSaveChanges = 1 and this.AreThereChangesInDoc() = 1) {
			Gui CryptWin:+OwnDialogs
			if (this.Active.Name = "")	; new, unnamed document
				MsgBox, 35, CryptWin, Do you want to save changes in this new document?
			else
				MsgBox, 35, CryptWin, % "Do you want to save changes in " this.Active.Name "?"
			IfMsgBox, Yes
			{
				if (this.GuiSaveSelect() = "")	; blank value = Error or aborted
					return "Cancel"
			}
			IfMsgBox, Cancel
				return "Cancel"
		}
	}
	PreSelectItem(List, ToPreSelect) {
		Loop, parse, List, |
		{
			if (A_loopField = ToPreSelect)
			NewList .= A_loopField "||"
			else
			NewList .= A_loopField "|"
		}
		if !(SubStr(NewList,-1) = "||")
		NewList := RTrim(NewList,"|")
		return NewList
	}
	IsPasswordBlank() {
		Password := Trim(this.Password, " `t`n`r")
		if Password is Space	; Password can't be empty or contain only whitespace.
		{
			Gui CryptWin:+OwnDialogs
			MsgBox, 16, Error, Password is missing!
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
			return		; Password is blank
		}
		return Password	; Password is not blank, return trimmed Password
	}
	GuiDecrypt(Text, Password, UpdateGui=1) { ; Return value structure: [WasSuccessful, DecryptedText]
		Password := Trim(Password, " `t`n`r")
		Text := Trim(Text, " `t`n`r")	; trim it because there should not be whitespaces around encrypted text but user maybe put them
		if Password is Space
		{
			Gui CryptWin:+OwnDialogs
			MsgBox, 16, Error, Password is missing!
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
			return ["",""]	; structure: WasSuccessful, DecryptedText
		}

		;=== Decrypt text ===
		if Text is Space
			DecryptedText := ""
		else {
			Gui CryptWin:+OwnDialogs	; because  Crypt.Encrypt.StrDecrypt() can display error MsgBox
			if (this.Events.BeforeDecrypt != "")	; if user wants to monitor and handle this event
				this.Events.BeforeDecrypt.(Text)	; execute user's function (call a function by reference). Text is ByRef param! Exa: Text := SubStr(Text,2)	; removes first character

			DecryptedText := Crypt.Encrypt.StrDecrypt(Text, Password, this.CryptAlg, this.HashAlg) ; decrypts string
			if (ErrorLevel != 0)	; Decrypt call fialed
				return ["",""]	; structure: WasSuccessful, DecryptedText
		}

		;=== If decrypt was successful ===
		if (UpdateGui=1) {
			this.Active.IsDecrypted := 1							; it was Encrypted and now it will be Decrypted
			GuiControl, CryptWin:, % this.hgText					; temporary empty for faster coloring below (tested)
			Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorDecrypted, % this.FontName	; Decrypted font
			GuiControl, CryptWin:Font, % this.hgText				; apply on text field

			GuiControl, CryptWin:, % this.hgText, % DecryptedText	; set DecryptedText to Edit control
			GuiControl, CryptWin:, % this.hgDecrypted, 1			; select Decrypted radio
			GuiControl, CryptWin:Focus, % this.hgText				; focus Edit control
		}
		return [1, DecryptedText]	; structure: WasSuccessful, DecryptedText
	}
	GuiEncrypt(Text, Password, UpdateGui=1) { ; Return value structure: [WasSuccessful, EncryptedText]
		Password := Trim(Password, " `t`n`r")
		if Password is Space
		{
			Gui CryptWin:+OwnDialogs
			MsgBox, 16, Error, Password is missing!
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
			return ["",""]	; structure: WasSuccessful, DecryptedText
		}

		;=== Encrypt text ===
		if Text is Space
			EncryptedText := ""
		else {
			Gui CryptWin:+OwnDialogs	; because  Crypt.Encrypt.StrEncrypt() can display error MsgBox

			EncryptedText := Crypt.Encrypt.StrEncrypt(Text, Password, this.CryptAlg, this.HashAlg) ; encrypts string
			if (ErrorLevel != 0)	; Encrypt call fialed
				return ["",""]	; structure: WasSuccessful, EncryptedText

			if (this.Events.AfterEncrypt != "")	; if user wants to monitor and handle this event
				this.Events.AfterEncrypt.(EncryptedText)	; execute user's function (call a function by reference). EncryptedText is ByRef param! Exa: Text := "4" Text ; adds one character to the beginning (should be random)
		}

		;=== If Encrypt was successful ===
		if (UpdateGui=1) {
			this.Active.IsDecrypted := 0							; it was Decrypted and now it will be Encrypted
			GuiControl, CryptWin:, % this.hgText					; temporary empty for faster coloring below (tested)
			Gui CryptWin: Font, % "s" this.FontSize " q" this.FontRendering " c" this.FontColorEncrypted, % this.FontName	; Encrypted font
			GuiControl, CryptWin:Font, % this.hgText				; apply on text field

			GuiControl, CryptWin:, % this.hgText, % EncryptedText	; set EncryptedText to Edit control
			GuiControl, CryptWin:, % this.hgEncrypted, 1			; select hgEncrypted radio
			GuiControl, CryptWin:Focus, % this.hgText				; focus Edit control
		}
		return [1, EncryptedText]	; structure: WasSuccessful, EncryptedText
	}
	GuiDecryptedSelect() {
		if (this.Active.IsDecrypted = 1)	; already Decrypted. Prevents re-decryption.
			return

		Password := Trim(this.Password, " `t`n`r")
		if Password is Space
		{
			GuiControl, CryptWin:, % this.hgEncrypted, 1	; select radio
			Gui CryptWin:+OwnDialogs
			MsgBox, 16, Error, Password is missing!
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
			return
		}

		result := this.GuiDecrypt(this.Text, Password)
		if (result.1 != 1) {	; error
			GuiControl, CryptWin:, % this.hgEncrypted, 1	; select radio
			return
		}

		; If all OK, GuiDecrypt() will update gui, focus Edit control and set this.Active.IsDecrypted := 1
	}
	GuiEncryptedSelect() {
		if (this.Active.IsDecrypted = 0)	; already Encrypted. Prevents re-encryption.
			return

		Password := Trim(this.Password, " `t`n`r")
		if Password is Space
		{
			GuiControl, CryptWin:, % this.hgDecrypted, 1	; select radio
			Gui CryptWin:+OwnDialogs
			MsgBox, 16, Error, Password is missing!
			GuiControl, CryptWin:Focus, % this.hgPassword	; focus Password field
			return
		}

		result := this.GuiEncrypt(this.Text, Password)
		if (result.1 != 1) {	; error
			GuiControl, CryptWin:, % this.hgDecrypted, 1	; select radio
			return
		}

		; If all OK, GuiEncrypt() will update gui, focus Edit control and set this.Active.IsDecrypted := 0
	}
	AreThereChangesInDoc() {	; returns 1 if there are changes in active document - compares current text and text which was present in the moment of opening existing file or creating a new one
		if (this.Active.IsDecrypted = 1) {
			if (this.Active.DecryptedText != this.Text)
				return 1
		}
		else {
			if (Trim(this.Active.EncryptedText, " `t`n`r") != Trim(this.Text, " `t`n`r"))
				return 1
		}
	}
	GuiSaveSelect() {	; return value: 1 = OK, blank value = Error or aborted
		Gui CryptWin:+OwnDialogs
		Password := this.IsPasswordBlank()	; if Password is blank, it will display "MsgBox Password is missing!" and return blank value
		if (Password = "") ; Password is blank
			return

		;=== If we are dealing with encrypted text which was loaded from file, and there is a difference between current password and password which was used to decrypt and open this file - warn the user! ===
		if (this.Active.FullPath != "" and this.Active.Password != Password) {
			MsgBox, 276, CryptWin - Different passwords warning!, There is a difference between current password and password which was used to decrypt and open this file. Are you sure you want to use new (current) password to encrypt and save this file? If you click Yes, you'll change password for this file.`n`nRecommended: No
			IfMsgBox, No
				return
			IfMsgBox, Yes
				this.Active.Password := Password, UserHasNewPassword := 1
		}
		if (UserHasNewPassword != 1) {
			if (this.AreThereChangesInDoc() != 1) { 	; no changes in active doc
				if (this.GetPathType(this.Active.FullPath) = "file") {
					;MsgBox, 64, CryptWin, No changes - nothing to save, 1
					GuiControl, CryptWin:Focus, % this.hgText	; focus Text field
					return 1
				}
			}
		}

		;=== Get EncryptedText ===
		if (this.Active.IsDecrypted = 1) {	; Text is decrypted. We have to encrypt it first.
			GuiControlGet, Text, CryptWin:, % this.hgText	; get text
			result := this.GuiEncrypt(Text, Password, 0)	; Encrypt but don't update gui
			; Return value structure: [WasSuccessful, EncryptedText]
			if (result.1 != 1)	; error
				return
			EncryptedText := result.2
			DecryptedText := Text
		}
		else {								; Text is already encrypted
			GuiControlGet, Text, CryptWin:, % this.hgText			; get text
			Text := Trim(Text, " `t`n`r")	; trim it because there should not be whitespaces around encrypted text but user maybe put them

			;== Although text is already encrypted, call GuiDecrypt() to see if there are problems with decrypting... ==
			result := this.GuiDecrypt(Text, Password, 0)	; Decrypt but don't update gui
			; Return value structure: [WasSuccessful, DecryptedText]
			if (result.1 != 1)	; error
				return
			if (result.2 = 0) {	; 0 = potential error...
				MsgBox, 292, Potential error, If this text would be decrypted`, it would give result "0" which usually means that something is wrong. Are you sure you want to save this file?`n`nRecommended: No
				IfMsgBox, No
					return
			}
			EncryptedText := Text	; NOT result.2 - that is DecryptedText!
			DecryptedText := result.2
		}

		;=== Determine FullPath where to save and Name  ===
		if (this.GetPathType(this.Active.FullPath) != "file") {		; no active filepath (new, unsaved file) or it doesn't exist any more
			FileSelectFile, FullPath, S24, % this.RootDir, Save new file	; 8: Prompt to Create New File 16: Prompt to OverWrite File S: Save button.
			if (ErrorLevel = 1)	; user dismissed the dialog without selecting a file
				return

			;=== Auto extension if needed ===
			this.AppendExtensionOnSave := Trim(this.AppendExtensionOnSave, ".")
			if (this.AppendExtensionOnSave != "") {	; AppendExtensionOnSave is without dot exa: "txt" or blank
				if (SubStr(FullPath,-StrLen(this.AppendExtensionOnSave)) != "." this.AppendExtensionOnSave)
					FullPath .= "." this.AppendExtensionOnSave
			}

			SplitPath, FullPath,,,,Name	; name is NameNoExt
		}
		else
			FullPath := this.Active.FullPath, Name := this.Active.Name	; use same old FullPath and Name

		;=== Overwrite file ===
		Result := this.SafeFileOverwrite(FullPath, EncryptedText)
		if (Result = "") { ; successful

			;=== Update ===
			this.Active.Name := Name, this.Active.FullPath := FullPath, this.Active.Password := Password
			this.Active.EncryptedText := EncryptedText, this.Active.DecryptedText := DecryptedText
			Gui CryptWin:Show,, % "CryptWin - " Name

			;=== Info user ===
			MsgBox, 64, CryptWin, Saved, 0.8
			GuiControl, CryptWin:Focus, % this.hgText	; focus Text field
			return 1 ; saved succesfuly
		}
		else {
			MsgBox, 16, CryptWin, % "File was NOT SAVED correctly!`n`n" Result
			return ; error
		}
	}
	GuiSaveExitSelect() {
		if (this.GuiSaveSelect() != 1)	; error, aborted
			return
		this.GuiClose()
	}
	Selection(Action, ReplaceIt=1, Password="", CryptAlg="", HashAlg="") {	; Encrypts or decrypts selected text. Action can be "Encrypt" or "Decrypt". If ReplaceIt=1 (default), selected text will be replaced with new text. If Password, CryptAlg, HashAlg are blank (default) last used Password, CryptAlg, HashAlg will apply. If method fails, blank value is returned, otherwise, it returns new text.
		Password := (Password="") ? this.Password : Password	; if password is not specified
		if Password is Space
		{
			result := this.PasswordDialog()	; displays mini enter password dialog without showing main CryptWin window. Returns new password and automatically sets this.Password := NewPassword if NewPassword is successfully set, otherwise returns blank value.
			if (result = "")	; fail
				return
			else				; success
				Password := result
		}
		CryptAlg := (CryptAlg="") ? this.CryptAlg : CryptAlg
		HashAlg := (HashAlg="") ? this.HashAlg : HashAlg

		;=== GetSelected text ===
		IsClipEmpty := (Clipboard = "") ? 1 : 0
		if (IsClipEmpty != 1) {	; not empty
			ClipboardBackup := ClipboardAll	; backup
			While (Clipboard != "") {	; empty Clipboard - looks funny but  usually is more reliable...
				Clipboard := ""
				Sleep, 20
			}
		}
		Send, ^c
		ClipWait, 0.1	; waits specifically for text or files to appear for 0.1 seconds

		Text := Clipboard	; Text is SelectedText
		this.PutToClipBoard(ClipboardBackup)	; restore Clipboard

		if Text is space
			return

		;=== If there's something to work with ===
		if (Action = "Decrypt") {

			; There should not be WhiteSpaces around encrypted text but user maybe selected them. Exa case: " 3A45501  "
			RegExMatch(Text, "(*UCP)^(\s*)(\S*)(\s*)$", match)
			WhiteSpacesBefore := match1
			Text := match2
			WhiteSpacesAfter := match3
			;ToolTip % ">" match1 "<`n" ">" match2 "<`n" ">" match3 "<`n"

			if (this.Events.BeforeDecrypt != "")	; if user wants to monitor and handle this event
				this.Events.BeforeDecrypt.(Text)	; execute user's function (call a function by reference). Text is ByRef param! Exa: Text := SubStr(Text,2)	; removes first character

			NewText := Crypt.Encrypt.StrDecrypt(Text, Password, CryptAlg, HashAlg) ; decrypts string
			if (ErrorLevel != 0) 	; Decrypt call fialed
				return
			else {	; success
				if (NewText = 0)	; 0 = potential error... it usually is
					return
				if (ReplaceIt=1) {
					this.PutToClipBoard(WhiteSpacesBefore NewText WhiteSpacesAfter)
					Sleep, 100		; improves reliability
					Send, ^v		; paste
					Sleep, 200		; improves reliability
					this.PutToClipBoard(ClipboardBackup)
				}
				return NewText
			}
		}
		else if (Action = "Encrypt") {
			; Note: don't do RegExMatch(Text, "(*UCP)^(\s*)(\S*)(\s*)$", match) stuff here - if user selected WhiteSpaces, encrypt them too

			NewText := Crypt.Encrypt.StrEncrypt(Text, Password, CryptAlg, HashAlg) ; encrypts string
			if (ErrorLevel != 0) {	; Encrypt call fialed
				return
			}
			else {	; success
				if (this.Events.AfterEncrypt != "")	; if user wants to monitor and handle this event
					this.Events.AfterEncrypt.(NewText)	; execute user's function (call a function by reference). NewText is ByRef param!
				if (ReplaceIt=1) {
					this.PutToClipBoard(NewText)
					Sleep, 100		; improves reliability
					Send, ^v		; paste
					Sleep, 200		; improves reliability
					this.PutToClipBoard(ClipboardBackup)
				}
				return NewText
			}
		}
	}
	PutToClipBoard(ToPut) {	; probably a little bit more reliable than just "Clipboard := ToPut" or not...?
		if (ToPut = "")
			Clipboard := ""
		else {
			; Clipboard := ""	; first empty, than put? More reliable or not?
			Clipboard := ToPut
			ClipWait, 0.5, 1	; waits for data of any kind to appear on the clipboard for 0.5 seconds
		}
	}
	SafeFileOverwrite(FilePath, NewFileText="", Encoding = "") {	; Safely overwrites a file. It makes temporary backup of a file in a same folder as file, deletes original file, creates it again and appends it with new text, and than deletes backup if there were no problems. If there were no problems, function returns blank value, else: it returns a string which contains a short error description and the original file or backup will stay in the same folder as original file, so nothing will be lost. Preserves original file attributes. By Learning one. Last update: 17.04.2013.

		FilePath := RTrim(FilePath, "\")
		Att := FileExist(FilePath)
		if (Att = "") {	; FilePath doesn't exist - there's nothing to overwrite, just do FileAppend
			try
				FileAppend, %NewFileText%, %FilePath%, %Encoding%	; make new original with replaced text
			catch
				return "ERROR: problems with FileAppend"
			return	; if there were no problems, function returns blank value
		}
		if (InStr(Att, "D") > 0)
			return "ERROR: specified path is a folder, not file"

		SplitPath, FilePath, FileName, Dir, Ext, NameNoExt
		Loop	; find free BackupFilePath
		{
			if (A_index = 1)
				CheckPath := Dir "\" NameNoExt " backup." Ext
			else
				CheckPath := Dir "\" NameNoExt " backup " A_Index "." Ext
			if (FileExist(CheckPath) = "") {	; free
				BackupFilePath := CheckPath
				break
			}
		}

		try
			FileCopy, %FilePath%, %BackupFilePath%	; make a backup
		catch
			return "ERROR: problems with making backup"

		try {
			if (InStr(Att, "R") > 0)	; file is read only
				FileSetAttrib, -R, % FilePath	; AHK help: to delete a read-only file, first remove the read-only attribute
			; no need to catch&try removing the read-only attribute - if it fails, FileDelete will fail
			FileDelete, %FilePath%	; delete original
		}
		catch
			return "ERROR: problems with deleting file"

		try
			FileAppend, %NewFileText%, %FilePath%, %Encoding%	; make new original with replaced text
		catch
			return "ERROR: problems with FileAppend"

		if (Att != "" and Att != "X") {	; if doesn't exist or has no attributes (X), don't restore original file attribures, otherwise, restore them
			try
				FileSetAttrib, % "+" Att, % FilePath
			catch
				return "ERROR: problems with FileSetAttrib"
		}

		try {
			if (InStr(Att, "R") > 0)	; file is read only. BackupFilePath has the same attributes as original FilePath - (FileCopy used)
				FileSetAttrib, -R, % BackupFilePath	; AHK help: to delete a read-only file, first remove the read-only attribute
			; no need to catch&try removing the read-only attribute - if it fails, FileDelete will fail
			FileDelete, %BackupFilePath%	; delete backup, because there were no problems above
		}
		catch
			return "ERROR: problems with deleting backup"

		; if there were no problems, function returns blank value
	}
}

;====== CryptWin subroutines ======
CryptWinGuiFavoritesSelect:
CryptWinGuiDecryptedSelect:
CryptWinGuiEncryptedSelect:
CryptWinGuiSaveExitSelect:
CryptWinGuiSaveSelect:
CryptWinGuiClose:
CryptWinGuiSize:
CryptWinGuiDropFiles:
CryptWin[SubStr(A_ThisLabel,9)]()	; CryptWin = 8 characters, trims "CryptWin" and executes appropriate method like GuiClose, GuiSize, etc.
return


CryptWinMakeItSuperGlobal:
global CryptWin	; make super-global variable "CryptWin"
return

;====== CryptWin initialization function ======
CryptWin(p*) {	; call it to initialize CryptWin
	if (CryptWinClass.DerivedObjectsCount = 0) {	; only one derived object per script is allowed
		gosub, CryptWinMakeItSuperGlobal
		CryptWin := new CryptWinClass(p*)	; pass all params
	}
	else
		MsgBox, 16, Error, % "You can derive only one object from 'CryptWinClass' class per script!"
}

;====== CryptWin hotkeys ======
;Use CryptWin.EnableHotkeys := 1 or CryptWin.EnableHotkeys := 0 to enable/disable CryptWin's built-in context-sensitive hotkeys.
#If CryptWin.HotkeysConditions("Edit")
^WheelUp::CryptWin.FontSize := "+1"
^WheelDown::CryptWin.FontSize := "-1"

#If CryptWin.HotkeysConditions()
^n::CryptWin.New()
^o::CryptWin.OpenDialog()
^s::CryptWin.GuiSaveSelect()
#If
