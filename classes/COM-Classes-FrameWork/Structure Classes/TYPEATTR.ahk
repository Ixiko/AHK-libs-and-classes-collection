/*
class: TYPEATTR
a structure class that contains attributes of an ITypeInfo.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TYPEATTR)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221003)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - DISPID, MEMBERID, TYPEKIND
	Structure classes - IDLDESC, TYPEDESC, ARRAYDESC
*/
class TYPEATTR extends StructBase
{
	/*
	Field: guid
	The GUID (string) of the TypeInfo

	Remarks:
		When retrieved from an instance created by <FromStructPtr()>, this is a GUID string.
		Otherwise, you may either set it to a string or a raw memory pointer to the GUID.
	*/
	guid := ""

	/*
	Field: lcid
	Locale of member names and doc strings
	*/
	lcid := 0

	/*
	Field: dwReserved
	Reserved.
	*/
	dwReserved := 0

	/*
	Field: memidConstructor
	ID of constructor, MEMBERID_NIL if none
	*/
	memidConstructor := 0

	/*
	Field: memidDestructor
	ID of destructor, MEMBERID_NIL if none
	*/
	memidDestructor := 0

	/*
	Field: lpstrSchema
	Reserved for future use
	*/
	lpstrSchema := ""

	/*
	Field: cbSizeInstance
	The size of an instance of this type.
	*/
	cbSizeInstance := 0

	/*
	Field: typekind
	The kind of type this TypeInfo describes
	*/
	typekind := 0

	/*
	Field: cFuncs
	Number of functions
	*/
	cFuncs := 0

	/*
	Field: cVars
	Number of variables/data members
	*/
	cVars := 0

	/*
	Field: cImplTypes
	Number of implemented interfaces
	*/
	cImplTypes := 0

	/*
	Field: cbSizeVft
	The size of this type's virtual func table
	*/
	cbSizeVft := 0

	/*
	Field: cbAlignment
	Byte alignment for an instance of this type
	*/
	cbAlignment := 0

	/*
	Field: wTypeFlags

	*/
	wTypeFlags := 0

	/*
	Field: wMajorVerNum
	Major version number
	*/
	wMajorVerNum := 0

	/*
	Field: wMinorVerNum
	Minor version number
	*/
	wMinorVerNum := 0

	/*
	Field: tdescAlias
	If typekind is TYPEKIND.ALIAS, specifies the type for which this type is an alias.
	*/
	tdescAlias := 0

	/*
	Field: idldescType
	IDL attributes of the described type
	*/
	idldescType := 0

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

		if !CCFramework.isInteger(this.guid)
			CCFramework.String2GUID(this.guid, ptr)
		else
			CCFramework.CopyMemory(this.guid, ptr, 16)

		NumPut(this.lcid,				1*ptr,	16+0*A_PtrSize,	"UInt")
		NumPut(this.dwReserved,			1*ptr,	20+0*A_PtrSize,	"UInt")
		NumPut(this.memidConstructor,	1*ptr,	24+0*A_PtrSize,	"Int")
		NumPut(this.memidDestructor,	1*ptr,	28+0*A_PtrSize,	"Int")
		NumPut(this.GetAdress("lpstrSchema"),	1*ptr,	32+0*A_PtrSize,	"UPtr")
		NumPut(this.cbSizeInstance,		1*ptr,	32+1*A_PtrSize,	"UInt")
		NumPut(this.typekind,			1*ptr,	36+1*A_PtrSize,	"UInt")
		NumPut(this.cFuncs,				1*ptr,	40+1*A_PtrSize,	"UShort")
		NumPut(this.cVars,				1*ptr,	42+1*A_PtrSize,	"UShort")
		NumPut(this.cImplTypes,			1*ptr,	44+1*A_PtrSize,	"UShort")
		NumPut(this.cbSizeVft,			1*ptr,	46+1*A_PtrSize,	"UShort")
		NumPut(this.cbAlignment,		1*ptr,	48+1*A_PtrSize,	"UShort")
		NumPut(this.wTypeFlags,			1*ptr,	50+1*A_PtrSize,	"UShort")
		NumPut(this.wMajorVerNum,		1*ptr,	52+1*A_PtrSize,	"UShort")
		NumPut(this.wMinorVerNum,		1*ptr,	54+1*A_PtrSize,	"UShort")
		this.tdescAlias.ToStructPtr(ptr+56+A_PtrSize)
		this.idldescType.ToStructPtr(ptr+56+A_PtrSize+this.tdescAlias.GetRequiredSize())

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a TYPEATTR struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		TYPEATTR instance - the new TYPEATTR instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new TYPEATTR()
		instance.SetOriginalPointer(ptr, own)

		instance.guid				:= CCFramework.GUID2String(ptr)
		instance.lcid				:= NumGet(1*ptr,	16+0*A_PtrSize,	"UInt")
		instance.dwReserved			:= NumGet(1*ptr,	20+0*A_PtrSize,	"UInt")
		instance.memidConstructor	:= NumGet(1*ptr,	24+0*A_PtrSize,	"Int")
		instance.memidDestructor	:= NumGet(1*ptr,	28+0*A_PtrSize,	"Int")
		instance.lpstrSchema		:= StrGet(NumGet(1*ptr,	32+0*A_PtrSize,	"UPtr"), "UTF-16")
		instance.cbSizeInstance		:= NumGet(1*ptr,	32+1*A_PtrSize,	"UInt")
		instance.typekind			:= NumGet(1*ptr,	36+1*A_PtrSize,	"UInt")
		instance.cFuncs				:= NumGet(1*ptr,	40+1*A_PtrSize,	"UShort")
		instance.cVars				:= NumGet(1*ptr,	42+1*A_PtrSize,	"UShort")
		instance.cImplTypes			:= NumGet(1*ptr,	44+1*A_PtrSize,	"UShort")
		instance.cbSizeVft			:= NumGet(1*ptr,	46+1*A_PtrSize,	"UShort")
		instance.cbAlignment		:= NumGet(1*ptr,	48+1*A_PtrSize,	"UShort")
		instance.wTypeFlags			:= NumGet(1*ptr,	50+1*A_PtrSize,	"UShort")
		instance.wMajorVerNum		:= NumGet(1*ptr,	52+1*A_PtrSize,	"UShort")
		instance.wMinorVerNum		:= NumGet(1*ptr,	54+1*A_PtrSize,	"UShort")
		instance.tdescAlias			:= TYPEDESC.FromStructPtr(ptr+56+A_PtrSize, false)
		instance.idldescType		:= IDLDESC.FromStructPtr(ptr+56+A_PtrSize+instance.tdescAlias.GetRequiredSize(), false)

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
		- The data object is passed to the TYPEDESC.GetRequiredSize() and IDLDESC.GetRequiredSize() methods.
	*/
	GetRequiredSize(data := "")
	{
		local td, idl
		td := (this == TYPEATTR) ? TYPEDESC : this.tdescAlias, idl := (this == TYPEATTR) ? IDLDESC : this.idldescType
		return 56 + 1 * A_PtrSize + td.GetRequiredSize(data) + idl.GetRequiredSize(data)
	}
}