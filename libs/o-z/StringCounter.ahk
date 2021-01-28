
/*
	;"RegExMatch" can't count Characters\String
	;"RegExReplace" can! ("StringReplace" too, but I think "StringCaseSense" option is not reliable as "RegEx" is)


x := "AB AB AB - BA BA BA \Q \q \Q - \E \e \E *** \\\ ... ???"

msgbox, % "Found " StringCounter(x, "a", "-casesense") " occurrences!"
*/

StringCounter(Text, String, Options := "") { 	;______________ StringCounter - v1.0 (Function) __________________

;if "Options" contains "RegEx" string, RegEx special characters will be activated! (Inicial RegEx options can be specified like this, "RegEx(im)", "i" for Case-Sense Off, "m" for multi line options, etc, etc - https://autohotkey.com/docs/misc/RegEx-QuickRef.htm#Options)
;if "Options" contains "-CaseSense" string, turns on RegEx case-insensitive option (Case-Sense Off)

	if !RegExMatch(Options, "i)RegEx")	;"!", if "Options" does not contain "RegEx" String
	{				;"i)", turns on RegEx case-insensitive option (Case-Sense Off)

	QOption := "\Q"	;"\Q", treats any RegEx special characters at its right as literal characters (except "\E" special string)

	String := RegExReplace(String, "\\E", "\E\\E\Q")	;Replace any "\E" with "\E\\E\Q" (first \ treats second \ as literal character)
	}
	else
	{
	RegExMatch(Options, "is)RegEx\((.*?)\)", Matched)	;All the match is stored in "Matched" variable, match in the first ( ) is stored in "Matched1" variable, match in the second ( ) is stored in "Matched2" variable, and so on ...!
						;"(.*?)" match is stored in "Matched1" variable | ".*" match 0 or more characters | "\" treats "(" and ")" as literal characters
						;"i)", turns on RegEx case-insensitive option (Case-Sense Off) | "s)" option allows "." to match "`r`n" newlines too

	IOptions .= Matched1 " "	;add "Matched1" value in "IOptions" Variable (to be used below in RegEx Inicial Options) | (" ") represents a "space" character
	}

if RegExMatch(Options, "i)-CaseSense")	;if "Options" contains "-CaseSense" String | "i)", turns on RegEx case-insensitive option (Case-Sense Off)
IOptions .= "i "			;Add "i " string in "IOptions" variable

RegExReplace(Text, IOptions "s)" QOption String, , Count)	;any "String" will be removed\deleted\replaced with "blank" string
						; The Total "String" removed\deleted\replaced will be stored in "Count" variable
						;"IOptions", may contain RegEx Inicial Options, such as, "i" for Case-insensitive on (CaseSense Off), "m" for multilines options, etc, etc (https://autohotkey.com/docs/misc/RegEx-QuickRef.htm#Options)
						;"s)" option allows "." to match "`r`n" newlines too

return, Count
}






