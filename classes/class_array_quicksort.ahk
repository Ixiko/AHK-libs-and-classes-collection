/*
Author: ryunp
Date: 04/17/18
Desc: Quicksort method as function object.
Usage: Array_Quicksort.Call(array[, compare_fn])

Created for 'array_.ahk' and 'array_base.ahk' sort function/method.
Default to alphanumeric comparison of items if no compare_fn given.
*/

;dependencies  'array_.ahk' and 'array_base.ahk

Class Array_QuickSort {
    _compare_alphanum(a, b) {
        return a > b ? 1 : a < b ? -1 : 0
    }

    _sort(array, compare_fn, left, right) {
        if (array.Length() > 1) {
            centerIdx := this._partition(array, compare_fn, left, right)
            if (left < centerIdx - 1) {
                this._sort(array, compare_fn, left, centerIdx - 1)
            }
            if (centerIdx < right) {
                this._sort(array, compare_fn, centerIdx, right)
            }
        }
    }

    _partition(array, compare_fn, left, right) {
        pivot := array[floor(left + (right - left) / 2)]
        i := left
        j := right

        while (i <= j) {
            while (compare_fn.Call(array[i], pivot) = -1) { ;array[i] < pivot
                i++
            }
            while (compare_fn.Call(array[j], pivot) = 1) { ;array[j] > pivot
                j--
            }
            if (i <= j) {
                this._swap(array, i, j)
                i++
                j--
            }
        }

        return i
    }

    _swap(array, idx1, idx2) {
        tmp := array[idx1]
        array[idx1] := array[idx2]
        array[idx2] := tmp
    }


    ; Left/Right remain from a standard implementation, but the adaption is
    ; ported from JS which doesn't expose these parameters.
    ;
    ; To expose left/right: Call(array, compare_fn:=0, left:=0, right:=0), but
    ; this would require passing a falsey value to compare_fn when only
    ; positioning needs altering: Call(myArr, <false/0/"">, 2, myArr.Length())
    Call(array, compare_fn:=0) {
        ; Default comparator
        if not (compare_fn) {
            compare_fn := objBindMethod(this, "_compare_alphanum")
        }

        ; Default start/end index
        left := left ? left : 1
        right := right ? right : array.Length()

        ; Perform in-place sort
        this._sort(array, compare_fn, left, right)

        ; Return object ref for method chaining
        return array
    }

    ; Redirect to newer calling standard
    __Call(method, args*) {
        if (method = "")
            return this.Call(args*)
        if (IsObject(method))
           return this.Call(method, args*)
    }
}