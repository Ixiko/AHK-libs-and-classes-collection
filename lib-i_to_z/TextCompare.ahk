
/*
	;"\.*?+[{|()^$", RegEx special characters

x := "ABCD`r`n\.*?+[{|()^$EFH"
y := "ABCD`r`n\.*?+[{|()^$EFh"

gui, add, edit, w600 h400 +HScroll +HwndControlId,
ControlSetText, , % TextCompare(x, y), % "ahk_id" ControlId

	;"+HwndControlId", stores the control Hwnd id number in "ControlId" variable
	;unlike "gui" commands,  "ControlSetText" does not translate any "`n" to "`r`n" (EOL off - End of line translation)
	;"ahk_id", search controls by their hwnd id number

gui, show

return

guiclose:	;_________ Gui Close __________
exitapp
*/

TextCompare(Text1, Text2, Options = "") {	;_____________ Text Compare v1.0 (Function) _______________

;if "Text1" is equal to "Text2", the function returns "Matched"
;if "Text1" is different than "Text2", and if "Options" parameter does not contain "GetPos" and "GetMatch" strings, the function returns multiple informations
;if "Text1" is different than "Text2", and if "Options" parameter contains "GetPos" string, the function returns the position where the "Un-Match" occurred
;if "Text1" is different than "Text2", and if "Options" parameter contains "GetMatch" string, the function returns the matched string before the "Un-Match" occurrence
;if "Options" parameter contains "-CaseSense" string, turns on RegEx case-insensitive option (Case-Sense Off)

	loop
	{
	RegExMatch(Text1, "s).", Char1, A_index)	;"s)" option allows "." to match "`r`n" newlines too
	RegExMatch(Text2, "s).", Char2, A_index)	;".", match any character \ Store the matched characters in "Char1" and "Char2" variables
					;"A_index", is the Start Position (1 match first charater, 2 match second character, and so on ...!)

	if RegExMatch(Char1, "^$") and RegExMatch(Char2, "^$")	;if "Char1" and "Char2" are blank (means that no more character found from "text1" and "text2")
	return, "Matched"					;"^" start by blank character / "$" end by blank character

	if RegExMatch(Options, "i)-CaseSense")	;if "Options" contains "-CaseSense" String | "i)", turns on RegEx case-insensitive option (Case-Sense Off)
	IOptions .= "i "			;Add "i " string in "IOptions" variable

		if !RegExMatch(Char1, IOptions ")^\Q" Char2 "\E$")	;"!", if "Char1" is different than "Char2" | "^" start by "Char2" character | "$" end by "Char2" character
		{					;"\Q", treats any RegEx special characters at its right as literal characters (except "\E" special string)
							;"\E", treats any RegEx special characters at its right as special characters (not as literal characters)
							;")" necessary for "IOptions" | "IOptions", may contain RegEx Inicial Options, such as, "i" for Case-insensitive on (CaseSense Off), "m" for multilines options, etc, etc (https://autohotkey.com/docs/misc/RegEx-QuickRef.htm#Options)

		if RegExMatch(Options, "i)GetPos")	;if "Options" contains "GetPos" String | "i)", turns on RegEx case-insensitive option (Case-Sense Off)
		return, A_index			;"A_index", the position where the "Un-Match" occurred

		if RegExMatch(Options, "i)GetMatch")	;if "Options" contains "GetMatch" String | "i)", turns on RegEx case-insensitive option (Case-Sense Off)
		return, MatchedText			;"MatchedText" contains all the matched strings before the "Un-Match" occurrence

		return, ""
			. "Un-Match Found at String Position " a_index "`r`n"
			. "----------------------------------------------------------------------------------------------------------------------`r`n"
			. """Text1"" character at position " a_index " = " Char1 " (Unicode character " Ord(Char1) ")`r`n`r`n"
			. """Text2"" character at position " a_index " = " Char2 " (Unicode character " Ord(Char2) ")`r`n"
			. "----------------------------------------------------------------------------------------------------------------------`r`n"
			. "No Character = 0 / Carriage Return = 13 / Line Feed = 10 / Tab = 9 / Space = 32`r`n`r`n"
			. "List of Unicode characters: https://en.wikipedia.org/wiki/List_of_Unicode_characters `r`n"
			. "----------------------------------------------------------------------------------------------------------------------`r`n"
			. "Matched String Found before the ""Un-Match"" occurrence:`r`n`r`n" MatchedText

				;"Ord( )", returns the ordinal value (numeric character code) of the specified character.
		}

	MatchedText .= Char1		;since "Char1" = "Char2", "Char1" will be added\appended to "MatchedText" variable
	}
}











