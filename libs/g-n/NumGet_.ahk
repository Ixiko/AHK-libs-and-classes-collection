NumGet_BE(ByRef VarOrAddress, Offset=0, Type = "UPtr") {
Static DT := AHK_DataType()
Bytes := dt[type]
VarSetCapacity(BE, Bytes, 0)
	loop,% Bytes
	{
		NumPut(NumGet(VarOrAddress, Bytes-A_Index+Offset, "UChar"), BE, A_Index-1, "UChar")
	}
	return NumGet(BE, Type)
}

NumGet_BE_Bytes(ByRef VarOrAddress, Offset=0, Type = "UPtr", Bytes="NULL") { ;BE
Static DT := AHK_DataType()
If (Bytes = "NULL")
	Bytes := dt[type]
VarSetCapacity(Buffer, 8, 0)
	loop,% Bytes
	{
		NumPut(NumGet(VarOrAddress, Bytes-A_Index+Offset, "UChar"), Buffer, A_Index-1, "UChar")
	}
	return NumGet(Buffer, Type)
}

BEint64(ByRef Var, Bytes) {
VarSetCapacity(BE, 8, 0)
	loop,% Bytes
	{
		NumPut(NumGet(Var, Bytes-A_Index, "UChar"), BE, A_Index-1, "UChar")
	}
	return NumGet(BE, "Int64")
	; ==================================================
; static qqq := MCode(BSwap64,"8B5424088B4424040FCA0FC88BC88BC28BD1C3")
	; If (bytes = 1)
		; return NumGet(Var, "UChar")
	; Else
		; return dllcall(qqq, "int64",numget(Var, "int64"), "int64")>>8*(8-Bytes)	
}

BEfloat(ByRef Var, Bytes) {
VarSetCapacity(BE, 16, 0)
	loop,% Bytes
	{
		NumPut(NumGet(Var, Bytes-A_Index, "UChar"), BE, A_Index-1, "UChar")
	}
	return NumGet(BE, "float")
}

AHK_DataType() {
Static DT :={ "":""
			, Char:    1
			, UChar:   1
			, Short:   2
			, UShort:  2
			, UInt:    4
			, Int:     4
			, Int64:   8
			, Double:  8
			, Float:   4
			, Ptr:     A_PtrSize
			, UPtr:    A_PtrSize}
return DT
}