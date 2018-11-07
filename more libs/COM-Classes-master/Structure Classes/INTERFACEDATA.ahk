/*
class: INTERFACEDATA
a structure class that describes an object's properties and methods.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/INTERFACEDATA)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221164)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Structure classes - METHODDATA
*/
class INTERFACEDATA extends StructBase
{
	/*
	Field: pmethdata
	An array of METHODDATA structures.
	*/
	pmethdata := 0

	/*
	Field: cMembers
	The count of members.
	*/
	cMembers := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		METHODDATA[] methods - the initial value for the <pmethdata> field.
		UINT count - the initial value for the <cMembers> field.
	*/
	__New(methods := 0, count := 0)
	{
		this.pmethdata := 0, this.cMembers := count
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

		NumPut(this.pmethdata,			1*ptr,	00+0*A_PtrSize, "UPtr")
		NumPut(this.cMembers,			1*ptr,	00+1*A_PtrSize,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		UPTR ptr - a pointer to a INTERFACEDATA struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		INTERFACEDATA instance - the new INTERFACEDATA instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new INTERFACEDATA(NumGet(1*ptr,	00,	"UPtr"), NumGet(1*ptr,	A_PtrSize,	"UInt"))
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
		return A_PtrSize + 4
	}
}