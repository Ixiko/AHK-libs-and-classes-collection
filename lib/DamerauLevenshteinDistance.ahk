/*
	Function: DamerauLevenshteinDistance
		Performs fuzzy string searching, see <http://en.wikipedia.org/wiki/Damerau-Levenshtein_distance>

	License:
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
DamerauLevenshteinDistance(s, t) {
	StringLen, m, s
	StringLen, n, t
	If m = 0
		Return, n
	If n = 0
		Return, m
	d0_0 = 0
	Loop, % 1 + m
		d0_%A_Index% = %A_Index%
	Loop, % 1 + n
		d%A_Index%_0 = %A_Index%
	ix = 0
	iy = -1
	Loop, Parse, s
	{
		sc = %A_LoopField%
		i = %A_Index%
		jx = 0
		jy = -1
		Loop, Parse, t
		{
			a := d%ix%_%jx% + 1, b := d%i%_%jx% + 1, c := (A_LoopField != sc) + d%ix%_%jx%
				, d%i%_%A_Index% := d := a < b ? a < c ? a : c : b < c ? b : c
			If (i > 1 and A_Index > 1 and sc == tx and sx == A_LoopField)
				d%i%_%A_Index% := d < c += d%iy%_%ix% ? d : c
			jx++
			jy++
			tx = %A_LoopField%
		}
		ix++
		iy++
		sx = %A_LoopField%
	}
	Return, d%m%_%n%
}
