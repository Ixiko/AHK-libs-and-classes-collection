StrReplicate(fnStr,fnCount)
{
	VarSetCapacity(S,fnCount*(A_IsUnicode ? 2 : 1),1) ; set capacity of variable to the same number of character spaces as the required count
	StringReplace, S, S, % SubStr(S,1,1), %fnStr%, All ; replace all occurences of the first character space with the required string
	Return SubStr(S,1,fnCount*StrLen(fnStr)) ; return the required number of characters
}
