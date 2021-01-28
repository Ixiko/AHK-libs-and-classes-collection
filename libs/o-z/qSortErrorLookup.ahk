; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=23&t=61602&p=297807#p297807
; Author:
; Date:
; for:     	AHK_L

/*

	x := StrReplace(Format("{:20100100}", ""), " ", "a")
	y := x . "A"
	x .= "B"
	SetBatchLines, -1
	qSortErrorLookup(x, y)
	qSortErrorLookup(x, y)
	qSortErrorLookup(x, y)
	;a few dry runs
	start := A_TickCount
	difference := qSortErrorLookup(x, y)
	total := A_TickCount - start
	Msgbox % Clipboard := "Found difference at character position: " . difference . "`ntook " . total . " ms"

	;Found difference at character position: 20100101
	;took 156 ms
	;Found difference at character position: 20100101
	;took 141 ms
	;Found difference at character position: 20100101
	;took 172 ms

*/


qSortErrorLookup(byref string1, byref string2, partCount := 2) {
	Local
	if (string1 = string2) {
		return false
	}

	cLeftBorder := 1
	cLen := max(strLen(string1), strLen(string2))
	loop {
		stepSize := (cLen)/partCount
		leftBorder := cLeftBorder
		loop %partCount% {
			leftB := round(leftBorder)
			len := Round((leftBorder+=stepSize)-leftB)
			if (subStr(string1, leftB, len) != subStr(string2, leftB, len)) {
				if (len = 1)
					return leftB
				cLeftBorder := leftB
				cLen := len
				break
			}
		}
	}
	return false
}