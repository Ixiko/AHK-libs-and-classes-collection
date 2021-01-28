; Any-base number conversion utilities
;
; Allows radix 2 to 62
;
; Inspired from:
; - https://autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/
; - https://autohotkey.com/board/topic/39121-convert-from-base-10-to-base-n-and-back/
;

ToBase(n, b) { ; n >= 0, 1 < b <= 62
	If b not between 2 and 62
		Throw Exception("Base must be between 2 and 62, inclusive. Was " . b . " instead.")

	m := ""
	Loop {
		d := mod(n, b), n //= b
		m := (d < 10 ? d : Chr(d < 36 ? d + 55 : d + 61)) . m
	} Until n < 1

	Return m
}

FromBase(s, b) { ; convert base b number; s:=strings of 0..9,A..Z,a..z, to AHK number
	If b not between 2 and 62
		Throw Exception("Base must be between 2 and 62, inclusive. Was " . b . " instead.")
	If b <= 36
		StringUpper s, s

	d := 0, L := StrLen(s)
	Loop % L {
		c := Asc(ch := SubStr(s, A_Index, 1))
		If ch is not alnum
			Throw Exception("Invalid number character: (0x" . ToBase(c, 16) . ") """ . ch . """")
		d := d * b + (c > 57 ? (c > 90 ? c - 61 : c - 55) : c - 48)
	}

	Return d
}
