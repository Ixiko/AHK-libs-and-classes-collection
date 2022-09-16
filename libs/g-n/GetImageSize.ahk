; Title:   	AutoGuiSwitch/AutoGuiSwitch.ahk at main · tthreeoh/AutoGuiSwitch
; Link:     	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

GetImageSize(imageFilePath) {
	   if !hBitmap := LoadPicture(imageFilePath, "GDI+")
	      throw "Failed to load the image"
		   VarSetCapacity(BITMAP, size := 4*4 + A_PtrSize*2, 0)
		   DllCall("GetObject", "Ptr", hBitmap, "Int", size, "Ptr", &BITMAP)
		   DllCall("DeleteObject", "Ptr", hBitmap)
		   Return { W: NumGet(BITMAP, 4, "UInt"), H: NumGet(BITMAP, 8, "UInt") }
		}