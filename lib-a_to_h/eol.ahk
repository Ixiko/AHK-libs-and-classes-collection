/* Function: eol
 *     Convert newline in strings to/from "`r`n", "`n", "`r"
 * Requirements:
 *     AutoHotkey v1.1+ OR v2.0-a+
 * License:
 *     WTFPL [http://wtfpl.net]
 * Syntax:
 *     out := eol( str [ , eol := "`n" ] )
 * Parameters:
 *     out   [retval] - output string
 *     str       [in] - input string
 *     eol  [in, opt] - the newline to convert to. Valid values are: '`r`n',
 *                      '`n', '`r', 'CRLF', 'LF', 'CR', 'DOS', 'Unix' and 'Mac'.
 */
eol(str, eol:="`n")
{
	if (str == "") ; do nothing if empty OR return eol??
		return
	
	static CRLF := "`r`n", LF := "`n", CR := "`r", DOS:=CRLF, Unix:=LF, Mac:=CR
	if (InStr(" `r`n", eol) <= 1) ; make sure blank("") strings are detected
		if !(eol ~= "i)^CR(LF)?|LF|dos|unix|mac$" ? eol := %eol% : 0)
			throw Exception("Invalid 'eol' parameter", -1, eol)

	if (eol == "`r`n") ; to CRLF (CRLF to LF -> CR to LF -> LF to CRLF)
		eols := Array(["`r`n", "`n"], ["`r", "`n"], ["`n", "`r`n"])
	
	else if (eol == "`n") ; to LF (CRLF to LF -> CR to LF)
		eols := Array(["`r`n", "`n"], ["`r", "`n"])

	else if (eol == "`r") ; to CR (CRLF to CR -> LF to CR)
		eols := Array(["`r`n", "`r"], ["`n", "`r"])

	for each, nl in eols
	{
		; v1.1+ and v2.0-a StringReplace/StrReplace workaround
		; alternative: str := RegExReplace(str, nl[1], nl[2])
		; If dual-compatibilty is not required, comment this out and uncomment
		; either of the one below for your respective AHK version
		p := A_Index>2 ? -1 : 0
		while p := InStr(str, nl[1],, p + StrLen(nl[2]))
			str := SubStr(str, 1, p-1) . nl[2] . SubStr(str, p + StrLen(nl[1]))
		
		; v1.1+
		; StringReplace, str, str, % nl[1], % nl[2], All

		; v2.0-a
		; str := StrReplace(str, nl[1], nl[2])
	}

	/* Add blank line at end(for LF and CR)??
	if (eol != "`r`n") && StrLen(str)
		if (SubStr(str, A_AhkVersion<"2" ? 0 : -1) != eol)
			str .= eol
	*/
	
	return str
}