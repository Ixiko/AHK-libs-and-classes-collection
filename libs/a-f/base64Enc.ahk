base64Enc( ByRef Bin, nBytes, LineLength := 64, LeadingSpaces := 0 ) { ; By SKAN / 18-Aug-2017
Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1
  DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",nBytes, "UInt",0x1, "Ptr",0,   "UIntP",Rqd )
  VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
  DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",nBytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
  If ( LineLength = 64 and ! LeadingSpaces )
    Return B64
  B64 := StrReplace( B64, "`r`n" )        
  Loop % Ceil( StrLen(B64) / LineLength )
    B .= Format("{1:" LeadingSpaces "s}",A_Space ) . SubStr( B64, N += LineLength, LineLength ) . "`n" 
Return B    
}