RemoveDuplicate(str, delim:=",", cs:=false) {
	_ := cs ? ComObjCreate("Scripting.Dictionary") : []
	Loop, Parse, str, % delim
		alf := A_LoopField
		, out .= cs ? (_.Exists(alf) ? "" : (alf . delim, _.Add(alf, 1)))
		            : (_[alf] ? "" : (alf . delim, _[alf] := 1))
	return RTrim(out, delim)
}