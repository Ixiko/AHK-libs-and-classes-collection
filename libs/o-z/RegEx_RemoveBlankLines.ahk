; Remove Blank Lines via RegEx.ahk
; https://github.com/m33mt33n/AutoHotkey/blob/master/Remove Blank Lines via RegEx.ahk

/* Example
	NewStr =
	(
	one
	two

	three
	four
	two

	three
	four



	three
	four
	four
	)

	MsgBox % RemoveBlankLines(NewStr)
*/

RemoveBlankLines(string) {
return  RegExReplace(string, "mi`n)^[ \t]*$\r?\n")
}

