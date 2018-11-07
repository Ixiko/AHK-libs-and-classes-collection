/*
class: PICTDESC
a structure class that contains parameters to create a picture object through the OleCreatePictureIndirect function.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PICTDESC)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms693798)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - PICTYPE
*/
class PICTDESC extends StructBase
{
	/*
	Field: cbSizeofstruct
	The size of the structure, in bytes.

	Remarks:
		- When retrieved on an instance created from a memory struct, this contains the value in this struct.
		- Otherwise, it'll be initially 0 as it changes depending on the other members.
		- Whenever you call <ToStructPtr()>, this will be calculated, based on the value of the <picType> field, used and set to the result.
	*/
	cbSizeofstruct := 0

	/*
	Field: picType
	The type of picture described by this structure. You may use the fields of the PICTYPE class for convenience.

	Remarks:
		- This field's value is responsible for the selected union arm.
	*/
	picType := 0

	/*
	Field: bmp
	Structure containing bitmap information if <picType> is PICTYPE.BITMAP.

	Nested fields:
		HBITMAP hbitmap - The HBITMAP handle identifying the bitmap assigned to the picture object.
		HPALETTE hpal - The HPALETTE handle identifying the color palette for the bitmap.
	*/
	bmp := { "hbitmap" : 0, "hpal" : 0 }

	/*
	Field: wmf
	Structure containing metafile information if <picType> is PICTYPE.METAFILE.

	Nested fields:
		HMETAFILE hmeta - The HMETAFILE handle identifying the metafile assigned to the picture object.
		INT xExt - Horizontal extent of the metafile in TWIPS units.
		INT yExt - Vertical extent of the metafile in TWIPS units.
	*/
	wmf := { "hmeta" : 0, "xExt" : 0, "yExt" : 0 }

	/*
	Field: icon
	Structure containing icon information if <picType> is PICTYPE.ICON.

	Nested fields:
		HICON hIcon - The HICON handle identifying the icon assigned to the picture object.
	*/
	icon := { "hIcon" : 0 }

	/*
	Field: emf
	Structure containing enhanced metafile information if <picType> is PICTYPE.ENHMETAFILE.

	Nested Fields:
		HENHMETAFILE hemf - The HENHMETAFILE handle identifying the enhanced metafile assigned to the picture object.
	*/
	emf := { "hemf" : 0 }

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
			ptr := this.Allocate(this.cbSizeofstruct := this.GetRequiredSize())
		}

		NumPut(this.cbSizeofstruct,	1*ptr,	00,	"UInt")
		NumPut(this.picType,		1*ptr,	04,	"UInt")

		if (this.picType == PICTYPE.BITMAP)
		{
			NumPut(this.bmp.hbitmap,1*ptr, 08+0*A_PtrSize, "UPtr")
			NumPut(this.bmp.hpal,	1*ptr, 08+1*A_PtrSize, "UPtr")
		}
		else if (this.picType == PICTYPE.METAFILE)
		{
			NumPut(this.wmf.hmeta,	1*ptr,	08+0*A_PtrSize,	"UPtr")
			NumPut(this.wmf.xExt,	1*ptr,	08+1*A_PtrSize,	"Int")
			NumPut(this.wmf.yExt,	1*ptr,	12+1*A_PtrSize,	"Int")
		}
		else if (this.picType == PICTYPE.ICON)
		{
			NumPut(this.icon.hIcon,	1*ptr,	08+0*A_PtrSize,	"UPtr")
		}
		else if (this.picType == PICTYPE.ENHMETAFILE)
		{
			NumPut(this.emf.hemf,	1*ptr,	08+0*A_PtrSize,	"UPtr")
		}

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a PICTDESC struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		PICTDESC instance - the new PICTDESC instance

	Remarks:
		To retrieve any values besides <cbSizeofstruct> and <picType>, the first must match the size the later one requires. <picType> must also not be PICTYPE.NONE or PICTYPE.UNINITIALIZED. If this is the case, all other fields are left to their defaults.
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new PICTDESC()
		instance.SetOriginalPointer(ptr, own)

		instance.cbSizeofstruct	:= NumGet(1*ptr,	00,	"UInt")
		instance.picType		:= NumGet(1*ptr,	04,	"UInt")

		if (instance.picType == PICTYPE.BITMAP && instance.cbSizeofstruct == 8 + 2 * A_PtrSize)
		{
			instance.bmp.hbitmap:= NumGet(1*ptr,	08+0*A_PtrSize,	"UPtr")
			instance.bmp.hpal	:= NumGet(1*ptr,	08+1*A_PtrSize,	"UPtr")
		}
		else if (instance.picType == PICTYPE.METAFILE && instance.cbSizeofstruct == 16 + A_PtrSize)
		{
			instance.wmf.hmeta	:= NumGet(1*ptr,	08+0*A_PtrSize,	"UPtr")
			instance.wmf.xExt	:= NumGet(1*ptr,	08+1*A_PtrSize,	"Int")
			instance.wmf.yExt	:= NumGet(1*ptr,	12+1*A_PtrSize,	"Int")
		}
		else if (instance.picType == PICTYPE.ICON && instance.cbSizeofstruct == 8 + A_PtrSize)
		{
			instance.icon.hIcon	:= NumGet(1*ptr,	08+0*A_PtrSize,	"UPtr")
		}
		else if (instance.picType == PICTYPE.ENHMETAFILE && instance.cbSizeofstruct == 8 + A_PtrSize)
		{
			instance.emf.hemf	:= NumGet(1*ptr,	08+0*A_PtrSize,	"UPtr")
		}

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
		- If this method is called from an instance, the instance's <picType> value will be used. To override this or if the method is called as static method, the data object may contain a field called "pictype" which specifies the PICTYPE value for the calcuation. If none is give, PICTYPE.METAFILE is assumed, which needs most memory.
	*/
	GetRequiredSize(data := "")
	{
		local picType
		picType := PICTYPE.METAFILE
		if (this != PICTDESC)
				picType := this.picType
		if (IsObject(data) && data.HasKey("pictype"))
				picType := data.picType
		return 8 + (picType == PICTYPE.ICON || picType == PICTYPE.ENHMETAFILE ? A_PtrSize
				: (picType == PICTYPE.BITMAP ? 2 * A_PtrSize
				: (picType == PICTYPE.METAFILE ? 8 + A_PtrSize : 0)))
	}
}