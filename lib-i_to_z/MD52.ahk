/*

###############################################
Encrypt() - Password protected Text Encryption
by Avi Aryan
v 0.6
#############################

FEATURES
*  SAME KEY (PASSWORD) FOR ENCRYPTION AND DECRYPTION
*  ENCRYPTED STRING IS POWERFUL BUT OF SAME SIZE AS STRING
*  PASSWORDS CAN BE CASE-SENSITIVE AND ALPHA NUMERIC THUS SECURE AND EASY TO REMEMBER
*  STRING'S CASE IS CONSERVED THROUGH THE PROCESS

NOTES
*  Max Pass Length = 30 characters

PLEASE SEE
*  Requires Scientific Maths lib
*  The Crypt algorithm changes with version. So, the function stores version number in the encrypted text (from v0.3) and notifies you when you are using a
   older/newer version for decryption.
		Version History -  		https://github.com/avi-aryan/Avis-Autohotkey-Repo/commits/master/Functions/Encrypt.ahk

*/

/*
msgbox,% var1 := Encrypt("AutoHotkey_l", "lexikos")
msgbox,% Decrypt(var1, "lexIkos") ;<--- Password problem. I is capital in lexikos
msgbox,% Decrypt(var1, "lexiko")   ;<--- s missing and you r dead
msgbox,% Decrypt(var1, "lexikos")  ;<--- Perfect password , perfect result
*/

Encrypt(text, password){
	return Crypt(text, password)
}

Decrypt(text, password){

	if ( Substr(text, -1) != "06" ) {
		; msgbox, 16, Encrypt(),% "The text is encrypted using version " Substr(text,-1,1) "." Substr(text,0,1) "`nUse that version to decrypt."
		return
	}
	else text := Substr(text, 1, -2)

	return Crypt(text, password, 0)
}

;Crypt()
;	Performs encryption and decryption

Crypt(text, password, mode=1) {

	oldcase := A_StringCaseSense
	StringCaseSense, On

	letters := "abcdefghijklmnopqrstuvwxyz0123456789-,. @!?/:;()"	;48 . no limit here but still
	parsedlist := PassCrypt(password, letters, convindex, carryindex) "ABCDEFGHIJKLMOPQRSTUVWXYZ"
	letters .= "ABCDEFGHIJKLMOPQRSTUVWXYZ"
	
	Loop
	{
		if mode
			toreturn .= Crypt_Replace(letters, parsedlist, Substr(text, 1, convindex))
		else
			toreturn .= Crypt_Replace(parsedlist, letters, Substr(text, 1, convindex))
		
		parsedlist := Substr(parsedlist, 1-carryindex) SubStr(parsedlist, 1, -1*carryindex)
		text := Substr(text, convindex+1)
		if ( text == "" )
		{
			StringCaseSense, %oldcase%
			return mode ? toreturn "06" : toreturn	;04 is version . Not using a global
		}
	}
}

;PassCrypt()
;	Generates Random sequence from a password

PassCrypt(password, letters, Byref convindex, Byref carryindex){
	
	alphalist := Substr(letters, 1, 26)

	loop,parse,alphalist
		StringReplace,password,password,%A_loopfield%,%A_index%,All	;Convert to numeric format
	
	StringUpper,alphalist,alphalist
	loop,parse,alphalist
		StringReplace,password,password,%A_loopfield%,% A_index+26, All

	convindex := Substr(password, 1, 1) , carryindex := ( Substr(password, 0) == "0" ) ? 1 : Substr(password, 0)
	return SM_uniquePMT(letters, password, "|")
}

;Crypt_Replace()
;	Responsible for Find and Replace

Crypt_Replace(baselist, parsedlist, text){

	reschars := "¢¤¥¦§©ª«®µ¶"
	loop, parse, reschars
		if !Instr(text, A_LoopField) {
			conv_char := A_LoopField
			break
		}

	loop, parse, baselist
		StringReplace,text,text,%A_loopfield%,%A_loopfield%%conv_char%,All	;a_
	
	loop, parse, parsedlist
	{
		from_baselist := Substr(baselist, A_index, 1)
		StringReplace,text,text,%from_baselist%%conv_char%,%A_LoopField%,All
	}
	return text
}

#Include, %A_ScriptDir%\Functions\Maths.ahk

;-----------------------------------------------------------------------   X   -------------------------------------------------------------------------------