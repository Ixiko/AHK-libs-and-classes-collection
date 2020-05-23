/*
; To implement 'native' support, redefine Array() to add custom _Array base object
Array(prms*) {
    ; Since prms is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, _Array.__New()
    ; is not called and any instance variables are not initialized.
    prms.base := _Array
    return prms
}
*/

; Define the base class.
class _Array {
    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/concat
    concat(arrays*) {
        
        results := []

        ; First add the values from the instance being called on
        for index, value in this
            results.push(value)

        ; Second, add arrays given in parameter
        for index, array in arrays
            for index, element in array
                results.push(element)

        return results
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
    every(callback) {

        for index, element in this
            if not callback.Call(element, index, this)
                return false

        return true
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/fill
    fill(value, start:=0, end:=0) {

        len := this.Length()

        ; START: Adjust 1 based index, check signage, set defaults
        if (start > 0)
            begin := start - 1    ; Include starting index going forward
        else if (start < 0)
            begin := len + start  ; Count backwards from end
        else
            begin := start


        ; END: Check signage and set defaults
        if (end > 0)
            last := end
        else if (end < 0)
            last := len + end   ; Count backwards from end
        else
            last := len


        loop, % (last - begin)
            this[begin + A_Index] := value

        return this
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
    filter(callback) {
        
        results := []

        for index, element in this
            if (callback.Call(element, index, this))
                results.push(element)

        return results
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find
    ; Modified to return 0 instead of 'undefined'
    find(callback) {
        
        for index, element in this
            if (callback.Call(element, index, this))
                return element

        return 0
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex
    findIndex(callback) {

        for index, value in this
            if (callback.Call(value, index, this))
                return index

        return 0
    }



    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
    forEach(callback) {

        for index, element in this
            callback.Call(element, index, this)

        return 0
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/includes
    includes(searchElement, fromIndex:=0) {

        return this.indexOf(searchElement, fromIndex) > 0 ? true : false
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf
    indexOf(searchElement, fromIndex:=0) {
        
        len := this.Length()

        if (fromIndex > 0)
            start := fromIndex - 1    ; Include starting index going forward
        else if (fromIndex < 0)
            start := len + fromIndex  ; Count backwards from end
        else
            start := fromIndex


        loop, % len - start
            if (this[start + A_Index] = searchElement)
                return start + A_Index

        return 0
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join
    join(delim) {
        
        result := ""
        
        for index, element in this
            result .= element (index < this.Length() ? delim : "")

        return result
    }

    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf
    ; "if the provided index is negative, the array is still searched from front to back"
    ;   - Are we not able to return the first found starting from the back?
    lastIndexOf(searchElement, fromIndex:=0) {
        
        len := this.Length()
        foundIdx := -1

        if (fromIndex > len)
            return foundIdx

        if (fromIndex > 0)
            start := fromIndex - 1    ; Include starting index going forward
        else if (fromIndex < 0)
            start := len + fromIndex  ; Count backwards from end
        else
            start := fromIndex

        loop, % len - start
            if (this[start + A_Index] = searchElement)
                foundIdx := start + A_Index

        return foundIdx
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
    map(callback) {

        results := []

        for index, element in this
            results.push(callback.Call(element, index, this))

        return results
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce
    ; -->[A,B,C,D,E,F]
    reduce(callback, initialValue:="__NULL__") {

        arrLen := this.Length()

        ; initialValue not defined
        if (initialValue == "__NULL__") {

            if (arrLen < 1) {
                ; Empty array with no intial value
                return
            }
            else if (arrLen == 1) {
                ; Single item array with no initial value
                return this[1]
            }

            ; Starting value is last element
            initialValue := this[1]

            ; Loop n-1 times (start at 2nd element)
            iterations := arrLen - 1 

            ; Set index A_Index+1 each iteration
            idxOffset := 1

        } else {
        ; initialValue defined

            if (arrLen == 0) {
                ; Empty array with initial value
                return initialValue
            }

            ; Loop n times (starting at 1st element)
            iterations := arrLen

            ; Set index A_Index each iteration
            idxOffset := 0
        }

        ; if no initialValue is passed, use first index as starting value and reduce
        ; array starting at index n+1. Otherwise, use initialValue as staring value
        ; and start at arrays first index.
        Loop, % iterations
        {
            adjIndex := A_Index + idxOffset
            initialValue := callback.Call(initialValue, this[adjIndex], adjIndex, this)
        }
        
        return initialValue
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduceRight
    ; [A,B,C,D,E,F]<--
    reduceRight(callback, initialValue:="__NULL__") {

        arrLen := this.Length()

        ; initialValue not defined
        if (initialValue == "__NULL__") {

            if (arrLen < 1) {
                ; Empty array with no intial value
                return
            }
            else if (arrLen == 1) {
                ; Single item array with no initial value
                return this[1]
            }

            ; Starting value is last element
            initialValue := this[arrLen]

            ; Loop n-1 times (starting at n-1 element)
            iterations := arrLen - 1 
            
            ; Set index A_Index-1 each iteration
            idxOffset := 0

        } else {
        ; initialValue defined

            if (arrLen == 0)
                ; Empty array with initial value
                return initialValue

            ; Loop n times (start at n element)
            iterations := arrLen

            ; Set index A_Index each iteration
            idxOffset := 1
        }

        ; If no initialValue is passed, use last index as starting value and reduce
        ; array starting at index n-1. Otherwise, use initialValue as starting value
        ; and start at arrays last index.
        Loop, % iterations
        {
            adjIndex := arrLen - (A_Index - idxOffset)
            initialValue := callback.Call(initialValue, this[adjIndex], adjIndex, this)
        }

        return initialValue
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse
    reverse() {

        arrLen := this.Length()

        Loop, % (arrLen // 2)
        {
            idxFront := A_Index
            idxBack := arrLen - (A_Index - 1)

            tmp := this[idxFront]
            this[idxFront] := this[idxBack]
            this[idxBack] := tmp
        }

        return this
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift
    shift() {

        return this.RemoveAt(1)
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice
    slice(start:=0, end:=0) {

        len := this.Length()

        ; START: Adjust 1 based index, check signage, set defaults
        if (start > 0)
            begin := start - 1    ; Include starting index going forward
        else if (start < 0)
            begin := len + start  ; Count backwards from end
        else
            begin := start


        ; END: Check signage and set defaults
        ; MDN States: "to end (end not included)" so subtract one from end
        if (end > 0)
            last := end - 1
        else if (end < 0)
            last := len + end + 1 ; Count backwards from end
        else
            last := len


        results := []

        loop, % last - begin
            results.push(this[begin + A_Index])

        return results
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
    some(callback) {

        for index, value in this
            if callback.Call(value, index, this)
                return true

        return false
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort
    sort(compare_fn:=0) {

        ; Quicksort
        Array_QuickSort.Call(this, compare_fn)

        return this
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice
    splice(start, deleteCount:=-1, args*) {

        arrLen := this.Length()
        exiting := []

        ; Determine starting index
        if (start > arrLen)
            start := arrLen

        if (start < 0)
            start := arrLen + start

        ; deleteCount unspecified or out of bounds, set count to start through end
        if ((deleteCount < 0) || (arrLen <= (start + deleteCount))) {
            deleteCount := arrLen - start + 1
        }

        ; Remove elements
        Loop, % deleteCount
        {
            exiting.push(this[start])
            this.RemoveAt(start)
        }

        ; Inject elements
        Loop, % args.Length()
        {
            curIndex := start + (A_Index - 1)

            this.InsertAt(curIndex, args[1])
            args.removeAt(1)
        }

        return exiting
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toString
    toString() {
        str := "["

        for i,v in this
            str .= v (i < this.Length() ? ", " : "")
        
        return str "]"
    }


    ; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift
    unshift(args*) {

        for index, value in args
            this.InsertAt(A_Index, value)

        return this.Length()
    }

    ; Simple swap
    swap(index1, index2) {
        tmp := this[index1]
        this[index1] := this[index2]
        this[index2] := tmp
    }
}
