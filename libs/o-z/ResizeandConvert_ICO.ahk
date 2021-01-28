
/*
#SingleInstance, Force
#NoEnv
SetBatchLines, -1
Gui, Add, Text, , Drag and drop images to create icons.
Gui, Show, H200 W200
return

GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
	i++
	ImageArray := []
	ImageArray[1] := [A_LoopField, 128, 128]
	ImageArray[2] := [A_LoopField, 64, 64]
	ImageArray[3] := [A_LoopField, 32, 32]
	ImageArray[4] := [A_LoopField, 16, 16]
	ResConICO(ImageArray, "MyIcon" i ".ico", A_Desktop)
}
return

GuiClose:
ExitApp
*/


; Based on (Large parts are directly from):
; http://www.autohotkey.com/board/topic/82416-ico-createrconverter-png-to-ico/
; http://www.autohotkey.net/~Rseding91/ICO%20Converter/ICO%20Converter.ahk
ResConICO(ImageArray, NewName, NewDir) {
	ICO_ContainerSize := 16
	, O := 0
	, Total_PotentialSize := 6
	, pToken := Gdip_Startup()

	; Convert Images
	for i, img in ImageArray {
		pBitmapFile := Gdip_CreateBitmapFromFile(img[1])							; Get a bitmap of the file to convert
		, pBitmap := Gdip_CreateBitmap(img[2], img[3])								; Create a new bitmap of the desired width/heigh
		, G := Gdip_GraphicsFromImage(pBitmap)                                  	; Get a pointer to the graphics of the bitmap
		, Gdip_SetSmoothingMode(G, 4)												; Set image quality modes
		, Gdip_SetInterpolationMode(G, 7)
		, Gdip_DrawImage(G, pBitmapFile, 0, 0, img[2], img[3])            		 	; Draw the original image onto the new bitmap
		, Gdip_DisposeImage(pBitmapFile)                                        	; Delete the bitmap of the original image
		, Gdip_SaveBitmapToFile(pBitmap, A_ScriptDir "\TempResized" i ".png")       ; Save the new bitmap to file
		, Gdip_DisposeImage(pBitmap)                                            	; Delete the new bitmap
		, Gdip_DeleteGraphics(G)                                               		; The graphics may now be deleted
		, img[1] := A_ScriptDir "\TempResized" i ".png"
		FileGetSize, ImgSize, % img[1]
		if (ImgSize)
			Total_PotentialSize += ICO_ContainerSize + ImgSize
	}

	VarSetCapacity(ICO_Data, Total_PotentialSize, 0)
	, NumPut(0, ICO_Data, O, "UShort"), O += 2 ;reserved - always 0
	, NumPut(1, ICO_Data, O, "UShort"), O += 2 ;ico = 1, cur = 2
	, NumPut(0, ICO_Data, O, "UShort"), O += 2 ;number of images in file

	for i, img in ImageArray {
		if (img[2] < 257 && img[3] < 257 && File := FileOpen(img[1], "r")) {
			NumPut(img[2], ICO_Data, O, "UChar"), O += 1 ;image width: 256 = 0
			, NumPut(img[3], ICO_Data, O, "UChar"), O += 1 ;image height: 256 = 0
			, NumPut(0, ICO_Data, O, "UChar"), O += 1 ;color palatte: 0 if not used
			, NumPut(0, ICO_Data, O, "UChar"), O += 1 ;reserved - always 0
			, NumPut(0, ICO_Data, O, "UShort"), O += 2 ;ico - color planes (0/1), cur - horizontal coordinates of the hotspot in pixels from left
			, NumPut(32, ICO_Data, O, "UShort"), O += 2 ;ico - bits per pixel, cur - vertical coordinates of hotspot in pixels from top
			, NumPut(File.Length, ICO_Data, O, "UInt"), O += 4 ;Size of image data in bytes
			, NumPut(O + 4, ICO_Data, O, "UInt"), O += 4 ;Offset of image data from begining of ico/cur file
			, File.RawRead(&ICO_Data + O, File.Length)
			, O += File.Length
			, NumPut(NumGet(ICO_Data, 4, "UShort") + 1, ICO_Data, 4, "UShort") ;Adds one to the total number of images
			, File.Close()
		}
		FileDelete, % img[1]
	}

	If (O > 6){
		File := FileOpen(NewDir "\" NewName, "w")
		, File.RawWrite(&ICO_Data, O)
		, File.Close()
		, VarSetCapacity(ICO_Data, O, 0)
		, VarSetCapacity(ICO_Data, 0)
	}
	Gdip_Shutdown(pToken)
}