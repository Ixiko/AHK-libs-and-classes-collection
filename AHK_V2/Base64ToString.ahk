; ===========================================================================================================================================================================
; Base64ToString
; Converts a base64 string to a readable string.
; ===========================================================================================================================================================================

Base64ToString(Base64)
{
	static CRYPT_STRING_BASE64 := 0x00000001

	if !(DllCall("crypt32\CryptStringToBinaryW", "Str", Base64, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", 0, "UInt*", &Size := 0, "Ptr", 0, "Ptr", 0))
		throw Error("CryptBinaryToString failed", -1)

	String := Buffer(Size, 0)
	if !(DllCall("crypt32\CryptStringToBinaryW", "Str", Base64, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", String, "UInt*", Size, "Ptr", 0, "Ptr", 0))
		throw Error("CryptBinaryToString failed", -1)

	return StrGet(String, "UTF-8")
}

; ===========================================================================================================================================================================

MsgBox Base64ToString("VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZwA=")    ; The quick brown fox jumps over the lazy dog
