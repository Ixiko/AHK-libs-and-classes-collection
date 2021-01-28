/*
	Function: grep
		Sets the output variable to all the entire or specified subpattern matches and returns their offsets within the haystack.

	Parameters:
		h - haystack
		n - regex
		v - output variable (ByRef)
		s - (optional) starting position (default: 1)
		e - (optional) subpattern to save in the output variable, where 0 is the entire match (default: 0)
		d - (optional) delimiter - the character that seperates multiple values (default: EOT (0x04))

	Returns:
		The position (or offset) of each entire match.

	Remarks:
		Since multiple values are seperated with the delimiter any found within the haystack will be removed.

	License:
		- Version 2.0 <http://www.autohotkey.net/~Titan/#grep>
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
grep(h, n, ByRef v, s = 1, e = 0, d = "") {
	v =
	StringReplace, h, h, %d%, , All
	Loop
		If s := RegExMatch(h, n, c, s)
			p .= d . s, s += StrLen(c), v .= d . (e ? c%e% : c)
		Else Return, SubStr(p, 2), v := SubStr(v, 2)
}
