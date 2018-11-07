/*
class: SAFEARRAYBOUND
a structure class that represents the bounds of one dimension of an array.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SAFEARRAYBOUND)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221167)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
*/
class SAFEARRAYBOUND extends StructBase
{
	/*
	Field: cElements
	The number of elements in the dimension.
	*/
	cElements := 0

	/*
	Field: lLbound
	The lower bound of the dimension.
	*/
	lLBound := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] UINT elements - the initial value for the <cElements> field
		[opt] INT bound - the initial value for the <lLBound> field
	*/
	__New(elements := 0, bound := 0)
	{
		this.cElements := elements, this.lLBound := bound
	}

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] PTR ptr - the fixed memory address to copy the struct to.

	Returns:
		PTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.cElements, 1*ptr, 00, "UInt"), NumPut(this.lLBound, 1*ptr, 04, "Int")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		PTR ptr - a pointer to a SAFEARRAYBOUND struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		SAFEARRAYBOUND instance - the new SAFEARRAYBOUND instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new SAFEARRAYBOUND(NumGet(1*ptr, 00, "UInt"), NumGet(1*ptr, 04, "UInt"))
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