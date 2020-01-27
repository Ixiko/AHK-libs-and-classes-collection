; Simple DSV (e.g., CSV, TSV) parsing utilities.
;
; See also:
; - AutoHotkey's `Loop, Parse, _, CSV`
; - https://github.com/hi5/CSV
; - https://github.com/JnLlnd/ObjCSV
;

global CSVParser := new DSVParser(",")
global TSVParser := new DSVParser("`t")

class DSVParser {

	; Creates a new DSVParser with the specified settings.
	__New(delimiters, qualifiers:="""") {
		local ; --
		if (StrLen(delimiters) <= 0)
			throw Exception("No delimiter specified.", -1)

		this.___delimiters := delimiters
		this.___qualifiers := qualifiers

		this.___defaultDelimiter := SubStr(this.___delimiters, 1, 1)
		this.___defaultQualifier := SubStr(this.___qualifiers, 1, 1)
		return this
	}

	; -------------------------------------------------------------------------
	; Properties

	delimiters {
		get {
			return this.___delimiters
		}
		set {
			return this.___delimiters ; NOP
		}
	}

	qualifiers {
		get {
			return this.___qualifiers
		}
		set {
			return this.___qualifiers ; NOP
		}
	}

	d {
		get {
			return this.___defaultDelimiter
		}
		set {
			return this.___defaultDelimiter ; NOP
		}
	}

	q {
		get {
			return this.___defaultQualifier
		}
		set {
			return this.___defaultQualifier ; NOP
		}
	}

	; -------------------------------------------------------------------------
	; Methods

	ToArray(InString, InitCapacity:=0) {
		local ; --
		Old_BatchLines := A_BatchLines ; Backup old setting
		SetBatchLines -1 ; Improve performance, especially for very large DSV data strings

		dsvArr := []
		if (InitCapacity)
			dsvArr.SetCapacity(InitCapacity)

		nextPos := 1
		maxCols := 0

		loop {
			nextPos := this.NextRow(InString, row, nextPos, maxCols)
			cols := row.MaxIndex()
			if (cols > maxCols)
				maxCols := cols
			dsvArr.Push(row)
		} until !nextPos

		for _, row in dsvArr {
			extraCols := maxCols - row.MaxIndex()
			if (extraCols) {
				row.SetCapacity(maxCols)
				loop %extraCols%
					row.Push("") ; Append an empty cell
			}
		}

		SetBatchLines %Old_BatchLines% ; Restore old setting
		return dsvArr
	}

	FromArray(DSVArray, LineSeparator:="`r`n", BlankLastLine:=true, byref OutputString:="") {
		local ; --
		; Supported line separators. See:
		; - https://en.wikipedia.org/wiki/Newline#Representation
		; - https://docs.python.org/3/library/stdtypes.html#str.splitlines
		static matchList_ls := "`r,`n,`r`n,`n`r,`v,`f," chr(0x85) "," chr(0x1E) "," chr(0x1D) "," chr(0x1C) "," chr(0x2028) "," chr(0x2029)
		if LineSeparator not in %matchList_ls%
			throw Exception("Unsupported newline sequence.", -1)

		rows := DSVArray.MaxIndex()
		Loop % rows - 1
		{
			this.FormatRow(DSVArray[A_Index], OutputString)
			OutputString .= LineSeparator
		}
		this.FormatRow(DSVArray[rows], OutputString)
		if (BlankLastLine)
			OutputString .= LineSeparator
		return OutputString
	}

	; Given a DSV string, parses a single DSV row from it, spits out to the
	; specified "OutRow" output variable an array of DSV cell values, and then
	; returns the next position in the input string where parsing may continue.
	;
	; The return value can be 0 to signal that the string was fully consumed
	; and that there is nothing left to parse.
	;
	; TIP: To improve performance use with `SetBatchLines -1` (see `ToArray()`
	; for an example).
	;
	NextRow(InString, byref OutRow:="", StartingPos:=1, InitCapacity:=0) {
		local ; --
		OutRow := []
		if (InitCapacity) {
			OutRow.SetCapacity(InitCapacity)
		}
		loop {
			StartingPos := this.NextCell(InString, cell, done, StartingPos)
			OutRow.Push(cell)
		} until done
		return StartingPos
	}

	FetchRow(InString, byref InOutPos:=1, InitCapacity:=0) {
		local ; --
		InOutPos := this.NextRow(InString, row, InOutPos, InitCapacity)
		return row
	}

	FormatRow(RowArray, byref OutputString:="") {
		local ; --
		d := this.___defaultDelimiter
		cols := RowArray.MaxIndex()
		Loop % cols - 1
			OutputString .= this.FormatCell(RowArray[A_Index]) . d
		OutputString .= this.FormatCell(RowArray[cols])
		return OutputString
	}

	; Given a DSV string, parses a single DSV cell from it, spits it out to the
	; specified "OutCell" output variable, and then returns the next position
	; in the input string where parsing may continue.
	;
	; The return value can be 0 to signal that the string was fully consumed
	; and that there is nothing left to parse.
	;
	; The output variable "OutIsLastInRow" will be set to true if the current
	; cell being parsed was detected to be the last cell of the current row.
	;
	; TIP: To improve performance use with `SetBatchLines -1` (see `ToArray()`
	; for an example).
	;
	NextCell(InString, byref OutCell:="", byref OutIsLastInRow:=false, StartingPos:=1) {
		local ; --
		regexNeedle := this.NextCell__regex
		if (!regexNeedle) {
			; Line break characters. See:
			; - https://en.wikipedia.org/wiki/Newline#Unicode
			; - https://docs.python.org/3/library/stdtypes.html#str.splitlines
			static nl := "`r`n`v`f" chr(0x85) chr(0x1E) chr(0x1D) chr(0x1C) chr(0x2028) chr(0x2029)

			ds := RegExReplace(this.___delimiters, "[\Q\.*?+[{|()^$}]\E]", "\$0")
			qs := RegExReplace(this.___qualifiers, "[\Q\.*?+[{|()^$}]\E]", "\$0")

			this.NextCell__regex := regexNeedle := "SsD)"
				. (StrLen(this.___qualifiers) > 1 ? "(?:"
					. "(?P<Qualifier>[" qs "])"
					. "(?P<Qualified>(?:(?!\1).|\1\1)*)"
					. "\1"
				. ")?" : (qs ? "(?:"
					. "(?P<Qualifier>" qs ")"
					. "(?P<Qualified>(?:[^" qs "]|" qs qs ")*)"
					. qs
				. ")?" : ""
					. "(?P<Qualifier>)"
					. "(?P<Qualified>)"
				. ""))
				. "(?P<Delimited>[^" ds nl "]*)"
				. "(?:"
					. "(?P<Delimiter>[" ds "])"
					. "|`r`n?|`n`r?" ; -- https://en.wikipedia.org/wiki/Newline#Representation
					. "|.|$"
				. ")"
		}
		StartingPos := StartingPos+0 ? Max(StartingPos, 1) : 1
		found := RegExMatch(InString, regexNeedle, match, StartingPos)

		q := matchQualifier
		; According to the RFC, Implementors should:
		; "be conservative in what you do, be liberal in what you accept from
		; others" (RFC 793, Section 2.10) (RFC 4180, Page 4)
		OutCell := StrReplace(matchQualified, q q, q) . matchDelimited
		; The above treatment is also the same as that of Microsoft Excel.

		nextPos := found + StrLen(match)
		if (StrLen(matchDelimiter)) {
			; Found a delimiter. Therefore, there should be a next cell,
			; even if it's an empty one.
			OutIsLastInRow := false
			return nextPos
		}

		OutIsLastInRow := true
		; The last record in the file may or may not have an ending line break.
		; (RFC 4180, Section 2.2)
		return nextPos > StrLen(InString) ? 0 : nextPos
	}

	FetchCell(InString, byref OutIsLastInRow:=false, byref InOutPos:=1) {
		local ; --
		InOutPos := this.NextCell(InString, cell, OutIsLastInRow, InOutPos)
		return cell
	}

	; Formats a string to be used as a single DSV cell.
	FormatCell(InputString) {
		local ; --
		matchList := this.FormatCell__matchList
		if (!matchList) {
			static matchList_presets := ",,,"",`t,"
				; Line break characters. See:
				; - https://en.wikipedia.org/wiki/Newline#Unicode
				; - https://docs.python.org/3/library/stdtypes.html#str.splitlines
				. "`r,`n,`v,`f," chr(0x85) "," chr(0x1E) "," chr(0x1D) "," chr(0x1C) "," chr(0x2028) "," chr(0x2029)

			qds := StrReplace(this.___qualifiers this.___delimiters, ",", "")
			; ^Removes all commas, since a comma as a single match list item
			; isn't supported, unless it's the first item. Also, we're already
			; handling commas in our above presets anyway.

			this.FormatCell__matchList := matchList := matchList_presets
				. RegExReplace(qds, "s).", ",$0")
		}

		if InputString contains %matchList%
		{
			q := this.___defaultQualifier
			return q . StrReplace(InputString, q, q q) . q
		}
		return InputString
	}
}
