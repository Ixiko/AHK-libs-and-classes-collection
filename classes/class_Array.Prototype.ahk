;===== Functions ==========;

Array(_parameters*) {
	r := {"base": __Array}

	Loop, % _parameters.Length()
		r[A_Index - 1] := _parameters[A_Index]

	Return (r)
}

;===== Classes ==========;

Class __Array {  ;https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/prototype

	;===== *** Modified propertie(s):

	/*
		Array.Length[ := Integer]

		Description:
			Reflects the number of elements in an array.
	*/
	Length[] {
		Get {
			Return (Round(this.MaxIndex() + 1))
		}

		Set {
			If (value ~= "^([0-9]+)$") {  ;Does not support negative integers.
				o := value - (s := this.Length)

				Loop, % Abs(o)
					(o < 0) ? this.RemoveAt(s - A_Index) : this[s + (A_Index - 1)] := "undefined"  ;["" || """""" || "undefined"].
			}

			Return (this.Length)
		}
	}

	;===== *** Modified method(s):

	/*
		Array.Push(_element1[, _element2[, ...[, _elementN]]])

		Description:
			Adds one or more elements to the end of an array and returns the new length of the array.

		Note:
			See known issue on Concat().
	*/
	Push(_elements*) {
		s := this.Length, m := Round(_elements.MaxIndex())

		If (m)
			this.InsertAt(s, _elements*)

		Return (s + m)
	}

	/*
		Array.Pop()

		Description:
			Removes the last element from an array and returns that element.
	*/
	Pop() {
		m := this.MaxIndex()

		Return (m ? this.RemoveAt(m) : "undefined")  ;["" || """""" || "undefined"].
	}

	;===== *** Custom propertie(s):

	/*
		Array.IsArray

		Description:
			Returns true for all arrays.
	*/
	IsArray[] {
		Get {
			Return (1)
		}
	}

	;===== *** Custom method(s):

	/*
		Array.Sum([_offset[, _start[, _end]]])

		Description:
			Sums all number values in an array and optionally offsets the total.
	*/
	Sum(_offset := 0, _start := 0, _end := "undefined") {
		s := this.Length
			, _start := (_start >= 0 ? Min(s, _start) : Max((s + _start), 0))

		Loop, % (_end != "undefined" ? _end >= 0 ? Min(s, _end) : Max(s + _end, 0) : s) - _start
			_offset += this[_start]*(!IsNaN(this[_start++]))

		Return (_offset)
	}

	/*
		Array.Swap(_index1, _index2)

		Description:
			Swap any two elements in an array.
	*/
	Swap(_index1, _index2) {
		t := this[_index1]
		this[_index1] := this[_index2]
		this[_index2] := t

		Return (this)
	}

	;===== *** Mutator method(s):

	;*** CopyWithin()

	/*
		Array.Fill([_value[, _start[, _end]]])

		Description:
			Fills all the elements of an array from a start index to an end index with a static value.
	*/
	Fill(_value := "undefined", _start := 0, _end := "undefined") {  ;_value := ["" || """""" || "undefined"].
		s := this.Length
			, _start := (_start >= 0 ? Min(s, _start) : Max((s + _start), 0))

		Loop, % (_end != "undefined" ? _end >= 0 ? Min(s, _end) : Max(s + _end, 0) : s) - _start
			this[_start++] := _value

		Return (this)
	}

	/*
		Array.Reverse()

		Description:
			Reverses the order of the elements of an array in place — the first becomes the last, and the last becomes the first.
	*/
	Reverse() {
		s := this.Length

		Loop, % s
			this.InsertAt(s - 1, this.RemoveAt(s - A_Index))

		Return (this)
	}

	/*
		Array.Shift()

		Description:
			Removes the first element from an array and returns that element.
	*/
	Shift() {
		Return (this.Length ? this.RemoveAt(0) : "undefined")  ;["" || """""" || "undefined"].
	}

	/*
		Array.Sort([_compareFunction])

		Description:
			Sorts the elements of an array in place and returns the array.

		Note:
			Use "StringCaseSense, [On || Off]" with the default _compareFunction to control case sensetivity.
	*/
	Sort(_compareFunction := "DefaultSort") {
		s := this.Length

		While (c != 0) {
			c := 0

			Loop, % s - 1
				If (%_compareFunction%(this[A_Index - 1], this[A_Index]) > 0)
					this.Swap(A_Index - (c := 1), A_Index)
			s--
		}

		Return (this)
	}

	/*
		Array.Splice(_start[, _count[, _element1[, _element2[, ...[, _elementN]]]]])

		Description:
			Adds and/or removes elements from an array.
	*/
	Splice(_start, _count := "undefined", _elements*) {
		s := this.Length, m := _elements.MaxIndex()
			, _start := (_start >= 0 ? Min(s, _start) : Max((s + _start), 0)), r := []

		Loop, % (_count != "undefined" ? Max(s <= _start + _count ? s - _start : _count, 0) : m ? 0 : s)
			r.InsertAt(A_Index - 1, this.RemoveAt(_start))

		If (m)
			this.InsertAt(_start, _elements*)

		return (r)
	}

	/*
		Array.UnShift(_element1[, _element2[, ...[, _elementN]]])

		Description:
			Adds one or more elements to the front of an array and returns the new length of the array.
	*/
	UnShift(_elements*) {
		If (_elements.MaxIndex())
			this.InsertAt(0, _elements*)

		Return (this.Length)
	}

	;===== *** Accessor method(s):

	/*
		Array.Concat(_element1[, _element2[, ...[, _elementN]]])

		Description:
			Returns a new array that is this array joined with other array(s) and/or value(s).

		Known issue:
			The temporary A_Args array used as a parameter does not have a base class to manipulate and as such is beyond my ability to address. Just be careful in how you pass objects to this function. i.e

			array := [[1, {2: [2]}, 3], [4, 5, 6], [7, 8, 9]]
			MsgBox, % [].Concat(array*).Join(", ")

			will skip over the first index. Use "[].Concat(array)" instead and manually strip nested arrays.
	*/
	Concat(_elements*) {
		r := this  ;Referencing the same object, this is consistent with MDN. Replace with "this.Clone()" if it is not to you liking.

		For i, v in _elements {
			If (v.IsArray)
				Loop, % v.Length
					r.Push(v[A_Index - 1])

			Else
				r.Push(v)  ;Catch for object/string or number element(s).
		}

		Return (r)
	}

	/*
		Array.Includes(_needle[, _start])

		Description:
			Determines whether an array contains a certain element, returning true or false as appropriate.
	*/
	Includes(_needle, _start := 0) {
		Return (this.IndexOf(_needle, _start) != -1)
	}

	/*
		Array.IndexOf(_needle[, _start])

		Description:
			Returns the first (least) index of an element within the array equal to the specified value, or -1 if none is found.
	*/
	IndexOf(_needle, _start := 0) {
		s := this.Length
			, _start := (_start >= 0 ? Min(s, _start) : Max((s + _start), 0))

		Loop, % s - _start {
			If (this[_start] = _needle)
				Return (_start)

			_start++
		}

		Return (-1)
	}

	/*
		Array.Join([_deliminator])

		Description:
			Joins all elements of an array into a string.
	*/
	Join(_deliminator := ",") {
		m := Round(this.MaxIndex())

		For i, v in this
			r .= (v.IsArray ? v.Join(_deliminator) : IsObject(v) ? "[object Object]" : v) . (i < m ? _deliminator : "")  ;Uses recursion to handle nested arrays.

		Return (r)
	}

	/*
		Array.LastIndexOf(_needle[, _start])

		Description:
			Returns the last (greatest) index of an element within the array equal to the specified value, or -1 if none is found.
	*/
	LastIndexOf(_needle, _start := -1) {
		s := this.Length
			, _start := (_start >= 0 ? Min(s - 1, _start) : Max(s + _start, -1))

		While (_start > -1) {
			If (this[_start] = _needle)
				Return (_start)

			_start--
		}

		Return (-1)
	}

	/*
		Array.Slice([_start[, _end]])

		Description:
			Extracts a section of an array and returns a new array.
	*/
	Slice(_start := 0, _end := "undefined") {
		s := this.Length
			, _start := (_start >= 0 ? Min(s, _start) : Max((s + _start), 0)), r := []

		Loop, % (_end != "undefined" ? _end >= 0 ? Min(s, _end) : Max(s + _end, 0) : s) - _start
			r.Push(this[_start++])

		Return (r)
	}

	;*** ToSource()

	/*
		Array.ToString()

		Description:
			Returns a string representing the array and its elements.
	*/
	ToString() {
		m := Round(this.MaxIndex())

		For i, v in this
			r .= (v.IsArray ? v.ToString() : IsObject(v) ? "[object Object]" : v) . (i < m ? "," : "")

		Return (r)
	}

	;*** ToLocaleString()

	;===== *** Iteration method(s):

	;*** Entries()

	/*
		Array.Every(Func("Function"))

		Description:
			Returns true if every element in this array satisfies the provided testing function.
	*/
	Every(_callback) {
		For i, v in this
			If (!_callback.Call(v, i, this))
				Return (0)

		Return (1)
	}

	/*
		Array := Array.Filter(Func("Function"))

		Description:
			Creates a new array with all of the elements of this array for which the provided filtering function returns true.
	*/
	Filter(_callback) {
		r := []

		For i, v in this
			If (_callback.Call(v, i, this))
				r.Push(v)

		Return (r)
	}

	/*
		Array.Find(Func("Function"))

		Description:
			Returns the found value in the array, if an element in the array satisfies the provided testing function or undefined if not found.
	*/
	Find(_callback) {
		For i, v in this
			If (_callback.Call(v, i, this))
				Return (v)

		Return ("undefined")  ;["" || """""" || "undefined"].
	}

	/*
		Array.FindIndex(Func("Function"))

		Description:
			Returns the found index in the array, if an element in the array satisfies the provided testing function or -1 if not found.
	*/
	FindIndex(_callback) {
		For i, v in this
			If (_callback.Call(v, i, this))
				Return (i)

		Return (-1)
	}

	/*
		Array.ForEach(Func("Function"))

		Description:
			Calls a function for each element in the array.
	*/
	ForEach(_callback) {
		For i, v in this
			this[i] := _callback.Call(v, i, this)
	}

	;*** Keys()

	/*
		Array.Map(Func("Function"))

		Description:
			Creates a new array with the results of calling a provided function on every element in this array.
	*/
	Map(_callback) {
		r := []

		For i, v in this
			r[i] := (_callback.Call(v, i, this))

		Return (r)
	}

	;*** Reduce()

	;*** ReduceRight()

	/*
		Array.Some(Func("Function"))

		Description:
			Returns true if at least one element in this array satisfies the provided testing function.
	*/
	Some(_callback) {

		For i, v in this
			If (_callback.Call(v, i, this))
				Return (1)

		Return (0)
	}

	;*** Values()
}

;===== General:
DefaultSort(_element1, _element2) {
	Return (_element1 < _element2 ? -1 : _element1 > _element2 ? 1 : 0)
}

;===== Strings:
TrimWhitespace(_element) {
	Return (RegExReplace(_element, "^\s*(\S(.*\S)?)\s*$", "$1"))
}

;===== Numbers:
IsNaN(_element) {
	Return (((_element + 0.0) ~= "^([-+]?[.]?[0-9]+([.][0-9]+)*([eE][+]?[0-9]+)*)$") != 1)
}

IsEven(_element) {
	Return ((_element & 1) == 0)
}

IsPrime(_element) {
	Loop, % Floor(Sqrt(_element))
		If (A_Index > 1 && Mod(_element, A_Index) == 0)
			Return (0)

	Return (1)
}

ToBinary(_element) {
	While (_element)
		r := (_element & 1) . r, _element >>= 1

	Return (r)
}

TrimTrailingZeros(_element) {
	Return (RegExReplace(_element, "\.?0*$"))
}
