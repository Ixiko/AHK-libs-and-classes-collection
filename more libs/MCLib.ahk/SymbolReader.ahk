class SymbolReaderBase {
	__New(pFileData, Length) {
		this.pData := pFileData
		this.Size := Length
	}
	
	ReadString(Offset, Length := -1) {
		if (Length > 0) {
			return StrGet(this.pData + Offset, Length, "UTF-8")
		}
		else {
			return StrGet(this.pData + Offset, "UTF-8")
		}
	}
	
	__Call(MethodName, Params*) {
		if (RegexMatch(MethodName, "O)Read(\w+)", Read) && Read[1] != "String") {
			return NumGet(this.pData + 0, Params[1], Read[1])
		}
	}
}

class PESymbolReader extends SymbolReaderBase {
	ReadSectionHeader(HeaderOffset) {
		Result := {}
		
		Result.Name            := this.ReadString(HeaderOffset, 8)
		Result.VirtualSize     :=   this.ReadUInt(HeaderOffset + 8)
		Result.VirtualAddress  :=   this.ReadUInt(HeaderOffset + 12)
		Result.FileSize        :=   this.ReadUInt(HeaderOffset + 16)
		Result.FileOffset      :=   this.ReadUInt(HeaderOffset + 20)
		Result.Characteristics :=   this.ReadUInt(HeaderOffset + 36)
		
		return Result
	}

	ReadSymbolHeader(SymbolNamesOffset, HeaderOffset) {
		Result := {}
		
		if (this.ReadUInt(HeaderOffset) != 0) {
			Result.Name := this.ReadString(HeaderOffset, 8)
		}
		else {
			Result.Name := this.ReadString(SymbolNamesOffset + this.ReadUInt(HeaderOffset + 4))
		}
		
		Result.Value          :=   this.ReadUInt(HeaderOffset + 8)
		Result.SectionIndex   := this.ReadUShort(HeaderOffset + 12)
		Result.Type           := this.ReadUShort(HeaderOffset + 14)
		Result.StorageClass   :=  this.ReadUChar(HeaderOffset + 16)
		Result.AuxSymbolCount :=  this.ReadUChar(HeaderOffset + 17)
		
		return Result
	}
	
	Read() {
		static SIZEOF_COFF_HEADER := 20
		static SIZEOF_SECTION_HEADER := 40
		static SIZEOF_SYMBOL := 18
		
		if (this.ReadUShort(0) != 0x8664) {
			Throw "Not a valid 64 bit PE object file"
		}
		
		SectionHeaderCount := this.ReadUShort(2)
		SizeOfOptionalHeader := this.ReadUShort(16)
		
		SectionHeaderTableOffset := SIZEOF_COFF_HEADER + SizeOfOptionalHeader
		
		Sections := []
		SectionsByName := {}
		
		loop, % SectionHeaderCount {
			Sections.Push(NextSection := this.ReadSectionHeader(SectionHeaderTableOffset + ((A_Index - 1) * SIZEOF_SECTION_HEADER)))
			
			SectionsByName[NextSection.Name] := NextSection
		}

		SymbolTableOffset := this.ReadUInt(8)
		SymbolCount := this.ReadUInt(12)
		SymbolNamesOffset := SymbolTableOffset + (SymbolCount * SIZEOF_SYMBOL)
		
		Symbols := []
		SymbolsByName := {}
		
		SymbolIndex := 0
		
		while (SymbolIndex < SymbolCount) {
			Symbols.Push(NextSymbol := this.ReadSymbolHeader(SymbolNamesOffset, SymbolTableOffset + (SymbolIndex * SIZEOF_SYMBOL)))
			
			SymbolsByName[NextSymbol.Name] := NextSymbol
			
			SymbolIndex += 1 + NextSymbol.AuxSymbolCount
		}

		TextSection := SectionsByName[".text"]

		RelocationSecton := SectionsByName[".reloc"]
		Relocations := []

		if (RelocationSecton && SymbolsByName[".text_offset"]) {
			TextOffset := SymbolsByName[".text_offset"].Value
			ImageBase := TextSection.VirtualAddress - TextOffset

			RelocationsOffset := 0

			while (RelocationsOffset < RelocationSecton.FileSize) {
				RelocationPage := this.ReadUInt(RelocationSecton.FileOffset + RelocationsOffset)
				RelocationsOffset += 4

				PageRelocationCount := (this.ReadUInt(RelocationSecton.FileOffset + RelocationsOffset) - 8) / 2
				RelocationsOffset += 4

				loop, % PageRelocationCount {
					Relocation := this.ReadUShort(RelocationSecton.FileOffset + RelocationsOffset)
					RelocationsOffset += 2

					RelocationType := (Relocation >> 12) & 0xF
					RelocationAddress := (RelocationPage + (Relocation & 0xFFF))
					RelocationOffset := RelocationAddress - TextSection.VirtualAddress

					if (RelocationOffset < 0 || RelocationOffset > TextSection.FileSize) {
						continue
					}
					else if (RelocationType = 0) {
						continue
					}
					else if (RelocationType != 10) {
						throw "Unknown relocation type '" RelocationType "'"
					}

					Relocations.Push(RelocationOffset)

					; This relocation currently has an RVA in place of an actual address, which makes it easy to relocate in an actual
					;  image. But since this code is loaded as if `.text` goes at RVA 0, we need to translate the RVA into a `.text`
					;   based offset.

					OldValue := this.ReadPtr(TextSection.FileOffset + RelocationOffset)
					OldValue -= TextOffset
					NumPut(OldValue, this.pData + 0, TextSection.FileOffset + RelocationOffset, "Ptr")
				}
			}
		}
		
		return {"AbsoluteSymbols": SymbolsByName, "Symbols": Symbols, "Sections": Sections, "SectionsByName": SectionsByName, "Relocations": Relocations}
	}
}