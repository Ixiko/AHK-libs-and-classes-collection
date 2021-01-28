; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

If !A_IsUnicode
    MsgBox, 48,, Please use AHK unicode version!
Else {
    Base64encUTF8(encoded, "natas19:4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs")
    MsgBox, % encoded
}
Return

; by lifeweaver -- http://ahkscript.org/boards/viewtopic.php?p=49863#p49863
Base64encUTF8( ByRef OutData, ByRef InData )
{ ; by SKAN + my modifications to encode to UTF-8
  InDataLen := StrPutVar(InData, InData, "UTF-8") - 1
  DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, UInt,0, UIntP,TChars, "CDECL Int" )
  VarSetCapacity( OutData, Req := TChars * ( A_IsUnicode ? 2 : 1 ), 0 )
  DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, Str,OutData, UIntP,Req, "CDECL Int" )
  Return TChars
}

StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
}