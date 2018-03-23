randomiseArray(byRef a)
{
    for index, value in a
        out .= value "-" index "|" ; "-" allows for sort to work with just the value
    ; out will look like:   value-index|value-index|
    v := a[a.minIndex()]
    if v is number 
        type := " N "
    StringTrimRight, out, out, 1 ; remove trailing | 
    Sort, out, % "D| " type  "Random"
    aStorage := []
    loop, parse, out, |
    {
        StringSplit, split, A_LoopField, -
        ; split1 = value, split2 = index
        aStorage.insert(a[split2])
    }
    a := aStorage
    return
}

/*
RandomiseArray(byref a)
{
    aIndicies := []
    for i, in a 
         aIndicies.insert(i)
    for index, in a
    {
        Random, i, 1, aIndicies.MaxIndex()
        storage := a[aIndicies[i]]
        , a[aIndicies[i]] := a[index]
        , a[index] := storage   
    }
    return
}


*/