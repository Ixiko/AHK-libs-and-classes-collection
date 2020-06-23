

Base64enc( ByRef OutData, ByRef InData, InDataLen ) {
    TChars:=""
 DllCall( "Crypt32.dll\CryptBinaryToString" ( A_IsUnicode ? "W" : "A" )
        , UInt,&InData, UInt,InDataLen, UInt,1, UInt,0, UIntP,TChars, "CDECL Int" )
 VarSetCapacity( OutData, Req := TChars * ( A_IsUnicode ? 2 : 1 ) )
 DllCall( "Crypt32.dll\CryptBinaryToString" ( A_IsUnicode ? "W" : "A" )
        , UInt,&InData, UInt,InDataLen, UInt,1, Str,OutData, UIntP,Req, "CDECL Int" )
Return TChars
}

Base64dec( ByRef OutData, ByRef InData ) {
    Bytes:=0
 DllCall( "Crypt32.dll\CryptStringToBinary" ( A_IsUnicode ? "W" : "A" ), UInt,&InData
        , UInt,StrLen(InData), UInt,1, UInt,0, UIntP,Bytes, Int,0, Int,0, "CDECL Int" )
 VarSetCapacity( OutData, Req := Bytes * ( A_IsUnicode ? 2 : 1 ) )
 DllCall( "Crypt32.dll\CryptStringToBinary" ( A_IsUnicode ? "W" : "A" ), UInt,&InData
        , UInt,StrLen(InData), UInt,1, Str,OutData, UIntP,Req, Int,0, Int,0, "CDECL Int" )
Return Bytes
}

VarZ_Save( ByRef Data, DataSize, TrgFile ) { ; By SKAN
; http://www.autohotkey.com/community/viewtopic.php?t=45559
 hFile :=  DllCall( "_lcreat", ( A_IsUnicode ? "AStr" : "Str" ),TrgFile, UInt,0 )
 IfLess, hFile, 1, Return "", ErrorLevel := 1
 nBytes := DllCall( "_lwrite", UInt,hFile, UInt,&Data, UInt,DataSize, UInt )
 DllCall( "_lclose", UInt,hFile )
Return nBytes
}


; ======================================================================================================================
; Namespace:   Base64
; AHK version: AHK 1.1.+ (required)
; Function:    Methods for Base64 en/decoding.
; Language:    English
; Tested on:   Win XPSP3, Win VistaSP2 (U32) / Win 7 (U64)
; Version:     1.0.00.00/2012-08-12/just me
; URL:         http://msdn.microsoft.com/en-us/library/windows/desktop/aa380252(v=vs.85).aspx
; Remarks:     The ANSI functions are used by default to save space. ANSI needs about 133 % of the original size for
;              encoding, whereas Unicode needs about 266 %.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class Base64 {
   ; CRYPT_STRING_BASE64 = 0x01
   ; ===================================================================================================================
   ; Base64.Encode()
   ; Parameters:
   ;    VarIn  - Variable containing the input buffer
   ;    SizeIn - Size of the input buffer in bytes
   ;    VarOut - Variable to receive the encoded buffer
   ;    Use    - Use ANSI (A) or Unicode (W) function
   ;             Default: A
   ; Return values:
   ;    On success: Number of bytes copied to VarOut, not including the terminating null character
   ;    On failure: False
   ; Remarks:
   ;    VarIn may contain any binary contents including NUll bytes.
   ; ===================================================================================================================
   Encode(ByRef VarIn, SizeIn, ByRef VarOut, Use = "A") {
      Static Codec := 0x01 ; CRYPT_STRING_BASE64
      If (Use <> "W")
         Use := "A"
      SizeOut:=0
      Enc := "Crypt32.dll\CryptBinaryToString" . Use
      If !DllCall(Enc, "Ptr", &VarIn, "UInt", SizeIn, "UInt", Codec, "Ptr", 0, "UIntP", SizeOut)
         Return False
      VarSetCapacity(VarOut, SizeOut << (Use = "W"), 0)
      If !DllCall(Enc, "Ptr", &VarIn, "UInt", SizeIn, "UInt", Codec, "Ptr", &VarOut, "UIntP", SizeOut)
         Return False
      Return SizeOut << (Use = "W")
   }
   ; ===================================================================================================================
   ; Base64.Decode()
   ; Parameters:
   ;    VarIn  - Variable containing a null-terminated Base64 encoded string
   ;    VarOut - Variable to receive the decoded buffer
   ;    Use    - Use ANSI (A) or Unicode (W) function
   ;          Default: A
   ; Return values:
   ;    On success: Number of bytes copied to VarOut
   ;    On failure: False
   ; Remarks:
   ;    VarOut may contain any binary contents including NUll bytes.
   ; ===================================================================================================================
   Decode(ByRef VarIn, ByRef VarOut, Use = "A") {
      Static Codec := 0x01 ; CRYPT_STRING_BASE64
      If (Use <> "W")
         Use := "A"
      SizeOut:=0
      Dec := "Crypt32.dll\CryptStringToBinary" . Use
      If !DllCall(Dec, "Ptr", &VarIn, "UInt", 0, "UInt", Codec, "Ptr", 0, "UIntP", SizeOut, "Ptr", 0, "Ptr", 0)
         Return False
      VarSetCapacity(VarOut, SizeOut, 0)
      If !DllCall(Dec, "Ptr", &VarIn, "UInt", 0, "UInt", Codec, "Ptr", &VarOut, "UIntP", SizeOut, "Ptr", 0, "Ptr", 0)
         Return False
      Return SizeOut
   }
}
