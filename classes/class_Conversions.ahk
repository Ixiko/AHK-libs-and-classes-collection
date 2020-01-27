class Conversions {
	HexToInt(HexString) {
		if !(SubStr(HexString, 1, 2) = "0x") {
			Throw, Exception("HexToInt can not convert non-hex (" HexString ") to int")
		}
	
		Base := StrLen(HexString) - 2 ; Subtract out the 0x
		Decimal := 0
		
		for k, Character in StrSplit(SubStr(HexString, 3)) {
			CharacterCode := Asc(Character)
			
			if (Asc("0") <= CharacterCode && CharacterCode <= Asc("9")) {
				CharacterCode := (CharacterCode - 48)
			}
			else if (Asc("a") <= CharacterCode && CharacterCode <= Asc("f")) {
				CharacterCode := (CharacterCode - 97) + 10
			}
			else if (Asc("A") <= CharacterCode && CharacterCode <= Asc("F")) {
				CharacterCode := (CharacterCode - 65) + 10
			}
			
			Decimal += CharacterCode * (16 ** --Base)
		}
		
		return Decimal
	}
	BinToInt(BinString) {
		if !(SubStr(BinString, 1, 2) = "0b") {
			Throw, Exception("BinToInt can not convert non-binary (" BinString ") to int")
		}
		
		Base := StrLen(BinString) - 2
		Decimal := 0
		
		for k, Character in StrSplit(SubStr(BinString, 3)) {
			Decimal += Character * (2 ** --Base)
		}
		
		return Decimal
	}
	OctToInt(OctString) {
		if !(SubStr(OctString, 1, 2) = "0o") {
			Throw, Exception("OctToInt can not convert non-octal (" OctString ") to int")
		}
		
		Base := StrLen(OctString) - 2
		Decimal := 0
		
		for k, Character in StrSplit(SubStr(OctString, 3)) {
			Decimal += Character * (8 ** --Base)
		}
		
		return Decimal
	}
	IntToHex(Int, NoZeros := True) {
		if !(IsNumber(Int)) {
			return "0x00"
		}
	
		static HexCharacters := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
		End := (NoZeros ? "" : "0x")
		HexString := ""
		Quotient := Int
		
		loop {
			Remainder := Mod(Quotient, 16)
			HexString := HexCharacters[Remainder + 1] HexString
			Quotient := Floor(Quotient / 16)
		} until (Quotient = 0)
		
		loop % 2 - StrLen(HexString) {
			HexString := "0" HexString
		}
		
		if (Mod(StrLen(HexString), 2)) {
			HexString := "0" HexString
		}
		
		return End HexString
	}
	
	IsNumber(Value) {
		if Value is Integer
			return true
		
		return false
	}
	IsFloat(Value) {
		if Value is Float
			return true
	
		return false
	}
	FloatToBinaryInt(Float) {
		VarSetCapacity(Buffer, 8, 0)
		NumPut(Float, &Buffer + 0, 0, "Double")
		return NumGet(&Buffer + 0, 0, "UInt64")
	}
	
	SplitIntoBytes32(Integer) {
		Array := []
	
		loop, % 4 {
			Array.Push((Integer >> ((A_Index - 1) * 8)) & 0xFF)
		}
		
		return Array
	}
	SplitIntoBytes64(Integer) {
		FirstFour := SplitIntoBytes32((Integer & 0x00000000FFFFFFFF) >> 0)
		LastFour := SplitIntoBytes32((Integer & 0x7FFFFFFF00000000) >> 32)
	
		return [FirstFour[1], FirstFour[2], FirstFour[3], FirstFour[4], LastFour[1], LastFour[2], LastFour[3], LastFour[4]]
	}
	NumberSizeOf(Number, ReturnNumber := true) {
		static Sizes := {8: "I8", 16: "I16", 32: "I32", 64: "I64"}
	
		loop 64 {
			NextBit := Number & (1 << (64 - A_Index))
		
			if (NextBit) {
				Length := A_Index - 1
				break
			}
		}
		
		NewLength := 64 - Length
		
		while !(Sizes.HasKey(NewLength)) {
			NewLength++
		}
		
		return (ReturnNumber ? NewLength : Sizes[NewLength])
	}
}