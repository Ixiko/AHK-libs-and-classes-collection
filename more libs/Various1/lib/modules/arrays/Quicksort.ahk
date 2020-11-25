class Quicksort {

	sort(anArray, compareFunc, left, right) {
		if (left < right) {
			pivotPoint := Arrays.Quicksort.divide(anArray, compareFunc
					, left, right)
			Arrays.Quicksort.sort(anArray, compareFunc, left, pivotPoint-1)
			Arrays.Quicksort.sort(anArray, compareFunc, pivotPoint+1, right)
		}
		return anArray
	}

	divide(anArray, compareFunc, left, right) {
		i := left
		j := right - 1
		pivotElement := anArray[right]
		loop {
			while (compareFunc.call(anArray[i], pivotElement)
					<= 0 && i < right) {
				i++
			}
			while (compareFunc.call(anArray[j], pivotElement)
					>= 0 && j > left) {
				j--
			}
			if (i < j) {
				Arrays.Quicksort.swap(anArray, i, j)
			} else {
				break
			}
		}
		Arrays.Quicksort.swap(anArray, i, right)
		return i
	}

	swap(anArray, pi, pj) {
		_temp := anArray[pi]
		anArray[pi] := anArray[pj]
		anArray[pj] := _temp
	}

	compareStrings(firstElement, secondElement) {
		scs := A_StringCaseSense
		StringCaseSense on
		firstElement .= "$"
		secondElement .= "$"
		result := (firstElement == secondElement ? 0
				: firstElement < secondElement ? -1
				: +1)
		StringCaseSense %scs%
		return result
	}
}
