#NoEnv
#Include %A_ScriptDir%\..\gpBinEncode.ahk

;Create our binary data
dataLength := gpStoreBinString(data, "000111010100001")

;===== EXAMPLE 1 =====
;Remove zeros from data / get data "weight" (amount of 1's)

remZeros := Object("1","1","0","-")

encodedLength := gpBinEncode(data, encodedData, remZeros, dataLength)

MsgBox % "EXAMPLE 1`nInput:`t" . gpLoadBinString(data, dataLength) . " (Length: " . dataLength . ")`n" . "Encoded:`t" . gpLoadBinString(encodedData, encodedLength) . " (Length: " . encodedLength . ")"



;===== EXAMPLE 2 =====
;Interpret input as 3bit groups, extend to 4bit groups with odd parity:

addParity := Object("000","0001","001","0010","010","0100","011","0111","100","1000","101","1011","110","1101","111","1110")
remParity := Object("0001","000","0010","001","0100","010","0111","011","1000","100","1011","101","1101","110","1110","111")

encodedLength := gpBinEncode(data, encodedData, addParity, dataLength)
decodedLength := gpBinEncode(encodedData, decodedData, remParity, encodedLength)

MsgBox % "EXAMPLE 2`nInput:`t" . gpLoadBinString(data, dataLength) . " (Length: " . dataLength . ")`n" . "Encoded:`t" . gpLoadBinString(encodedData, encodedLength) . " (Length: " . encodedLength . ")`n" . "Decoded:`t" . gpLoadBinString(decodedData, decodedLength) . " (Length: " . decodedLength . ")"


;===== EXAMPLE 3 =====
;Replace each 4bit binary fixed-point number of value n with exactly n 1's and a subsequent 0.
;15 bit Input will produce a 3 bit leftover since mod(15,4) = 3
;Since this code fulfills the prefix property, it's possible to decode it afterwards
;Generate encoding table by looping through all possible source words.

serialEncode := Object(), serialDecode := Object()
Loop 16 {
	sourceWord := "" . SubStr("0000", 1, 4 - StrLen(tmpsw := Bin(A_Index - 1))) . tmpsw, codeWord := SubStr("111111111111111", 1, A_Index - 1) . "0"
	serialEncode["" . sourceWord] := "" . codeWord, serialDecode["" . codeWord] := "" . sourceWord
}

encodedLength := gpBinEncode(data, encodedData, serialEncode, dataLength, leftoverData, leftoverLength)
decodedLength := gpBinEncode(encodedData, decodedData, serialDecode, encodedLength)

MsgBox % "EXAMPLE 3`nInput:`t" . gpLoadBinString(data, dataLength) . " (Length: " . dataLength . ")`n" . "Encoded:`t" . gpLoadBinString(encodedData, encodedLength) . " (Length: " . encodedLength . ")`n`tLeftover: " . gpLoadBinString(leftoverData, leftoverLength) . "`nDecoded:`t" . gpLoadBinString(decodedData, decodedLength) . " (Length: " . decodedLength . ")"