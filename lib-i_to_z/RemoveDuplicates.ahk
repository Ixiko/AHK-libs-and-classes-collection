RemoveDuplicates(list)
{
    Loop, Parse, list, `n
    {
        list := (A_Index = 1 ? A_LoopField : list . (InStr("`n" list . "`n", "`n" A_LoopField "`n") ? "" : "`n" A_LoopField))
    }

    Return, list
}
