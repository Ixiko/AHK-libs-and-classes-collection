#Include <Is>
#Include <Type>
#Include <IsFuncObj>
#Include <Validate>

Op_Get(Obj, Key)
{
    local
    Sig := "Op_Get(Obj, Key)"
    _Validate_ObjArg(Sig, "Obj", Obj)
    try
    {
        if (IsFuncObj(Obj.Get))
        {
            Result := Obj.Get(Key)
        }
        else
        {
            Obj := _Validate_UnwrapObj(Obj)
            if (Type(Obj) == "Object" and not ObjHasKey(Obj, Key))
            {
                throw Exception("Key Error")
            }
            Result := Obj[Key]
        }
    }
    catch E
    {
        if (E["Message"] == "Key Error")
        {
            throw Exception("Key Error", -1
                           ,Sig . "  Key not found.  Key is " . _Validate_ValueRepr(Key) . ".")
        }
        else
        {
            throw E
        }
    }
    return Result
}

Op_Pow(X, Y)
{
    local
    Sig := "Op_Pow(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_NumberArg(Sig, "Y", Y)
    if (X < 0 and Y != Y & -1)
    {
        throw Exception("Value Error", -1
                       ,Sig . "  Negative base with a fractional exponent.  X is " . X . " and Y is " . Y . ".")
    }
    if (X == 0 and Y < 0)
    {
        throw Exception("Division by Zero Error", -1
                       ,Sig . "  X is " . X . " and Y is " . Y . ".")
    }
    return X ** Y
}

Op_Neg(X)
{
    local
    Sig := "Op_Neg(X)"
    _Validate_NumberArg(Sig, "X", X)
    return -X
}

Op_BitNot(X)
{
    local
    Sig := "Op_BitNot(X)"
    _Validate_IntegerArg(Sig, "X", X)
    return X ^ -1
}

Op_Mul(X, Y)
{
    local
    Sig := "Op_Mul(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_NumberArg(Sig, "Y", Y)
    return X * Y
}

Op_Div(X, Y)
{
    local
    Sig := "Op_Div(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_DivisorArg(Sig, "Y", Y)
    return X / Y
}

Op_FloorDiv(X, Y)
{
    local
    Sig := "Op_FloorDiv(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_DivisorArg(Sig, "Y", Y)
    return X // Y
}

Op_Add(X, Y)
{
    local
    Sig := "Op_Add(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_NumberArg(Sig, "Y", Y)
    return X + Y
}

Op_Sub(X, Y)
{
    local
    Sig := "Op_Sub(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_NumberArg(Sig, "Y", Y)
    return X - Y
}

Op_BitAsl(X, N)
{
    local
    Sig := "Op_BitAsl(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? 0 : X << N
}

Op_BitAsr(X, N)
{
    local
    Sig := "Op_BitAsr(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? X >= 0 ? 0 : -1 : X >> N
}

Op_BitAnd(X, Y)
{
    local
    Sig := "Op_BitAnd(X, Y)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_IntegerArg(Sig, "Y", Y)
    return X & Y
}

Op_BitXor(X, Y)
{
    local
    Sig := "Op_BitXor(X, Y)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_IntegerArg(Sig, "Y", Y)
    return X ^ Y
}

Op_BitOr(X, Y)
{
    local
    Sig := "Op_BitOr(X, Y)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_IntegerArg(Sig, "Y", Y)
    return X | Y
}

Op_Concat(Strings*)
{
    local
    Sig := "Op_Concat(Strings*)"
    _Validate_StringArgs(Sig, Strings)
    Length := 0
    for _, String in Strings
    {
        Length += StrLen(String)
    }
    VarSetCapacity(Result, Length * 2)
    for _, String in Strings
    {
        Result .= String
    }
    return Result
}

Op_Lt(A, B)
{
    local
    Sig := "Op_Lt(A, B)"
    _Validate_NumberOrStringArg(Sig, "A", A)
    _Validate_NumberOrStringArg(Sig, "B", B)
    return A < B
}

Op_Gt(A, B)
{
    local
    Sig := "Op_Gt(A, B)"
    _Validate_NumberOrStringArg(Sig, "A", A)
    _Validate_NumberOrStringArg(Sig, "B", B)
    return A > B
}

Op_Le(A, B)
{
    local
    Sig := "Op_Le(A, B)"
    _Validate_NumberOrStringArg(Sig, "A", A)
    _Validate_NumberOrStringArg(Sig, "B", B)
    return A <= B
}

Op_Ge(A, B)
{
    local
    Sig := "Op_Ge(A, B)"
    _Validate_NumberOrStringArg(Sig, "A", A)
    _Validate_NumberOrStringArg(Sig, "B", B)
    return A >= B
}

Op_EqCi(A, B)
{
    local
    return A = B
}

Op_EqCs(A, B)
{
    local
    return A == B
}

Op_Ne(A, B)
{
    local
    return A != B
}
