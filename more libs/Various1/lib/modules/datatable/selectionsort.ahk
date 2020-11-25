class Selectionsort {

	sort(listToSort, listWithColumnNumbersToSort) {
		n := listToSort.maxIndex()
		l := 1
		while (l < n) {
			m := l
			i := l + 1
			while (i <= n) {
				if (Datatable.compare(listWithColumnNumbersToSort
						, listToSort[i], listToSort[m]) < 0) {
					m := i
				}
				i++
			}
			Datatable.swap(listToSort, m, l)
			l++
		}
	}
}
