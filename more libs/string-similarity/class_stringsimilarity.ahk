Class stringsimilarity {

	; --- Static Methods ---

	compareTwoStrings(param_string1, param_string2) {
		;Sørensen-Dice coefficient
		savedBatchLines := A_BatchLines
		setBatchLines, -1

		vCount := 0
		;make default key value 0 instead of a blank string
		l_arr := {base:{__Get:Func("Abs").Bind(0)}}
		loop, % vCount1 := StrLen(param_string1) - 1 {
			l_arr["z" SubStr(param_string1, A_Index, 2)]++
		}
		loop, % vCount2 := StrLen(param_string2) - 1 {
			if (l_arr["z" SubStr(param_string2, A_Index, 2)] > 0) {
				l_arr["z" SubStr(param_string2, A_Index, 2)]--
				vCount++
			}
		}
		vSDC := round((2 * vCount) / (vCount1 + vCount2), 2)
		;round to 0 if less than 0.005
		if (!vSDC || vSDC < 0.005) {
			return 0
		}
		; return 1 if rounded to 1.00
		if (vSDC = 1) {
			return 1
		}
		setBatchLines, % savedBatchLines
		return vSDC
	}


	findBestMatch(param_string, param_array) {
		savedBatchLines := A_BatchLines
		setBatchLines, -1
		if (!IsObject(param_array)) {
			setBatchLines, % savedBatchLines
			return false
		}

		l_arr := []

		; Score each option and save into a new array
		for key, value in param_array {
			l_arr[A_Index, "rating"] := this.compareTwoStrings(param_string, value)
			l_arr[A_Index, "target"] := value
		}

		;sort the rated array
		l_sortedArray := this._internal_Sort2DArrayFast(l_arr, "rating")
		; create the besMatch property and final object
		l_object := {bestMatch:l_sortedArray[1].clone(), ratings:l_sortedArray}
		setBatchLines, % savedBatchLines
		return l_object
	}


	simpleBestMatch(param_string, param_array) {
		if (!IsObject(param_array)) {
			return false
		}
		l_highestRating := 0

		for key, value in param_array {
			l_rating := this.compareTwoStrings(param_string, value)
			if (l_highestRating < l_rating) {
				l_highestRating := l_rating
				l_bestMatchValue := value
			}
		}
		return l_bestMatchValue
	}



	_internal_Sort2DArrayFast(param_arr, param_key, Ascending := True)
	{
		for index, obj in param_arr {
			out .= obj[param_key] "+" index "|"
			; "+" allows for sort to work with just the value
			; out will look like:   value+index|value+index|
		}

		v := param_arr[param_arr.minIndex(), param_key]
		if v is number
			type := " N "
		out := subStr(out, 1, strLen(out) -1) ; remove trailing |
		sort, out, % "D| " type  " R"
		l_arr := []
		loop, parse, out, |
			l_arr.push(param_arr[subStr(A_LoopField, inStr(A_LoopField, "+") + 1)])
		return l_arr
	}
}
