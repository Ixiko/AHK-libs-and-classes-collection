; Title:   	InBin() = InStr() for searching binary buffer.
; Link:   	    https://www.autohotkey.com/boards/viewtopic.php?f=6&t=90318
; Author:	SKAN
; Date:   	May-09-2021
; for:     	AHK_L

/* Description

InBin( pHaystack, HaystackBytes, pNeedle, NeedleBytes:=0, CaseSensitive:=1, StartingPos:=1, Occurence:=1 )
Searches binary data and returns a pointer when a needle is found or returns 0 when search fails.
ErrorLevel is set with an error message on failure.
This function was modeled after my favorite InStr() function. This function employs machine code for a faster search.

Reference:
I had wanted to write this one for a while, but recently got motivated by @teadrinker`s SearchInBuff()
There is useful info and InBuf() by @Helgef here

Quick example calls: InBin() works very similar to InStr()
In following example calls, search is made for single byte so that it works both in Ansi and Unicode AHK.
Code: Select all - Expand View - Download - Toggle Line numbers

#NoEnv
#Warn
#SingleInstance, Force

Hay    := "The Quick Brown Fox Jumps Over the Lazy Dog"
HayLen := VarSetCapacity(Hay)
Ndl    := "o"
NdlLen := 1

FoundPtr := InBin(&Hay, HayLen, &Ndl, NdlLen)          ; Normal search
MsgBox % StrGet( FoundPtr )

FoundPtr := InBin(&Hay, HayLen, &Ndl, NdlLen,, 0)      ; Search from right
MsgBox % StrGet( FoundPtr )

FoundPtr := InBin(&Hay, HayLen, &Ndl, NdlLen,, 0, 2)   ; Search from right the 2nd occurence
MsgBox % StrGet( FoundPtr )

FoundPtr := InBin(&Hay, HayLen, &Ndl, NdlLen, 0, 0, 2) ; Search from right the 2nd occurence, case-insensitive
MsgBox % StrGet( FoundPtr )

Normally, you should prepare a needle and pass its pointer to pNeedle parameter and the data length to NeedleBytes parameter.
The valid data length range for NeedleBytes parameter is 1 to 256.
InBin() will automatically prepare the needle when NeedleBytes is not a valid data length value.
The default value of NeedleBytes is 0 and when 0 it will expect pNeedle to contain hex data in which case the function will convert
Hex-to-Bin automatically, as seen in following example:
Code: Select all - Download - Toggle Line numbers

#NoEnv
#Warn
#SingleInstance, Force

VarSetCapacity(Hay, 128, 0)
StrPut("The Quick Brown Fox Jumps Over the Lazy Dog", &Hay, 128, "cp0")

FoundPtr := InBin(&Hay, 128, "4C 61 7A 79") ; 'L' 'a' 'z' 'y'
MsgBox % StrGet( FoundPtr, "cp0" )

*/

/* Examle

#NoEnv
#Warn
#SingleInstance, Force

VarSetCapacity(Hay, 128, 0)
StrPut("The Quick Brown Fox Jumps Over the Lazy Dog", &Hay, 128, "cp0")

FoundPtr := InBin(&Hay, 128, 0x797A614C, "UInt") ; uses NumPut()
MsgBox % StrGet( FoundPtr, "cp0" )
FoundPtr := InBin(&Hay, 128, "Lazy", "cp0")      ; uses StrPut()
MsgBox % StrGet( FoundPtr, "cp0" )

*/

/* Example

#NoEnv
#Warn
#SingleInstance, Force

VarSetCapacity(Hay, 128, 0)
StrPut("The Quick Brown Fox Jumps Over the Lazy Dog", &Hay, 128, "cp0")

FoundPtr := InBin(&Hay, 128, 0x6B63697551, -5) ; Hex of 'Quick' in reverse = 'kciuQ'
MsgBox % StrGet( FoundPtr, "cp0" )
FoundPtr := InBin(&Hay, 128, 74, -1) ; Ord("J") = 74
MsgBox % StrGet( FoundPtr, "cp0" )

*/

/* Example

#NoEnv
#Warn
#SingleInstance, Force

hMod     := DllCall("GetModuleHandle", "Str",A_AhkPath, "Ptr")
FoundPtr := InBin(hMod, 0xffffff, "FileDescription", "utf-16")
If ( FoundPtr )
   MsgBox % StrGet(FoundPtr + 34, "utf-16")

*/

InBin( pHaystack, HaystackBytes, pNeedle, NeedleBytes:=0, CaseSensitive:=1, StartingPos:=1, Occurence:=1 )  {
Local                                                      ; InBin v0.60 by SKAN on D456/D459 @ tiny.cc/inbin
Static InBinMcode  := InBin(0,0,0,0)
Static MemCpyLower := InBinMcode + (A_PtrSize=8 ? 204 : 184)

  If ( ! VarSetCapacity(InBinMcode) )
  {
     M1 := DllCall("Kernel32.dll\GlobalAlloc", "Int",0, "Ptr",Msz := A_PtrSize=8 ? 268 : 248, "UPtr")
     M2 := DllCall("Kernel32.dll\VirtualProtect", "Ptr",M1, "Ptr",Msz, "Int",0x40, "IntP",0)

     M3 := DllCall("Crypt32.dll\CryptStringToBinary", "Str",A_PtrSize=8
     ? "U1ZXQVSLRCRIRItcJFCJ00Qpy4XAvgEAAABBuv////9BD07yhcB+B2dEjVD/6wgBwkGJ0kUpykGD6QFFhdJyQzHSQTnadzxEidBB"
     . "ijhAODwBdShEichBigQAZ0ONPAqJ/zgEOXUVQYP5AnMbg8IB6wVEOc909kQ52nRDQQHyRYXSc78xwOs9vwEAAABBg/kBdt8PH0QA"
     . "AGYPH4QAAAAAAIn4QYoEAGdFjSQ6RYnkQjgEIXW9g8cBRDnPcuTrs0SJ0EgByEFcX15bwwAARYXAdjoxwEGJwUaKFAlBgPpAdhJB"
     . "icNCgDwZW3MIQbsgAAAA6wNFMdtFD7bSRQHaRYjSRogUCoPAAUQ5wHLIww"    :    "VYnlg+wQU1ZXi1UIi00Qi3UUi0UMKfC"
     . "JRfQxwIN9GAAPntD32IPg/kCJRfyDfRgAfgmLRRhIiUX46wuLRQwDRRgp8IlF+ItF+InHToX/cjvHRfAAAAAAO330dy+KBDo6AXU"
     . "hjQQ3igQCOgQxdRaD/gJzHP9F8OsEOfN094tF8DtFHHQnA338hf9zzDHA6x+7AQAAAIP+AXbfjQQfigQCOgQZddRDOfNy8OvNjQQ"
     . "6X15biexdwwAAAFNWV4tEJBCLVCQUi0wkGIXJdiYx9oocMID7QHYNgDwwW3MHvyAAAADrAjH/D7bbAfuIHDJGOc5y3F9eW8MAAAA"
     , "Int",A_PtrSize=8 ? 358 : 331, "Int",0x1, "Ptr",M1, "IntP",Msz, "Int",0, "Int",0)

     Return M1
  }

  If NeedleBytes is number
  {
       NeedleBytes := Max(-8, Format("{:d}", NeedleBytes))

       If ( NeedleBytes<0 && NeedleBytes>-9 )
       {
            VarSetCapacity(Bin,8)
            pNeedle := NumPut(pNeedle, Bin, "UInt64") - 8
            NeedleBytes := Abs(NeedleBytes)
       }

       Else
       If ( NeedleBytes=0 )
       {
            Src := StrReplace(pNeedle,A_Space)
            Len := StrLen(Src)
            NeedleBytes := Ceil(Len/2)
            VarSetCapacity(Bin, NeedleBytes, 0)
            If ! DllCall("Crypt32.dll\CryptStringToBinary", "Str",Src, "Int",Len, "Int",12
                     , "Ptr",pNeedle := &Bin, "UIntP",NeedleBytes, "Int",0, "Int",0)
                 Return (0, ErrorLevel := "Hex to Bin conversion failed.")
       }
  }

  Else
  If ( InStr(".double.float.uint64.int64.uint.int.ushort.short.uptr.ptr.uchar.char."
           , "." . RTrim(NeedleBytes, "*p") . ".") )
  {
       VarSetCapacity(Bin, 8, 0)
       NeedleBytes := NumPut(pNeedle, &Bin, NeedleBytes) - &Bin
       pNeedle := &Bin
  }
  Else
  {
       m := ( NeedleBytes="utf-16" || NeedleBytes="cp1200" ? 2 : 1 )
       If ! ( nBytes := StrPut(pNeedle, NeedleBytes) - 1 )
              Return (0, ErrorLevel := "String encode failed: '" . NeedleBytes . "'")
       VarSetCapacity(sStr, nBytes * m)
       nBytes := StrPut(pNeedle, &sStr, nBytes, NeedleBytes)
       pNeedle  := &sStr,   NeedleBytes := nBytes * m
  }

  NeedleBytes := Min(256, NeedleBytes)
  Occurence := Max(1, Format("{:d}", Occurence))
, CaseSensitive := !!CaseSensitive

  If ( CaseSensitive=0 && HaystackBytes>0x1000000 )
       Return (0, ErrorLevel := "Haystack too large for case-insensitve search. (Limit: 16 MiB)")

  If ( HaystackBytes - NeedleBytes - (StartingPos>0 ? StartingPos-1 : Abs(StartingPos)) < 0 )
       Return (0, ErrorLevel := "Haystack is too small to accomodate StartPosition and Needle")

  If ( CaseSensitive = False )
  {
       VarSetCapacity(Hay, HaystackBytes), pHaystack2 := &Hay
       DllCall(MemCpyLower, "Ptr",pHaystack, "Ptr",pHaystack2, "Int", HaystackBytes, "CDecl")
       VarSetCapacity(Ndl, NeedleBytes),   pNeedle2   := &Ndl
       DllCall(MemCpyLower, "Ptr",pNeedle,   "Ptr",pNeedle2,   "Int", NeedleBytes,   "CDecl")
  }

  FoundPtr := DllCall(InBinMcode, "Ptr",CaseSensitive ? pHaystack : pHaystack2,  "Int", HaystackBytes
                                , "Ptr",CaseSensitive ? pNeedle   : pNeedle2,  "Short", NeedleBytes
                                , "Int",StartingPos, "Int",Occurence, "CDecl Ptr")

  ErrorLevel := ( FoundPtr="" ? "Memory access violation" : FoundPtr=0 ? "Needle not found." : "" )
Return ( FoundPtr ? ( CaseSensitive ? FoundPtr : pHaystack + FoundPtr - pHaystack2 ) : FoundPtr )
}