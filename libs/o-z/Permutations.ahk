gString := "jabicdhefg 123 defgbachj 456 ghilcbamnop 789 something 111" 
gWord := "abcdefghi"

For x,y in strsplit(gString," ")
	for a,b in Permutations(gWord)
		if instr(y,b)
			lst .= y "`n"
msgbox % lst

Permutations(Word) { 												; return an unsorted array with all permutations of Word by Wolf_II
	static memo := []
    if memo.hasKey(Word)
        return memo[Word]
    if (Len := StrLen(Word)) = 1
        return (memo[Word] := [Word])
    Result := []
    Loop, %Len% 
		{
        Split1 := SubStr(Word, 1, A_Index - 1)      				; before pos
        Split2 := SubStr(Word, A_Index, 1)          				; at pos
        Split3 := SubStr(Word, A_Index + 1)         				; after pos
        for each, Perm in Permutations(Split1 Split3)
            Result.Push(Split2 Perm)
		}
    return (memo[Word] := Result)
}
