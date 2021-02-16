BitRotateL(nmb, t="1", type="UChar") {

	r := BRCheck(t, type)
	if !r
		return 0

	Loop, % t {
		msb := (nmb & 2**(r-1)) ? 1 : 0		          	; 2^(r-1) should be the leftmost bit
		nmb := (nmb << 1 & (2**r -1)) + msb  	; 2^r-1 should be number's bytes less extra byte
		}

return nmb
}

BitRotateR(ByRef nmb, t="1", type="UChar") {

	r := BRCheck(t, type)
	if !r
		return 0
	Loop, % t		{
		lsb := (nmb & 0x1) ? 2**(r - 1) : 0	; 2^(r-1) should become the leftmost bit
		nmb := (nmb >> 1) + lsb
	}

return 1
}

BRCheck(a, b) {

	if (a < 1 || a > 63 || b not in UChar,UShort,UInt,UInt64)
		return 0

	Loop, Parse, % "UChar|UShort|UInt|UInt64", |
	{
		; find number length in bits
		if (A_LoopField == b)		{
			mT := 4*(2**A_Index)
			break
		}
	}

return mT
}
