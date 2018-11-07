/*
class: IDLDESC
a structure class that is used for holding information needed for transferring a structure element, parameter, or function return value between processes.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/IDLDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/aa909796.aspx, originally intended for Windows Mobile)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - IDLFLAG
*/
class IDLDESC extends StructBase
{
	/*
	Field: dwReserved
	Reserved; set to NULL.
	*/
	dwReserved := 0

	/*
	Field: wIDLFlags
	Specifies flags from the IDLFLAG class.
	*/
	wIDLFlags := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] UINT reserved - the initial value for the <dwReserved> field.
		[opt] USHORT flag - the initial value for the <wIDLFlags> field.
	*/
	__New(reserved := 0, flag := 0)
	{
		this.dwReserved := reserved, this.wIDLFlags := flag
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

		NumPut(this.dwReserved,		1*ptr,	00,	"Ptr")
		NumPut(this.wIDLFlags,		1*ptr,	A_PtrSize,	"UShort")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		UPTR ptr - a pointer to a IDLDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		IDLDESC instance - the new IDLDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new IDLDESC(NumGet(1*ptr,	A_PtrSize,	"Ptr"), NumGet(1*ptr,	04,	"UShort"))
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
		return A_PtrSize + 2
	}
}