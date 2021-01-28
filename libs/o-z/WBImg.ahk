; WBImg v1.00 (2015-11-28)

/*
	Description: Get WebBrowser image without redownloading.
	Limitations: * Require IE9+
	             * Cross-Origin image is not supported
	---------------------------------------------
	Methods:
		ToBase64Url(ByRef base64Url, imgEle, mimeType := "", jpegQuality := "")
		ToHBitmap(imgEle, mimeType := "", jpegQuality := "")
		ToFile(fileName, imgEle, mimeType := "", jpegQuality := "")
	Parameters:
		imgEle      - WebBrowser's image element
		mimeType    - (Optional) Valid values are image/png or image/jpeg. The type image/gif isn't supported.
		jpegQuality - (Optional) The quality level of a JPEG image in the range of 0.0 to 1.0.
	---------------------------------------------
	Examples:
		img := wb.document.getElementById("imgVerifycode")
		WBImg.ToFile("vcode.png", img)
		WBImg.ToBase64Url(base64URL, img)
		hBitmap := WBImg.ToHBitmap(img)
*/

Class WBImg {

	ToBase64Url(ByRef base64Url, imgEle, mimeType := "", jpegQuality := "") {
		cnv := imgEle.ownerDocument.createElement("CANVAS")
		cnv.width  := imgEle.naturalWidth
		cnv.height := imgEle.naturalHeight
		ctx := cnv.getContext("2d")
		ctx.drawImage(imgEle, 0, 0)
		base64Url := cnv.toDataURL(mimeType, jpegQuality)
	}

	ToHBitmap(imgEle, mimeType := "", jpegQuality := "") {
		this.ToBase64Url(base64Url, imgEle, mimeType, jpegQuality)
		base64Url := RegExReplace(base64Url, ".*?,")
		Return this.DecodeBase64(base64Url)
	}

	ToFile(fileName, imgEle, mimeType := "", jpegQuality := "") {
		this.ToBase64Url(base64Url, imgEle, mimeType, jpegQuality)
		base64Url := RegExReplace(base64Url, ".*?,")
		Return this.DecodeBase64(base64Url, fileName)
	}

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

}