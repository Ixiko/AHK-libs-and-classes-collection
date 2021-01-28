/*
b := FileOpen(A_ScriptDir "\B64.txt", "r", "CP1252").Read()
b := RegExReplace(b, "\=+\s", "##")
c := RegExReplace(b, "##", "")
;~ e := FileOpen(A_ScriptDir "\enkotet.txt", "w", "UTF-8")
;~ For i, enc in StrSplit)b, "##")
		;~ e.WriteLine(Base64Dec


DecodeBase64(c, A_ScriptDir "\bild.bmp")


ExitApp
*/









DecodeBase64(ByRef base64Data, fileName := "") { ; Modified from the generated file of ImageToInclude.ahk (by just me)
		static hBitmap := 0
		VarSetCapacity(B64, StrLen(base64Data) << !!A_IsUnicode)
		B64 := base64Data
		If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
			Return False
		VarSetCapacity(Dec, DecLen, 0)
		If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
			Return False

		If fileName is not space
			Return FileOpen(fileName, "w").RawWrite(&Dec, DecLen)

		; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
		; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
		hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
		pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
		DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
		DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
		DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
		hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
		VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
		DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
		DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
		DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
		DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
		DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
		DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
		DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
		Return hBitmap
	}

Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
; from https://autohotkey.com/boards/viewtopic.php?t=35964
Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
  DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
  VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
  DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
         , "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
Return Rqd
}