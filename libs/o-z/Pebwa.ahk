/*
Pebwa.ahk

Routines to encode and decode binary data to and from Ascii/Ansi data.
This allows to embed such data in source code or plain text (8bit) files.

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.00.001 -- 2007/01/14 (PL) -- Minor doc. changes.
 1.00.000 -- 2006/07/04 (PL) -- Creation, moving Bin2Pebwa & Pebwa2Bin from
          BinaryEncodingDecoding.ahk.
*/
/* Copyright notice: See the PhiLhoSoftLicence.txt file for details.
This file is distributed under the zlib/libpng license.
Copyright (c) 2006-2007 Philippe Lhoste / PhiLhoSoft
*/
/*
// Plain Encoding of Binary data to Windows Ansi (Pebwa)
//
// The purpose is to take binary data, which cannot be put as is in a script or
// on a Web page, for example, and to encode it to displayable chars.
// What displayable chars does we have?
// In the 7bit Ascii character map, codes < 32 and 127 are control chars,
// so are excluded. I will remove also 32 (space) as it is too often
// trimmed out by display (HTML) or processing.
// I can use also the High-Ascii range. ISO-8859-x considers the 128-159 range
// as reserved, offering the risk of becoming control chars if the high bit is
// cleared (eg. in some old e-mail client or server).
// Since I target only Windows computers, I will use the displayable
// Microsoft Windows Latin-1 characters added in this range as control chars.
// 160 (non breaking space) is removed too.
// An obvious limitation of this format is that I don't know if chosen chars are legal
// in other encoding, eg. Turkish or Russian, etc. Not to mention other platforms...
//
// The encoded data starts with a signature (magic number) allowing automatic
// identification of the format: it starts with 159 (ü) 156 (ú) <a reserved char>,
// where the reserved char will be used in the future to indicate which level /
// version of encoding is used. Currently 1.
//
// To ease the decoding, the signature is followed by the size of the unencoded
// data, encoded as described below, ending with char 151 (ó).
//
// A quantity (number of chars) is encoded using the 33-126 and 161-255 ranges:
// 0-93 is encoded by a char of code 33-126 (ie. plus 33) and
// 94-188 is encoded by a char of code 161-255 (ie. plus 67).
// Greater quantities are encoded using base189:
// 2,140,187,847 = 11,323,745 * 189 + 42
// 11,323,745 = 59,913 * 189 + 188
// 59,913 = 317 * 189 + 0
// 317 = 1 * 189 + 128
// so 2,140,187,847 = (((1 * 189 + 128) * 189 + 0) * 189 + 188) * 189 + 42
// or 2,140,187,847 = 1  128  0  188  42
//
// After this size, the base rule is: all characters in the 33-126 and 161-255 ranges
// represent themselves. One advantage is that plain text (even using Latin-1 accented chars)
// is still readable.
//
// Single 32 (space) and 160 (non breaking space) chars are encoded respectively
// with 145 (ë) and 146 (í).
// The zero byte is quite frequent in binary data, I choose to encode it with a
// single char: 149 (ï).
//
// Single chars in the 1-31 and the 127-159 ranges are encoded with the char
// 134 (Ü) followed by the code of char plus 33 (34-64 and 161-192).
//
// Multiple consecutive runs of chars are encoded with the char 137 (â) for the
// displayable chars and the char 135 (á) for the control chars followed by a
// quantity (as above), the char 151 (ó) and either the char itself (in the
// displayable range) or its encoding (for 0-32, 127-160).
// That's run-length encoding (RLE).
// Obviously, since this takes at least 4 chars, it is interesting only for
// encoding at least 5 identical displayable chars or 3 control chars.
*/

PEBWA_QTY_BASE = 188
PEBWA_MAX_LOWER_QTY = 93
PEBWA_LOW_QTY_OFFSET = 33
PEBWA_HIGH_QTY_OFFSET = 67

/*
// Encode a quantity following the rules above.
*/
EncodeQuantity(_quantity)
{
	local oneByte, encodedQ

	Loop
	{
		If (_quantity > PEBWA_QTY_BASE)
		{
			oneByte := Mod(_quantity, PEBWA_QTY_BASE)
			_quantity := _quantity // PEBWA_QTY_BASE
		}
		Else
		{
			oneByte := _quantity
			_quantity := 0
		}
		If (oneByte > PEBWA_MAX_LOWER_QTY)
		{
			oneByte := Chr(oneByte + PEBWA_HIGH_QTY_OFFSET)
		}
		Else
		{
			oneByte := Chr(oneByte + PEBWA_LOW_QTY_OFFSET)
		}
		encodedQ = %oneByte%%encodedQ%
		If (_quantity = 0)
			Break
	}
	Return encodedQ
}

/*
// Decode a quantity following the rules above.
*/
DecodeQuantity(_quantity)
{
	local byte, quantity

	quantity := 0
	Loop Parse, _quantity
	{
		; Decode 189-based digit
		byte := Asc(A_LoopField)
;~ OutputDebug b: %byte% (%A_LoopField%)
		If (byte <= PEBWA_MAX_LOWER_QTY + PEBWA_LOW_QTY_OFFSET)
		{
			byte -= PEBWA_LOW_QTY_OFFSET
		}
		Else
		{
			byte -= PEBWA_HIGH_QTY_OFFSET
		}
		quantity := quantity * PEBWA_QTY_BASE + byte
;~ OutputDebug b: %byte%, q: %quantity%
	}
	Return quantity
}

SPECIAL_ENCODED_CHAR0 := Chr(149)		; Binary zero
SPECIAL_ENCODED_CHAR32 := Chr(145)		; Space
SPECIAL_ENCODED_CHAR160 := Chr(146)	; Non Breaking Space

/*
// Convert raw bytes stored in a variable to a string of Ansi characters.
// Convert either byteNb bytes or, if null, the whole content of the variable.
//
// Return the number of converted bytes, or -1 if error (memory allocation)
*/
Bin2Pebwa(ByRef @pebwa, ByRef @bin, _byteNb=0)
{
	local dataSize, dataAddress, granted
	local val, prevVal, prevChar, count, encodedChar

	; Get size of data
	dataSize := VarSetCapacity(@bin)
	If (_byteNb < 1 or _byteNb > dataSize)
	{
		_byteNb := dataSize
	}
	dataAddress := &@bin
	; Make enough room for worse case (faster)
	granted := VarSetCapacity(@pebwa, _byteNb * 2)
	if (granted < _byteNb * 2)
	{
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}

	; Init
	count := 1
	prevVal := *dataAddress
;~ OutputDebug Size: %_byteNb% / dataAddress: %dataAddress% / first byte: %prevVal%
	dataAddress++	; Next byte
	; Go!
	Loop %_byteNb%
	{
		val := *dataAddress
;~ OutputDebug Val: %val%
		If (val != prevVal)
		{
			If (prevVal >= 33 and prevVal <= 126
					or prevVal >= 161)
			{
				; Displayable data
				prevChar := Chr(prevVal)
				If (count > 4)
				{
					; Encode RLE
					encoded := Chr(137) . EncodeQuantity(count)  . Chr(151) . prevChar
				}
				Else
				{
					; Repeat the char
					encoded =
					Loop %count%
					{
						encoded := encoded . prevChar
					}
				}
			}
			Else	; Control char
			{
				If prevVal in 0,32,160
				{
					prevChar := SPECIAL_ENCODED_CHAR%prevVal%
				}
				Else
				{
					prevChar := Chr(prevVal + 33) ; Another control char
				}
				If (count > 2)
				{
					; Encode RLE
					encoded := Chr(135) . EncodeQuantity(count) . Chr(151) . prevChar
				}
				Else
				{
					If prevVal not in 0,32,160	; No prefix for these controls chars
					{
						prevChar := Chr(134) . prevChar
					}
					; Repeat the encoded char
					encoded =
					Loop %count%
					{
						encoded := encoded . prevChar
					}
				}
			}
			prevVal := val
			count := 1
			@pebwa = %@pebwa%%encoded%
		}
		Else
		{
			count++
		}
		dataAddress++	; Next byte
	}
	; Encode the signature of format and the length
	@pebwa := Chr(159) . Chr(156) . "1"
			. EncodeQuantity(_byteNb) . Chr(151) . @pebwa

	Return _byteNb
}

SPECIAL_CONTROL_CHAR145 := 32		; Space
SPECIAL_CONTROL_CHAR146 := 160	; Non Breaking Space
SPECIAL_CONTROL_CHAR149 := 0		; Binary zero

/*
// Convert a string of encoded bytes to raw bytes stored in a variable.
// Convert either byteNb bytes or, if null, the whole content of the variable.
//
// Return the number of converted bytes, or -1 if error
*/
Pebwa2Bin(ByRef @bin, _pebwa)
{
	local byte, b1, dataSize, binaryDataSize, granted
	local encodedAddress, binaryAddress, ri, wi

	encodedAddress := &_pebwa
	; Is it starting by the signature?
	Gosub Pebwa2Bin_GetNextEncodedChar
	b1 := byte
	Gosub Pebwa2Bin_GetNextEncodedChar
	If (b1 != 159 || byte != 156)
	{
		ErrorLevel := "Bad Data Format"
		Return -1
	}
	Gosub Pebwa2Bin_GetNextEncodedChar ; Eat the version id, unused now
	; Get size of data
	Gosub Pebwa2Bin_ReadQuantity
	binaryDataSize := dataSize
	; Make enough room
	granted := VarSetCapacity(@bin, binaryDataSize, 0)
	if (granted < binaryDataSize)
	{
		; Cannot allocate enough memory
		ErrorLevel := "Not Enough Memory (" . granted . "/" . binaryDataSize . ")"
		Return -1
	}
	binaryAddress := &@bin
	wi = 0
;~ MsgBox %binaryDataSize% %granted% %binaryAddress% %encodedAddress%

	Loop
	{
		Gosub Pebwa2Bin_GetNextEncodedChar
		If (byte = 0)
			Break	; End!
		If byte in 145,146,149
		{
			Gosub Pebwa2Bin_DecodeControlChar
			Gosub Pebwa2Bin_WriteNextByte
		}
		Else If (byte = 134)
		{
			; One encoded control char
			Gosub Pebwa2Bin_GetNextEncodedChar
			Gosub Pebwa2Bin_DecodeControlChar
			Gosub Pebwa2Bin_WriteNextByte
		}
		Else If byte in 135,137
		{
			b1 := byte
			; A run of encoded chars
			Gosub Pebwa2Bin_ReadQuantity
			Gosub Pebwa2Bin_GetNextEncodedChar
			If (b1 = 135)
			{
				; Need to decode the control char
				Gosub Pebwa2Bin_DecodeControlChar
			}
			; Write bytes
			Loop %dataSize%
			{
				Gosub Pebwa2Bin_WriteNextByte
			}
		}
		Else
		{
			Gosub Pebwa2Bin_WriteNextByte	; Plain char
		}
	}
;~ 	MsgBox % DumpDWORDs(@bin, binaryDataSize)

	Return binaryDataSize

Pebwa2Bin_ReadQuantity:
	; Read quantity
	quantity := ""
	Loop
	{
		Gosub Pebwa2Bin_GetNextEncodedChar
		If (byte = 151)
			Break
		quantity := quantity . Chr(byte)
	}
	dataSize := DecodeQuantity(quantity)
Return

Pebwa2Bin_DecodeControlChar:
	If byte in 145,146,149
	{
		byte := SPECIAL_CONTROL_CHAR%byte%
	}
	Else
	{
		byte -= 33	; Other control char
	}
Return

Pebwa2Bin_GetNextEncodedChar:
	byte := *encodedAddress
;~ OutputDebug % "R => " ri ": Byte: " byte " (" Chr(byte) ")"
;~ ri++
	encodedAddress++
Return

Pebwa2Bin_WriteNextByte:
	DllCall("RtlFillMemory"
			, "UInt", binaryAddress
			, "UInt", 1
			, "UChar", byte)
;~ OutputDebug % "W => " wi ": Byte: " byte " (" Chr(byte) ")"
;~ wi++
	binaryAddress++
Return
}
