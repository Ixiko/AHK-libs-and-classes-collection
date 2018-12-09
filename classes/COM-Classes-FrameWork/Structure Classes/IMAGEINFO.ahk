/*
class: IMAGEINFO
a structure class that contains information about an image in an image list. This structure is used with IImageList::GetImageInfo.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/IMAGEINFO)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761393)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
	Structure classes - RECT
*/
class IMAGEINFO extends StructBase
{
	/*
	Field: 	hbmImage
	A handle to the bitmap that contains the images. 
	*/
	hbmImage := 0

	/*
	Field: hbmMask
	A handle to a monochrome bitmap that contains the masks for the images. If the image list does not contain a mask, this member is 0.
	*/
	hbmMask := 0

	/*
	Field: Unused1
	Not used. This member should always be zero. 
	*/
	Unused1 := 0

	/*
	Field: Unused2
    Not used. This member should always be zero.
	*/
	Unused2 := 0

	/*
	Field: rcImage
    The bounding rectangle of the specified image within the bitmap specified by hbmImage.

	Remarks:
		- This should be a RECT instance.
	*/
	rcImage := new RECT()

	/*
	Method: Constructor
	creates a new instance of the class

	Parameters:
		[opt] HBITMAP hbmImage - the initial value of the <hbmImage> field
		[opt] HBITMAP hbmMask - the initial value of the <hbmMask> field
		[opt] RECT rcImage - the initial value of the <rcImage> field
	*/
	__New(hbmImage := 0, hbmMask := 0, rcImage  := 0)
	{
		this.hbmImage := hbmImage, this.hbmMask := hbmMask, this.rcImage := rcImage
	}

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] UPTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.hbmImage,		1*ptr,		00+0*A_PtrSize,	"UPtr")
		NumPut(this.hbmMask,		1*ptr,		00+1*A_PtrSize,	"UPtr")
		NumPut(this.Unused1,		1*ptr,		00+2*A_PtrSize,	"Int")
		NumPut(this.Unused2,		1*ptr,		04+2*A_PtrSize,	"Int")
		this.rcImage.ToStructPtr(ptr + 08 + 2*A_PtrSize)

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a IMAGEINFO struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		IMAGEINFO instance - the new IMAGEINFO instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new IMAGEINFO(NumGet(1*ptr,	00+0*A_PtrSize, "UPtr")
						,	NumGet(1*ptr,		00+1*A_PtrSize, "UPtr")
						,	RECT.FromStructPtr(ptr + 08 + 2*A_PtrSize, false))
		instance.SetOriginalPointer(ptr, own)
		return instance
	}

	/*
	Method: GetRequiredSize
	calculates the size a memory instance of this class requires.

	Parameters:
		[opt] OBJECT data - an optional data object that may contain data for the calculation.

	Returns:
		UINT bytes - the number of bytes required

	Remarks:
		- This may be called as if it was a static method.
		- The data object is ignored by this class.
	*/
	GetRequiredSize(data := "")
	{
		return 8 + 2 * A_PtrSize + RECT.GetRequiredSize()
	}
}