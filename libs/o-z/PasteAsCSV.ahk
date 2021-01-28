PasteAsCSV(fnInputText,fnInclLetters,fnExtraSpace,fnIncludeNewLine,fnIncludeQuotes,fnNoSeperator)
{
	; turns text string into a formatted comma separated list
	; MsgBox fnInputText: %fnInputText%
	; MsgBox % fnInclLetters fnExtraSpace fnIncludeNewLine fnIncludeQuotes fnNoSeperator


	; declare local, global, static variables
	Global SendNotPasteWindowList


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If !fnInputText
			Throw, Exception("fnInputText was empty")


		; initialise variables
		LastCharWasReqd := "" ; flag to show character was required
		CSVString := ""
		Separator := ""
		Quote := ""


		; determine separator string
		If !fnNoSeperator
			Separator := ","
		If fnIncludeQuotes
			Quote := "'"
		If fnIncludeNewLine
			Separator := "`n" . Separator
		If fnExtraSpace
			Separator .= " "

		; StringReplace, fnInputText, fnInputText, COUNT(, CountOf, All
		; StringReplace, fnInputText, fnInputText, DISTINCT, Distinct, All


		; generate the CSV string
		Loop, Parse, fnInputText
		{				
			If A_LoopField in % fnInclLetters ? "0,1,2,3,4,5,6,7,8,9,-,/,\,_,@,:,.,[,],a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z," Chr(0x03BC) ; 'full' character set ; 0x03BC = small mu
											  : "0,1,2,3,4,5,6,7,8,9" ; digits only character set
			{
				If (StrLen(CSVString) = 0)                             ; if first character is being added to result string
					CSVString := Quote                                 ; add a quote value first
				Else If !LastCharWasReqd                               ; else if (non-zero length string and) last character was not required i.e. new 'word'
					CSVString := CSVString . Quote . Separator . Quote ; add quote-separator-quote to end of result string
				CSVString := CSVString . A_LoopField                   ; add character to end of result string
				LastCharWasReqd = 1                                    ; set flag to show character was required
			}
			Else                                                       ; else if this character is not in list
				LastCharWasReqd = 0                                    ; turn off flag
		}
		CSVString := CSVString . Quote ; terminate with quote value
		; If fnExtraSpace
			; CSVString = %CSVString%%Separator% ; add a trailing separator
		
		
		; hacks for sending to certain application windows e.g.SSMS Object Explorer
		SendNotPaste := 0
		Loop, Parse, SendNotPasteWindowList, CSV
		{
			StringSplit, ListLine, A_LoopField, \, %A_Space%%A_Tab%
			WinTitle := ListLine1
			WinText  := ListLine2
			TitleMatchModeOrig := A_TitleMatchMode
			SetTitleMatchMode, 2 ;2: A window's title can contain WinTitle anywhere inside it to be a match
			IfWinActive, %WinTitle%, %WinText%
				SendNotPaste := 1
			SetTitleMatchMode, %TitleMatchModeOrig%
		}
		If SendNotPaste
		{
			StringReplace, CSVString, CSVString, [,, All
			StringReplace, CSVString, CSVString, ],, All
			;~ If (fnInclLetters && !fnExtraSpace && !fnIncludeNewLine && !fnIncludeQuotes && fnNoSeperator) ; Ctrl+Shift+BSlash
				;~ If WinTitle not contains CabinetWClass,explorer.exe
					;~ CSVString := (SubStr(CSVString,1,4) = "dbo." ? "" : "dbo.") . CSVString
		}
		
		
		; send or paste the new CSV string
		If SendNotPaste
			Send %CSVString%
		Else
		{
			ClipStore("Store",ClipOriginal)
			ClipStore("Paste",CSVString,ClipOriginal)
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Sleep, 5000 ;testing
	ToolTip ;testing
	Return ReturnValue
}


/* ; testing
ThisString = %Clipboard%
ShiftKey := 1, AltKey := 1, WinKey := 0, Quote := 0, BSlash := 0
ReturnValue := PasteAsCSV(ThisString,ShiftKey,AltKey,WinKey,Quote,BSlash)
; MsgBox, PasteAsCSV`n`nReturnValue: %ReturnValue%
*/