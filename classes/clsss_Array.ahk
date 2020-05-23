/**
 * extends functionality for Objects on the base object
 * 
 * @Source    - https://autohotkey.com/board/topic/83081-ahk-l-customizing-object-and-array/
 * @Source    - https://gist.github.com/errorseven/559681eb1fa122c14a75455d272abbea (extended Objects)
*/
Class _Object {

    /**
     * Getter meta function
     * this allows to interact on given object directly using keywords
     *
     * @Parameters
     *    @Key     - [string][int] identifier to trigger different functions/routines
     *
     * @Return
     *    string
    */
    __Get(key) {
        if (key == "rmDupe") || (key == "rmDuplicate") {
            ; removes duplicate values from array
            return this.removeDuplicate()
        } else if (key == "rmEmpty") {
            ; removes empty values from array
            return this.removeEmpty()
        }
    }

    /**
     * Deterimines if an Object is linear (associative Arrays are treated as objects, not arrays)
     * this is a Property
    */
    isLinear[] {
        Get {
            While (A_Index != this.MaxIndex()) 
                If !(this.hasKey(A_Index)) 
                    Return False
            Return True
        }
    }

    /**
     * creates a msgbox for the created print result
     * this is a Property
     *
     * @Usage
     *     obj := [1, 2, 3, {a: 1, b: 2}]
     *     obj.print ; --> [1, 2, 3, {a:1, b:2}]
     *     arr := [1, 2, "ape"]
     *     arr.print()
     *     
            */
    */
    print[] {
        
        Get {
            msgbox(this.createPrintResult(this, level:=0))
        }
    }

    /**
     * Returns a reverse ordered Array/Object
     * this is a Property
     *
     * @Return
     *    Return
    */
    reverse[] {
        
        Get {
            out := []
            if (!IsObject(this)) {
                loop % this.count {
                    out.push(this.pop())
                }
            } else {
                loop % this.MaxIndex() {
                    out.push(this.pop())
                }
            }
            return out
        }
    }

    /**
     * creates the output for displaying the array. Recursively goes over the array 
     * and indents if array has depth
     *
     * @Parameters
     *    @array    - [array] array to be sorted, the recursive call will take care of nested arrays
     *    @level    - [int] for nested arrays
     *
     * @Source    - http://autohotkey.com/board/topic/70490-print-array/?p=492815
     *
     * @Return
     *    string
    */
    createPrintResult(array, level:=0) {
        Loop, % 4 + (level*4) {
            Tabs .= A_Space
        
            out := "Array ("
        
            for key, value in array {
                if (IsObject(value)) {
                    level++
                        value := this.createPrintResult(value, level)
                        level--
                }
                
                out .= "`r`n" . Tabs . "[" . key . "] => " . value
            }
        out .= "`r`n" . SubStr(Tabs, 5) . ")"
        }
        return out
    }
    
    /**
     * Checks if object contains value
     *
     * @Parameters
     *    Parameters
     *
     * @Return
     *    boolean
    */
    contains(compare_value, output_string:="") {
        
        If this.IsCircle()
            return 0
    
        For key, value in this {
            if (value == compare_value) {
                return output_string "[" key "]"
            }

            if (IsObject(value) && value != this) {
                found_in_sub_object := this[key].contains(compare_value, output_string "[" key "]" )
            }
        
            if (found_in_sub_object) {
                return found_in_sub_object
            }
        }

        return 0
    }

    /**
     * Used to merge two or more arrays. This method does not change the existing arrays, but instead returns a new array.
     *
     * @Parameters
     *    @arrays    - [array] 1 or more arrays to merge
     *
     * @Return
     *    array
    */
    concat(arrays*) {
        
        out := []

        ; First add the values from the instance being called on
        for index, value in this {
            out.push(value)
        }

        ; Second, add arrays given in parameter
        for index, array in arrays {
            for index, element in array {
                out.push(element)
            }
        }

        return out
    }

    /**
     * Function by GeekDude
       Returns True if Object contains a reference to itself
     *
     * @Parameters
     *    object    - [object] name of the object to check
     *
     * @Return
     *    boolean
    */
    isCircle(object=0) {
        
        if !object
            object := {}
        For Key, Val in this {
            if (IsObject(Val)&&(object[&Val]||Val.IsCircle((object,object[&Val]:=1)))) {
                return 1
            }
        }
        return 0
    }

    /**
     * joins parameters into string seperated by user defined seperator
     *
     * @Parameters
     *    @delimiter      - [string] expects any string input
     *
     * @Return
     *    string
    */
    join(delimiter=",") {
        for i, value in this {
            out .= value (i < this.Length() ? delimiter : "")
        }
        return out
    }

    /**
     * removed duplicates by creating an object using the values as keys
     *
     * @Source    - https://stackoverflow.com/questions/46432447/how-do-i-remove-duplicates-from-an-autohotkey-array
     * 
     * @Return
     *    no return value
    */
    removeDuplicate() { ; Hash O(n) - Linear
        hash := {}

        for index, value in this {
            if (!hash[value]) {
                hash[(value)] := 1
            } else {
                this.removeAt(index)
            }
        }
        return this
    }

    /**
     * remove empty keys from array
     *
     * @Return
     *    array
    */
    removeEmpty() {
        temp_new_array := []
        temp_new_array.SetCapacity(this.GetCapacity())
        for k, v in this {
            if (v) {
                temp_new_array.Push(v)
            }
        }
        this := temp_new_array
        temp_new_array := ""

        return this
    }

    /**
     * sorts a 2D array 
     *
     * @Parameters
     *    @order    - [string] expects following inputs "A", "D", "R"
     *
     * @Source    - https://sites.google.com/site/ahkref/custom-functions/sortarray
     *
     * @Return
     *    array
    */
    sort(order:="A") {
        ;Order A: Ascending, D: Descending, R: Reverse
        max_index := ObjMaxIndex(this)
        if (order == "R") {
            count := 0
            Loop, % max_index {
                ObjInsert(this, ObjRemove(this, max_index - count++))
            }
            Return
        }
        partitions := "|" ObjMinIndex(this) "," max_index
        Loop {
            comma := InStr(this_partition := SubStr(partitions, InStr(partitions, "|", False, 0)+1), ",")
            spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
            if (order == "A") {
                Loop, % epos - spos {
                    if (this[pivot] > this[A_Index+spos])
                        ObjInsert(this, pivot++, ObjRemove(this, A_Index+spos))
                }
            } else {
                Loop, % epos - spos {
                    if (this[pivot] < this[A_Index+spos]) {
                        ObjInsert(this, pivot++, ObjRemove(this, A_Index+spos))
                    }
                }
            }
            partitions := SubStr(partitions, 1, InStr(partitions, "|", False, 0)-1)
            if (pivot - spos) > 1 {                     ;if more than one element
                partitions .= "|" spos "," pivot-1      ;the left partition
            }
            if (epos - pivot) > 1 {                     ;if more than one element
                partitions .= "|" pivot+1 "," epos      ;the right partition
            }
        } Until !partitions
        return this
    }

    /**
     * changes the contents of an array by removing or replacing existing elements and/or adding new elements in place
     *
     * @Parameters
     *    @start            - [] index to insert at
     *    @delete_count      - [] replacement count
     *    @args             - [string][int]element to be replaced or elements to be added
     *
     * @Return
     *    array
    */
    splice(start, delete_count:=-1, args*) {

        array_length := this.Length()
        out := []

        ; Determine starting index
        if (start > array_length) {
            start := array_length
        }

        if (start < 0) {
            start := array_length + start
        }

        ; delete_count unspecified or out of bounds, set count to start through end
        if ((delete_count < 0) || (array_length <= (start + delete_count))) {
            delete_count := array_length - start + 1
        }

        ; Remove elements
        Loop, % delete_count {
            out.push(this[start])
            this.removeAt(start)
        }

        ; Inject elements
        Loop, % args.Length() {
            current_index := start + (A_Index - 1)

            this.insertAt(current_index, args[1])
            args.removeAt(1)
        }

        return out
    }
}

/**
 * duplicating functionality to Arrays (object and arrays are not the same)
 *
*/
class _Array Extends _Object {

}

/**
 * redefines Object().
 *
 * @Parameters
 *    [string]  keyword to trigger the functions
 *
 * @Return
 *    array
*/
Object(prm*) {

    ; Create a new object derived from _Object.
    obj := new _Object
    ; For each pair of parameters, store a key-value pair.
    Loop % prm.MaxIndex()//2 {
        obj[prm[A_Index*2-1]] := prm[A_Index*2]
    }
    ; Return the new object.
    return obj
}

/**
 * redefines Array().
 *
 * @Parameters
 *    @prm    - [string]  keyword to trigger the functions
 *
 * @Return
 *    array
*/
Array(prm*) {
    ; Since prm is already an array of the parameters, just give it a
    ; new base object and return it. Using this method, _Array.__New()
    ; is not called and any instance variables are not initialized.
    prm.base := _Array
    return prm
}
