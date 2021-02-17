; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=82210
; Author:
; Date:
; for:     	AHK_L

/*


*/

; Function to search Scintilla Control
FnSearchSciControl() {
	sci := GV_ST_SciEdit1
	H := "ahk_id " . sci.Hwnd

	InputBox, Target, "Search for?", "Search for?"

	; Setup the indicator - #8 is the first one not potentially used by lexers - so use that
	; Ref https://github.com/LuaDist/scintilla/blob/master/include/Scintilla.h
	SendMessage, 2080, 8, 7, , % H ; SCI_INDICSETSTYLE  = 7 full box
	SendMessage, 2082, 8, 0x00ffff, , % H ; SCI_INDICSETFORE  = yellow
	SendMessage, 2523, 8, 255, , % H ; SCI_INDICSETALPHA
	SendMessage, 2558, 8, 255, , % H ; SCI_INDICSETOUTLINEALPHA
	SendMessage, 2510, 8, 1, , % H ; SCI_INDICSETUNDER - draw under text
	SendMessage, 2500, 8, 0, , % H ; SCI_SETINDICATORCURRENT = 8

	; Clear old matches
	SendMessage, 2505, 0, sci.GetLength(), , % H ; SCI_INDICATORCLEARRANGE
	If (Target = "") {
		Return
	}

	; Find New matches
	While (curPos < sci.GetLength() + 1) {
		pos := FnSciDoSearch(sci, curPos, sci.GetLength(), Target)
		If (pos > -1) { ; -1 signifies not found
			SendMessage, 2504, pos, strlen(Target), , % H ; SCI_INDICATORFILLRANGE
			curPos := pos + strlen(Target)
		} Else {
			Return
		}
	}
}

FnSciDoSearch(sci, tStart, tEnd, str, flags:=""){
	sci := GV_ST_SciEdit1
    sci.SetSearchFlags(flags), sci.SetTargetStart(tStart), sci.SetTargetEnd(tEnd)
    return pos:=sci.SearchInTarget(strlen(str), str)
}