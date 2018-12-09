/*
class: POINT
a structure class that defines the x- and y- coordinates of a point.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/LGPL-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/POINT)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd162805)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
*/
class POINT extends StructBase
{
	/*
	Field: x
	The x-coordinate of the point.
	*/
	x := 0

	/*
	Field: y
	The y-coordinate of the point.
	*/
	y := 0

	/*
	Method: Constructor
	creates a new instance of the POINT class

	Parameters:
		[opt] INT x - the initial value for the <x> field
		[opt] INT y - the initial value for the <y> field
	*/
	__New(x := 0, y := 0)
	{
		this.x := x, this.y := y
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

		NumPut(this.x,	1*ptr,	00,	"Int")
		NumPut(this.y,	1*ptr,	04,	"Int")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a POINT struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		POINT instance - the new POINT instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new POINT(NumGet(1*ptr, 00, "Int"), NumGet(1*ptr, 04, "Int"))
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
		return 8
	}
}