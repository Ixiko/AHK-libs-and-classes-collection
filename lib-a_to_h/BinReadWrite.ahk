/*
BinReadWrite.ahk

Routines to read and write binary data from/to files.
Based on original functions written by Laszlo

http://www.autohotkey.com/forum/viewtopic.php?t=7549

TODO: Perhaps set a lastError variable to explicit the errors.

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.04.000 -- 2007/04/12 (PL) -- Code cleanup.
 1.03.000 -- 2006/02/15 (PL) -- Moved Bin2Hex & Hex2Bin to DllCallStruct, apply code rules.
 1.02.000 -- 2006/01/24 (PL) -- Slight change of the API: all functions return -1 if error.
			  Integrated Laszlo suggestions on improving Bin2Hex and Hex2Bin.
 1.01.000 -- 2006/01/23 (PL) -- Declaration of the local variables, to get access to global
			 WinAPI constants, and for consistency.
 1.00.000 -- 2006/01/19 (PL) -- Rewrote the functions to separate opening and closing,
			 allowing efficient multiple operations.
*/
/* Copyright notice: See the PhiLhoSoftLicence.txt file for details.
This file is distributed under the zlib/libpng license.
Copyright (c) 2006 Philippe Lhoste / PhiLhoSoft
*/

; WinAPI constants
INVALID_HANDLE_VALUE = -1
INVALID_FILE_SIZE = 0xFFFFFFFF
FILE_BEGIN = 0
FILE_CURRENT = 1
FILE_END = 2

/*
// Open the file for reading.
// Return the file handle to provide in further read operations and in the final close operation,
// or INVALID_HANDLE_VALUE if an error was found.
*/
OpenFileForRead(_filename)
{
	local handle

	handle := DllCall("CreateFile"
			, "Str", _filename		; lpFileName
			, "UInt", 0x80000000		; dwDesiredAccess (GENERIC_READ)
			, "UInt", 3		; dwShareMode (FILE_SHARE_READ|FILE_SHARE_WRITE)
			, "UInt", 0		; lpSecurityAttributes
			, "UInt", 3		; dwCreationDisposition (OPEN_EXISTING)
			, "UInt", 0		; dwFlagsAndAttributes
			, "UInt", 0)	; hTemplateFile
	If (handle = INVALID_HANDLE_VALUE or handle = 0)
	{
		ErrorLevel = -1
	}
	If (ErrorLevel != 0)
		Return INVALID_HANDLE_VALUE	; Couldn't open the file
	Return handle
}

/*
// Open the file for writing.
// Return the file handle to provide in further write operations and in the final close operation,
// or INVALID_HANDLE_VALUE if an error was found.
*/
OpenFileForWrite(_filename)
{
	local handle

	handle := DllCall("CreateFile"
			, "Str", _filename		; lpFileName
			, "UInt", 0x40000000	; dwDesiredAccess (GENERIC_WRITE)
			, "UInt", 3		; dwShareMode (FILE_SHARE_READ|FILE_SHARE_WRITE)
			, "UInt", 0		; lpSecurityAttributes
			, "UInt", 4		; dwCreationDisposition (OPEN_ALWAYS: create if not exists)
			, "UInt", 0		; dwFlagsAndAttributes
			, "UInt", 0)	; hTemplateFile
	If (handle = INVALID_HANDLE_VALUE or handle = 0)
	{
		ErrorLevel = -1
	}
	If (ErrorLevel != 0)
		Return INVALID_HANDLE_VALUE	; Couldn't open the file
	Return handle
}

/*
// Close the file.
*/
CloseFile(_handle)
{
	local result

	result := DllCall("CloseHandle", "UInt", _handle)
	If (result = 0)
	{
		ErrorLevel = -1
	}
}

/*
// Get the size of the opened file, in bytes.
// Limited to 4GB, so it is more limited that AHK's FileGetSize.
// It is here for consistency, and because it accepts a file handle instead of a path.
//
// Return the size in bytes, -1 if there was an error.
*/
GetFileSize(_handle)
{
	local fileSize

	fileSize := DllCall("GetFileSize"
			, "UInt", _handle
			, "UInt", 0)
	If (fileSize = INVALID_FILE_SIZE)
	{
		ErrorLevel = -1
	}
	If (ErrorLevel != 0)
		Return -1
	Return fileSize
}

/*
// Move the file pointer in the file to the given offset relative to moveMethod.
//
// moveMethod can be FILE_BEGIN, FILE_CURRENT or FILE_END.
// If moveMethod is -1, nothing is done (default, for operations at current position).
// To get the current position, call this function with just FILE_CURRENT (null offset).
// offset can be positive (toward end of the file) or negative (toward start of the file).
//
// Return -1 if there was an error, the new file pointer position if OK.
// Note: Currently it doesn't work for files larger than 2GB...
*/
MoveInFile(_handle, _moveMethod=-1, _offset=0)
{
	local result

	result = %INVALID_FILE_SIZE%
	if (_moveMethod != -1)
	{
		result := DllCall("SetFilePointer"
				, "UInt", _handle		; hFile
				, "Int", _offset		; lDistanceToMove
				, "UInt", 0			; lpDistanceToMoveHigh
				, "UInt", _moveMethod)	; dwMoveMethod
		if (result = -1)	; INVALID_SET_FILE_POINTER
		{
			ErrorLevel = -1
		}
		If (ErrorLevel != 0)
			Return -1	; Couldn't make the move
	}
	Return result
}

/*
// Write in a file opened for writing.
//
// Move to position given by moveMethod and offset
// (by default stand at current position) and
// write byteNb bytes from data (all data if byteNb = 0;
// data contains binary bytes that can be a string or
// raw bytes generated from hexa data with the Hex2Bin routine).
//
// moveMethod, defaulting to -1 (no move, write at current position),
// can also be FILE_BEGIN, FILE_CURRENT or FILE_END.
// offset can be positive (toward end of file) or negative (toward beginning of file).
//
// Return the number of bytes written (-1 if there was an error).
*/
WriteInFile(_handle, ByRef @data, _byteNb=0, _moveMethod=-1, _offset=0)
{
	local dataSize, result, written

	_offset := MoveInFile(_handle, _moveMethod, _offset)
	If (ErrorLevel != 0)
		Return -1	; Couldn't make the move

	dataSize := VarSetCapacity(@data)        ; Get the capacity (>= used length!)
	If (_byteNb < 1 or _byteNb > dataSize)
	{
		_byteNb := dataSize
	}
	result := DllCall("WriteFile"
			, "UInt", _handle	; hFile
			, "UInt", &@data	; lpBuffer
			, "UInt", _byteNb	; nNumberOfBytesToWrite
			, "UInt *", written	; lpNumberOfBytesWritten
			, "UInt", 0)		; lpOverlapped
	if (result = 0 or written < _byteNb)
	{
		ErrorLevel = -2
	}
	If (ErrorLevel != 0)
		Return -1	; Couldn't write in the file
	Return written
}

/*
// Read from a file opened for reading.
//
// Move to position given by moveMethod and offset
// (by default stand at current position) and
// read byteNb bytes in data (the whole file if byteNb = 0;
// data contains binary bytes that can be a string or
// raw bytes that can be converted to hex digits with the Bin2Hex routine).
//
// moveMethod, defaulting to -1 (no move, read at current position),
// can also be FILE_BEGIN, FILE_CURRENT or FILE_END.
// offset can be positive (toward end of file) or negative (toward beginning of file).
//
// Return the number of bytes read (-1 if there was an error), which can be less
// than requested if end-of-file is meet.
*/
ReadFromFile(_handle, ByRef @data, _byteNb=0, _moveMethod=-1, _offset=0)
{
	local fileSize, result, read

	_offset := MoveInFile(_handle, _moveMethod, _offset)
	If (ErrorLevel != 0)
		Return -1	; Couldn't make the move

	if (_byteNb = 0)
	{
		; Read whole file (or less if file pointer isn't at start)
		fileSize := GetFileSize(_handle)
		If (ErrorLevel != 0)
			Return -1	; Couldn't get the file size
		_byteNb := fileSize
	}
	VarSetCapacity(@data, _byteNb, 0)

	result := DllCall("ReadFile"
			, "UInt", _handle	; hFile
			, "UInt", &@data	; lpBuffer
			, "UInt", _byteNb	; nNumberOfBytesToRead
			, "UInt *", read	; lpNumberOfBytesRead
			, "UInt", 0)		; lpOverlapped
	if (result = 0)
	{
		ErrorLevel = -2
	}
;~ MsgBox fileSize: %fileSize% - offset: %_offset% - byteNb: %_byteNb% - read: %read%
	If (ErrorLevel != 0)
		Return -1	; Couldn't read the file

	; Note that we can have read less data than requested,
	; eg. if end of file has been meet
	Return read
}
