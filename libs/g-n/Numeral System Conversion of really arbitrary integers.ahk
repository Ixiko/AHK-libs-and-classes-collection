; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=85816
; Author:	Rohwedder
; Date:
; for:     	AHK_L

/*

	N = 31415926 ; Decimal Integer Number to test
	Dec = 0123456789 ; the Decimal Numerals
	Hex = 0123456789ABCDEF ; the Hexadecimal Numerals
	Comic = Oh @#&*$! ; a Comic Numeral system
	; no repeating characters!
	MsgBox,% "Dec2Comic : " N := NuSyCo(N,Dec,Comic)
	MsgBox,% "Comic2Hex : " N := NuSyCo(N,Comic,Hex)
	MsgBox,% "Hex2Dec : " N := NuSyCo(N,Hex,Dec)
	Return

*/

NuSyCo(N1,S1,S2) { ;Numeral System Conversion
	L1 := StrLen(S1), L2 := StrLen(S2)
	Loop, Parse, N1
		N := (0 N)*L1 + InStr(S1, A_LoopField) -1
	While, N ;decimal intermediate result
		N2 := SubStr(S2,Mod(N,L2)+1,1) N2, N//=L2
	Return, N2
}