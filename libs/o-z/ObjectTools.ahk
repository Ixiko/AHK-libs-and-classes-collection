;Example: zip([a,b,c],[d,e,f]) = [[a,d],[b,e],[c,f]]
zip(lists*)
{
	zipped := []
	Loop % min(map(lists,"objMaxIndex"))
		zipped.Insert(get(lists, A_Index))
	return zipped
}

;Applies a function to a list of values and returns all results of the function as a list.
map(list, function, args*)
{
	results := []
	for index, value in list
		results.Insert(function.(value, args*))
	return results
}

;returns all entries from "list" for which "function" returns true
filter(list,function,args*)
{
	filtered := []
	for index, value in list
		if(function.(value, args*))
			filtered.Insert(value)
	return filtered
}

;Successively applies "function" to two elements from "list" and their results and returns the final result.
reduce(list, function, args*)
{
	reduced := list.clone()
	while(reduced.MaxIndex() > 1)
		reduced.Insert(function.(reduced.Remove(), reduced.Remove(), args*))
	return reduced
}

;combines a list to a string of values separated by a separator
join(list, separator = "`n")
{
	result := ""
	for index, value in list
		result .= (A_Index != 1 ? separator : "") value
	return result
}

;Splits a string into a list of strings using a separator
split(string, separator = "`n")
{
	result :=   []
	Loop, parse, string, %separator% 
		result.Insert(A_LoopField)
	return   result
}

;returns a subset of properties from objects in a list.
;Example: get([{x:1, y:2}, {x:3, y:4}], "x") = [1,3]
;Example: get([{x:1, y:2, z:3}, {x:4, y:5, z:6}], "x", "z") = [{x:1,z:3},{x:4,z:6}]
get(list, keys*)
{
	values := []
	if(keys.MaxIndex() > 1)
		for index, value in list
		{
			result := []
			for index2, key in keys
				result[key] := value[key]
			values.Insert(result)
		}
	else
		for index, value in list
			values.Insert(value[keys[1]])
	return values.MaxIndex() ? values : ""
}

;Gets a subset of items from a list where listEntry[KeyOrValue] = value or listEntry = KeyOrValue
GetAll(list, KeyOrValue, value = "")
{
	values := []
	for index, VarOrObject in list
	{
		if(IsObject(VarOrObject))
		{
			if(VarOrObject[KeyOrValue] = value)
				values.Insert(VarOrObject)
		}
		else
			if(VarOrObject = KeyOrValue)
				values.Insert(VarOrObject)
	}
	return values.MaxIndex() ? values : ""
}
;Minimum from a list of values
min(values*)
{
	for index, value in values
		if(A_Index = 1 || value < min)
			min := value
	return min
}

;Maximum from a list of values
max(values*)
{
	for index, value in values
		if(A_Index = 1 || value > max)
			max := value
	return max
}


;Example: reversed([a,b,c]) = [c,b,a]
reversed(list)
{
	if(IsObject(list))
	{
		reversed := []
		MaxIndex := list.MaxIndex()
		Loop % MaxIndex
			reversed.Insert(list[MaxIndex - A_Index + 1])
		return reversed
	}
	else
	{
		reversed := ""
		Loop, parse, list
      		reversed := A_LoopField reversed
      	return reversed
	}
}

;Sorts a list of integers or strings. Does not support lists of objects
;Example: sorted([b,c,a]) = [a,b,c]
;Example: sorted([3,7,1]) = [1,3,7]
sorted(list, Callback = "")
{
	if(IsObject(list))
	{
		if(IsObject(first := list[list.MinIndex()]))
			return []
		escapedStringList := join(map(list, "escape"), ",")
		if first is number
			Sort, escapedStringList, % "N D" (IsFunc(Callback) ? " F " Callback : "")
		else
			Sort, escapedStringList, % "N" (IsFunc(Callback) ? " F " Callback : "")
		return split(unescape(escapedStringList), ",")
	}
}

;Sorts an array by one of the members keys
ArraySort(object, key, order = "Down")
{
	static obj, k, o
	;Called by user
	if(order = "Up" || order = "Down")
	{
		obj := object
		k := key
		o := order
		SortString := ""
		Loop % obj.MaxIndex()
			SortString .= (A_Index = 1 ? "" : "`n") A_Index
		Sort, SortString, % "F ArraySort"
		obj := ""
		k := ""
		o := ""
		sorted := Array()
		Loop, Parse, SortString, `n
			sorted.Insert(object[A_LoopField])
		return sorted
	}
	else ;Called by Sort command
	{
		if(obj[object][k] != obj[key][k])
			return (o = "Down" && obj[object][k] < obj[key][k]) || (o = "Up" && obj[object][k] > obj[key][k]) ? 1 : -1
		else
			return 0
	}
}

;Escapes all occurences of "separator" in "string" with "EscapeChar". This allows to use "separator" as a separator for string lists
escape(string, escapechar = "\", separator = ",")
{
	StringReplace, string, string, escapechar, escapechar escapechar, 1
	StringReplace, string, string, separator, escapechar separator, 1
	return string
}

;Unescapes all occurences of "separator" which are escaped by "escapechar" (and "escapechar" itself)
unescape(string, escapechar = "\", separator = ",")
{
	StringReplace, string, string, escapechar escapechar, Chr(1), 1
	StringReplace, string, string, escapechar separator, separator, 1
	StringReplace, string, string, Chr(1), escapechar, 1
	return string
}

;Example: range(10,90,30) = [10, 40, 70]
range(start, end, step = 1)
{
	index := start
	range := []

	;Wrong step direction -> infinite results -> return empty list
	if(step > 0 && end < start || step < 0 && end > start)
		return []

	while(step > 0 && index <= end || step < 0 && index >= end)
	{
		range.Insert(index)
		index += step
	}
	return range
}

;Example: unique([a,b,a,c,b]) = [a,b,c]
;Example: unique("abadcac") = "abdc"
unique(list)
{
	if(IsObject(list))
	{
		unique := []
		for key1, value1 in list
		{
			found := false
			for key2, value2 in list
				if(key1 != key2 && value1 = value2)
				{
					found := true
					break
				}
			if(!found)
				unique[key1] := value1
		}
		return unique
	}
	else
	{
		unique := ""
		Loop, parse, list
		{
			index := A_Index
			char1 := A_LoopField
			found := false
			Loop, parse, list
				if(index != A_Index && char1 = A_LoopField)
				{
					found := true
					break
				}
			if(!found)
				unique .= char1
		}
		return unique
	}
}

;Example: slice([1,2,3,4], 2, 4) = [2,3]
;Example: slice([1,2,3,4], "", 4) = [1,2,3]
;Example: slice([1,2,3,4], 2, "") = [2,3,4]
;Example: slice([1,2,3,4], -2, "") = [3,4]
;Example: slice([1,2,3,4], 2, -1) = [2,3]
;Example: slice([1,2,3,4], 2, 20) = [2,3,4]
;Example: slice("12345", -4, -2) = "23"
slice(list, start = "", end = "")
{
	if(IsObject(list))
	{
		sliced := []
		if(!start)
			start := 1
		if(!end)
			end := list.MaxIndex() + 1
		if(start < 0)
			start := list.MaxIndex() + start + 1
		if(end < 0)
			end := list.MaxIndex() + end + 1
		Loop % end - start
			sliced.Insert(list[A_Index + start - 1])
		return sliced
	}
	else
	{
		sliced := ""
		if(!start)
			start := 1
		len := StrLen(list)
		if(!end)
			end := len + 1
		if(start < 0)
			start := len + start + 1
		if(end < 0)
			end := len + end + 1
		return SubStr(list, start, end - start)
	}
}

;Example: repeat([1,2],3) = [1,2,1,2,1,2]
;Example: repeat("hello", 3) = "hellohellohello"
repeat(list, times)
{
	if(IsObject(list))
	{
		repeated := []
		Loop %times%
			repeated := extend(repeated,repeated)
		return repeated
	}
	else
	{
		repeated := ""
		Loop %times%
			repeated .= list
		return repeated
	}
}

;Example: extend([1,2],[3,4]) = [1,2,3,4]
extend(list, list2)
{
	extended := list.Clone()
	Loop % list2.MaxIndex()
		extended.Insert(list2[A_Index])
	return extended
}


;Checks if an object contains subitems which have a specific key-value pair or a specific value
Any(Object, KeyOrValue, value = "")
{
	for k,v in Object
		if(IsObject(v))
		{
			if(v[KeyOrValue] = value)
				return true
		}
		else
		{
			if(v = KeyOrValue)
				return true
		}
	return false
}

;Counts the subitems of an object which have a specific key-value pair or a specific value
Count(Object, KeyOrValue, value = "")
{
	count := 0
	for k,v in Object
		if(IsObject(v))
		{
			if(v[KeyOrValue] = value)
				count++
		}
		else
		{
			if(v = KeyOrValue)
				count++
		}
	return count
}

;Class Array
;{
;	__new(items*)
;	{
;		for index, item in items
;			this.Insert(item)
;	}

;	static Any := func("Any")
;	static Count := func("Count")

;	append(items*)
;	{
;		for index, item in items
;			this.Insert(item)
;	}

;	insertRange(pos, items*)
;	{
;		for index, item in items
;			this.Insert(pos + A_Index - 1, item)
;	}

;	clear()
;	{
;		Loop % this.MaxIndex()
;			this.remove()
;	}

;	;Removes the first occurence of an item in this list. Returns the item itself.
;	removeItem(item)
;	{
;		for index, element in this
;			if(item = element)
;			{
;				this.remove(index)
;				return item
;			}
;	}

;	;Removes all occurences of an item in this list. Returns the item itself.
;	removeAll(item)
;	{
;		pos := 1
;		Loop % this.MaxIndex()
;		{
;			if(this[pos] = item)
;				this.remove(pos)
;			else
;				pos++
;		}
;		return item
;	}

;	;Functions for retrieving items/indices:
;	indexOf(element)
;	{
;		for index, item in this
;			if(item = element)
;				return index
;	}

;	indexOfEquals(element)
;	{
;		for index, item in this
;			if(item = element || IsFunc(item.equals) && item.equals(element))
;				return index
;	}

;	;Finds an item of an array which has member variables specified by "conditions"
;	;"conditions" is of the form [key1, value1, key2, value2, ...]
;	;Example to get the key of an object in the list representing the active window from a list of window objects: WindowObjects.findIndex("hwnd", WinExist("A"))
;	findIndex(conditions*)
;	{
;		for index, item in this
;		{
;			fulfilled := true
;			Loop % conditions.MaxIndex() / 2
;				if(item[conditions[(A_Index - 1) * 2 + 1]] != conditions[A_Index * 2])
;				{
;					fulfilled := false
;					break
;				}
;			if(fulfilled)
;				return index
;		}
;	}

;	;Finds all items of an array which have member variables specified by "conditions"
;	;"conditions" is of the form [key1, value1, key2, value2, ...]
;	;Example to get the keys of all objects in the list representing notepad windows from a list of window objects: WindowObjects.findAllIndices("class", "Notepad")
;	findAllIndices(conditions*)
;	{
;		findings := []
;		for index, item in this
;		{
;			fulfilled := true
;			Loop % conditions.MaxIndex() / 2
;				if(item[conditions[(A_Index - 1) * 2 + 1]] != conditions[A_Index * 2])
;				{
;					fulfilled := false
;					break
;				}
;			if(fulfilled)
;				findings.Insert(index)
;		}
;		return findings
;	}

;	;Finds an item of an array which has member variables specified by "conditions"
;	;"conditions" is of the form [key1, value1, key2, value2, ...]
;	;Example to get the object representing the active window from a list of window objects: WindowObjects.findItem("hwnd", WinExist("A"))
;	findItem(conditions*)
;	{
;		for index, item in this
;		{
;			fulfilled := true
;			Loop % conditions.MaxIndex() / 2
;				if(item[conditions[(A_Index - 1) * 2 + 1]] != conditions[A_Index * 2])
;				{
;					fulfilled := false
;					break
;				}
;			if(fulfilled)
;				return item
;		}
;	}

;	;Finds all items of an array which have member variables specified by "conditions"
;	;"conditions" is of the form [key1, value1, key2, value2, ...]
;	;Example to get all objects representing notepad windows from a list of window objects: WindowObjects.findAllItems("class", "Notepad")
;	findAllItems(conditions*)
;	{
;		findings := []
;		for index, item in this
;		{
;			fulfilled := true
;			Loop % conditions.MaxIndex() / 2
;				if(item[conditions[(A_Index - 1) * 2 + 1]] != conditions[A_Index * 2])
;				{
;					fulfilled := false
;					break
;				}
;			if(fulfilled)
;				findings.Insert(item)
;		}
;		return findings
;	}

;	;See <slice()>
;	slice(start = "", end = "")
;	{
;		return slice(this, start, end)
;	}
;}