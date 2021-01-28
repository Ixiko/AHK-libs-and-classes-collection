#SingleInstance, Force
#NoEnv

; gdiplus must be started up once at the beginning of your script
pToken := Gdip_Startup()

; Example to convert "in.jpg" to "out.png" and make it 200x100 pixels
ConvertImage("in.jpg", "out.bmp")			;%
; ConvertImage("C:\Documents and Settings\USER\Desktop\67245.jpg","C:\Documents and Settings\USER\Desktop\67245.bmp")
; ....and gdiplus must be shut down once at the end of your script
Gdip_Shutdown(pToken)
Return

;###############################################################################################################

Gdip_Startup()
{
	If !DllCall("GetModuleHandle", "Str", "gdiplus")
	DllCall("LoadLibrary", "Str", "gdiplus")
	VarSetCapacity(si, 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "UInt*", pToken, "UInt", &si, "UInt", 0)
	VarSetCapacity(si, 0)
	Return, pToken
}

;###############################################################################################################

Gdip_Shutdown(pToken)
{
	DllCall("gdiplus\GdiplusShutdown", "UInt", pToken)
	If hModule := DllCall("GetModuleHandle", "Str", "gdiplus")
	DllCall("FreeLibrary", "UInt", hModule)
	Return, 0
}

;###############################################################################################################
;
; ConvertImage() by Tariq Porter (tic) 04/05/08
; Version:		1.01
;
; sInput:      	Location of the input file to be converted. May be of filetype jpg,bmp,png,tiff,gif
; sOutput:      Location to save the converted file. Extension determines the output filetype jpg,bmp,png,tiff,gif
; Width:     	Width either in pixels or percentage (depending on Method) to save the converted file
; Height:      	Height either in pixels or percentage (depending on Method) to save the converted file
;				Width or Height may also be -1 to keep the aspect ratio the same
; Method:      	Can either be "Percent" or "Pixels" to determine the width and height of the converted file
;
; Return:		0=Success; -1=Could not create a bitmap from file; -2=Source file has no width or height
;				-3=Resize method must be either Precentage or Pixels; -4=Error resizing image; 
;				-5=Could not get a list of filetype encoders on the system; -6=Could not find matching codec
;				-7=Wide file output could not be created; -8=File could not be written to disk

ConvertImage(sInput, sOutput, Width="", Height="", Method="Percent")
{
	StringSplit, OutputArray, sOutput, .
    Extension := "." OutputArray%OutputArray0%
   
	VarSetCapacity(wInput, 1023)
	DllCall("kernel32\MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sInput, "Int", -1, "UInt", &wInput, "Int", 512)
	DllCall("gdiplus\GdipCreateBitmapFromFile", "UInt", &wInput, "UInt*", pBitmap)
	If !pBitmap
	Return, -1
   
	If (Width && Height)
	{
		DllCall("gdiplus\GdipGetImageWidth", "UInt", pBitmap, "UInt*", sWidth)
		DllCall("gdiplus\GdipGetImageHeight", "UInt", pBitmap, "UInt*", sHeight)
		If !(sWidth && sHeight)
		{
			DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
			Return, -2
		}
         
		If (Method = "Percent")
		{
			Width := (Width = -1) ? Height : Width, Height := (Height = -1) ? Width : Height
			dWidth := Round(sWidth*(Width/100)), dHeight := Round(sHeight*(Height/100))
		}
		Else If (Method = "Pixels")
		{
			If (Width = -1)
			dWidth := Round((Height/sHeight)*sWidth), dHeight := Height
			Else If (Height = -1)
			dHeight := Round((Width/sWidth)*sHeight), dWidth := Width
			Else
			dWidth := Width, dHeight := Height
		}
		Else
		{
			DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
			Return, -3
		}
      
		DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", dWidth, "Int", dHeight, "Int", 0, "Int", 0x26200A, "UInt", 0, "UInt*", FpBitmap)
		DllCall("gdiplus\GdipGetImageGraphicsContext", "UInt", FpBitmap, "UInt*", G)
		DllCall("gdiplus\GdipSetInterpolationMode", "UInt", G, "Int", 7)
      
		E := DllCall("gdiplus\GdipDrawImageRectRectI", "UInt", G, "UInt", pBitmap
		, "Int", 0, "Int", 0, "Int", dWidth, "Int", dHeight
		, "Int", 0, "Int", 0, "Int", sWidth, "Int", sHeight
		, "Int", 2, "UInt", ImageAttr, "UInt", 0, "UInt", 0)
      
		DllCall("gdiplus\GdipDeleteGraphics", "UInt", G)
		DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
		pBitmap := FpBitmap
		
		If E
		{
			DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
			Return, -4
		}
	}
   
	DllCall("gdiplus\GdipGetImageEncodersSize", "UInt*", nCount, "UInt*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UInt", &ci)
	If !(nCount && nSize)
	{
		DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
		Return, -5
	}
   
    Loop, %nCount%
    {
        nSize := DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0, "UInt", NumGet(ci, 76*(A_Index-1)+44), "Int", -1, "UInt", 0, "Int",  0, "UInt", 0, "UInt", 0)
        VarSetCapacity(sString, nSize)
        DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0, "UInt", NumGet(ci, 76*(A_Index-1)+44), "Int", -1, "Str", sString, "Int", nSize, "UInt", 0, "UInt", 0)
   
        If !InStr(sString, Extension)
        Continue
        pCodec := &ci+76*(A_Index-1)
        Break
    }
	If !pCodec
	{
		DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
		Return, -6
	}
   
	nSize := DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sOutput, "Int", -1, "UInt", 0, "Int", 0)
	VarSetCapacity(wOutput, nSize*2)
	DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sOutput, "Int", -1, "UInt", &wOutput, "Int", nSize)
	VarSetCapacity(wOutput, -1)
	If !VarSetCapacity(wOutput)
	{
		DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
		Return, -7
	}

	E := DllCall("gdiplus\GdipSaveImageToFile", "UInt", pBitmap, "UInt", &wOutput, "UInt", pCodec, "UInt", 0)
	DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
	If E
	DllCall("gdiplus\GdipDisposeImage", "UInt", pBitmap)
	Return, E ? -8 : 0
}