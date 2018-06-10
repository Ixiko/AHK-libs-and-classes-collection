; Note: This can only be used if you want to order the array
; by one key, and you dont care about how any of the other key values
; are ordered (when there are multiple sorted keys with the same value)
; eg sort could result in something like this:

; sortedKey:     1     associatedKey:   0
; sortedKey:     2     associatedKey:   2*   Higher
; sortedKey:     2     associatedKey:   1*   Lower
; sortedKey:     2     associatedKey:   3
; sortedKey:     3     associatedKey:   12

; (the associated keys will still be paired with their associated sorted key)   

; Keys/Values should not contain the chars + or |

sort2DArray(byRef a, key, Ascending := True)
{

    ; set capcity to 20MB to greatly increase concatenation speed for v. v. V. large arrays
    ; > 20,00 items+. But before this it is insignificant 
    ; 1000000 items is ~300ms faster 
    ; as its still uninitialised, it doesn't actually take up 20 MB
    ; and this call only takes .02 ms - which is easily made up for in concatenation  
    ;VarSetCapacity(out, 20 * 1000 *1000) 
   
  
    for index, obj in a
        out .= obj[key] "+" index "|" ; "+" allows for sort to work with just the value (and negatives values)
    ; out will look like:   value+index|value+index|

    ; if index values are strings, then this check would fail - could use another function param to set alpha/numeric sort
    ; but It's not an issue for me
    v := a[a.minIndex(), key]
    if v is number 
        type := " N "
    StringTrimRight, out, out, 1 ; remove trailing | 
    Sort, out, % "D| " type  (!Ascending ? " R" : " ")
    aStorage := []
    loop, parse, out, |
    {
        ; split1 = value, split2 = index
        ; StringSplit, split, A_LoopField, -
        ; aStorage.insert(a[split2])
        aStorage.insert(a[SubStr(A_LoopField, InStr(A_LoopField, "+") + 1)])
        
    }
    a := aStorage
    return
}
; the sort command only takes a fraction of the function time, the rest is spent
; iterating and copying the data

; Test:
; Object: 
/*
    loop 10000
         a.insert({ "key": rand(1,10), "another": "b"})
*/
; Old Bubble Search
; Bubble took 54,032 ms
; New sort took 26.7 ms (2,023x Faster!)

