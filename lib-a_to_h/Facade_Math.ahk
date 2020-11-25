#Include <Is>
#Include <Validate>

Math_Abs(X)
{
    local
    Sig := "Math_Abs(X)"
    _Validate_NumberArg(Sig, "X", X)
    if (Is(X, "integer") and X == -9223372036854775808)
    {
        throw Exception("Value Error", -1
                       ,Sig . "  X has no 64-bit non-negative equal in magnitude.  X is -9223372036854775808.")
    }
    return Abs(X)
}

Math_Ceil(X)
{
    local
    Sig := "Math_Ceil(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Ceil(X)
}

Math_Exp(X)
{
    local
    Sig := "Math_Exp(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Exp(X)
}

Math_Floor(X)
{
    local
    Sig := "Math_Floor(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Floor(X)
}

Math_Log(X)
{
    local
    Sig := "Math_Log(X)"
    _Validate_NonNegNumberArg(Sig, "X", X)
    return Log(X)
}

Math_Ln(X)
{
    local
    Sig := "Math_Ln(X)"
    _Validate_NonNegNumberArg(Sig, "X", X)
    return Ln(X)
}

Math_Max(Numbers*)
{
    local
    Sig := "Math_Max(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    if (Numbers.Length() == 0)
    {
        throw Exception("Arity Error", -1
                       ,Sig . "  Called with 0 arguments.")
    }
    return Max(Numbers*)
}

Math_Min(Numbers*)
{
    local
    Sig := "Math_Min(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    if (Numbers.Length() == 0)
    {
        throw Exception("Arity Error", -1
                       ,Sig . "  Called with 0 arguments.")
    }
    return Min(Numbers*)
}

Math_Mod(X, Y)
{
    local
    Sig := "Math_Mod(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_DivisorArg(Sig, "Y", Y)
    return X - Y * (X // Y)
}

Math_Rem(X, Y)
{
    local
    Sig := "Math_Rem(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_DivisorArg(Sig, "Y", Y)
    return Mod(X, Y)
}

_Math_CCeil(X)
{
    local
    return DllCall("msvcrt\ceil", "double", X, "cdecl double")
}

_Math_CFloor(X)
{
    local
    return DllCall("msvcrt\floor", "double", X, "cdecl double")
}

Math_Round(X, N := 0)
{
    local
    Sig := "Math_Round(X [, N])"
    _Validate_NumberArg(Sig, "X", X)
    _Validate_IntegerArg(Sig, "N", N)
    Multiplier    := N == 0 ? 1 : 10 ** N
    MovedPoint    := X * Multiplier
    ; Mod is intentionally used as Rem.
    AbsRem        := Abs(Mod(MovedPoint, 1))
    ; DLLCalls are used to avoid integer overflow.
    Rounded       := AbsRem < 0.5 ? X >= 0.0 ? _Math_CFloor(MovedPoint) : _Math_CCeil(MovedPoint)
                   : AbsRem > 0.5 ? X >= 0.0 ? _Math_CCeil(MovedPoint)  : _Math_CFloor(MovedPoint)
                   : Mod(_Math_CCeil(MovedPoint), 2) == 0.0 ? _Math_CCeil(MovedPoint) : _Math_CFloor(MovedPoint)
    RestoredPoint := Rounded / Multiplier
    if (N > 0)
    {
        ; Format does not work.
        Halves := StrSplit(RestoredPoint, ".")
        Halves[2] := SubStr(Halves[2], 1, N)
        while (StrLen(Halves[2]) < N)
        {
            Halves[2] .= "0"
        }
        Result := Halves[1] . "." . Halves[2]
    }
    else
    {
        Result := RestoredPoint & -1
    }
    return Result
}

Math_Sqrt(X)
{
    local
    Sig := "Math_Sqrt(X)"
    _Validate_NonNegNumberArg(Sig, "X", X)
    return Sqrt(X)
}

Math_Sin(X)
{
    local
    Sig := "Math_Sin(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Sin(X)
}

Math_Cos(X)
{
    local
    Sig := "Math_Cos(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Cos(X)
}

Math_Tan(X)
{
    local
    Sig := "Math_Tan(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Tan(X)
}

Math_ASin(X)
{
    local
    Sig := "Math_ASin(X)"
    _Validate_Neg1To1NumberArg(Sig, "X", X)
    return ASin(X)
}

Math_ACos(X)
{
    local
    Sig := "Math_ACos(X)"
    _Validate_Neg1To1NumberArg(Sig, "X", X)
    return ACos(X)
}

Math_ATan(X)
{
    local
    Sig := "Math_ATan(X)"
    _Validate_NumberArg(Sig, "X", X)
    return ATan(X)
}

Math_BitLsr(X, N)
{
    local
    Sig := "Math_BitLsr(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
    _Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? 0 : X >> N & (1 << 63 >> N << 1 ^ -1)
}

Math_Bin(X)
{
    local
    Sig := "Math_Bin(X)"
    _Validate_IntegerArg(Sig, "X", X)
    Digits := ["0000"
              ,"0001"
              ,"0010"
              ,"0011"
              ,"0100"
              ,"0101"
              ,"0110"
              ,"0111"
              ,"1000"
              ,"1001"
              ,"1010"
              ,"1011"
              ,"1100"
              ,"1101"
              ,"1110"
              ,"1111"]
    Result := ""
    loop 16
    {
        Result := Digits[(Math_BitLsr(X, 4 * (a_index - 1)) & 0xF) + 1] . Result
    }
    return "0b" . Result
}

Math_Hex(X)
{
    local
    Sig := "Math_Hex(X)"
    _Validate_IntegerArg(Sig, "X", X)
    return Format("0x{:016X}", X)
}

Math_Integer(X)
{
    local
    Sig := "Math_Integer(X)"
    if (X ~= "^[ \t]*[-+]?0(?:[bB][01]+|[xX][0-9A-Fa-f]+)[ \t]*$")
    {
        Digits := {"0":  0
                  ,"1":  1
                  ,"2":  2
                  ,"3":  3
                  ,"4":  4
                  ,"5":  5
                  ,"6":  6
                  ,"7":  7
                  ,"8":  8
                  ,"9":  9
                  ,"A": 10
                  ,"B": 11
                  ,"C": 12
                  ,"D": 13
                  ,"E": 14
                  ,"F": 15}
        RegExMatch(X, "O)(?<Sign>[-+]?)0(?<Radix>[bBxX])(?<Number>[0-9A-Fa-f]+)", Match)
        BitWidth := Match.Value("Radix") = "b" ? 1 : 4
        Number := Match.Value("Number")
        X := 0
        while (Number != "")
        {
            X <<= BitWidth
            X |= Digits[SubStr(Number, 1, 1) . ""]
            Number := SubStr(Number, 2)
        }
        X := Match.Value("Sign") == "-" ? -X : X
    }
    else if (X ~= "^[ \t]*[-+]?\d+[eE][-+]?\d+[ \t]*$")
    {
        X := Math_Float(X)
    }
    _Validate_NumberArg(Sig, "X", X)
    return X & -1
}

Math_Float(X)
{
    local
    Sig := "Math_Float(X)"
    if (X ~= "^[ \t]*[-+]?0(?:[bB][01]+|[xX][0-9A-Fa-f]+)[ \t]*$")
    {
        X := Math_Integer(X)
    }
    else if (X ~= "^[ \t]*[-+]?\d+[eE][-+]?\d+[ \t]*$")
    {
        X := StrReplace(X, "e", ".e")
    }
    _Validate_NumberArg(Sig, "X", X)
    return X + 0.0
}
