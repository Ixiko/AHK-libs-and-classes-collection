;MsgBox % boxit("EVERYWHERE IS WITHIN WALKING DISTANCE IF YOU HAVE THE TIME")
;MsgBox % boxit("IT IS RAINING CATS AND DOGS OUT THERE")

boxit(z) {
	StringReplace, z, z, %A_SPACE%, , All ;remove spaces
	r := box(z), i := 1, d := "1, 1", x := []
	loop % r {
		count++
			if !mod(count, 2) {
                    y := SubStr(z, i,r)
                        x.Insert(Count, "`n" . Flip(y))
                }
                else {
                    x.Insert(Count, "`n" . SubStr(z, i,r))
                }
            i += r
        }
		for index, value in x
			For each, Char in StrSplit(value,, "`r")
				d .= Char . " "
	return d
}

box(size) {
    return Round(Sqrt(StrLen(size)))
}

Flip(in) {
    VarSetCapacity(out, n:=StrLen(in))
    Loop %n%
        out .= SubStr(in, n--, 1)
    return out
}