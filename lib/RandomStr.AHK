RandomStr(length := 12, OnlyAlphaNum := 1, lowCharacter := 48, HiCharacter := 122)
{
	loop % length
	{
		Random, r, lowCharacter, HiCharacter
		s .= Chr(r)
	}
	return OnlyAlphaNum ? RegExReplace(s, "\W", "i") : s
}