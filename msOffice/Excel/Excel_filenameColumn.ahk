filenameColumn(xl, refColumns) {
	global
	Loop, % xl.ActiveSheet.UsedRange.Columns.Count ; Loop through used columns 
    	headers .= A_Index ": &" xl.Range(refColumns[A_Index] . 1).Value "|" ; Get column headers
	StringTrimRight, headers, headers, 1 ; Delete final |-character
	splashUI("r", "Which column contains your filenames?", headers)
	StringLeft, choice, choice, 1 ; Get numerical value of column choice 
	Return
}

