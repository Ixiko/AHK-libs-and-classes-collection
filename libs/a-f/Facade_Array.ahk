#Include <Is>
#Include <HashTable>
#Include <Validate>
#Include <Op>
#Include <Func>

Array_Fill(Func, Array, Length := "")
{
    local
    Length := Length == "" ? Array.Length() : Length
    Sig := "Array_Fill(Func, Array [, Length])"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_BadArrayArg(Sig, "Array", Array)
    _Validate_NonNegIntegerArg(Sig, "Length", Length)
    if (Length < Array.Length())
    {
        throw Exception("Value Error", -1
                       ,Sig . "  Length < Array length.")
    }
    Result := []
    Result.SetCapacity(Length)
    loop % Length
    {
        Result[a_index] := Array.HasKey(a_index) ? Array[a_index]
                         : Func.Call(a_index - 1)
    }
    return Result
}

Array_Empty(Pred, Array)
{
    local
    Sig := "Array_Empty(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    _Validate_BadArrayArg(Sig, "Array", Array)
    Result := []
    for Index, Value in Array
    {
        if (    Is(Index, "integer")
            and 1 <= Index
            and not Pred.Call(Index - 1, Value))
        {
            Result[Index] := Value
        }
    }
    return Result
}

Array_Length(Array)
{
    local
    Sig := "Array_Length(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
    return Array.Length()
}

_Array_BadIndex(Array, N)
{
    local
    return N >= 0 ? 1 + N : Array.Length() + 1 + N
}

Array_Index(Array, N)
{
    local
    Sig := "Array_Index(Array, N)"
    _Validate_ArrayArg(Sig, "Array", Array)
    _Validate_IntegerArg(Sig, "N", N)
    BadIndex := _Array_BadIndex(Array, N)
    if (1 > BadIndex or BadIndex > Array.Length())
    {
        throw Exception("Index Error", -1
                       ,Sig . "  N is out of bounds.  N is " . _Validate_ValueRepr(N) . ".")
    }
    return Array[BadIndex]
}

Array_Slice(Array, Start, Stop)
{
    local
    Sig := "Array_Slice(Array, Start, Stop)"
    _Validate_ArrayArg(Sig, "Array", Array)
    _Validate_IntegerArg(Sig, "Start", Start)
    _Validate_IntegerArg(Sig, "Stop", Stop)
    Beginning := _Array_BadIndex(Array, Start)
    End       := _Array_BadIndex(Array, Stop) - 1
    Beginning := Beginning < 1              ? 1              : Beginning
    End       := End       > Array.Length() ? Array.Length() : End
    Result    := []
    while (Beginning <= End)
    {
        Result.Push(Array[Beginning])
        ++Beginning
    }
    return Result
}

_Array_ConcatAux(A, X)
{
    local
    A.Push(X*)
    return A
}

Array_Concat(Arrays*)
{
    local
    Sig := "Array_Concat(Arrays*)"
    _Validate_ArrayArgs(Sig, Arrays)
    Result := []
    Result.SetCapacity(Result, Array_FoldL(Func_Hook2(Func("Op_Add")
                                                     ,Func("Array_Length"))
                                          ,0, Arrays))
    return Array_FoldL(Func("_Array_ConcatAux"), Result, Arrays)
}

Array_GetMany(Keys, Obj)
{
    local
    Sig := "Array_GetMany(Keys, Obj)"
    _Validate_ArrayArg(Sig, "Keys", Keys)
    _Validate_ObjArg(Sig, "Obj", Obj)
    return _Validate_Blame(Sig
                          ,Func("Array_Map")
                              .Bind(Func_Applicable(Obj)
                                   ,Keys))
}

Array_FoldL(Func, Init, Array)
{
    local
    Sig := "Array_FoldL(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_ArrayArg(Sig, "Array", Array)
    Index := 1
    A     := Init
    while (Index <= Array.Length())
    {
        A := Func.Call(A, Array[Index])
        ++Index
    }
    return A
}

Array_FoldR(Func, Init, Array)
{
    local
    Sig := "Array_FoldR(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_ArrayArg(Sig, "Array", Array)
    Index := Array.Length()
    A     := Init
    while (Index >= 1)
    {
        A := Func.Call(Array[Index], A)
        --Index
    }
    return A
}

Array_FoldL1(Func, Array)
{
    local
    Sig := "Array_FoldL1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_NonEmptyArrayArg(Sig, "Array", Array)
    Index := 2
    A     := Array[1]
    while (Index <= Array.Length())
    {
        A := Func.Call(A, Array[Index])
        ++Index
    }
    return A
}

Array_FoldR1(Func, Array)
{
    local
    Sig := "Array_FoldR1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_NonEmptyArrayArg(Sig, "Array", Array)
    Index := Array.Length() - 1
    A     := Array[Array.Length()]
    while (Index >= 1)
    {
        A := Func.Call(Array[Index], A)
        --Index
    }
    return A
}

_Array_FilterAux(Pred, A, X)
{
    local
    if (Pred.Call(X))
    {
        A.Push(X)
    }
    return A
}

Array_Filter(Pred, Array)
{
    local
    Sig := "Array_Filter(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    _Validate_ArrayArg(Sig, "Array", Array)
    return Array_FoldL(Func("_Array_FilterAux").Bind(Pred), [], Array)
}

_Array_UniqueAux(HashTable, X)
{
    local
    if (HashTable.HasKey(X))
    {
        Result := false
    }
    else
    {
        HashTable.Set(X, "")
        Result := true
    }
    return Result
}

Array_Unique(Array)
{
    local
    global HashTable
    Sig := "Array_Unique(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
    return Array_Filter(Func("_Array_UniqueAux").Bind(new HashTable()), Array)
}

_Array_MapAux(Func, A, X)
{
    local
    A.Push(Func.Call(X))
    return A
}

Array_Map(Func, Array)
{
    local
    Sig := "Array_Map(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_ArrayArg(Sig, "Array", Array)
    Result := []
    Result.SetCapacity(Array.Length())
    return Array_FoldL(Func("_Array_MapAux").Bind(Func), Result, Array)
}

_Array_ReverseAux(X, A)
{
    local
    A.Push(X)
    return A
}

Array_Reverse(Array)
{
    local
    Sig := "Array_Reverse(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
    Result := []
    Result.SetCapacity(Array.Length())
    return Array_FoldR(Func("_Array_ReverseAux"), Result, Array)
}

Array_Sort(Pred, Array)
{
    ; This is bottom-up merge sort.
    local
    Sig := "Array_Sort(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    _Validate_ArrayArg(Sig, "Array", Array)
    ; Always return an unwrapped Array.
    Result := _Validate_UnwrapObj(Array).Clone()
    if (Array.Length() > 1)
    {
        RunLength := 1
        Index     := 1
        WorkArray := []
        WorkArray.SetCapacity(Array.Length())
        while (RunLength < Array.Length())
        {
            while (Index <= Array.Length())
            {
                LeftFirst  := Index
                LeftLast   := LeftFirst + RunLength - 1  <= Array.Length() ? LeftFirst + RunLength - 1  : Array.Length()
                RightFirst := LeftLast + 1               <= Array.Length() ? LeftLast + 1               : Array.Length() + 1
                RightLast  := RightFirst + RunLength - 1 <= Array.Length() ? RightFirst + RunLength - 1 : Array.Length()
                while (Index <= RightLast)
                {
                    if (LeftFirst <= LeftLast and (RightFirst > RightLast or not Pred.Call(Result[RightFirst], Result[LeftFirst])))
                    {
                        WorkArray[Index] := Result[LeftFirst]
                        ++LeftFirst
                    }
                    else
                    {
                        WorkArray[Index] := Result[RightFirst]
                        ++RightFirst
                    }
                    ++Index
                }
            }
            RunLength *= 2
            Index     := 1
            Temp      := Result
            Result    := WorkArray
            WorkArray := Temp
        }
    }
    return Result
}

_Array_ZipAux(Arrays, Index)
{
    local
    return Array_Map(Func_Flip(Func("Array_Index")).Bind(Index), Arrays)
}

Array_Zip(Arrays*)
{
    local
    Sig := "Array_Zip(Arrays*)"
    _Validate_ArrayArgs(Sig, Arrays)
    Length := Arrays.Length() == 0 ? 0 : Arrays[1].Length()
    for _, Array in Arrays
    {
        if (not Array.Length() == Length)
        {
            throw Exception("Value Error", -1
                           ,Sig . "  Arrays are different lengths.")
        }
    }
    Indices := []
    Indices.SetCapacity(Length)
    return Arrays.Length() == 0 ? []
         : Array_Map(Func("_Array_ZipAux").Bind(Arrays)
                    ,Array_Fill(Func("Func_Id"), Indices, Length))
}
