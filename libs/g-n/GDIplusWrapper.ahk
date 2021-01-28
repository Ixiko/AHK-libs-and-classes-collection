/*
GDIplusWrapper.ahk

Wrappers around some useful GDI+ functions.

// by Philippe Lhoste <PhiLho(a)GMX.net> http://Phi.Lho.free.fr
// File/Project history:
 1.05.000 -- 2007/05/24 (PL) -- Added GDIplus_CloneBitmapArea, thanks to Paulo.
 1.04.000 -- 2007/03/26 (PL) -- Added GDIplus_DisposeImage and GDIplus_GetImageDimension.
 1.03.000 -- 2006/09/15 (PL) -- Added GDIplus_CaptureScreenRectangle.
 1.02.000 -- 2006/08/22 (PL) -- Added GDIplus_LoadBitmapFromClipboard.
 1.01.000 -- 2006/08/21 (PL) -- Some fixes, support of more parameters.
 1.00.000 -- 2006/08/18 (PL) -- Initial code.
*/
/* Copyright notice: See the PhiLhoSoftLicence.txt file for details.
This file is distributed under the zlib/libpng license.
copyright (c) 2007 Philippe Lhoste / PhiLhoSoft
*/

#Include DllCallStruct.ahk

; GDI+ constants

; GpStatus enumeration
; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/gdicpp/GDIPlus/GDIPlusreference/enumerations/status.asp
#GDIplusOK = 0
#GpStatus@0 = OK
#GpStatus@1 = GenericError
#GpStatus@2 = InvalidParameter
#GpStatus@3 = OutOfMemory
#GpStatus@4 = ObjectBusy
#GpStatus@5 = InsufficientBuffer
#GpStatus@6 = NotImplemented
#GpStatus@7 = Win32Error
#GpStatus@8 = WrongState
#GpStatus@9 = Aborted
#GpStatus@10 = FileNotFound
#GpStatus@11 = ValueOverflow
#GpStatus@12 = AccessDenied
#GpStatus@13 = UnknownImageFormat
#GpStatus@14 = FontFamilyNotFound
#GpStatus@15 = FontStyleNotFound
#GpStatus@16 = NotTrueTypeFont
#GpStatus@17 = UnsupportedGdiplusVersion
#GpStatus@18 = GdiplusNotInitialized
#GpStatus@19 = PropertyNotFound
#GpStatus@20 = PropertyNotSupported

#sizeOfCLSID = 16

; EncoderValueCompressionLZW, ...CCITT3, ...CCITT4, ...Rle, ...None for TIFF
#EncoderCompression = {E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}
; 1, 4, 8, 24, 32 -- The image must be in the right format before saving
#EncoderColorDepth = {66087055-AD66-4C7C-9A18-38A2310B8337}
#EncoderScanMethod = {3A4E2661-3109-4E56-8536-42C156E7DCFA}
#EncoderVersion = {24D18C76-814A-41A4-BF53-1C219CCCF797}
#EncoderRenderMethod = {6D42C53A-229A-4825-8BB7-5C99E2B9A8B8}
; 0 to 100 (JPeg)
#EncoderQuality = {1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}
#EncoderTransformation = {8D0EB2D1-A58E-4EA8-AA14-108074B7B6F9}
#EncoderLuminanceTable = {EDB33BCE-0266-4A77-B904-27216099E717}
#EncoderChrominanceTable = {F2E455DC-09B3-4316-8260-676ADA32481C}
; EncoderValueMultiFrame (TIFF)
#EncoderSaveFlag = {292266FC-AC40-47BF-8CFC-A85B89A655DE}

#FrameDimensionTime = {6AEDBD6D-3FB5-418A-83A6-7F45229DC872}
#FrameDimensionResolution = {84236F7B-3BD3-428F-8DAB-4EA1439CA315}
#FrameDimensionPage   = {7462DC86-6180-4C7E-8E3F-EE7333A7A483}

#FormatIDImageInformation = {E5836CBE-5EEF-0F1D-ACDE-AE4C43B608CE}
#FormatIDJpegAppHeaders  = {1C4AFDCD-6177-43CF-ABC7-5F51AF39EE85}

#CodecIImageBytes  = {025D1823-6C7D-447B-BBDB-A3CBC3DFA2FC}

; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/gdicpp/GDIPlus/usingGDIPlus/usingimageencodersanddecoders/determiningtheparameterssupportedbyanencoder/listingparametersandvaluesforallencoders.asp
; Specifies that the parameter is an 8-bit unsigned integer.
#EncoderParameterValueTypeByte = 1
; Specifies that the parameter is a null-terminated character string.
#EncoderParameterValueTypeASCII = 2
; Specifies that the parameter is a 16-bit unsigned integer.
#EncoderParameterValueTypeShort = 3
; Specifies that the parameter is a 32-bit unsigned integer.
#EncoderParameterValueTypeLong = 4
; Specifies that the parameter is an array of two, 32-bit unsigned integers.
; The pair of integers represents a fraction.
; The first integer in the pair is the numerator, and the second integer in the pair is the denominator.
#EncoderParameterValueTypeRational = 5
; Specifies that the parameter is an array of two, 32-bit unsigned integers.
; The pair of integers represents a range of numbers.
; The first integer is the smallest number in the range, and the second integer is the largest number in the range.
#EncoderParameterValueTypeLongRange = 6
; Specifies that the parameter is an array of bytes that can hold values of any type.
#EncoderParameterValueTypeUndefined = 7
; Specifies that the parameter is an array of four, 32-bit unsigned integers.
; The first two integers represent one fraction, and the second two integers represent a second fraction.
; The two fractions represent a range of rational numbers.
; The first fraction is the smallest rational number in the range, and the second fraction is the largest rational number in the range.
#EncoderParameterValueTypeRationalRange = 8
; Specifies that the parameter is a pointer to a block of custom metadata.
#EncoderParameterValueTypePointer = 9

#sizeOfEncoderParameter := 16 + 3 * 4

#GDIplus_mimeType_BMP = image/bmp
#GDIplus_mimeType_JPG = image/jpeg
#GDIplus_mimeType_GIF = image/gif
#GDIplus_mimeType_PNG = image/png
#GDIplus_mimeType_TIF = image/tiff

; Not used in GDI+ version 1.0.
#EncoderValueColorTypeCMYK = 0
; Not used in GDI+ version 1.0.
#EncoderValueColorTypeYCCK = 1
; For a TIFF image, specifies the LZW compression method.
#EncoderValueCompressionLZW = 2
; For a TIFF image, specifies the CCITT3 compression method.
#EncoderValueCompressionCCITT3 = 3
; For a TIFF image, specifies the CCITT4 compression method.
#EncoderValueCompressionCCITT4 = 4
; For a TIFF image, specifies the RLE compression method.
#EncoderValueCompressionRle = 5
; For a TIFF image, specifies no compression.
#EncoderValueCompressionNone = 6
; Not used in GDI+ version 1.0.
#EncoderValueScanMethodInterlaced = 7
; Not used in GDI+ version 1.0.
#EncoderValueScanMethodNonInterlaced = 8
; Not used in GDI+ version 1.0.
#EncoderValueVersionGif87 = 9
; Not used in GDI+ version 1.0.
#EncoderValueVersionGif89 = 10
; Not used in GDI+ version 1.0.
#EncoderValueRenderProgressive = 11
; Not used in GDI+ version 1.0.
#EncoderValueRenderNonProgressive = 12
; For a JPEG image, specifies lossless 90-degree clockwise rotation.
#EncoderValueTransformRotate90 = 13
; For a JPEG image, specifies lossless 180-degree rotation.
#EncoderValueTransformRotate180 = 14
; For a JPEG image, specifies lossless 270-degree clockwise rotation.
#EncoderValueTransformRotate270 = 15
; For a JPEG image, specifies a lossless horizontal flip.
#EncoderValueTransformFlipHorizontal = 16
; For a JPEG image, specifies a lossless vertical flip.
#EncoderValueTransformFlipVertical = 17
; Specifies multiple-frame encoding.
#EncoderValueMultiFrame = 18
; Specifies the last frame of a multiple-frame image.
#EncoderValueLastFrame = 19
; Specifies that the encoder object is to be closed.
#EncoderValueFlush = 20
; Not used in GDI+ version 1.0.
#EncoderValueFrameDimensionTime = 21
; Not used in GDI+ version 1.0.
#EncoderValueFrameDimensionResolution = 22
; For a TIFF image, specifies the page frame dimension.
#EncoderValueFrameDimensionPage = 23

#GDIplus_lastError = 0

#hGDIplusDLL = 0
#GDIplus_token = 0

; Initialize GDI+ library
GDIplus_Start()
{
	local r, structGdiplusStartupInput

	#GDIplus_lastError =
	; Note: LoadLibrary *must* be called, otherwise on each call of the GDIplus
	; functions, AutoHotkey will free the DLL, and we loose the token, crashing AHK!
	#hGDIplusDLL := DllCall("LoadLibrary", "Str", "GDIplus.dll")
	If (#hGDIplusDLL = 0)
	{
		MsgBox 16, GDIplus Wrapper, You need the GDIplus.dll in your path!
		Exit
	}

	/*
	struct GdiplusStartupInput
	{
		UINT32 GdiplusVersion;	// Must be 1
		DebugEventProc DebugEventCallback;	// NULL
		BOOL SuppressBackgroundThread;	// FALSE
		BOOL SuppressExternalCodecs;	// Ignored...
	}
	http://msdn.microsoft.com/library/default.asp?url=/library/en-us/gdicpp/GDIPlus/GDIPlusreference/functions/gdiplusstartup.asp
	*/
	VarSetCapacity(structGdiplusStartupInput, 4 * 4, 0)
	SetInteger(structGdiplusStartupInput, 1)    ; Version
	r := DllCall("GDIplus.dll\GdiplusStartup"
			, "UInt *", #GDIplus_token
			, "UInt", &structGdiplusStartupInput
			, "UInt", 0)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdiplusStartup (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	Return r
}

; Close GDI+ library
GDIplus_Stop()
{
	#GDIplus_lastError =
	DllCall("GDIplus.dll\GdiplusShutdown"
			, "UInt", #GDIplus_token)
	DllCall("FreeLibrary", "UInt", #hGDIplusDLL)
	#hGDIplusDLL := 0
}

; Load a bitmap from a file
GDIplus_LoadBitmap(ByRef @bitmap, _fileName)
{
	local r, ufn

	#GDIplus_lastError =
	GetUnicodeString(ufn, _fileName)
	r := DllCall("GDIplus.dll\GdipCreateBitmapFromFile"
			, "UInt", &ufn
			, "UInt *", @bitmap)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipCreateBitmapFromFile (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	Return r
}

; Load an image (bitmap or vector) from a file
GDIplus_LoadImage(ByRef @image, _fileName)
{
	local r, ufn

	#GDIplus_lastError =
	GetUnicodeString(ufn, _fileName)
	r := DllCall("GDIplus.dll\GdipLoadImageFromFile"
			, "UInt", &ufn
			, "UInt *", @image)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipLoadImageFromFile (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	Return r
}

; Load a bitmap from the clipboard
GDIplus_LoadBitmapFromClipboard(ByRef @bitmap)
{
	local r, result, handle

	#GDIplus_lastError =
	result := 0

	r := DllCall("OpenClipboard", "UInt", 0)
	If (r = 0)
	{
		#GDIplus_lastError := "OpenClipboard (" . A_LastError . ") " . ErrorLevel
		result := -1
		Goto LoadBitmapFromClipboard_CleanUp
	}
	handle := DllCall("GetClipboardData"
			, "UInt", 2)	; CF_BITMAP = 2, CF_DIB = 8
	If (r = 0)
	{
		#GDIplus_lastError := "GetClipboardData (" . A_LastError . ") " . ErrorLevel
		result := -1
		Goto LoadBitmapFromClipboard_CleanUp
	}
	If (handle = 0)
	{
		#GDIplus_lastError := "GDIplus_LoadBitmapFromClipboard: No image in clipboard"
		result := -1
		Goto LoadBitmapFromClipboard_CleanUp
	}

	r := DllCall("GDIplus.dll\GdipCreateBitmapFromHBITMAP"
			, "UInt", handle
			, "UInt", 0
			, "UInt *", @bitmap)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipCreateBitmapFromHBITMAP (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel . " " . A_LastError
		result := r
		Goto LoadBitmapFromClipboard_CleanUp
	}

LoadBitmapFromClipboard_CleanUp:
	DllCall("CloseClipboard")

	Return result
}

; Capture a portion of screen.
; By default, relative to whole screen.
; Can be relative to a window: you have to provide its hwnd,
; which can be get with WinGet hwnd, ID, WinTitle
; _bWholeWindow: if false, capture relative to client area,
; otherwise, capture relative to whole window, including title and borders.
; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/gdi/bitmaps_5a5h.asp
GDIplus_CaptureScreenRectangle(ByRef @bitmap
		, _x=0, _y=0
		, _w=0, _h=0
		, _hwndWindow=0, _bWholeWindow=false)
{
	local result, bRes, r, hOld
	local hdcWindow, hdcBuffer, hbmpBuffer

	#GDIplus_lastError =
	result := 0

	; Sensible defaults for whole screen capture
	If (_w = 0)
		_w := A_ScreenWidth
	If (_h = 0)
		_h := A_ScreenHeight

	If (_hwndWindow = 0 or not _bWholeWindow)
		hdcWindow := DllCall("GetDC", "UInt",  _hwndWindow)
	Else
		hdcWindow := DllCall("GetWindowDC", "UInt",  _hwndWindow)
	If (hdcWindow = 0)
	{
		#GDIplus_lastError := "Get[Window]DC (for " . _hwndWindow . ": " .  A_LastError . ") " . ErrorLevel
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}

	; Create the buffer holding the capture
	hdcBuffer := DllCall("CreateCompatibleDC", "UInt", hdcWindow)
	If (hdcBuffer = 0)
	{
		#GDIplus_lastError := "CreateCompatibleDC (" .  A_LastError . ") " . ErrorLevel
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	hbmpBuffer := DllCall("CreateCompatibleBitmap"
			, "UInt", hdcWindow
			, "Int", _w
			, "Int", _h)
	If (hbmpBuffer = 0)
	{
		#GDIplus_lastError := "CreateCompatibleBitmap (" .  A_LastError . ") " . ErrorLevel
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	hOld := DllCall("SelectObject", "UInt", hdcBuffer, "UInt", hbmpBuffer)
	If (hOld = 0)
	{
		#GDIplus_lastError := "SelectObject (" .  A_LastError . ") " . ErrorLevel
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	bRes := DllCall("BitBlt"
			, "UInt", hdcBuffer	; HDC hdcDest
			, "Int", 0			; nXDest
			, "Int", 0			; nYDest
			, "Int", _w			; nWidth
			, "Int", _h			; nHeight
			, "UInt", hdcWindow	; HDC hdcSrc
			, "Int", _x			; nXSrc
			, "Int", _y			; nYSrc
			, "UInt", 0x00CC0020)	; DWORD dwRop=SRCCOPY
	If (!bRes)
	{
		#GDIplus_lastError := "BitBlt (" .  A_LastError . ") " . ErrorLevel
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}

	r := DllCall("GDIplus.dll\GdipCreateBitmapFromHBITMAP"
			, "UInt", hbmpBuffer
			, "UInt", 0
			, "UInt *", @bitmap)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipCreateBitmapFromHBITMAP (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
		result := r
		Goto CaptureScreenRectangle_CleanUp
	}

CaptureScreenRectangle_CleanUp:
	DllCall("DeleteObject", "UInt", hbmpBuffer)
	DllCall("DeleteDC", "UInt", hdcBuffer)
	DllCall("ReleaseDC", "UInt", hdcWindow)

	Return result
}

; Save an image on a file
GDIplus_SaveImage(_image, _fileName, ByRef @clsidEncoder, ByRef @encoderParams)
{
	local r, ufn, encoderAddr

	#GDIplus_lastError =
	If @encoderParams = NONE
		encoderAddr := 0
	Else
		encoderAddr := &@encoderParams
	GetUnicodeString(ufn, _fileName)
	r := DllCall("GDIplus.dll\GdipSaveImageToFile"
			, "UInt", _image
			, "UInt", &ufn
			, "UInt", &@clsidEncoder
			, "UInt", encoderAddr)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipSaveImageToFile (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	Return r
}

; Release the memory when an image is stored
GDIplus_DisposeImage(_image)
{
	DllCall("GDIplus.dll\GdipDisposeImage", "UInt", _image)
	; No error checking...
}

; Get size of the image
GDIplus_GetImageDimension(_image, ByRef @imageWidth, ByRef @imageHeight)
{
	local r

   #GDIplus_lastError =
	r := DllCall("GDIplus.dll\GdipGetImageDimension"
			, "UInt", _image
			, "Float *", @imageWidth
			, "Float *", @imageHeight)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipGetImageDimension (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	@imageWidth := Floor(@imageWidth)
	@imageHeight := Floor(@imageHeight)
	Return r
}

; Get part of an image, made by Paulo
; This creates a new bitmap, the given one is unchanged.
GDIplus_CloneBitmapArea(ByRef @croppedImage, _image, _x, _y, _w, _h)
{
   local r

	#GDIplus_lastError =
	r := DllCall("GDIplus.dll\GdipCloneBitmapAreaI"
		, "Int", _x
		, "Int", _y
		, "Int", _w
		, "Int", _h
		, "Int", 0	; PixelFormat: PixelFormatDontCare
		, "UInt", _image
		, "UInt *", _croppedImage)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipCloneBitmapAreaI (" . r . ": " . #GpStatus@%r% . ") _" . ErrorLevel
	}
	Return r
}

;##################################################
; Utility functions

GDIplus_GetEncoderCLSID(ByRef @encoderCLSID, _mimeType)
{
	local r, numEncoders, size, encoders, encoderAddr, sizeImageCodecInfo
	local addr, mimeTypeAddr, mimeType, codecIdentifierAddr

	#GDIplus_lastError =
	; What size do we need?
	r := DllCall("GDIplus.dll\GdipGetImageEncodersSize"
			, "UInt *", numEncoders
			, "UInt *", size)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipGetImageEncodersSize (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}

	; Allocate this size
	VarSetCapacity(encoders, size, 0)
	; And get the listing of encoders
	r := DllCall("GDIplus.dll\GdipGetImageEncoders"
			, "UInt", numEncoders
			, "UInt", size
			, "UInt", &encoders)
	If (r != #GDIplusOK)
	{
		#GDIplus_lastError := "GdipGetImageEncoders (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	encoderAddr := &encoders

	sizeImageCodecInfo := 76
	mimeTypeOffset := 48
	/*
	class ImageCodecInfo
	{
	// Size: 2 * 16 + 11 * 4 = 76
	public:                             // Offsets / Sizes (4 by default)
		// Codec identifier.
		CLSID Clsid;                    //   0 / 16
		// File format identifier. GUIDs that identify various file formats
		// (ImageFormatBMP, ImageFormatEMF, and the like) are defined in Gdiplusimaging.h.
		GUID  FormatID;                 //  16 / 16
		// Pointer to a null-terminated string that contains the codec name.
		const WCHAR* CodecName;         //  32
		// Pointer to a null-terminated string that contains the path name of the DLL
		// in which the codec resides.  If the codec is not in a DLL, this pointer is NULL.
		const WCHAR* DllName;           //  36
		// Pointer to a null-terminated string that contains the name of the file format used by the codec.
		const WCHAR* FormatDescription; //  40
		// Pointer to a null-terminated string that contains all file-name extensions associated with the codec.
		// The extensions are separated by semicolons.
		const WCHAR* FilenameExtension; //  44
		// Pointer to a null-terminated string that contains the mime type of the codec.
		const WCHAR* MimeType;          //  48
		// Combination of flags from the ImageCodecFlags enumeration.
		DWORD Flags;                    //  52
		// Integer that indicates the version of the codec.
		DWORD Version;                  //  56
		// Integer that indicates the number of signatures used by the file format associated with the codec.
		DWORD SigCount;                 //  60
		// Integer that indicates the number of bytes in each signature.
		DWORD SigSize;                  //  64
		// Pointer to an array of bytes that contains the pattern for each signature.
		const BYTE* SigPattern;         //  68
		// Pointer to an array of bytes that contains the mask for each signature.
		const BYTE* SigMask;            //  72
	};
	// Size: 4 + 2 + 2 + 8 = 16
	typedef struct _GUID {
		unsigned long  Data1;
		unsigned short Data2;
		unsigned short Data3;
		unsigned char  Data4[ 8 ];
	} GUID;
	typedef GUID CLSID;
	*/
	; Loop through all the codecs
	codecIdentifierAddr = 0
	Loop %numEncoders%
	{
		addr := encoderAddr + 48
		mimeTypeAddr := *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
		mimeType := GetAnsiStringFromUnicodePointer(mimeTypeAddr)
		If (mimeType = _mimeType)
		{
			; We found it!
			codecIdentifierAddr := encoderAddr
			Break
		}
		encoderAddr += sizeImageCodecInfo
	}

	If (codecIdentifierAddr = 0)
	{
		; Not found
		r := #GpStatus@13	; UnknownImageFormat
		#GDIplus_lastError := "GDIplus_GetEncoderCLSID (" . r . ": " . #GpStatus@%r% . ") " . ErrorLevel
	}
	Else
	{
		; Copy the CLSID of the codec
		VarSetCapacity(@encoderCLSID, #sizeOfCLSID, 0)
		DllCall("RtlMoveMemory"
				, "UInt", &@encoderCLSID
				, "UInt", codecIdentifierAddr
				, "Int", #sizeOfCLSID)
	}

	Return r
}

; Initialize the encoder parameters
GDIplus_InitEncoderParameters(ByRef @encoderParameters, _paramCount)
{
	local r

	; Initialize encoder parameters (blank)
	VarSetCapacity(@encoderParameters, 4 + _paramCount * #sizeOfEncoderParameter, 0)

	Return 0
}

; Add one encoder parameter (currently only Long ones)
GDIplus_AddEncoderParameter(ByRef @encoderParameters, _categoryGUID, ByRef @value)
{
	local r, size, clsid, guid, count, parameterOffset

	/*
	class EncoderParameters
	{
	public:
		UINT Count;                      // Number of parameters in this structure
		EncoderParameter Parameter[1];   // Parameter values
	};
	*/
	; Get current number of parameters
	count := GetInteger(@encoderParameters, 0)
	parameterOffset := 4 + count * #sizeOfEncoderParameter
	; Add another
	count++

	size := VarSetCapacity(@encoderParameters)
	If (size <4 + count * #sizeOfEncoderParameter)
	{
		#GDIplus_lastError = GDIplus_AddEncoderParameter (@encoderParameters is too small, call GDIplus_InitEncoderParameters with proper number of parameters)
		Return -1
	}
	SetInteger(@encoderParameters, count, 0)	; Number of EncoderParameter's

	/*
	class EncoderParameter
	{
	public:
		// Identifies the parameter category. (EncoderCompression, EncoderColorDepth, EncoderQuality, and the like) are defined in Gdiplusimaging.h.
		GUID Guid;
		// Number of values in the array pointed to by the Value data member.
		ULONG NumberOfValues;
		// Identifies the data type of the parameter. The EncoderParameterValueType enumeration in Gdiplusenums.h defines several possible value types.
		ULONG Type;
		// Pointer to an array of values. Each value has the type specified by the Type data member.
		VOID* Value;
	};
	*/
	GetUnicodeString(clsid, _categoryGUID)
	VarSetCapacity(guid, #sizeOfCLSID, 0)
	r := DllCall("Ole32\CLSIDFromString"
			, "UInt", &clsid
			, "UInt", &guid
			, "UInt")
	If (r != 0)	; NOERROR
	{
		If (r = 0x800401F3)	; CO_E_CLASSSTRING
			#GDIplus_lastError = CLSIDFromString (CO_E_CLASSSTRING: The class string was improperly formatted.)
		Else If (r = 0x80040151)	; REGDB_E_WRITEREGDB
			#GDIplus_lastError = CLSIDFromString (REGDB_E_WRITEREGDB: The CLSID corresponding to the class string was not found in the registry.)
		Else
			#GDIplus_lastError = CLSIDFromString (Unknown error: %r%)
		Return r
	}

	; Set Guid
	DllCall("RtlMoveMemory"
			, "UInt", &@encoderParameters + parameterOffset
			, "UInt", &guid
			, "Int", #sizeOfCLSID)
	parameterOffset += #sizeOfCLSID
	; Set NumberOfValues
	SetInteger(@encoderParameters, 1,  parameterOffset)
	parameterOffset += 4
	; Set Type
	SetInteger(@encoderParameters, #EncoderParameterValueTypeLong, parameterOffset)
	parameterOffset += 4
	; Set Value
	SetInteger(@value, @value)	; Overwrite the @value storage space with the value it contained
	SetInteger(@encoderParameters, &@value, parameterOffset)

	Return 0
}
