Bin_Hex(ByRef Bin,Len,Chunks=32, Div="|") {
	; Bin2Hex - Convert Binary data in a variable to hex, good for displaying data from a DLL call
	;	Bin   = The data,
	;	Len	  = The size in bytes
	;	Chunks= How many bits to insert a divider, set to zero for no divider
	;	Div	  = Character/String to divide chunks
	; Returns - String with Hex characters and chunks dividers
	;	e.g.  - "EC010100|00000000|0404000|60EB6D04"
	bytes:=Chunks/8
	strint:=A_FormatInteger
	SetFormat, IntegerFast, H
	line:=""
	Loop, %Len% {
		chunk:=NumGet(Bin,A_Index-1, "UChar") 
		chunk:=SubStr("00" . SubStr(chunk,3), -1) 
		if (!Mod(A_Index-1,bytes) && Chunks!=0)
			line.=Div
		line.=chunk
	}
	SetFormat, IntegerFast, %strint%
	Return line
}

Hex_Bin(ByRef bin, hex) { ; Hex2Bin(fun,"8B4C24") = MCode(fun,"8B4C24")
   Static fun
   If (fun = "") {
      h:="568b74240c8a164684d2743b578b7c240c538ac2c0e806b109f6e98ac802cac0e104880f8"
       . "a164684d2741a8ac2c0e806b309f6eb80e20f02c20ac188078a16474684d275cd5b5f5ec3"
      VarSetCapacity(fun,StrLen(h)//2)
      Loop % StrLen(h)//2
         NumPut("0x" . SubStr(h,2*A_Index-1,2), fun, A_Index-1, "Char")
   }
   VarSetCapacity(bin,StrLen(hex)//2)
   dllcall( &fun, "uint",&bin, (A_IsUnicode ? "AStr" : "Str"),hex, "cdecl" )
}