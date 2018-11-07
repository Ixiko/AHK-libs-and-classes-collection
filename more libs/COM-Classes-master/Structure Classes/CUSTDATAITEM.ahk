/*
class: CUSTDATAITEM
a structure class that represents a custom data item.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/CUSTDATAITEM)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221695)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Other classes - CCFramework
*/
class CUSTDATAITEM extends StructBase
{
	/*
	Field: guid
    The unique identifier of the data item.

	Remarks:
		When retrieved from an instance created by <FromStructPtr()>, this is a GUID string.
		Otherwise, you may either set it to a string or a raw memory pointer to the GUID.
	*/
	guid := 0

	/*
	Field: varValue
	The value of the data item (a VARIANTARG). You may set this to any type of value, e.g. a string, an integer, a (builtin) COM wrapper object, ...

	Remarks:
		- The type is calculated automatically. If you want it to have a special type (e.g. VT_UINT instead of VT_I4), change its type with ComObjParameter() and set this field to the returned wrapper object.
		- When you create an instance of this structure from a memory pointer, the field receives a VARIANT wrapper object as described in the docs about CCFramework.CreateVARIANT().
	*/
	varValue := 0

	/*
	Method: constructor
	creates a new instance of the class

	Parameters:
		[opt] GUID guid - the initial value for the <guid> field
		[opt] VAR value - the initial value for the <varValue> field
	*/
	__New(guid := 0, value := 0)
	{
		this.guid := guid, this.varValue := value
	}

	/*
	Method: ToStructPtr
	converts the instance to a script-usable struct and returns its memory adress.

	Parameters:
		[opt] PTR ptr - the fixed memory address to copy the struct to.

	Returns:
		UPTR ptr - a pointer to the struct in memory
	*/
	ToStructPtr(ptr := 0)
	{
		local variant
		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		if !CCFramework.isInteger(this.guid)
			CCFramework.String2GUID(this.guid, ptr)
		else
			CCFramework.CopyMemory(this.guid, ptr, 16)

		; copy VARIANT to memory and free its memory again:
		CCFramework.CopyMemory(variant := CCFramework.CreateVARIANTARG(this.varValue).ref, ptr + 16, 16), CCFramework.FreeMemory(variant)

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a TYPEDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		TYPEDESC instance - the new TYPEDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new CUSTDATAITEM(CCFramework.GUID2String(ptr), CCFramework.BuildVARIANTARG(ptr+16))
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
		return 32
	}
}