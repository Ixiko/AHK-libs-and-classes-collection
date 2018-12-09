TilePicture(guiName, TilehWnd, desiredW, desiredH) {	
/*		Credits: dmatch - autohotkey.com/board/topic/24542-tiled-gui-background/?p=159043
		Allows to tile a picture to the defined sizes.
		
		Usage:
		Gui, Example:Add, Picture,x0 y0 hWndhTile,% pathToYourPicture
		TilePicture("Example", hTile, 500, 300)
*/
	picturePos := Get_ControlCoords(guiName, TileHwnd) ; Get size of the picture
	w := picturePos.W, h := picturePos.H

	SendMessage,0x173,0,0,,ahk_id %TilehWnd% ; 0x173 is STM_GETIMAGE
	hBMCopy:=ErrorLevel
	
	hBM:=DllCall("CopyImage",uint,hBMCopy,uint,0,int,0,int,0,uint,0x2000) ; Get a copy of the picture
	hDC:=DllCall("GetDC",uint,TilehWnd,uint) ; Get device context for picture
	hCDC:=DllCall("CreateCompatibleDC",uint,hDC,uint) ; Create compatible device context to put picture in
	DllCall("SelectObject",uint,hCDC,uint,hBM) ; Put the picture in the CDC
	hCDC2:=DllCall("CreateCompatibleDC",uint,hDC,uint) ; Create compatible device context to hold tiled image
	hBM2:=DllCall("CreateCompatibleBitmap",uint,hDC,int,desiredW,int,desiredH,uint) ; Create an empty bitmap to trap the tiled image in
	DllCall("SelectObject",uint,hCDC2,uint,hBM2) ; Put the empty image in so can draw on it
	
	x := -1 * w,    y := 0
	
	Loop {
		x += w
		if (x >= desiredW) {
			x:=0,    y+=h
			if (y >= desiredH) {
				break
			}
		}
		DllCall("BitBlt",uint,hCDC2,int,x,int,y,int,w,int,h,uint,hCDC,int,0,int,0,uint,0xcc0020) ; Build the tiled image in the compatible heretofore empty bitmap
	}

	; Cleanup
	DllCall("ReleaseDC",uint,TilehWnd,uint,hDC)
	DllCall("DeleteObject",uint,hCDC)
	DllCall("DeleteObject",uint,hCDC2)
	DllCall("DeleteObject",uint,hBM)
	
	; Apply the tiled image to the original picture
	SendMessage, 0x172, 0, hBM2,, ahk_id %TilehWnd% ; 0x172 is STM_SETIMAGE message	
	if (ErrorLevel && hBM2 <> ErrorLevel) {
		DllCall("DeleteObject",uint,errorlevel)
	}
}