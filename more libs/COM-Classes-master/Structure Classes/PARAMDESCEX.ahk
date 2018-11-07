/*
class: PARAMDESCEX
a structure class that contains information about the default value of a parameter.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PARAMDESCEX)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221410)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Other classes - CCFramework
*/
class PARAMDESCEX extends StructBase
{
	/*
	Field: cBytes
	The size of the structure. This is calculated automatically.
	*/
	cBytes := this.GetRequiredSize()

	/*
	Field: varDefaultValue
	The default value of the parameter (a VARIANTARG). You may set this to any type of value, e.g. a string, an integer, a (builtin) COM wrapper object, ...

	Remarks:
		- The type is calculated automatically. If you want it to have a special type (e.g. VT_UINT instead of VT_I4), change its type with ComObjParameter() and set this field to the returned wrapper object.
		- When you create an instance of this structure from a memory pointer, the field receives a VARIANT wrapper object as described in the docs about CCFramework.CreateVARIANT().
	*/
	varDefaultValue := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] VAR val - the initial value of the <varDefaultValue> field.
	*/
	__New(val := 0)
	{
		this.varDefaultValue := val
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
		local variant
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.cBytes, 1*ptr, 00, "UInt")
		; <4 bytes padding>
		; copy VARIANT to memory and free its memory again:
		CCFramework.CopyMemory(variant := CCFramework.CreateVARIANTARG(this.varDefaultValue).ref, ptr + 8, 16), CCFramework.FreeMemory(variant)

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a PARAMDESCEX struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		PARAMDESCEX instance - the new PARAMDESCEX instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new PARAMDESCEX(CCFramework.BuildVARIANTARG(ptr + 8))
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
		return 24
	}
}