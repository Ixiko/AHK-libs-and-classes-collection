/*
DllCallStruct.ahk

Routines to read and write binary data to and from variables.
Helpers for DllCalls, handling of structures and such.

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.04.001 -- 2006/12/15 (PL) -- Inverted last two parameters of GetInteger, more logical.
 1.04.000 -- 2006/03/29 (PL) -- Moved Bin2Hex and Hex2Bin from to BinaryEncodingDecoding.ahk.
          Renamed/recoded SetUInt & GetUInt to SetNextUInt & GetNextUInt and
          added SetNextByte and GetNextByte.
 1.03.000 -- 2006/03/24 (PL) -- Added Pebwa2Hex & Hex2Pebwa, to encode and decode binary data
          in an Ascii format, supposedly compact.
 1.02.000 -- 2006/03/17 (PL) -- Added SetUInt & GetUInt, mostly for copy/paste of small examples.
          Created FormatHexNumber and Improved DumpDWORDs (extended mode).
 1.01.000 -- 2006/02/15 (PL) -- Moved Bin2Hex & Hex2Bin from BinReadWrite.
 1.00.000 -- 2006/01/19 (PL) -- Creation with stock ExtractInteger & InsertInteger.

GetInteger & SetInteger derivated from the AHK's documentation.
*/
/* Copyright notice: See the PhiLhoSoftLicence.txt file for details.
This file is distributed under the zlib/libpng license.
Copyright (c) 2006 Philippe Lhoste / PhiLhoSoft
*/

#Include BinaryEncodingDecoding.ahk

/*
// Write a UInt (DWORD, ULONG, etc.) after the previously written ones.
// Useful for structures made only of UInts (POINT, RECT, etc.).
//
// @struct: hold the buffer where to write the UInt
// _value: value to write
// _bReset: if true, set UInt at offset 0
*/
SetNextUInt(ByRef @struct, _value, _bReset=false)
{
	local addr
	static $offset

	If (_bReset)
	{
		$offset := 0
	}
	addr := &@struct + $offset
	$offset += 4
	DllCall("RtlFillMemory", "UInt", addr,     "UInt", 1, "UChar", (_value & 0x000000FF))
	DllCall("RtlFillMemory", "UInt", addr + 1, "UInt", 1, "UChar", (_value & 0x0000FF00) >> 8)
	DllCall("RtlFillMemory", "UInt", addr + 2, "UInt", 1, "UChar", (_value & 0x00FF0000) >> 16)
	DllCall("RtlFillMemory", "UInt", addr + 3, "UInt", 1, "UChar", (_value & 0xFF000000) >> 24)
}

/*
// Read a UInt (DWORD, ULONG, etc.) after the previously read ones.
// Useful for structures made only of UInts (POINT, RECT, etc.).
//
// @struct: hold the buffer from which to extract the UInt.
// _bReset: if true, get UInt at offset 0. Needed when calling with another structure.
*/
GetNextUInt(ByRef @struct, _bReset=false)
{
	local addr
	static $offset

	If (_bReset)
	{
		$offset := 0
	}
	addr := &@struct + $offset
	$offset += 4

	Return *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
}

/*
// Write a byte after the previously written ones.
//
// @struct: hold the buffer where to write the byte
// _value: value to write
// _bReset: if true, set byte at offset 0
*/
SetNextByte(ByRef @struct, _value, _bReset=false)
{
	local addr
	static $offset

	If (_bReset)
	{
		$offset := 0
	}
	addr := &@struct + $offset
	$offset++
	DllCall("RtlFillMemory", "UInt", addr, "UInt", 1, "UChar", _value)
}

/*
// Read a byte after the previously read ones.
//
// @struct: hold the buffer from which to extract the byte
// _bReset: if true, get byte at offset 0
*/
GetNextByte(ByRef @struct, _bReset=false)
{
	local addr
	static $offset

	If (_bReset)
	{
		$offset := 0
	}
	addr := &@struct + $offset
	$offset++

	Return *addr
}

/*
// Get and return a numerical value from the given buffer (@source) at given
// offset (_offset, in bytes). By default get a UInt/DWORD/Long (4 bytes)
// but _size parameter can be set to another size (in bytes).
// If _bIsSigned is true, interpret the result as signed number.
*/
; @source is a string (buffer) whose memory area contains a raw/binary integer at _offset.
; The caller should pass true for _bIsSigned to interpret the result as signed vs. unsigned.
; _size is the size of @source's integer in bytes (e.g. 4 bytes for a DWORD or Int).
; @source must be ByRef to avoid corruption during the formal-to-actual copying process
; (since @source might contain valid data beyond its first binary zero).
GetInteger(ByRef @source, _offset = 0, _size = 4, _bIsSigned = false)
{
	local result

	Loop %_size%  ; Build the integer by adding up its bytes.
	{
		result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)
	}
	If (!_bIsSigned OR _size > 4 OR result < 0x80000000)
		Return result  ; Signed vs. unsigned doesn't matter in these cases.
	; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:
	return -(0xFFFFFFFF - result + 1)
}

/*
// Set a numerical value (_integer) in the given buffer (@dest) at given
// offset (_offset, in bytes). By default set a UInt/DWORD/Long (4 bytes)
// but _size parameter can be set to another size (in bytes).
*/
; The caller must ensure that @dest has sufficient capacity.
; To preserve any existing contents in @dest,
; only _size number of bytes starting at _offset are altered in it.
SetInteger(ByRef @dest, _integer, _offset = 0, _size = 4)
{
	Loop %_size%  ; Copy each byte in the integer into the structure as raw binary data.
	{
		DllCall("RtlFillMemory"
				, "UInt", &@dest + _offset + A_Index-1
				, "UInt", 1
				, "UChar", (_integer >> 8*(A_Index-1)) & 0xFF)
	}
}

; Some API functions require a WCHAR string.
GetUnicodeString(ByRef @unicodeString, _ansiString)
{
	local len

	len := StrLen(_ansiString)
	VarSetCapacity(@unicodeString, len * 2 + 1, 0)

	; http://msdn.microsoft.com/library/en-us/intl/unicode_17si.asp
	DllCall("MultiByteToWideChar"
			, "UInt", 0             ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
			, "UInt", 0             ; dwFlags
			, "Str", _ansiString    ; LPSTR lpMultiByteStr
			, "Int", len            ; cbMultiByte: -1=null terminated
			, "UInt", &@unicodeString ; LPCWSTR lpWideCharStr
			, "Int", len)           ; cchWideChar: 0 to get required size
}

; Some API functions return a WCHAR string.
GetAnsiStringFromUnicodePointer(_unicodeStringPt)
{
	local len, ansiString

	len := DllCall("lstrlenW", "UInt", _unicodeStringPt)
	VarSetCapacity(ansiString, len, 0)

	; http://msdn.microsoft.com/library/en-us/intl/unicode_2bj9.asp
	DllCall("WideCharToMultiByte"
			, "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
			, "UInt", 0           ; dwFlags
			, "UInt", _unicodeStringPt ; LPCWSTR lpWideCharStr
			, "Int", len          ; cchWideChar: size in WCHAR values, -1=null terminated
			, "Str", ansiString   ; LPSTR lpMultiByteStr
			, "Int", len          ; cbMultiByte: 0 to get required size
			, "UInt", 0           ; LPCSTR lpDefaultChar
			, "UInt", 0)          ; LPBOOL lpUsedDefaultChar

	Return ansiString
}

/*
// Kept for backward compatibility (and convenience?).
*/
DumpDWORDs(ByRef @bin, _byteNb, _bExtended=false)
{
	Return DumpDWORDsByAddr(&@bin, _byteNb, _bExtended)
}

/*
// For debugging, return formatted hex string separating DWORDs
// Idem to Bin2Hex, usable directly in a MsgBox...
// Extended mode: give offsets and Ascii dump.
*/
DumpDWORDsByAddr(_binAddr, _byteNb, _bExtended=false)
{
	local dataSize, dataAddress, granted, line, dump, hex, ascii
	local dumpWidth, offsetSize, resultSize

	offsetSize = 4	; 4 hex digits (enough for most dumps)
	dumpWidth = 32
	; Make enough room (faster)
	resultSize := _byteNb * 4
	If _bExtended
	{
		dumpWidth = 16 ; Make room for offset and Ascii
		resultSize += offsetSize + 8 + dumpWidth
	}
	granted := VarSetCapacity(dump, resultSize)
	if (granted < resultSize)
	{
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}
	If _bExtended
	{
		offset = 0
		line := FormatHexNumber(offset, offsetSize) ": "
	}
	Loop %_byteNb%
	{
		; Get byte in hexa
		hex := FormatHexNumber(*_binAddr, 2)
		If _bExtended
		{
			; Get byte in Ascii
			If (*_binAddr >= 32)	; Not a control char
			{
				ascii := ascii Chr(*_binAddr)
			}
			Else
			{
				ascii := ascii "."
			}
			offset++
		}
		line := line hex A_Space
		If (Mod(A_Index, dumpWidth) = 0)
		{
			; Max dumpWidth bytes per line
			If (_bExtended)
			{
				; Show Ascii dump
				line := line " - " ascii
				ascii =
			}
			dump := dump line "`n"
			line =
			If (_bExtended && A_Index < _byteNb)
			{
				line := FormatHexNumber(offset, offsetSize) ": "
			}
		}
		Else If (Mod(A_Index, 4) = 0)
		{
			; Separate bytes per groups of 4, for readability
			line := line "| "
		}
		_binAddr++	; Next byte
	}
	If (Mod(_byteNb, dumpWidth) != 0)
	{
		If (_bExtended)
		{
			line := line " - " ascii
		}
		dump := dump line "`n"
	}

	Return dump
}
