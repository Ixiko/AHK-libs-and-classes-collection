; Function to get current "word" at caret position from scintilla control
Scintilla_get_CurrentWord() {
	sci := GV_ST_SciEdit1
	StartingPos := sci.GetCurrentPos() ; store current position
	; Select current 'word'
	sci.SetSelectionStart(sci.WordStartPosition(StartingPos, 1))
	sci.SetSelectionEnd(sci.WordEndPosition(StartingPos, 1))
	; UTF-8 jiggery-pokery begins...
	SelLength := Sci.GetSelText() - 1
	VarSetCapacity(SelText, SelLength, 0)
	Sci.GetSelText(0, &SelText)
	thisWord := StrGet(&SelText, SelLength, "UTF-8")
	; UTF-8 jiggery-pokery ends...
	Sci.SetSelectionStart(StartingPos) ; clear selection start
	Sci.SetSelectionEnd(StartingPos) ; clear selection end
	Return thisWord
}