; Link:   	https://github.com/wofeng/PocketTAFramework/blob/f4989822f155ffaae143ec8506a3cd180e5a6fa5/Lib/Email/EmailLib.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

;-----------------------------
;
; Function: ReceiveEmailFromOL (v1.2.2)
; Description:
;		Initiates immediate delivery of all undelivered messages submitted in the current session, and immediate receipt of mail for all accounts in the current profile. 
; Syntax: ReceiveEmailFromOL()
; Parameters:
;		None	
; Remarks:
; 		The method will receive mails for all folders
; Related:
;		SendEmailFromOL
; Example: 
;		ReceiveEmailFromOL()
; 
;-------------------------------------------------------------------------------
ReceiveEmailFromOL()
{
	try
    {
		nsp:= ComObjActive("Outlook.Application").GetNamespace("MAPI")  
		nsp.SendAndReceive(true)
	}
	catch 
	{
	  Debug("[" . A_ThisFunc . "] Err- Please open Outlook first, then try again")
	  Gosub, ErrorLabel
	}
	
	WinWaitActive, ahk_class #32770,,3 	; Outlook Send/Receive Progress window
	WinWaitClose,,,5
}