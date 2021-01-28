Bin2Dec(bin)
{
	sum := 0, len := StrLen(bin)
	Loop Parse, bin
	{
		b := 1
		, n := A_LoopField + 0

		if (n != 1 && n != 0)
		{
			throw Exception("Invalid input!")
		}
		b := b << (len - A_Index)
		sum += n * b
	}
	return sum
}