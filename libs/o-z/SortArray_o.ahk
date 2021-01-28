; Link:   	https://sites.google.com/site/ahkref/custom-functions/sortarray
; Author:
; Date:
; for:     	AHK_L

/*

    Array1 := [ "b", "f", "e", "c", "d", "a", "h", "g" ]
    Array2 := [ "100", "333", "987", "54", "1", "0", "-263", "543" ]

    SortArray(Array1)
    Loop, % Array1.MaxIndex()
        list1 .= Array1[A_Index] . "`n"
    msgbox % list1

    SortArray(Array2, "D")
    Loop, % Array2.MaxIndex()
        list2 .= Array2[A_Index] . "`n"
    msgbox % list2

    SortArray(Array1, "R")
    Loop, % Array1.MaxIndex()
        list3 .= Array1[A_Index] . "`n"
    msgbox % list3

*/

SortArray(Array, Order="A") {
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