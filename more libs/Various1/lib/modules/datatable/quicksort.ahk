class Quicksort {

	sort(listToSort, listWithColumnNumbersToSort
			, leftBoundary, rightBoundary) {
		if (leftBoundary < rightBoundary) {
			pivot := DataTable.Quicksort.divide(listToSort
					, listWithColumnNumbersToSort, leftBoundary, rightBoundary)
			DataTable.Quicksort.sort(listToSort
					, listWithColumnNumbersToSort, leftBoundary, pivot-1)
			DataTable.Quicksort.sort(listToSort
					, listWithColumnNumbersToSort, pivot+1, rightBoundary)
		}
	}

	divide(listToSort, listWithColumnNumbersToSort
			, leftBoundary, rightBoundary) {
		left := leftBoundary
		right := rightBoundary - 1
		pivot := listToSort[rightBoundary]
		loop {
			left := this.searchAtRightForElementGreaterThanPivot(listToSort
					, listWithColumnNumbersToSort, left, pivot, rightBoundary)
			right := this.searchAtLeftForElementGreaterThanPivot(listToSort
					, listWithColumnNumbersToSort, right, pivot, leftBoundary)
			if (left < right) {
				DataTable.swap(listToSort, left, right)
			}
		} until (left >= right)
		DataTable.swap(listToSort, left, rightBoundary)
		return left
	}

	searchAtRightForElementGreaterThanPivot(listToSort
			, listWithColumnNumbersToSort, left, pivot, rightBoundary) {
		while (DataTable.compare(listWithColumnNumbersToSort
				, listToSort[left], pivot) <= 0 && left < rightBoundary) {
			left++
		}
		return left
	}

	searchAtLeftForElementGreaterThanPivot(listToSort
			, listWithColumnNumbersToSort, right, pivot, leftBoundary) {
		while (DataTable.compare(listWithColumnNumbersToSort
				, listToSort[right], pivot) >= 0 && right > leftBoundary) {
			right--
		}
		return right
	}
}
