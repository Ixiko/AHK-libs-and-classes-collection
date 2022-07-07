class ngram {

	; --- Static Methods ---
	generate(param_array, param_size:=1, param_separator:="") {
		if (!isObject(param_array)) {
			param_array := strSplit(param_array, param_separator)
		}
		ngrams := []
		if (isObject(param_size)) {
			for key, value in param_size {
				ngrams.push(this.generate(param_array, value, param_separator))
			}
		} else {
			loop, % param_array.count() {
				thisIteration := this._slice(param_array, A_Index, A_Index + param_size - 1)
				if (thisIteration.count() == param_size) {
					ngrams.push(thisIteration)
				}
			}
		}
		return ngrams
	}

	_slice(param_array, param_start, param_end) {
		l_array := []
		for key, value in param_array {
			if (A_Index >= param_start && A_Index <= param_end) {
				l_array.push(value)
			}
		}
		return l_array
	}
}
