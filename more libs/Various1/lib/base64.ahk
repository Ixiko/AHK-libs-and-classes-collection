class Base64 {

	requires() {
		return []
	}

	static A_W := Base64.initAorW()

	/*
	 *	Constants: Encode/Decode
	 *	CRYPT_STRING_BASE64HEADER - Base64, with certificate beginning and ending headers.
	 *	CRYPT_STRING_BASE64 - Base64, without headers.
	 *	CRYPT_STRING_BINARY - Pure binary copy.
	 *	CRYPT_STRING_BASE64REQUESTHEADER - Base64, with request beginning and ending headers.
	 *	CRYPT_STRING_HEX - Hexadecimal only.
	 *	CRYPT_STRING_HEXASCII - Hexadecimal, with ASCII character display.
	 *	CRYPT_STRING_BASE64X509CRLHEADER - Base64, with X.509 CRL beginning and ending headers.
	 *	CRYPT_STRING_HEXADDR - Hexadecimal, with address display.
	 *	CRYPT_STRING_HEXRAW - A raw hexadecimal string.
	 *	CRYPT_STRING_STRICT - Enforce strict decoding of ASN.1 text formats.
	 *

	 *	Constants: Encode only
	 *	CRYPT_STRING_NOCRLF - Do not append any new line character to the encoded string.
	 *	CRYPT_STRING_NOCR - Only use the line feed (LF) character (0x0A) for a new line.


	 *	Constants: Decode only
	 *	CRYPT_STRING_BASE64_ANY - Tries the following, in order: CRYPT_STRING_BASE64HEADER / CRYPT_STRING_BASE64
	 *	CRYPT_STRING_ANY - Tries the following, in order: CRYPT_STRING_BASE64HEADER / CRYPT_STRING_BASE64 / CRYPT_STRING_BINARY
	 *	CRYPT_STRING_HEX_ANY - Tries the following, in order: CRYPT_STRING_HEXADDR / CRYPT_STRING_HEXASCIIADDR / CRYPT_STRING_HEX / CRYPT_STRING_HEXRAW / CRYPT_STRING_HEXASCII
	 */
	static CRYPT_STRING_BASE64HEADER := 0x00000000
	static CRYPT_STRING_BASE64 := 0x00000001
	static CRYPT_STRING_BINARY := 0x00000002
	static CRYPT_STRING_BASE64REQUESTHEADER := 0x00000003
	static CRYPT_STRING_HEX := 0x00000004
	static CRYPT_STRING_HEXASCII := 0x00000005
	static CRYPT_STRING_BASE64_ANY := 0x00000006
	static CRYPT_STRING_ANY := 0x00000007
	static CRYPT_STRING_HEX_ANY := 0x00000008
	static CRYPT_STRING_BASE64X509CRLHEADER := 0x00000009
	static CRYPT_STRING_HEXADDR := 0x0000000a
	static CRYPT_STRING_HEXASCIIADDR := 0x0000000b
	static CRYPT_STRING_HEXRAW := 0x0000000c
	static CRYPT_STRING_STRICT := 0x20000000
	static CRYPT_STRING_NOCRLF := 0x40000000
	static CRYPT_STRING_NOCR := 0x80000000

	__new() {
		throw Exception("Instantiation of class '" this.__Class
				. "' is not allowed", -1)
	}

	initAorW() {
		return A_IsUnicode ? "W" : "A"
	}

	encode(ByRef pbBinary, cbBinary=0, dwFlags=0x40000001) {
		if (!cbBinary) {
			cbBinary := (StrLen(pbBinary)) * (A_IsUnicode ? 2 : 1)
		}
		pcchString := 0
		if (!DllCall("crypt32\CryptBinaryToString" Base64.A_W
				, "Str", pbBinary
				, "UInt", cbBinary
				, "UInt", dwFlags
				, "Ptr", 0
				, "UInt*", pcchString
				, "CDecl")) {
			throw Exception(A_ThisFunc " failed",, A_LastError)
		}
		VarSetCapacity(pszString, pcchString * (A_IsUnicode ? 2 : 1), 0)
		if (!DllCall("crypt32\CryptBinaryToString" Base64.A_W
				, "Str", pbBinary
				, "UInt", cbBinary
				, "UInt", dwFlags
				, "Ptr", &pszString
				, "UInt*", pcchString
				, "CDecl")) {
			throw Exception(A_ThisFunc " failed",, A_LastError)
		}
		return StrGet(&pszString)
	}

	decode(pszString, cchString, dwFlags, ByRef pbBinary, ByRef pcbBinary=0
			, ByRef pdwSkip=0, ByRef pdwFlags=0) {
		if (!cchString) {
			cchString := StrLen(pszString) * (A_IsUnicode ? 2 : 1)
		}
		VarSetCapacity(_pcbBinary, 4, 0)
		NumPut(pcbBinary, _pcbBinary, 0, "UInt")
		VarSetCapacity(_pdwSkip, 4, 0)
		NumPut(pdwSkip, _pdwSkip, 0, "UInt")
		VarSetCapacity(_pdwFlags, 4, 0)
		NumPut(pdwFlags, _pdwFlags, 0, "UInt")
		if (!DllCall("crypt32\CryptStringToBinary" Base64.A_W
				, "Str", pszString
				, "UInt", cchString
				, "UInt", dwFlags
				, "Ptr", 0
				, "UInt", &_pcbBinary
				, "UInt", &_pdwSkip
				, "UInt", &_pdwFlags
				, "CDecl")) {
			throw Exception(A_ThisFunc " failed",, A_LastError)
		}
		pcbBinary := NumGet(_pcbBinary, 0, "UInt") * (A_IsUnicode ? 2 : 1)
		VarSetCapacity(pbBinary, pcbBinary, 0)
		NumPut(pcbBinary, _pcbBinary, 0, "UInt")
		if (!DllCall("crypt32\CryptStringToBinary" Base64.A_W
				, "Str", pszString
				, "UInt", cchString
				, "UInt", dwFlags
				, "Ptr", &pbBinary
				, "UInt", &_pcbBinary
				, "UInt", &_pdwSkip
				, "UInt", &_pdwFlags
				, "CDecl")) {
			throw Exception(A_ThisFunc " failed",, A_LastError)
		}
		pcbBinary := NumGet(_pcbBinary, 0, "UInt")
		pdwSkip := NumGet(_pdwSkip, 0, "UInt")
		pdwFlags := NumGet(_pdwFlags, 0, "UInt")
		return NumGet(_pcbBinary, 0, "UInt")
	}
}
; vim: ts=4:sts=4:sw=4:tw=0:noet
