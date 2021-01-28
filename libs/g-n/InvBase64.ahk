InvBase64(B64val) {
	Chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" 
	StringReplace B64val, B64val, =,,All 
	Loop Parse, B64val 
	{
		If Mod(A_Index,4) = 1 
			buffer := InStr(Chars,A_LoopField,1) - 1 << 18
		Else If Mod(A_Index,4) = 2 
			buffer += InStr(Chars,A_LoopField,1) - 1 << 12 
		Else If Mod(A_Index,4) = 3 
			buffer +=  InStr(Chars,A_LoopField,1) - 1<< 6 
		Else { 
			buffer +=  InStr(Chars,A_LoopField,1) - 1
			out := out . Chr(buffer>>16) . Chr(255 & buffer>>8) . Chr(255 & buffer)
		} 
	}
	If Mod(B64val.Len,4) = 0 
		Return out 
	If Mod(B64val.Len,4) = 2 
		Return out . Chr(buffer>>16) 
	Return out . Chr(buffer>>16) . Chr(255 & buffer>>8) 
}
