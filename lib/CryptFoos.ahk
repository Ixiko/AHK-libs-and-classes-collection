b64Encode( ByRef buf, bufLen )
{
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", 0, "UInt*", outLen )
	VarSetCapacity( outBuf, outLen, 0 )
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
	return strget( &outBuf, outLen, "CP0" )
}

b64Decode( b64str, ByRef outBuf )
{
   static CryptStringToBinary := "crypt32\CryptStringToBinary" (A_IsUnicode ? "W" : "A")

   DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
   VarSetCapacity( outBuf, outLen, 0 )
   DllCall( CryptStringToBinary, "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )

   return outLen
}

b2a_hex( ByRef pbData, dwLen )
{
	if (dwLen < 1)
		return 0
	if pbData is integer
		ptr := pbData
	else
		ptr := &pbData
	SetFormat,integer,Hex
	loop,%dwLen%
	{
		num := numget(ptr+0,A_index-1,"UChar")
		hash .= substr((num >> 4),0) . substr((num & 0xf),0)
	}
	SetFormat,integer,D
	StringLower,hash,hash
	return hash
}

a2b_hex( sHash,ByRef ByteBuf )
{
	if (sHash == "" || RegExMatch(sHash,"[^\dABCDEFabcdef]") || mod(StrLen(sHash),2))
		return 0
	BufLen := StrLen(sHash)/2
	VarSetCapacity(ByteBuf,BufLen,0)
	loop,%BufLen%
	{
		num1 := (p := "0x" . SubStr(sHash,(A_Index-1)*2+1,1)) << 4
		num2 := "0x" . SubStr(sHash,(A_Index-1)*2+2,1)
		num := num1 | num2
		NumPut(num,ByteBuf,A_Index-1,"UChar")
	}
	return BufLen
}

Free(byRef var)
{
  VarSetCapacity(var,0)
  return
}