QA_Create(ByRef arr, capacity="4") {
	capacity := capacity < 1 ? 1 : capacity
	VarSetCapacity(arr, __QA_ByteSize(capacity))
	__QA_WriteIdentifier(arr)
	__QA_SetLength(arr, 0)
	__QA_SetCapacity(arr, capacity)
}
QA_ValueOf(ByRef arr, str, delim=",") {
	StringSplit, tokens, str, %delim%
	QA_Create(arr, tokens0)
	Loop, %tokens0%
		QA_Add(arr, tokens%A_Index%)
}
QA_Clone(ByRef arr, ByRef clonedArr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	capacity := __QA_Capacity(arr)
	QA_Create(clonedArr, capacity)
	length := __QA_Length(arr)
	Loop, %length%	 {
		__QA_Get(arr, A_Index, value)
		__QA_Add(clonedArr, value)
	}
}
QA_CopyOf(ByRef arr, ByRef newArr, from="not_idx", to="not_idx", default="") {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	last := __QA_Length(arr) + 1
	If (from == "not_idx") {
		from := 1
		to := last
	}
	If (__QA_CheckInvalidRangeIndex(from, to, last, A_ThisFunc))
		return
	If (to > last) {
		__QA_CopyOf(arr, newArr, from, last)
		addCnt := to - last
		Loop, %addCnt%
			__QA_Add(newArr, default)
	} Else
		__QA_CopyOf(arr, newArr, from, to)
}
QA_Destroy(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	length := __QA_Length(arr)
	addr := __QA_ByteSize(0)
	Loop, %length%	 {
		elemId := NumGet(arr, addr, "UInt")
		__QA_Free(elemId)
		addr += 8
	}
	VarSetCapacity(arr, 0)
}
QA_Add(ByRef arr, value) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	__QA_Add(arr, value)
}
QA_Set(ByRef arr, index, value) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc) || __QA_CheckInvalidIndex(index, __QA_Length(arr), A_ThisFunc))
		return
	__QA_Set(arr, index, value)
}
QA_Get(ByRef arr, index) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc) || __QA_CheckInvalidIndex(index, __QA_Length(arr), A_ThisFunc))
		return
	__QA_Get(arr, index, value)
	return value
}
QA_Insert(ByRef arr, index, value) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	maxIndex := __QA_Length(arr) + 1
	If (index == maxIndex) {
		__QA_Add(arr, value)
	} Else If (__QA_CheckInvalidIndex(index, maxIndex, A_ThisFunc)) {
		return
	} Else {
		__QA_Move(arr, index, index + 1)
		newElemId := __QA_Alloc()
		__QA_Write(newElemId, value)
		__QA_SetElemId(arr, index, newElemId)
	}
}
QA_Remove(ByRef arr, index) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	length := __QA_Length(arr)
	If (__QA_CheckInvalidIndex(index, length, A_ThisFunc))
		return
	elemId := __QA_ElemId(arr, index)
	__QA_Read(elemId, value)
	__QA_Free(elemId)
	offset := __QA_ByteSize(index - 1)
	elemCountToCopy := length - index
	DllCall("msvcrt.dll\memcpy", "UInt", &arr + offset, "UInt", &arr + offset + 8, "UInt", 8 * elemCountToCopy)
	__QA_SetLength(arr, length - 1)
	return value
}
QA_Push(ByRef arr, value) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	__QA_Add(arr, value)
}
QA_Pop(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc)) {
		ErrorLevel := 1
		return ""
	}
	length := __QA_Length(arr)
	If (length == 0) {
		ErrorLevel := 1
		return ""
	}
	elemId := __QA_ElemId(arr, length)
	__QA_Read(elemId, result)
	__QA_Free(elemId)
	__QA_SetLength(arr, length - 1)
	ErrorLevel := 0
	return result
}
QA_Fill(ByRef arr, value, from="not_idx", to="not_idx") {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	last := __QA_Length(arr) + 1
	If (from == "not_idx") {
		from := 1
		to := last
	}
	If (__QA_CheckInvalidRangeIndex(from, to, last, A_ThisFunc))
		return
	If (to > last) {
		__QA_Fill(arr, value, from, last)
		addCnt := to - last
		Loop, %addCnt%
			__QA_Add(arr, value)
	} Else
		__QA_Fill(arr, value, from, to)
}
QA_Swap(ByRef arr, i, j) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	length := QA_Length(arr)
	If (__QA_CheckInvalidIndex(i, length, A_ThisFunc) || __QA_CheckInvalidIndex(j, length, A_ThisFunc))
		return
	__QA_Swap(arr, i, j)
}
QA_IndexOf(ByRef arr, value) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	length := __QA_Length(arr)
	Loop, %length% {
		__QA_Get(arr, A_Index, aVal)
		If (aVal == value)
			return A_Index
	}
	return 0
}
QA_BinarySearch(ByRef arr, key, from="not_idx", to="not_idx") {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	last := __QA_Length(arr) + 1
	If (from == "not_idx") {
		from := 1
		to := last
	}
	If (__QA_CheckInvalidRangeIndex(from, to, last, A_ThisFunc))
		return
	return to > last ? __QA_BinarySearch(arr, key, from, last)
							: __QA_BinarySearch(arr, key, from, to)
}
QA_Shuffle(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	Random,, %A_TickCount%
	length := __QA_Length(arr)
	Loop, %length% {
		Random, a, 1, %length%
		Random, b, 1, %length%
		__QA_Swap(arr, a, b)
	}
}
QA_Sort(ByRef arr, asc=true) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	__QA_Sort(arr, asc, 1, __QA_Length(arr))
}
QA_Equals(ByRef arr, ByRef arr2) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc) || __QA_CheckInvalidArray(arr2, A_ThisFunc))
		return
	length := __QA_Length(arr)
	length2 := __QA_Length(arr2)
	If (length != length2)
		return false
	Loop, %length% {
		__QA_Get(arr, A_Index, value)
		__QA_Get(arr, A_Index, value2)
		If (value != value2)
			return false
	}
	return true
}
QA_ToString(ByRef arr, delim=",") {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	result := ""
	length := __QA_Length(arr)
	Loop, %length% {
		If (A_Index != 1)
			result .= delim
		result .= QA_Get(arr, A_Index)
	}
	return result
}
QA_Length(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	return __QA_Length(arr)
}
QA_HeaderInfo(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	__QA_Identifier(arr, id)
	return "[array header info]`r`n`r`n"
			. "id=" . id . "`r`n"
			. "length=" . __QA_Length(arr) . "`r`n"
			. "capacity=" . __QA_Capacity(arr)
}
QA_IsArray(ByRef arr) {
	__QA_Identifier(arr, id)
	return id == "S0A0S0A0"
}
QA_DumpAllMemory() {
	global
	__QA_Dump_TotalBytes := 0
	__QA_Dump_Result := ""
	Loop, %__QA_LastElemId% {
		__QA_Dump_TotalBytes += StrLen(__QA_Elem%A_Index%)
		If (A_Index <= 50)
			__QA_Dump_Result .= "__QA_Elem" . A_Index . "=[" . __QA_Elem%A_Index% . "]`r`n"
		If (A_Index == 50)
			__QA_Dump_Result .= "...`r`n"
	}
	MsgBox [QA all memory dump]`r`n`r`nTotal memory size=%__QA_Dump_TotalBytes% bytes`r`nThe last element ID=%__QA_LastElemId%`r`n`r`n%__QA_Dump_Result%
	__QA_Dump_TotalBytes := ""
	__QA_Dump_Result := ""
}
QA_DumpArray(ByRef arr) {
	If (__QA_CheckInvalidArray(arr, A_ThisFunc))
		return
	result := ""
	length := __QA_Length(arr)
	Loop, %length% {
		elemId := __QA_ElemId(arr, A_Index)
		value := ""
		__QA_Read(elemId, value)
		result .= "__QA_Elem" . elemId . "=[" . value . "]`r`n"
		If (A_Index == 50) {
			result .= "...`r`n"
			break
		}
	}
	MsgBox [QA array dump]`r`n`r`n%result%
}
__QA_Add(ByRef arr, ByRef value) {
	newLength := __QA_Length(arr) + 1
	__QA_Expand(arr, newLength)
	__QA_SetLength(arr, newLength)
	newElemId := __QA_Alloc()
	__QA_Write(newElemId, value)
	__QA_SetElemId(arr, newLength, newElemId)
}
__QA_Expand(ByRef arr, newLength) {
	capacity := __QA_Capacity(arr)
	If (newLength < capacity)
		return
	while (newLength > capacity)
		capacity *= 2
	oldByteSize := __QA_ByteSize(__QA_Length(arr))
	VarSetCapacity(tmpArr, oldByteSize)
	DllCall("msvcrt.dll\memcpy", "UInt", &tmpArr, "UInt", &arr, "UInt", oldByteSize)
	newByteSize := __QA_ByteSize(capacity)
	VarSetCapacity(arr, newByteSize)
	DllCall("msvcrt.dll\memcpy", "UInt", &arr, "UInt", &tmpArr, "UInt", oldByteSize)
	VarSetCapacity(tmpArr, 0)
	__QA_SetCapacity(arr, capacity)
}
__QA_Set(ByRef arr, index, ByRef value) {
	elemId := __QA_ElemId(arr, index)
	__QA_Write(elemId, value)
}
__QA_Get(ByRef arr, index, ByRef value) {
	elemId := __QA_ElemId(arr, index)
	__QA_Read(elemId, value)
}
__QA_Move(ByRef arr, from, to) {
	oldLength := __QA_Length(arr)
	newLength := oldLength + to - from
	newCapacity := __QA_Capacity(arr)
	while (newLength > newCapacity)
		newCapacity *= 2
	oldByteSize := __QA_ByteSize(oldLength)
	VarSetCapacity(tmpArr, oldByteSize)
	DllCall("msvcrt.dll\memcpy", "UInt", &tmpArr, "UInt", &arr, "UInt", oldByteSize)
	VarSetCapacity(arr, __QA_ByteSize(newCapacity))
	fromOffset := __QA_ByteSize(from - 1)
	toOffset := __QA_ByteSize(to - 1)
	DllCall("msvcrt.dll\memcpy", "UInt", &arr, "UInt", &tmpArr, "UInt", fromOffset)
	DllCall("msvcrt.dll\memcpy", "UInt", &arr + toOffset, "UInt", &tmpArr + fromOffset, "UInt", oldByteSize - fromOffset)
	VarSetCapacity(tmpArr, 0)
	__QA_SetLength(arr, newLength)
	__QA_SetCapacity(arr, newCapacity)
}
__QA_CopyOf(ByRef arr, ByRef newArr, from, to) {
	length := to - from
	QA_Create(newArr, length)
	Loop, %length% {
		__QA_Get(arr, from + A_Index - 1, value)
		__QA_Add(newArr, value)
	}
}
__QA_Fill(ByRef arr, value, from, to) {
	curIdx := from
	fillCnt := to - from
	Loop, %fillCnt% {
		elemId := __QA_ElemId(arr, curIdx)
		__QA_Write(elemId, value)
		curIdx += 1
	}
}
__QA_BinarySearch(ByRef sortedArr, key, from, to) {
	Loop {
		mid := Floor((from + to) / 2)
		If (from >= to)
			return -mid
		__QA_Get(sortedArr, mid, aVal)
		If (key == aVal)
			return mid
		Else IF (key < aVal)
			to := mid
		Else
			from := mid + 1
	}
}
__QA_Sort(ByRef arr, asc, left, right) {
	If (left < right) {
		pivot := __QA_Partition(arr, asc, left, right)
		__QA_Sort(arr, asc, left, pivot - 1)
		__QA_Sort(arr, asc, pivot + 1, right)
	}
}
__QA_Partition(ByRef arr, asc, left, right) {
	__QA_Get(arr, left, pivot)
	i := left
	j := right + 1
	Loop {
		Loop {
			i += 1
			__QA_Get(arr, i, aVal)
			If (i == right || (asc ? aVal >= pivot : aVal <= pivot))
				break
		}
		Loop {
			j := j - 1
			__QA_Get(arr, j, aVal)
			If (j == left || (asc ? aVal <= pivot : aVal >= pivot))
				break
		}
		If (i >= j)
			break
		__QA_Swap(arr, i, j)
	}
	__QA_Swap(arr, left, j)
	return j
}
__QA_Swap(ByRef arr, i, j) {
	tmpElemId := __QA_ElemId(arr, i)
	__QA_SetElemId(arr, i, __QA_ElemId(arr, j))
	__QA_SetElemId(arr, j, tmpElemId)
}
__QA_WriteIdentifier(ByRef arr) {
	id := "S0A0S0A0"
	DllCall("msvcrt.dll\memcpy", "UInt", &arr, "UInt", &id, "UInt", 8)
}
__QA_SetLength(ByRef arr, length) {
	NumPut(length, arr, 8, "UInt")
}
__QA_SetCapacity(ByRef arr, capacity) {
	NumPut(capacity, arr, 16, "UInt")
}
__QA_SetElemId(ByRef arr, index, elemId) {
	offset := __QA_ByteSize(index - 1)
	NumPut(elemId, arr, offset, "UInt")
}
__QA_Identifier(ByRef arr, ByRef id) {
	VarSetCapacity(id, 9, 0)
	DllCall("msvcrt.dll\memcpy", "UInt", &id, "UInt", &arr, "UInt", 8)
	VarSetCapacity(id, -1)
}
__QA_Length(ByRef arr) {
	return NumGet(arr, 8, "UInt")
}
__QA_Capacity(ByRef arr) {
	return NumGet(arr, 16, "UInt")
}
__QA_ElemId(ByRef arr, index) {
	offset := __QA_ByteSize(index - 1)
	return NumGet(arr, offset, "UInt")
}
__QA_PopUnusedElemID(ByRef elemID) {
	global
	If (__QA_UnusedElemIDCnt != 0) {
		elemID := __QA_UnusedElemID%__QA_UnusedElemIDCnt%, __QA_UnusedElemID%__QA_UnusedElemIDCnt% := ""
		__QA_UnusedElemIDCnt--
	} Else {
		elemID := -1
	}
}
__QA_PushUnusedElemID(ByRef elemID) {
	global
	__QA_UnusedElemIDCnt++
	__QA_UnusedElemID%__QA_UnusedElemIDCnt% := elemID
}
__QA_Alloc() {
	global
	If (__QA_LastElemId == "") {
		__QA_LastElemId := 0
		__QA_UnusedElemIDCnt := 0
	}
	local unusedElemID
	__QA_PopUnusedElemID(unusedElemID)
	If (unusedElemID == -1) {
		return ++__QA_LastElemId
	} Else {
		return unusedElemID
	}
}
__QA_Free(elemId) {
	global
	VarSetCapacity(__QA_Elem%elemId%, 0)
	__QA_PushUnusedElemID(elemId)
}
__QA_FreeAllMemory() {
	global __QA_LastElemId, __QA_UnusedElemIDCnt
	Loop, %__QA_LastElemId%
		VarSetCapacity(__QA_Elem%A_Index%, 0)
	__QA_LastElemId := ""
	Loop, %__QA_UnusedElemIDCnt%
		VarSetCapacity(__QA_UnusedElemID%A_Index%, 0)
	__QA_UnusedElemIDCnt := ""
}
__QA_Write(elemId, ByRef value) {
	global
	__QA_Elem%elemId% := value
}
__QA_Read(elemId, ByRef value) {
	global
	value := __QA_Elem%elemId%
}
__QA_ByteSize(capacity) {
	return 8 * capacity + 24
}
__QA_CheckInvalidArray(ByRef arr, func="") {
	valid := QA_IsArray(arr)
	If (!valid) {
		msg := "Invalid array."
		__QA_Error(msg, func)
	}
	return !valid
}
__QA_CheckInvalidIndex(index, maxIndex, func="") {
	If (!__QA_Include(1, maxIndex, index)) {
		msg = Index(%index%) must be [1,%maxIndex%].
		__QA_Error(msg, func)
		return true
	}
	return false
}
__QA_CheckInvalidRangeIndex(from, to, last, func="") {
	If from is not integer
	{
		msg = "From" index(%from%) must be an integer value.
		return true
	} Else If to is not integer
	{
		msg = "To" index(%to%) index must be an integer value.
		return true
	} Else If (from > to) {
		msg = "From" index(%from%) must be less than or equal to "to" index(%to%).
		__QA_Error(msg, func)
		return true
	} Else If (!__QA_Include(1, last, from)) {
		msg = "From" index(%from%) must be [1,%last%].
		__QA_Error(msg, func)
		return true
	} Else
		return false
}
__QA_CheckInvalidElemId(elemId) {
	global __QA_LastElemId
	If (!__QA_Include(1, __QA_LastElemId, elemId)) {
		msg = Element ID(%elemId%), which is internally used, must be [1,%__QA_LastElemId%].
		__QA_Error(msg, func)
		return true
	}
	return false
}
__QA_Include(from, to, value) {
	return from <= value && value <= to
}
__QA_Error(msg, func="") {
	result := "[Quick Array library error]`r`n"
	If (func != "")
		result .= "`r`nfunction : " . func . "()"
	result .= "`r`nmessage : " . msg
	MsgBox % result
}
QA_PerfTest_General(length=3000, testCnt=5) {
	timeForAdding := timeForGetting := timeForInserting := timeForRemoving := 0
	Loop, %testCnt% {
		Random,, %A_TickCount%
		QA_Create(arr)
		Loop, %length% {
			value := "test" . A_Index
			start := A_TickCount
			QA_Add(arr, value)
			timeForAdding += A_TickCount - start
		}
		Loop, %length% {
			Random, idx, 1, %length%
			start := A_TickCount
			dumpVar := QA_Get(arr, idx)
			timeForGetting += A_TickCount - start
		}
		Loop, %length% {
			availIdxBound := QA_Length(arr)
			Random, idx, 1, %availIdxBound%
			start := A_TickCount
			dumpVar := QA_Remove(arr, 1)
			timeForRemoving += A_TickCount - start
		}
		Loop, %length% {
			availIdxBound := QA_Length(arr) + 1
			Random, idx, 1, %availIdxBound%
			value := "test" . A_Index
			start := A_TickCount
			QA_Insert(arr, idx, value)
			timeForInserting += A_TickCount - start
		}
		QA_Destroy(arr)
	}
	MsgBox % "[QA general performance test for " . length . " elements]`r`n`r`n"
			. "adding = " . (timeForAdding / testCnt) . " ms`r`n"
			. "getting = " . (timeForGetting / testCnt) . " ms`r`n"
			. "inserting = " . (timeForInserting / testCnt) . " ms`r`n"
			. "removing = " . (timeForRemoving / testCnt) . " ms`r`n"
}
QA_PerfTest_Search(length=1500, srchCnt=500, testCnt=5) {
	timeForSeqSrch := timeForBinSrch := 0
	Loop, %testCnt% {
		QA_Create(arr)
		Loop, %length%
			QA_Add(arr, "test" . A_Index)
		QA_Shuffle(arr)
		Loop, %srchCnt% {
			Random, idx, 1, %length%
			key := "test" . idx
			start := A_TickCount
			dumpVar := QA_IndexOf(arr, key)
			timeForSeqSrch += A_TickCount - start
		}
		QA_Sort(arr)
		Loop, %srchCnt% {
			Random, idx, 1, %length%
			key := "test" . idx
			start := A_TickCount
			dumpVar := QA_BinarySearch(arr, key)
			timeForBinSrch += A_TickCount - start
		}
		QA_Destroy(arr)
	}
	MsgBox % "[QA search performance test for " . length . " elements]`r`n"
			. "Each value is the time spent for searching " . srchCnt . " times.`r`n`r`n"
			. "sequantial searching = " . (timeForSeqSrch / testCnt) . " ms`r`n"
			. "binary searching = " . (timeForBinSrch / testCnt) . " ms"
}
QA_PerfTest_Sort(length=500, testCnt=5) {
	timeForSorting := 0
	Loop, %testCnt% {
		QA_Create(arr, length)
		Loop, %length%
			QA_Add(arr, "test" . A_Index)
		QA_Shuffle(arr)
		start := A_TickCount
		QA_Sort(arr)
		timeForSorting += A_TickCount - start
		QA_Destroy(arr)
	}
	MsgBox % "[QA sort performance test for " . length . " elements]`r`n`r`n"
			. "average sorting time = " . (timeForSorting / testCnt) . " ms"
}
