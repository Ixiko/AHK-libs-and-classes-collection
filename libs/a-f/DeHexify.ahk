; Title:   	DeHexify
; Link:     	autohotkey.com/boards/viewtopic.php?f=76&t=87383&sid=d5a1dd8d6825fc76b3189e6a83755907
; Author:
; Date:
; for:     	AHK_L

/*


*/

DeHexify(x){
	;//LOG
	DebugLog .= "Line: " A_LineNumber ", DeHexify(" x ")`n"

	Loop % (StrLen(x))/2 	{
		StringLeft hex, x, 2
		Transform y, Chr, % "0x"hex
		string .= y
		StringTrimLeft x, x, 2
	}
	Return RegexReplace( string, "^\s+|\s+$" )
}