; Title:   	Hash() : Computes hash for Files, Strings and Binary data
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=392052#p392052
; Author:	SKAN
; Date:   	05.04.2021
; for:     	AHK_L

/*   Hash( Options, ByRef Var, nBytes )

   When successful, returns hash as a hex string (Optionally, in Base64 encoding).
   On failure, ErrorLevel is set with an error message.

   Parameters:

   Options:
   Options should be a string with space separated values of key:value
   The default Options should be as: algorithm:sha256 base64:0 upperhex:1 encoding:utf-8
   but only the leading 3 characters of key are relevant and so, the actual default string is alg:sha256 bas:0 upp:1 enc:utf-8
   alg: value can be one of these MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512

   Var: (VarOrAddress)
   Can be a filepath, a string or a variable containing a filepath or string.
   Furthermore , Var can contain binary data or a pointer to binary contents.
   Hash() will determine the context by referring the third parameter: nBytes

   nBytes:
   The value passed to this parameter decides the mode of operation.


*/

/*  Examples:

      Hashing a file
      Omit the third parameter (nBytes) to hash a file.
      nBytes will be equal to file size, obviously.

         MsgBox % Hash("", A_AhkPath)                        ; Default SHA256 hash formatted as hex (uppercase is default)
         MsgBox % Hash("Upper:0",  A_AhkPath)                ; Same as above but hash will be in lowercase
         MsgBox % Hash("Base64:1", A_AhkPath)                ; Default SHA256 hash as Base64 text
         MsgBox % Hash("alg:SHA512 Upper:0",   A_AhkPath)    ; SHA512 hash formatted as hex (lowercase)
         MsgBox % Hash("alg:SHA512 Base64:1",  A_AhkPath)    ; SHA512 hash formatted as Base64 text


      Hashing a string
      Pass -1 as third parameter (nBytes) to hash a string.
      nBytes will be decided as per encoding. The default is encoding:utf-8.
      Encoding only applies when hashing a string. It will be ignored when nBytes is not -1
      Only these are valid: CP0 UTF-8 UTF-16
      Note: -1 should be easy to remember.. as easy as VarSetCapacity(Var, -1)


         ; Default: SHA256, Default: Encoding UTF-8
         MsgBox % Hash("", "SKAN", -1)                                ; 5129AE7CA433CC7AA26B60434007764C3D62833903EA26E8FE98BEB73D4074E0

         ; Default: SHA256, Encoding UTF-16
         MsgBox % Hash("enc:utf-16", "SKAN", -1)                      ; CDD064556C60B0ED71B9BD685B36F0514689C8717E07BFEC744360075E598B89

         ; SHA512, Encoding UTF-16, output as Base64 string
         MsgBox % Hash("alg:SHA512 enc:utf-16 Base64:1 ", "SKAN", -1) ; 7MhDU8j8DQT2Jf++5bykErvRTuc3jeBxpIjCaefE+hgil2V1JigRajVMZos6/GeWrUVXcvR2zEGE+fzeUTr6vw==


      Hashing binary content
      When nBytes is a positive integer, (greater than 0), Hash() would deal Var contents as binary.
      Like NumPut() / NumGet(), Hash()'s Var is a VarOrAddress parameter.
      Hash("", "123456", -1) is alright..     but  Hash("", 123456, -1) isn't.
      When Var content is a pure number, Hash() will presume it to be a pointer.
      Thanks to @lexikos for type(v) for v1.1


         #NoEnv
         #Warn
         #SingleInstance, Force
         SetBatchLines, -1

         FileGetSize, nBytes, %A_AhkPath%
         FileRead, Var, *c %A_AhkPath%
         ; Hash contents of Var in binary mode
         MsgBox % Hash("Alg:MD5", Var, nBytes)
         ; Hash only 1024 tail bytes with pointer math
         MsgBox % Hash("Alg:MD5", &Var + nBytes - 1024, 1024)


*/

Hash(Options, ByRef Var, nBytes:="") { ;                                 Hash() v0.37 by SKAN on D444/D445 @ tiny.cc/hashit
Local
  HA := {"ALG":"SHA256","BAS":0, "UPP":1, "ENC":"UTF-8"}
  Loop, Parse, % Format("{:U}", Options), %A_Space%, +
     A := StrSplit(A_LoopField, ":", "+"), HA[ SubStr(A[1], 1, 3) ] := A[2]

  HA.X := ( HA.ENC="UTF-16" ? 2 : 1)
  OK1  := { "SHA1":1, "SHA256":1, "SHA384":1, "SHA512":1, "MD2":1, "MD4":1, "MD5":1 }[ HA.ALG ]
  OK2  := { "CP0":1, "UTF-8":1, "UTF-16":1}[ HA.ENC ]
  NaN  := ( StrLen(nBytes) And (nBytes != Round(nBytes)) ),                    lVar := StrLen(Var)
  pNum := ( lVar And [var].GetCapacity(1)="" And (Var = Abs(Round(Var))) ),    nVar := VarSetCapacity(Var)

  If ( OK1="" Or OK2="" Or NaN=1 Or lVar<1 Or (pNum=1 And nBytes<1) Or (pNum=0 And nVar<nBytes))
     Return ( 0, ErrorLevel := OK1="" ? "Algorithm not known.`n=> MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512`nDefault: SHA256"
                            :  OK2="" ? "Codepage incorrect.`n=> CP0 UTF-16 UTF-8`nDefault: UTF-8"
                            :  NaN=1  ? "nBytes in incorrect format"
                            :  lVar<1 ? "Var is empty. Nothing to hash."
              : (pNum=1 And nBytes<1) ? "Pointer requires nBytes greater than 0."
           : (pNum=0 And nVar<nBytes) ? "Var's capacity is lesser than nBytes." : "" )

  hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr")
  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg:=0, "WStr",HA.ALG, "Ptr",0, "Int",0, "UInt")
  DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash:=0, "Ptr", 0, "Int", 0, "Ptr",0, "Int",0, "Int", 0)

  nLen := 0, FileLen := File := rBytes := sStr := nErr := ""
  If ( nBytes!="" And (pBuf:=pNum ? Var+0 : &Var) )
         {
           If ( nBytes<=0  )
                nBytes := StrPut(Var, HA.ENC)
              , VarSetCapacity(sStr, nBytes * HA.X)
              , nBytes := ( StrPut(Var, pBuf := &sStr, nBytes, HA.ENC) - 1 ) * HA.X
           nErr := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",pBuf, "Int",nBytes, "Int", 0, "UInt")
  } Else {
           File := FileOpen(Var, "r -rwd")
           If  ( (FileLen := File.Length) And VarSetCapacity(Bin, 65536) )
                 Loop
                 If ( rBytes := File.RawRead(&Bin, 65536) )
                    nErr   := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",&Bin, "Int",rBytes, "Int", 0, "Uint")
                 Until ( nErr Or File.AtEOF Or !rBytes )
           File := ( FileLen="" ? 0 : File.Close() )
         }

  DllCall("Bcrypt.dll\BCryptGetProperty", "Ptr",hAlg, "WStr", "HashDigestLength", "UIntP",nLen, "Int",4, "PtrP",0, "Int",0)
  VarSetCapacity(Hash, nLen)
  DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",&Hash, "Int",nLen, "Int", 0)
  DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)

  If ( nErr=0 )
     VarSetCapacity(sStr, 260, 0),  nFlags := HA.BAS ? 0x40000001 : 0x4000000C
   , DllCall("Crypt32\CryptBinaryToString", "Ptr",&Hash, "Int",nLen, "Int",nFlags, "Str",sStr, "UIntP",130)
   , sStr := ( nFlags=0x4000000C And HA.UPP ? Format("{:U}", sStr) : sStr )

Return ( sStr, ErrorLevel := File=0    ? ( FileExist(Var) ? "Open file error. File in use." : "File does not exist." )
                           : FileLen=0 ? "Zero byte file. Nothing to hash."
                : (FileLen & rBytes=0) ? "Read file error."
                                : nErr ? Format("Bcrypt error. 0x{:08X}", nErr)
                             : nErr="" ? "Unknown error." : "" )
}