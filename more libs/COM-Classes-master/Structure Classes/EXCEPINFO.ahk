/*
class: EXCEPINFO
a structure class that describes an exception that occurred during IDispatch::Invoke.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/EXCEPINFO)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221133)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
*/
class EXCEPINFO extends StructBase
{
	/*
	Field: wCode
	The error code. Error codes should be greater than 1000. Either this field or the <scode> field must be filled in; the other must be set to 0.
	*/
	wCode := 0

	/*
	Field: wReserved
	Reserved. Should be 0.
	*/
	wReserved := 0

	/*
	Field: bstrSource
	The name of the exception source. Typically, this is an application name. This field should be filled in by the implementor of IDispatch.
	*/
	bstrSource := ""

	/*
	Field: bstrDescription
	The exception description to display. If no description is available, use null.
	*/
	bstrDescription := ""

	/*
	Field: bstrHelpFile
	The fully-qualified help file path. If no Help is available, use null.
	*/
	bstrHelpFile := ""

	/*
	Field: dwHelpContext
	The help context ID.
	*/
	dwHelpContext := 0

	/*
	Field: pvReserved
	Reserved. Must be null.
	*/
	pvReserved := 0

	/*
	Field: pfnDeferredFillIn
	Provides deferred fill-in. If deferred fill-in is not desired, this field should be set to null.
	*/
	pfnDeferredFillIn := 0

	/*
	Field: scode
	A return value that describes the error. Either this field or <wCode> (but not both) must be filled in; the other must be set to 0. (16-bit Windows versions only.)
	*/
	scode := 0

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

		NumPut(this.wCode,							1*ptr,	00+0*A_PtrSize,	"Short")
		NumPut(this.wReserved,						1*ptr,	02+0*A_PtrSize,	"Short")
		NumPut(this.GetAdress("bstrSource"),		1*ptr,	04+0*A_PtrSize,	"UPtr")
		NumPut(this.GetAdress("bstrDescription"),	1*ptr,	04+1*A_PtrSize,	"UPtr")
		NumPut(this.GetAdress("bstrHelpFile"),		1*ptr,	04+2*A_PtrSize,	"UPtr")
		NumPut(this.dwHelpContext,					1*ptr,	04+3*A_PtrSize,	"UInt")
		NumPut(this.pvReserved,						1*ptr,	08+3*A_PtrSize,	"UPtr")
		NumPut(this.pfnDeferredFillIn,				1*ptr,	08+4*A_PtrSize,	"UPtr")
		NumPut(this.scode,							1*ptr,	08+5*A_PtrSize,	"Int")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a EXCEPINFO struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		EXCEPINFO instance - the new EXCEPINFO instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new EXCEPINFO()
		instance.SetOriginalPointer(ptr, own)

		instance.wCode				:= NumGet(1*ptr,	00+0*A_PtrSize,	"Short")
		instance.wReserved			:= NumGet(1*ptr,	02+0*A_PtrSize,	"Short")
		instance.bstrSource			:= StrGet(NumGet(1*ptr,	04+0*A_PtrSize,	"UPtr"))
		instance.bstrDescription	:= StrGet(NumGet(1*ptr,	04+1*A_PtrSize,	"UPtr"))
		instance.bstrHelpFile		:= StrGet(NumGet(1*ptr,	04+2*A_PtrSize,	"UPtr"))
		instance.dwHelpContext		:= NumGet(1*ptr,	04+3*A_PtrSize,	"UInt")
		instance.pvReserved			:= NumGet(1*ptr,	08+3*A_PtrSize,	"UPtr")
		instance.pfnDeferredFillIn	:= NumGet(1*ptr,	08+4*A_PtrSize,	"UPtr")
		instance.scode				:= NumGet(1*ptr,	08+5*A_PtrSize,	"Int")

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
		return 12 + 5 * A_PtrSize
	}
}