;-------------------------------------------------------------------------------
;
; TEA Encryption Library 0.10
; String and File Encruption Library for AutoHotkey
; 
; - Original Encryption Functions By Laszlo
; - Library Modifications by Danny Ben Shitrit (aka Icarus)
;
; - Forum: http://www.autohotkey.com/forum/viewtopic.php?p=27017#27017
;
; FUNCTIONS IN THIS LIBRARY:
;   EncryptFile( inputFile, password, outputFile="" ) ; rewrite to inputFile if
;   DecryptFile( inputFile, password, outputFile="" ) ; outputFile is empty.
;
;   NewString := EncryptString( inputString, password )
;   NewString := DecryptString( inputString, password )
;
; Revision History at the end of the file
; 
;-------------------------------------------------------------------------------

; TESTER - Delete or comment out when including the file
;-------------------------------------------------------------------------------

; File Encryption / Decryption
  EncryptFile( A_ScriptFullPath , "myNicePassword" , "encrypted.txt" )
  DecryptFile( "encrypted.txt"  , "myNicePassword" , "decrypted.txt" )

; String Encryption / Decryption
  MyString  := "Hello world, I am a nice readable string"
  Encrypted := EncryptString( MyString , "aSimplePassword" )
  Decrypted := DecryptString( Encrypted, "aSimplePassword" )

  Msgbox Original:`t`t[%MyString%]`nEncrypted:`t[%Encrypted%]`nDecrypted:`t[%Decrypted%]
  
; INI Key Encryption / Decryption
  IniWrite % EncryptString( "Clean String", "MyPass" ), test.ini, Section, Key
  IniRead  EncString, test.ini, Section, Key
  Msgbox % DecryptString( EncString, "MyPass" )

  ExitApp
;-------------------------------------------------------------------------------
; END OF TESTER


;-------------------------------------------------------------------------------
; INTERFACE
;-------------------------------------------------------------------------------
EncryptFile( inputFile, password, outputFile="" ) {
  ; Reads a file, encrypts its contents and write it back to itself or
  ; to a new file.
  ;_____________________________________________________________________________
  If( outputFile = "" )
    outputFile := inputFile
    
  FileRead FileString, %inputFile%
  FileDelete %outputFile%
  FileAppend % EncryptString( FileString, password ), %outputFile%
}

DecryptFile( inputFile, password, outputFile="" ) {
  ; Reads a file, decrypts its contents and write it back to itself or
  ; to a new file.
  ;_____________________________________________________________________________
  If( outputFile = "" )
    outputFile := inputFile
    
  FileRead FileString, %inputFile%
  FileDelete %outputFile%
  FileAppend % DecryptString( FileString, password ), %outputFile%
}


EncryptString( inputString, password ) {
  ; Gets a plain string and returns the encrypted string.
  ;_____________________________________________________________________________
  TEA_Pwd2Key( password, k1,k2,k3,k4,k5 )
  
  i := 9                         ; pad-index, force restart
  p := 0                         ; counter to be encrypted
  OutString := ""
  
  Loop Parse, inputString, `n,`r
  {
    ThisLine := A_LoopField
    L := ""                      ; processed line
    Loop % StrLen( ThisLine )
    {
      i++
      IfGreater i,8, {        ; all 9 pad values exhausted
        u := p
        v := k5              ; another secret
        p++                  ; increment counter
        TEA_TEA(u,v, k1,k2,k3,k4)
        TEA_Stream9(u,v)         ; 9 pads from encrypted counter
        i = 0
      }
      StringMid c, ThisLine, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                       ; chars > 126 or < 31 unchanged
        a += s%i%
        IfGreater a, 126, SetEnv, a, % a-95
        c := Chr(a)
      }
      L := L . c              ; attach encrypted character
    }
    OutString .= L . "`n"
  }
  StringTrimRight OutString, OutString, 1
  Return OutString
}

DecryptString( inputString, password ) {
  ; Gets an encrypted string and returns the plain string.
  ;_____________________________________________________________________________
  TEA_Pwd2Key( password, k1,k2,k3,k4,k5 )
  
  i := 9                         ; pad-index, force restart
  p := 0                         ; counter to be encrypted
  OutString := ""
  
  Loop Parse, inputString, `n,`r
  {
    ThisLine := A_LoopField
    L := ""                    ; processed line
    Loop % StrLen( ThisLine )
    {
      i++
      IfGreater i,8, {        ; all 9 pad values exhausted
        u := p
        v := k5              ; another secret
        p++                  ; increment counter
        TEA_TEA(u,v, k1,k2,k3,k4)
        TEA_Stream9(u,v)         ; 9 pads from encrypted counter
        i = 0
      }
      StringMid c, ThisLine, A_Index, 1
      a := Asc(c)
      if a between 32 and 126
      {                       ; chars > 126 or < 31 unchanged
        a -= s%i%
        IfLess a, 32, SetEnv, a, % a+95
        c := Chr(a)
      }
      L := L . c              ; attach encrypted character
    }
    OutString .= L . "`n"
  }
  StringTrimRight OutString, OutString, 1
  Return OutString
}

;-------------------------------------------------------------------------------
; INTERNAL ENCRYPTION FUNCTIONS
;-------------------------------------------------------------------------------

TEA_PWD2Key(PW, ByRef k1, ByRef k2, ByRef k3, ByRef k4, ByRef k5)
{
  TEA_CBC(k1,k2, PW, 1,2,3,4)
  TEA_CBC(k3,k4, PW, 4,3,2,1)
  k5 := k1^k2^k3^k4
}

TEA_CBC(ByRef u, ByRef v, x, k0,k1,k2,k3)
{
  u = 0
  v = 0
  Loop % Ceil(StrLen(x)/8)
  {
    p = 0
    StringLeft  c, x, 4
    Loop Parse, c
      p := (p<<8) + Asc(A_LoopField)
    u := u ^ p
    p = 0
    StringMid   c, x, 5, 4
    Loop Parse, c
      p := (p<<8) + Asc(A_LoopField)
    v := v ^ p
    TEA_TEA(u,v,k0,k1,k2,k3)
    StringTrimLeft x, x, 8
  }
}


TEA_TEA(ByRef y,ByRef z,k0,k1,k2,k3) ; (y,z) = 64-bit I/0 block
{                                    ; (k0,k1,k2,k3) = 128-bit key
  IntFormat = %A_FormatInteger%
  SetFormat Integer, D          ; needed for decimal indices
  s := 0
  d := 0x9E3779B9
  Loop 32
  {
    k := "k" . s & 3           ; indexing the key
    y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
    s := 0xFFFFFFFF & (s + d)  ; simulate 32 bit operations
    k := "k" . s >> 11 & 3
    z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
  }
  SetFormat Integer, %IntFormat%
  y += 0
  z += 0                        ; Convert to original ineger format
}

TEA_Stream9(x,y)                     ; Convert 2 32-bit words to 9 pad values
{                                ; 0 <= s0, s1, ... s8 <= 94
  Local z                       ; makes all s%i% global
  s0 := Floor(x*0.000000022118911147) ; 95/2**32
  Loop 8
  {
    z := (y << 25) + (x >> 7) & 0xFFFFFFFF
    y := (x << 25) + (y >> 7) & 0xFFFFFFFF
    x  = %z%
    s%A_Index% := Floor(x*0.000000022118911147)
  }
}

;-------------------------------------------------------------------------------
; REVISION HISTORY
;-------------------------------------------------------------------------------
/*

  2008 12 02  0.10
    Added  : EncryptFile, DecryptFile, EncryptString, DecryptString
    Changed: Internal encryption functions prefix (TEA_)
    Changed: AutoTrim Off and StringCaseSenseOff are no longer needed.

*/