/*
class: IMAGELISTSTATS
a structure class that contains image list statistics. Used by IImageList2::GetStatistics.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/IMAGELISTSTATS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761397)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, StructBase
*/
class IMAGELISTSTATS extends StructBase
{
	/*
	Field: cbSize
	The image list size.
	*/
	cbSize := 0

	/*
	Field: cAlloc
	The number of images allocated.
	*/
	cAlloc := 0

	/*
	Field: cUsed
	The number of images in use.
	*/
	cUsed := 0

	/*
	Field: cStandby
	The number of standby images.
	*/
	cStandby := 0

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

		NumPut(this.cbSize,		1*ptr,	00,	"UInt")
		NumPut(this.cAlloc,		1*ptr,	04,	"Int")
		NumPut(this.cUsed,		1*ptr,	08,	"Int")
		NumPut(this.cStandby,	1*ptr,	12,	"Int")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a IMAGELISTSTATS struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		IMAGELISTSTATS instance - the new IMAGELISTSTATS instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new IMAGELISTSTATS()
		instance.SetOriginalPointer(ptr, own)

		instance.cbSize 	:= NumGet(1*ptr,	00,	"UInt")
		instance.cAlloc		:= NumGet(1*ptr,	04,	"Int")
		instance.cUsed		:= NumGet(1*ptr,	08,	"Int")
		instance.cStandby	:= NumGet(1*ptr,	12,	"Int")

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
		return 16
	}
}