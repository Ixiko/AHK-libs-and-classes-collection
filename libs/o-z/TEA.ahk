/*
---------------------------------------------------------------------------
Function:
    To encrypt/decrypt string using Tiny Encryption Algorithm
---------------------------------------------------------------------------
*/

Encrypt( _String, _Password ) {
    PWD2Key( _Password, k1, k2, k3, k4, k5 )
    i = 9
    p = 0
    OutString =
    Loop, Parse, _String, `n, `r
    {
        ThisLine := A_LoopField
        L =
        Loop, % StrLen( ThisLine )
        {
            i++
            IfGreater i, 8, {
                u := p
                v := k5
                p++
                TEA( u, v, k1, k2, k3, k4 )
                Stream9( u, v )
                i = 0
            }
            StringMid, c, ThisLine, A_Index, 1
            a := Asc(c)
            if a between 32 and 126
            {
                a += s%i%
                IfGreater a, 126, SetEnv, a, % a - 95
                c := Chr(a)
            }
            L := L . c
        }
        OutString .= L . "`n"
    }
    StringTrimRight, OutString, OutString, 1
    return OutString
}

Decrypt( _String, _Password ) {
    PWD2Key( _Password, k1, k2, k3, k4, k5 )
    i = 9
    p = 0
    OutString =
    Loop, Parse, _String, `n, `r
    {
        ThisLine := A_LoopField
        L =
        Loop, % StrLen( ThisLine )
        {
            i++
            IfGreater i, 8, {
                u := p
                v := k5
                p++
                TEA( u, v, k1, k2, k3, k4 )
                Stream9( u, v )
                i = 0
            }
            StringMid, c, ThisLine, A_Index, 1
            a := Asc(c)
            if a between 32 and 126
            {
                a -= s%i%
                IfLess a, 32, SetEnv, a, % a + 95
                c := Chr(a)
            }
            L := L . c
        }
        OutString .= L . "`n"
    }
    StringTrimRight, OutString, OutString, 1
    return OutString
}

PWD2Key( PW, ByRef k1, ByRef k2, ByRef k3, ByRef k4, ByRef k5 ) {
    CBC( k1, k2, PW, 1, 2, 3, 4 )
    CBC( k3, k4, PW, 4, 3, 2, 1 )
    k5 := k1 ^ k2 ^ k3 ^ k4
}

CBC( ByRef u, ByRef v, x, k0, k1, k2, k3 ) {
    u = 0
    v = 0
    Loop, % Ceil( StrLen(x) / 8 )
    {
        p = 0
        StringLeft, c, x, 4
        Loop, Parse, c
            p := ( p << 8 ) + Asc( A_LoopField )
        u := u ^ p
        p = 0
        StringMid, c, x, 5, 4
        Loop, Parse, c
            p := ( p << 8 ) + Asc( A_LoopField )
        v := v ^ p
        TEA( u, v, k0, k1, k2, k3 )
        StringTrimLeft, x, x, 8
    }
}

TEA( ByRef y, ByRef z, k0, k1, k2, k3 ) {
    IntFormat := A_FormatInteger
    SetFormat Integer, D
    s = 0
    d = 0x9E3779B9
    Loop, 32
    {
      k := "k" . s & 3
      y := 0xFFFFFFFF & ( y + ( ( z << 4 ^ z >> 5 ) + z  ^  s + %k% ) )
      s := 0xFFFFFFFF & ( s + d )
      k := "k" . s >> 11 & 3
      z := 0xFFFFFFFF & ( z + ( ( y << 4 ^ y >> 5 ) + y  ^  s + %k% ) )
    }
    SetFormat Integer, %IntFormat%
    y += 0
    z += 0
}

Stream9( x, y ) {
    Local z
    s0 := Floor( x * 0.000000022118911147 )
    Loop, 8
    {
        z := ( y << 25 ) + ( x >> 7 ) & 0xFFFFFFFF
        y := ( x << 25 ) + ( y >> 7 ) & 0xFFFFFFFF
        x := z
        s%A_Index% := Floor( x * 0.000000022118911147 )
    }
}
