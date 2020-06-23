class DataTable {

	requires() {
		return [Ansi, Arrays, String, Object]
	}

	static COL_ALIGN_LEFT :=  0
	static COL_ALIGN_RIGHT :=  1
	static COL_ALIGN_CENTER :=  2
	static COL_RESIZE_TRUNCATE :=  4
	static COL_RESIZE_TRUNCATE_RIGHT :=  4
	static COL_RESIZE_TRUNCATE_LEFT :=  8
	static COL_RESIZE_TRUNCATE_MIDDLE := 16
	static COL_RESIZE_USE_LARGEST_DATA := 32
	static COL_RESIZE_SHOW_ELLIPSIS := 64

	static SORT_SELECTIONSORT := 1
	static SORT_QUICKSORT := 2

	static COMPARE_EQUALS := 0
	static COMPARE_GREATER_THAN := +1
	static COMPARE_LESS_THAN := -1

	tableColumns := []
	aMaxColValue := []
	tableRows := []
	iSortAlgorithm := DataTable.SORT_QUICKSORT

	#Include %A_LineFile%\..\modules\datatable
	#Include column.ahk
	#Include selectionsort.ahk
	#Include quicksort.ahk

	defineColumn(column) {
		if (!Object.instanceOf(column, "DataTable.Column")) {
			throw Exception("The passed object is not of type "
					. "'DataTable.Column'")
		}
		this.tableColumns.push(column)
		this.aMaxColValue.push(0)
		return this.tableColumns.maxIndex()
	}

	addData(rowsWithColumns*) {
		for rowIndex, columns in rowsWithColumns {
			if (!IsObject(columns)) {
				throw Exception("Argument " rowIndex " - Array required: "
						. columns)
			}
			if (columns.maxIndex() != this.tableColumns.maxIndex()) {
				throw Exception("Argument " rowIndex " - "
						. this.tableColumns.maxIndex()
						. " element(s) required but got " columns.maxIndex())
			}
			this.appendRowAndInsertColumnData(columns)
		}
		return this.tableRows.maxIndex()
	}

	appendRowAndInsertColumnData(columns) {
		rowIndex := 1 + (this.tableRows.maxIndex() != ""
				? this.tableRows.maxIndex()
				: 0)
		while (A_Index <= columns.maxIndex()) {
			columnData := columns[A_Index]
			this.tableRows[rowIndex, A_Index] := columnData
			this.checkIfThisColumnHasTheWidestData(rowIndex, A_Index)
		}
	}

	checkIfThisColumnHasTheWidestData(rowIndex, columnIndex) {
		columnData := this.getCellContent(rowIndex, columnIndex)
		columnDataLength := StrLen(columnData)
		if ((this.tableColumns[columnIndex].flags
				& DataTable.COL_RESIZE_USE_LARGEST_DATA)
				&& columnDataLength > this.aMaxColValue[columnIndex]) {
			this.aMaxColValue[columnIndex] := columnDataLength
		}
	}

	getTable() {
		table := []
		loop % this.tableRows.maxIndex() {
			row := []
			rowIndex := A_Index
			loop % this.tableRows[rowIndex].maxIndex() {
				cellData := this.getCellContent(rowIndex, A_Index)
				row.push(this.renderColumn(cellData, A_Index))
			}
			table.push(row)
		}
		return table
	}

	getTableAsString(textBetweenColumns=" "
			, textInFrontOfFirstColumn="", textAfterLastColumn="") {
		tableAsString := ""
		loop % this.tableRows.maxIndex() {
			columns := []
			rowIndex := A_Index
			maxLines := this.determineRowHeight(rowIndex)
			columns := this.insertColumnWithCorrectHeight(columns
					, textInFrontOfFirstColumn, maxLines)
			loop % this.tableRows[rowIndex].maxIndex() {
				if (A_Index > 1) {
					columns := this.insertColumnWithCorrectHeight(columns
							, textBetweenColumns, maxLines)
				}
				columnWidth := this.getColumnWidth(A_Index)
				cellData := this.getCellContent(rowIndex, A_Index)
				columnData := this.renderColumn(cellData, A_Index)
				columns.push(this
						.expandToNeccesaryRowHeight(columnData, maxLines
						, " ".repeat(columnWidth)))
			}
			columns := this.insertColumnWithCorrectHeight(columns
					, textAfterLastColumn, maxLines)
			tableAsString .= this.concatLinesOfEveryColumn(columns, maxLines)
		}
		return tableAsString
	}

	concatLinesOfEveryColumn(columns, maxLines) {
		lines := ""
		loop %maxLines% {
			rowLine := A_Index
			line := ""
			loop % columns.maxIndex() {
				line .= columns[A_Index, rowLine]
			}
			lines .= line "`n"
		}
		return lines
	}

	determineRowHeight(rowIndex) {
		maxLines := 0
		loop % this.tableRows[rowIndex].maxIndex() {
			columnData := this.getCellContent(rowIndex, A_Index)
			lines := StrSplit(this.renderColumn(columnData, A_Index), "`n")
			if (lines.maxIndex() > maxLines) {
				maxLines := lines.maxIndex()
			}
		}
		return maxLines
	}

	insertColumnWithCorrectHeight(columns, textToInsert, maxLines) {
		if (textToInsert) {
			columns.push(this.expandToNeccesaryRowHeight(textToInsert
					, maxLines))
		}
		return columns
	}

	expandToNeccesaryRowHeight(what, height, whatElse="") {
		if (whatElse == "") {
			whatElse := what
		}
		return StrSplit(what.expand("`n" whatElse, height), "`n")
	}

	getTableForConsoleOutput(textBetweenColumns=" "
			, textInFrontOfFirstColumn="", textAfterLastColumn="") {
		table := []
		loop % this.tableRows.maxIndex() {
			row := []
			rowIndex := A_Index
			row.push(textInFrontOfFirstColumn)
			loop % this.tableRows[rowIndex].maxIndex() {
				cellData := this.getCellContent(rowIndex, A_Index)
				columnData := this.renderColumn(cellData, A_Index)
				if (A_Index > 1) {
					row.push(textBetweenColumns)
				}
				if (this.tableColumns[A_Index].attributes = "") {
					row.push(columnData)
				} else {
					graphicAttributes := Arrays
							.toString(this.tableColumns[A_Index].attributes
							, ";")
					row.push(Ansi.setGraphic(graphicAttributes)
							. columnData
							. Ansi.reset())
				}
			}
			row.push(textAfterLastColumn "`n")
			table.push(row)
		}
		return table
	}

	getColumn(columnData, columnIndex) {
		OutputDebug %A_ThisFunc% is deprecated: Use DataTable.renderColumn() instead ; ahklint-ignore: W002
		return this.renderColumn(columnData, columnIndex)
	}

	renderColumn(columnData, columnIndex) {
		column := this.tableColumns[columnIndex]
		if (Object.instanceOf(column, "DataTable.Column.Wrapped")) {
			columnData := columnData.wrap(column.width,,,, true)
		} else {
			columnWidth := ((column.flags
					& DataTable.COL_RESIZE_USE_LARGEST_DATA)
					? this.aMaxColValue[columnIndex]
					: column.width)
			if (columnWidth > 0 && StrLen(columnData) != columnWidth) {
				columnData := this.reformatColumnData(columnData, columnWidth
						, column.flags)
			}
		}
		return columnData
	}

	reformatColumnData(columnData, columnWidth, flags) {
		if (StrLen(columnData) > columnWidth) {
			columnData := this.handleColumnDataOverflow(columnData, columnWidth
					, flags)
		} else if (StrLen(columnData) < columnWidth) {
			columnData := this.handleColumnDataUnderflow(columnData, columnWidth
					, flags)
		}
		return columnData
	}

	handleColumnDataOverflow(columnData, columnWidth, flags) {
		ellipsis := ""
		if (flags & DataTable.COL_RESIZE_SHOW_ELLIPSIS) {
			columnWidth -= 3
			ellipsis := "..."
		}
		if (flags & DataTable.COL_RESIZE_TRUNCATE_LEFT) {
			columnData := ellipsis columnData.subStr(1 - columnWidth)
		} else if (flags & DataTable.COL_RESIZE_TRUNCATE_MIDDLE) {
			middleOfColumnAt := Ceil(columnWidth / 2)
			halfSizeOfTheColumn := columnWidth - middleOfColumnAt
			columnData := columnData.subStr(1, middleOfColumnAt)
					. ellipsis
					. columnData.subStr(1 - halfSizeOfTheColumn)
		} else {
			columnData := columnData.subStr(1, columnWidth)
					. ellipsis
		}
		return columnData
	}

	handleColumnDataUnderflow(columnData, columnWidth, flags) {
		if (flags & DataTable.COL_ALIGN_RIGHT) {
			columnData := columnData.padLeft(columnWidth)
		} else if (flags & DataTable.COL_ALIGN_CENTER) {
			columnData := columnData.padCenter(columnWidth)
		} else {
			columnData := columnData.padRight(columnWidth)
		}
		return columnData
	}

	getCellContent(rowIndex, columnIndex) {
		return this.tableRows[rowIndex, columnIndex]
	}

	getColumnWidth(colIndex) {
		return (this.aMaxColValue[colIndex] > 0
				? this.aMaxColValue[colIndex]
				: this.tableColumns[colIndex].width)
	}

	swap(listToSort, anIndex, anotherIndex) {
		saveElement := listToSort[anIndex]
		listToSort[anIndex] := listToSort[anotherIndex]
		listToSort[anotherIndex] := saveElement
	}

	compare(listWithColumnNumbersToSort, aRow, anotherRow) {
		resultOfComparison := DataTable.COMPARE_EQUALS
		loop % listWithColumnNumbersToSort.maxIndex() {
			columnNumberToCompare := listWithColumnNumbersToSort[A_Index]
			resultOfComparison := this.compareTwoColumns(aRow, anotherRow
					, columnNumberToCompare)
			if (resultOfComparison != 0) {
				break
			}
		}
		return resultOfComparison
	}

	ascendingSortRequested(columnNumberToSort) {
		return (columnNumberToSort > 0)
	}

	compareTwoColumns(aRow, anotherRow, columnNumberToCompare) {
		columnNumber := Abs(columnNumberToCompare)
		resultOfComparison := this.compareValues(aRow[columnNumber]
				, anotherRow[columnNumber])
		return (this.ascendingSortRequested(columnNumberToCompare))
				? resultOfComparison
				: resultOfComparison * -1
	}

	compareValues(aValue, anotherValue) {
		return (aValue < anotherValue ? DataTable.COMPARE_LESS_THAN
				: aValue > anotherValue ? DataTable.COMPARE_GREATER_THAN
				: DataTable.COMPARE_EQUALS)
	}

	setSortAlgorithm(algorithm) {
		if (algorithm = DataTable.SORT_SELECTIONSORT
				|| algorithm = DataTable.SORT_QUICKSORT) {
			this.iSortAlgorithm := algorithm
		} else {
			throw Exception("Invalid sort algorithm: " algorithm)
		}
	}

	sort(sortOrderByColumnIndex*) {
		sortOrder := []
		if (sortOrderByColumnIndex.maxIndex() == "") {
			sortOrder.push(1)
		} else {
			while (A_Index <= sortOrderByColumnIndex.maxIndex()) {
				sortOrder.push(sortOrderByColumnIndex[A_Index])
			}
		}
		if (this.iSortAlgorithm = DataTable.SORT_QUICKSORT) {
			DataTable.Quicksort.sort(this.tableRows, sortOrder
					, this.tableRows.minIndex(), this.tableRows.maxIndex())
		} else if (this.iSortAlgorithm = DataTable.SORT_SELECTIONSORT) {
			DataTable.Selectionsort.sort(this.tableRows, sortOrder)
		} else {
			throw Exception("Invalid sort algorithm set: " this.iSortAlgorithm)
		}
	}
}
