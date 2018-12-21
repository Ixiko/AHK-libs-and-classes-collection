#Include <IsFuncObj>
#Include <Validate>
#Include <Op>
#Include <Array>

_Nested_Blame(Sig, Func)
{
    local
    try
    {
        Result := Func.Call()
    }
    catch E
    {
        if (E["Message"] == "Key Error")
        {
            throw Exception("Key Error", -2
                           ,Sig . "  Invalid path.")
        }
        else if (    E["Message"] == "Type Error"
                 and E["Extra"]   == "Invalid path.")
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid path.")
        }
        else
        {
            throw E
        }
    }
    return Result
}

Nested_Count(Path, Dict)
{
    local
    Sig := "Nested_Count(Path, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_ObjArg(Sig, "Dict", Dict)
    Result := _Nested_Blame(Sig
                           ,Func("Nested_Get")
                               .Bind(Path
                                    ,Dict)).Count()
    if (Result == "")
    {
        throw Exception("Type Error", -1
                       ,Sig . "  Invalid path.")
    }
    return Result
}

Nested_HasKey(Path, Dict)
{
    local
    Sig := "Nested_HasKey(Path, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_ObjArg(Sig, "Dict", Dict)
    Result        := true
    Index         := 1
    CurrentObject := Dict
    while (Result and Index <= Path.Length())
    {
        ; Return false instead of an empty string when HasKey(Key) does not
        ; exist.
        Result := CurrentObject.HasKey(Path[Index]) ? true : false
        if (Result)
        {
            CurrentObject := Op_Get(CurrentObject, Path[Index])
            ++Index
        }
    }
    return Result
}

Nested_Get(Path, Dict)
{
    local
    Sig := "Nested_Get(Path, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_ObjArg(Sig, "Dict", Dict)
    return _Nested_Blame(Sig
                        ,Func("Array_FoldL")
                            .Bind(Func("Op_Get")
                                 ,Dict
                                 ,Path))
}

_Nested_SetAux(Value, Dict, Key)
{
    local
    if (IsFuncObj(Dict.Set))
    {
        Dict.Set(Key, Value)
    }
    else
    {
        Dict[Key] := Value
    }
    return Dict
}

_Nested_ReconstructAux(Path, Index, PreviousClone, PreviousKey, Func)
{
    local
    if (Index == 1)
    {
        Clone := PreviousClone.Clone()
    }
    else
    {
        Clone := Op_Get(PreviousClone, PreviousKey).Clone()
    }
    if (Clone == "")
    {
        throw Exception("Type Error",
                       ,"Invalid path.")
    }
    Key := Path[Index]
    if (Index == Path.Length())
    {
        Result := Func.Call(Clone, Key)
    }
    else
    {
        Result := _Nested_SetAux(_Nested_ReconstructAux(Path
                                                       ,Index + 1
                                                       ,Clone
                                                       ,Key
                                                       ,Func)
                                ,Clone
                                ,Key)
    }
    return Result
}

_Nested_Reconstruct(Path, Func, Dict)
{
    local
    if (Path.Length() == 0)
    {
        ; Mutation-equivalent functions should always return a copy.
        Result := Dict.Clone()
        if (Result == "")
        {
            throw Exception("Type Error",
                           ,"Invalid path.")
        }
    }
    else
    {
        Result := _Nested_ReconstructAux(Path
                                        ,1
                                        ,Dict
                                        ,""
                                        ,Func)
    }
    return Result
}

Nested_Set(Path, Value, Dict)
{
    local
    Sig := "Nested_Set(Path, Value, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_ObjArg(Sig, "Dict", Dict)
    return _Nested_Blame(Sig
                        ,Func("_Nested_Reconstruct")
                            .Bind(Path
                                 ,Func("_Nested_SetAux").Bind(Value)
                                 ,Dict))
}

_Nested_UpdateAux(Func, Dict, Key)
{
    local
    return _Nested_SetAux(Func.Call(Op_Get(Dict, Key)), Dict, Key)
}

Nested_Update(Path, Func, Dict)
{
    local
    Sig := "Nested_Update(Path, Func, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_ObjArg(Sig, "Dict", Dict)
    return _Nested_Blame(Sig
                        ,Func("_Nested_Reconstruct")
                            .Bind(Path
                                 ,Func("_Nested_UpdateAux").Bind(Func)
                                 ,Dict))
}

_Nested_DeleteAux(Dict, Key)
{
    local
    if (not Dict.HasKey(Key))
    {
        throw Exception("Key Error")
    }
    Dict.Delete(Key)
    return Dict
}

Nested_Delete(Path, Dict)
{
    local
    Sig := "Nested_Delete(Path, Dict)"
    _Validate_ArrayArg(Sig, "Path", Path)
    _Validate_ObjArg(Sig, "Dict", Dict)
    return _Nested_Blame(Sig
                        ,Func("_Nested_Reconstruct")
                            .Bind(Path
                                 ,Func("_Nested_DeleteAux")
                                 ,Dict))
}
