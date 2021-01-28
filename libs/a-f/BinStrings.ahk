; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62392
; Author:
; Date:
; for:     	AHK_L

/*

	;BinStrings( ) - Extract Strings From Binary.ahk
	#SingleInstance, Force
	#NoTrayIcon
	#KeyHistory, 0
	#MaxThreadsPerHotkey, 1
	#MaxMem 1000
	ListLines, Off
	SetBatchLines, -1
	SetWinDelay, -1
	SetMouseDelay, -1
	SetKeyDelay, -1, -1
	SetTitleMatchMode, 3
	Process, Priority,, High
	;compare results with lower filter threshold having less garbage BinStrings...
	Print(BinStrings(comspec,4))
	Print(BinStrings(comspec,4,50))
	Print(BinStrings(comspec,4,25))
	Print(BinStrings(comspec,4,20))

*/


;charRepetitionFilter is expressed in percent(1-100), it ommits BinStrings with any character that constitutes defined percent of string...
;^the Higher This Value, the higher the requirement to filter out a string & so more garbage BinStrings included in output... LOWER IS BETTER!
BinStrings(file, minLength:=3,charRepetitionFilter:=""){	;if charRepetitionFilter is ommitted,filter is simply not used...
	;Bin2Hex	-	h
	FileRead b, %file%
	f := A_FormatInteger, s:=0
	SetFormat Integer, H
	VarSetCapacity(h, 5*(VarSetCapacity(b) * !s + s))
	Loop % VarSetCapacity(b) * !s + s
		h := h . *(&b+A_Index-1)+256
	StringReplace h, h, 0x1,,All
	SetFormat Integer, %f%

	;Hex2Ascii	-	n
	startpos:=1
	Loop % StrLen(h)/2
		n .= Chr( "0x" . SubStr(h, StartPos+2 , 2) . SubStr(h, StartPos , 2) ), startpos +=4

	Loop Parse, n	;Filter characters to alphanum & punctuations
		nF .= Asc(A_LoopField) >= 32 && Asc(A_LoopField) <= 126 ? A_LoopField : Asc(A_LoopField) = 12 || Asc(A_LoopField) = 9 || Asc(A_LoopField) <= 26 || Asc(A_LoopField) >= 127 ? (SubStr(A_LoopField,StrLen(A_LoopField),StrLen(A_LoopField))<>" "?" ":"") : ""

	Loop Parse, nF, % A_Space	;Build String List
		oF .= !charRepetitionFilter &&  StrLen(A_LoopField) >= minLength  || charRepetitionFilter && StrLen(A_LoopField) >= minLength && !StringContainsRepeatingChar(A_LoopField,charRepetitionFilter) ? ( oF ?  "`r`n" A_LoopField : A_LoopField) : ""

	Return oF
}

StringContainsRepeatingChar(ByRef str,repetitionThresholdInPercent:=80){	;Returns true if any char in str constitutes N percent of str(i.e the threshold)
	Loop Parse, str
		If ( (freq := 100*StringCharCount(str, A_LoopField)//StrLen(str)) >= repetitionThresholdInPercent)
			Return A_LoopField ":" freq
}

StringCharCount(ByRef str, char){	;Returns the number of ooccurrences of a character in a string
	StringReplace, str, str, %char%, %char%, UseErrorLevel
	Return ErrorLevel
}

Print(string){
	ListVars
	WinWait ahk_id %A_ScriptHwnd%
	ControlSetText Edit1, %string%
	WinWaitClose
}