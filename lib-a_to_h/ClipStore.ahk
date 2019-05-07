ClipStore(fnClipAction,ByRef fnClipContentsVar := "",ByRef fnClipStorageVar := "")
{
	; stores the current clipboard and captures the selected text
	; uses atypical return values to make call syntax more intuitive e.g. If !ClipStore("Copy",xVarx) means 'if text was not copied to xVarx successfully'
	; MsgBox fnClipAction: %fnClipAction%`nfnClipContentsVar: %fnClipContentsVar%`nfnClipStorageVar: %fnClipStorageVar%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 1 ; success: atypical return value


		; validate parameters
		If fnClipAction not in Copy,C,Paste,P,Store,S,Restore,R
			Throw, Exception("fnClipAction not in Copy,C,Paste,P,Store,S,Restore,R")
		
		fnClipAction := fnClipAction = "Copy"    ? "C"
					 :  fnClipAction = "Paste"   ? "P"
					 :  fnClipAction = "Store"   ? "S"
					 :  fnClipAction = "Restore" ? "R"
					 :  fnClipAction

		If fnClipAction in C,P
			If !IsByRef(fnClipContentsVar)
				Throw, Exception("fnClipContentsVar was not provided")
		
		If fnClipAction in P
			If !fnClipContentsVar
				Throw, Exception("fnClipContentsVar was empty")			

		If fnClipAction in R,S
		{
			If !IsByRef(fnClipStorageVar)
				Throw, Exception("fnClipStorageVar was not provided")
		}
		
		If fnClipAction in R
		{
			If !fnClipStorageVar
				Throw, Exception("fnClipStorageVar was empty")
		}


		; initialise variables
		AutoTrimStatus := A_AutoTrim


		; set autotrim
		AutoTrim, Off

		
		; clipboard in / out
		If fnClipAction in C,S ; if copy or store
		{
			; store contents of the clipboard
			fnClipStorageVar := Clipboard ;All 
			
			; capture selected
			If (fnClipAction = "C")
			{
				Clipboard = ; empty the clipboard
				Send ^c ; copy
				ClipWait, 1 ; wait 1 second for clipboard to contain something
				If (ErrorLevel || !Clipboard) ; if nothing appeared on clipboard
				{
					Clipboard = %fnClipStorageVar% ; restore original clipboard contents
					fnClipStorageVar := "" ; empty clipstore variable
					Throw, Exception("Nothing appeared on clipboard after copy",-1,"AlwaysSilent")
				}
				fnClipContentsVar := Clipboard ; pass the clipboard contents back out of the function
			}
		}
		Else ; if paste or restore
		{
			; paste input
			If (fnClipAction = "P")
			{
				Clipboard = ; empty the clipboard
				Clipboard = %fnClipContentsVar% ; read contents of variable back to clipboard
				ClipWait, 1 ; wait 1 second for clipboard to contain something
				If (ErrorLevel || !Clipboard) ; if nothing appeared on clipboard
					Throw, Exception("Nothing appeared on clipboard for paste",-1,"AlwaysSilent")
				Send ^v ; Ctrl+V - paste
				Sleep, 1000 ; slight pause for pasting to finish
			}
			
			; restore contents of the clipboard
			Clipboard = ; empty the clipboard
			Clipboard = %fnClipStorageVar% ; restore clipboard contents
			ClipWait, 1 ; wait 1 second for clipboard to contain something
			If (ErrorLevel || !Clipboard) ; if nothing appeared on clipboard
				Throw, Exception("Nothing appeared on clipboard for restore",-1,"AlwaysSilent")
			fnClipStorageVar := "" ; empty clipstore variable
		}
			
		
		; reset autotrim
		AutoTrim, %AutoTrimStatus%

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		; CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,1,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
; Some text to copy
Sleep, 2000 ; pause to select text elsewhere
ReturnValue := ClipStore("Copy",SomeClipContents) ; 1
MsgBox, ClipStore`n`nReturnValue: %ReturnValue%`n`nSomeClipContents: %SomeClipContents%
If ReturnValue
{
	Send {End}{Ctrl down}{Shift down}{Left}{Shift up}{Ctrl up}
	ClipStore("Copy",EndWord) ; 2 nested copy
	Send {Enter}Prefix with:
	ClipStore("Paste",EndWord) ; 2
	SomeClipContents .= ". Some added text." ; some arbitrary change
	ReturnValue := ClipStore("Paste",SomeClipContents) ; 1
	MsgBox, ClipStore`n`nReturnValue: %ReturnValue%`n`nSomeClipContents: %SomeClipContents%
}
*/