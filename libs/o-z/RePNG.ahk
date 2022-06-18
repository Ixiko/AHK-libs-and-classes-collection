; Title:   	RePNG() : Dissolves data in to PNG image + Digital Matryoshka example
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=389663#p389663
; Author:	SKAN
; Date:   	23.03.2021
; for:     	AHK_L

/*
    RePNG( SourcePNG, DataFile, TargetPNG )
    This function accepts a GdiPlus supported image (Parameter 1) and dissolves a DataFile (Parameter 2) into the source image bits
    and exports the result as a PNG (Parameter 3)
    RePNG() returns false on error (ErrorLevel is set) or the CRC32 hash of Bitmap bits when successful.

    SourcePNG vs DataFile
    The DataFile contents are converted to Base64 before being dissolved into image pixels. Each Base64 char occupies 1 pixel.
    For eg. if your DataFile weighs 760 bytes, multiply it by 1.33333333 to derive 1014 pixels. Add 4 pixels overhead and you get 1018 pixels.
    A 32x32 image (1024 pixels) will be sufficient to to fit 760 bytes of original data.

    Usage Example:

    To encode, pass file names for all 3 parameters.
    Code: Select all - Toggle Line numbers

    RePNG("White.jpg", "Ring08.mp3", "White.png")

*/

/*
#NoEnv
#Warn
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1

If ! FileExist("Matryoshka_500x883.png")
  URLDownloadToFile, https://i.imgur.com/lavHeA5.png , Matryoshka_500x883.png

CRC32 := RePNG("Matryoshka_500x883.png")
If ( CRC32 != 0x5FA466CC )
  ExitApp

RePNG("Matryoshka_500x883.png", "Matryoshka_308x544.png")
RePNG("Matryoshka_308x544.png", "Matryoshka_180x318.png")
RePNG("Matryoshka_180x318.png", "Matryoshka_104x184.png")
RePNG("Matryoshka_104x184.png", "Matryoshka_070x124.png")

MsgBox Done!

*/

RePNG( SourcePNG, DataFile:="", TargetPNG:="" ) {                      ; RePNG v0.33 by SKAN on D43L/D43O @ tiny.cc/repng
Local
  hCrypt32 := Error := 0
  hGdiPlus := DllCall("kernel32.dll\LoadLibrary", "Str","GdiPlus.dll", "Ptr")
  VarSetCapacity(GdiplusStartupInput, 24, 0),          NumPut(1, GdiplusStartupInput, "Int")
  DllCall("gdiplus.dll\GdiplusStartup", "PtrP",pToken:=0, "Ptr",&GdiplusStartupInput, "Int",0)
  If DllCall("gdiplus.dll\GdipCreateBitmapFromFile", "WStr",SourcePNG, "PtrP",pBitmap:=0)
     GoTo, % ( "RePNG_Cleanup", Error:=1 )

  DllCall("gdiplus.dll\GdipGetImageWidth",  "Ptr",pBitmap, "UIntP", W:=0),      Stride := W*4
  DllCall("gdiplus.dll\GdipGetImageHeight", "Ptr",pBitmap, "UIntP", H:=0),      pSize  := Stride*H

  If ( TargetPNG != "" )
  If ( !( dSz := FileOpen(DataFile, "r").Length ) || ( (AvlPixels := W*H) < (RqdPixels := (Ceil((Dsz/3)*4)) + 4) ) )
       GoTo, % ("RePNG_Cleanup", Error:=( !Dsz ? 3 : 4) )
  DllCall("gdiplus.dll\GdipGetImagePixelFormat", "Ptr",pBitmap, "PtrP",PixelFormat:=0)
  If ( PixelFormat = (ARGB := 0x26200A) )
       GoTo, % ( "RePNG_LoadBits", Error:=0 )

; else create a new ARGB bitmap and draw image into it
  DllCall("gdiplus.dll\GdipCreateBitmapFromScan0", "Int",W, "Int",H, "Int",0, "Int",ARGB, "Ptr",0, "PtrP",pBitmap2:=0 )
  DllCall("gdiplus.dll\GdipGetImageGraphicsContext", "Ptr",pBitmap2, "PtrP",pGraphics:=0)
  DllCall("gdiplus.dll\GdipDrawImage", "Ptr",pGraphics, "Ptr",pBitmap, "Float",0, "Float",0)
  DllCall("gdiplus.dll\GdipDeleteGraphics", "Ptr",pGraphics)
  DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",pBitmap),      pBitmap2 := (pBitmap := pBitmap2) * 0

RePNG_LoadBits:
  VarSetCapacity(Bits, W*H*4, 0),                  VarSetCapacity(BitmapData, A_PtrSize=8 ? 32 : 24, 0)
  NumPut(pBits:=&Bits,BitmapData, 16, "Ptr"),      NumPut(Stride, BitmapData, 8, "Int")
  DllCall("gdiplus.dll\GdipBitmapLockBits", "Ptr",pBitmap, "Ptr",0, "Int",0x5, "Int",ARGB, "Ptr",&BitmapData)
  DllCall("gdiplus.dll\GdipBitmapUnlockBits", "Ptr",pBitmap, "Ptr",&BitmapData)
  pBitmap  := DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",pBitmap) * 0
  hCrypt32 := ( DataFile="" ? 0 : DllCall("kernel32.dll\LoadLibrary", "Str","Crypt32.dll", "Ptr") )
  GoTo, % ( DataFile="" ? "RePNG_Cleanup" : TargetPNG="" ? "RePNG_Decode" : "RePNG_Encode", Error:=0 )

RePNG_Encode:
  Encode :=      { 065: 0x000000, 066: 0x000001, 067: 0x000002, 068: 0x000003, 069: 0x000100, 070: 0x000101, 071: 0x000102
  , 072: 0x000103, 073: 0x000200, 074: 0x000201, 075: 0x000202, 076: 0x000203, 077: 0x000300, 078: 0x000301, 079: 0x000302
  , 080: 0x000303, 081: 0x010000, 082: 0x010001, 083: 0x010002, 084: 0x010003, 085: 0x010100, 086: 0x010101, 087: 0x010102
  , 088: 0x010103, 089: 0x010200, 090: 0x010201, 097: 0x010202, 098: 0x010203, 099: 0x010300, 100: 0x010301, 101: 0x010302
  , 102: 0x010303, 103: 0x020000, 104: 0x020001, 105: 0x020002, 106: 0x020003, 107: 0x020100, 108: 0x020101, 109: 0x020102
  , 110: 0x020103, 111: 0x020200, 112: 0x020201, 113: 0x020202, 114: 0x020203, 115: 0x020300, 116: 0x020301, 117: 0x020302
  , 118: 0x020303, 119: 0x030000, 120: 0x030001, 121: 0x030002, 122: 0x030003, 048: 0x030100, 049: 0x030101, 050: 0x030102
  , 051: 0x030103, 052: 0x030200, 053: 0x030201, 054: 0x030202, 055: 0x030203, 056: 0x030300, 057: 0x030301, 043: 0x030302
  , 047: 0x030303 }

  FileOpen(DataFile, "r").RawRead(Bin, dSz), Rqd:=0
  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",dSz, "UInt",0x1, "Ptr",0,   "UIntP",Rqd)
  VarSetCapacity(B64, Rqd*(A_Isunicode? 2:1), 0),
  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",dSz, "UInt",0x1, "Str",B64, "UIntP",Rqd)
  bSz := StrLen(B64 := RTrim(B64 := StrReplace(B64, "`r`n" ), "="))
  VarSetCapacity(VSz,4,0), NumPut(bSz, VSz, "Int"),  sSz:="////", Rqd:=7
  DllCall("Crypt32.dll\CryptBinaryToString", "Ptr",&vSz, "UInt",3,   "UInt",0x1, "Str",sSz, "UIntP",Rqd)

  Loop, Parse, % ( StrReplace(sSz, "`r`n"), pPtr:=pBits )
    pPtr := NumPut((NumGet(pPtr+0, "UInt") & ~0x030303) | Encode[ Asc(A_LoopField) ], pPtr+0, "Int")
  Loop, Parse, % B64
    pPtr := NumPut((NumGet(pPtr+0, "UInt") & ~0x030303) | Encode[ Asc(A_LoopField) ], pPtr+0, "Int")
                                                                 ; ImageCodecPNG  = {557CF406-1A04-11D3-9A73-0000F81EF32E}
  VarSetCapacity(V,16),  NumPut(0x2EF31EF8,NumPut(0x739A,NumPut(0x11D31A04,NumPut(0x557CF406,V,"Int"),"Int"),"Int"),"Int")
  DllCall("gdiplus.dll\GdipCreateBitmapFromScan0", "Int",W, "Int",H, "Int",Stride, "Int",ARGB, "Ptr",pBits,"PtrP",pBitmap)
  DllCall("gdiplus.dll\GdipSaveImageToFile", "Ptr",pBitmap, "WStr",TargetPNG, "Ptr",&V, "Int",0)
  DllCall("gdiplus.dll\GdipDisposeImage", "Ptr",pBitmap)
  GoTo, % ( "RePNG_Cleanup", Error:=0 )

RePNG_Decode:
  Decode:=       { 0x000000: "A", 0x000001: "B", 0x000002: "C", 0x000003: "D", 0x000100: "E", 0x000101: "F", 0x000102: "G"
  , 0x000103: "H", 0x000200: "I", 0x000201: "J", 0x000202: "K", 0x000203: "L", 0x000300: "M", 0x000301: "N", 0x000302: "O"
  , 0x000303: "P", 0x010000: "Q", 0x010001: "R", 0x010002: "S", 0x010003: "T", 0x010100: "U", 0x010101: "V", 0x010102: "W"
  , 0x010103: "X", 0x010200: "Y", 0x010201: "Z", 0x010202: "a", 0x010203: "b", 0x010300: "c", 0x010301: "d", 0x010302: "e"
  , 0x010303: "f", 0x020000: "g", 0x020001: "h", 0x020002: "i", 0x020003: "j", 0x020100: "k", 0x020101: "l", 0x020102: "m"
  , 0x020103: "n", 0x020200: "o", 0x020201: "p", 0x020202: "q", 0x020203: "r", 0x020300: "s", 0x020301: "t", 0x020302: "u"
  , 0x020303: "v", 0x030000: "w", 0x030001: "x", 0x030002: "y", 0x030003: "z", 0x030100: "0", 0x030101: "1", 0x030102: "2"
  , 0x030103: "3", 0x030200: "4", 0x030201: "5", 0x030202: "6", 0x030203: "7", 0x030300: "8", 0x030301: "9", 0x030302: "+"
  , 0x030303: "/" }

  Loop, % ( 4, sSz:="",  pPtr := pBits,  VarSetCapacity(VSz,4,0) )
    sSz .= Decode[ NumGet(pPtr+0, "UInt") & ~0xFFFCFCFC ], pPtr+=4
  DllCall("Crypt32.dll\CryptStringToBinary", "Str",sSz, "UInt",4, "UInt",0x1, "Ptr",&VSz, "UIntP",3, "Int",0, "Int",0)
  If ( (dSz := NumGet(VSz, "UInt")) < 1 || (dSz > (W*H-4)) )
    GoTo, % ( "RePNG_Cleanup", Error:=5 )

  Loop, % ( dSz,  pPtr := pBits+16,  VarSetCapacity(B64, (dSz+1) * (A_Isunicode ? 2 : 1)) )
    B64 .= Decode[ NumGet(pPtr+0, "UInt") & ~0xFFFCFCFC ], pPtr+=4

  Len := StrLen(B64), Rqd := 0
  DllCall("Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",Len, "UInt",0x1, "Ptr",0,    "UIntP",Rqd, "Int",0, "Int",0)
  VarSetCapacity(Bin, Rqd, 0)
  DllCall("Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",Len, "UInt",0x1, "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0)
  FileOpen(DataFile,"w").RawWrite(Bin, Rqd)

RePNG_Cleanup:
  pBitmap  := pBitmap ? DllCall("gdiplus\GdipDisposeImage", "Ptr",pBitmap)          * 0 : 0
  pToken   := DllCall("gdiplus.dll\GdiplusShutdown", "Ptr",pToken)                  * 0
  hGdiPlus := DllCall("kernel32.dll\FreeLibrary", "Ptr",hGdiPlus)                   * 0
  hCrypt32 := hCrypt32 ? DllCall("kernel32.dll\FreeLibrary", "Ptr",hCrypt32)        * 0 : 0
  CRC32    := Error ? 0  : DllCall("ntdll.dll\RtlComputeCrc32", "Int",0, "Ptr",pBits, "Int",pSize, "UInt")

Return ( CRC32 | ( (ErrorLevel := Error) * 0 ) )
}