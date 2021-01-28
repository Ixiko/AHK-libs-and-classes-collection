Obj_Print(obj, indent = 0)
{
	static level := A_Tab
	Loop % indent
		tabs .= level

	if !IsObject(obj)
	{
		if obj is number
			return tabs . obj
		return tabs . """" . obj . """"
	}

	if (Obj_IsPureArray(obj))
	{
		representation .= tabs . "[`n"

		for each, value in obj
			representation .= Obj_Print(value, indent + 1) . ",`n"

		representation := RTrim(representation, ",`n")

		representation .= "`n" tabs . "]"
	}
	else
	{
		representation .= tabs . "{`n"

		for key, value in obj
		{
			if key is not number
				key := """" . key . """"
			representation .= tabs . level . key " : " Trim(Obj_Print(value, indent + 1)) . ",`n"
		}

		representation := RTrim(representation, ",`n")

		representation .= "`n" tabs . "}"
	}
	return representation
}
Obj_FindValue(obj, value, caseSensitive = false)
{
	for key, val in obj
	{
		if (!caseSensitive && val = value)
			return key
		else if (caseSensitive && val == value)
			return key
	}
}
Obj_IsPureArray(obj, zeroBased = false)
{
	for key in obj
	{
		if (!zeroBased && key != A_Index)
		{
			return false
		}
		else if (zeroBased && key != (A_Index - 1))
		{
			return false
		}
	}
	return true
}