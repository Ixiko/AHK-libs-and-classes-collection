; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=43680&sid=52a7ed68fff4cd1c36c2a3797c3becb9
; by DigiDon

/*

	Hi I hope this can benefit others ;)

	I needed to display some sentences in a GUI by splitting some text into natural lines.
	However I realised that StringSplit, Loop Parse etc. were omitting the delimiters from the result.
	In this case this was a problem.

	Couldn't find a script so here is one

*/

;~ teststring:="This is a test??? This is a test2... This is a test3[] This is a test4!!?"
;~ msgbox % "Split by punctuation `n" SplitTextByDelim(teststring)
;~ msgbox % "Split by custom delimiters `n" SplitTextByDelim(teststring,"!?.[]")
;~ ; msgbox %
;~ exitapp
;~ return

SplitTextByDelim(P_Text,Delim="!?.") {
return rtrim(regexreplace(P_Text,"[" Delim "](\s+)", "$0`n"), "`n ")
}