/*
class: REOBJECT
a structure class that contains information about a RichEdit-object.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/REOBJECT)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb787946)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - REO, DVASPECT
	Structure classes - SIZE
	Other classes - CCFramework
*/
class REOBJECT extends StructBase
{
	/*
	Field: cbStruct
	Structure size, in bytes. *DO NOT CHANGE THIS VALUE!*
	*/
	cbStruct := this.GetRequiredSize()

	/*
	Field: cp
	Character position of the object.
	*/
	cp := 0

	/*
	Field: clsid
	Class identifier of the object.

	Remarks:
		When retrieved from an instance created by <FromStructPtr()>, this is a GUID string.
		Otherwise, you may either set it to a string or a raw memory pointer to the GUID.
	*/
	clsid := ""

	/*
	Field: poleobj
	Points to an instance of the IOleObject interface for the object.

	Remarks:
		- This is a raw COM pointer, no class instance.
	*/
	poleobj := 0

	/*
	Field: pstg
	Points to an instance of the IStorage interface. This is the storage object associated with the object.

	Remarks:
		- This is a raw COM pointer, no class instance.
	*/
	pstg := 0

	/*
	Field: polesite
	Points to an instance of the IOleClientSite interface. This is the object's client site in the rich edit control. This address must have been obtained from the GetClientSite method.

	Remarks:
		- This is a raw COM pointer, no class instance.
	*/
	polesite := 0

	/*
	Field: sizel
	A SIZE structure class instance specifying the size of the object. The unit of measure is 0.01 millimeters, which is a himetric measurement. A 0, 0 on insertion indicates that an object is free to determine its size until the modify flag is turned off.
	*/
	sizel := new SIZE()

	/*
	Field: dvaspect
	Display aspect used. You may use one of the fields in the DVASPECT class for convenience.
	*/
	dvaspect := 0

	/*
	Field: dwFlags
	Object status flag. It can be a combination of the flags in the "object flags" group of the REO class.
	*/
	dwFlags := 0

	/*
	Field: dwUser
	Reserved for user-defined values.
	*/
	dwUser := 0

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

		NumPut(this.cbStruct,	1*ptr,	00+0*A_PtrSize,	"UInt")
		NumPut(this.cp,			1*ptr,	04+0*A_PtrSize,	"Int")

		if !CCFramework.isInteger(this.clsid)
			CCFramework.String2GUID(this.clsid, ptr + 08)
		else
			CCFramework.CopyMemory(this.clsid, ptr + 08, 16)

		NumPut(this.poleobj,	1*ptr,	24+0*A_PtrSize,	"UPtr")
		NumPut(this.pstg,		1*ptr,	24+1*A_PtrSize,	"UPtr")
		NumPut(this.polesite,	1*ptr,	24+2*A_PtrSize,	"UPtr")
		this.sizel.ToStructPtr(ptr + 24 + 3*A_PtrSize)
		NumPut(this.dvaspect,	1*ptr,	32+3*A_PtrSize,	"UInt")
		NumPut(this.dwFlags,	1*ptr,	36+3*A_PtrSize,	"UInt")
		NumPut(this.dwUser,		1*ptr,	40+3*A_PtrSize,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a REOBJECT struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		REOBJECT instance - the new REOBJECT instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new REOBJECT()
		instance.SetOriginalPointer(ptr, own)

		instance.cbStruct	:= NumGet(1*ptr,	00+0*A_PtrSize,	"UInt")
		instance.cp			:= NumGet(1*ptr,	04+0*A_PtrSize,	"UInt")
		instance.clsid		:= CCFramework.GUID2String(ptr + 08)
		instance.poleobj	:= NumGet(1*ptr,	24+0*A_PtrSize,	"UPtr")
		instance.pstg		:= NumGet(1*ptr,	24+1*A_PtrSize,	"UPtr")
		instance.polesite	:= NumGet(1*ptr,	24+2*A_PtrSize,	"UPtr")
		instance.sizel 		:= SIZE.FromStructPtr(ptr + 24+3*A_PtrSize, false)
		instance.dvaspect	:= NumGet(1*ptr,	32+3*A_PtrSize,	"UInt")
		instance.dwFlags	:= NumGet(1*ptr,	36+3*A_PtrSize,	"UInt")
		instance.dwUser		:= NumGet(1*ptr,	40+3*A_PtrSize,	"UInt")

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
		return 36 + 3 * A_PtrSize + SIZE.GetRequiredSize()
	}
}