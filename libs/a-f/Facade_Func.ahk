#Include <Is>
#Include <Validate>
#Include <Op>

class _Func_Bindable
{
    __New(Func)
    {
        local
        global _Func_Bindable
        if (Is(Func, _Func_Bindable))
        {
            Result := Func
        }
        else
        {
            this._Func     := Func
            this._Bindings := []
            Result := this
        }
        return Result
    }

    Bind(Args*)
    {
        local
        Result := Func_Bindable(this._Func)
        Result._Bindings.Push(this._Bindings*)
        Result._Bindings.Push(Args*)
        return Result
    }

    Call(Args*)
    {
        local
        FullArgs := []
        FullArgs.Push(this._Bindings*)
        FullArgs.Push(Args*)
        return this._Func.Call(FullArgs*)
    }

    __Get(Key)
    {
        local
        ; Members we did not override pass through.
        if (Key != "base" and not this.base.HasKey(Key))
        {
            return this._Func[Key]
        }
    }

    __Call(Method, Args*)
    {
        local
        ; %Func%(Args*)
        if (Method == "")
        {
            return this.Call(Args*)
        }
    }
}

Func_Bindable(Func)
{
    local
    global _Func_Bindable
    Sig := "Func_Bindable(Func)"
    _Validate_FuncArg(Sig, "Func", Func)
    return new _Func_Bindable(Func)
}

class _Func_Applicable extends _Func_Bindable
{
    __New(Obj)
    {
        local
        global _Func_Applicable
        if (Is(Obj, _Func_Applicable))
        {
            Result := Obj
        }
        else
        {
            this._Obj      := Obj
            this._Bindings := []
            Result := this
        }
        return Result
    }

    Clone()
    {
        local
        Result := Func_Applicable(this._Obj.Clone())
        Result._Bindings.Push(this._Bindings*)
        return Result
    }

    Bind(Args*)
    {
        local
        Result := Func_Applicable(this._Obj)
        Result._Bindings.Push(this._Bindings*)
        Result._Bindings.Push(Args*)
        return Result
    }

    Call(Args*)
    {
        local
        FullArgs := []
        FullArgs.Push(this._Bindings*)
        FullArgs.Push(Args*)
        return Op_Get(this._Obj, FullArgs*)
    }

    __Get(Key)
    {
        local
        ; Members we did not override pass through.
        if (Key != "base" and not this.base.HasKey(Key))
        {
            return Op_Get(this._Obj, Key)
        }
    }

    __Call(Method, Args*)
    {
        local
        ; %Func%(Args*)
        if (Method == "")
        {
            return this.Call(Args*)
        }
        ; Members we did not override pass through.
        if (not this.base.HasKey(Method))
        {
            return (this._Obj)[Method](Args*)
        }
    }
}

Func_Applicable(Obj)
{
    local
    global _Func_Applicable
    Sig := "Func_Applicable(Obj)"
    _Validate_ObjArg(Sig, "Obj", Obj)
    return new _Func_Applicable(Obj)
}

Func_Apply(Func, Args)
{
    local
    Sig := "Func_Apply(Func, Args)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_BadArrayArg(Sig, "Args", Args)
    return Func.Call(Args*)
}

_Func_CompAux(Funcs, Args*)
{
    local
    Index  := Funcs.Length()
    Result := Funcs[Index].Call(Args*)
    --Index
    while (Index >= 1)
    {
        Result := Funcs[Index].Call(Result)
        --Index
    }
    return Result
}

Func_Comp(Funcs*)
{
    local
    Sig := "Func_Comp(Funcs*)"
    _Validate_FuncArgs(Sig, Funcs)
    return Funcs.Length() == 0 ? Func_Bindable(Func("Func_Id"))
         : Funcs.Length() == 1 ? Func_Bindable(Funcs[1])
         : Func_Bindable(Func("_Func_CompAux").Bind(Funcs))
}

_Func_ReparamAux(Func, Positions, Args*)
{
    local
    NewArgs     := []
    MaxPosition := 0
    for Destination, Source in Positions
    {
        NewArgs[Destination] := Args[1 + Source]
        MaxPosition          := 1 + Source > MaxPosition ? 1 + Source
                              : MaxPosition
    }
    while (MaxPosition < Args.Length())
    {
        ++MaxPosition
        NewArgs.Push(Args[MaxPosition])
    }
    return Func.Call(NewArgs*)
}

Func_Reparam(Func, Positions)
{
    local
    Sig := "Func_Reparam(Func, Positions)"
    _Validate_FuncArg(Sig, "Func", Func)
    _Validate_BadArrayArg(Sig, "Positions", Positions)
    FilteredPositions := []
    for Index, Value in Positions
    {
        if (    Is(Index, "integer")
            and 1 <= Index)
        {
            if (not Is(Value, "integer"))
            {
                throw Exception("Type Error", -1
                               ,Sig . "  Invalid position " . _Validate_TypeRepr(Value) . ".")
            }
            if (not 0 <= Value)
            {
                throw Exception("Value Error", -1
                               ,Sig . "  Invalid position " . Value . ".")
            }
            FilteredPositions[Index] := Value
        }
    }
    return Func_Bindable(Func("_Func_ReparamAux").Bind(Func, FilteredPositions))
}

Func_Flip(F)
{
    local
    Sig := "Func_Flip(F)"
    _Validate_FuncArg(Sig, "F", F)
    return Func_Reparam(F, [1, 0])
}

Func_Id(X)
{
    local
    return X
}

Func_Const(X)
{
    local
    ; Function objects ignore excess arguments.
    ;
    ; Make it bindable, not because binding is useful here, but because
    ; Bind(Args*) is expected to return a function object.
    return Func_Bindable(Func("Func_Id").Bind(X))
}

_Func_OnAux(G, F, X, Y)
{
    local
    return G.Call(F.Call(X), F.Call(Y))
}

Func_On(G, F)
{
    local
    Sig := "Func_On(G, F)"
    _Validate_FuncArg(Sig, "G", G)
    _Validate_FuncArg(Sig, "F", F)
    return Func_Bindable(Func("_Func_OnAux").Bind(G, F))
}

Func_Hook1(G, F)
{
    local
    Sig := "Func_Hook1(G, F)"
    _Validate_FuncArg(Sig, "G", G)
    _Validate_FuncArg(Sig, "F", F)
    return Func_Dup(Func_Hook2(G, F))
}

_Func_Hook2Aux(G, F, X, Y)
{
    local
    return G.Call(X, F.Call(Y))
}

Func_Hook2(G, F)
{
    local
    Sig := "Func_Hook2(G, F)"
    _Validate_FuncArg(Sig, "G", G)
    _Validate_FuncArg(Sig, "F", F)
    return Func_Bindable(Func("_Func_Hook2Aux").Bind(G, F))
}

_Func_ForkAux(F, H, G, Args*)
{
    local
    return H.Call(F.Call(Args*), G.Call(Args*))
}

Func_Fork(F, H, G)
{
    local
    Sig := "Func_Fork(F, H, G)"
    _Validate_FuncArg(Sig, "F", F)
    _Validate_FuncArg(Sig, "H", G)
    _Validate_FuncArg(Sig, "G", G)
    return Func_Bindable(Func("_Func_ForkAux").Bind(F, H, G))
}

Func_Dup(F)
{
    local
    Sig := "Func_Dup(F)"
    _Validate_FuncArg(Sig, "F", F)
    return Func_Reparam(F, [0, 0])
}

_Func_NotAux(Pred, Args*)
{
    local
    return not Pred.Call(Args*)
}

Func_Not(Pred)
{
    local
    Sig := "Func_Not(Pred)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    return Func_Bindable(Func("_Func_NotAux").Bind(Pred))
}

_Func_AndAux(Preds, Args*)
{
    local
    Index  := 1
    Result := Preds[Index].Call(Args*)
    ++Index
    while (Result and Index <= Preds.Length())
    {
        Result := Preds[Index].Call(Args*)
        ++Index
    }
    return Result
}

Func_And(Preds*)
{
    local
    Sig := "Func_And(Preds*)"
    _Validate_FuncArgs(Sig, Preds)
    return Preds.Length() == 0 ? Func_Const(true)
         : Preds.Length() == 1 ? Func_Bindable(Preds[1])
         : Func_Bindable(Func("_Func_AndAux").Bind(Preds))
}

_Func_OrAux(Preds, Args*)
{
    local
    Index  := 1
    Result := Preds[Index].Call(Args*)
    ++Index
    while (not Result and Index <= Preds.Length())
    {
        Result := Preds[Index].Call(Args*)
        ++Index
    }
    return Result
}

Func_Or(Preds*)
{
    local
    Sig := "Func_Or(Preds*)"
    _Validate_FuncArgs(Sig, Preds)
    return Preds.Length() == 0 ? Func_Const(false)
         : Preds.Length() == 1 ? Func_Bindable(Preds[1])
         : Func_Bindable(Func("_Func_OrAux").Bind(Preds))
}

_Func_IfAux(Pred, ThenFunc, ElseFunc, Args*)
{
    local
    return Pred.Call(Args*) ? ThenFunc.Call(Args*) : ElseFunc.Call(Args*)
}

Func_If(Pred, ThenFunc, ElseFunc)
{
    local
    Sig := "Func_If(Pred, ThenFunc, ElseFunc)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    _Validate_FuncArg(Sig, "ThenFunc", ThenFunc)
    _Validate_FuncArg(Sig, "ElseFunc", ElseFunc)
    return Func_Bindable(Func("_Func_IfAux").Bind(Pred, ThenFunc, ElseFunc))
}

_Func_ConvAux(F, X)
{
    local
    PredecessorX := {}
    while (not X == PredecessorX)
    {
        PredecessorX := X
        X            := F.Call(X)
    }
    return X
}

Func_Conv(F)
{
    local
    Sig := "Func_Conv(F)"
    _Validate_FuncArg(Sig, "F", F)
    return Func_Bindable(Func("_Func_ConvAux").Bind(F))
}

_Func_AdverseAux(Funcs, Args*)
{
    local
    Failed := true
    Index  := 1
    while (Failed and Index <= Funcs.Length())
    {
        try
        {
            Result := Funcs[Index].Call(Args*)
            Failed := false
        }
        catch E
        {
            ++Index
        }
    }
    if (Failed)
    {
        throw E
    }
    return Result
}

Func_Adverse(Funcs*)
{
    local
    Sig := "Func_Adverse(Funcs*)"
    _Validate_FuncArgs(Sig, Funcs)
    if (Funcs.Length() == 0)
    {
        throw Exception("Arity Error", -1
                       ,Sig . "  Called with 0 arguments.")
    }
    else if (Funcs.Length() == 1)
    {
        Result := Func_Bindable(Funcs[1])
    }
    else
    {
        Result := Func_Bindable(Func("_Func_AdverseAux").Bind(Funcs))
    }
    return Result
}
