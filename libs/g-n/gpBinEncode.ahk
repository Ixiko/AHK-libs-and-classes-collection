/*
#####################################################################################
General Purpose Binary Encode - "gpBinEncode" - v0.2 by Alibaba - 19 August 2015
http://ahkscript.org/boards/viewtopic.php?f=10&t=9209
#####################################################################################
MAIN FUNCTIONS:

	gpBinEncode(	ByRef sourceData,
					ByRef encodedData,
					encodingTable,
					sourceLength="StrLen",
					ByRef leftoverData := "omitted",
					ByRef leftoverLength := "" )
				
INTERNAL / HELP FUNCTIONS:

	gpStoreBinString(ByRef var, binString)
	gpLoadBinString(ByRef var, length)
	gpApproxAverageLength(encodingTable)

#####################################################################################
*/

; Function:     			gpBinEncode
; Description:  			Performs a serial binary coding on the given data, based on any given encoding table.
; 
; ByRef sourceData			The variable holding the source data for encoding
; ByRef encodedData			The variable in which the encoded output will be stored
; encodingTable				An array/object where indices are the binary source words and values are the respective code words
;							Note: source words and code words must always be stored as strings! Specifying a "-" as code word will act as "no output".
; sourceLength     			Amount of bits (not bytes!) to be encoded
;							If omitted, the length will be calculated using StrLen() and the string encoding (UTF-8/UTF-16)
;							A string should be passed in order for this to work correctly!
; ByRef leftoverData		(Optional) The variable in which the remainder of the source data which couldn't be encoded (no match in the encoding table), will be stored
; ByRef leftoverLength		(Optional) The variable in which the length (amount of bits) of leftoverData will be stored
;
; returns:					The length of encodedData in bits
;
; notes:					Any output that is produced (encodedData, leftoverData), will be written to an integer amount of bytes, although the length of the respective
;							data in bits doesn't have to be a multiple of 8, meaning that the last bits of the output will always be filled up to a full byte with zeros.

gpBinEncode(ByRef sourceData, ByRef encodedData, encodingTable, sourceLength="StrLen", ByRef leftoverData := "omitted", ByRef leftoverLength := ""){
	if (sourceLength == "StrLen")
		sourceLength := A_IsUnicode ? (StrLen(sourceData) * 16) : StrLen(sourceData) * 8
	encodedApproxSize := ceil(sourceLength * gpApproxAverageLength(encodingTable))
	VarSetCapacity(encodedData,encodedApproxSize,0)
	VarSetCapacity(inputbuffer,1,0)
	sourcewordbuffer := "", codewordbuffer := "", bytecount := 0, encodedBitsCounter := 0, encodedDataLength := 0
	Loop % sourceLength {
		inputbuffer := NumGet(sourceData, (A_Index - 1), "UChar")
		Loop, 8 {
			bitposition := (8 - A_Index), nextbit := (inputbuffer & (2 ** (8 - A_Index))) && 1, sourcewordbuffer .= "" . nextbit
			if (encodingTable["" . sourcewordbuffer] != "") {
				if (encodingTable["" . sourcewordbuffer] != "-"){
					bitcount := StrLen(codewordbuffer .= encodingTable["" . sourcewordbuffer])
					while (bitcount >= 8) {
						NumPut(Dec(SubStr(codewordbuffer, 1, 8)), encodedData, bytecount, "UChar")
						codewordbuffer := SubStr(codewordbuffer, 9), bitcount -= 8, bytecount++, encodedDataLength += 8
					}
				}
				sourcewordbuffer := ""
			}
			encodedBitsCounter++
			if (encodedBitsCounter == sourceLength)
				break, 2
		}
	}
	if(bitcount := StrLen(codewordbuffer .= encodingTable["" . sourcewordbuffer])){
		NumPut((Dec(SubStr(codewordbuffer, 1, 8)) << (8 - bitcount)), encodedData, bytecount, "UChar")
		encodedDataLength += bitcount
	}
	if((leftoverData != "omitted") && (leftoverLength := StrLen(sourcewordbuffer))){
		gpStoreBinString(leftoverData, sourcewordbuffer)
	}
	return encodedDataLength
}

;##################################################################################
;
; Function:     			gpStoreBinString
; Description:  			Stores any "binary" string (simple string of 0's and 1's) as binary data into an integer amount of bytes at the given location
; 
; ByRef var					The destination variable
; binStr					The "binary" string that will be converted to binary data and stored
;
; returns:					The amount of stored bits / equal to StrLen(binStr)
;
; notes:					Any output that is produced, will be written to an integer amount of bytes, although the length of the respective data in bits doesn't
;							have to be a multiple of 8, meaning that the last bits of the output will always be filled up to a full byte with zeros.
;							The output is written from most significant bit to last significant bit, meaning that the first "bit" from the string will be the first
;							byte's most significant bit at the specified destination

gpStoreBinString(ByRef var, binString){ 
	requiredBytes := ceil((strlen := StrLen(binString)) / 8)
	VarSetCapacity(var,requiredBytes,0)
	Loop, % requiredBytes {
		byte := SubStr(binString, A_Index * 8 - 7, 8), len := StrLen(byte)
		NumPut(Dec(byte) << (8 - len), var, (A_Index - 1), "UChar")
	}
	return strlen
}

;##################################################################################
;
; Function:     			gpLoadBinString
; Description:  			Reads a specified amount of bits from the specified location, returns it as a string of 0's and 1's
; 
; ByRef var					The source variable to read from
; length					The amount of bits to read
;
; returns:					The "binary" string containing the bits from the source variable
;
; notes:					Reading is done from most significant bit to last significant bit, meaning that the first byte's most significant bit at the specified
;							source, will be the first "bit" in the "binary" string.

gpLoadBinString(ByRef var, length){
	binStr := "", requiredBytes := ceil(length / 8)
	Loop, % requiredBytes {
		bin := Bin(NumGet(var, (A_Index - 1), "UChar")), bin := SubStr("00000000", 1, 8 - StrLen(bin)) . bin
		binStr .= (length > 8) ? bin : SubStr(bin, 1, length), length -= 8
	}
	return binStr
}

;##################################################################################
;
; Function:     			gpApproxAverageLength
; Description:  			Approximates the average length of output per sourceword-bit, based on a given encoding table, by assuming that shorter code words
;							appear more often than long ones
; 
; encodingTable				An array/object where indices are the binary source words and values are the respective code words
;							Note: source words and code words must always be stored as strings!
;
; returns:					The approximated average amount of bits produced by encoding a bit from a binary source word (code ratio)

gpApproxAverageLength(encodingTable){
	maxLm := 0
	for sourceWord, codeWord in encodingTable {
		maxLM := (Lm := (codeWord / sourceWord) > maxLm) ? Lm : maxLm
	}
	return maxLm
}

;##################################################################################
;##################################################################################
;
;Binary and Decimal conversion functions by infogulch
;http://www.autohotkey.com/board/topic/49990-binary-and-decimal-conversion/
Dec(x){
	b:=StrLen(x),r:=0
	loop,parse,x
		r|=A_LoopField<<--b
	return r
}
Bin(x){
	while x
		r:=1&x r,x>>=1
	return r
}