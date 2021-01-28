implode(array, sep = "")
{
	local str := "", k := "", v := ""
	for k, v in array
		str .= v . sep
	return SubStr(str, 1, StrLen(str) - StrLen(sep))
}