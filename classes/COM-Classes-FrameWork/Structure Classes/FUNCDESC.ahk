/*
class: FUNCDESC
a structure class that describes a function.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/FUNCDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221425)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - DISPID, MEMBERID, FUNCKIND, INVOKEKIND, CALLCONV, FUNCFLAGS
	Structure classes - ELEMDESC
*/
class FUNCDESC extends StructBase
{
	/*
	Field: memid
	The function member ID. For some special values you might use the fields in the MEMBERID enum class.
	*/
	memid := 0

	/*
	Field: lprgscode
	An array of possible return values.

	Remarks:
		You can set this field either to an AHK-array or a raw memory pointer to the array in memory.
		In case you set it to a pointer, set the <cScodes> field to the lenght (in items) of the array.
		Otherwise, you may leave <cScodes> unchanged (to use the entire array) or change it to use only a few values out of the array.

		When retrieved from an instance created <FromStructPtr>, this is always an AHK array.
	*/
	lprgscode := 0

	/*
	Field: lprgelemdescParam
	An array of ELEMDESC structures describing the parameters.

	Remarks:
		You can set this field either to an AHK-array or a raw memory pointer to the array in memory.
		In case you set it to a pointer, set the <cParams> field to the lenght (in items) of the array.
		Otherwise, you may leave <cParams> unchanged (to use the entire array) or change it to use only a few values out of the array.

		When retrieved from an instance created <FromStructPtr>, this is always an AHK array.
	*/
	lprgelemdescParam := 0

	/*
	Field: funckind
	Indicates the type of function (virtual, static, or dispatch-only). You might use the fields of the FUNCKIND class for convenience.
	*/
	funckind := 0

	/*
	Field: invkind
	The invocation type. Indicates whether this is a property function, and if so, which type. You might use the fields of the INVOKEKIND enum class for convenience.
	*/
	invkind := 0

	/*
	Field: callconv
	The calling convention. You might use the fields of the CALLCONV enum class for convenience.
	*/
	callconv := 0

	/*
	Field: cParams
	The total number of parameters.

	Remarks:
		This defines the size of the <lprgelemdescParam> array. If you set that member to an AHK array and you want to use all of its indexes, just leave this field unchanged.
	*/
	cParams := -1

	/*
	Field: cParamsOpt
	The number of optional parameters.
	*/
	cParamsOpt := 0

	/*
	Field: oVft
	if <funckind> is FUNCKIND.VIRTUAL, specifies the offset in the VTBL.
	*/
	oVft := 0

	/*
	Field: cScodes
	The number of possible return values.

	Remarks:
		This defines the size of the <lprgscode> array. If you set that member to an AHK array and you want to use all of its indexes, just leave this field unchanged.
	*/
	cScodes := -1

	/*
	Field: elemdescFunc
	An ELEMDESC structure specifying the function return type.
	*/
	elemdescFunc := 0

	/*
	Field: wFuncFlags
	The function flags. You might use the fields in the FUNCFLAG class for convenience.
	*/
	wFuncFlags := 0

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
		local mem1, mem2, val, error_count, param_count

		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		NumPut(this.memid, 1*ptr, 00, "UInt")

		if (IsObject(this.lprgscode))
		{
			error_count := this.cScodes == -1 ? this.lprgscode.maxIndex() : this.cScodes, mem1 := this.Allocate(4 * error_count)
			Loop error_count
				NumPut(this.lprgscode[A_Index], 1*mem1, (A_Index - 1) * 4, "UInt")
		}
		else
			mem1 := this.lprgscode
		NumPut(mem1, 1*ptr, 04, "Ptr")

		if (IsObject(this.lprgelemdescParam))
		{
			param_count := this.cParams == -1 ? this.lprgelemdescParam.maxIndex() : this.cParams, mem2 := this.Allocate(ed_size * param_count)
			Loop param_count
				this.lprgelemdescParam[A_Index].ToStructPtr(mem2 + (A_Index - 1) * ed_size)
		}
		else
			mem2 := this.lprgelemdescParam
		NumPut(mem2, 1*ptr, 04 + 1*A_PtrSize, "Ptr")

		, NumPut(this.funckind, 1*ptr, 04 + 2 * A_PtrSize, "UInt")
		, NumPut(this.invkind, 1*ptr, 08 + 2 * A_PtrSize, "UInt")
		, NumPut(this.callconv, 1*ptr, 12 + 2 * A_PtrSize, "UInt")
		, NumPut(param_count, 1*ptr, 16 + 2 * A_PtrSize, "Short")
		, NumPut(this.cParamsOpt, 1*ptr, 18 + 2 * A_PtrSize, "Short")
		, NumPut(this.oVft, 1*ptr, 20 + 2 * A_PtrSize, "Short")
		, NumPut(error_count, 1*ptr, 22 + 2 * A_PtrSize, "Short")
		, IsObject(this.elemdescFunc) ? this.elemdescFunc.ToStructPtr(ptr + 24 + 2 * A_PtrSize) : CCFramework.CopyMemory(this.elemdescFunc, ptr + 24 + 2 * A_PtrSize, ed_size)
		, NumPut(this.wFuncFlags, 1*ptr, 24 + 2 * A_PtrSize + ed_size, "Short")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a FUNCDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		FUNCDESC instance - the new FUNCDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		static ed_size := ELEMDESC.GetRequiredSize()
		local arr_ptr

		local instance := new FUNCDESC()
		instance.SetOriginalPointer(ptr, own)

		instance.memid := NumGet(1*ptr, 00, "UInt")
		, instance.funckind := NumGet(1*ptr, 04 + 2 * A_PtrSize, "UInt")
		, instance.invkind := NumGet(1*ptr, 08 + 2 * A_PtrSize, "UInt")
		, instance.callconv := NumGet(1*ptr, 12 + 2 * A_PtrSize, "UInt")
		, instance.cParams := NumGet(1*ptr, 16 + 2 * A_PtrSize, "Short")
		, instance.cParamsOpt := NumGet(1*ptr, 18 + 2 * A_PtrSize, "Short")
		, instance.oVft := NumGet(1*ptr, 20 + 2 * A_PtrSize, "Short")
		, instance.cScodes := NumGet(1*ptr, 22 + 2 * A_PtrSize, "Short")
		, instance.elemdescFunc := ELEMDESC.FromStructPtr(ptr + 24 + 2 * A_PtrSize, false)
		, instance.wFuncFlags := NumGet(1*ptr, 24 + 2 * A_PtrSize + ed_size, "Short")

		instance.lprgscode := [], arr_ptr := NumGet(1*ptr, 04, "Ptr")
		Loop instance.cScodes
			instance.lprgscode.Insert(NumGet(1*arr_ptr, (A_Index - 1) * 4, "UInt"))

		instance.lprgelemdescParam := [], arr_ptr := NumGet(1*ptr, 04 + A_PtrSize, "Ptr")
		Loop instance.cParams
			instance.lprgelemdescParam.Insert(ELEMDESC.FromStructPtr(arr_ptr + (A_Index - 1) * ed_size, false))

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
		return 26 + 2 * A_PtrSize + ELEMDESC.GetRequiredSize()
	}
}