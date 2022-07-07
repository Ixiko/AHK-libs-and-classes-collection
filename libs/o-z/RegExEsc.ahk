; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=59466
; Author:
; Date:
; for:     	AHK_L

/*
String := "\.*?+[{|()^$  \E"

msgbox, % ""
. "Test: "   RegExReplace(String, "\.*?+[{|()^$  \E", "@")                                 "`r`n"
. "`r`n"
. "Test: "   RegExReplace(String, RegExEsc("\.*?+[{|()^$  \E"), "@")                       "`r`n"
. "`r`n"
. "Test: "   RegExReplace(String, RegExEsc("\.*?+[{|()^$  \E"), "$1$2$3")                  "`r`n"
. "`r`n"
. "Test: "   RegExReplace(String, RegExEsc("\.*?+[{|()^$  \E"), RegExEsc("$1$2$3", "$") )  "`r`n"

String := ".. \E - Lalalallal  - .. \E - Lululululuulululu - .. \E"

	;from string above, I want to replace only ".. \E" at the start of the string with "@"
	;"\.*?+[{|()^$  \E" are regex special characters\string
	;you have to escape each one with "\" or by using "\Q"

	;I want to replace only ".. \E" at the start of the string with "$1$2$3"
	;"$" is a special character for "RegExReplace()" third parameter
	;you have to escape each one with another "$"

	;So, you can use "RegExEsc()" to escape regex special characters\string for you automatically

Match := ".. \E"

Rep := "$1$2$3"

msgbox, % ""
. RegExReplace(String, "^\Q" Match, "@")                           "   (Does not work)"    "`r`n"
. "`r`n"
. RegExReplace(String, "^" RegExEsc(Match), "@")                   "   (works)"            "`r`n"
. "`r`n"
. RegExReplace(String, "^" RegExEsc(Match), Rep)                   "   (Does not work)"    "`r`n"
. "`r`n"
. RegExReplace(String, "^" RegExEsc(Match), RegExEsc(Rep, "$") )   "   (works)"            "`r`n"

*/

RegExEsc(String, Options := "")	{	;_________ RegExEsc(Function) - v1.0 __________

	if (Options == "$")
		return, RegExReplace(String, "\$", "$$$$")	;to be used with "RegExReplace" third parameter! ("$$" represents one literal "$")

return, "\E\Q" RegExReplace(String, "\\E", "\E\\E\Q") "\E"	;to be used with "RegExMatch" and "RegExReplace" second parameters! ("\\" represents one literal "\")
}