/*
class: VARDESC
a structure class that describes a variable, constant, or data member.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/VARDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221391)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - MEMBERID, VARKIND, VARFLAGS
	Structure classes - ELEMDESC
	Other classes - CCFramework
*/
class VARDESC extends StructBase
{
	/*
	Field: memid
	the member ID. For some special values, you might use the fields in the MEMBERID class.
	*/
	memid := 0

	/*
	Field: lpstrSchema
	Reserved.
	*/
	lpstrSchema := ""

	/*
	Field: oInst
	If <varkind> is VARKIND.PERINSTANCE, the offset of this variable within the instance.
	*/
	oInst := -1

	/*
	Field: lpvarValue
	If <varkind> is VARKIND.CONST, the value of the constant.

	Remarks:
		You may set this to any "normal" AHK value, e.g. a number, a string, a COM wrapper object (no normal objects!), ...
		If you want it to have a special type, set this to the result of ComObjParameter().
		When retrieved from an instance created with <FromstructPtr()>, this is always a VARIANT wrapper object.
	*/
	lpvarValue := 0

	/*
	Field: elemdescVar
	An ELEMDESC structure (as class instance or pointer) containing the variable type.
	*/
	elemdescVar := new ELEMDESC()

	/*
	Field: wVarFlags
	The variable flags. You might use the VARFLAGS class for convenience.
	*/
	wVarFlags := 0

	/*
	Field: varkind
	The variable type. You might use the fields of the VARKIND class for convenience.
	*/
	varkind := -1

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
		static ed_size := ELEMDESC.GetRequiredSize()
		local variant

		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.memid, 1*ptr, 00, "UInt")
		; < A_PtrSize - 4 bytes padding >
		NumPut(this.lpstrSchema, 1*ptr, A_PtrSize, "Ptr")
		if (this.varkind == 0)
			NumPut(this.oInst, 1*ptr, 2 * A_PtrSize, "UInt")
		else if (this.varkind == 2)
			NumPut(variant := CCFramework.CreateVARIANT(this.lpvarValue).ref, 2 * A_PtrSize, "Ptr"), CCFramework.FreeMemory(variant)
		IsObject(this.elemdescVar) ? this.elemdescVar.ToStructPtr(ptr + 3 * A_PtrSize) : CCFramework.CopyMemory(this.elemdescVar, ptr + 3 * A_PtrSize, ed_size)
		NumPut(this.wVarFlags, 1*ptr, 3 * A_PtrSize + ed_size, "UShort")
		; < 2 bytes padding >
		NumPut(this.varkind, 1*ptr, 3 * A_PtrSize + ed_size + 4, "UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a VARDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		VARDESC instance - the new VARDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		static ed_size := ELEMDESC.GetRequiredSize()

		local instance := new VARDESC()
		instance.SetOriginalPointer(ptr, own)

		instance.memid := NumGet(1*ptr, 00, "UInt")
		; < A_PtrSize - 4 bytes padding >
		, instance.lpstrSchema := StrGet(NumGet(1*ptr, A_PtrSize, "Ptr"))
		, instance.varkind := NumGet(1*ptr, 3 * A_PtrSize + ed_size + 4, "UInt")
		if (instance.varkind == 0)
			instance.oInst := NumGet(1*ptr, 2 * A_PtrSize, "UInt")
		else if (instance.varkind == 2)
			instance.lpvarValue := CCFramework.BuildVARIANT(NumGet(1*ptr, 2 * A_PtrSize, "Ptr"))
		instance.elemdescVar := ELEMDESC.FromStructPtr(ptr + 3 * A_PtrSize, false)
		; < 2 bytes padding >
		, instance.wVarFlags := NumGet(1*ptr, 3 * A_PtrSize + ed_size, "UShort")

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
		return 12 + 2 * A_PtrSize + ELEMDESC.GetRequiredSize()
	}
}