
$Name() {
	static CodeBase64 := $CodeBase64
	static CodeSize := $CodeSize
	static Code := false

	if (!Code) {
		if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "UPtr", 0, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
			throw Exception("Failed to parse MCLib b64 to binary")
		
		CompressedSize := VarSetCapacity(DecompressionBuffer, CompressedSize, 0)

		if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
			throw Exception("Failed to convert MCLib b64 to binary")
		
		if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", CodeSize, "Ptr"))
			throw Exception("Failed to reserve MCLib memory")

		if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", CodeSize, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
			throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
	
$HasImports
		for ImportName, ImportOffset in $Imports {
			Import := StrSplit(ImportName, "_")
			
			hDll := DllCall("GetModuleHandle", "Str", Import[1], "Ptr")

			if (ErrorLevel || A_LastError)
				Throw "Could not load dll " Import[1] ", ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
			
			pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", Import[2], "Ptr")

			if (ErrorLevel || A_LastError)
				Throw "Could not find function " Import[2] " from " Import[1] ".dll, ErrorLevel " ErrorLevel ", LastError " Format("{:0x}", A_LastError) 
			
			NumPut(pFunction, pCode + 0, ImportOffset, "Ptr")
		}
$HasImports

$HasRelocations
		for k, Offset in $Relocations {
			Old := NumGet(pCode + 0, Offset, "Ptr")
			NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
		}
$HasRelocations
		
		if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", CodeSize, "UInt", 0x40, "UInt*", OldProtect, "UInt")
			Throw Exception("Failed to mark MCLib memory as executable")

$HasExports
		Exports := {}

		for ExportName, ExportOffset in $Exports {
			Exports[ExportName] := pCode + SymbolOffset
		}

		Code := Exports
$HasExports
$HasNoExports
		Code := pCode + $MainOffset
$HasNoExports
	}

	return Code
}