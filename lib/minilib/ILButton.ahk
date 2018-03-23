/*
	Function:	ILButton
				Creates an ImageList and associates it with a button.
	
	Parameters:
		HBtn   - Handle of a buttton.
		Images - A pipe delimited list of images in form "FileName[:zeroBasedIndex]" or ImageList handle.
				 Any position can be omitted in which case icon for state "normal" is used.
		Cx     - Width of the image in pixels. By default 16.
		Cy     - Height of the image in pixels. By default 16.
		Align  - One of the word: Left (default), Right, Top, Bottom, Center.
		Margin - Margin around the icon. A space separated list of four integers in form "left top right bottom".

	Images:
		- File must be of type exe, dll, ico, cur, ani or bmp.
		- There are 5 states: normal, hot (hover), pressed, disabled, defaulted (focused), stylushot.
		- If only one image is specified, it will be used for all the button's states
		- If fewer than six images are specified, nothing is drawn for the states without images
		- Omit "file" to use the last file specified ( "states.dll:0|:1|:2|:3|:4|:5" )
		- Omitting an index is the same as specifying 0.
	
	Returns:
		Handle of the ImageList if operation was completed or 0 otherwise.
	
	Remarks:
		Within Aero theme (WinOS >= Vista), a defaulted (focused) button fades between images 5 and 6.
		Each succesifull call to this function creates new ImageList. If you are calling this function
		more times for single button control, freeing previous ImageList is your responsibility.

	About:
		- Version 1.0 by majkinetor.
		- Original code by tkoi. See <http://www.autohotkey.com/forum/viewtopic.php?p=247168>
		- Minimum operating systems: Windows XP.
		- Licensed under GNU GPLv3 <http://www.opensource.org/licenses/gpl-3.0.html>
*/

ILButton(HBtn, Images, Cx=16, Cy=16, Align="Left", Margin="1 1 1 1") {
	static BCM_SETIMAGELIST=0x1602, a_left=0, a_right=1, a_top=2, a_bottom=3, a_center=4

	if Images is not integer
	{
		hIL := DllCall("ImageList_Create", "UInt", Cx, "UInt",Cy, "UInt", 0x20, "UInt", 1, "UInt", 6)
		Loop, Parse, Images, |, %A_Space%%A_Tab%
		{
			if (A_LoopField = "") {
				DllCall("ImageList_AddIcon", "UInt", hIL, "UInt", I)
				continue
			}

			if (k := InStr(A_LoopField, ":", 0, 0)) && ( k!=2 )
				 v1 := SubStr(A_LoopField, 1, k-1), v2 := SubStr(A_LoopField, k+1)
			else v1 := A_LoopField, v2 := 0

			ifEqual, v1,,SetEnv,v1, %prevFileName%
			else prevFileName := v1
			
			if SubStr(v1, -3) = ".bmp"
			{
				hBmp := DllCall("LoadImage", "UInt", 0, "Str", v1, "UInt", 0, "Int", Cx, "Int", Cy, "UInt", 0x10 , "UInt") ; 0x10=LR_LOADFROMFILE
				DllCall("ImageList_Add", "UInt", hIL, "UInt", hBmp)
				ifEqual, A_Index, 1, SetEnv, B, %hBmp%
				else DllCall("DestroyIcon", "UInt", hBmp)
			} else {	;although privateextract loads bmps too it shows black dot in top left corner ...
				DllCall("PrivateExtractIcons", "Str", v1, "UInt", v2, "UInt", Cx, "UInt", Cy, "UIntP", hIcon, "UInt",0, "UInt", 1, "UInt", 0x20) ; LR_LOADTRANSPARENT = 0x20
				DllCall("ImageList_AddIcon", "UInt",hIL, "UInt",hIcon)
				ifEqual, A_Index, 1, SetEnv, I, %hIcon%
				else DllCall("DestroyIcon", "UInt", hIcon)
			}
		}
		r := I ? DllCall("DestroyIcon", "UInt", I) : DllCall("DeleteObject", "UInt", B)
	} else hIL := Images

	VarSetCapacity(BIL, 24), NumPut(hIL, BIL), NumPut(a_%Align%, BIL, 20)
	Loop, Parse, Margin, %A_Space%
		NumPut(A_LoopField, BIL, A_Index * 4)

	SendMessage, BCM_SETIMAGELIST,,&BIL,, ahk_id %HBtn%
	ifEqual, ErrorLevel, 0, return 0, DllCall("ImageList_Destroy", "Uint", hIL)
	return hIL
}

/* --
 Function:  Image
			Adds image to the Button control.

 Parameters:
			HButton	- Handle to the button.
			Image	- Path to the .BMP file or image handle. First pixel signifies transparency color.
			Width	- Width of the image, if omitted, current control width will be used.
			Height	- Height of the image, if omitted, current control height will be used.

 Returns:
			Bitmap handle. 
 */
/*	OUTDATED BUT COULD BE USED IN WIN2K IF NEEDED.
Image(HButton, Image, Width="", Height=""){ 
    static BM_SETIMAGE=247, IMAGE_ICON=2, BS_BITMAP=0x80, IMAGE_BITMAP=0, LR_LOADFROMFILE=16, LR_LOADTRANSPARENT=0x20

	if (Width = "" || Height = "") {
		ControlGetPos, , ,W,H, ,ahk_id %hButton%
		ifEqual, Width,, SetEnv, Width, % W-8
		ifEqual, Height,,SetEnv, Height, % H-8
	}

	if Image is not integer 
	{
		if (!hBitmap := DllCall("LoadImage", "UInt", 0, "Str", Image, "UInt", 0, "Int", Width, "Int", Height, "UInt", LR_LOADFROMFILE | LR_LOADTRANSPARENT, "UInt"))
			return 0
	} else hBitmap := Image 
    
    WinSet, Style, +%BS_BITMAP%, ahk_id %hButton% 
    SendMessage, BM_SETIMAGE, IMAGE_BITMAP, hBitmap, , ahk_id %hButton%
	return hBitmap
}
*/