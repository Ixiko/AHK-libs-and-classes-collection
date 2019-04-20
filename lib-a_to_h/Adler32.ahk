Adler32(String)
{
    Local a := 1
        , b := 0

    Loop Parse, String
        b := Mod(b + (a := Mod(a + Ord(A_LoopField), 0xFFF1)), 0xFFF1)

    Return (Format('0x{:X}', (b << 16) | a))
}
