; My Text Analysis Tool (MyTextAnalysisTool.ahk)
;  Contains tools to analyze text information rather than process it into something.

; #Warn  ; Enable warnings to assist with detecting common errors.
;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Class MyTextAnalysisTool {

	CountCharacters(vText) {
		; Counts the complete amount of characters
	}

	CountNonWhitespaceCharacters(vText) {
		; Counts and returns the numbers of characters present in a given text.
		; Does not include spaces or tabs.

		vLength := StrLen(vText)

		vLines := 0
		vSpaces := 0
		vTabs := 0

		Loop, Parse, vText, `n, `r
		{
			vLines += 1
			vLine := A_LoopField
			vLength += StrLen(vLine)

			Loop, Parse, vLine
			{
				if ( A_loopField == A_Space )
					vSpaces += 1

				if ( A_loopField == A_Tab )
					vTabs += 1
			}
		}

		return vLength - vSpaces - vTab
	}

	CountSpaces(vText) {
		; Counts and returns the total amount of whitespace count

		vSpaces := 0

		Loop, Parse, vText
			If A_loopField=%A_Space%
				vSpaces += 1

		return vSpaces
	}

	CountTabs(vText) {
		; Counts and returns the total amount of tabs counted

		vTabs := 0

		Loop, Parse, vText
			if ( A_loopField == A_Tab )
				vTabs += 1

		return vTabs
	}

	CountLines(vText) {
		; Counts and returns the total number of lines counted

		if ( StrLen(vText) == 0 )
			return 0

		vLines := 0
		Loop, Parse, vText, `n, `r
			vLines += 1

		return vLines
	}
}

; TESTING

;myTAT := New MyTextAnalysisTool
;MsgBox % myTAT.CountSpaces("One Two Three Four`nFive Six`n Seven Eight Nine")

;MsgBox % "Preceeding tab: " myTAT.CountTabs("	Tab1	Tab2	Tab3")

;MsgBox % myTAT.CountLines("Line1`r`nLine2`r`nLine3")