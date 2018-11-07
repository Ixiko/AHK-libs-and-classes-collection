/*
class: ELEMDESC
a structure class that contains the type description and process-transfer information for a variable, a function, or a function parameter.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ELEMDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221018)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Helper classes - TYPEDESC, PARAMDESC, IDLDESC
	Other classes - CCFramework
*/
class ELEMDESC extends StructBase
{
	/*
	Field: tdesc
	a TYPEDESC structure (as pointer or class instance) that describes the type of the element
	*/
	tdesc := 0

	/*
	Field: idldesc
	an IDLDESC structure containing information for remoting the element. This information is for backward compatibility.

	Remarks:
		- If this field is 0, it is ignored and <paramdesc> is put in memory. If you change this value, <paramdesc> is ignored instead.
		- When an instance was created using <FromStructPtr()>, both fields are attempted to be filled. This may result in garbage in one of them.
	*/
	idldesc := 0

	/*
	Field: paramdesc
	a PARAMDESC structure (as pointer or class instance) that contains the parameter information.

	Remarks:
		See the remarks on <idldesc>.
	*/
	paramdesc := 0

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
		static td_size := TYPEDESC.GetRequiredSize(), idl_size := IDLDESC.GetRequiredSize(), param_size := PARAMDESC.GetRequiredSize()
		local offset

		if (!ptr)
		{
			ptr := this.Allocate(this.GetRequiredSize())
		}

		IsObject(this.tdesc) ? this.tdesc.ToStructPtr(ptr) : CCFramework.CopyMemory(this.tdesc, ptr, td_size)
		; <A_PtrSize - 4 bytes padding>
		offset := td_size + A_PtrSize - 4
		if (!this.idldesc)
			IsObject(this.paramdesc) ? this.paramdesc.ToStructPtr(ptr + offset) : CCFramework.CopyMemory(this.paramdesc, ptr + offset, param_size)
		else
			IsObject(this.idldesc) ? this.idldesc.ToStructPtr(ptr + offset) : CCFramework.CopyMemory(this.idldesc, ptr + offset, idl_size)

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		PTR ptr - a pointer to a ELEMDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		ELEMDESC instance - the new ELEMDESC instance
	*/
	FromStructPtr(ptr, own := true)
	{
		static td_size := TYPEDESC.GetRequiredSize()
		local offset

		local instance := new ELEMDESC()
		instance.SetOriginalPointer(ptr, own)

		instance.tdesc := TYPEDESC.FromStructPtr(ptr, false)
		; <A_PtrSize - 4 bytes padding>
		, offset := td_size + A_PtrSize - 4
		, instance.idldesc := IDLDESC.FromStructPtr(ptr + offset, false)
		, instance.paramdesc := PARAMDESC.FromStructPtr(ptr + offset, false)

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
		static td_size := TYPEDESC.GetRequiredSize(), pd_size := PARAMDESC.GetRequiredSize(), padding := A_PtrSize - 4
		return td_size + padding + pd_size
	}
}