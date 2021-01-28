#NoEnv
#Persistent
#SingleInstance Force
SetBatchLines, -1

#Include <OpenCV>

Example() {

	static scale := 0.6
	static window1 := "AHK | OpenCV - Preview Window 1"
	static window2 := "AHK | OpenCV - Preview Window 2"
	static file := "Images\2.png"
	static haarCascadePath := A_ScriptDir "\haarcascades_GPU\haarcascade_fullbody.xml"

	; Create OpenCV instance.
	cv := new OpenCV()

	; Load HAAR Features dataset
	cascade := cv.Load(haarCascadePath)

	pImg := cv.LoadImage(file) ; Load IPL type image
	; pImg := cv.BmpToIPL(pBitmap) ; Load Bitmap image
	cv.ShowImage(window1, pImg) ; Display input image inside window

	; Create destination images
	pimgGrayScale := cv.CreateImage(cv.GetSize(pImg, width, height), 8, 1)
	pimgSmall := cv.CreateImage(cv.Size(Round(width / scale), Round(height/scale)), 8, 1)

	; Convert the original image into grayscale, then resize and equalize...
	cv.CvtColor(pImg, pimgGrayScale, cv.Constants.BGR2GRAY)
	cv.Resize(pimgGrayScale, pimgSmall, cv.Constants.INTER_LINEAR)
	cv.EqualizeHist(pimgSmall, pimgSmall)

	; Setup memory block for sequence storage - Storage area for all contours
	pStorage := cv.CreateMemStorage(0)

	; Detect features using HAAR Cascades store as CvSeq
	objects := cv.HaarDetectObjects(pimgSmall, cascade, pStorage, 1.1, 8, 0, cv.Size(30, 30))

	; Draw rectangles around detected features
	totalObjects := NumGet(objects + 0, 8 + A_PtrSize * 4, "int")
	Loop % totalObjects {
	   r := cv.GetSeqElem(objects, A_Index)
	   x := NumGet(r+0, 0, "int") * scale
	   y := NumGet(r+0, 4, "int") * scale
	   w := NumGet(r+0, 8, "int") * scale
	   h := NumGet(r+0, 12, "int") * scale
	   cv.Rectangle(pImg, cv.Point(x, y), cv.Point(x+w, y+h), cv.RGB(255, 0, 0), 2, 8, 0)

	   ; Update input image inside the window
	   cv.ShowImage(window1, pImg)
	}
	ListVars
	; Release memory stuff
	cv.ReleaseImage(pimgSmall)
	cv.ReleaseImage(pimgGrayScale)
	cv.ReleaseImage(pImg)
	; cv.DestroyAllWindows()
	cv.ClearMemStorage(pStorage)
	cv.ClearSeq(objects)
}

GetWindowInfo(WinTitle) {
	; DetectHiddenWindows, On
	hwnd := WinExist(WinTitle)
	WinGetPos, X, Y, Width, Height, A
	; DetectHiddenWindows, Off
	return { x: X, y: Y, w: Width, h: Height, hWnd: hwnd }
}

__Init() {
	static vAutoExecDummyVar := Example()
}

#If WinActive("ahk_exe notepad++.exe")
^R:: Reload
#If
~ESC:: ExitApp