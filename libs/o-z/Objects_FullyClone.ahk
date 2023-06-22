


;Thanks to fincs
ObjFullyClone(obj, keysToSkip = "")
{
	if IsObject(obj)
	{
		nobj := obj.Clone()
		for k,v in nobj
		{
			if (keysToSkip)
			{
				found := false
				for oneIndex, oneKey in keysToSkip
				{
					if (oneKey = k)
						found := true
				}
				if (found)
				{
					nobj.delete(k)
					Continue
				}
			}
			if IsObject(v)
				nobj[k] := A_ThisFunc.(v)
		}
	}
	else
		nobj := obj
	return nobj
}

ObjFullyCompare_oneDir(obj1, obj2)
{
	for k,v in obj1
	{
		if IsObject(v)
		{
			if (A_ThisFunc.(v, obj2[k]) = false)
				return false
		}
		else
		{
			if (v != obj2[k])
				return false
		}
	}
	return true
}

; deeply merges content of obj2 in obj1
ObjFullyMerge(obj1, obj2)
{
	for k,v in obj2
	{
		if (isobject(v))
		{
			if (isobject(obj1[k]))
			{
				ObjFullyMerge(obj1[k], v)
			}
			else
			{
				obj1[k] := ObjFullyClone(v)
			}
		}
		else
		{
			obj1[k] := v
		}
	}
	return obj1
}

;Copied from https://autohotkey.com/board/topic/84006-ahk-l-containshasvalue-method/
;thanks to trismarck
ObjHasValue(aObj, aValue) {
    for key, val in aObj
        if(val = aValue)
            return, true, ErrorLevel := 0
    return, false, errorlevel := 1
}


ArrayToDelimitedString(obj, delimiter)
{
	result := ""
	for oneKey, oneValue in obj
	{
		if a_index != 1
			result .= delimiter
		result .= oneValue
	}
	return result
}