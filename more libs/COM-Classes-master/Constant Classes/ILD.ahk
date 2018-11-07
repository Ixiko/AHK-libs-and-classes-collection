/*
class: ILD
an enumeration class containing flags passed to IImageList::Draw in the fStyle member of IMAGELISTDRAWPARAMS.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ILD)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775230)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
*/
class ILD
{
	/*
	Field: NORMAL
	Draws the image using the background color for the image list. If the background color is the CLR.NONE value, the image is drawn transparently using the mask.
	*/
	static NORMAL := 0x00000000

	/*
	Field: TRANSPARENT
	Draws the image transparently using the mask, regardless of the background color. This value has no effect if the image list does not contain a mask.
	*/
	static TRANSPARENT := 0x00000001

	/*
	Field: BLEND25
	Draws the image, blending 25 percent with the blend color specified by rgbFg. This value has no effect if the image list does not contain a mask.
	*/
	static BLEND25 := 0x00000002

	/*
	Field: FOCUS
	Same as <BLEND25>.
	*/
	static FOCUS := 0x00000002

	/*
	Field: BLEND50
	Draws the image, blending 50 percent with the blend color specified by rgbFg. This value has no effect if the image list does not contain a mask.
	*/
	static BLEND50 := 0x00000004

	/*
	Field: SELECTED
	Same as <BLEND50>.
	*/
	static SELECTED := 0x00000004

	/*
	Field: BLEND
	Same as <BLEND50>.
	*/
	static BLEND := 0x00000004

	/*
	Field: MASK
	Draws the mask.
	*/
	static MASK := 0x00000010

	/*
	Field: IMAGE
	If the overlay does not require a mask to be drawn, set this flag.
	*/
	static IMAGE := 0x00000020

	/*
	Field: ROP
	Draws the image using the raster operation code specified by the dwRop member.
	*/
	static ROP := 0x00000040

	/*
	Field: OVERLAYMASK
	To extract the overlay image from the fStyle member, use the logical AND to combine fStyle with the <OVERLAYMASK> value.
	*/
	static OVERLAYMASK := 0x00000F00

	/*
	Field: PRESERVEALPHA
	Preserves the alpha channel in the destination.
	*/
	static PRESERVEALPHA := 0x00001000

	/*
	Field: SCALE
	Causes the image to be scaled to cx, cy instead of being clipped.
	*/
	static SCALE := 0x00002000

	/*
	Field: DPISCALE
	Scales the image to the current dpi of the display.
	*/
	static DPISCALE := 0x00004000

	/*
	Field: ASYNC
	*Windows Vista and later.* Draw the image if it is available in the cache. Do not extract it automatically. The called draw method returns E_PENDING to the calling component, which should then take an alternative action, such as, provide another image and queue a background task to force the image to be loaded via ForceImagePresent (http://msdn.microsoft.com/en-us/library/bb761411.aspx) using the ILFIP.ALWAYS flag. The <ASYNC> flag then prevents the extraction operation from blocking the current thread and is especially important if a draw method is called from the user interface (UI) thread.
	*/
	static ASYNC := 0x00008000
}