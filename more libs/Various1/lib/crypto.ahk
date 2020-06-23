; TODO: Refactor
class Crypto {

	requires() {
		return [String, Base64]
	}

	static ALGORITHM_RC4 := 1
	static ALGORITHM_XOR := 2

	class RC4 {

		__new() {
			throw Exception("Instatiation of class '" this.__Class
					. "' ist not allowed", -1)
		}

		; TODO: Refactor
		encodeDecode(ByRef Message, ByRef Key, iMsgLen=0, iKeyLen=0
				, iSkipStates=256) {
			if (iMsgLen = 0) {
				iMsgLen := StrLen(Message) * (A_IsUnicode ? 2 : 1)
			}
			if (iKeyLen = 0) {
				iKeyLen := StrLen(Key) * (A_IsUnicode ? 2 : 1)
			}

			__KeyToArray__:
			aKey := []
			loop % iKeyLen {
				i := A_Index - 1
				aKey[i] := NumGet(Key, i, "UChar")
			}

			__Initialize__:
			aS_Box := []
			loop 256 {
				i := A_Index - 1
				aS_Box[i] := i
			}

			__ComputeRandoms__:
			j := 0
			; skip first 256 states to avoid Fluhrer/Martin/Shamir RC4 attack
			; http://www.fact-index.com/r/rc/rc4_cipher.html
			loop % iSkipStates + iKeyLen {
				i := A_Index - 1
				m := Mod(i, iKeyLen)
				j := Mod((j + aS_Box[i] + aKey[m]), 256)
				_x := aS_Box[i]
				aS_Box[i] := aS_Box[j]
				aS_Box[j] := _x
			}

			__EncryptDecrypt__:
			i := 0
			j := 0
			loop % iMsgLen {
				i := Mod(A_Index, 256)
				j := Mod((j + aS_Box[i]), 256)
				_x := aS_Box[i]
				aS_Box[i] := aS_Box[j]
				aS_Box[j] := _x
				z := Mod((aS_Box[i] + aS_Box[j]), 256)
				k := aS_Box[z]
				i_1 := A_Index - 1
				char := k ^ NumGet(Message, i_1, "UChar")
				NumPut(char, Message, i_1, "UChar")
			}
			return iMsgLen
		}
	}

	class XOR {

		__new() {
			throw Exception("Instatiation of class '" this.__Class
					. "' ist not allowed", -1)
		}

		encodeDecode(ByRef Message, ByRef Key, iMsgLen=0, iKeyLen=0) {
			if (iMsgLen = 0) {
				iMsgLen := StrLen(Message) * (A_IsUnicode ? 2 : 1)
			}
			if (iKeyLen = 0) {
				iKeyLen := StrLen(Key) * (A_IsUnicode ? 2 : 1)
			}
			i := 0
			Loop %iMsgLen% {
				c_m := NumGet(Message, A_Index - 1, "UChar")
				c_k := NumGet(Key, i, "UChar")
				char := c_m ^ c_k
				NumPut(char, Message, A_Index - 1, "UChar")
				i := Mod(i + 1, iKeyLen)
			}
			return iMsgLen
		}
	}

	class MD5 {

		__new() {
			throw Exception("Instatiation of class '" this.__Class
					. "' ist not allowed", -1)
		}

		encode(ByRef Message, iMsgLen=0) {
			if (iMsgLen = 0) {
				iMsgLen := VarSetCapacity(Message, -1)
				if (A_IsUnicode) {
					Message := Message.put("cp0")
					iMsgLen /= 2
				}
			}
			VarSetCapacity(md5Context, 104, 0)
			DllCall("advapi32\MD5Init", "Str", md5Context)
			DllCall("advapi32\MD5Update", "Str", md5Context
					, "Str", Message, "UInt", iMsgLen)
			DllCall("advapi32\MD5Final", "Str", md5Context)
			Hexstr_Digest := ""
			loop 16 {
				Hexstr_Digest .= RegExReplace((*(&md5Context + 87 + A_Index), 2)
						.AsHex(), "i)^0x", "").padLeft(2, "0")
			}
			return Hexstr_Digest
		}
	}

	__new() {
		throw Exception("Instatiation of class '" this.__Class
				. "' ist not allowed", -1)
	}

	encrypt(ByRef Message, ByRef Key, iAlgorithm, iMsgLen=0, iKeyLen=0) {
		if (!Crypto.isValidAlgorithm(iAlgorithm)) {
			throw Exception("Invalid Algorithm: " iAlgorithm)
		}
		if (iAlgorithm = Crypto.ALGORITHM_RC4) {
			n := Crypto.RC4.encodeDecode(Message, Key, iMsgLen, iKeyLen)
			return "{RC4}" Base64.encode(Message, n
					, Base64.CRYPT_STRING_BASE64|Base64.CRYPT_STRING_NOCRLF)
		}
		if (iAlgorithm = Crypto.ALGORITHM_XOR) {
			n := Crypto.XOR.encodeDecode(Message, Key, iMsgLen, iKeyLen)
			return "{XOR}" Base64.encode(Message, n
					, Base64.CRYPT_STRING_BASE64|Base64.CRYPT_STRING_NOCRLF)
		}
	}

	decrypt(ByRef Message, ByRef Key, iKeyLen=0, iAlgorithm="") {
		if (iAlgorithm != "" && !Crypto.isValidAlgorithm(iAlgorithm)) {
			throw Exception("Invalid Algorithm: " iAlgorithm)
		}
		n := ""
		if (iAlgorithm = "") {
			if (!RegExMatch(Message
					, "iO)^\{(?P<Algorithm>RC4|XOR)}"
					. "(?P<Data>[a-zA-Z0-9+/]+={0,2})"
					, Code)) {
				throw Exception("Invalid Message: "
						. Code.algorithm " " Code.data)
			}
		} else {
			Code := {Data: Message}
			if (iAlgorithm = Crypto.ALGORITHM_RC4) {
				Code["Algorithm"] := "RC4"
			} else {
				Code["Algorithm"] := "XOR"
			}
		}
		if (Code.algorithm = "RC4") {
			len := Base64.decode(Code.data, 0
					, Base64.CRYPT_STRING_BASE64, Message)
			n := Crypto.RC4.encodeDecode(Message, Key, len, iKeyLen)
		} else if (Code.algorithm = "XOR") {
			len := Base64.decode(Code.data, 0
					, Base64.CRYPT_STRING_BASE64, Message)
			n := Crypto.XOR.encodeDecode(Message, Key, len, iKeyLen)
		}
		return n
	}

	isValidAlgorithm(iAlgorithm) {
		if (iAlgorithm >= Crypto.ALGORITHM_RC4
				&& iAlgorithm <= Crypto.ALGORITHM_XOR) {
			return true
		}
		return false
	}
}
; vim: ts=4:sts=4:sw=4:tw=0:noet
