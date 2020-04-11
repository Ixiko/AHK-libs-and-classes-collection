FormatNumberCommas(fnInputNumber)
{
	; takes a decimal value and formats it with thousands separators
	; MsgBox fnInputNumber: %fnInputNumber%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ParsedNumber := ""


		; validate parameters
		If !fnInputNumber
			Throw, Exception("fnInputNumber was empty")


		; initialise variables
		IntegerPart := ""
		FractionPart := ""
		GettingNumber := 0
		FoundDecimalPoint := 0
		DigitsCharacterSet := "0,1,2,3,4,5,6,7,8,9,-,."
		DigitsCharacterSetExtended := ",,,.,0,1,2,3,4,5,6,7,8,9" ; first two consecutive commas results in a single literal comma


		; look at each character
		Loop, Parse, fnInputNumber 
		{
			If A_LoopField in % GettingNumber ? DigitsCharacterSetExtended : DigitsCharacterSet
			{
				GettingNumber := 1
				If (A_LoopField = ".")
				{
					FoundDecimalPoint := 1
					Continue
				}
				IntegerPart  .= FoundDecimalPoint ? "" : A_LoopField
				FractionPart .= FoundDecimalPoint ? A_LoopField : ""
			}
			Else
			{
				If GettingNumber ; first non-number character found after a number has been found
					Break ; stop looking
				Continue ; next character
			}
		}

		CountOfReplacements := 1 ; just to force entry into while loop
		While CountOfReplacements > 0
		{
			PCRE := "S)(.*)([\d])([\d][\d][\d])([.,]?.*$)"
			IntegerPart := RegExReplace(IntegerPart,PCRE,"$1$2,$3$4",CountOfReplacements)
		}
		
		ParsedNumber := IntegerPart (FoundDecimalPoint ? "." : "") FractionPart


	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ParsedNumber
}


/* ; testing
params := "hello -123456789.056 there 789,65"
ReturnValue := FormatNumberCommas(params)
MsgBox, FormatNumberCommas`n`nReturnValue: %ReturnValue%
*/