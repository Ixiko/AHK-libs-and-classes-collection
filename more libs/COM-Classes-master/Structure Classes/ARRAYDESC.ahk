/*
class: ARRAYDESC
a structure class that specifies the dimensions of an array and the type of its elements.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ARRAYDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221226)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Structure classes - SAFEARRAYBOUND, TYPEDESC
*/
class ARRAYDESC extends StructBase
{
	/*
	Field: tdescElem
	a TYPEDESC describing the element type. You may set this either to a class instance or a raw memory pointer.

	Remarks:
		When retrieved from an instance created with <FromStructPtr()> this is always a class instance.
	*/
	tdescElem := 0

	/*
	Field: cDims
	The dimension count.

	Remarks:
		If you set <rgbounds> to an AHK-array, you may also leave this field unchanged. In this case, the value is assumed to be the member count of the array.
	*/
	cDims := -1

	/*
	Field: rgbounds
	A variable-length array containing one SAFEARRAYBOUND element for each dimension.

	Remarks:
		You may set this field to
		- ... an AHK-array containing SAFEARRAYBOUND class instances
		- ... an AHK-array containing raw pointers to SAFEARRAYBOUND strcutures (may also be mixed with above)
		- ... a raw memory pointer to the array
	*/
	rgbounds := 0

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
		static sab_size := SAFEARRAYBOUND.GetRequiredSize(), td_size := TYPEDESC.GetRequiredSize()
		local count

		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		if (IsObject(this.rgbounds))
		{
			Loop count := this.cDims == -1 ? this.rgbounds.maxIndex() : this.cDims
				IsObject(this.rgbounds[A_Index])
					? this.rgbounds[A_Index].ToStructPtr(ptr + td_size + 2 + (A_Index - 1) * sab_size)
					: CCFramework.CopyMemory(this.rgbounds[A_Index], ptr + td_size + 2 + (A_Index - 1) * sab_size, sab_size)
		}
		else
			count := this.cDims, CCFramework.CopyMemory(ptr + td_size + 2, count * sab_size)

		IsObject(this.tdescElem) ? this.tdescElem.ToStructPtr(ptr) : CCFramework.CopyMemory(this.tdescElem, ptr, td_size)
		NumPut(count, 1*ptr, td_size, "UShort")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		PTR ptr - a pointer to a ARRAYDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		ARRAYDESC instance - the new ARRAYDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		static td_size := TYPEDESC.GetRequiredSize(), sab_size := SAFEARRAYBOUND.GetRequiredSize()

		local instance := new ARRAYDESC()
		instance.SetOriginalPointer(ptr, own)

		instance.tdescElem := TYPEDESC.FromStructPtr(ptr, false)
		instance.cDims := NumGet(1*ptr, td_size, "UShort")

		instance.rgbounds := []
		Loop instance.cDims
			instance.rgbounds.Insert(SAFEARRAYBOUND.FromStructPtr(ptr + td_size + 2 + (A_Index - 1) * sab_size, false))

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
		- The data object may contain a field called "cDims" to set the number of dimensions in the array.
			If this is not present and the method is not called on an instance (in which case it would use the instance data), it is assumed to be 1.
	*/
	GetRequiredSize(data := "")
	{
		static td_size := TYPEDESC.GetRequiredSize(), sab_size := SAFEARRAYBOUND.GetRequiredSize()
		local count := IsObject(data) && data.HasKey("cDims")
			? data.cDims ; if cDims was passed: use this value
			: (this != ARRAYDESC) ; if not called as static method but on instance:
				? (this.cDims == -1) ; if user did not change original value:
					? IsObject(this.rgbounds) ; if we have an AHK-array of dimension bounds:
						? this.rgbounds.maxIndex() ; use its length
						: 1 ; if it is not an AHK-array but a pointer, use 1
					: this.cDims ; if cDims was changed by the user, use it
				: 1 ; if called as static method, use 1
		return td_size + 2 + count * sab_size
	}
}