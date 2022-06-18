class biga {

	; --- Static Variables ---
	static throwExceptions := true
	static limit := -1

	static _guardedMethods := ["trim"]

	; --- Static Methods ---
	chunk(param_array,param_size:=1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := []
		param_array := this.clone(param_array)

		; create
		; keep working till the parameter array is empty
		while (param_array.count() > 0) {
			l_innerArr := []
			; fill the inner array to the max size of the size parameter
			loop, % param_size {
				; exit loop if there is nothing left in parameter array to work with
				if (param_array.count() == 0) {
					break
				}
				l_innerArr.push(param_array.removeAt(1))
			}
		l_array.push(l_innerArr)
		}
		return l_array
	}
	compact(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}
		l_array := []

		; create
		for key, value in param_array {
			if (value == "" || value == 0) {
				continue
			}
			l_array.push(value)
		}
		return l_array
	}
	concat(param_array,param_values*) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_array)

		; create
		for index, object in param_values {
			; push on any plain values
			if (!isObject(object)) {
				l_array.push(object)
			} else { ;push object values 1 level deep
				for index2, object2 in object {
					l_array.push(object2)
				}
			}
		}
		return l_array
	}
	depthOf(param_array,param_depth:=1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		for key, value in param_array {
			if (isObject(value)) {
				param_depth++
				param_depth := this.depthOf(value, param_depth)
			}
		}
		return param_depth
	}
	difference(param_array,param_values*) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_array)

		; create
		; loop all Variadic inputs
		for i, obj in param_values {
			for key, value in obj {
				loop {
					foundIndex := this.indexOf(l_array, value)
					if (foundIndex != -1) {
						l_array.removeAt(foundIndex)
					}
				} until (foundIndex == -1)
			}
		}
		return l_array
	}
	drop(param_array,param_n:=1) {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			l_array := strSplit(param_array)
		}

		; create
		loop, % param_n	{
			l_array.RemoveAt(1)
		}
		; return empty array if empty
		if (l_array.count() == 0) {
			return []
		}
		return l_array
	}
	dropRight(param_array,param_n:=1) {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			l_array := strSplit(param_array)
		}

		; create
		loop, % param_n	{
			l_array.removeAt(l_array.count())
		}
		; return empty array if empty
		if (l_array.count() == 0) {
			return []
		}
		return l_array
	}
	dropRightWhile(param_array,param_predicate:="__identity") {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}
		; validate
		; return empty array if empty
		if (param_array.count() == 0) {
			return []
		}

		l_array := this.reverse(this.cloneDeep(param_array))
		return this.reverse(this.dropWhile(l_array, param_predicate))
	}
	dropWhile(param_array,param_predicate:="__identity") {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}
		; validate
		; return empty array if empty
		if (param_array.count() == 0) {
			return []
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_array)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_array)
		}

		; create
		l_array := this.cloneDeep(param_array)
		l_droppableElements := 0
		for key, value in l_array {
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value, key, l_array)) {
					l_droppableElements++
				} else {
					break
				}
			}
		}
		if (l_droppableElements >= 1) {
			l_array.removeAt(1, l_droppableElements)
		}
		return l_array
	}
	fill(param_array,param_value:="",param_start:=1,param_end:=-1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_array)
		if (param_end == -1) {
			param_end := this.size(param_array)
		}

		; create
		for key, value in l_array {
			if (key >= param_start && key <= param_end) {
				l_array[key] := param_value
			}
		}
		return l_array
	}
	findIndex(param_array,param_predicate,param_fromindex:=1) {
		if (!isObject(param_array) || !this.isNumber(param_fromindex)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := []
		shorthand := this._internal_differenciateShorthand(param_predicate, param_array)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_array)
		}

		; create
		for key, value in param_array {
			if (param_fromIndex > A_Index) {
				continue
			}
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value, key, param_array)) {
					return key
				}
			}
		}
		return -1
	}
	findLastIndex(param_array,param_value,param_fromIndex:=1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; create
		l_array := this.reverse(this.cloneDeep(param_array))
		l_count := this.size(l_array)
		l_foundIndex := this.findIndex(l_array, param_value, param_fromIndex)

		if (l_foundIndex < 0) {
			return -1
		} else {
			finalIndex := l_count + 1
			finalIndex := finalIndex - l_foundIndex
		}
		return finalIndex
	}
	flatten(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := []

		; create
		for Index, Object in param_array {
			if (isObject(Object)) {
				for Index2, Object2 in Object {
					l_obj.push(Object2)
				}
			} else {
				l_obj.push(Object)
			}
		}
		return l_obj
	}
	flattenDeep(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_depth := this.depthOf(param_array)

		; create
		return this.flattenDepth(param_array, l_depth)
	}
	flattenDepth(param_array,param_depth:=1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := this.cloneDeep(param_array)

		; create
		loop, % param_depth {
			l_obj := this.flatten(l_obj)
		}
		return l_obj
	}
	fromPairs(param_pairs) {
		if (!isObject(param_pairs)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := {}

		; create
		for key, value in param_pairs {
			l_obj[value[1]] := value[2]
		}
		return l_obj
	}
	head(param_array) {

		; create
		return this.take(param_array)[1]
	}
	indexOf(param_array,param_value,fromIndex:=1) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_value)) {
			param_value := this._internal_MD5(param_value)
			param_array := this.map(param_array, this._internal_MD5)
		}

		;  create
		for index, value in param_array {
			if (A_Index < fromIndex) {
				continue
			}
			if (value != param_value) {
				continue
			} else {
				return index
			}
		}
		return -1
	}
	initial(param_array) {

		; prepare
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			l_array := StrSplit(param_array)
		}

		; create
		; return empty array if empty
		if (l_array.count() == 0) {
			return []
		}
		return % this.dropRight(l_array)

	}
	intersection(param_arrays*) {
		for key, value in param_arrays {
			if (!isObject(value)) {
				this._internal_ThrowException()
			}
		}

		; prepare
		tempArray := A.cloneDeep(param_arrays[1])
		param_arrays.removeAt(1) ;no need to check 1st array against itself, this does not mutate the input args
		l_array := []

		; create
		for key, value in tempArray { ;for each value in first array
			for key2, value2 in param_arrays { ;for each array sent to the method
				; search all arrays for value in first array
				if (this.indexOf(value2, value) != -1) {
					found := true
				} else {
					found := false
					break
				}
			}
			if (found && this.indexOf(l_array, value) == -1) {
				l_array.push(value)
			}
		}
		return l_array
	}
	join(param_array,param_sepatator:=",") {
		if (!isObject(param_array) || isObject(param_sepatator)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_array)

		; create
		for l_key, l_value in l_array {
			if (A_Index == 1) {
				l_string := "" l_value
				continue
			}
			l_string := l_string param_sepatator l_value
		}
		return l_string
	}
	last(param_array) {

		; prepare
		if (isObject(param_array)) {
			param_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			param_array := strSplit(param_array)
		}

		; create
		return param_array.pop()
	}
	lastIndexOf(param_array,param_value,param_fromIndex:=0) {
		if (param_fromIndex == 0) {
			param_fromIndex := param_array.count()
		}

		; create
		for Index, value in param_array {
			Index -= 1
			vNegativeIndex := param_array.count() - Index
			if (vNegativeIndex > param_fromIndex) { ;skip search
				continue
			}
			if (this.isEqual(param_array[vNegativeIndex], param_value)) {
				return vNegativeIndex
			}
		}
		return -1
	}
	nth(param_array,param_n:=1) {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_array)) {
			l_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			l_array := strSplit(param_array)
		}
		if (param_n == 0) {
			param_n := 1
		}

		; create
		if (l_array.count() < param_n) { ;return "" if n is greater than the array's size
			return ""
		}
		if (param_n > 0) {
			return l_array[param_n]
		}
		; return empty array if empty
		if (l_array.count() == 0) {
			return ""
		}
		; if called with negative n, call self with reversed array and positive number
		l_array := this.reverse(l_array)
		param_n := 0 - param_n
		return this.nth(l_array, param_n)
	}
	reverse(param_collection) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		l_collection := this.cloneDeep(param_collection)
		l_array := []

		; create
		while (l_collection.count() != 0) {
			l_array.push(l_collection.pop())
		}
		return l_array
	}
	slice(param_array,param_start:=1,param_end:=0) {
		if (!this.isNumber(param_start)) {
			this._internal_ThrowException()
		}
		if (!this.isNumber(param_end)) {
			this._internal_ThrowException()
		}

		; prepare
		if (this.isStringLike(param_array)) {
			param_array := strSplit(param_array)
		}
		if (param_end == 0) {
			param_end := param_array.count()
		}
		l_array := []

		; create
		for key, value in param_array {
			if (A_Index >= param_start && A_Index <= param_end) {
				l_array.push(value)
			}
		}
		return l_array
	}
	sortedIndex(param_array,param_value) {

		; prepare
		if (param_value < param_array[1]) {
			return 1
		}

		; create
		loop, % param_array.count() {
			if (param_array[A_Index] < param_value && param_value < param_array[A_Index+1]) {
				return A_Index + 1
			}
		}
		return param_array.count() + 1
	}
	sortedUniq(param_collection) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := []

		; create
		for key, value in param_collection {
			printedelement := this._printObj(param_collection[key])
			if (l_temp != printedelement) {
				l_temp := printedelement
				l_array.push(value)
			}
		}
		return l_array
	}
	tail(param_array) {

		; create
		return this.drop(param_array)
	}
	take(param_array,param_n:=1) {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_array)) {
			param_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			param_array := strSplit(param_array)
		}
		l_array := []

		; create
		for key, value in param_array {
			if (param_n < A_Index) {
				break
			}
			l_array.push(value)
		}
		; return empty array if empty
		if (l_array.count() == 0 || param_n == 0) {
			return []
		}
		return l_array
	}
	takeRight(param_array,param_n:=1) {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_array)) {
			param_array := this.clone(param_array)
		}
		if (this.isStringLike(param_array)) {
			param_array := strSplit(param_array)
		}
		l_array := []

		; create
		loop, % param_n	{
			if (param_array.count() == 0) {
				continue
			}
			vvalue := param_array.pop()
			l_array.push(vvalue)
		}
		; return empty array if empty
		if (l_array.count() == 0 || param_n == 0) {
			return []
		}
		return this.reverse(l_array)
	}
	union(param_arrays*) {

		; prepare
		l_array := []

		; create
		for key, Array in param_arrays {
			if (isObject(Array)) {
				l_array := this.concat(l_array, Array)
			} else {
				l_array.push(Array)
			}
		}
		return this.uniq(l_array)
	}
	uniq(param_collection) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		tempArray := []
		l_array := []

		; create
		for key, value in param_collection {
			l_printedElement := this._internal_MD5(param_collection[key])
			if (this.indexOf(tempArray, l_printedElement) == -1) {
				tempArray.push(l_printedElement)
				l_array.push(value)
			}
		}
		return l_array
	}
	without(param_array,param_values*) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_array)

		; create
		for i, val in param_values {
			while (foundindex := this.indexOf(l_array, val) != -1) {
				l_array.removeAt(foundindex)
			}
		}
		return l_array
	}
	zip(param_arrays*) {
		if (!isObject(param_arrays)) {
			this._internal_ThrowException()
		}
		l_array := []

		; loop all Variadic inputs
		for key, value in param_arrays {
			; for each value in the supplied set of array(s)
			for key2, value2 in value {
				loop, % value.count() {
					if (key2 == A_Index) {
						; create array if not encountered yet
						if (isObject(l_array[A_Index]) == false) {
							l_array[A_Index] := []
						}
						; push values onto the array for their position in the supplied arrays
						l_array[A_Index].push(value2)
					}
				}
			}
		}
		return l_array
	}
	zipObject(param_props,param_values) {
		if (!isObject(param_props)) {
			param_props := []
		}
		if (!isObject(param_values)) {
			param_values := []
		}

		l_obj := {}
		for key, value in param_props {
			l_obj[value] := param_values[A_Index]
		}
		return l_obj
	}
	count(param_collection,param_predicate,param_fromIndex:=1) {

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}

		; create
		l_count := 0
		if (this.isAlnum(param_collection) || this.isString(param_collection)) {
			; cut fromindex length off from start of string if specified fromIndex > 1
			if (param_fromIndex > 1) {
				param_collection := subStr(param_collection, param_fromIndex, strLen(param_collection))
			}
			; count by replacing all occurances
			strReplace(param_collection, param_predicate, "", l_count)
			return l_count
		}
		for key, value in param_collection {
			if (param_fromIndex > A_Index) {
				continue
			}
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value, key, param_collection) == true) {
					l_count++
					continue
				}
			}
			if (this.isEqual(value, param_predicate)) {
				l_count++
			}
		}
		return l_count
	}
	every(param_collection,param_predicate) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}

		; create
		for key, value in param_collection {
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value, key, param_collection) == true) {
					continue
				}
				return false
			}
		}
		return true
	}
	filter(param_collection,param_predicate:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}
		l_paramAmmount := param_predicate.maxParams
		if (l_paramAmmount == 3) {
			collectionClone := this.cloneDeep(param_collection)
		}
		l_array := []

		; create
		for key, value in param_collection {
			; functor
			if (this.isCallable(param_predicate)) {
				if (l_paramAmmount == 3) {
					if (param_predicate.call(value, key, collectionClone)) {
					l_array.push(value)
					continue
					}
				}
				if (param_predicate.call(value, key)) {
					l_array.push(value)
				}
			}
		}
		return l_array
	}
	find(param_collection,param_predicate,param_fromindex:=1) {
		if (!isObject(param_collection) || !this.isNumber(param_fromindex)) {
			this._internal_ThrowException()
		}

		; create
		foundIndex := this.findIndex(param_collection, param_predicate, param_fromindex)
		if (foundIndex != -1) {
			return param_collection[foundIndex]
		}
		return false
	}
	findLast(param_collection,param_predicate) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; create
		return this.find(this.reverse(param_collection), param_predicate)
	}
	forEach(param_collection,param_iteratee:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		if (!isFunc(param_iteratee)) {
			boundFunc := param_iteratee.bind(this)
		}
		if (l_paramAmmount == 3) {
			collectionClone := this.cloneDeep(param_collection)
		}

		; create
		; run against every value in the collection
		for key, value in param_collection {
			if (!boundFunc) { ; is property/string
				;nothing currently
			}
			if (!boundFunc.call(value, key, collectionClone)) {
				vIteratee := param_iteratee.call(value, key, collectionClone)
			}
			; exit iteration early by explicitly returning false
			if (vIteratee == false) {
				return param_collection
			}
		}
		return param_collection
	}
	groupBy(param_collection,param_iteratee:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_collection)
		if (shorthand != false) {
			param_iteratee := this._internal_createShorthandfn(param_iteratee, param_collection)
		}

		; create
		l_array := []
		for key, value in param_collection {
			vIteratee := 0

			; functor
			if (this.isCallable(param_iteratee) || !vIteratee) {
				vIteratee := param_iteratee.call(value)
			}
			; create array at key if not encountered yet
			if (!l_array.haskey(vIteratee)) {
				l_array[vIteratee] := []
			}
			; add value to this key
			l_array[vIteratee].push(value)
		}
		return l_array
	}
	includes(param_collection,param_value,param_fromIndex:=1) {
		if (!this.isNumber(param_fromIndex)) {
			this._internal_ThrowException()
		}

		; prepare
		if (isObject(param_value)) {
			param_value := this._internal_MD5(param_value)
			param_collection := this.map(param_collection, this._internal_MD5)
		}

		; create
		if (isObject(param_collection)) {
			for key, value in param_collection {
				if (param_fromIndex > A_Index) {
					continue
				}
				if (this.isEqual(value, param_value)) {
					return true
				}
			}
			return false
		} else {
			; RegEx
			if (RegEx_value := this._internal_JSRegEx(param_value)) {
				return RegExMatch(param_collection, RegEx_value, RE, param_fromIndex)
			}
			; Normal string search
			if (A_StringCaseSense == "On") {
				StringCaseSense := 1
			} else {
				StringCaseSense := 0
			}
			if (InStr(param_collection, param_value, StringCaseSense, param_fromIndex)) {
				return true
			} else {
				return false
			}
		}
	}
	keyBy(param_collection,param_iteratee:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_collection)
		if (shorthand == ".property") {
			param_iteratee := this._internal_createShorthandfn(param_iteratee, param_collection)
		}
		l_obj := {}

		; run against every value in the collection
		for key, value in param_collection {
			if (this.isCallable(param_iteratee)) {
				vIteratee := param_iteratee.call(value)
			}
			if (l_paramAmmount == 3) {
				if (!boundFunc.call(value, key, collectionClone)) {
					vIteratee := param_iteratee.call(value, key, collectionClone)
				}
			}
			objRawSet(l_obj, vIteratee, value)
		}
		return l_obj
	}
	map(param_collection,param_iteratee:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_collection)
		if (shorthand == ".property") {
			param_iteratee  := this.property(param_iteratee)
		}
		if (this.startsWith(param_iteratee.name, this.base.__Class ".")) { ;if starts with "biga."
			guarded := this.includes(this._guardedMethods, strSplit(param_iteratee.name, ".").2)
			param_iteratee := param_iteratee.bind(this)
		}
		l_collection := this.cloneDeep(param_collection)
		l_array := []

		; create
		for key, value in param_collection {
			if (param_iteratee == "__identity") {
				l_array.push(value)
				continue
			}
			; functor
			if (guarded) {
				l_array.push(param_iteratee.call(value))
				continue
			}
			if (this.isCallable(param_iteratee)) {
				l_array.push(param_iteratee.call(value, key, l_collection))
			}
		}
		return l_array
	}
	partition(param_collection,param_predicate) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		trueArray := []
		falseArray := []
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}

		; create
		for key, value in param_collection {
			if (param_predicate.call(value) == true) {
				trueArray.push(value)
			} else {
				falseArray.push(value)
			}
		}
		return [trueArray, falseArray]
	}
	reject(param_collection,param_predicate) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}
		l_array := []

		; create
		for key, value in param_collection {
			; functor
			; predefined !functor handling (slower as it .calls blindly)
			if (this.isCallable(param_predicate)) {
				if (!param_predicate.call(value)) {
					l_array.push(value)
				}
				continue
			}
		}
		return l_array
	}
	sample(param_collection) {
		if (!this.isStringLike(param_collection) && !isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		if (this.isStringLike(param_collection)) {
			param_collection := strSplit(param_collection)
		}
		if (param_collection.count() != param_collection.length()) {
			l_array := this.map(param_collection)
		} else {
			l_array := param_collection.clone()
		}

		; create
		randomIndex := this.random(1, l_array.count())
		return l_array[randomIndex]
	}
	sampleSize(param_collection,param_sampleSize:=1) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; return immediately if array is smaller than requested sampleSize
		if (param_sampleSize > param_collection.count()) {
			return param_collection
		}

		; prepare
		if (this.isStringLike(param_collection)) {
			param_collection := strSplit(param_collection)
		}
		l_order := A.shuffle(this.keys(param_collection))
		l_array := []

		; create
		loop, % param_sampleSize
		{
			ordervalue := l_order.pop()
			l_array.push(param_collection[ordervalue])
		}
		return l_array
	}
	shuffle(param_collection) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		l_array := this.clone(param_collection)

		; create
		l_index := l_array.count()
		loop, % l_index - 1 {
			random, randomIndex, 1, % l_index
			l_tempVar := l_array[l_index]
			l_array[l_index] := l_array[randomIndex]
			l_array[randomIndex] := l_tempVar
			l_index--
		}
		return l_array
	}
	size(param_collection) {

		; prepare
		if (param_collection.count() == 0) {
			return ""
		}

		; create
		if (max := this.max([param_collection.count(), param_collection.maxIndex()])) {
			return max
		}
		return strLen(param_collection)
	}
	some(param_collection,param_predicate) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}

		; create
		for key, value in param_collection {
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value, key, param_collection) = true) {
					return true
				}
			}
		}
		return false
	}
	sortBy(param_collection,param_iteratees:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}
		; prepare
		if (this.startsWith(param_iteratees.name, this.base.__Class ".")) { ;if starts with "biga."
			param_iteratees := param_iteratees.bind(this)
		}
		l_array := []

		; create
		; no param_iteratees
		if (param_iteratees == "__identity") {
			return this._internal_sort(param_collection)
		}
		; property
		if (this.isAlnum(param_iteratees)) {
			return this._internal_sort(param_collection, param_iteratees)
		}
		; own method or function
		if (this.isCallable(param_iteratees)) {
			for key, value in param_collection {
				l_array[A_Index] := {}
				l_array[A_Index].value := value
				l_array[A_Index].key := param_iteratees.call(value)
			}
			l_array := this._internal_sort(l_array, "key")
			return this.map(l_array, "value")
		}
		; shorthand/multiple keys
		if (isObject(param_iteratees)) {
			l_array := this.cloneDeep(param_collection)
			; sort the collection however many times is requested by the shorthand identity
			for key, value in param_iteratees {
				l_array := this._internal_sort(l_array, value)
			}
			return l_array
		}
		return -1
	}

	_internal_sort(param_collection,param_iteratees:="") {
		l_array := this.cloneDeep(param_collection)

		; associative arrays
		if (param_iteratees != "") {
			for Index, obj in l_array {
				out .= obj[param_iteratees] "+" Index "|" ; "+" allows for sort to work with just the value
				; out will look like:   value+index|value+index|
			}
			lastvalue := l_array[Index, param_iteratees]
		} else {
			; regular arrays
			for Index, obj in l_array {
				out .= obj "+" Index "|"
			}
			lastvalue := l_array[l_array.count()]
		}

		if (this.isNumber(lastvalue)) {
			sortType := "N"
		}
		stringTrimRight, out, out, 1 ; remove trailing |
		sort, out, % "D| " sortType
		arrStorage := []
		loop, parse, out, |
		{
			arrStorage.push(l_array[SubStr(A_LoopField, InStr(A_LoopField, "+") + 1)])
		}
		return arrStorage
	}
	; /--\--/--\--/--\--/--\--/--\
	; Internal functions
	; \--/--\--/--\--/--\--/--\--/

	_printObj(param_obj) {
		if (!isObject(param_obj)) {
			return """" param_obj """"
		}
		if this._internal_IsCircle(param_obj) {
			this._internal_ThrowException()
		}

		for key, value in param_obj {
			if key is not Number
			{
				Output .= """" . key . """:"
			} else {
				Output .= key . ":"
			}
			if (isObject(value)) {
				Output .= "[" . this._printObj(value) . "]"
			} else if value is not number
			{
				Output .= """" . value . """"
			} else {
				Output .= value
			}
			Output .= ", "
		}
		StringTrimRight, OutPut, OutPut, 2
		return OutPut
	}
	print(param_obj) {
		if (!isObject(param_obj)) {
			return """" param_obj """"
		}
		if this._internal_IsCircle(param_obj) {
			this._internal_ThrowException()
		}

		return this._printObj(param_obj)
	}

	_internal_MD5(param_string, case := 0) {
		if (isObject(param_string)) {
			param_string := this.print(param_string)
		}
		static MD5_DIGEST_LENGTH := 16
		hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
		, VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
		, DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", param_string, "UInt", StrLen(param_string))
		, DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
		loop % MD5_DIGEST_LENGTH {
			o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
		}
		DllCall("FreeLibrary", "Ptr", hModule)
		return o
	}

	_internal_JSRegEx(param_string) {
		if (!this.isString(param_string) && !this.isAlnum(param_string)) {
			this._internal_ThrowException()
		}
		if (this.startsWith(param_string, "/") && this.startsWith(param_string, "/", StrLen(param_string))) {
			return SubStr(param_string, 2, StrLen(param_string) - 2)
		}
		return false
	}

	_internal_differenciateShorthand(param_shorthand,param_objects:="") {
		if (this.startsWith(param_shorthand.name, this.base.__Class ".")) { ;if starts with "biga."
			return "_classMethod"
		}
		if (isObject(param_shorthand) && !this.isCallable(param_shorthand)) {
			if (param_shorthand.maxIndex() != param_shorthand.count()) {
				return ".matches"
			}
			return ".matchesProperty"
		}
		if (this.isStringLike(param_shorthand) && isObject(param_objects)) {
			for key, value in param_objects {
				if (value.hasKey(param_shorthand)) {
					return ".property"
				}
			}
		}
		return false
	}

	_internal_createShorthandfn(param_shorthand,param_objects) {
		shorthand := this._internal_differenciateShorthand(param_shorthand, param_objects)
		if (shorthand == "_classMethod") {
			return param_shorthand.bind(this)
		}
		if (shorthand == ".matches") {
			return this.matches(param_shorthand)
		}
		if (shorthand == ".matchesProperty") {
			return this.matchesProperty(param_shorthand[1], param_shorthand[2])
		}
		if (shorthand == ".property") {
			return this.property(param_shorthand)
		}
	}

	_internal_ThrowException() {
		if (this.throwExceptions == true) {
			throw Exception("Type Error", -2)
		}
	}

	_internal_inStr(param_haystack,param_needle,param_fromIndex:=1,param_occurance:=1) {
		; used inplace of inStr to follow A_StringCaseSense
		if (A_StringCaseSense == "On") {
			StringCaseSense := 1
		} else {
			StringCaseSense := 0
		}
		if (position := inStr(param_collection, param_value, StringCaseSense, param_fromIndex, param_occurance)) {
			return position
		} else {
			return false
		}
	}

	isFalsey(param) {
		if (isObject(param)) {
			return false
		}
		if (param == "" || param == 0) {
			return true
		}
		return false
	}
	isStringLike(param) {
		if (isObject(param)) {
			return false
		}
		if (this.isString(param) || this.isAlnum(param)) {
			return true
		}
		return false
	}
	clone(param_value) {

		if (isObject(param_value)) {
			return param_value.Clone()
		} else {
			return param_value
		}
	}
	cloneDeep(param_array) {

		Objs := {}
		Obj := param_array.Clone()
		Objs[&param_array] := Obj ; Save this new array
		for key, value in Obj {
			if (isObject(value)) ; if it is a subarray
				Obj[key] := Objs[&value] ; if we already know of a refrence to this array
				? Objs[&value] ; Then point it to the new array
				: this.clone(value, Objs) ; Otherwise, clone this sub-array
		}
		return Obj
	}
	isAlnum(param) {
		if (isObject(param)) {
			return false
		}
		if param is alnum
		{
			return true
		}
		return false
	}
	isArray(param) {
		if (param.GetCapacity()) {
			return true
		}
		return false
	}
	isBoolean(param) {

		if this.isEqual(param, 1) {
			return true
		}
		if this.isEqual(param, 0) {
			return true
		}
		return false
	}
	isCallable(param) {
		fn := numGet(&(_ := Func("InStr").bind()), "Ptr")
		return (isFunc(param) || (isObject(param) && (numGet(&param, "Ptr") = fn)))
	}
	isEqual(param_value,param_other*) {

		; prepare
		if (isObject(param_value)) {
			l_array := []
			param_value := this._printObj(param_value)
			loop, % param_other.count() {
				l_array.push(this._printObj(param_other[A_Index]))
			}
		} else {
			l_array := this.cloneDeep(param_other)
		}

		; create
		loop, % l_array.count() {
			if (param_value != l_array[A_Index]) { ; != follows StringCaseSense
				return false
			}
		}
		return true
	}
	isFloat(param) {
		if (isObject(param)) {
			return false
		}
		if param is float
		{
			return true
		}
		return false
	}
	isInteger(param) {
		if param is integer
		{
			if (!this.isString(param)) {
				return true
			}
		}
		return false
	}
	isMatch(param_object,param_source) {
		for key, value in param_source {
			if (param_object[key] == value) {
				continue
			} else {
				return false
			}
		}
		return true
	}
	isNumber(param) {
		if (isObject(param)) {
			return false
		}
		if param is number
		{
			return true
		}
		return false
	}
	isObject(param) {
		if (isObject(param)) {
			return true
		}
		return false
	}
	isString(param) {
		if (isObject(param)) {
			return false
		}
		if (ObjGetCapacity([param], 1) == "") {
			return false
		}
		return true
	}
	isUndefined(param_value) {
		if (param_value == "") {
			return true
		}
		return false
	}
	toString(param_value) {

		if (isObject(param_value)) {
			return this.join(param_value, ",")
		} else {
			return "" param_value
		}
	}
	add(param_augend,param_addend) {
		if (!this.isNumber(param_augend) || !this.isNumber(param_addend)) {
			this._internal_ThrowException()
		}

		; create
		return param_augend + param_addend
	}
	ceil(param_number,param_precision:=0) {
		if (!this.isNumber(param_number) || !this.isNumber(param_precision)) {
			this._internal_ThrowException()
		}

		if (param_precision == 0) { ; regular ceil
			return ceil(param_number)
		}

		l_offset := 0.5 / (10**param_precision)
		if (param_number < 0 && param_precision >= 1) {
			l_offset /= 10 ; adjust offset for negative numbers and positive param_precision
		}
		if (param_precision >= 1) {
			l_decChar := strlen( substr(param_number, instr(param_number, ".") + 1) ) ; count the number of decimal characters
			l_sum := format("{:." this.max([l_decChar, param_precision]) + 1 "f}", param_number + l_offset)
		} else {
			l_sum := param_number + l_offset
		}
		l_sum := trim(l_sum, "0") ; trim zeroes
		l_value := (SubStr(l_sum, 0) = "5") && param_number != l_sum ? SubStr(l_sum, 1, -1) : l_sum ; if last char is 5 then remove it unless it is part of the original string
		return Round(l_value, param_precision)
	}
	divide(param_dividend,param_divisor) {
		if (!this.isNumber(param_dividend) || !this.isNumber(param_divisor)) {
			this._internal_ThrowException()
		}

		; create
		return param_dividend / param_divisor
	}
	floor(param_number,param_precision:=0) {
		if (!this.isNumber(param_number) || !this.isNumber(param_precision)) {
			this._internal_ThrowException()
		}

		if (param_precision == 0) { ; regular floor
			return floor(param_number)
		}

		l_offset := -0.5 / (10**param_precision)
		if (param_number < 0 && param_precision >= 1) {
			l_offset /= 10 ; adjust offset for negative numbers and positive param_precision
		}
		if (param_precision >= 1) {
			l_decChar := strlen( substr(param_number, instr(param_number, ".") + 1) ) ; count the number of decimal characters
			l_sum := format("{:." this.max([l_decChar, param_precision]) + 1 "f}", param_number + l_offset)
		} else {
			l_sum := param_number + l_offset
		}
		l_sum := trim(l_sum, "0") ; trim zeroes
		l_value := (SubStr(l_sum, 0) = "5") && param_number != l_sum ? SubStr(l_sum, 1, -1) : l_sum ; if last char is 5 then remove it unless it is part of the original string
		return Round(l_value, param_precision)
	}
	max(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		l_max := ""
		for key, value in param_array {
			if (l_max < value || this.isUndefined(l_max)) {
				l_max := value
			}
		}
		return l_max
	}
	mean(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		l_sum := 0
		for key, value in param_array {
			l_sum += value
		}
		return l_sum / this.size(param_array)
	}
	meanBy(param_array,param_iteratee:="__identity") {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		if (!isFunc(param_iteratee)) {
			boundFunc := param_iteratee.bind(this)
		}
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_array)
		if (shorthand != false) {
			param_iteratee := this._internal_createShorthandfn(param_iteratee, param_array)
		}

		; prepare
		if (l_paramAmmount == 3) {
			arrayClone := this.cloneDeep(param_array)
		}
		l_total := 0

		; run against every value in the array
		for key, value in param_array {
			; functor
			if (this.isCallable(param_iteratee)) {
				l_iteratee := param_iteratee.call(value)
			}
			l_total += l_iteratee
		}
		return l_total / param_array.count()
	}
	min(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		l_min := ""
		for key, value in param_array {
			if (l_min > value || this.isUndefined(l_min)) {
				l_min := value
			}
		}
		return l_min
	}
	multiply(param_multiplier,param_multiplicand) {
		if (!this.isNumber(param_multiplier) || !this.isNumber(param_multiplicand)) {
			this._internal_ThrowException()
		}

		; create
		return param_multiplier * param_multiplicand
	}
	round(param_number,param_precision:=0) {
		if (!this.isNumber(param_number) || !this.isNumber(param_precision)) {
			this._internal_ThrowException()
		}

		; create
		return round(param_number, param_precision)
	}
	subtract(param_minuend,param_subtrahend) {
		if (!this.isNumber(param_minuend) || !this.isNumber(param_subtrahend)) {
			this._internal_ThrowException()
		}

		; create
		param_minuend -= param_subtrahend
		return param_minuend
	}
	sum(param_array) {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		vSum := 0
		for key, value in param_array {
			vSum += value
		}
		return vSum
	}
	sumBy(param_array,param_iteratee:="__identity") {
		if (!isObject(param_array)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_array)
		if (shorthand = ".property") {
			param_iteratee := this._internal_createShorthandfn(param_iteratee, param_array)
		}
		l_total := 0

		; run against every value in the array
		for key, value in param_array {
			; functor
			if (this.isCallable(param_iteratee)) {
				l_iteratee := param_iteratee.call(value)
			}
			l_total += l_iteratee
		}
		return l_total
	}
	clamp(param_number,param_lower,param_upper) {
		if (!this.isNumber(param_number) || !this.isNumber(param_lower) || !this.isNumber(param_upper)) {
			this._internal_ThrowException()
		}

		; check the lower bound
		if (param_number < param_lower) {
			param_number := param_lower
		}
		; check the upper bound
		if (param_number > param_upper) {
			param_number := param_upper
		}
		return param_number
	}
	inRange(param_number,param_lower,param_upper) {
		if (!this.isNumber(param_number) || !this.isNumber(param_lower) || !this.isNumber(param_upper)) {
			this._internal_ThrowException()
		}

		; prepare
		if (param_lower > param_upper) {
			l_temp := param_lower
			param_lower := param_upper
			param_upper := l_temp
		}

		; check the bounds
		if (param_number > param_lower && param_number < param_upper) {
			return true
		}
		return false
	}
	random(param_lower:=0,param_upper:=1,param_floating:=false) {
		if (!this.isNumber(param_lower) || !this.isNumber(param_upper) || !this.isNumber(param_floating)) {
			this._internal_ThrowException()
		}

		; prepare
		if (param_lower > param_upper) {
			l_temp := param_lower
			param_lower := param_upper
			param_upper := l_temp
		}
		if (param_floating) {
			param_lower += 0.0
			param_upper += 0.0
		}

		; create
		random, vRandom, param_lower, param_upper
		return vRandom
	}
	defaults(param_object,param_sources*) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := this.clone(param_object)
		param_sources := this.reverse(param_sources)

		; create
		for Index, Object in param_sources {
			for key, value in Object {
				if (!l_obj.haskey(key)) { ; if the key is not already in use
					l_obj[key] := value
				}
			}
		}
		return l_obj
	}
	findKey(param_collection,param_predicate,param_fromindex:=1) {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
		if (shorthand != false) {
			param_predicate := this._internal_createShorthandfn(param_predicate, param_collection)
		}

		; create
		for key, value in param_collection {
			if (param_fromindex > A_Index) {
				continue
			}
			; functor
			if (this.isCallable(param_predicate)) {
				if (param_predicate.call(value)) {
					return key
				}
			}
		}
		return false
	}
	invert(param_object) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := this.cloneDeep(param_object)
		l_newObj := {}

		; create
		for key, value in l_obj {
			l_newObj[value] := key
		}
		return l_newObj
	}
	invertBy(param_object,param_iteratee:="__identity") {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := this.cloneDeep(param_object)
		l_newObj := {}

		; create
		for key, value in l_obj {
			if (this.isCallable(param_iteratee)) {
				vkey := param_iteratee.call(value)
			} else {
				vkey := value
			}

			if (!isObject(l_newObj[vkey])) {
				l_newObj[vkey] := []
			}
			l_newObj[vkey].push(key)
		}
		return l_newObj
	}
	keys(param_object) {

		; prepare
		if (!isObject(param_object)) {
			param_object := StrSplit(param_object)
		}
		l_returnkeys := []

		; create
		for key, _ in param_object {
			l_returnkeys.push(key)
		}
		return l_returnkeys
	}
	mapKeys(param_object,param_iteratee:="__identity") {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_object)
		if (shorthand == ".property") {
			param_iteratee := this.property(param_iteratee)
		}
		if (this.startsWith(param_iteratee.name, this.base.__Class ".")) { ;if starts with "biga."
			param_iteratee := param_iteratee.bind(this)
		}
		l_object := this.cloneDeep(param_object)
		l_array := {}

		; create
		for key, value in l_object {
			if (param_iteratee == "__identity") {
				l_array[value] := A_Index
				continue
			}
			; functor
			if (this.isCallable(param_iteratee)) {
				l_array[param_iteratee.call(value, key, l_object)] := A_Index
			}
		}
		return l_array
	}
	mapValues(param_object,param_iteratee:="__identity") {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		shorthand := this._internal_differenciateShorthand(param_iteratee, param_object)
		if (shorthand == ".property") {
			param_iteratee := this.property(param_iteratee)
		}
		if (this.startsWith(param_iteratee.name, this.base.__Class ".")) { ;if starts with "biga."
			param_iteratee := param_iteratee.bind(this)
		}
		l_object := this.cloneDeep(param_object)
		l_array := {}

		; create
		for key, value in l_object {
			if (param_iteratee == "__identity") {
				l_array[key] := value
				continue
			}
			; functor function
			if (this.isCallable(param_iteratee)) {
				l_array[key] := param_iteratee.call(value, key, l_object)
			}
		}
		return l_array
	}
	merge(param_collections*) {
		if (!isObject(param_collections)) {
			this._internal_ThrowException()
		}

		result := param_collections[1]
		for index, obj in param_collections {
			if(A_Index = 1) {
				continue
			}
			result := this.internal_Merge(result, obj)
		}
		return result
	}

	internal_Merge(param_collection1, param_collection2) {
		if(!isObject(param_collection1) && !isObject(param_collection2)) {
			; if only one OR the other exist, display them together.
			if(param_collection1 = "" || param_collection2 = "") {
				return param_collection2 param_collection1
			}
			; return only one if they are the same
			if (param_collection1 = param_collection2)
				return param_collection1
			; otherwise, return them together as an object.
			return [param_collection1, param_collection2]
		}

		; initialize an associative array
		combined := {}

		for key, value in param_collection1 {
			combined[key] := this.internal_Merge(value, param_collection2[key])
		}
		for key, value in param_collection2 {
			if(!combined.haskey(key)) {
				combined[key] := value
			}
		}
		return combined
	}
	omit(param_object,param_paths) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := this.cloneDeep(param_object)

		; create
		if (isObject(param_paths)) {
			for key, value in param_paths {
				l_obj.delete(value)
			}
		} else {
			l_obj.delete(param_paths)
		}
		return  l_obj
	}
	pick(param_object,param_paths) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		; prepare
		l_obj := {}

		; create
		if (isObject(param_paths)) {
			for key, value in param_paths {
				vvalue := this.internal_property(value, param_object)
				l_obj[value] := vvalue
			}
		} else {
			vvalue := this.internal_property(param_paths, param_object)
			l_obj[param_paths] := vvalue
		}
		return l_obj
	}
	toPairs(param_object) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		l_array := []
		for key, value in param_object {
			l_array.push([key, value])
		}
		return l_array
	}
	camelCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; prepare
		l_arr := this.compact(this.split(param_string, "/[_ -]+/"))
		l_head := this.toLower(this.head(l_arr))
		; create
		l_tail := this.join(this.map(this.tail(l_arr), this.startCase), "")

		return l_head l_tail
	}
	endsWith(param_string,param_needle,param_fromIndex:=0) {
		if (!this.isString(param_string) || !this.isString(param_needle) || !this.isNumber(param_fromIndex)) {
			this._internal_ThrowException()
		}

		; prepare defaults
		if (param_fromIndex == 0) {
			param_fromIndex := StrLen(param_string)
		}
		if (StrLen(param_needle) > 1) {
			param_fromIndex := StrLen(param_string) - StrLen(param_needle) + 1
		}

		; create
		l_endChar := SubStr(param_string, param_fromIndex, StrLen(param_needle))
		if (this.isEqual(l_endChar, param_needle)) {
			return true
		}
		return false
	}
	escape(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; prepare
		HTMLmap := [["&","&amp;"], ["<","&lt;"], [">","&gt;"], ["""","&quot;"], ["'","&#39;"]]

		for key, value in HTMLmap {
			element := value
			param_string := StrReplace(param_string, element.1, element.2, , -1)
		}
		return param_string
	}
	kebabCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; create
		l_string := this.startCase(param_string)
		l_string := StrReplace(l_string, " ", "-")
		return l_string
	}
	lowerCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; create
		l_string := this.startCase(param_string)
		l_string := this.toLower(this.trim(l_string))
		return l_string
	}
	pad(param_string:="",param_length:=0,param_chars:=" ") {
		if (!this.isStringLike(param_string) || !this.isNumber(param_length) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; prepare
		if (param_length <= strLen(param_string)) {
			return param_string
		}
		param_length := param_length - strLen(param_string)
		l_start := this.floor(param_length / 2)
		l_end := this.ceil(param_length / 2)

		; create
		l_start := this.padStart("", l_start, param_chars)
		l_end := this.padEnd("", l_end, param_chars)
		return l_start param_string l_end
	}
	padEnd(param_string:="",param_length:=0,param_chars:=" ") {
		if (!this.isStringLike(param_string) || !this.isNumber(param_length) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; prepare
		if (param_length <= strLen(param_string)) {
			return param_string
		}

		; create
		l_pad := this.slice(param_chars)
		l_string := param_string
		while (strLen(l_string) < param_length) {
			l_pos++
			if (l_pos > l_pad.count()) {
				l_pos := 1
			}
			l_string .= l_pad[l_pos]
		}
		return l_string
	}
	padStart(param_string:="",param_length:=0,param_chars:=" ") {
		if (!this.isStringLike(param_string) || !this.isNumber(param_length) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; prepare
		if (param_length <= strLen(param_string)) {
			return param_string
		}

		; create
		l_pad := this.slice(param_chars)
		while (strLen(param_string) + strLen(l_padding) < param_length) {
			l_pos++
			if (l_pos > l_pad.count()) {
				l_pos := 1
			}
			l_padding .= l_pad[l_pos]
		}
		return l_padding . param_string
	}
	parseInt(param_string:="0") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; prepare
		l_int := this.trimStart(param_string, " 0_")

		; create
		if (this.size(l_int) == 0 && inStr(param_string, "0")) {
			return 0
		}
		if (this.isNumber(l_int)) {
			return l_int
		}
		l_int := this.replace(l_int, "/\D+/")
		if (this.isNumber(l_int)) {
			return l_int
		}
		return ""
	}
	repeat(param_string,param_number:=1) {
		if (!this.isString(param_string) || (!this.isNumber(param_number))) {
			this._internal_ThrowException()
		}

		if (param_number == 0) {
			return ""
		}
		return StrReplace(Format("{:0" param_number "}", 0), "0", param_string)
	}
	replace(param_string:="",param_needle:="",param_replacement:="") {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_needle) || !this.isStringLike(param_replacement)) {
			this._internal_ThrowException()
		}

		; prepare
		l_string := param_string

		; create
		if (l_needle := this._internal_JSRegEx(param_needle)) {
			return  RegExReplace(param_string, l_needle, param_replacement, , this.limit)
		}
		output := StrReplace(l_string, param_needle, param_replacement, , this.limit)
		return output
	}
	snakeCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; create
		l_string := this.startCase(param_string)
		l_string := StrReplace(l_string, " ", "_")
		return l_string
	}
	split(param_string:="",param_separator:=",",param_limit:=0) {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_separator) || !this.isNumber(param_limit)) {
			this._internal_ThrowException()
		}

		; prepare inputs if regex detected
		if (this._internal_JSRegEx(param_separator)) {
			param_string := this.replace(param_string, param_separator, ",")
			param_separator := ","
		}

		; create
		oSplitArray := strSplit(param_string, param_separator)
		if (!param_limit) {
			return oSplitArray
		} else {
			oReducedArray := []
			loop, % param_limit {
				if (A_Index <= oSplitArray.count()) {
					oReducedArray.push(oSplitArray[A_Index])
				}
			}
		}
		return oReducedArray
	}
	startCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; create
		l_string := this.replace(param_string, "/[_ -]/", " ")

		; add space before each capitalized character
		RegExMatch(l_string, "O)([A-Z])", RE_Match)
		if (RE_Match.count()) {
			loop, % RE_Match.count() {
				l_string := % SubStr(l_string, 1, RE_Match.Pos(A_Index) - 1) " " SubStr(l_string, RE_Match.Pos(A_Index))
			}
		}
		; Split the string into array and Titlecase each element in the array
		l_array := StrSplit(l_string, " ")
		loop, % l_array.count() {
			l_string := l_array[A_Index]
			StringUpper, l_string, l_string, T
			l_array[A_Index] := l_string
		}
		; join the string back together from Titlecased array elements
		l_string := this.join(l_array, " ")
		l_string := trim(l_string)
		return l_string
	}
	startsWith(param_string,param_needle,param_fromIndex:=1) {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_needle) || !this.isNumber(param_fromIndex)) {
			this._internal_ThrowException()
		}

		; create
		l_startString := subStr(param_string, param_fromIndex, strLen(param_needle))
		; check if substring matches
		if (this.isEqual(l_startString, param_needle)) {
			return true
		}
		return false
	}
	toLower(param_string) {
		if (!this.isString(param_string)) {
			this._internal_ThrowException()
		}

		; create
		StringLower, OutputVar, param_string
		return  OutputVar
	}
	toUpper(param_string) {
		if (!this.isString(param_string)) {
			this._internal_ThrowException()
		}

		; create
		StringUpper, OutputVar, param_string
		return  OutputVar
	}
	trim(param_string,param_chars:="") {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; create
		if (param_chars == "") {
			return trim(param_string)
		} else {
			; replace starting characters
			l_string := this.trimStart(param_string, param_chars)
			; replace ending characters
			l_string := this.trimEnd(l_string, param_chars)
			return l_string
		}
	}
	trimEnd(param_string,param_chars:="") {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; create
		if (param_chars = "") {
			l_string := param_string
			return  regexreplace(l_string, "(\s+)$") ;trim ending whitespace
		} else {
			l_array := StrSplit(param_chars, "")
			for key, value in l_array {
				if (this.includes(value, "/[a-zA-Z0-9]/")) {
					l_removechars .= value
				} else {
					l_removechars .= "\" value
				}
			}
			; replace ending characters
			l_string := this.replace(param_string, "/([" l_removechars "]+)$/", "")
			return l_string
		}
	}
	trimStart(param_string,param_chars:="") {
		if (!this.isStringLike(param_string) || !this.isStringLike(param_chars)) {
			this._internal_ThrowException()
		}

		; create
		if (param_chars = "") {
			return  regexreplace(param_string, "^(\s+)") ;trim beginning whitespace
		} else {
			l_array := StrSplit(param_chars, "")
			for key, value in l_array {
				if (this.includes(value, "/[a-zA-Z0-9]/")) {
					l_removechars .= value
				} else {
					l_removechars .= "\" value
				}
			}
			; replace leading characters
			l_string := this.replace(param_string, "/^([" l_removechars "]+)/", "")
			return l_string
		}
	}
	truncate(param_string,param_options:="") {
		if (!this.isString(param_string)) {
			this._internal_ThrowException()
		}

		; prepare
		if (!isObject(param_options)) {
			param_options := {}
			param_options.length := 30
		}
		if (!param_options.haskey("omission")) {
			param_options.omission := "..."
		}

		; check that length is even worth working on, skip if separator is defined
		if (strLen(param_string) < param_options.length && !param_options.separator) {
			return param_string
		}

		; create
		; cut length of the string by character count + the omission's length
		l_string := subStr(param_string, 1, param_options.length)

		; Regex separator
		if (this._internal_JSRegEx(param_options.separator)) {
			param_options.separator := this._internal_JSRegEx(param_options.separator)
		}
		; handle string or Regex seperator
		if (param_options.separator) {
			return  RegexReplace(l_string, "^(.{1," param_options.length "})" param_options.separator ".*$", "$1") param_options.omission
		}

		; omission
		if (strLen(l_string) < strLen(param_string)) {
			l_string := subStr(l_string, 1, (strLen(l_string) - strLen(param_options.omission) + 1))
			l_string := l_string . param_options.omission
		}
		return l_string
	}
	unescape(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; prepare
		HTMLmap := [["&","&amp;"], ["<","&lt;"], [">","&gt;"], ["""","&quot;"], ["'","&#39;"]]

		for key, value in HTMLmap {
			element := value
			param_string := StrReplace(param_string, element.2, element.1, , -1)
		}
		return param_string
	}
	upperCase(param_string:="") {
		if (!this.isStringLike(param_string)) {
			this._internal_ThrowException()
		}

		; create
		l_string := this.startCase(param_string)
		l_string := this.toupper(this.trim(l_string))
		return l_string
	}
	words(param_string,param_pattern:="/[^\W]+/") {
		if (!this.isString(param_string) || !this.isString(param_pattern)) {
			this._internal_ThrowException()
		}

		l_string := param_string
		l_array := []
		if (l_needle := this._internal_JSRegEx(param_pattern)) {
			param_pattern := l_needle
		}
		l_needle := "O)" param_pattern
		while(RegExMatch(l_string, l_needle, RE_Match)) {
			tempString := RE_Match.value()
			l_array.push(tempString)
			l_string := SubStr(l_string, RE_Match.Pos()+RE_Match.Len())
		}
		return l_array
	}
	constant(param_value) {

		boundFunc := ObjBindMethod(this, "_internal_constant", param_value)
		return boundFunc
	}

	_internal_constant(param_value) {
		return param_value
	}
	matches(param_source) {
		if (!isObject(param_source)) {
			this._internal_ThrowException()
		}

		boundFunc := ObjBindMethod(this, "internal_matches", param_source)
		return boundFunc
	}

	internal_matches(param_matches,param_itaree) {
		for key, value in param_matches {
			if (param_matches[key] != param_itaree[key]) {
				return false
			}
		}
		return true
	}
	matchesProperty(param_path,param_srcvalue) {
		if (!this.isStringLike(param_srcvalue)) {
			this._internal_ThrowException()
		}

		; create the property fn
		fnProperty := this.property(param_path)
		; create the fn
		boundFunc := ObjBindMethod(this, "_internal_matchesProperty", fnProperty, param_srcvalue)
		return boundFunc
	}

	_internal_matchesProperty(param_property,param_matchvalue,param_itaree) {
		itareevalue := param_property.call(param_itaree)
		; msgbox, % "comparing " this._printObj(param_matchvalue) " to " this._printObj(itareevalue) " from(" this._printObj(param_itaree) ")"
		if (!this.isUndefined(itareevalue)) {
			if (itareevalue = param_matchvalue) {
				return true
			}
		}
		return false
	}
	property(param_source) {

		; prepare
		if (this.includes(param_source, ".")) {
			param_source := strSplit(param_source, ".")
		}

		; create the fn
		if (isObject(param_source)) {
			keyArray := []
			for key, value in param_source {
				keyArray.push(value)
			}
			boundFunc := ObjBindMethod(this, "internal_property", keyArray)
			return boundFunc
		} else {
			boundFunc := ObjBindMethod(this, "internal_property", param_source)
		return boundFunc
		}
	}

	internal_property(param_property,param_itaree) {
		if (isObject(param_property)) {
			for key, value in param_property {
				if (param_property.count() == 1) {
					; msgbox, % "dove deep and found: " ObjRawGet(param_itaree, value)
					return  ObjRawGet(param_itaree, value)
				} else if (param_itaree.haskey(value)){
					rvalue := this.internal_property(this.tail(param_property), param_itaree[value])
				}
			}
			return rvalue
		}
		return  param_itaree[param_property]
	}
	times(param_n,param_iteratee:="__identity") {
		if (!this.isNumber(param_n)) {
			this._internal_ThrowException()
		}

		; prepare
		if (this.startsWith(param_iteratee.name, this.base.__Class ".")) { ;if starts with "biga."
			guarded := this.includes(this._guardedMethods, strSplit(param_iteratee.name, ".").2)
			param_iteratee := param_iteratee.bind(this)
		}
		shorthand := this._internal_differenciateShorthand(param_iteratee)
		if (shorthand != false) {
			param_iteratee := this._internal_createShorthandfn(param_iteratee)
		}
		l_array := []

		; create
		loop, % param_n {
			l_array.push(param_iteratee.call(A_Index))
		}
		return l_array
	}
	first(param_array) {

		; create
		return this.take(param_array)[1]
	}
	each(param_collection,param_iteratee:="__identity") {
		if (!isObject(param_collection)) {
			this._internal_ThrowException()
		}

		; prepare
		if (!isFunc(param_iteratee)) {
			boundFunc := param_iteratee.bind(this)
		}
		if (l_paramAmmount == 3) {
			collectionClone := this.cloneDeep(param_collection)
		}

		; create
		; run against every value in the collection
		for key, value in param_collection {
			if (!boundFunc) { ; is property/string
				;nothing currently
			}
			if (!boundFunc.call(value, key, collectionClone)) {
				vIteratee := param_iteratee.call(value, key, collectionClone)
			}
			; exit iteration early by explicitly returning false
			if (vIteratee == false) {
				return param_collection
			}
		}
		return param_collection
	}
	entries(param_object) {
		if (!isObject(param_object)) {
			this._internal_ThrowException()
		}

		l_array := []
		for key, value in param_object {
			l_array.push([key, value])
		}
		return l_array
	}
}

class AHK extends biga {

}