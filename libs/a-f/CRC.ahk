; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=63052
; Author:	jNizM
; Date:   	25.03.2019
; for:     	AHK_L
; Description: Generates the cyclic redundancy checksum polynomial of the string. This is usually used to validate the integrity of data being transmitted.

/*


*/

;MsgBox % CRC32("The quick brown fox jumps over the lazy dog")   ; -> 0x414fa339
CRC32(str) {
	static table := []
	loop 256 {
		crc := A_Index - 1
		loop 8
			crc := (crc & 1) ? (crc >> 1) ^ 0xEDB88320 : (crc >> 1)
		table[A_Index - 1] := crc
	}
	crc := ~0
	loop, parse, str
		crc := table[(crc & 0xFF) ^ Asc(A_LoopField)] ^ (crc >> 8)
	return Format("{:#x}", ~crc)
}

CRC32Dll(str, enc = "UTF-8") {
	size := (StrPut(str, enc) - 1) * (len := (enc = "CP1200" || enc = "UTF-16") ? 2 : 1)
	VarSetCapacity(buf, size, 0) &&	StrPut(str, &buf, Floor(size / len), enc)
	crc := DllCall("ntdll\RtlComputeCrc32", "uint", 0, "ptr", &buf, "uint", size, "uint")
	return Format("{:x}", crc)
}

;MsgBox % CRC16_CCITT("The quick brown fox jumps over the lazy dog")   ; -> 0x8fdd
CRC16_CCITT(str) {
	static table := []
	loop 256 {
		crc := (A_Index - 1) << 8
		loop 8
			crc := (crc & 0x8000) ? (crc << 1) ^ 0x1021 : (crc << 1)
		table[A_Index - 1] := crc
	}
	crc := 0xFFFF
	loop, parse, str
		crc := table[((crc >> 8) ^ Asc(A_LoopField)) & 0xFF] ^ (crc << 8)
	return Format("{:#x}", crc & 0xFFFF)
}

;MsgBox % Adler32("The quick brown fox jumps over the lazy dog")   ; -> 0x5bdc0fda
Adler32(str){
	static a := 1, b := 0
	loop, parse, str
		b := Mod(b + (a := Mod(a + Asc(A_LoopField), 0xFFF1)), 0xFFF1)
	return Format("{:#x}", (b << 16) | a)
}

;MsgBox % JSHash("The quick brown fox jumps over the lazy dog")   ; -> 0x948df2c
JSHash(str){
	static h := 0x4E67C6A7
	loop, parse, str
		h ^= ((h << 5) + Asc(A_LoopField) + (h >> 2))
	return Format("{:#x}", (h & 0x7FFFFFFF))
}

;MsgBox % RSHash("The quick brown fox jumps over the lazy dog")   ; -> 0x29a4500b
RSHash(str){
	static a := 0xF8C9, b := 0x5C6B7, h := 0
	loop, parse, str
		h := h * a + Asc(A_LoopField), a *= b
	return Format("{:#x}", (h & 0x7FFFFFFF))
}

