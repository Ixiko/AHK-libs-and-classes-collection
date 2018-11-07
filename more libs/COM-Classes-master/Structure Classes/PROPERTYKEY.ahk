/*
class: PROPERTYKEY
a structure class that programmatically identifies a property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PROPERTYKEY)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb773381)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, StructBase
	Other classes - CCFramework
*/
class PROPERTYKEY extends StructBase
{
	/*
	Field: fmtid
	A unique GUID for the property.

	Remarks:
		When retrieved from an instance created by <FromStructPtr()>, this is a GUID string.
		Otherwise, you may either set it to a string or a raw memory pointer to the GUID.
	*/
	fmtid := ""

	/*
	Field: pid
	A property identifier (PID). Any value greater than or equal to 2 (default) is acceptable.
	*/
	pid := 2

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

		if !CCFramework.isInteger(this.fmtid)
			CCFramework.String2GUID(this.fmtid, ptr)
		else
			CCFramework.CopyMemory(this.fmtid, ptr, 16)

		NumPut(this.pid,	1*ptr,	16,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a PROPERTYKEY struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		PROPERTYKEY instance - the new PROPERTYKEY instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new PROPERTYKEY()
		instance.SetOriginalPointer(ptr, own)

		instance.fmtid	:= CCFramework.GUID2String(ptr)
		instance.pid	:= NumGet(1*ptr,	16,	"UInt")

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
		return 20
	}
}