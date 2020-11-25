; Link:   	https://gist.github.com/tmplinshi/cee1bc644e3fc4e2a4465470d2cd9c4d
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=67479
; Author:	 tmplinshi
; Date:   	2019-08-28
; for:     	AHK_L
; Syntax:	RegExReplaceF(Haystack, NeedleRegEx, FunctionName [, OutputVarCount := "", Limit := -1, StartingPosition := 1])

/* example 1

	;find all feedrates and "override" them, test case 140% feed
	;avoid modifying comments, stuff within ()s
	;don't change the feedrate for tapping cycles, those with G84 and G74
	;maintain the same number of decimal places as the original feedrate
	;maintain the decimal point or not for integers

	String =
	(
	G1G90X1.F10.M8(WAS F10.)
	F10
	F10.
	F10.0
	F10.00
	F10.000
	X2. Y3. F12.3456 (WAS F12.3456)
	G84     F10.00   (TAPPING F10.00)
	G1G90X1.F10.F2.34  (WAS F10.F2.34)
	G1G90X1.F10  (WAS F10)
	X1.F10F10.F10.0F10.00
	F10.
	(COMMENT)
	(FEED)
	(F10.0)
	)

	MsgBox, % RegExReplaceF(string, "O)([^\r\n]*?)F([\-\d.]+(?![^\(]*\)))", Func("Override").Bind(140))

	Override(percent, match) {
		if InStr(match.1, "G84") OR InStr(match.1, "G74")
			return match.0
		else
			return match.1 "F" Round(match.2 * percent/100, _:=DecimalPlaces(match.2)) . ((_=0) && InStr(match.2, ".") ? "." : "")
	}

	DecimalPlaces(n) {
	 if (!RegExMatch(n, "^\d*\.(\d*)$", m))
			return 0
		return StrLen(m1)
	}

*/

/* more examples

; Examples
	str := "a 100 b 200"
	MsgBox % RegExReplaceF(str, "\d+"    , "Add8")               ; -> "a 108 b 208"
	MsgBox % RegExReplaceF(str, "O)(\d+)", "Add5")               ; -> "a 105 b 205"
	MsgBox % RegExReplaceF(str, "O)(\d+)", Func("AddN").Bind(3)) ; -> "a 103 b 203"
	Add8(match) {
		return match + 8
	}
	Add5(match) {
		return match.1 + 5
	}
	AddN(num, match) {
		return match.1 + num
	}
*/

RegExReplaceF(ByRef Haystack, NeedleRegEx, FunctionName, ByRef OutputVarCount := "", Limit := -1, StartingPosition := 1) {

	local out

	VarSetCapacity(out, VarSetCapacity(Haystack))
	OutputVarCount := 0

	while ( pos := RegExMatch(Haystack, NeedleRegEx, match, StartingPosition) ) 	{
		out .= SubStr(Haystack, StartingPosition, pos-StartingPosition)
		out .= %FunctionName%(match)
		len := IsObject(match) ? match.Len : StrLen(match)
		StartingPosition := pos + len
		if (++OutputVarCount = Limit)
			break
	}

return out . SubStr(Haystack, StartingPosition)
}