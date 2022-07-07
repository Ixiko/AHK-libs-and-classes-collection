; ====================
; https://autohotkey.com/boards/viewtopic.php?f=6&t=47895
; https://autohotkey.com/board/topic/6316-rc4-encryption-to-hex-stream/
; Base64 + RC4 Encode / Decode a string (binary-to-text encoding)
; Encrypt Functions
; =========================

b64Encode(string)
{
    If (string != "") {
		Len1 := StrPut(string, "UTF-8")
        VarSetCapacity(bin, Len1) && len := StrPut(string, &bin, "UTF-8") - 1
        if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size:=0))
            throw Exception("CryptBinaryToString failed", -1)
        VarSetCapacity(buf, size << 1, 0)
        if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
            throw Exception("CryptBinaryToString failed", -1)
		
        return StrGet(&buf)
    }
}

b64Decode(string) {
    InvalidChars := RegexMatch(string,"[\#\(\)\$\^\{\}\[\]\.\*\?\+\|]+")
    If (InvalidChars > 0) {
        MsgBox "Invalid characters detected.  Halting.  (Char position: " InvalidChars ")"
        return
    }
    
    If (string != "") {
        if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size:=0, "ptr", 0, "ptr", 0))
            throw Exception("CryptStringToBinary failed", -1)
        VarSetCapacity(buf, size, 0)
        if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
            throw Exception("CryptStringToBinary failed", -1)
        
        return StrGet(&buf, size, "UTF-8")
    }
}

swap(ByRef val1,ByRef val2) {
	c:=val1, val1:=val2, val2:=c, c:=""
}

RC4txt2hex(Data,Pass) {
    If (Data != "") {
	   passLen := StrLen(Pass)
       b := Format("0x{:X}",0), j := Format("0x{:X}",0)
       VarSetCapacity(Result,StrLen(Data)*2)
       Loop 256 {
          a := Format("0x{:X}",A_Index - 1)
          ,Key%a% := Format("0x{:X}",passLen?Ord(SubStr(Pass, Mod(a,passLen)+1, 1)):0)
          ,sBox%a% := Format("0x{:X}",a)
	   }
       Loop 256 {
          a := Format("0x{:X}",A_Index - 1)
          b := b + sBox%a% + Key%a%  & 255, b := Format("0x{:X}",b)
		  temp := sBox%a%, sBox%a% := sBox%b%, sBox%b% := temp, temp := "" ; swap
	   }
	   Loop Parse, Data
	   {
          i := Format("0x{:X}",A_Index & 255)
          j := Format("0x{:X}",sBox%i% + j & 255)
          k := Format("0x{:X}",sBox%i% + sBox%j% & 255)
		  temp := sBox%i%, sBox%i% := sBox%j%, sBox%j% := temp, temp := "" ; swap
		  numConv := String(Format("0x{:X}",Ord(A_LoopField)^sBox%k%))
          Result .= SubStr(numConv, -2, 2)
	   }
       Return Result
   }
}

RC4hex2txt(Data,Pass) {
    If (Data != "") {
	   passLen := StrLen(Pass)
       b := 0, j := 0, x := "0x"
       VarSetCapacity(Result,StrLen(Data)//2)
       Loop 256
          a := A_Index - 1
         ,Key%a% := passLen?Ord(SubStr(Pass, Mod(a,passLen)+1, 1)):0
         ,sBox%a% := a
       Loop 256 {
          a := A_Index - 1
          b := b + sBox%a% + Key%a%  & 255
		  temp := sBox%a%, sBox%a% := sBox%b%, sBox%b% := temp, temp := "" ; swap
	   }
       Loop StrLen(Data)//2 {
          i := A_Index  & 255
          j := sBox%i% + j  & 255
          k := sBox%i% + sBox%j%  & 255
		  temp := sBox%i%, sBox%i% := sBox%j%, sBox%j% := temp, temp := "" ; swap
          Result .= Chr((x . SubStr(Data,2*A_Index-1,2)) ^ sBox%k%)
	   }
       Return Result
   }
}

; ==========================================================================
; Link: https://autohotkey.com/boards/viewtopic.php?f=6&t=35964&hilit=base64
; Poster: SKAN
; ==========================================================================
;
; Parameters:
; Bin = Binary data
; nBytes = length of data
; LineLength = length of output string before wrapping, defaults to 64
; LeadingSpaces = number of spaces before string start, defaults to 0
;
; File := "ahkicon.png"
; If ! FileExist( File )
; URLDownloadToFile, http://i.imgur.com/dS56Ewu.png, %File%

; FileGetSize, nBytes, %File%
; FileRead, Bin, *c %File%
; B64Data := Base64Enc( Bin, nBytes, 100, 2 )
; MsgBox % Clipboard := B64Data 

; Return ;     // end of auto-execcute section //

Base64EncBin( ByRef Bin, nBytes, LineLength := 64, LeadingSpaces := 0 ) { ; By SKAN / 18-Aug-2017
    Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1
    DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",nBytes, "UInt",0x1, "Ptr",0,   "UIntP",Rqd:=0 )
    VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
    DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",nBytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
    If ( LineLength = 64 and ! LeadingSpaces )
        Return B64
    B64 := StrReplace( B64, "`r`n" )        
    Loop Ceil( StrLen(B64) / LineLength )
    B .= Format("{1:" LeadingSpaces "s}","" ) . SubStr( B64, N += LineLength, LineLength ) . "`n" 
    Return RTrim( B,"`n" )    
}

; maybe like this:
; B64 = B64 text data
; Bin = output var with binary data to be written to file via File.WriteRaw()
;
; Base64Dec returns the length of bytes which is needed to write the file wth File.WriteRaw()
;
; Example:
;
; Base64ImageData := "
; ( LTrim Join
  ; iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAz1BMVEX///8AAAD7/fwjdCv///+bwJ8SaBv///////9KjFBon26U
  ; u5j///////////////////////9Oj1VfmmX///////////////8NZRb4+PgJQw4MYBUJRw8MXRTP2dAKTBAJSBCguKJnf2nP1M+g
  ; raELWBNokmsLVBIKThEKUBEMWxMLUhILVhMJShDu8O7a4NotcTLk6eTE0cW4wrmUr5aHpolXh1uUopSGmIdWclhEfUgrVS3Ey8St
  ; wK6st614nHp3i3hCZES5ybosZDCUqpV0X6tXAAAAGHRSTlOzALL2jMz9TRXm3M6deVosJiHk35h1W1hTCYFzAAAIt0lEQVR42uzW
  ; SQrDMAxA0V/ZTpx5oCG6/0kLbkM6nSDSX2mrBwJxM54DnGOut164fHLf6vwHYI4YKs7fADvG2j8AlghIWkOll68KaxIgLm8AEUhB
  ; zRQSEE+AEaRVU7UC4wEwAcb2V22B6QUQIam5EsQnQAYxdP9HQSAXgBo6NVgHdQEYoFGDNTAUgB4MXoBqgL4ACBj4f36rQAoAoCYD
  ; HMABHMABHMABHMAB1GQO4AAO4AAO4AAP9up4N0EYiOP4a9yvIoJGZ9TRUi0xJM7o3v+dlu2PZTPAFbqDBfm8AM23d2UKMAWYAkwB
  ; pgD0lP4gQOnS+Et6NTSE8hR/uriSWgsP4DR+sBvqWxHjm3bUTnCAa44HcUG9SvFLfqU2AgOYOyo46o+xeGQN+QsLYDQq3eckhz9B
  ; XszIV1AAo1HjuJ5RLyyqZIX3DQQFsKh1PvRSIEW17H3n+f2QACfUy277OYnboM5q6zmDAQFMhgbHZC8+AyZHrbNngYAAJzS6JeJb
  ; cEG9PNruyENAAI1Gb2qxI1EFmiwjryXsHsCgmVaR8BLEzAV4jWD3ABswlOQI8AdYqWg7J1b3ACkYSxW9SI5AzF5AsiaWaADFXAEj
  ; dAK9dlAygOwOWDaA1w7IBnhdk5QSfAC1GDpAIhfgAoYeeYAMjOO4AzhwzuMOYMG5KaUGfwTFAhhwcvUffoNiARx8noDkMNoAH+za
  ; 62qDQBCG4dvY2YZtjMmY5lQNGmlAQ+//poot/b1fhMm4h/cGxEcY9uAVGgFnYBkSKAB5+7LWqu8FxAAe5A0dAYIAVg5gIF/l7wiI
  ; FsABMxBciEsCyO0FyNsWXQYJAxyMRDfy1k97QX0A7Bvg4TNwg87A+QBOD6DAAKrEAdanaAEcCGCAYgbYGSA5gFIV4Dt1AJsBFgGw
  ; 1wLAV2GiAKuPNyORI/BIGChIAPJWZgB9gFETYJwGkDLAVhQAeLg0wGXJAD388PkABAAcZQDA3fACACpNgCpagBo6FF+fogVg8mbh
  ; 3XDEADuDJAew0QTAtwLxArwnD4Ctg0QB1qfUAXYGLECAmx5AARwHyAPwkgHKDJAB7D5xgJU6gNUEwI8DMoAkwFkGwIUDcDBocQI8
  ; cTMWHsBjyQDjXIAwfhHyA2wzQNQADQRwjBeAIIAqAxgkMYBSE6BPHWCTAfQBRrFfhBj8TVIaQOV2/M7MLQhggEIAqJm7org61xAc
  ; fhgzH2DAbujnxzy9dkNzsi8AcFIXQ3duC+fov4QAau4K90lACMBZG8A+MYhrbgd3ITT0clgfAPgI3MGvjnf5W4OoA/ywd6fricJQ
  ; GIBvg7AIkggoCKXtiIqtS+f+r2mgtA9lXHIwPYYl3/95kvMmMA2GcHsWbvfT54SghHYAIL4xC4sZf2r88yECXOlDcZ8DzXhxgKBr
  ; AFvv6owfLEBg1fd48si8VH+FdgBgVcz4lDw8rAMAict24Bk/RACkwAFCBTBigM91iAJQAKMGcKKxA8y0EQPkYwfQHwEQk+7mIQCk
  ; w6meRYwbwLY0BTBaAKoAFIACCAYHEFO6Y4wdXDcD7hMdBgCl72ztuvqPuKMASChjVd2NmEW6AeARpBSVZ+7xrGzHWS7tIJiHoc9t
  ; etdTAPrC3M1Z4WXd89CPZrOFZVlGkSnhhPUOoCi9OejliH8XvqjKrpseFECyY4dNc8yrys8KbwkQYgPsiWBSytYXSi/GvKy8Lryr
  ; AFOR/9Hfs8b9/bv0atC1KoIAfjcByos9v1B69KP0gQKkZxe741TXej3hewVwajPj1+7/F3t1m/tZet8AJrAZn12c8RdKHxxAenHG
  ; X7/YBwdAW8743gEQCECLGT84gF1RvxMKzHgBgF0XAMpRCBaGhpBX/uzDB1gReacJehCAEBnAgwCECkDDiNeFJ0Lc6/BQXoeSABJE
  ; APg3diQCEAWgm9i/C0xA23TkAejSARA/MuR14dfhRCLAExdggw9AEA/REW/clQ+QIB2iAwfA3SKzJbjvjosDLHEBvG4DMPRdYh5k
  ; NRwMGOAVeLw9TlIIAOZeYfjPcziZQF6a8uUCZOViUBoARQd4Jpy40gFCVIAJBMCXBpB0AsCJpAEQ9NfmUtj5/kh5gwDgvjoL3LCO
  ; lCmkefkAS4kAG+TX559w10LiAO69AL1YCgABgP6DBVhKBwjQAPa/uRpqAvRiLaR50gGw10JwAPHl4GABTF82QCgRYIcMcCKcrMsO
  ; SASgdwP0YTEIBAiHC7DqBQDaariI9NPlJ7jfFxEHSMcOQJABYsLJsQMA931lpg/PQ2AA+ugBbEwAhA+sDA6g7eMABaAAegQQSwZI
  ; CScxMsAE1j5aJrK/N/jGW44jAcAfyaEAwNejGTLAlgewQflDCH4RHnEeCsMPNNWxP7T0h7NBo2ofLyveVnWEJ0LwIYjz+mR5rEw5
  ; tyD04/W38W3/8pcp1DxzBsDEPll6Fd94IFo9kELNU3K1/o2uI+wSAwus9TLBQsPO6Vb9Zoh+jpC2TS417+plloU/evaXhoDmn/XD
  ; B+B+AM34e9aD97yuHz8fL2f+mV7GtGfgDggAaMbHOiF1kiz/ar6qHz/WR9bowPqrA0GL+kUANGMxz13GKKWMHY66ftY8dowoyA/f
  ; Hcj1Ks68zRurIgBFLD9wzMZr8nZYN48fYxHaZqMDTuBbWosIAhQ9iALbMas4duAjlM/pgN/oQNSyA4IARQxrMfPD+Xz+eRYKQvmA
  ; DkQCHeAAwGJ8RZMVgfYbAKOMAlAACkABKAAFoAAUgAJQAApAG2UUgAL41269oEAMwgAQnUStutZ+6FK8/0m3WIp32HTICR4k5AV4
  ; AV6AaxSmZrAJtAN8wTWDOZg7QIXcDJahdoAIpRmsQOwACdTgDjiF1AHEQ2jmCuDlBliBTzPWB1g7wNUJejRTHQqnPADigWDoDrgA
  ; eBkAuwe0ZGfgI5pcLgr4fQBcLRhrkTtE7jaPofwmA+ApxTorf5/ONSaRAWA88wA/FYbIdxzaJjsAAAAASUVORK5CYII=
; )"

; nBytes := Base64Dec( Base64ImageData, Bin )

; File := FileOpen("ahkiconnew.png", "w")
; File.RawWrite(Bin, nBytes)
; File.Close()

; Gui, Add, Picture, w256 h256, ahkiconnew.png
; Gui, Show
; Return ;    // end of auto-execcute section //

Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
    Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
           , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
    VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
           , "Ptr",&Bin, "UIntP",Rqd:=0, "Int",0, "Int",0 )
    Return Rqd
}

DataDecode(InString) {
    return InString
}