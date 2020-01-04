; Data-structure-related functions.


; Returns the number of keys in an array.
;  Returns 0 for null or non-objects
;  Returns count of both numeric and string indices.
getArraySize(ary) {
	if(!ary | !isObject(ary))
		return 0
	
	; Catches both string (associative arrays) and integer keys.
	size := 0
	For i,v in ary
		size++
	
	return size
}

isEmpty(obj) {
	if(!isObject(obj))
		return true
	
	For i,v in obj
		return false ; We found something, not empty.
	
	return true
}

; If the given object is already an array, return it. Otherwise, return an array with the given object as its only element (index 0).
forceArray(obj) {
	if(IsObject(obj))
		return obj
	
	newArray := []
	newArray[0] := obj
	return newArray
}

forceNumber(data) {
	if(isNum(data))
		return data
	return 0
}

; Inserts an item at the beginning of an array.
insertFront(ByRef arr, new) {
	arr2 := Object()
	arr2.Insert(new)
	; DEBUG.popup(arr2, "Array 2")
	
	arrLen := arr.MaxIndex()
	Loop, %arrLen% {
		arr2.Insert(arr[A_Index])
	}
	
	return arr2
}

; Array contains function. Returns index if it exists.
arrayContains(haystack, needle) {
	; DEBUG.popup("Hay", haystack, "Needle", needle)
	
	For i, el in haystack
		if(el = needle)
			return i
	
	return ""
}

; Maximum of any number of numeric arguments.
max(nums*) {
	; DEBUG.popup("Max", "Start", "Nums", nums)
	max := nums[1]
	For i,n in nums {
		if((max = "") || (max < n))
			max := n
	}
	
	return max
}

; overrides wins if they both have an index.
mergeArrays(default, overrides) {
	if(IsObject(default))
		retAry := default.clone()
	else
		retAry := []
	
	For i,v in overrides {
		if(IsObject(v))
			retAry[i] := mergeArrays(default[i], v)
		else
			retAry[i] := v
	}
	
	return retAry
}

; Appends the contents of one (numerically-indexed) array to the (numerically-indexed) other.
arrayAppend(baseAry, arrayToAppend) {
	; .length() returns "" if it's not an object and 0 if it's empty
	isBaseEmpty   := !(baseAry.length() > 0)
	isAppendEmpty := !(arrayToAppend.length() > 0)
	
	if(isBaseEmpty)
		return arrayToAppend
	if(isAppendEmpty)
		return baseAry
	
	outAry := baseAry.clone()
	For _,value in arrayToAppend
		outAry.push(value)
	
	return outAry
}

arrayDropDuplicates(inputAry) {
	outAry := []
	
	For _,val in inputAry
		if(!arrayContains(outAry, val))
			outAry.push(val)
	
	return outAry
}


; Counterpart to strSplit() - puts together all parts of an array with the given delimiter (defaults to "|")
arrayJoin(arrayToJoin, delim := "|") {
	outStr := ""
	
	For index,value in arrayToJoin {
		if(outStr)
			outStr .= delim
		outStr .= value
	}
	
	return outStr
}

; Sets global variables to null.
nullGlobals(baseName, startIndex, endIndex) {
	global
	local i
	
	i := startIndex
	While i <= endIndex {
		; DEBUG.popup("Variable", baseName i, "Before nullify", %baseName%%i%)
		%baseName%%i% := ""
		; DEBUG.popup("Variable", baseName i, "After nullify", %baseName%%i%)
		i++
	}
}

arrayDropEmptyValues(inputAry) {
	outAry := []
	
	For _,val in inputAry
		if(val != "")
			outAry.push(val)
	
	return outAry
}

; Creates a new table (2D array) with the values of the old, but the rows are indexed by the value of a specific subscript in each row.
; Example:
;   Input:
;      {
;      	1          => {"A" => "HI",       "B" => "THERE"}
;      	2          => {"A" => "BYE",      "B" => "SIR"}
;      	3          => {"A" => "GOOD DAY", "B" => "MADAM"}
;      }
;   Output (with a given subscriptName of "A"):
;      {
;      	"BYE"      => {"A" => "BYE",      "B" => "SIR"}
;      	"GOOD DAY" => {"A" => "GOOD DAY", "B" => "MADAM"}
;      	"HI"       => {"A" => "HI",       "B" => "THERE"}
reIndexTableBySubscript(inputTable, subscriptName) {
	if(subscriptName = "")
		return ""
	
	outTable := []
	For _,row in inputTable {
		newIndex := row[subscriptName]
		if(newIndex = "") ; Throw out rows without a value for our new index.
			Continue
		
		outTable[newIndex] := row.clone()
	}
	
	return outTable
}

; Reduce a table to the value of a single column per row, indexed by the value of another column.
reduceTableToColumn(inputTable, valueColumn, indexColumn := "") {
	if(!inputTable || !valueColumn)
		return ""
	
	outTable := []
	For origIndex,row in inputTable {
		if(indexColumn != "")
			newIndex := row[indexColumn]
		else
			newIndex := origIndex
		
		if(newIndex = "") ; Throw out rows without a value for our new index.
			Continue
		
		outTable[newIndex] := row[valueColumn]
	}
	
	return outTable
}

; Expand lists that can optionally contain numeric ranges.
; Note that ranges with non-numeric values will be ignored (not included in the output array).
; Example:
;  1,2:3,7,6:4 -> [1, 2, 3, 7, 6, 5, 4]
expandList(listString) {
	elementAry := strSplit(listString, ",")
	outAry := []
	
	For _,element in elementAry {
		if(stringContains(element, ":")) { ; Treat it as a numeric range and expand it
			rangeAry := expandNumericRange(element) ; If it's not numeric, this will return [] and we'll ignore that element entirely.
			outAry := arrayAppend(outAry, rangeAry)
		} else {
			outAry.push(element)
		}
	}
	
	return outAry
}

; Expands numeric ranges (i.e. 1:5 -> [1, 2, 3, 4, 5]).
expandNumericRange(rangeString) {
	splitAry := strSplit(rangeString, ":")
	start := splitAry[1]
	end   := splitAry[2]
	
	; Non-numeric ranges are not allowed.
	if(!isNum(start) || !isNum(end))
		return []
	
	if(start = end)
		return [start] ; Single-element range
	
	if(start < end)
		step := 1
	else
		step := -1
	
	numElements := abs(end - start) + 1
	rangeAry := []
	currNum := start
	Loop, %numElements% {
		rangeAry.push(currNum)
		currNum += step
	}
	
	return rangeAry
}
