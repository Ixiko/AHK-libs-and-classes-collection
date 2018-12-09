/*
class: FILETIME
a structure class that contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/FILETIME)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms724284)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
*/
class FILETIME extends StructBase
{
	/*
	Field: dwLowDateTime
	The low-order part of the file time.
	*/
	dwLowDateTime := 0

	/*
	Field: dwHighDateTime
	The high-order part of the file time.
	*/
	dwHighDateTime := 0

	/*
	Method: Constructor

	Parameters:
		[opt] UINT low - the initial value for the dwLowDateTime field.
		[opt] UINT high - the initial value for the dwHighDateTime field.
	*/
	__New(low := 0, high := 0)
	{
		this.dwLowDateTime := low, this.dwHighDateTime := high
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

		NumPut(this.dwLowDateTime,	1*ptr,	0,	"UInt")
		NumPut(this.dwHighDateTime,	1*ptr,	4,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a FILETIME struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		FILETIME instance - the new FILETIME instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new FILETIME(NumGet(1*ptr, 00, "UInt"), NumGet(1*ptr, 04, "UInt"))
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

	/*
	Method: FromSYSTEMTIME
	(static) method that converts a SYSTEMTIME instance to a FILETIME instance

	Parameters:
		SYSTEMTIME src - the SYSTEMTIME instance to convert

	Returns:
		FILETIME instance - the new FILETIME instance
	*/
	FromSYSTEMTIME(src)
	{
		local dest, src_mem
		if (IsObject(src))
			VarSetCapacity(src_mem, SYSTEMTIME.GetRequiredSize(), 00), src := src.ToStructPtr(&src_mem)
		VarSetCapacity(dest, 8, 0), DllCall("SystemTimeToFileTime", "ptr", src, "ptr", &dest)
		return FILETIME.FromStructPtr(&dest)
	}
}