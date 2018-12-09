ITL_Max(params*)
{
	local each, value, maxValue
	for each, value in params
	{
		if (A_Index == 1)
			maxValue := value
		else if (value > maxValue)
			maxValue := value
	}
	return maxValue
}