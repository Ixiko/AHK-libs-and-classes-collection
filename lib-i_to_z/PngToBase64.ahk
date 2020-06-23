;FileSelectFile, File,,, Pick a PNG, Images (*.png)
;Clipboard := PngToBase64(File)
;MsgBox, % "The image is now on your clipboard. Paste into your browser URL bar."
;return

PngToBase64(file) {
	FileGetSize, size, % file
	FileRead, bin, % "*c " file
	return "data:image/png;base64," Base64enc(bin, size)
}

Base64enc(bin, size) {   ; by SKAN
	DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), UInt, &bin, UInt, size, UInt, 1, UInt, 0, UIntP, chars, "CDECL Int")
	VarSetCapacity(out, req := chars * (A_IsUnicode ? 2 : 1 ))
	DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), UInt, &bin, UInt, size, UInt, 1, Str, out, UIntP, req, "CDECL Int")
	return out
}