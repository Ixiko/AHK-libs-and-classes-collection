/*
class: PARAMDATA
a structure class that describes a parameter accepted by a method or property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PARAMDATA)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221100)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - VARENUM
*/
class PARAMDATA extends StructBase
{
	/*
	Field: szName
	The parameter name. Names should follow standard conventions for programming language access; that is, no embedded spaces or control characters, and 32 or fewer characters.
	*/
	szName := ""

	/*
	Field: vt
	The parameter type. You may use the fields of the VARENUM class for convenience. If more than one parameter type is accepted, VARENUM.VARIANT should be specified.
	*/
	vt := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] STR name - the initial value for the <szName> field.
		[opt] USHORT vt - the initial value for the <vt> field.
	*/
	__New(name := "", vt := 0)
	{
		this.szName := name, this.vt := vt
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

		NumPut(this.GetAdress("szName"),	1*ptr,	00, "UPtr")
		NumPut(this.vt,						1*ptr,	A_PtrSize,	"UShort")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		UPTR ptr - a pointer to a PARAMDATA struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		PARAMDATA instance - the new PARAMDATA instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new PARAMDATA(StrGet(NumGet(1*ptr, 00, "UPtr")), NumGet(1*ptr, A_PtrSize,	"UShort"))
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