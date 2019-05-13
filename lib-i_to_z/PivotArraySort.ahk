PivotSortArray(Array, Order="A") {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex 
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
        if (Order = "A") {    
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}

PivotSortArray2D(ByRef _array, 2D, sortByItem) { ;1 means array is one dimensional, 2 means array is two dimensional

    sorted := []
    size := _array.MaxIndex()
    if (2D = True)
    {
        loop % size
        {
            min := _array[1][sortByItem]
            for index,item in _array
            {
                if (item[sortByItem] <= min)
                {
                    temp := index
                    min := item[sortByItem]
                }
            }
            sorted.Push(_array.RemoveAt(temp))
        }
    }
    else
    {
        loop % size
        {
            min := _array[1]
            for index,item in _array
            {
                if (item <= min)
                {
                    temp := index
                    min := item
                }
            }
            sorted.Push(_array.RemoveAt(temp))
        }
    }
    return sorted
}

sort(ByRef array, element) {

    length := array.MaxIndex()
    pos := 1
    swapped := 0
    loop
    {
        if (pos >= length)
        {
            pos := 1
            if (swapped = 0)
                break
            swapped := 0
        }
        if (element = 0)
        {
            if (array[pos] > array[pos + 1])
            {
                swap(array, pos, pos + 1)
                pos++
                swapped := 1
                continue
            }
        }
        else
        {
            if (array[pos][element] > array[pos + 1][element])
            {
                swap(array, pos, pos + 1)
                pos++
                swapped := 1
                continue
            }
        }
        pos++
    }
}

SimpleSortArray(Array) {

    Static Delim := Chr(1)
    SortVar := ""
    For index, item In Array
        SortVar .= item . Delim . index . "`n"
    Sort, SortVar, N
    NewArray := {}
    Loop, Parse, SortVar, `n
    {
        If (A_LoopField)
            {
                temp := StrSplit(A_LoopField,Delim)
                NewArray.Push(Array[temp[2]])
            }
    }
    return NewArray
}