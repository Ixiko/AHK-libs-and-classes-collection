/*  RePNG() v0.55 : Dissolves data in to PNG image / Digital Matryoshka example

    @
    02 Apr 2021, 01:23
    New version. Added an options parameter to accept a key.
    I had to rewrite it completely... and unusually, I have written it modular.

    RePNG() v0.55

    RePNG( SourcePNG, DataFile, TargetPNG, Options )
    This function accepts a GdiPlus supported image (Parameter 1) and dissolves a DataFile (Parameter 2) into the source image bits
    and exports the result as a PNG (Parameter 3)
    RePNG() returns false on error (ErrorLevel is set with a descriptive message) or the CRC32 hash of Bitmap bits when successful.

    SourcePNG vs DataFile
    The DataFile contents are converted to Base64 before being dissolved into image pixels. Each Base64 char occupies 1 pixel.
    For eg. if your DataFile weighs 760 bytes, multiply it by 1.33333333 to derive 1014 pixels. Add 4 pixels overhead and you get 1018 pixels.
    A 32x32 image (1024 pixels) will be sufficient to to fit 760 bytes of original data.

    Usage Example:

    To encode, pass file names for 3 parameters. (optionally a key word to protect contents, which in this example is SKAN.)
    Code: Select all - Collapse View - Download - Toggle Line numbers

    RePNG("blowfly.png", "furelise.mp3", "blowfly_mp3.png", "key:SKAN")
    Result:

    Image

    To decode, omit the 3rd parameter,. (But do provide the key in the options parameter)
    Save the above image as blowfly_mp3 into your script folder, and use the following code.
    Code: Select all - Expand View - Download - Toggle Line numbers

    RePNG("blowfly_mp3.png", "furelise.mp3",, "key:SKAN")


    If you only need the CRC32 hash, call the function with single/first parameter:
    Code: Select all - Collapse View - Download - Toggle Line numbers

    RePNG("blowfly_mp3.png")

    DIGITAL MATRYOSHKA
    If you stick to to the PNG format, you may re-encode multiple PNGs into one.
    The following image is a RePNG with 4 different sizes of the same image.
    Down deep, the 4th and the smallest image contains a text file.
    Some PNG optimizer of this forum doesn't prefer fully transparent pixels to contain RGB values, and so discards it.
    Unable to attach it, and so, I have hosted the following image in ImgUR.

    Image

    The following code will extract the 3 embedded PNG's from the main PNG and finally the text file from smallest image.



*/


/*
  #NoEnv
  #Warn
  #SingleInstance, Force
  SetWorkingDir, %A_ScriptDir%

  If ! FileExist("Matryoshka_400x400.png")
    URLDownloadToFile, https://i.imgur.com/S2QA7Cx.png , Matryoshka_400x400.png

  CRC32 := RePNG("Matryoshka_400x400.png")
  If ( CRC32 != 0xF5A0C31C )
    ExitApp

  RePNG("Matryoshka_400x400.png", "Matryoshka_240x240.png")
  RePNG("Matryoshka_240x240.png", "Matryoshka_140x140.png")
  RePNG("Matryoshka_140x140.png", "Matryoshka_100x100.png")
  RePNG("Matryoshka_100x100.png", "Message.txt")

  MsgBox Done!
*/


RePNG( SourcePNG, DataFile:="", TargetPNG:="", Options:="" )  {                   ;  RePNG v0.55.01 by SKAN on D43L/D442 @ tiny.cc/repng
Global A_Args
  A_Args.RePNG := {"Error":0, "hCrypt32":0, "hGdiPlus":0, "pToken":0, "pBitmap":0, "nBytes": 0, "CODE":{}}
  RA := A_Args.RePNG,   RA.BatchLines := A_BatchLines,   RA.Encode  := ( TargetPNG != "" ), RA.Options := Format(" {:} ",Options)
  SetBatchLines -1

  VarSetCapacity(File,520,0)
  DllCall("Kernel32.dll\GetFullPathName", "Str",SourcePNG, "Int",260, "Str",File, "Ptr",0),    RA.Source   := File
  DllCall("Kernel32.dll\GetFullPathName", "Str",DataFile,  "Int",260, "Str",File, "Ptr",0),    RA.DataFile := File
  DllCall("Kernel32.dll\GetFullPathName", "Str",TargetPNG, "Int",260, "Str",File, "Ptr",0),    RA.Target   := File

  If RePNG_ParseOptions(RA)
     Return RePNG_Cleanup(RA)

  If RePNG_GdiPlusStartup(RA)
     Return RePNG_Cleanup(RA)

  If RePNG_LoadBitmap(RA)
     Return RePNG_Cleanup(RA)

  If ( RA.Encode )
  If RePNG_MeasurePixels(RA)
     Return RePNG_Cleanup(RA)

  RePNG_ConvertToARGB(RA)
  RePNG_LoadBits(RA, Bits:="")

  If ( DataFile = "" )
     Return RePNG_Cleanup(RA)

  RA.hCrypt32 := DllCall("Kernel32.dll\LoadLibrary", "Str","Crypt32.dll", "Ptr")
  RA.Encode := RA.Encode ? RePNG_Encode(RA) : RePNG_Decode(RA)

Return RePNG_Cleanup(RA)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_ParseOptions(RA) {
Local
  ChkStr := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  If ( BaseStr := RePNG_xStr(RA.Options,," Base64:",A_Space) )
  If ( DllCall("Shlwapi.dll\StrSpn", "Str",BaseStr, "Str",ChkStr, "UInt") != 64 )
       Return ( RA.Error := Format("{:}`n`nBase64:`n{:}", "User defined Base64 string is invalid.", BaseStr) )

  BaseStr := BaseStr ? BaseStr : ChkStr,    ChkStr := RTrim(ChkStr, "+/")
  If ( RA.Encode )
       Loop, Parse, BaseStr
           n := A_Index-1,    RA.CODE[ Asc(A_LoopField) ] := ( (n & 3) | ((n>>2) & 3)<<8 | ((n>>4) & 3)<<16 )
  Else Loop, Parse, BaseStr
           n := A_Index-1,    n := ( (n & 3) | ((n>>2) & 3)<<8 | ((n>>4) & 3)<<16 ),    RA.CODE[n] := A_LoopField

  If InStr(RA.Options, " Key:")
  If ( (RA.Key := RePNG_xStr(RA.Options,," Key:", A_Space)) = "" )
     Return ( RA.Error := Format("{:}`n`n{:}`n", "Key pair incorrect.", RePNG_xStr(RA.Options,," Key:",,,,,,1) ))
  Else If ( DllCall("Shlwapi.dll\StrSpn", "Str",RA.Key, "Str",ChkStr, "UInt") != StrLen(RA.Key) )
     Return ( RA.Error := Format("{:}`n`nKey:`n{:}`n", "Invalid character(s) in Key", RA.Key) )

  RA.RNG := ! InStr(RA.Options, " -R", A_Space)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_GdiPlusStartup(RA) {
Local
  hGdiPlus := DllCall("Kernel32.dll\LoadLibrary", "Str","GdiPlus.dll", "Ptr")
  VarSetCapacity(GdiplusStartupInput, 24, 0),           NumPut(1, GdiplusStartupInput, "Int")
  If ( E := DllCall("gdiplus.dll\GdiplusStartup", "PtrP",pToken:=0, "Ptr",&GdiplusStartupInput, "Int",0) )
       Return ( RA.Error := Format("{:}`n{:}{:}", "Unable to acquire a GdiPlus token", "GdiPlus Error: ", E) )
  RA.hGdiPlus := hGdiPlus,  RA.pToken := pToken
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_LoadBitmap(RA) {
Local
  If ! FileExist(RA.Source)
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File not found.", "Source image:", RA.Source) )

  If ! FileOpen(RA.Source, "r -r").__Handle
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File in use (in a different process)", "Source image:", RA.Source) )

  If ( E := DllCall("gdiplus.dll\GdipCreateBitmapFromFile", "WStr",RA.Source, "PtrP",pBitmap:=0) )
       Return ( RA.Error := Format("{:}`n{:}   {:}`n`nSource image:`n{:}", "Unable to load image.", "GdiPlus Error: ", E, RA.Source ) )

  DllCall("gdiplus.dll\GdipGetImageWidth",  "Ptr",pBitmap, "UIntP",W:=0),      RA.W := W,      RA.pBitmap := pBitmap
  DllCall("gdiplus.dll\GdipGetImageHeight", "Ptr",pBitmap, "UIntP",H:=0),      RA.H := H,      RA.nBytes  := W*H*4
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_MeasurePixels(RA) {
Local
  If ! FileExist(RA.DataFile)
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File not found.", "Data file:", RA.DataFile) )

  If ! FileOpen(RA.DataFile, "r -r").__Handle
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File in use (in a different process)", "Data file:", RA.DataFile) )

  If ! ( RA.DataSize := FileOpen(RA.DataFile, "r").Length )
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File has zero bytes.", "Data file:", RA.DataFile) )

  Dim := Format("{:}x{:}", RA.W, RA.H), New := RePNG_Calc(Dim, RA.DataSize), Rqd := ErrorLevel, Avl := (RA.W * RA.H)
  If ! Rqd
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}`n`n{:} bytes", "File too large.", "Data file:", RA.DataFile, RA.DataSize) )

  If (Rqd > Avl)
     Return ( RA.Error := Format("{:}`n`n{:}`n{:}`n`n{:} {:}`n{:} {:}`n`n{:} {:} bytes`n{:}"
        , "Image too small.", "Source image:", RA.Source, "Currently:", Dim, "Required:", New, "Data file:", RA.DataSize, RA.DataFile) )
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_ConvertToARGB(RA) { ; ARGB := 0x26200A
Local
  DllCall("gdiplus.dll\GdipGetImagePixelFormat", "Ptr",RA.pBitmap, "PtrP",PixelFormat:=0)
  If ( PixelFormat = 0x26200A )
       Return
  DllCall("gdiplus.dll\GdipCreateBitmapFromScan0", "Int",RA.W, "Int",RA.H, "Int",0, "Int",0x26200A, "Ptr",0,  "PtrP",pBitmap:=0)
  DllCall("gdiplus.dll\GdipGetImageGraphicsContext", "Ptr",pBitmap, "PtrP",pGraphics:=0)
  DllCall("gdiplus.dll\GdipDrawImageRect", "Ptr",pGraphics, "Ptr",RA.pBitmap, "Float",0, "Float",0, "Float",RA.W, "Float",RA.H)
  DllCall("gdiplus.dll\GdipDeleteGraphics", "Ptr",pGraphics)
  DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",RA.pBitmap),      RA.pBitmap := pBitmap
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_LoadBits(RA, ByRef Bits) { ; ARGB := 0x26200A
Local
  VarSetCapacity(Bits, RA.pSize := (RA.W * RA.H * 4), 0),      sSize := A_PtrSize=8 ? 32 : 24,      VarSetCapacity(BitmapData, sSize, 0)
  NumPut(&Bits, BitmapData, 16, "Ptr"),      NumPut(Stride := (RA.W * 4), BitmapData, 8, "Int"),
  DllCall("gdiplus.dll\GdipBitmapLockBits", "Ptr",RA.pBitmap, "Ptr",0, "Int",0x5, "Int",0x26200A, "Ptr",&BitmapData)
  DllCall("gdiplus.dll\GdipBitmapUnlockBits", "Ptr",RA.pBitmap, "Ptr",&BitmapData)
  DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",RA.pBitmap),    RA.pBitmap := 0,    RA.pBits := &Bits
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_Encode(RA) {
Local
  If ( FileExist(RA.Target) && !FileOpen(RA.Target, "r -r").__Handle )
       Return ( RA.Error := Format("{:}`n`n{:}`n{:}", "File in use (in a different process)", "Target PNG:", RA.Target) )

  DataSize := RA.DataSize,       CODE := RA.CODE,         pBits := RA.pBits,    pSize := RA.pSize
  VarSetCapacity(Bin,128),               VarSetCapacity(Bin,0),   VarSetCapacity(Bin, (n:=DataSize+16)-Mod(n,16), 0)
  File := FileOpen(RA.DataFile, "r"),    File.Pos := 0,           File.RawRead(&Bin, DataSize), File.Close(),    Rqd:=0

  If ( RA.Key )
       RePNG_Crypt("Encrypt", Bin, DataSize, RA.Key)

  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",DataSize, "UInt",0x1, "Ptr",0, "UIntP",Rqd)
  VarSetCapacity(Base64, Rqd*(A_Isunicode? 2:1), 0)
  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",DataSize, "UInt",0x1, "Str",Base64, "UIntP",Rqd)
  Base64 := RTrim( StrReplace(Base64, "`r`n" ), "=")

  Loop % (4, pPtr := pBits, n := StrLen(Base64))                        ; Write data length
        pPtr := NumPut((NumGet(pPtr+0,"UInt") & ~0x030303) | (n&3 | ((n>>2)&3)<<8 | ((n>>4)&3)<<16),pPtr+0,"Int"), n>>=6

  Loop, Parse, % Base64                                                  ; Write data
        pPtr := NumPut((NumGet(pPtr+0,"UInt") & ~0x030303) | Code[ Asc(A_LoopField) ], pPtr+0, "Int")

  RA.nBytes := pPtr - pBits
  If ( RA.RNG )                                                          ; Fill random data on unsed pixels
  {
      rSz := pSize-(pPtr-pBits),   VarSetCapacity(Bin, rSz)
      DllCall("Advapi32.dll\SystemFunction036", "Ptr",&Bin, "UInt",rSz)
      Loop % ( rsz//4, pBin:=&Bin )
         n    := NumGet(pBin+0, "UInt"),   pBin+=4,   n := ( n&3 | ((n>>8)&3)<<8  | ((n>>16)&3)<<16 )
       , pPtr := NumPut((NumGet(pPtr+0,"UInt") & ~0x030303) | n, pPtr+0, "Int")
  }

  If ( RePNG_SavePNG(RA) )
       Return ( RA.Error := Format("{:}`n`nTarget PNG:`n{:}", "File write error!", RA.Target ))
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_SavePNG(RA) { ; ARGB := 0x26200A
Local
  VarSetCapacity(ImageCodecPNG, 16), RA.pBits, Stride := RA.W * 4, pBitmap := 0
  DllCall("ole32.dll\CLSIDFromString", "Str","{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr",&ImageCodecPNG)
  DllCall("gdiplus.dll\GdipCreateBitmapFromScan0", "Int",RA.W, "Int",RA.H, "Int",Stride, "Int",0x26200A, "Ptr",RA.pBits, "PtrP",pBitmap)
  DllCall("gdiplus.dll\GdipSaveImageToFile", "Ptr",pBitmap, "WStr",RA.Target, "Ptr",&ImageCodecPNG, "Int",0)
  DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",pBitmap)
Return ! FileExist(RA.Target)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_Decode(RA) {
Local
  CODE := RA.CODE,    pBits := RA.pBits,    pSize := RA.pSize

  Loop % (4, pPtr:=pBits, n:=0)                                       ; Read data length
    r := NumGet(pPtr+0,"UInt") & ~0xFFFCFCFC, n |= ( (((r>>16)&3)<<4 | ((r>>8)&3)<<2 | r&3) << (A_Index-1)*6 ),    pPtr+=4

  If ( n < 1 || n > (RA.W * RA.H - 4) )
       Return ( RA.Error := Format("{:}`n`nSource file: Data length = {:}`n{:}", "Invalid data length!", n, RA.Source ) )

  VarSetCapacity(Base64, (A_Isunicode ? 2 : 1) * (n+1))
  Loop, % ( n )                                                       ; Read data
    Base64 .= CODE[ NumGet(pPtr+0, "UInt") & ~0xFFFCFCFC ],  pPtr+=4

  RA.nBytes := pPtr-pBits,  n := StrLen(Base64),  Rqd := Floor(n*3/4), VarSetCapacity(Bin, Rqd)
  DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64, "UInt",n, "UInt",0x1, "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0)

  If ( RA.Key && (RA.Error := RePNG_Crypt("Decrypt", Bin, Rqd, RA.Key)) )
       Return RA.Error := Format("{:}{:} 0x{:08X}`n`n{:}`n{:}", RA.Encode ? "En" : "De", "cryption failed.`nBCrypt error:"
            , RA.Error, "Source PNG:", RA.Source)

  If ( FileOpen(RA.DataFile,"w").RawWrite(Bin, Rqd) < Rqd )
       Return ( RA.Error := Format("{:}`n`nData file:`n{:}", "File write error!", RA.DataFile ))
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_Cleanup(RA) {
Local
  If !(RA.hGdiPlus)
     Return Format("0x{:08X}", 0, ErrorLevel:=RA.Error, RA:="")

  If ( RA.pBitmap )
       DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",RA.pBitmap)
  DllCall("gdiplus.dll\GdiplusShutdown", "Ptr",RA.pToken)
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",RA.hGdiPlus)
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",RA.hCrypt32)
  SetBatchLines % RA.BatchLines
  nCRC32 := RA.Error ? 0 : DllCall("ntdll.dll\RtlComputeCrc32", "Int",0, "Ptr",RA.pBits, "Int",RA.nBytes, "UInt")
Return Format("0x{:08X}", nCRC32, ErrorLevel:=RA.Error, RA:="")
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_Crypt( Mode, ByRef Src, ByRef sBytes, sKey ) {
Local
  tbytes  := ( Mode="Encrypt" ? (tbytes:=sBytes+16) - Mod(tBytes,16) : sBytes )
  hKey    := hHash := hAlg := VarSetCapacity(Hash,48,0) * 0
  hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr")

  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","SHA256", "Ptr", 0, "Int",0)
  DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash, "Ptr",0, "Int",0, "Ptr",0, "Int",0, "Int",0)
  DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "AStr",sKey, "Int",StrLen(sKey), "Int",0)
  DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",&Hash, "Int",32, "Int",0)
  DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
  DllCall("Shlwapi.dll\HashData", "Ptr",&Hash, "Int",32, "Ptr",&Hash+32, "Int",16)

  DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg, "WStr","AES", "Ptr",0, "Int",0)
  DllCall("Bcrypt.dll\BCryptSetProperty", "Ptr",hAlg, "WStr","ChainingMode", "WStr","ChainingModeCBC", "Int",15, "Int",0)
  DllCall("Bcrypt.dll\BCryptGenerateSymmetricKey", "Ptr",hAlg, "PtrP",hKey, "Ptr",0, "Int",0, "Ptr",&Hash, "Int",32, "Int",0, "UInt")
  E := DllCall("Bcrypt.dll\BCrypt" . (  Mode := Mode="Encrypt" ? "Encrypt" : "Decrypt"  ), "Ptr",hKey, "Ptr",&Src, "Int",sBytes, "Ptr",0
              ,"Ptr",&Hash+32, "Int",16, "Ptr",&Src, "Int",tBytes, "UIntP",tBytes, "Int",1, "UInt")
  DllCall("Bcrypt.dll\BCryptDestroyKey", "Ptr",hKey)
  DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int", 0)
  DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)
Return Format("0x{:08X}", E, sBytes := tBytes)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_Calc( Dim, nBytes:=0 ) {    ; Max image dimension = 4098x4094 (best fit). Max data bytes = 12582912
Local
  D := StrSplit(Dim, ["x","X",":"]),      W := Round(D[1], 7),    H := Round(D[2], 7),    Pixels := W * H

  If ! ( nBytes := Round(nBytes) )
  {
      If ( Pixels > 16777215 || InStr(Dim, ":") )                 ; 16.7 Mega pixels
          Return 0
      Pixels := (W * H - 4),    BaseChars := (Pixels//4 * 3),    nBytes := BaseChars - Mod(BaseChars, 16)
      Return Round( Min(nBytes, 12582912) - 1 )
  }

  If (  (nBytes := (nBytes+=16) - Mod(nBytes, 16)) > 12582912  )  ; 12 Mega bytes
      Return 0

  Avl    := ( W * H ),                            Rqd    := Ceil( nBytes/3 * 4) + 4
  Scale  := Round(Sqrt(Rqd) / Sqrt(Avl), 10),     NW     := Round(W * Scale)
  Aspect := Round(H / W, 10),                     NH     := Round(NW * Aspect)

  If ( (NW * NH) <  Rqd )
    NW += 1, NH +=1
Return ( (ErrorLevel := NW * NH) > 16777215 ? 0x0 : NW . "x" . NH )
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RePNG_xStr(ByRef H, C:=0, B:="", E:="",ByRef BO:=1, EO:="", BI:=1, EI:=1, BT:="", ET:="") {
Local L, LB, LE, P1, P2, Q, N:="", F:=0                 ; xStr v0.97 by SKAN on D1AL/D343 @ tiny.cc/xstr
Return SubStr(H,!(ErrorLevel:=!((P1:=(L:=StrLen(H))?(LB:=StrLen(B))?(F:=InStr(H,B,C&1,BO,BI))?F+(BT=N?LB
:BT):0:(Q:=(BO=1&&BT>0?BT+1:BO>0?BO:L+BO))>1?Q:1:0)&&(P2:=P1?(LE:=StrLen(E))?(F:=InStr(H,E,C>>1,EO=N?(F
?F+LB:P1):EO,EI))?F+LE-(ET=N?LE:ET):0:EO=N?(ET>0?L-ET+1:L+1):P1+EO:0)>=P1))?P1:L+1,(BO:=Min(P2,L+1))-P1)
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
