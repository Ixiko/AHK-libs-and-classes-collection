; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=83453
; Author:
; Date:
; for:     	AHK_L

/*

	#SingleInstance Force

	strFiles := "abc.docx|abc.xlsx|def.docx|docx.txt"
	strWildcards := "*.docx|abc.*|*b*.*|*.*x*|???.*|?b?.*o*|*c.*"

	loop, parse, strWildcards, |
	{
		strWildCard := A_LoopField
		strResult .= strWildCard . "`n"
		loop, parse, strFiles, |
			strResult .= A_LoopField . " -> " . (RegExMatch(A_LoopField, Wildcards2RegEx(strWildcard)) ? "yes" : "no") . "`n"
		strResult .= "`n`n"
	}
	MsgBox, % strResult

	return

*/





;---------------------------------------------------------
Wildcards2RegEx(strDosWildcards)
;---------------------------------------------------------
{
	return "i)^\Q" . StrReplace(StrReplace(StrReplace(strDosWildcards, "\E", "\E\\E\Q"), "?", "\E.?\Q"), "*", "\E.*\Q") . "\E$"
}
;---------------------------------------------------------