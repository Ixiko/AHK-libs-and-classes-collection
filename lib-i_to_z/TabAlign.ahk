; DESCRIPTION: Aligns tabs from input data into human-readable aligned columns.
; Found at: http://www.autohotkey.com/board/topic/123117-tabalign-tab-align-columnar-data/
; Which is an improvement of: http://www.autohotkey.com/board/topic/74885-tabalign-function-to-tab-align-columnar-data/
; 09/15/2015 05:55:15 PM

TabAlign(data) {
    MaxWidth:=[], cells:=[]
    for row, line in StrSplit(data, "`n", "`r")						; loop lines
	for col , text in StrSplit(line?line:"`t", "`t")				; loop tabs per line or once if empty line
	    cells[row, col] := text							; save each text field
	    , MaxWidth[col] := StrLen(text)>MaxWidth[col]?StrLen(text):MaxWidth[col]	; save max width per column

    for row, line in cells								; loop rows
    {
	for col, text in line								; loop columns
	    NextTabStop := ((MaxWidth[col] + 8) // 8) * 8				; find nearest tab stop from this column's max width
	    , Tabs := Ceil((NextTabStop - StrLen(text)) / 8)				; find out amount of tabs needed to get there
	    , NewLine .= text . tabs(tabs)						; pad text with needed amount of tabs
	    res .= RTrim(NewLine, "`t") . "`r`n", 	NewLine := ""			; append to result
    }
    return RTrim(res, "`r`n")
}

tabs(n) {
    loop, % n
	    res .= "`t"
    return res
}