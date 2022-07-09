; arr - Array object with values of any type to sort.
; cmpFunc - <optional> Comparison function, as normaly takes two arguments
;	(array values). It should return 0 on equal,
;	>0 if first is greater and <0 if first is less than second.
;	You can exchange it to make sorting in descending order.
; If no cmpFunc is passed, simple numeric comparison a > b is performed.

QuickSort(arr, cmpFunc:="") {
	if (!arr is Array) {
		throw Error("QuickSort works only on Array objects")
	}
	if (!cmpFunc) {
		cmpFunc := __SimpleCmp
	}
	continuousArr := []
	for it in arr {
		continuousArr.Push(it)
	}
	return __QuickSortRange(continuousArr, 1, arr.Length, cmpFunc)
}

QuickSortByProperty(arr, propertyName) {
	cmpClosure(a,b) {
		return __SimpleCmp(a.%propertyName%, b.%propertyName%)
	}
	cmpFunc := cmpClosure
	return QuickSort(arr, cmpFunc)
}

__SimpleCmp(a, b) {
	return (a > b) ? 1 : (a < b) ? -1 : 0
}

__QuickSortRange(arr, beginIndex, endIndex, cmpFunc){

    if (beginIndex >= endIndex) {
        return arr
    }

    part := __QuickSortPartition(arr, beginIndex, endIndex, cmpFunc)
    __QuickSortRange(arr, beginIndex, part - 1, cmpFunc)
    __QuickSortRange(arr, part + 1, endIndex, cmpFunc)

	return arr
}

__QuickSortPartition(arr, beginIndex, endIndex, cmpFunc)
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

        if(leftIndex < rightIndex)
        {
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
