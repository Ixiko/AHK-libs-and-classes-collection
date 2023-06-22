/*
	Name: Array.ahk
	Version 0.3 (24.03.23)
	Created: 27.08.22
	Author: Descolada

	Description:
	A compilation of useful array methods.

    Array.Slice(start:=1, end:=0, step:=1)  => Returns a section of the array from 'start' to 'end', 
        optionally skipping elements with 'step'.
    Array.Swap(a, b)                        => Swaps elements at indexes a and b.
    Array.Map(func, arrays*)                => Applies a function to each element in the array.
    Array.ForEach(func)                     => Calls a function for each element in the array.
    Array.Filter(func)                      => Keeps only values that satisfy the provided function
    Array.Reduce(func, initialValue?)       => Applies a function cumulatively to all the values in 
        the array, with an optional initial value.
    Array.IndexOf(value, start:=1)          => Finds a value in the array and returns its index.
    Array.Find(func, &match?, start:=1)     => Finds a value satisfying the provided function and returns the index.
        match will be set to the found value. 
    Array.Reverse()                         => Reverses the array.
    Array.Count(value)                      => Counts the number of occurrences of a value.
    Array.Sort(OptionsOrCallback?, Key?)    => Sorts an array, optionally by object values.
    Array.Shuffle()                         => Randomizes the array.
    Array.Join(delim:=",")                  => Joins all the elements to a string using the provided delimiter.
    Array.Flat()                            => Turns a nested array into a one-level array.
    Array.Extend(arr)                       => Adds the contents of another array to the end of this one.
*/

Array.Prototype.base := Array2

class Array2 {
    /**
     * Returns a section of the array from 'start' to 'end', optionally skipping elements with 'step'.
     * Modifies the original array.
     * @param start Optional: index to start from. Default is 1.
     * @param end Optional: index to end at. Can be negative. Default is 0 (includes the last element).
     * @param step Optional: an integer specifying the incrementation. Default is 1.
     * @returns {Array}
     */
    static Slice(start:=1, end:=0, step:=1) {
        len := this.Length, i := start < 1 ? len + start : start, j := Min(end < 1 ? len + end : end, len), r := [], reverse := False
        if len = 0
            return []
        if i < 1
            i := 1
        if step = 0
            Throw Error("Slice: step cannot be 0",-1)
        else if step < 0 {
            while i >= j {
                r.Push(this[i])
                i += step
            }
        } else {
            while i <= j {
                r.Push(this[i])
                i += step
            }
        }
        return this := r
    }
    /**
     * Swaps elements at indexes a and b
     * @param a First elements index to swap
     * @param b Second elements index to swap
     * @returns {Array}
     */
    static Swap(a, b) {
        temp := this[b]
        this[b] := this[a]
        this[a] := temp
        return this
    }
    /**
     * Applies a function to each element in the array (mutates the array).
     * @param func The mapping function that accepts one argument.
     * @param arrays Additional arrays to be accepted in the mapping function
     * @returns {Array}
     */
    static Map(func, arrays*) {
        if !HasMethod(func)
            throw ValueError("Map: func must be a function", -1)
        for i, v in this {
            bf := func.Bind(v?)
            for _, vv in arrays
                bf := bf.Bind(vv.Has(i) ? vv[i] : unset)
            try bf := bf()
            this[i] := bf
        }
        return this
    }
    /**
     * Applies a function to each element in the array.
     * @param func The callback function with arguments Callback(value[, index, array]).
     * @returns {Array}
     */
    static ForEach(func) {
        if !HasMethod(func)
            throw ValueError("ForEach: func must be a function", -1)
        for i, v in this
            func(v, i, this)
        return this
    }
    /**
     * Keeps only values that satisfy the provided function
     * @param func The filter function that accepts one argument.
     * @returns {Array}
     */
    static Filter(func) {
        if !HasMethod(func)
            throw ValueError("Filter: func must be a function", -1)
        r := []
        for v in this
            if func(v)
                r.Push(v)
        return this := r
    }
    /**
     * Applies a function cumulatively to all the values in the array, with an optional initial value.
     * @param func The function that accepts two arguments and returns one value
     * @param initialValue Optional: the starting value. If omitted, the first value in the array is used.
     * @returns {func return type}
     * @example
     * [1,2,3,4,5].Reduce((a,b) => (a+b)) ; returns 15 (the sum of all the numbers)
     */
    static Reduce(func, initialValue?) {
        if !HasMethod(func)
            throw ValueError("Reduce: func must be a function", -1)
        len := this.Length + 1
        if len = 1
            return initialValue ?? ""
        if IsSet(initialValue)
            out := initialValue, i := 0
        else
            out := this[1], i := 1
        while ++i < len {
            out := func(out, this[i])
        }
        return out
    }
    /**
     * Finds a value in the array and returns its index.
     * @param value The value to search for.
     * @param start Optional: the index to start the search from. Default is 1.
     */
    static IndexOf(value, start:=1) {
        if !IsInteger(start)
            throw ValueError("IndexOf: start value must be an integer")
        for i, v in this {
            if i < start
                continue
            if v == value
                return i
        }
        return 0
    }
    /**
     * Finds a value satisfying the provided function and returns its index.
     * @param func The condition function that accepts one argument.
     * @param match Optional: is set to the found value
     * @param start Optional: the index to start the search from. Default is 1.
     * @example
     * [1,2,3,4,5].Find((v) => (Mod(v,2) == 0)) ; returns 2
     */
    static Find(func, &match?, start:=1) {
        if !HasMethod(func)
            throw ValueError("Find: func must be a function", -1)
        for i, v in this {
            if i < start
                continue
            if func(v) {
                match := v
                return i
            }
        }
        return 0
    }
    /**
     * Reverses the array.
     * @example
     * [1,2,3].Reverse() ; returns [3,2,1]
     */
    static Reverse() {
        len := this.Length + 1, max := (len // 2), i := 0
        while ++i <= max
            this.Swap(i, len - i)
        return this
    }
    /**
     * Counts the number of occurrences of a value
     * @param value The value to count. Can also be a function.
     */
    static Count(value) {
        count := 0
        if HasMethod(value) {
            for v in this
                if value(v?)
                    count++
        } else
            for v in this
                if v == value
                    count++
        return count
    }
    /**
     * Sorts an array, optionally by object keys
     * @param OptionsOrCallback Optional: either a callback function, or one of the following:
     * 
     *     N => array is considered to consist of only numeric values. This is the default option.
     *     C, C1 or COn => case-sensitive sort of strings
     *     C0 or COff => case-insensitive sort of strings
     * 
     *     The callback function should accept two parameters elem1 and elem2 and return an integer:
     *     Return integer < 0 if elem1 less than elem2
     *     Return 0 is elem1 is equal to elem2
     *     Return > 0 if elem1 greater than elem2
     * @param Key Optional: Omit it if you want to sort a array of primitive values (strings, numbers etc).
     *     If you have an array of objects, specify here the key by which contents the object will be sorted.
     * @returns {Array}
     */
    static Sort(optionsOrCallback:="N", key?) {
        static sizeofFieldType := 16 ; Same on both 32-bit and 64-bit
        if HasMethod(optionsOrCallback)
            pCallback := CallbackCreate(CustomCompare.Bind(optionsOrCallback), "F Cdecl", 2), optionsOrCallback := ""
        else {
            if InStr(optionsOrCallback, "N")
                pCallback := CallbackCreate(IsSet(key) ? NumericCompareKey.Bind(key) : NumericCompare, "F CDecl", 2)
            if RegExMatch(optionsOrCallback, "i)C(?!0)|C1|COn")
                pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key,,True) : StringCompare.Bind(,,True), "F CDecl", 2)
            if RegExMatch(optionsOrCallback, "i)C0|COff")
                pCallback := CallbackCreate(IsSet(key) ? StringCompareKey.Bind(key) : StringCompare, "F CDecl", 2)
            if InStr(optionsOrCallback, "Random")
                pCallback := CallbackCreate(RandomCompare, "F CDecl", 2)
            if !IsSet(pCallback)
                throw ValueError("No valid options provided!", -1)
        }
        mFields := NumGet(ObjPtr(this) + (8 + 3*A_PtrSize), "Ptr") ; 0 is VTable. 2 is mBase, 4 is FlatVector, 5 is mLength and 6 is mCapacity
        DllCall("msvcrt.dll\qsort", "Ptr", mFields, "UInt", this.Length, "UInt", sizeofFieldType, "Ptr", pCallback, "Cdecl")
        CallbackFree(pCallback)
        if RegExMatch(optionsOrCallback, "i)R(?!a)")
            this.Reverse()
        if InStr(optionsOrCallback, "U")
            this := this.Unique()
        return this

        CustomCompare(compareFunc, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), compareFunc(fieldValue1, fieldValue2))
        NumericCompare(pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), fieldValue1 - fieldValue2)
        NumericCompareKey(key, pFieldType1, pFieldType2) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), fieldValue1.%key% - fieldValue2.%key%)
        StringCompare(pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1 "", fieldValue2 "", casesense))
        StringCompareKey(key, pFieldType1, pFieldType2, casesense := False) => (ValueFromFieldType(pFieldType1, &fieldValue1), ValueFromFieldType(pFieldType2, &fieldValue2), StrCompare(fieldValue1.%key% "", fieldValue2.%key% "", casesense))
        RandomCompare(pFieldType1, pFieldType2) => (Random(0, 1) ? 1 : -1)

        ValueFromFieldType(pFieldType, &fieldValue?) {
            static SYM_STRING := 0, PURE_INTEGER := 1, PURE_FLOAT := 2, SYM_MISSING := 3, SYM_OBJECT := 5
            switch SymbolType := NumGet(pFieldType + 8, "Int") {
                case PURE_INTEGER: fieldValue := NumGet(pFieldType, "Int64") 
                case PURE_FLOAT: fieldValue := NumGet(pFieldType, "Double") 
                case SYM_STRING: fieldValue := StrGet(NumGet(pFieldType, "Ptr")+2*A_PtrSize)
                case SYM_OBJECT: fieldValue := ObjFromPtrAddRef(NumGet(pFieldType, "Ptr")) 
                case SYM_MISSING: return		
            }
        }
    }
    /**
     * Randomizes the array. Slightly faster than Array.Sort(,"Random N")
     * @returns {Array}
     */
    static Shuffle() {
        len := this.Length
        Loop len-1
            this.Swap(A_index, Random(A_index, len))
        return this
    }
    /**
     * 
     */
    static Unique() {
        unique := Map()
        for v in this
            unique[v] := 1
        return [unique*]
    }
    /**
     * Joins all the elements to a string using the provided delimiter.
     * @param delim Optional: the delimiter to use. Default is comma.
     * @returns {String}
     */
	static Join(delim:=",") {
		result := ""
		for v in this
			result .= v delim
		return (len := StrLen(delim)) ? SubStr(result, 1, -len) : result
	}
    /**
     * Turns a nested array into a one-level array
     * @returns {Array}
     * @example
     * [1,[2,[3]]].Flat() ; returns [1,2,3]
     */
    static Flat() {
        r := []
        for v in this {
            if Type(v) = "Array"
                r.Extend(v.Flat())
            else
                r.Push(v)
        }
        return this := r
    }
    /**
     * Adds the contents of another array to the end of this one.
     * @param arr The array that is used to extend this one.
     * @returns {Array}
     */
    static Extend(arr) {
        if !HasMethod(arr, "__Enum")
            throw ValueError("Extend: arr must be an iterable")
        for v in arr
            this.Push(v)
        return this
    }
}