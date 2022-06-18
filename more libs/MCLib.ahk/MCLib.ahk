#Include %A_LineFile%\..\SymbolReader.ahk

class MClib {
	class LZ {
		Compress(pData, cbData, pCData, cbCData) {
			if (r := DllCall("ntdll\RtlGetCompressionWorkSpaceSize"
				, "UShort", 0x102                        ; USHORT CompressionFormatAndEngine
				, "UInt*", compressBufferWorkSpaceSize   ; PULONG CompressBufferWorkSpaceSize
				, "UInt*", compressFragmentWorkSpaceSize ; PULONG CompressFragmentWorkSpaceSize
				, "UInt")) ; NTSTATUS
				throw Exception("Erorr calling RtlGetCompressionWorkSpaceSize",, Format("0x{:08x}", r))
			
			VarSetCapacity(compressBufferWorkSpace, compressBufferWorkSpaceSize)
			
			if (r := DllCall("ntdll\RtlCompressBuffer"
				, "UShort", 0x102                       ; USHORT CompressionFormatAndEngine,
				, "Ptr", pData                          ; PUCHAR UncompressedBuffer,
				, "UInt", cbData                        ; ULONG  UncompressedBufferSize,
				, "Ptr", pCData                         ; PUCHAR CompressedBuffer,
				, "UInt", cbCData                       ; ULONG  CompressedBufferSize,
				, "UInt", compressFragmentWorkSpaceSize ; ULONG  UncompressedChunkSize,
				, "UInt*", finalCompressedSize          ; PULONG FinalCompressedSize,
				, "Ptr", &compressBufferWorkSpace       ; PVOID  WorkSpace
				, "UInt")) ; NTSTATUS
				throw Exception("Error calling RtlCompressBuffer",, Format("0x{:08x}", r))
			
			return finalCompressedSize
		}

		Decompress(pCData, cbCData, pData, cbData) {
			if (r := DllCall("ntdll\RtlDecompressBuffer"
				, "UShort",  0x102 ; USHORT CompressionFormat
				, "Ptr", pData     ; PUCHAR UncompressedBuffer
				, "UInt", cbData   ; ULONG  UncompressedBufferSize
				, "Ptr", pCData    ; PUCHAR CompressedBuffer
				, "UInt", cbCData  ; ULONG  CompressedBufferSize,
				, "UInt*", cbFinal ; PULONG FinalUncompressedSize
				, "UInt")) ; NTSTATUS
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			
			return cbFinal
		}
	}

	class Base64 {
		Encode(pData, Size) {
			if !DllCall("Crypt32\CryptBinaryToString"
				, "Ptr", pData       ; const BYTE *pbBinary
				, "UInt", Size     ; DWORD      cbBinary
				, "UInt", 0x40000001 ; DWORD      dwFlags = CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
				, "Ptr", 0           ; LPWSTR     pszString
				, "UInt*", Base64Length    ; DWORD      *pcchString
				, "UInt") ; BOOL
				throw Exception("Failed to calculate b64 size")
			
			VarSetCapacity(Base64, Base64Length * (1 + A_IsUnicode), 0)
			
			if !DllCall("Crypt32\CryptBinaryToString"
				, "Ptr", pData       ; const BYTE *pbBinary
				, "UInt", Size     ; DWORD      cbBinary
				, "UInt", 0x40000001 ; DWORD      dwFlags = CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
				, "Str", Base64         ; LPWSTR     pszString
				, "UInt*", Base64Length    ; DWORD      *pcchString
				, "UInt") ; BOOL
				throw Exception("Failed to convert to b64")

			return Base64
		}

		Decode(Base64) {
			if !DllCall("Crypt32\CryptStringToBinary", "Str", Base64, "UInt", 0, "UInt", 1
				, "UPtr", 0, "UInt*", DecodedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to parse b64 to binary")
			
			DecodedSize := VarSetCapacity(DecodeBuffer, DecodedSize, 0)
			pDecodeBuffer := &DecodeBuffer

			if !DllCall("Crypt32\CryptStringToBinary", "Str", Base64, "UInt", 0, "UInt", 1
				, "Ptr", pDecodeBuffer, "UInt*", DecodedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert b64 to binary")

			return {"pData": pDecodeBuffer, "Size": Size}
		}
	}

	GetTempPath(baseDir := "", prefix := "", ext := ".tmp") {
		if (baseDir == "" || !InStr(FileExist(baseDir), "D"))
			baseDir := A_Temp
		Loop
		{
			DllCall("QueryPerformanceCounter", "Int64*", counter)
			fileName := baseDir "\" prefix . counter . ext
		}
		until !FileExist(fileName)
		return prefix counter ext
	}

	NormalizeSymbols(Symbols) {
		Result := {}

		for SymbolName, Symbol in Symbols {
			if (SymbolName = "__main" || RegExMatch(SymbolName, "O)__MCLIB_(e|i)_(\w+)")) {
				Result[SymbolName] := Symbol.Value
			}
		}

		return Result
	}

	static CompilerPrefix := "x86_64-w64-mingw32-"
	static CompilerSuffix := ".exe"

	Compile(Compiler, Code, ExtraOptions := "") {
		LinkerScript  := this.GetTempPath(A_WorkingDir, "mclib-linker-", "")
		IncludeFolder := this.GetTempPath(A_WorkingDir, "mclib-include-", "")
		InputFile     := this.GetTempPath(A_WorkingDir, "mclib-input-", ".c")
		OutputFile    := this.GetTempPath(A_WorkingDir, "mclib-output-", ".bin")

		try {
			FileOpen(LinkerScript, "w").Write("OUTPUT_FORMAT(pe-x86-64)SECTIONS{.text :{*(.text*)*(.rodata*)*(.rdata*)*(.data*)*(.bss*)}}")

			FileOpen(InputFile, "w").Write(code)
			
			while (!FileExist(InputFile)) {
				Sleep, 100
			}

			FileCopyDir, %A_LineFile%/../include, % IncludeFolder
			
			shell := ComObjCreate("WScript.Shell")
			exec := shell.Exec(this.CompilerPrefix Compiler this.CompilerSuffix " -m64 " InputFile " -o " OutputFile ExtraOptions " -ffreestanding -nostdlib -Wno-attribute-alias -T " LinkerScript " -Wl,--image-base -Wl,0x10000000 -Wl,-Ttext=0x5000 -Wl,--defsym -Wl,.text_offset=0x5000 -I " IncludeFolder)
			exec.StdIn.Close()
			
			if !exec.StdErr.AtEndOfStream
				Throw Exception(StrReplace(exec.StdErr.ReadAll(), " ", " "),, "Compiler Error")
			
			while (!FileExist(OutputFile)) {
				Sleep, 100
			}

			if !(F := FileOpen(OutputFile, "r"))
				Throw Exception("Failed to load output file")
			
			Size := F.Length
			
			if !(pPE := DllCall("GlobalAlloc", "UInt", 0, "Ptr", Size, "Ptr"))
				Throw Exception("Failed to reserve MCLib PE memory")
			
			F.RawRead(pPE + 0, Size)
			F.Close()
		}
		finally {
			FileDelete, % InputFile
			FileDelete, % LinkerScript
			FileDelete, % OutputFile

			FileRemoveDir, % IncludeFolder, 1
		}
		
		Reader := new PESymbolReader(pPE, Size)
		Output := Reader.Read()
		
		pCode := pPE + Output.SectionsByName[".text"].FileOffset

		return [pCode, Output.SectionsByName[".text"].FileSize, this.NormalizeSymbols(Output.AbsoluteSymbols), Output.Relocations]
	}
	
	Load(pCode, CodeSize, Symbols, Relocations) {
		for SymbolName, SymbolOffset in Symbols {
			if (RegExMatch(SymbolName, "O)__MCLIB_i_(\w+?)_(\w+)", Match)) {
				DllName := Match[1]
				FunctionName := Match[2]

				hDll := DllCall("GetModuleHandle", "Str", DllName, "Ptr")

				if (ErrorLevel || A_LastError) {
					Throw "Could not load dll " DllName ", ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
				}

				pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", FunctionName, "Ptr")

				if (ErrorLevel || A_LastError) {
					Throw "Could not find function " FunctionName " from " DllName ".dll, ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
				}

				NumPut(pFunction, pCode + 0, SymbolOffset, "Ptr")
			}
		}

		for k, Offset in Relocations {
			Old := NumGet(pCode + 0, Offset, "Ptr")
			NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
		}
		
		if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", CodeSize, "UInt", 0x40, "UInt*", OldProtect, "UInt")
			Throw Exception("Failed to mark MCLib memory as executable")
		
		Exports := {}

		for SymbolName, SymbolOffset in Symbols {
			if (RegExMatch(SymbolName, "O)__MCLIB_e_(\w+)", Match)) {
				Exports[Match[1]] := pCode + SymbolOffset
			}
		}

		if (Exports.Count()) {
			return Exports
		}
		else {
			return pCode + Symbols["__main"]
		}
	}
	
	FromC(Code) {
		return this.Load(this.Compile("gcc", Code)*)
	}
	
	FromCPP(Code) {
		return this.Load(this.Compile("g++", "extern ""C"" {`n" Code "`n}", " -fno-exceptions -fno-rtti")*)
	}
	
	Pack(FormatAsStringLiteral, pCode, CodeSize, Symbols, Relocations) {

		; First, compress the actual code bytes
		CompressionBufferSize := VarSetCapacity(CompressionBuffer, CodeSize * 2, 0)
		pCompressionBuffer := &CompressionBuffer

		CompressedSize := this.LZ.Compress(pCode, CodeSize, pCompressionBuffer, CompressionBufferSize)
		Base64 := this.Base64.Encode(pCompressionBuffer, CompressedSize)

		SymbolsString := ""

		for SymbolName, SymbolOffset in Symbols {
			SymbolsString .= SymbolName ":" SymbolOffset ","
		}

		SymbolsString .= "__size:" CodeSize

		RelocationsString := ""

		for k, RelocationOffset in Relocations {
			RelocationsString .= RelocationOffset ","
		}

		RelocationsString := SubStr(RelocationsString, 1, -1)

		; And finally, format our output
		
		if (FormatAsStringLiteral) {
			; Format the output as an AHK string literal, which can be dropped directly into a source file

			while StrLen(Base64) {
				Out .= "`n. """ SubStr(Base64, 1, 120-8) """"
				Base64 := SubStr(Base64, (120-8)+1)
			}

			return """V0.1;" SymbolsString ";" RelocationsString ";""" Out
		}
		else {
			; Don't format the output, return the string that would result from AHK parsing the string literal returned when `FormatAsStringLiteral` is true

			return "V0.1;" SymbolsString ";" RelocationsString ";" Base64
		}
	}

	DoTemplateBlock(Template, BlockName, Values, AsArray := false) {
		; If Values is not empty, this function populates $BlockName with Values stringified, and
		;  preserves anything inside $HasBlockName...$HasBlockName, removing anything between
		;   $HasNoBlockName...$HasNoBlockName

		; If values is empty, the opposite is done, removing $HasBlockName...$HasBlockName and
		;  keeping $HasNoBlockName...$HasNoBlockName

		if (Values.Count()) {
			Template := RegExReplace(Template, "s)\$HasNo" BlockName ".*?\$HasNo" BlockName)
			Template := StrReplace(Template, "$Has" BlockName)

			ValuesString := AsArray ? "[" : "{"

			for k, v in Values {
				ValuesString .= (AsArray ? v : """" k """: " v) ", "
			}

			ValuesString := SubStr(ValuesString, 1, -2) (AsArray ? "]" : "}")

			Template := StrReplace(Template, "$" BlockName, ValuesString)
		}
		else {
			Template := StrReplace(Template, "$HasNo" BlockName)
			Template := RegExReplace(Template, "s)\$Has" BlockName ".*?\$Has" BlockName)
		}

		return Template
	}

	StandalonePack(Name, pCode, CodeSize, Symbols, Relocations) {
		; First, compress the actual code bytes
		CompressionBufferSize := VarSetCapacity(CompressionBuffer, CodeSize * 2, 0)
		pCompressionBuffer := &CompressionBuffer

		CompressedSize := this.LZ.Compress(pCode, CodeSize, pCompressionBuffer, CompressionBufferSize)
		Base64 := this.Base64.Encode(pCompressionBuffer, CompressedSize)

		Imports := {}
		Exports := {}

		for SymbolName, SymbolOffset in Symbols {
			if (RegExMatch(SymbolName, "O)__MCLIB_i_(\w+)_(\w+)", Match)) {
				Imports[Match[1] "_" Match[2]] := SymbolOffset
			}
			else if (RegExMatch(SymbolName, "O)__MCLIB_e_(\w+)", Match)) {
				Exports[Match[1]] := SymbolOffset
			}
		}

		while StrLen(Base64) {
			Out .= "`n. """ SubStr(Base64, 1, 120-8) """"
			Base64 := SubStr(Base64, (120-8)+1)
		}

		FileRead, Template, %A_LineFile%/../StandaloneTemplate.ahk

		Template := StrReplace(Template, "$Name", Name)
		Template := StrReplace(Template, "$CodeBase64", """""" Out)
		Template := StrReplace(Template, "$CodeSize", CodeSize)

		Template := this.DoTemplateBlock(Template, "Imports", Imports)
		Template := this.DoTemplateBlock(Template, "Relocations", Relocations, true)
		Template := this.DoTemplateBlock(Template, "Exports", Exports)

		Template := StrReplace(Template, "$MainOffset", Symbols["__main"])

		Template := RegexReplace(Template, "\n\s*\n")

		return Template
	}
	
	AHKFromC(Code, FormatAsStringLiteral := true) {
		return this.Pack(FormatAsStringLiteral, this.Compile("gcc", Code)*)
	}
	StandaloneAHKFromC(Code, Name := "MyMCLibC") {
		return this.StandalonePack(Name, this.Compile("gcc", Code)*)
	}
	
	AHKFromCPP(Code, FormatAsStringLiteral := true) {
		return this.Pack(FormatAsStringLiteral, this.Compile("g++", "extern ""C"" {`n" Code "`n}", " -fno-exceptions -fno-rtti")*)
	}
	StandaloneAHKFromCPP(Code, Name := "MyMCLibCPP") {
		return this.StandalonePack(Name, this.Compile("g++", "extern ""C"" {`n" Code "`n}", " -fno-exceptions -fno-rtti")*)
	}


	FromString(Code) {
		Formats := {"V0": 3, "V0.1": 4}

		Parts := StrSplit(Code, ";")
		Version := Parts[1]

		if (!Formats.HasKey(Version) || Parts.Count() != Formats[Version] ) {
			Throw "Unknown/corrupt MClib packed code format"
		}

		Symbols := {}

		for k, SymbolEntry in StrSplit(Parts[2], ",") {
			SymbolEntry := StrSplit(SymbolEntry, ":")

			Symbols[SymbolEntry[1]] := SymbolEntry[2]
		}

		Relocations := []

		if (Version = "V0") {
			CodeBase64 := Parts[3]
		}
		else {
			for k, Relocation in StrSplit(Parts[3], ",") {
				Relocations.Push(Relocation)
			}

			CodeBase64 := Parts[4]
		}		

		DecompressedSize := Symbols.__Size
		
		if !(pBinary := DllCall("GlobalAlloc", "UInt", 0, "Ptr", DecompressedSize, "Ptr"))
			throw Exception("Failed to reserve MCLib memory")

		Decoded := this.Base64.Decode(CodeBase64)
		this.LZ.Decompress(Decoded.pData, Decoded.Size, pBinary, DecompressedSize)
		
		return this.Load(pBinary, DecompressedSize, Symbols, Relocations)
	}
}
