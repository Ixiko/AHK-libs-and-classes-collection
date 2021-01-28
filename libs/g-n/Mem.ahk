;=========================================================================================
; Title:	Mem
;			*Functions to work with binary data*
;
;About:
;		o Ver 1.0 by majkinetor. See http://www.autohotkey.com/forum/topic20495.html
;		o Original code by Philo & Laszlo
;		o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.
;
; 2 Mem-libs in one , merged 2018
;=========================================================================================

Mem_Dump(_binAddr, _byteNb=0, _bExtended=false) {

	;-----------------------------------------------------------------
	; Function:		Dump
	;				Returns formatted hex string from address
	;
	; Parameters:
	;				_binAddr - Reference to binary data
	;				_byteNb	 - Number of bytes to dump
	;				_bExtend - Set to true to get offsets and Ascii dump.
	;
	; Returns:
	;				Memory dump	
	;

	local dataSize, dataAddress, granted, line, dump, hex, ascii
	local dumpWidth, offsetSize, resultSize, offset

	offsetSize := 4,	dumpWidth := 32								; 4 hex digits (enough for most dumps)

	; Make enough room (faster)
	if !_byteNb 
		_byteNb := VarSetCapacity( _binAddr )
		
	resultSize := _byteNb * 4
	If _bExtended
		dumpWidth :=16,  resultSize += offsetSize + 8 + dumpWidth	; Make room for offset and Ascii


	granted := VarSetCapacity(dump, resultSize)
	if (granted < resultSize)
	{
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}

	If _bExtended
		offset := 0,  line := Mem_FormatHexNum(offset, offsetSize) ": "

	Loop %_byteNb%
	{
		hex := Mem_FormatHexNum(*_binAddr, 2)						; Get byte in hexa

		If _bExtended	
			offset++,	ascii .= (*_binAddr >= 32) ? Chr(*_binAddr) : "."		; Get byte in Ascii;   binAdr >=32 is not a control char

		line := line hex A_Space
		If (Mod(A_Index, dumpWidth) = 0)
		{
			; Max dumpWidth bytes per line
			If (_bExtended)
				line := line " - " ascii, 	ascii := ""				; Show Ascii dump

			dump := dump line "`n",  line := ""
			If (_bExtended && A_Index < _byteNb)
				line := Mem_FormatHexNum(offset, offsetSize) ": "
		}
		Else If (Mod(A_Index, 4) = 0)
			line := line "| "										; Separate bytes per groups of 4, for readability

		_binAddr++	; Next byte
	}

	If (Mod(_byteNb, dumpWidth) != 0){
		If (_bExtended)
			line := line " - " ascii
		dump := dump line "`n"
	}

	Return dump
}

Mem_Bin2Hex(ByRef @hexString, @bin, _byteNb=0) {
	
	/*	Function: Bin2Hex
	Convert raw bytes stored in a variable to a string of hexa digit pairs.

	Parameters:
		@hexString	- Reference to the variable that will receive the hex string
		@bin		- Input binary data
		_byteNb		- Optional number of bytes to convert, default 0 means to convert
					  whole variable content

	Returns:
		The number of converted bytes, or -1 if error (memory allocation)
*/
	
	local dataSize, dataAddress, granted, f

	; Get the size of the data
	dataSize := _byteNb < 1 ? VarSetCapacity(@bin) : _byteNb
	

	; Make enough room (faster)
	granted := VarSetCapacity(@hexString, dataSize * 5)
	if (granted < dataSize * 5)
	{
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}


	f := A_FormatInteger, 	dataAddress := &@bin
	SetFormat Integer, H
	Loop %dataSize%
		@hexString .= *(dataAddress++) + 256
	StringReplace @hexString, @hexString, 0x1, , All
	SetFormat Integer, %f%
	

	StringUpper @hexString, @hexString
	Return dataSize
}

Mem_Hex2Bin(ByRef @bin,  @hex, _byteNb=0) {
	
	/*	Function:  Hex2Bin
	Convert a string of hexa digit pairs to raw bytes.
	
	Parameters:
		@bin		- Reference to the variable that will receive binary data 
		@hexString	- Input hex string
		_byteNb		- Optional number of bytes to convert, default 0 means to convert
					  whole variable content

	Returns:
		The number of converted bytes, or -1 if error (memory allocation)

*/
	
	local l, data, granted, dataAddress, dataSize

  	; Get the size of the data
	dataSize := _byteNb < 1 ? VarSetCapacity(@hex) : _byteNb

	If (_byteNb < 1 or _byteNb > dataSize)	
	{
		l := StrLen(@hex), 	_byteNb := l // 2				; Get size of data

		if (l = 0 or _byteNb * 2 != l)	{
			; Invalid string, empty or odd number of digits
			ErrorLevel := "Invalid param"
			Return -1
		}
	}

	; Make enough room
	granted := VarSetCapacity(@bin, _byteNb, 0)
	if (granted < _byteNb){
		; Cannot allocate enough memory
		ErrorLevel = Mem=%granted%
		Return -1
	}

	data := RegExReplace(@hex, "..", "0x$0!")
	StringLeft data, data, _byteNb * 5
	dataAddress := &@bin

	Loop Parse, data, !
		DllCall("RtlFillMemory", "UInt", dataAddress++	, "UInt", 1, "Uint", A_LoopField)

	Return _byteNb
}

Mem_FormatHexNum(_value, _digitNb=0) {
	/*	Function:	FormatHexNum
				Format number as hex string

	Parameters:
				_value	  -	value to be formated as hex string	
				_digitNb  - number of digits the resulting hex number will contain

	Returns:
				String containing formated hex number
*/
	local hex, intFormat

	intFormat := A_FormatInteger				; Save original integer format

	SetFormat Integer, Hex						; For converting bytes to hex

	hex := _value + 0
	if _digitNb between 1 and 16
		hex += (1 << 4 * _digitNb)

	if !_digitNb
		 StringTrimLeft, hex, hex, 2
	else StringRight hex, hex, _digitNb

	StringUpper hex, hex						; I prefer my hex numbers to be in upper case
	SetFormat Integer, %intFormat%				; Restore original integer format

	Return hex
}

Mem_StrAtAdr(adr) { 
;----------------------------------------------------------------------------------------
;	Function:		StrAtAdr
;					Get string from address
;
;	Parameters:
;					adr - Address of the string
;
;   Returns:
;					String
;
Return DllCall("MulDiv", "Int",adr, "Int",1, "Int",1, "str") 
}

Mem_Allocate(bytes) {
	static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
	return DllCall("HeapAlloc", "Ptr", Mem_GetHeap(), "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes, "Ptr")
}

Mem_GetHeap() {
	static heap := DllCall("GetProcessHeap", "Ptr")
	return heap
}

Mem_Release(buffer) {
	return DllCall("HeapFree", "Ptr", Mem_GetHeap(), "UInt", 0, "Ptr", buffer, "Int")
}

Mem_Copy(src, dest, bytes) {
	DllCall("RtlMoveMemory", "Ptr", dest, "Ptr", src, "UInt", bytes)
}




