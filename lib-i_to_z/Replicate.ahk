Replicate(Str,Count) ; www.autohotkey.com/community/viewtopic.php?p=435990#435990 ; By SKAN / CD:12-04-2011
{
	Count := Count < 0 ? 0 : Count ; if a negative number is passed, set to zero
	VarSetCapacity(S,Count * (A_IsUnicode ? 2 : 1),1)
	StringReplace, S, S, % SubStr(S,1,1), %Str%, All
	Return SubStr(S,1,Count * StrLen(Str))
}
