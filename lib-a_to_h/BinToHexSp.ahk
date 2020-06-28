; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/


BinToHexSp(ByRef B, NB:=0, ByRef H:="", F:=0x40000004) { ; By SKAN on D36P/D36P @ tiny.cc/bintohexsp
Local BB:=NB ? NB : VarSetCapacity(B), HB:=(BB*(F?3:2))*(A_Isunicode?2:1), X:=VarSetCapacity(H,HB,0)
Return DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&B,"Int",BB,"Int",F?F:12,"Str",H,"UIntP",HB)
}

InHex(Haystack, Needle, CS:=0, Pos:=1, Occur:=1) { ; InHex by SKAN on D36P/D36P @ tiny.cc/bintohexsp
Return (ErrorLevel:=InStr(Haystack, Needle, CS, Pos, Occur)) ? ((ErrorLevel+2)//3)-1 : ""  
}
