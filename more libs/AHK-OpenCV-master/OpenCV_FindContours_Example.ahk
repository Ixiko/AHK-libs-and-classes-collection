#NoEnv
#Persistent
#SingleInstance Force 
SetBatchLines, -1

#Include Lib\OpenCV.ahk
; #Include Lib\gdip.ahk

file := "Images\shapes.jpg"

; Create OpenCV instance.
cv := new OpenCV()

; Start up gdip
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}

; Load image from file
pImg := cv.LoadImage(file) 

; Get the size of the image
cv.GetSize(pImg, width, height) 

; Create a gui window to use for drawing the contours
Gui, +E0x80000 +hwndhwnd1

; Show the window
Gui, Show, w%width% h%height%, NA

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; Create a fully opaque red pen (ARGB = Transparency, red, green, blue) of width 2 (the thickness the pen will draw at)
pPen := Gdip_CreatePen("0xffff0000", 2)

; Display input image inside an opencv window
cv.ShowImage("Example-in", pImg) 

; Smooth the input image a bit
cv.Smooth( pimg, pimg, GAUSSIAN:=2, 3, 3) ;

; Create a destination image for the grayscale version of the input image
pimgGrayScale := cv.CreateImage(cv.GetSize(pImg, width, height), 8, 1)

; Store a grayscale version of the input image
cv.CvtColor( pimg, pimgGrayScale, cv.Constants.BGR2GRAY) ; BGR2GRAY = 6

; Create a black and white image holder
pimgBW := cv.CreateImage( cv.GetSize(pimg), 8, 1) ;

; Get ride of some noise by erode
cv.Erode( pimgGrayScale, pimgBW , Null:=0, 3 )

; Convert to BW, may need to adjust threshold value (200)
cv.Threshold( pimgBW, pimgBW, 200, 255, cv.Constants.THRESH_BINARY)

; Get ride of some noise by dilate
cv.Dilate( pimgBW, pimgBW, Null:=0, 3 )

; Invert black and white with a threshold
cv.Threshold( pimgBW, pimgBW, 128, 255, cv.Constants.THRESH_BINARY_INV) ;

; Show the black and white image inside an opencv window
cv.ShowImage( "Example-bw", pimgBW) ;

; Setup memory block
pStorage := cv.CreateMemStorage(0) ; Create a storage area

; Create a sequence for the contours
pcontours := cv.CreateSeq(0, 24+10*A_PtrSize, tagCvPointSize := 8, pstorage)

; Find all exterior and inner contours in a list format (no vertical)
num_found := cv.FindContours(pimgBW, pstorage, pcontours, 56+10*A_PtrSize, CV_RETR_LIST := 1, CV_CHAIN_APPROX_SIMPLE := 2, 0) ; return amount of found contours

; Copy the contours pointer
pnext := pcontours

; Cycle through all contours
loop % num_found 
{
	; Copy the current contours pointer
	vnext := pnext
	
	; get the pointer to the next contours sequence
	pnext := NumGet(vnext+0, 8, "ptr") ; h_next = 8
	
	if (pnext = 0) ; skip over first sequence (which seems empty)
		pnext := pcontours + NumGet(vnext+0, 4, "int") ; header_size = 4 
	
	; get the sequence flags (like "0x4299500C" is an exterior contours)
	flags := NumGet(pnext+0, 0, "int")

	; Check if the sequence holds a exterior contours "0x4299500C" or interior contours "0x4299D00C". Remove if statement for both
	if (flags =  0x4299500C) 
	{
		; Determine number of elements in sequence
		datasize := NumGet(pnext+0, 8+4*A_PtrSize, "int") ; "int total;" at 8+4*A_PtrSize
		
		; Clear variable to hold coords of sequence
		apts := "" 
		
		; Cycle through number of elements in sequence
		loop % datasize + 1 
		{
			vpoint := cv.GetSeqElem(pnext, A_index-1) ; get sequence element
			
			x := NumGet(vpoint+0, 0, "int") ; get point x coords
			y := NumGet(vpoint+0, 4, "int") ; get point y coords
			
			apts .= x "," y "|" ; store coords in a "x,y|x1,y1|x2,y2" format
			
			vpoint := "" ; clear variable
		}
		
		; Trim off last |
		StringTrimRight,apts,apts,1 
		
		; Draw it in Layered Window using gdi drawlines
		Gdip_DrawLines(G, pPen, apts)

		vnext := ""
	}

	; just to show that each sequence is drawn individually
	UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height) ; remove this line and use the below call outside the loop to update the window only once
	Sleep 1000 ; remove for speed
	
}

; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; With some simple maths we can place the gui in the centre of our primary monitor horizontally and vertically at the specified heigth and width
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)

; Wait for the user to hit ok, then clean up the windows
msgbox % "wait for key"

; Be tidy

; Select the object back into the hdc
SelectObject(hdc, obm)

; Remove the window with the drawn contours sequences
gui Destroy 

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)

cv.ReleaseImage( pimgBW ) ;
cv.ReleaseImage( pimgGrayScale ) ;
cv.ReleaseImage( pimg ) ;
cv.DestroyAllWindows() ;
cv.ClearMemStorage( pstorage ) ;
cv.ClearSeq(pcontours) ;

Gdip_Shutdown(pToken)
return

~ESC:: ExitApp