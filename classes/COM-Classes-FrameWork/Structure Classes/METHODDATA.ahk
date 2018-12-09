/*
class: METHODDATA
a structure class that describes a method or property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/METHODDATA)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221359)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - VARENUM, DISPID, MEMBERID, CALLCONV, DISPATCHF
	Structure classes - PARAMDATA
*/
class METHODDATA extends StructBase
{
	/*
	Field: szName
	The method name.
	*/
	szName := ""

	/*
	Field: ppdata
	An array of PARAMDATA structs representing method parameters.
	*/
	ppdata := 0

	/*
	Field: dispid
	The ID of the method, as used in IDispatch.
	*/
	dispid := -1

	/*
	Field: iMeth
	The index of the method in the VTBL of the interface, starting with 0.
	*/
	iMeth := -1

	/*
	Field: cc
	The calling convention. The CDECL and Pascal calling conventions are supported by the dispatch interface creation functions, such as CreateStdDispatch.
	*/
	cc := -1

	/*
	Field: cArgs
	The number of arguments.
	*/
	cArgs := 0

	/*
	Field: wFlags
	Invoke flags. You may use the fields of the DISPATCHF class for convenience.
	*/
	wFlags := 0

	/*
	Field: vtRturn
	The return type for the method.
	*/
	vtRturn := 0

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

		NumPut(this.GetAdress("szName"),1*ptr,	00+0*A_PtrSize, "UPtr")
		NumPut(this.ppdata,				1*ptr,	00+1*A_PtrSize,	"UPtr")
		NumPut(this.dispid,				1*ptr,	00+2*A_PtrSize,	"Int")
		NumPut(this.iMeth,				1*ptr,	04+2*A_PtrSize,	"UInt")
		NumPut(this.cc,					1*ptr,	08+2*A_PtrSize,	"UInt")
		NumPut(this.cArgs,				1*ptr,	12+2*A_PtrSize,	"UInt")
		NumPut(this.wFlags,				1*ptr,	16+2*A_PtrSize,	"Short")
		NumPut(this.vtRturn,			1*ptr,	18+2*A_PtrSize,	"UShort")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class.

	Parameters:
		UPTR ptr - a pointer to a METHODDATA struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		METHODDATA instance - the new METHODDATA instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new METHODDATA()
		instance.SetOriginalPointer(ptr, own)

		instance.szName := StrGet(NumGet(1*ptr,	00+0*A_PtrSize,	"UPtr"))
		instance.ppdata	:= NumGet(1*ptr,	00+1*A_PtrSize,	"UPtr")
		instance.dispid	:= NumGet(1*ptr,	04+2*A_PtrSize,	"Int")
		instance.iMeth	:= NumGet(1*ptr,	04+2*A_PtrSize,	"UInt")
		instance.cc		:= NumGet(1*ptr,	08+2*A_PtrSize,	"UInt")
		instance.cArgs	:= NumGet(1*ptr,	12+2*A_PtrSize,	"UInt")
		instance.wFlags	:= NumGet(1*ptr,	16+2*A_PtrSize,	"Short")
		instance.vtRturn:= NumGet(1*ptr,	18+2*A_PtrSize,	"UShort")

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
		return 20 + 2*A_PtrSize
	}
}