class Long {

	requires() {
		return [Math]
	}

	static DIGITS
			:= ["0", "1", "2", "3", "4", "5"
			, "6", "7", "8", "9", "a", "b"
			, "c", "d", "e", "f", "g", "h"
			, "i", "j", "k", "l", "m", "n"
			, "o", "p", "q", "r", "s", "t"
			, "u", "v", "w", "x", "y", "z"]

	toUnsignedString(i, shift) {
		buf := []
		charPos := 64
		radix := I(1 << shift)
		mask := radix - 1
		loop {
			buf[--charPos] := Long.DIGITS[I(i & mask)+1]
			i := Math.zeroFillShiftR(i, shift)
		} until (i = 0)
		st := ""
		loop % 64 - charPos {
			st := st . buf[charPos + A_Index - 1]
		}
		return st
	}

	toBinaryString(i) {
		return Long.toUnsignedString(i, 1)
	}

	toHexString(i) {
		return Long.toUnsignedString(i, 4)
	}

	toOctalString(i) {
		return Long.toUnsignedString(i, 3)
	}
}
