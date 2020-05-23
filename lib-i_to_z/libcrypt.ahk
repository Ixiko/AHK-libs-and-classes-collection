/**
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 The ahkscript community (ahkscript.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
LC_Version := "0.0.24.01"

LC_ASCII2Bin(s,pretty:=0) {
	r:=""
	Loop, % l:=StrLen(s)
	{
		z:=Asc(SubStr(s,A_Index,1)),y:="",p:=1
		Loop, 8
			b:=!!(z&p),y:=b y,p:=p<<1
		r.=y
		if (pretty && (A_Index<l))
			r.=" "
	}
	return r
}

LC_Ascii2Bin2(Ascii) {
	for each, Char in StrSplit(Ascii)
	Loop, 8
		Out .= !!(Asc(Char) & 1 << 8-A_Index)
	return Out
}
 
LC_Bin2Ascii(Bin) {
	Bin := RegExReplace(Bin, "[^10]")
	Loop, % StrLen(Bin) / 8
	{
		for each, Bit in StrSplit(SubStr(Bin, A_Index*8-7, 8))
			Asc += Asc + Bit
		Out .= Chr(Asc), Asc := 0
	}
	return Out
}

LC_BinStr_EncodeText(Text, Pretty=False, Encoding="UTF-8") {
	VarSetCapacity(Bin, StrPut(Text, Encoding))
	LC_BinStr_Encode(BinStr, Bin, StrPut(Text, &Bin, Encoding)-1, Pretty)
	return BinStr
}

LC_BinStr_DecodeText(Text, Encoding="UTF-8") {
	Len := LC_BinStr_Decode(Bin, Text)
	return StrGet(&Bin, Len, Encoding)
}

LC_BinStr_Encode(ByRef Out, ByRef In, InLen, Pretty=False) {
	Loop, % InLen
	{
		Byte := NumGet(In, A_Index-1, "UChar")
		Loop, 8
			Out .= Byte>>(8-A_Index) & 1
		if Pretty ; Perhaps a regex at the end instead of a check in every loop would be better
			Out .= " "
	}
	; Out := RegExReplace(Out, "(\d{8})", "$1 ") ; For example, this
}

LC_BinStr_Decode(ByRef Out, ByRef In) {
	ByteCount := StrLen(In)/8
	VarSetCapacity(Out, ByteCount, 0)
	BitIndex := 1
	Loop, % ByteCount
	{
		Byte := 0
		Loop, 8
			Byte := Byte<<1 | SubStr(In, BitIndex++, 1)
		NumPut(Byte, Out, A_Index-1, "UChar")
	}
}


; implemented in ahk by joedf
; based on https://github.com/cryptii/cryptii/blob/4a0a58318d093c4c6e3333b3f296ad7c96309629/src/Encoder/Ascii85.js

/**
 * Performs encode on given content.
 * @param {String} content
 * @param {String} variant 
 * @return {String} Encoded content
 */
LC_ASCII85_Encode(content, variant="") {
	; Check for <~ ~> wrappers often used to wrap ascii85 encoded data
	; Decode wrapped data only
	content:=StrReplace(content,"<~")
	content:=StrReplace(content,"~>")
	
	; get bytes
	bytes := StrSplit(content)
	Loop % bytes.MaxIndex()
		bytes[A_Index] := Asc( bytes[A_Index] )

	; get variant
	variant := __LC_ASCII85_getVariant(variant)

	; get number of bytes
	n := bytes.Length()

	; Encode each tuple of 4 bytes
	string := ""
	i := 1
	while (i <= n)
	{
		; Read 32-bit unsigned integer from bytes following the
		; big-endian convention (most significant byte first)
		/*
		tuple = (
			((bytes[i]) << 24) +
			((bytes[i + 1] || 0) << 16) +
			((bytes[i + 2] || 0) << 8) +
			((bytes[i + 3] || 0))
		) >>> 0
		*/
		if (i-1 + 4 > n) ; handles the js-hack for falsy||0 test
			bytes.Push(0,0,0)
		tuple := ( ((bytes[i]) << 24)
			+ ((bytes[i + 1]) << 16)
			+ ((bytes[i + 2]) << 8)
			+ ((bytes[i + 3]))) >> 0
		
		if ( (variant["zeroTupleChar"] == "null") || (tuple > 0) )
		{
			; Calculate 5 digits by repeatedly dividing
			; by 85 and taking the remainder
			digits := []
			Loop, 5
			{
				digits.Push( mod(tuple,85) )
				tuple := tuple // 85
			}

			; Take most significant digit first
			; >>>> digits = digits.reverse()
			; following is based method by jNizM from https://github.com/jNizM/AHK_Scripts/blob/master/src/arrays/RevArr.ahk
			newarr := []
			for t_idx, t_val in digits
				newarr.InsertAt(1, t_val)
			digits := newarr

			if (n < (i-1 + 4)) {
				; Omit final characters added due to bytes of padding
				; >>>> digits.splice(n - (i + 4), 4)
				digits := __LC_ASCII85_splice(digits,n - (i-1 + 4), 4)
			}

			; Convert digits to characters and glue them together
			for t_k, t_v in digits
				string .= (variant["alphabet"] == "null")
					? chr(t_v + 33)
					: SubStr(variant["alphabet"],t_v+1,1)

		} else {
			; An all-zero tuple is encoded as a single character
			string .= variant["zeroTupleChar"]
		}

		i += 4
	}

	return string
}

/*
 * Performs decode on given content.
 * @param {String} content
 * @return {String} Decoded content
 */
LC_ASCII85_Decode(content, variant="") {
	; Remove whitespaces
	string := Trim(content)
	
	; Get variant
	variant := __LC_ASCII85_getVariant(variant)
	
	; get length
	n := StrLen(string)

	; Decode each tuple of 5 characters
	bytes := []
	i := 1
	while (i <= n) {
		if (SubStr(string,i,1) == variant.zeroTupleChar) {
			; A single character encodes an all-zero tuple
			bytes.Push(0, 0, 0, 0)
			i++
		} else {
			; Retrieve radix-85 digits of tuple
			digits := StrSplit(SubStr(string,i,5))
			newarr := []
			for index, character in digits
			{
				digit := (variant["alphabet"] == "null")
					? digit := Asc(character) - 33
					: digit := InStr(variant["alphabet"],character)-1
				if (digit < 0 || digit > 84) {
					throw Format("Invalid character '{1}' at index {2}", character, index)
				}
				newarr.Push(digit)
			}
			digits := newarr

			; Create 32-bit binary number from digits and handle padding
			; tuple = a * 85^4 + b * 85^3 + c * 85^2 + d * 85 + e
			tuple := 0
				+ digits[1] * 52200625
				+ digits[2] * 614125
				+ (i-1 + 2 < n ? digits[3] : 84) * 7225
				+ (i-1 + 3 < n ? digits[4] : 84) * 85
				+ (i-1 + 4 < n ? digits[5] : 84)

			; Get bytes from tuple
			tupleBytes := [(tuple >> 24) & 0xff
						,  (tuple >> 16) & 0xff
						,  (tuple >> 8) & 0xff
						,   tuple & 0xff ]

			; Remove bytes of padding
			if (n < i-1 + 5) {
				tupleBytes := __LC_ASCII85_splice(tupleBytes, n - (i-1 + 5), 5)
			}

			; Append bytes to result
			for t_k, t_v in tupleBytes
				bytes.Push(t_v)

			i += 5
		}
	}

	; joedf: transform bytes array to string
	decoded := ""
	for k, v in bytes
		decoded .= Chr(v)
	
	return decoded
}

; Helper function (not to create global vars), to return the variant associated information
__LC_ASCII85_getVariant(variant="") {
	if InStr(variant, "z")
		return { "name": "Z85"
				,"label": "Z85 (ZeroMQ)"
				,"alphabet": "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
				,"zeroTupleChar": "null"}
	return { "name": "original"
			,"label": "Original"
			,"alphabet": "null"
			,"zeroTupleChar": "z"}
}

; AHK minimum (no add-item feature) Polyfill for javascript's Array.prototype.splice()
; uses 0-based index, not ahk's default count starting at 1 instead of 0.
__LC_ASCII85_splice(arr, start, deleteCount="") {
	len := arr.Length()
	newarr := []

	startIndex := start
	if (start > len) {
		startIndex := len
	} else if (start < 0) {
		startIndex := len + start
	}

	if (len + start < 0)
		startIndex := 0
	
	Loop % startIndex
		newarr.push( arr[A_Index] )

	; check if deleteCount is specified
	if (StrLen(deleteCount)) {
		
		; dont omit anything if deleteCount <= 0
		if (deleteCount<0)
			deleteCount:=0
		
		j := 1 + startIndex+deleteCount
		while (j <= len) {
			newarr.push( arr[j] )
			j++
		}
	}

	return newarr
}

LC_Base64_EncodeText(Text,Encoding="UTF-8")
{
	VarSetCapacity(Bin, StrPut(Text, Encoding))
	LC_Base64_Encode(Base64, Bin, StrPut(Text, &Bin, Encoding)-1)
	return Base64
}

LC_Base64_DecodeText(Text,Encoding="UTF-8")
{
	Len := LC_Base64_Decode(Bin, Text)
	return StrGet(&Bin, Len, Encoding)
}

LC_Base64_Encode(ByRef Out, ByRef In, InLen)
{
	return LC_Bin2Str(Out, In, InLen, 0x40000001)
}

LC_Base64_Decode(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x1)
}


LC_Bin2Hex(ByRef Out, ByRef In, InLen, Pretty=False)
{
	return LC_Bin2Str(Out, In, InLen, Pretty ? 0xb : 0x4000000c)
}

LC_Hex2Bin(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x8)
}

LC_Bin2Str(ByRef Out, ByRef In, InLen, Flags)
{
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Str", Out, "UInt*", OutLen)
	return OutLen
}

LC_Str2Bin(ByRef Out, ByRef In, Flags)
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Ptr", 0, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Str", Out, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return OutLen
}

; 
; Version: 2014.03.06-1518, jNizM
; see https://en.wikipedia.org/wiki/Caesar_cipher
; ===================================================================================

LC_Caesar(string, num := 2) {
    ret := c := ""
    loop, parse, string
    {
        c := Asc(A_LoopField)
        if (c > 64) && (c < 91)
            ret .= Chr(Mod(c - 65 + num, 26) + 65)
        else if (c > 96) && (c < 123)
            ret .= Chr(Mod(c - 97 + num, 26) + 97)
        else
            ret .= A_LoopField
    }
    return ret
}

LC_CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0) {
	static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
	static b := h.minIndex()
	hProv := hHash := o := ""
	if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
	{
		if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
		{
			if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
			{
				if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
				{
					VarSetCapacity(hash, hashlength, 0)
					if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
					{
						loop % hashlength
						{
							v := NumGet(hash, A_Index - 1, "UChar")
							o .= h[(v >> 4) + b] h[(v & 0xf) + b]
						}
					}
				}
			}
			DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
		}
		DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
	}
	return o
}
LC_CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0) {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	return LC_CalcAddrHash(&data, length, algid, hash, hashlength)
}
LC_CalcHexHash(hexstring, algid) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index - 1, 2), data, A_Index - 1, "Char")
	}
	return LC_CalcAddrHash(&data, length, algid)
}
LC_CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0) {
	fpos := ""
	if (!(f := FileOpen(filename, "r")))
	{
		return
	}
	f.pos := 0
	if (!continue && f.length > 0x7fffffff)
	{
		return
	}
	if (!continue)
	{
		VarSetCapacity(data, f.length, 0)
		f.rawRead(&data, f.length)
		f.pos := oldpos
		return LC_CalcAddrHash(&data, f.length, algid, hash, hashlength)
	}
	hashlength := 0
	while (f.pos < f.length)
	{
		readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
		VarSetCapacity(data, hashlength + readlength, 0)
		DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
		f.rawRead(&data + hashlength, readlength)
		h := LC_CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
	}
	return h
}

LC_CRC32(string, encoding = "UTF-8") {
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
	length := (StrPut(string, encoding) - 1) * chrlength
	VarSetCapacity(data, length, 0)
	StrPut(string, &data, floor(length / chrlength), encoding)
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_HexCRC32(hexstring) {
	length := StrLen(hexstring) // 2
	VarSetCapacity(data, length, 0)
	loop % length
	{
		NumPut("0x" SubStr(hexstring, 2 * A_Index -1, 2), data, A_Index - 1, "Char")
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
	CRC := SubStr(CRC32 | 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC)
	SetFormat, Integer, %A_FI%
	return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}
LC_FileCRC32(sFile := "", cSz := 4) {
	Bytes := ""
	cSz := (cSz < 0 || cSz > 8) ? 2**22 : 2**(18 + cSz)
	VarSetCapacity(Buffer, cSz, 0)
	hFil := DllCall("Kernel32.dll\CreateFile", "Str", sFile, "UInt", 0x80000000, "UInt", 3, "Int", 0, "UInt", 3, "UInt", 0, "Int", 0, "UInt")
	if (hFil < 1)
	{
		return hFil
	}
	hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
	CRC32 := 0
	DllCall("Kernel32.dll\GetFileSizeEx", "UInt", hFil, "Int64", &Buffer), fSz := NumGet(Buffer, 0, "Int64")
	loop % (fSz // cSz + !!Mod(fSz, cSz))
	{
		DllCall("Kernel32.dll\ReadFile", "UInt", hFil, "Ptr", &Buffer, "UInt", cSz, "UInt*", Bytes, "UInt", 0)
		CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", CRC32, "UInt", &Buffer, "UInt", Bytes, "UInt")
	}
	DllCall("Kernel32.dll\CloseHandle", "Ptr", hFil)
	SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
	CRC32 := SubStr(CRC32 + 0x1000000000, -7)
	DllCall("User32.dll\CharLower", "Str", CRC32)
	SetFormat, Integer, %A_FI%
	return CRC32, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}

;from joedf : fork-fusion of jNizM+Laszlo's functions [to_decimal()+ToBase()]
LC_To_Dec(b, n) { ; 1 < b <= 36, n >= 0
	d:=0
	StringUpper,n,n
	loop % StrLen(n)
	{
		d *= b, k:=SubStr(n,A_Index,1)
		if k is not Integer
			k:=Asc(k)-55
		d += k
	}
	return d
}
;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
LC_From_Dec(b,n) { ; 1 < b <= 36, n >= 0
	Loop {
		d := mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess n,1, Break
	}
	Return m
}
LC_Dec2Hex(x) {
	return LC_From_Dec(16,x)
}
LC_Hex2Dec(x) {
	return LC_To_Dec(16,x)
}
LC_Numvert(num,from,to) { ; from joedf : http://ahkscript.org/boards/viewtopic.php?f=6&t=6363
    return LC_From_Dec(to,LC_To_Dec(from,num))
}

;
; Date Updated:
;	Friday, November 23rd, 2012 - Tuesday, February 10th, 2015
;
; Script Function:
;	Function Library to Encrypt / Decrypt in Div2 (by Joe DF)
;	Div2 was invented with a friend for fun, back in ~2010.
;	The string is "divided" in 2 during encryption. It is a 
;	simple reordering of the characters in a string. The was
; 	to have a human-readable/decryptable message.
;
; Notes:
;	AutoTrim should turned off, for the encryption to work properly
;	because, in Div2, <spaces> and <New lines> count as a character.
;

LC_Div2_encode(input, WithAutoTrim:=1, numproc:=1) {
	if (WithAutoTrim)
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		final:="", inputlen := StrLen(input)
		divmax := ceil((0.5 * inputlen) + 1)
		loop, %inputlen%
		{
			temp := SubStr(input,A_Index,1)
			q := inputlen + 1 - A_Index
			temp2 := SubStr(input,q,1)
			if (A_Index < divmax) {
				final .= temp
				if (A_Index != q)
					final .= temp2
			}
			if (A_Index >= divmax)
				Break
		}
		input := final
	}
	return final
}

LC_Div2_decode(input, WithAutoTrim:=1, numproc:=1) {
	if (WithAutoTrim)
		StringReplace,input,input,%A_Space%,_,A
	loop, %numproc%
	{
		i := 1, final:="", inputlen := StrLen(input)
		loop, % loopc := ceil(inputlen * (1/2))
		{	
			if (i <= inputlen)
				final .= SubStr(input,i,1)
			i += 2
		}
		i := inputlen
		loop, %loopc%
		{		
			if (i <= inputlen) {
				if (mod(SubStr(i,0,1)+0,2)==1) {
					if (i != 1)
						final .= SubStr(input,i-1,1)
				} else {
					final .= SubStr(input,i,1)
				}
			}
			i -= 2
		}
		input := final
	}
	return final
}


LC_HMAC(Key, Message, Algo := "MD5") {
	static Algorithms := {MD2:    {ID: 0x8001, Size:  64}
						, MD4:    {ID: 0x8002, Size:  64}
						, MD5:    {ID: 0x8003, Size:  64}
						, SHA:    {ID: 0x8004, Size:  64}
						, SHA256: {ID: 0x800C, Size:  64}
						, SHA384: {ID: 0x800D, Size: 128}
						, SHA512: {ID: 0x800E, Size: 128}}
	static iconst := 0x36
	static oconst := 0x5C
	if (!(Algorithms.HasKey(Algo)))
	{
		return ""
    }
	Hash := KeyHashLen := InnerHashLen := ""
	HashLen := 0
	AlgID := Algorithms[Algo].ID
	BlockSize := Algorithms[Algo].Size
	MsgLen := StrPut(Message, "UTF-8") - 1
	KeyLen := StrPut(Key, "UTF-8") - 1
	VarSetCapacity(K, KeyLen + 1, 0)
	StrPut(Key, &K, KeyLen, "UTF-8")
	if (KeyLen > BlockSize)
    {
		LC_CalcAddrHash(&K, KeyLen, AlgID, KeyHash, KeyHashLen)
	}

	VarSetCapacity(ipad, BlockSize + MsgLen, iconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ iconst, ipad, i, "UChar")
		i++
	}
	if (MsgLen)
	{
		StrPut(Message, &ipad + BlockSize, MsgLen, "UTF-8")
	}
	LC_CalcAddrHash(&ipad, BlockSize + MsgLen, AlgID, InnerHash, InnerHashLen)

	VarSetCapacity(opad, BlockSize + InnerHashLen, oconst)
	Addr := KeyLen > BlockSize ? &KeyHash : &K
	Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
	i := 0
	while (i < Length)
	{
		NumPut(NumGet(Addr + 0, i, "UChar") ^ oconst, opad, i, "UChar")
		i++
	}
	Addr := &opad + BlockSize
	i := 0
	while (i < InnerHashLen)
	{
		NumPut(NumGet(InnerHash, i, "UChar"), Addr + i, 0, "UChar")
		i++
	}
	return LC_CalcAddrHash(&opad, BlockSize + InnerHashLen, AlgID)
}

/* from AHK forums
Fast 64- and 128-bit hash functions
Originally created by Laszlo , Jan 01 2007 06:59 PM 

https://autohotkey.com/board/topic/14040-fast-64-and-128-bit-hash-functions/

Here are two of hash functions, which
- are programmed fully in AHK
- are much faster than cryptographic hash functions
- provide long enough hash values (64 or 128 bits), so a collision is very unlikely

They are modeled after Linear Feedback Shift Register (LFSR) based hash functions, like CRC-32.

joedf: modified/updated for inclusion in libcrypt.ahk
The dynamic __LC_LHashTable global array variable is kept global in the interest of speed for successive calls.
*/

LC_L64Hash(x) {                        ; 64-bit generalized LFSR hash of string x
	Local i, R = 0
	__LC_LHash_LHashInit()             ; 1st time set LHASH0..LHAS256 global table
	Loop Parse, x
	{
		i := (R >> 56) & 255           ; dynamic vars are global
		R := (R << 8) + Asc(A_LoopField) ^ __LC_LHashTable%i%
	}
	Return __LC_LHash_Hex8(R>>32) . __LC_LHash_Hex8(R)
}

LC_L128Hash(x) {                       ; 128-bit generalized LFSR hash of string x
	Local i, S = 0, R = -1
	__LC_LHash_LHashInit()             ; 1st time set LHASH0..LHAS256 global table
	Loop Parse, x
	{
		i := (R >> 56) & 255           ; dynamic vars are global
		R := (R << 8) + Asc(A_LoopField) ^ __LC_LHashTable%i%
		i := (S >> 56) & 255
		S := (S << 8) + Asc(A_LoopField) - __LC_LHashTable%i%
	}
	Return __LC_LHash_Hex8(R>>32) . __LC_LHash_Hex8(R) . __LC_LHash_Hex8(S>>32) . __LC_LHash_Hex8(S)
}

__LC_LHash_Hex8(i) {                   ; integer -> LS 8 hex digits
	SetFormat Integer, Hex
	i:= 0x100000000 | i & 0xFFFFFFFF   ; mask LS word, set bit32 for leading 0's --> hex
	SetFormat Integer, D
	Return SubStr(i,-7)                ; 8 LS digits = 32 unsigned bits
}

__LC_LHash_LHashInit() {               ; build pseudorandom substitution table
	Local i, u = 0, v = 0
	If __LC_LHashTable0=
		Loop 256 {
			i := A_Index - 1
			__LC_LHASH_TEA(u,v, 1,22,333,4444, 8) ; <- to be portable, no Random()
			__LC_LHashTable%i% := (u<<32) | v
		}
}
;                                      ; [y,z] = 64-bit I/0 block, [k0,k1,k2,k3] = 128-bit key
__LC_LHASH_TEA(ByRef y,ByRef z, k0,k1,k2,k3, n = 32) { ; n = #Rounds
	s := 0, d := 0x9E3779B9
	Loop %n% {                         ; standard = 32, 8 for speed
		k := "k" . s & 3               ; indexing the key
		y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
		s := 0xFFFFFFFF & (s + d)      ; simulate 32 bit operations
		k := "k" . s >> 11 & 3
		z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
	}
}

LC_MD2(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8001, encoding)
}
LC_HexMD2(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8001)
}
LC_FileMD2(filename) {
	return LC_CalcFileHash(filename, 0x8001, 64 * 1024)
}
LC_AddrMD2(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8001)
}

LC_MD4(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8002, encoding)
}
LC_HexMD4(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8002)
}
LC_FileMD4(filename) {
	return LC_CalcFileHash(filename, 0x8002, 64 * 1024)
}
LC_AddrMD4(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8002)
}

LC_MD5(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8003, encoding)
}
LC_HexMD5(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8003)
}
LC_FileMD5(filename) {
	return LC_CalcFileHash(filename, 0x8003, 64 * 1024)
}
LC_AddrMD5(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8003)
}

;nnnik's custom encryption algorithm
;Version 2.1 of the encryption/decryption functions

LC_nnnik21_encryptStr(str="",pass="")
{
	If !(enclen:=(strput(str,"utf-16")*2))
		return "Error: Nothing to Encrypt"
	If !(passlen:=strput(pass,"utf-8")-1)
		return "Error: No Pass"
	enclen:=Mod(enclen,4) ? (enclen) : (enclen-2)
	Varsetcapacity(encbin,enclen,0)
	StrPut(str,&encbin,enclen/2,"utf-16")
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	LC_nnnik21_encryptbin(&encbin,enclen,&passbin,passlen)
	LC_Base64_Encode(Text, encbin, enclen)
	return Text
}

LC_nnnik21_decryptStr(str="",pass="")
{
	If !((strput(str,"utf-16")*2))
		return "Error: Nothing to Decrypt"
	If !((passlen:=strput(pass,"utf-8")-1))
		return "Error: No Pass"
	Varsetcapacity(passbin,passlen+=mod((4-mod(passlen,4)),4),0)
	StrPut(pass,&passbin,strlen(pass),"utf-8")
	enclen:=LC_Base64_Decode(encbin, str)
	LC_nnnik21__decryptbin(&encbin,enclen,&passbin,passlen)
	return StrGet(&encbin,"utf-16")
}


LC_nnnik21_encryptbin(pBin1,sBin1,pBin2,sBin2)
{
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a+b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,(A_Index-1)*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput((a+b)^c,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
}

LC_nnnik21__decryptbin(pBin1,sBin1,pBin2,sBin2){
	Loop % sBin2/4
	{
		c:=numget(pBin2+0,sBin2-A_Index*4,"uint")
		b:=0
		Loop % sBin1/4
		{
			a:=numget(pBin1+0,(A_Index-1)*4,"uint")
			numput(a:=(a^c)-b,pBin1+0,(A_Index-1)*4,"uint")
			b:=(a+b)*a
		}
	}
	b:=0
	Loop % sBin1/4
	{
		a:=numget(pBin1+0,sBin1-A_Index*4,"uint")
		numput(a:=a-b,pBin1+0,sBin1-A_Index*4,"uint")
		b:=(a+b)*a
	}
}


LC_RC4_Encrypt(Data,Pass) {
	Format:=A_FormatInteger,b:=0,j:=0,Key:=Object(),sBox:=Object()
	SetFormat,Integer,Hex
	VarSetCapacity(Result,StrLen(Data)*2)
	Loop 256
		a:=(A_Index-1),Key[a]:=Asc(SubStr(Pass,Mod(a,StrLen(Pass))+1,1)),sBox[a]:=a
	Loop 256
		a:=(A_Index-1),b:=(b+sBox[a]+Key[a])&255,sBox[a]:=(sBox[b]+0,sBox[b]:=sBox[a]) ; SWAP(a,b)
	Loop Parse, Data
		i:=(A_Index&255),j:=(sBox[i]+j)&255,k:=(sBox[i]+sBox[j])&255,sBox[i]:=(sBox[j]+0,sBox[j]:=sBox[i]) ; SWAP(i,j)
		,Result.=SubStr(Asc(A_LoopField)^sBox[k],-1,2)
	StringReplace,Result,Result,x,0,All
	SetFormat,Integer,%Format%
	Return Result
}

LC_RC4_Decrypt(Data,Pass) {
	b:=0,j:=0,x:="0x",Key:=Object(),sBox:=Object()
	VarSetCapacity(Result,StrLen(Data)//2)
	Loop 256
		a:=(A_Index-1),Key[a]:=Asc(SubStr(Pass,Mod(a,StrLen(Pass))+1,1)),sBox[a]:=a
	Loop 256
		a:=(A_Index-1),b:=(b+sBox[a]+Key[a])&255,sBox[a]:=(sBox[b]+0,sBox[b]:=sBox[a]) ; SWAP(a,b)
	Loop % StrLen(Data)//2
		i:=(A_Index&255),j:=(sBox[i]+j)&255,k:=(sBox[i]+sBox[j])&255,sBox[i]:=(sBox[j]+0,sBox[j]:=sBox[i]) ; SWAP(i,j)
		,Result.=Chr((x . SubStr(Data,(2*A_Index)-1,2))^sBox[k])
	Return Result
}

LC_RC4(RC4Data,RC4Pass) { ; Thanks Rajat for original, Updated Libcrypt version
	; http://www.autohotkey.com/board/topic/570-rc4-encryption/page-2#entry25712
	ATrim:=A_AutoTrim,BLines:=A_BatchLines,RC4PassLen:=StrLen(RC4Pass),Key:=Object(),sBox:=Object(),b:=0,RC4Result:="",i:=0,j:=0
	AutoTrim,Off
	SetBatchlines,-1
	Loop, 256
		a:=(A_Index-1),ModVal:=Mod(a,RC4PassLen),c:=SubStr(RC4Pass,ModVal+=1,1),Key[a]:=Asc(c),sBox[a]:=a
	Loop, 256
		a:=(A_Index-1),b:=Mod(b+sBox[a]+Key[a],256),T:=sBox[a],sBox[a]:=sBox[b],sBox[b]:=T
	Loop, Parse, RC4Data
		i:=Mod(i+1,256),j:=Mod(sBox[i]+j,256),k:=sBox[Mod(sBox[i]+sBox[j],256)],c:=Asc(A_LoopField)^k,c:=((c==0)?k:c),RC4Result.=Chr(c)
	AutoTrim, %ATrim%
	SetBatchlines, %BLines%
	Return RC4Result
}

/*
	- ROT5 covers the numbers 0-9.
	- ROT13 covers the 26 upper and lower case letters of the Latin alphabet (A-Z, a-z).
	- ROT18 is a combination of ROT5 and ROT13.
	- ROT47 covers all printable ASCII characters, except empty spaces. Besides numbers and the letters of the Latin alphabet,
			the following characters are included:
			!"#$%&'()*+,-./:;<=>?[\]^_`{|}~
*/

LC_Rot5(string) {
	Loop, Parse, string
		s .= (strlen((c:=A_LoopField)+0)?((c<5)?c+5:c-5):(c))
	Return s
}

; by Raccoon July-2009
; http://rosettacode.org/wiki/Rot-13#AutoHotkey
LC_Rot13(string) {
	Loop, Parse, string
	{
		c := asc(A_LoopField)
		if (c >= 97) && (c <= 109) || (c >= 65) && (c <= 77)
			c += 13
		else if (c >= 110) && (c <= 122) || (c >= 78) && (c <= 90)
			c -= 13
		s .= Chr(c)
	}
	Return s
}

LC_Rot18(string) {
	return LC_Rot13(LC_Rot5(string))
}

; adapted from http://langref.org/fantom+java+scala/strings/reversing-a-string/simple-substitution-cipher
; from decimal 33 '!' through 126 '~', 94 
LC_Rot47(string) {
	Loop Parse, string
	{
		c := Asc(A_LoopField)
		c += (c >= Asc("!") && c <= Asc("O") ? 47 : (c >= Asc("P") && c <= Asc("~") ? -47 : 0))
		s .= Chr(c)
	}
	Return s
}

; RSHash (Robert Sedgewick's string hashing algorithm)
; from jNizM
; https://autohotkey.com/boards/viewtopic.php?p=87929#p87929

LC_RSHash(str) {
	a := 0xF8C9, b := 0x5C6B7, h := 0
	loop, parse, str
		h := h * a + Asc(A_LoopField), a *= b
	return (h & 0x7FFFFFFF)
}

LC_SecureSalted(salt, message, algo := "md5") {
	hash := ""
	saltedHash := LC_%algo%(message . salt) 
	saltedHashR := LC_%algo%(salt . message)
	len := StrLen(saltedHash)
	loop % len / 2
	{
		byte1 := "0x" . SubStr(saltedHash, 2 * A_index - 1, 2)
		byte2 := "0x" . SubStr(saltedHashR, 2 * A_index - 1, 2)
		SetFormat, integer, hex
		hash .= StrLen(ns := SubStr(byte1 ^ byte2, 3)) < 2 ? "0" ns : ns
	}
	SetFormat, integer, dez
	return hash
}

LC_SHA(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x8004, encoding)
}
LC_HexSHA(hexstring) {
	return LC_CalcHexHash(hexstring, 0x8004)
}
LC_FileSHA(filename) {
	return LC_CalcFileHash(filename, 0x8004, 64 * 1024)
}
LC_AddrSHA(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x8004)
}

LC_SHA256(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800c, encoding)
}
LC_HexSHA256(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800c)
}
LC_FileSHA256(filename) {
	return LC_CalcFileHash(filename, 0x800c, 64 * 1024)
}
LC_AddrSHA256(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800c)
}

LC_SHA384(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800d, encoding)
}
LC_HexSHA384(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800d)
}
LC_FileSHA384(filename) {
	return LC_CalcFileHash(filename, 0x800d, 64 * 1024)
}
LC_AddrSHA384(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800d)
}

LC_SHA512(string, encoding = "UTF-8") {
	return LC_CalcStringHash(string, 0x800e, encoding)
}
LC_HexSHA512(hexstring) {
	return LC_CalcHexHash(hexstring, 0x800e)
}
LC_FileSHA512(filename) {
	return LC_CalcFileHash(filename, 0x800e, 64 * 1024)
}
LC_AddrSHA512(addr, length) {
	return LC_CalcAddrHash(addr, length, 0x800e)
}

; analogous to encodeURIComponent() / decodeURIComponent() in javascript
; see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent

; Modified by GeekDude from http://goo.gl/0a0iJq
LC_UriEncode(Uri, RE="[0-9A-Za-z]") {
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	While Code := NumGet(Var, A_Index - 1, "UChar")
		Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
	Return, Res
}

LC_UriDecode(Uri) {
	Pos := 1
	While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
	{
		VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
		Loop, Parse, Code, `%
			NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
		Decoded := StrGet(&Var, "UTF-8")
		Uri := SubStr(Uri, 1, Pos-1) . Decoded . SubStr(Uri, Pos+StrLen(Code)+1)
		Pos += StrLen(Decoded)+1
	}
	Return, Uri
}

;----------------------------------

; analogous to encodeURI() / decodeURI() in javascript
; see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI

LC_UrlEncode(Url) {
	; keep certain symbols like ":/;?@,&=+$#.", as per the standard js implementation
	; see https://github.com/ahkscript/libcrypt.ahk/issues/30
	return LC_UriEncode(Url, "[!#$&-;=?-Z_a-z~]")
}

LC_UrlDecode(url) {
	return LC_UriDecode(url)
}

; 
; Version: 2014.03.06-1518, jNizM
; see https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher
; ===================================================================================

LC_VigenereCipher(string, key, enc := 1) {
	enc := "", DllCall("user32.dll\CharUpper", "Ptr", &string, "Ptr")
	, string := RegExReplace(StrGet(&string), "[^A-Z]")
	loop, parse, string
	{
		a := Asc(A_LoopField) - 65
		, b := Asc(SubStr(key, 1 + Mod(A_Index - 1, StrLen(key)), 1)) - 65
		, enc .= Chr(Mod(a + b, 26) + 65)
	}
	return enc
}

LC_VigenereDecipher(string, key) {
	dec := ""
	loop, parse, key
		dec .= Chr(26 - (Asc(A_LoopField) - 65) + 65)
	return LC_VigenereCipher(string, dec)
}

; FUnctions and algorithm by VxE
; intergrated into libcrypt.ahk with "LC_" prefixes

/*
####################################################################################################
####################################################################################################
######                                                                                        ######
######                                [VxE]-251 Encryption                                    ######
######                                          &                                             ######
######                                [VxE]-89  Encryption                                    ######
######                                                                                        ######
####################################################################################################
####################################################################################################

[VxE] 251 encryption is a rotation-based encryption algorithm using a dynamic key and a
dynamic map. The '251' indicates the size of the map, which omits the following byte-values:
0x00 ( null byte: string terminator )
0x09 ( tab character: common text formatting character )
0x0A ( newline character: common text formatting character )
0x0D ( carriage return character: common text formatting character )
0x7F ( wierd character: ascii 'del' )

This encryption function also supports an 89-character map, which incorporates the byte values
between 0x20 and 0x7e, omitting 0x22, 0x27, 0x2C, 0x2F, 0x5C, and 0x60. This mode allows text value
input to be encrypted as text without high-ascii characters or non-printable characters.
*/

; ##################################################################################################
; ## Function shortcuts

LC_VxE_Encrypt89( key, byref message ) { ; ----------------------------------------------------------
   Return LC_VxE_Crypt( key, message, 1, "vxe89 len" StrLen( message ) << !!A_IsUnicode )
} ; VxE_Encrypt89( key, byref message ) ----------------------------------------------------------

LC_VxE_Decrypt89( key, byref message ) { ; ----------------------------------------------------------
   Return LC_VxE_Crypt( key, message, 0, "vxe89 len" StrLen( message ) << !!A_IsUnicode )
} ; VxE_Decrypt89( key, byref message ) ----------------------------------------------------------

LC_VxE_Encrypt251( key, byref message, len ) { ; ----------------------------------------------------
   Return LC_VxE_Crypt( key, message, 1, "len" len )
} ; VxE_Encrypt251( key, byref message, len ) ----------------------------------------------------

LC_VxE_Decrypt251( key, byref message, len ) { ; ----------------------------------------------------
   Return LC_VxE_Crypt( key, message, 0, "len" len )
} ; VxE_Decrypt251( key, byref message, len ) ----------------------------------------------------

; ##################################################################################################
; ## The core function

LC_VxE_Crypt( key, byref message, direction = 1, options="" ) { ; -----------------------------------
; Transorms the message. 'direction' indicates whether or not to decrypt or encrypt the message.
; However, since this algorithm is symmetrical, distinguishing between 'encrypt' and 'decrypt' is
; merely for the benefit of human understanding.

; This agorithm was developed by [VxE] in July 2010. When a key/message are passed to this function,
; it generates the rotation map using the key. Then, it traverses the bytes in the message, rotating
; their values along the map according to the key. Once the character's encoded value is determined,
; the key is augmented by a value based on the byte value.

   If !RegexMatch( options, "i)(?:len|l)\K(?:0x[\da-fA-F]+|\d+)", length ) ; check explicit length
      length := StrLen( message ) << !!A_IsUnicode ; otherwise, find length.
   UseVxE89 := InStr( options, "vxe89" ) ; check 'options' for text-friendly mode.
   direction := 2 * ( direction = 1 ) - 1 ; coerce the 'direction' to either +1 or -1.

   w := StrLen( key ) << !!A_IsUnicode
   ; 'w' holds the derived key, which is a 32-bit integer based on the key.
   ; Although this doesn't seem very entropic, remember that the map is also derived from the key.
   
   If (UseVxE89) ; using the smaller map allows text-friendly encrypting since the small map is
      Loop 126 ; composed only of low-ascii printable characters
         If ( A_Index >= 32 && A_Index != 34 && A_Index != 39 && A_Index != 44
         && A_Index != 47 && A_Index != 92 && A_Index != 96 )
            map .= Chr( A_Index )
   If !UseVxE89 ; the 251 map is more suitable for non-text data
      Loop 255
         If ( A_Index != 9 && A_Index != 10 && A_Index != 13 && A_Index != 127 )
            map .= Chr( A_Index )
   k := StrLen( map ) ; keep the length of the map

   Loop 9 ; pad the key up to 509 characters, mixing in digit-characters
      If StrLen( key ) < 509
         key := SubStr( key Chr( 48 + A_Index ) key, 1, 509 )

   Loop 509 ; rearrange the map, using the padded key as the selector.
   { ; This is how the map becomes dynamic. 509 times, a char is selected from the map and
   ; is extracted from the map string, then appended to it. At the same time, the derived key is
   ; augmented by XORing it with a value based on each byte in the key.
      q := *( &key + A_Index - 1 )
      pos := 1 + Mod( q * A_Index * 3, k )
      StringMid, e, map, %pos%, 1
      StringLeft, i, map, pos - 1
      StringTrimLeft, c, map, %pos%
      map := i c e
      w ^= q * A_Index * 1657
   }
   x := 0
   Loop %length%
   {
      c := NumGet( message, A_Index - 1, "UChar" ) ; for each byte in the message

      If !c || !( i := InStr( map, Chr( c ), 1 ) )
         Continue ; if the character isn't in the map, just skip it.
      i-- ; the map index should be zero based for easier use with Mod() function
      x++ ; this tracks the actual index, not the char position.

      e := Mod( 223390000 + i + w * direction, k ) ; rotate the index along the map

      c := Asc( SubStr( map, e + 1, 1 ) ) ; lookup the character at the rotated index

      NumPut( c, message, A_Index - 1, "UChar" ) ; append the newly-mapped char to the result

      ; Finally, depending on the direction of rotation, use either the original index or
      ; the rotated index to augment the derived key
      If ( direction = 1 )
         c := Mod( e + x, 251 )
      Else c := Mod( i + x, 251 )
      w ^= c | c << 8 | c << 16 | c << 24
   }
   return length
} ; VxE_Crypt( key, byref message, direction = 1, options="" ) -----------------------------------

LC_XOR_Encrypt(str,key) {
	EncLen:=StrPut(Str,"UTF-16")*2
	VarSetCapacity(EncData,EncLen)
	StrPut(Str,&EncData,"UTF-16")

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(OutData,EncData,EncLen,PassData,PassLen)
	LC_Base64_Encode(OutBase64, OutData, EncLen)
	return OutBase64
}

LC_XOR_Decrypt(OutBase64,key) {
	EncLen:=LC_Base64_Decode(OutData, OutBase64)

	PassLen:=StrPut(key,"UTF-8")
	VarSetCapacity(PassData,PassLen)
	StrPut(key,&PassData,"UTF-8")

	LC_XOR(EncData,OutData,EncLen,PassData,PassLen)
	return StrGet(&EncData,"UTF-16")
}

LC_XOR(byref OutData,byref EncData,EncLen,byref PassData,PassLen)
{
	VarSetCapacity(OutData,EncLen)
	Loop % EncLen
		NumPut(NumGet(EncData,A_Index-1,"UChar")^NumGet(PassData,Mod(A_Index-1,PassLen),"UChar"),OutData,A_Index-1,"UChar")
}
