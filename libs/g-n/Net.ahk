; Network-related functions v1.1
; Requires updates() #include updates.ahk
; May require WSAStartup() prior to using ws2_32.dll APIs

;================================================================
Net_MakeMAC(pStr, len=6, sep="-")	; variable length
;================================================================
{
Global A_CharSize, Ptr
if (len < 1 OR !A_CharSize)
	return
VarSetCapacity(i, 3*len*A_CharSize, 0)
Loop, %len%
	DllCall("msvcrt\" (A_IsUnicode ? "swprintf" : "sprintf")
		, Ptr, &i+3*(A_Index-1)*A_CharSize
		, "Str", "%02X" sep
		, "UChar", NumGet(pStr+0, A_Index-1, "UChar")
		, "CDecl")
VarSetCapacity(i, -1)
StringTrimRight, i, i, 1
return i
}
;================================================================
Net_MakeMAC2(pStr, sep="-")		; fixed length
;================================================================
{
Global A_CharSize, Ptr
VarSetCapacity(i, 18*A_CharSize, 0)
DllCall("msvcrt\" (A_IsUnicode ? "swprintf" : "sprintf")
	, Ptr, &i
	, "Str", "%02X" sep "%02X" sep "%02X" sep "%02X" sep "%02X" sep "%02X"
	, "UChar", NumGet(pStr+0, 0, "UChar")
	, "UChar", NumGet(pStr+0, 1, "UChar")
	, "UChar", NumGet(pStr+0, 2, "UChar")
	, "UChar", NumGet(pStr+0, 3, "UChar")
	, "UChar", NumGet(pStr+0, 4, "UChar")
	, "UChar", NumGet(pStr+0, 5, "UChar")
	, "CDecl")
VarSetCapacity(i, -1)
return i
}
;================================================================
Net_MakeIP(n)	; Convert UInt (network byte order) to dotted decimal IP string 123.456.789.012
;================================================================
{
Global
return DllCall("MulDiv", Ptr, DllCall("ws2_32\inet_ntoa", "UInt", n, Ptr), "Int", 1, "Int", 1, AStr)
}
