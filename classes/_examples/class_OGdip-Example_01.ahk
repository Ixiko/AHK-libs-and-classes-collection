SetBatchLines, -1
#KeyHistory, 0


#Include %A_ScriptDir%\OGdip.ahk
Gdip.Startup()

; I'm wrapping everything into function so I don't have
; to deal with deleting objects myself before shutdown.

GdipExampleFunction_01() {
	; Let's load well-known test image
	bmpLenna := new Gdip.Bitmap(A_ScriptDir "\Lenna.jpg")

	; It's too big for us, let's make half-sized copy of that image
	bmpHalf := new Gdip.Bitmap(bmpLenna.width // 2, bmpLenna.height // 2)
	bmpHalf.G.DrawBitmap(bmpLenna, 0, 0,  0.5, 0.5)

	; These width and height will be used many times
	hw := bmpHalf.width
	hh := bmpHalf.height

	; Okay, let's make our canvas for 3x3 images
	bmpCanvas := new Gdip.Bitmap(hw * 3, hh * 3)


	; R1C1 - 2-color (1bpp) image
	bmpTest_I1 := new Gdip.Bitmap(bmpHalf)  ; Create copy of original bitmap
	bmpTest_I1.ConvertFormat("I1", "BW")    ; Convert to dithered black-n-white
	bmpTest_I1.SetPalette([ 0xFF4A2514, 0xFFD0BAA4 ])  ; Change palette
	bmpCanvas.G.DrawBitmap(bmpTest_I1, 0*hw, 0*hh)

	; R1C2 - 16-color (4bpp) image
	bmpTest_I4 := new Gdip.Bitmap(bmpHalf)
	bmpTest_I4.ConvertFormat("I4", "SYS8", False)  ; Convert to non-dithered 16-color
	bmpTest_I4.SetAttribute("Remap"                ; Remap dark-yellow color with attribute.
	, [ Gdip.RGBA(128,128,0)                       ; Attributes don't change original bitmap,
	,   Gdip.RGBA(150,100,50) ])                   ; they only applied when drawing.
	bmpCanvas.G.DrawBitmap(bmpTest_I4, 1*hw, 0*hh)

	; R1C3 - 256-color (8bpp) image
	bmpTest_I8 := new Gdip.Bitmap(bmpHalf)
	bmpTest_I8.ConvertFormat("I8", "WEB", "8x8")   ; Convert with ordered dithering.
	bmpCanvas.G.DrawBitmap(bmpTest_I8, 2*hw, 0*hh)


	; R2C1 - Blur image
	bmpTest_Blurry := new Gdip.Bitmap(bmpHalf)
	bmpTest_Blurry.Blur(8)
	bmpCanvas.G.DrawBitmap(bmpTest_Blurry, 0*hw, 1*hh)

	; R2C2 - Alter image's hue
	bmpTest_Hue := new Gdip.Bitmap(bmpHalf)
	bmpTest_Hue.HSL(150, 0, 0)
	bmpCanvas.G.DrawBitmap(bmpTest_Hue, 1*hw, 1*hh)

	; R2C3 - Invert image with color matrix
	bmpTest_Mx := new Gdip.Bitmap(bmpHalf)
	bmpTest_Mx.ColorMatrix([ [-1,0,0,0,1],[0,-1,0,0,1], [0,0,-1,0,1] ])
	bmpCanvas.G.DrawBitmap(bmpTest_Mx, 2*hw, 1*hh)

	; R3C1 - Flip image and use clipping for caleidoscopic appearance
	bmpTest_Flip := new Gdip.Bitmap(bmpHalf)
	bmpCanvas.G.SetClip(0*hw, 2*hh, 0.5*hw, 0.5*hh)  ; Clip quarter of image
	bmpCanvas.G.DrawBitmap(bmpTest_Flip, 0*hw, 2*hh)

	bmpTest_Flip.Rotate("X")  ; Part 2
	bmpCanvas.G.SetClip(0.5*hw, 2*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawBitmap(bmpTest_Flip, 0*hw, 2*hh)

	bmpTest_Flip.Rotate("Y")  ; Part 3
	bmpCanvas.G.SetClip(0.5*hw, 2.5*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawBitmap(bmpTest_Flip, 0*hw, 2*hh)

	bmpTest_Flip.Rotate("X")  ; Part 4
	bmpCanvas.G.SetClip(0*hw, 2.5*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawBitmap(bmpTest_Flip, 0*hw, 2*hh)
	bmpCanvas.G.ResetClip()

	; R3C2 - Rotate image by 45°
	bmpTest_R45 := new Gdip.Bitmap(bmpHalf)
	bmpCanvas.G.DrawBitmap(bmpTest_R45
	, 1.5*hw, 2.5*hh   ; Here we draw image by its center, not top-left corner
	, 0.707, 0.707     ; Scale by ≈1/√2
	, hw/2, hh/2       ; Set origin to the center of the image
	, 45)              ; Rotate by 45 degrees (clockwise)

	; R3C3 - Create histogram - see another function
	bmpHist := Example_CreateHistogram(bmpHalf, "MemBuffer")  ; Try "SetPixel"/"LockBits"!
	bmpCanvas.G.DrawBitmap(bmpHist, 2*hw, 2*hw)

	bmpCanvas.SaveToFile("Example_01.tif")
}

; This function creates histogram with one of three different methods
Example_CreateHistogram(source, method) {
	; Get histogram array
	histData := source.GetHistogram("RGB")
	maxValue := Max(histData.info.R.Max, histData.info.G.Max, histData.info.B.Max)
	fitValueTo255 := 255 / maxValue  ; Multiplier for histogram values

	; Prepare to do hard work and measure it
	SetBatchLines -1
	ListLines Off
	timeStart := A_TickCount

	sizeX := histData.entries
	sizeY := source.height

	; Fast way: fill memory buffer first, then create image from it.
	If (method == "MemBuffer") {
		; Create memory buffer
		VarSetCapacity(memBuffer, source.height * histData.entries * 4)

		Loop % sizeY {
			py := A_Index-1

			Loop % sizeX {
				px := A_Index-1

				r := (fitValueTo255 * histData.R[px]  >  py)  ?  0xFF  : 0x20
				g := (fitValueTo255 * histData.G[px]  >  py)  ?  0xFF  : 0x20
				b := (fitValueTo255 * histData.B[px]  >  py)  ?  0xFF  : 0x20
				rgbColor := Gdip.RGBA(r, g, b)

				NumPut(rgbColor, memBuffer, 4*(px + py * sizeY), "UInt")
			}
		}

		bmpHist := new Gdip.Bitmap(sizeX, sizeY, &memBuffer, "ARGB32", 4*sizeY)

	} Else
	; Slow way: set each pixel individually.
	If (method == "SetPixel") {
		bmpHist := new Gdip.Bitmap(source)

		Loop % sizeY {
			py := A_Index-1

			Loop % sizeX {
				px := A_Index-1

				r := (fitValueTo255 * histData.R[px]  >  py)  ?  0xFF  : 0x20
				g := (fitValueTo255 * histData.G[px]  >  py)  ?  0xFF  : 0x20
				b := (fitValueTo255 * histData.B[px]  >  py)  ?  0xFF  : 0x20
				rgbColor := Gdip.RGBA(r, g, b)

				bmpHist.SetPixel(px, py, rgbColor)
			}
		}

	} Else
	; Fast way: create image and get its data as memory buffer.
	If (method == "LockBits") {
		bmpHist := new Gdip.Bitmap(source)
		bmpHist.LockBits(0, 0, source.width, source.height,  pBmpData, pStride, pScan0)

		Loop % sizeY {
			py := A_Index-1

			Loop % sizeX {
				px := A_Index-1

				r := (fitValueTo255 * histData.R[px]  >  py)  ?  0xFF  : 0x20
				g := (fitValueTo255 * histData.G[px]  >  py)  ?  0xFF  : 0x20
				b := (fitValueTo255 * histData.B[px]  >  py)  ?  0xFF  : 0x20
				rgbColor := Gdip.RGBA(r, g, b)

				NumPut(rgbColor, 0+pScan0, 4*px + pStride*py, "UInt")
			}
		}

		bmpHist.UnlockBits(pBmpData)

	} Else {
		Return "There is no such method"
	}

	timeEnd := A_TickCount

	; Resulting histogram's bottom is on top, so flip it:
	bmpHist.Rotate("Y")

	; Print measured time
	timeString := Format("Histogram`n{1} method: {2} ms", method, timeEnd-timeStart)
	bmpHist.SetBrush(0xFFFFFFFF)    ; White brush for text
	bmpHist.SetOptions("+Hint-AA")  ; Enable hinting, disable antialiasing
	bmpHist.DrawString(timeString, "Arial", 11, 16, 16)

	Return bmpHist
}

; Call the function
GdipExampleFunction_01()

Gdip.Shutdown()