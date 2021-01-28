; arr - Array of any type to sort. Indexes should be consecutive whole numbers (have values under all
; 	indexes from the first used, to the last used).
; cmpFunc - <optional> Comparison function, as normaly takes two arguments (of
;	the same type as array elements). It should return 0 on equal,
;	>0 on first greater than second, <0 on first less than second.
;	You can exchange it to make sorting in descending order.
; If no cmpFunc is passed, simple comparison a > b is performed.
QuickSort(arr, cmpFunc:="")
{
	if (!cmpFunc) {
		cmpFunc := Func("SimpleCmp")
	}
	return QuickSortRange(arr, arr.MinIndex(), arr.MaxIndex(), cmpFunc)
}

QuickSortRange(arr, beginIndex, endIndex, cmpFunc)
{
	if (beginIndex >= endIndex) {
		return
	}

	part := QuickSortPartition(arr, beginIndex, endIndex, cmpFunc)
	QuickSortRange(arr, beginIndex, part - 1, cmpFunc)
	QuickSortRange(arr, part + 1, endIndex, cmpFunc)

	return arr
}

QuickSortPartition(arr, beginIndex, endIndex, cmpFunc)
{
	leftIndex := beginIndex
	rightIndex := endIndex
	middleIndex := (leftIndex + rightIndex) // 2
	pivotValue := arr[middleIndex]

	temp := arr[leftIndex]
	arr[leftIndex] := arr[middleIndex]
	arr[middleIndex] := temp
	leftIndex += 1

	while (leftIndex <= rightIndex) {
		while (leftIndex <= rightIndex && cmpFunc.Call(arr[leftIndex], pivotValue) <= 0) {
			leftIndex += 1
		}
		while (leftIndex <= rightIndex && cmpFunc.Call(arr[rightIndex], pivotValue) > 0) {
			rightIndex -= 1
		}

		if(leftIndex < rightIndex) {
			temp := arr[rightIndex]
			arr[rightIndex] := arr[leftIndex]
			arr[leftIndex] := temp
		}
	}

	temp := arr[leftIndex - 1]
	arr[leftIndex - 1] := arr[beginIndex]
	arr[beginIndex] := temp
	return leftIndex - 1
}

SimpleCmp(a, b)
{
	return (a > b) ? 1 : (a < b) ? -1 : 0
}
