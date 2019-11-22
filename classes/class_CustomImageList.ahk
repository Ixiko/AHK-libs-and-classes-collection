Class CustomImageList {
	
	LargeIcons := true
	
	__New(Width, Height, Flags, GifPeriod := 333, InitialCount := 20, GrowCount := 5) {
		this.id := DllCall("comctl32.dll\ImageList_Create", "int", Width, "int", Height, "uint", Flags, "int", Initial, "int", Grow)
		this.Width := Width
		this.Height := Height
		this.GifPeriod := GifPeriod
		this.InitialCount := InitialCount
		this.GrowCount := GrowCount
	}
	
	__Destroy() {
		return DllCall("comctl32.dll\ImageList_Destroy", "uint", this.id)
	}
	
	Add(hBitmap, hbmMask := "") {
		return DllCall("comctl32.dll\ImageList_Add", "uint", this.id, "uint", hBitmap, "uint", hbmMask) + 1
	}
	
	AddFile(File) {
		; create bitmap from file
		pBitmap := Gdip_CreateBitmapFromFile(File)
		if (pBitmap < 1) ; failed at creating bitmap from file
			return false
		Icon := this.AddBitmap(pBitmap)
		Gdip_DisposeImage(pBitmap)
		return Icon
	}
	
	AddBitmap(pBitmap) {
		; get a resized bitmap
		;pBitmapResized := this.ScaleBitmap(pBitmap)
		; get handle
		hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)
		return this.Add(hBitmap)
	}

	; https://autohotkey.com/boards/viewtopic.php?t=14275
	; returns a list of imagelist icon numbers in order associated with the gif
	AddGif(File) {
		IconList := []
		
		; gif bitmap
		pBitmap := Gdip_CreateBitmapFromFile(file)
		
		; dunno what this is, honestly
		DllCall("Gdiplus\GdipImageGetFrameDimensionsCount", "ptr", pBitmap, "uptr*", frameDimensions)
		this.SetCapacity("dimensionIDs", 32)
		DllCall("Gdiplus\GdipImageGetFrameDimensionsList", "ptr", pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int", frameDimensions)
		DllCall("Gdiplus\GdipImageGetFrameCount", "ptr", pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int*", count)
		
		DelayAdd := 0
		FrameDelay := this.GetFrameDelay(pBitmap)
		
		for Index, Delay in FrameDelay {
			DelayAdd += Delay
			if (DelayAdd > this.GifPeriod) {
				DllCall("Gdiplus\GdipImageSelectActiveFrame", "ptr", pBitmap, "uptr", this.GetAddress("dimensionIDs"), "int", Index)
				IconList.Push(this.AddBitmap(pBitmap))
				DelayAdd -= this.GifPeriod
			}
		}
		
		Gdip_DisposeImage(pBitmap)
		Object.Delete("dimensionIDs")
		
		return IconList
	}
	
	; Return a zero-based array, containing the frames delay (in milliseconds)
	; thanks tmplinshi!
	GetFrameDelay(pImage) {
		static PropertyTagFrameDelay := 0x5100
		
		DllCall("Gdiplus\GdipGetPropertyItemSize", "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt*", ItemSize)
		VarSetCapacity(Item, ItemSize, 0)
		DllCall("Gdiplus\GdipGetPropertyItem", "Ptr", pImage, "UInt", PropertyTagFrameDelay, "UInt", ItemSize, "Ptr", &Item)
		
		PropLen := NumGet(Item, 4, "UInt")
		PropVal := NumGet(Item, 8 + A_PtrSize, "UPtr")
		
		outArray := []
		Loop, % PropLen//4 {
			if !n := NumGet(PropVal+0, (A_Index-1)*4, "UInt")
				n := 10
			outArray[A_Index-1] := n * 10
		}
		return outArray
	}
	
	; scales any bitmap down to the Width and Height specified at the imagelist creation
	ScaleBitmap(pBitmap) {
		; get dimensions
		BigWidth := Gdip_GetImageWidth(pBitmap)
		BigHeight := Gdip_GetImageHeight(pBitmap)
		
		; make a new bitmap and size it up
		pBitmapResized := Gdip_CreateBitmap(this.Width, this.Height)
		G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_SetInterpolationMode(G, 7)
		
		; figure out aspect ratio stuffs
		if (this.Width/this.Height > BigWidth/BigHeight) ; target thumbnail size is wider than original image, limit by height
			h := this.Height, w := Round(this.Width * ((BigWidth/BigHeight) / (this.Width/this.Height)))
		else if (this.Width/this.Height < BigWidth/BigHeight) ; target thumbnail size is higher than original image, limit by width
			w := this.Width, h := Round(this.Height * ((BigHeight/BigWidth) / (this.Height/this.Width)))
		else ; aspects are equal
			h := this.Height, w := this.Width
		
		; spit out a resized bitmap on top of that new bitmap
		Gdip_DrawImage(G, pBitmap, this.Width/2 - w/2, this.Height/2 - h/2, w, h)
		
		; return the resized bitmap
		return pBitmapResized
	}
}