; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat
array_concat(arrays*) {

	results := []

	for index, array in arrays
		for index, element in array
			results.push(element)

	return results
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
array_every(array, callback) {

	for index, element in array
		if not callback.Call(element, index, array)
			return false

	return true
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find
array_fill(array, value, start:=0, end:=0) {

	len := array.Length()

	; START: Adjust 1 based index, check signage, set defaults
	if (start > 0)
		begin := start - 1    ; Include starting index going forward
	else if (start < 0)
		begin := len + start  ; Count backwards from end
	else
		begin := start


	; END: Check signage and set defaults
	if (end > 0)
	    last := end
	else if (end < 0)
		last := len + end   ; Count backwards from end
	else
		last := len


	loop, % (last - begin)
		array[begin + A_Index] := value

	return array
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
array_filter(array, callback) {
	
	results := []

	for index, element in array
		if (callback.Call(element, index, array))
			results.push(element)

	return results
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find
; Modified to return 0 instead of 'undefined'
array_find(array, callback) {
	
	for index, element in array {
		if (callback.Call(element, index, array))
			return element
	}

	return 0
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex
array_findIndex(array, callback) {

	for index, value in array
		if (callback.Call(value, index, array))
			return index

	return 0
}



; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
array_forEach(array, callback) {

	for index, element in array
		callback.Call(element, index, array)

	return 0
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/includes
array_includes(array, searchElement, fromIndex:=0) {

	return array_indexOf(array, searchElement, fromIndex) > 0 ? true : false
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf
array_indexOf(array, searchElement, fromIndex:=0) {
	
	len := array.Length()

	if (fromIndex > 0)
		start := fromIndex - 1    ; Include starting index going forward
	else if (fromIndex < 0)
		start := len + fromIndex  ; Count backwards from end
	else
		start := fromIndex


	loop, % len - start
		if (array[start + A_Index] = searchElement)
			return start + A_Index

	return 0
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join
array_join(array, delim) {
	
	result := ""
	
	for index, element in array
		result .= element (index < array.Length() ? delim : "")

	return result
}

; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf
; "if the provided index is negative, the array is still searched from front to back"
;   - Are we not able to return the first found starting from the back?
array_lastIndexOf(array, searchElement, fromIndex:=0) {
	
	len := array.Length()
	foundIdx := -1

	if (fromIndex > len)
		return foundIdx

	if (fromIndex > 0)
		start := fromIndex - 1    ; Include starting index going forward
	else if (fromIndex < 0)
		start := len + fromIndex  ; Count backwards from end
	else
		start := fromIndex

	loop, % len - start
		if (array[start + A_Index] = searchElement)
			foundIdx := start + A_Index

	return foundIdx
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
array_map(array, callback) {

	results := []

	for index, element in array
		results.push(callback.Call(element, index, array))

	return results
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce
; -->[A,B,C,D,E,F]
array_reduce(array, callback, initialValue:="__NULL__") {

	arrLen := array.Length()

	; initialValue not defined
	if (initialValue == "__NULL__") {

		if (arrLen < 1) {
			; Empty array with no intial value
			return
		}
		else if (arrLen == 1) {
			; Single item array with no initial value
			return array[1]
		}

		; Starting value is last element
		initialValue := array[1]

		; Loop n-1 times (start at 2nd element)
		iterations := arrLen - 1 

		; Set index A_Index+1 each iteration
		idxOffset := 1

	} else {
	; initialValue defined

		if (arrLen == 0) {
			; Empty array with initial value
			return initialValue
		}

		; Loop n times (starting at 1st element)
		iterations := arrLen

		; Set index A_Index each iteration
		idxOffset := 0
	}

	; if no initialValue is passed, use first index as starting value and reduce
	; array starting at index n+1. Otherwise, use initialValue as staring value
	; and start at arrays first index.
	Loop, % iterations
	{
		adjIndex := A_Index + idxOffset
		initialValue := callback.Call(initialValue, array[adjIndex], adjIndex, array)
	}
	
	return initialValue
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduceRight
; [A,B,C,D,E,F]<--
array_reduceRight(array, callback, initialValue:="__NULL__") {

	arrLen := array.Length()

	; initialValue not defined
	if (initialValue == "__NULL__") {

		if (arrLen < 1) {
			; Empty array with no intial value
			return
		}
		else if (arrLen == 1) {
			; Single item array with no initial value
			return array[1]
		}

		; Starting value is last element
		initialValue := array[arrLen]

		; Loop n-1 times (starting at n-1 element)
		iterations := arrLen - 1 
		
		; Set index A_Index-1 each iteration
		idxOffset := 0

	} else {
	; initialValue defined

		if (arrLen == 0)
			; Empty array with initial value
			return initialValue

		; Loop n times (start at n element)
		iterations := arrLen

		; Set index A_Index each iteration
		idxOffset := 1
	}

	; If no initialValue is passed, use last index as starting value and reduce
	; array starting at index n-1. Otherwise, use initialValue as starting value
	; and start at arrays last index.
	Loop, % iterations
	{
		adjIndex := arrLen - (A_Index - idxOffset)
		initialValue := callback.Call(initialValue, array[adjIndex], adjIndex, array)
	}

	return initialValue
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse
array_reverse(array) {

	arrLen := array.Length()

	Loop, % (arrLen // 2)
	{
		idxFront := A_Index
		idxBack := arrLen - (A_Index - 1)

		tmp := array[idxFront]
		array[idxFront] := array[idxBack]
		array[idxBack] := tmp
	}

	return array
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift
array_shift(array) {

	return array.RemoveAt(1)
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice
array_slice(array, start:=0, end:=0) {

	len := array.Length()

	; START: Adjust 1 based index, check signage, set defaults
	if (start > 0)
		begin := start - 1    ; Include starting index going forward
	else if (start < 0)
		begin := len + start  ; Count backwards from end
	else
		begin := start


	; END: Check signage and set defaults
	; MDN States: "to end (end not included)" so subtract one from end
	if (end > 0)
	    last := end - 1
	else if (end < 0)
		last := len + end + 1 ; Count backwards from end
	else
		last := len


	results := []

	loop, % last - begin
		results.push(array[begin + A_Index])

	return results
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
array_some(array, callback) {

	for index, value in array
		if callback.Call(value, index, array)
			return true

	return false
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort
array_sort(array, compare_fn:=0) {

    ; Quicksort
	Array_QuickSort.Call(array, compare_fn)

    return array
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice
array_splice(ByRef array, start, deleteCount:=-1, args*) {

	arrLen := array.Length()
	exiting := []

	; Determine starting index
	if (start > arrLen)
		start := arrLen

	if (start < 0)
		start := arrLen + start

	; deleteCount unspecified or out of bounds, set count to start through end
	if ((deleteCount < 0) || (arrLen <= (start + deleteCount))) {
		deleteCount := arrLen - start + 1
	}

	; Remove elements
	Loop, % deleteCount
	{
		exiting.push(array[start])
		array.RemoveAt(start)
	}

	; Inject elements
	Loop, % args.Length()
	{
		curIndex := start + (A_Index - 1)

		array.InsertAt(curIndex, args[1])
		args.removeAt(1)
	}

	return exiting
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toString
array_toString(array) {

	str := ""
	for i,v in array
		str .= v (i < array.Length() ? "," : "")
	
	return "[" str "]"
}


; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift
array_unshift(array, args*) {

	for index, value in args
		array.InsertAt(A_Index, value)

	return array.Length()
}

/*
Class _Array_QuickSort {
    __New(array, compare_fn:=0) {
        this.array := array
        this.compare_fn := compare_fn
        if not (compare_fn) {
            this.compare_fn := objBindMethod(this, "_basic_compare")
        }
    }

    _basic_compare(a, b) {
        return a > b ? 1 : a < b ? -1 : 0
    }

    sort(left, right) {
        if (this.array.Length() > 1) {
            centerIdx := this.partition(left, right)
            if (left < centerIdx - 1) {
                this.sort(left, centerIdx - 1)
            }
            if (centerIdx < right) {
                this.sort(centerIdx, right)
            }
        }
    }

    partition(left, right) {
        pivot := this.array[floor(left + (right - left) / 2)]
        i := left
        j := right

        while (i <= j) {
            while (this.compare_fn.Call(this.array[i], pivot) = -1) { ;this.array[i] < pivot
                i++
            }
            while (this.compare_fn.Call(this.array[j], pivot) = 1) { ;this.array[j] > pivot
                j--
            }
            if (i <= j) {
                this.array.swap(i, j)
                i++
                j--
            }
        }

        return i
    }
}
*/