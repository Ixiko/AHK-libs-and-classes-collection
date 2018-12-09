ITL_Min(params*)
{
	local each, value, minValue
	for each, value in params
	{
		if (A_Index == 1)
			minValue := value
		else if (value < minValue)
			minValue := value
	}
	return minValue
}