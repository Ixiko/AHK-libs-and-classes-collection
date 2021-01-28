;InputBox, word, Enter a Word, Enter a series of letters to see all the arrangements of those letters.
;msgbox % Permutate(word)

Permutate(set,delimeter="",trim="", presc="") { ; function by [VxE], returns a newline-seperated list of
 ; all unique permutations of the input set.
 ; Note that the length of the list will be (N!)
	d := SubStr(delimeter,1,1)
	StringSplit, m, set, %d%, %trim%
	IfEqual, m0, 1, return m1 d presc
	Loop %m0%
	{
		remains := m1
		Loop % m0-2
			x := A_Index + 1, remains .= d m%x%
		list .= Permutate(remains, d, trim, m%m0% d presc)"`n"
		mx := m1
		Loop % m0-1
			x := A_Index + 1, m%A_Index% := m%x%
		m%m0% := mx
	}
	return substr(list, 1, -1)
}