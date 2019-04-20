Base32Encode(Decoded, UseHex := FALSE)
{
    Local Encoded, J, N, S
        , Chars  := UseHex ? '0123456789ABCDEFGHIJKLMNOPQRSTUV' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'
        , Length := VarSetCapacity(UTF8, StrPut(Decoded, 'UTF-8') - 1)
        , I      := 0

    StrPut(Decoded, &UTF8, 'UTF-8')
    VarSetCapacity(Encoded, Length * 2)

    While (I < Length)
    {
        J := N := 0
        S := 40

        Loop (5)
            N += NumGet(&UTF8 + I++, 'UChar') << (8 * (5 - ++J))
        Until (I >= Length)

        Loop (Ceil((8 * J) / 5))
            Encoded .= SubStr(Chars, ((N >> (S -= 5)) & 0x1F) + 1, 1)
    }
    
    Loop ((40 - (J * 8)) // 5)
        Encoded .= '='

    Return (Encoded)
}




Base32Decode(Encoded, UseHex := FALSE)
{
    Local Decoded
        , I := J := K := 0
        , Chars := UseHex ? '0123456789ABCDEFGHIJKLMNOPQRSTUV' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

    VarSetCapacity(Decoded, StrLen(Encoded) * 2) 

    Loop Parse, Encoded
    {
        If (!(N := InStr(Chars, A_LoopField)))
            break

        K += --N << (5 * (8 - ++J))
        If (J == 8)
        {
            S := 40
            Loop (5)
                NumPut((K >> (S -= 8)) & 0xFF, &Decoded + I++, 'Uchar')
            J := K := 0
    }   }
    
    If (J < 8)
    {
        S := 40
        Loop (Ceil((5 * J) / 8))
            NumPut((K >> (S -= 8)) & 0xFF, &Decoded + I++, 'Uchar')
    }

    Return (StrGet(&Decoded, I, 'UTF-8'))
}
