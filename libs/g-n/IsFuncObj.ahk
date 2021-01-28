#Include <Type>

IsFuncObj(Value)
{
    local
    Result := false
    while (not Result and Value != "")
    {
        Type   := Type(Value)
        Result := Type == "BoundFunc" or Type == "Func"
        ; The seemingly redundant test below works around a defect where
        ; BoundFuncs execute when their Call property is read.
        Value  := not Result ? Value.Call : ""  ; "" when Call does not exist
    }
    return Result
}
