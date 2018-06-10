; Parameters
; pattern 		
;			A string of two digit numbers representing the hex value of each byte of the pattern. The '0x' hex-prefix is not required
;			?? Represents a wildcard byte (can be any value)
;			All of the digit groups must be 2 characters long i.e 05, 0F, and ??, NOT 5, F or ?
;			Spaces, tabs, and 0x hex-prefixes are optional  
; haystackAddress	
;			The memory address of the binary haystack eg &haystack
; haystackAddress
;			The byte length of the binary haystack

; Return values
;  0  	Not Found
; -1 	An odd number of characters were passed via pattern
;		Ensure you use two digits to represent each byte i.e. 05, 0F and ??, and not 5, F or ?
; -2   	No valid bytes in the needle/pattern
; int 	The offset from haystackAddress of the start of the found pattern

patternScan(pattern, haystackAddress, haystackSize)
{
		StringReplace, pattern, pattern, 0x,, All
		StringReplace, pattern, pattern, %A_Space%,, All
		StringReplace, pattern, pattern, %A_Tab%,, All
		pattern := RTrim(pattern, "?")				; can pass patterns beginning with ?? ?? - but why not just start the pattern with the first known byte
		loopCount := bufferSize := StrLen(pattern) / 2
		if Mod(StrLen(pattern), 2)
			return -1  
		VarSetCapacity(binaryNeedle, bufferSize)
		aOffsets := [], startGap := 0
		loop, % loopCount
		{
			hexChar := SubStr(pattern, 1 + 2 * (A_Index - 1), 2)
			if (hexChar != "??") && (prevChar = "??" || A_Index = 1)
				binNeedleStartOffset := A_index - 1
			else if (hexChar = "??" && prevChar != "??" && A_Index != 1) 
			{

				aOffsets.Insert({ "binNeedleStartOffset": binNeedleStartOffset
								, "binNeedleSize": A_Index - 1 - binNeedleStartOffset
								, "binNeedleGap": !aOffsets.MaxIndex() ? 0 : binNeedleStartOffset - startGap + 1}) ; equals number of wildcard bytes between two sub needles
				startGap := A_index
			}

			if (A_Index = loopCount) ; last char cant be ??
				aOffsets.Insert({ "binNeedleStartOffset": binNeedleStartOffset
								, "binNeedleSize": A_Index - binNeedleStartOffset
								, "binNeedleGap": !aOffsets.MaxIndex() ? 0 : binNeedleStartOffset - startGap + 1})
			prevChar := hexChar
			if (hexChar != "??")
			{
				numput("0x" . hexChar, binaryNeedle, A_index - 1, "UChar")
				realNeedleSize++
			}
		}
		if !realNeedleSize
			return -2 ; no valid bytes in the needle

		haystackOffset := 0
		aOffset := aOffsets[arrayIndex := 1]
		loop
		{
			if (-1 != foundOffset := scanInBuf(haystackAddress, &binaryNeedle + aOffset.binNeedleStartOffset, haystackSize, aOffset.binNeedleSize, haystackOffset))
			{
				; either the first subneedle was found, or the current subneedle is the correct distance from the previous subneedle 
				; The scanInBuf returned 'foundOffset' is relative to haystackAddr regardless of haystackOffset
				if (arrayIndex = 1 || foundOffset = haystackOffset)
				{		
					if (arrayIndex = 1)
					{
						currentStartOffstet := aOffset.binNeedleSize + foundOffset ; save the offset of the match for the first part of the needle - if remainder of needle doesn't match,  resume search from here
						tmpfoundAddress := foundOffset
					}
					if (arrayIndex = aOffsets.MaxIndex())
						return foundAddress := tmpfoundAddress - aOffsets[1].binNeedleStartOffset  ;+ haystackAddress ; deduct the first needles starting offset - in case user passed a pattern beginning with ?? eg "?? ?? 00 55"
					prevNeedleSize := aOffset.binNeedleSize
					aOffset := aOffsets[++arrayIndex]
					haystackOffset := foundOffset + prevNeedleSize + aOffset.binNeedleGap   ; move the start of the haystack ready for the next needle - accounting for previous needle size and any gap/wildcard-bytes between the two needles
					continue
				}
				; else the offset of the found subneedle was not the correct distance from the end of the previous subneedle
			}
			if (arrayIndex = 1) ; couldn't find the first part of the needle
				return 0
			; the subsequent subneedle couldn't be found. 
			; So resume search from the address immediately next to where the first subneedle was found
			aOffset := aOffsets[arrayIndex := 1]
			haystackOffset := currentStartOffstet
		}

	}

	;Doesn't WORK with AHK 64 BIT, only works with AHK 32 bit
	;taken from:
	;http://www.autohotkey.com/board/topic/23627-machine-code-binary-buffer-searching-regardless-of-null/
	; -1 not found else returns offset address (starting at 0)
	; The returned offset is relative to the haystackAddr regardless of StartOffset
	scanInBuf(haystackAddr, needleAddr, haystackSize, needleSize, StartOffset = 0)
	{  static fun

		; AHK32Bit a_PtrSize = 4 | AHK64Bit - 8 bytes
		if (a_PtrSize = 8)
		  return -1

		ifequal, fun,
		{
		  h =
		  (  LTrim join
		     5589E583EC0C53515256579C8B5D1483FB000F8EC20000008B4D108B451829C129D9410F8E
		     B10000008B7D0801C78B750C31C0FCAC4B742A4B742D4B74364B74144B753F93AD93F2AE0F
		     858B000000391F75F4EB754EADF2AE757F3947FF75F7EB68F2AE7574EB628A26F2AE756C38
		     2775F8EB569366AD93F2AE755E66391F75F7EB474E43AD8975FC89DAC1EB02895DF483E203
		     8955F887DF87D187FB87CAF2AE75373947FF75F789FB89CA83C7038B75FC8B4DF485C97404
		     F3A775DE8B4DF885C97404F3A675D389DF4F89F82B45089D5F5E5A595BC9C2140031C0F7D0
		     EBF0
		  )
		  varSetCapacity(fun, strLen(h)//2)
		  loop % strLen(h)//2
		     numPut("0x" . subStr(h, 2*a_index-1, 2), fun, a_index-1, "char")
		}

		return DllCall(&fun, "uInt", haystackAddr, "uInt", needleAddr
		              , "uInt", haystackSize, "uInt", needleSize, "uInt", StartOffset)
	}




hexToBinaryBuffer(hexString, byRef buffer)
{
	StringReplace, hexString, hexString, 0x,, All
	StringReplace, hexString, hexString, %A_Space%,, All
	StringReplace, hexString, hexString, %A_Tab%,, All	
	if !length := strLen(hexString)
	{
		msgbox nothing was passed to hexToBinaryBuffer
		return 0
	}
	if mod(length, 2)
	{
		msgbox Odd Number of characters passed to hexToBinaryBuffer`nEnsure two digits are used for each byte e.g. 0E 
		return 0
	}
	byteCount := length/ 2
	VarSetCapacity(buffer, byteCount)
	loop, % byteCount
		numput("0x" . substr(hexString, 1 + (A_index - 1) * 2, 2), buffer, A_index - 1, "UChar")
	return byteCount

}

