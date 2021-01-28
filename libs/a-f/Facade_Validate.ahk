#Include <Is>
#Include <Type>
#Include <IsFuncObj>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       Oh, what a mess we create, when all our types we do conflate!        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------------------------------------
; Auxiliary Functions

_Validate_TypeRepr(Value)
{
    local
    Type := Type(Value)
    ; "Applicable Bindable Func" is valid but rarely useful.
    return Type == "_Func_Applicable" ? "Applicable " . _Validate_TypeRepr(Value._Obj)
         : Type == "_Func_Bindable"   ? "Bindable " . _Validate_TypeRepr(Value._Func)
         : Type
}

_Validate_ValueRepr(Value)
{
    local
    if (Is(Value, "object"))
    {
        Result := _Validate_TypeRepr(Value)
    }
    else if (Is(Value, "number"))
    {
        Result := Value
    }
    else
    {
        EscSeqs := {"`a": "``a"
                   ,"`b": "``b"
                   ,"`t": "``t"
                   ,"`n": "``n"
                   ,"`v": "``v"
                   ,"`f": "``f"
                   ,"`r": "``r"
                   ,"""": """"""
                   ,"``": "````"}
        Result := """"
        for _, Char in StrSplit(Value)
        {
            Result .= EscSeqs.HasKey(Char) ? EscSeqs[Char]
                    : Char
        }
        Result .= """"
    }
    return Result
}

_Validate_UnwrapObj(Value)
{
    local
    return Type(Value) == "_Func_Applicable" ? Value._Obj
         : Value
}

_Validate_Blame(Sig, Func)
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
            RegExMatch(E["Extra"], "O)  Key not found.  Key is .*\.$", Match)
            throw Exception("Key Error", -2
                           ,Sig . Match.Value(0))
        }
        else
        {
            throw E
        }
    }
    return Result
}

;-------------------------------------------------------------------------------
; Type Error Reporting

_Validate_StringArgs(Sig, Args)
{
    local
    loop % Args.Length()
    {
        if (not Args.HasKey(a_index))
        {
            throw Exception("Missing Argument Error", -2
                           ,Sig)
        }
        if (Is(Args[a_index], "object"))
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid argument " . _Validate_TypeRepr(Args[a_index]) . ".")
        }
    }
}

_Validate_NumberArg(Sig, Var, Value)
{
    local
    if (not Is(Value, "number"))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not a number.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_NumberArgs(Sig, Args)
{
    local
    loop % Args.Length()
    {
        if (not Args.HasKey(a_index))
        {
            throw Exception("Missing Argument Error", -2
                           ,Sig)
        }
        if (not Is(Args[a_index], "number"))
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid argument " . _Validate_TypeRepr(Args[a_index]) . ".")
        }
    }
}

_Validate_IntegerArg(Sig, Var, Value)
{
    local
    if (not Is(Value, "integer"))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not an integer.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_NumberOrStringArg(Sig, Var, Value)
{
    local
    if (Is(Value, "object"))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not a number or string.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_FuncArg(Sig, Var, Value)
{
    local
    if (not IsFuncObj(Value))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not a function object.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_FuncArgs(Sig, Args)
{
    local
    loop % Args.Length()
    {
        if (not Args.HasKey(a_index))
        {
            throw Exception("Missing Argument Error", -2
                           ,Sig)
        }
        if (not IsFuncObj(Args[a_index]))
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid argument " . _Validate_TypeRepr(Args[a_index]) . ".")
        }
    }
}

_Validate_ObjArg(Sig, Var, Value)
{
    local
    if (not Is(Value, "object"))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not an object.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_ObjectArg(Sig, Var, Value)
{
    local
    if (not Type(_Validate_UnwrapObj(Value)) == "Object")
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not an Object.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_BadArrayArg(Sig, Var, Value)
{
    local
    if (not Type(_Validate_UnwrapObj(Value)) == "Object")
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not an Array.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

_Validate_ArrayArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_BadArrayArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    loop % Value.Length()
    {
        if (not Value.HasKey(a_index))
        {
            throw Exception("Value Error", -2
                           ,Sig . "  " . Var . " is missing elements.")
        }
    }
    ; This test must be performed after ensuring the necessary positive integer
    ; keys exist.
    if (not Value.Length() == Value.Count())
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not an Array.  " . Var . " contains indices that are not positive integers.")
    }
}

_Validate_ArrayArgs(Sig, Args)
{
    local
    loop % Args.Length()
    {
        if (not Args.HasKey(a_index))
        {
            throw Exception("Missing Argument Error", -2
                           ,Sig)
        }
        if (not Type(_Validate_UnwrapObj(Args[a_index])) == "Object")
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid argument " . _Validate_TypeRepr(Args[a_index]) . ".")
        }
        CurrentArray := Args[a_index]
        loop % CurrentArray.Length()
        {
            if (not CurrentArray.HasKey(a_index))
            {
                throw Exception("Value Error", -2
                               ,Sig . "  Invalid argument.  It is missing elements.")
            }
        }
        ; This test must be performed after ensuring the necessary positive
        ; integer keys exist.
        if (not Args[a_index].Length() == Args[a_index].Count())
        {
            throw Exception("Type Error", -2
                           ,Sig . "  Invalid argument.  It contains indices that are not positive integers.")
        }
    }
}

_Validate_HashTableArg(Sig, Var, Value)
{
    local
    global HashTable
    if (not Is(_Validate_UnwrapObj(Value), HashTable))
    {
        throw Exception("Type Error", -2
                       ,Sig . "  " . Var . " is not a HashTable.  " . Var . "'s type is " . _Validate_TypeRepr(Value) . ".")
    }
}

;-------------------------------------------------------------------------------
; Value Error Reporting

_Validate_DivisorArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (Value == 0)
    {
        throw Exception("Division by Zero Error", -2
                       ,Sig)
    }
}

_Validate_Neg1To1NumberArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (not (-1 <= Value and Value <= 1))
    {
        throw Exception("Value Error", -2
                       ,Sig . "  " . Var . " is not in the interval [-1, 1].  " . Var . " is " . Value . ".")
    }
}

_Validate_NonNegNumberArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (Value < 0)
    {
        throw Exception("Value Error", -2
                       ,Sig . "  " . Var . " is negative.  " . Var . " is " . Value . ".")
    }
}

_Validate_NonNegIntegerArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_IntegerArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (Value < 0)
    {
        throw Exception("Value Error", -2
                       ,Sig . "  " . Var . " is negative.  " . Var . " is " . Value . ".")
    }
}

_Validate_NonEmptyArrayArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_ArrayArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (Value.Length() == 0)
    {
        throw Exception("Value Error", -2
                       ,Sig . "  " . Var . " is an empty Array.")
    }
}

_Validate_NonEmptyHashTableArg(Sig, Var, Value)
{
    local
    try
    {
        _Validate_HashTableArg(Sig, Var, Value)
    }
    catch E
    {
        throw Exception(E["Message"], -2, E["Extra"])
    }
    if (Value.Count() == 0)
    {
        throw Exception("Value Error", -2
                       ,Sig . "  " . Var . " is an empty HashTable.")
    }
}
