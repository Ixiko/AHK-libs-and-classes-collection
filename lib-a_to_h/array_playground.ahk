/*  This file is where I do experimental or fun stuff in AutoHotkey.
*/

; Functions
; ==============================================================================
genArray(len, start := 1, step := 1) {
    /*  Generate an array of specified length
    */
    array := []
    for x in range(start, len + 1, step) {
        array.Push(x)
    }

    Return array
}

generateRandArrayFile(len, num) {
    /*  Generate num random arrays of length len (1 to len)

        Output saved to file named rand_array_<len>.txt
    */
    array := genArray(len)

    file_name := "rand_array_" . len . ".txt"
    file := FileOpen(file_name, "w")

    i := 0
    while (i < num) {
        rand_array := shuffle(array)
        file.Write(arrayAsStr(rand_array))
        i += 1
    }
    file.Close()

    Return file_name
}

readRandArrayFile(name) {
    /*  read file containing random arrays.

        Count the number of time each array appears.
    */
    array := {}
    Loop, Read, % name
    {
        if not array.HasKey(A_LoopReadLine) {
            array[A_LoopReadLine] := 0
        }
        array[A_LoopReadLine] += 1
    }

    StringTrimRight, base_name, name, 4
    res_name := name . "_res.txt"

    file := FileOpen(res_name, "w")
    file.Write("Array: Count`r`n")
    for key, val in array {
        str := key . ": " . val . "`r`n"
        file.Write(str)
    }
    file.close()

    Return res_name
}

arrayAsStr(array) {
    /*  Format array as string
    */
    str := "["
    for key, val in array {
        str := str . val . ", "
    }
    StringTrimRight, str, str, 2
    str := str . "]`r`n"
    Return str
}

genRandomArray(array) {
    /*  Returns shuffled version of provided array.

        Original array is unaffected.

        I could rebuild this using the inside out implementation of Fischer-Yates
        but that depends on frequent calls to the length of an array.
        I am pretty sure that those calls in AutoHotkey are linear time.
        I believe this implementation is faster.
    */

    a := [array.clone()]  ; Copy of array so original is not changed
    shuffle(a)
    Return a
}

shuffle(a) {
    /*  Shuffle array in place.

        Implementation of the Fischer-Yates shuffle.
    */
    i := a.length()  ; Arrays are 1-indexed so I don't need to -1 here.
    while (i > 1) {  ; Don't need to swap the last element with itself.
        Random, rand, 0.0, 1.0  ; Get random float between 0 and 1
        j := Ceil(rand * i)  ; Turn float to int between 1 and i.
        temp := a[i], a[i] := a[j], a[j] := temp  ; swap values at i and j in array
        i -= 1
    }
    Return a
}

range(start, stop:="", step:=1) {
    /*  Create Python style range function in AutoHotkey.

        Copied from HTTPS://autohotkey.com/boards/viewtopic.php?t=4303
    */
    static range := { _NewEnum: Func("_RangeNewEnum") }
    if !step
        throw "range(): Parameter 'step' must not be 0 or blank"
    if (stop == "")
        stop := start, start := 0
    ; Formula: r[i] := start + step*i ; r = range object, i = 0-based index
    ; For a positive 'step', the constraints are i >= 0 and r[i] < stop
    ; For a negative 'step', the constraints are i >= 0 and r[i] > stop
    ; No result is returned if r[0] does not meet the value constraint
    if (step > 0 ? start < stop : start > stop) ;// start == start + step*0
        Return { base: range, start: start, stop: stop, step: step }
}

_RangeNewEnum(r) {
    /*  Subfunction of range.
    */
    static enum := { "Next": Func("_RangeEnumNext") }
    Return { base: enum, r: r, i: 0 }
}

_RangeEnumNext(enum, ByRef k, ByRef v:="") {
    /*  Subfunction of range.
    */
    stop := enum.r.stop, step := enum.r.step
    , k := enum.r.start + step*enum.i
    if (ret := step > 0 ? k < stop : k > stop)
        enum.i += 1
    Return ret
}
