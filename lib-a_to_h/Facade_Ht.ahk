#Include <HashTable>
#Include <Validate>
#Include <Array>

Ht(Items*)
{
    local
    global HashTable
    return new HashTable(Items*)
}

Ht_FromObject(Object)
{
    local
    Sig := "Ht_FromObject(Object)"
    _Validate_ObjectArg(Sig, "Object", Object)
    Result := Ht()
    for Key, Value in Object
    {
        Result.Set(Key, Value)
    }
    return Result
}

_Ht_ToObjectAux(A, X)
{
    local
    if (not ObjHasKey(A, X[1]))
    {
        ObjRawSet(A, X[1], X[2])
    }
    else
    {
        throw Exception("Value Error", -2
                       ,"Ht_ToObject(HashTable)  HashTable contains keys that collide when case-folded.")
    }
    return A
}

Ht_ToObject(HashTable)
{
    local
    Sig := "Ht_ToObject(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    Result := {}
    Result.SetCapacity(HashTable.Count())
    return Ht_Fold(Func("_Ht_ToObjectAux"), Result, HashTable)
}

Ht_Count(HashTable)
{
    local
    Sig := "Ht_Count(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return HashTable.Count()
}

Ht_HasKey(Key, HashTable)
{
    local
    Sig := "Ht_HasKey(Key, HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return HashTable.HasKey(Key)
}

Ht_GetMany(Keys, Obj)
{
    local
    Sig := "Ht_GetMany(Keys, Obj)"
    _Validate_ArrayArg(Sig, "Keys", Keys)
    _Validate_ObjArg(Sig, "Obj", Obj)
    return Ht(Array_Zip(Keys
                       ,_Validate_Blame(Sig
                                       ,Func("Array_GetMany")
                                           .Bind(Keys
                                                ,Obj)))*)
}

Ht_SetMany(Defaults, HashTable)
{
    local
    Sig := "Ht_SetMany(Defaults, HashTable)"
    _Validate_HashTableArg(Sig, "Defaults", Defaults)
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    ; Always return an unwrapped HashTable.
    Result := _Validate_UnwrapObj(Defaults).Clone()
    for Key, Value in Ht
    {
        Result.Set(Key, Value)
    }
    return Result
}

Ht_Fold(Func, Init, HashTable)
{
    local
    Sig := "Ht_Fold(Func, Init, HashTable)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    A := Init
    for Key, Value in HashTable
    {
        A := Func.Call(A, [Key, Value])
    }
    return A
}

Ht_Fold1(Func, HashTable)
{
    local
    Sig := "Ht_Fold1(Func, HashTable)"
    _Validate_NonEmptyHashTableArg(Sig, "HashTable", HashTable)
    Enum := HashTable._NewEnum()
    Enum.Next(Key, Value)
    A := [Key, Value]
    while (Enum.Next(Key, Value))
    {
        A := Func.Call(A, [Key, Value])
    }
    return A
}

_Ht_FilterAux(Pred, A, X)
{
    local
    if (Pred.Call(X))
    {
        A.Set(X*)
    }
    return A
}

Ht_Filter(Pred, HashTable)
{
    local
    Sig := "Ht_Filter(Pred, HashTable)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return Ht_Fold(Func("_Ht_FilterAux").Bind(Pred), Ht(), HashTable)
}

_Ht_MapAux(Func, A, X)
{
    local
    A.Set(Func.Call(X)*)
    return A
}

Ht_Map(Func, HashTable)
{
    local
    Sig := "Ht_Map(Func, HashTable)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return Ht_Fold(Func("_Ht_MapAux").Bind(Func), Ht(), HashTable)
}

_Ht_InvertAux(X)
{
    local
    return [X[2], X[1]]
}

Ht_Invert(HashTable)
{
    local
    Sig := "Ht_Invert(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    Result := Ht_Map(Func("_Ht_InvertAux"), HashTable)
    if (Result.Count() < HashTable.Count())
    {
        throw Exception("Value Error", -1
                       ,Sig . "  HashTable contains duplicate values.")
    }
    return Result
}

_Ht_ItemsAux(A, X)
{
    local
    A.Push(X)
    return A
}

Ht_Items(HashTable)
{
    local
    Sig := "Ht_Items(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    Result := []
    Result.SetCapacity(HashTable.Count())
    return Ht_Fold(Func("_Ht_ItemsAux"), Result, HashTable)
}

Ht_Keys(HashTable)
{
    local
    Sig := "Ht_Keys(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return Array_Zip(Ht_Items(HashTable)*)[1]
}

Ht_Values(HashTable)
{
    local
    Sig := "Ht_Values(HashTable)"
    _Validate_HashTableArg(Sig, "HashTable", HashTable)
    return Array_Zip(Ht_Items(HashTable)*)[2]
}
