/*
class: DISPPARAMS
a structure class that contains the arguments passed to a method or property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/DISPPARAMS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221416)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Other classes - CCFramework
*/
class DISPPARAMS extends StructBase
{
	/*
	Field: rgvarg
	An array of arguments.

	Remarks:
		You can set this either to
			- an AHK-array of values in any form. To set their types, use ComObjParameter() and add the result to the array. The array may also include VARIANTARG wrapper objects.
			- ... or a raw memory pointer to the array
		When retrieved from an instance created using <FromStructPtr()>, this is always an AHK-array of wrapper objects.
	*/
	rgvarg := 0

	/*
	Field: rgdispidNamedArgs
	The dispatch IDs of the named arguments.

	Remarks:
		You can set this either to
			- an AHK-array containing the DISPIDs. For some special cases, you might use the DISPID class for convenience.
			- ... or a raw memory pointer to the array
		When retrieved from an instance created using <FromStructPtr()>, this is always an AHK-array containing the DISPIDs.
	*/
	rgdispidNamedArgs := 0

	/*
	Field: cArgs
	The number of arguments in the <rgvarg> array.

	Remarks:
		If you set <rgvarg> to an AHK-array, you may also leave this field unchanged. In this case, the member count of the array is used.
	*/
	cArgs := -1

	/*
	Field: cNamedArgs
	The number of named arguments in the <rgdispidNamedArgs> array.

	Remarks:
		If you set <rgdispidNamedArgs> to an AHK-array, you may also leave this field unchanged. In this case, the member count of the array is used.
	*/
	cNamedArgs := -1

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
		local arg_array, named_array, arg_count, named_count, variant
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		if (IsObject(this.rgvarg))
		{
			arg_count := this.cArgs == -1 ? this.rgvarg.maxIndex() : this.cArgs, arg_array := this.Allocate(arg_count * 16)
			Loop arg_count
				CCFramework.CopyMemory(variant := CCFramework.CreateVARIANTARG(this.rgvarg[A_Index]).ref, arg_array + (A_Index - 1) * 16, 16)
				, CCFramework.FreeMemory(variant) ; copy VARIANT to memory and free its memory again
		}
		else
			arg_array := this.rgvarg, arg_count := this.cArgs

		if (IsObject(this.rgdispidNamedArgs))
		{
			named_count := this.cNamedArgs == -1 ? this.rgdispidNamedArgs.maxIndex() : this.cNamedArgs, named_array := this.Allocate(named_count * 16)
			Loop named_count
				NumPut(this.rgdispidNamedArgs[A_Index], 1 * named_array, (A_Index - 1) * 4, "UInt")
		}
		else
			named_array := this.rgdispidNamedArgs, named_count := this.cNamedArgs

		NumPut(arg_array, 1*ptr, 00, "Ptr")
		NumPut(named_array, 1*ptr, A_PtrSize, "Ptr")
		NumPut(arg_count, 1*ptr, 2 * A_PtrSize, "UInt")
		NumPut(named_count, 1*ptr, 2 * A_PtrSize + 4, "UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		PTR ptr - a pointer to a DISPPARAMS struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		DISPPARAMS instance - the new DISPPARAMS instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new DISPPARAMS(), arg_array := [], named_array := [], arg_ptr, named_ptr
		instance.SetOriginalPointer(ptr, own)

		instance.cArg := NumGet(1*ptr, 2 * A_PtrSize, "UInt")
		instance.cNamedArgs := NumGet(1*ptr, 2 * A_PtrSize + 4, "UInt")

		arg_ptr := NumGet(1*ptr, 00, "Ptr")
		Loop instance.cArgs
			arg_array.Insert(CCFramework.BuildVARIANTARG(arg_ptr + (A_Index - 1) * 16))

		named_ptr := NumGet(1*ptr, A_PtrSize, "Ptr")
		Loop instance.cNamedArgs
			named_array.Insert(NumGet(1*named_ptr, (A_Index - 1) * 4, "UInt"))

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
		return 8 + 2 * A_PtrSize
	}
}