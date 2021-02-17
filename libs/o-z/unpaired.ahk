Unpaired =
(
A
B
C
D
)

Paired := UniquePairs(Unpaired)
MsgBox % Paired
return

UniquePairs(list) {
	loop {
		pairs := ""
		first := StrSplit(list, "`n", "`r")
		second := first.Clone()
		loop, % first.Count() {
			i := A_Index
			if (second.Count() = 1) && (first[i] = second[1])
				continue 2
			loop {
				Random, r, 1, second.Count()
			} until first[i] != second[r]
			pairs .= first[i] . "|" . second.RemoveAt(r) . "`n"
		} until !second.Count()
		break
	}
	return RTrim(pairs, "`n")
}