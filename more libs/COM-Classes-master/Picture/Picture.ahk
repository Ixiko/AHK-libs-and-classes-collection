/*
class: Picture
wraps the *IPicture* interface and manages a picture object and its properties.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/Picture)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms680761)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant Classes - PICTYPE
	Structure classes - RECT, PICTUREATTRIBUTES, PICTDESC
	Other classes - Stream, CCFramework
*/
class Picture extends Unknown
{
	/*
	Field: IID
	This is IID_IPicture. It is required to create an instance.
	*/
	static IID := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.

	Remarks:
		You may obtain an instance from the <FromPICTDESC()> method.
	*/
	static ThrowOnCreation := true

	/*
	Method: FromPICTDESC
	(static) method that creates a Picture instance from a given PICTDESC struct

	Parameters:
		PICTDESC src - either a raw memory pointer or a PICTDESC struct class instance to create the instance from

	Returns:
		Picture instance - the created instance

	Remarks:
		- This function updates the Picture class' Error field. You may use it to obtain information about failure.
	*/
	FromPICTDESC(src)
	{
		local mem, iid, pPict
		if IsObject(src)
			src := src.ToStructPtr()
		VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(Picture.IID, &mem)
		this._Error(DllCall("OleAut32.dll\OleCreatePictureIndirect", "UPtr", src, "UPtr", iid, "UInt", false, "ptr*", pPict))
		return new Picture(pPict)
	}

	/*
	group: meta-functions

	Method: __Get
	meta-function to implement dynamic properties.
	*/
	__Get(property)
	{
		if (property = "handle")
			return this.get_Handle()
		else if (property = "hPal")
			return this.get_hPal()
		else if (property = "Type")
			return this.get_Type()
		else if (property = "width")
			return this.get_Width()
		else if (property = "height")
			return this.get_Height()
		else if (property = "CurDC")
			return this.get_CurDC()
		else if (property = "KeepOriginalFormat")
			return this.get_KeepOriginalFormat()
		else if (property = "Attributes")
			return this.get_Attributes()
	}

	/*
	Method: __Set
	meta-function to implement dynamic properties.
	*/
	__Set(property, value)
	{
		if (property = "hPal")
			this.set_hPal(value)
		else if (property = "KeepOriginalFormat")
			this.put_KeepOriginalFormat(value)
	}

	/*
	group: dynamic properties

	========================================================================================================
	Field: handle
	the handle to the picture managed within this picture object to a specified location.

	Access: read-only

	corresponding methods: <get_Handle>

	========================================================================================================
	Field: hPal
	a GDI palette to the picture contained in the picture object.

	Access: read-write

	Remarks:
		Reading this property retrieves *a copy of the palette currently used by the picture object.*

	corresponding methods: <get_hPal>, <set_hPal>

	========================================================================================================
	Field: Type
	the current type of the picture contained in the picture object.

	Access: read-only

	Remarks:
		This is one of the values defined in the PICTYPE enumeration class.

	corresponding methods: <get_Type>

	========================================================================================================
	Field: width
	the current width of the picture in the picture object.

	Access: read-only

	corresponding methods: <get_Width>

	========================================================================================================
	Field: height
	the current height of the picture in the picture object.

	Access: read-only

	corresponding methods: <get_Height>

	========================================================================================================
	Field: CurDC
	the handle of the current device context. This property is valid only for bitmap pictures.

	Access: read-only

	corresponding methods: <get_CurDC>

	========================================================================================================
	Field: KeepOriginalFormat
	the current value of the picture's KeepOriginalFormat property.

	Access: read-write

	corresponding methods: <get_KeepOriginalFormat>, <put_KeepOriginalFormat>

	========================================================================================================
	Field: Attributes
	the current set of the picture's bit attributes.

	Access: read-only

	corresponding methods: <get_Attributes>

	========================================================================================================
	*/
	/*
	group: IPicture methods

	Method: get_Handle
	Retrieves the handle to the picture managed within this picture object to a specified location.

	Returns:
		UPTR handle - the handle
	
	corresponding property: <handle>
	*/
	get_Handle()
	{
		local handle
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "uint*", handle))
		return handle
	}

	/*
	Method: get_hPal
	Retrieves a copy of the palette currently used by the picture object.

	Returns:
		UPTR palette - the handle to the copy

	corresponding property: <hPal>
	*/
	get_hPal()
	{
		local hPal
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint*", hPal))
		return hPal
	}

	/*
	Method: get_Type
	Retrieves the current type of the picture contained in the picture object.

	Returns:
		SHORT type - the picture type

	corresponding property: <Type>
	*/
	get_Type()
	{
		local type
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "short*", type))
		return type
	}

	/*
	Method: get_Width
	Retrieves the current width of the picture in the picture object.

	Returns:
		UINT width - the image's width

	corresponding property: <width>
	*/
	get_Width()
	{
		local width
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "int*", width))
		return width
	}

	/*
	Method: get_Height
	Retrieves the current height of the picture in the picture object.

	Returns:
		UINT height - the image's height

	corresponding property: <height>
	*/
	get_Height()
	{
		local height
		this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "int*", height))
		return height
	}

	/*
	Method: Render
	Renders (draws) a specified portion of the picture of the source picture and the dimensions to copy. This picture is rendered onto the specified device context.

	Parameters:
		HDC dc - A handle of the device context on which to render the image.
		INT x - The horizontal coordinate in hdc at which to place the rendered image.
		INT y - The vertical coordinate in hdc at which to place the rendered image.
		INT w - The horizontal dimension (width) of the destination rectangle.
		INT h - The vertical dimension (height) of the destination rectangle.
		INT xSrc - The horizontal offset in the source picture from which to start copying.
		INT ySrc - The vertical offset in the source picture from which to start copying.
		INT wSrc - The horizontal extent to copy from the source picture.
		INT hSrc - The vertical extent to copy from the source picture.
		RECT rect - a rectangle containing the position of the destination within a metafile device context if dc is a metafile DC. Cannot be NULL in such cases.
					This can either be a RECT instance or a pointer ot a valid struct in memory.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	Render(dc, x, y, w, h, xSrc, ySrc, wSrc, hSrc, rect := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "UPtr", dc, "int", x, "int", y, "int", w, "int", h, "int", xSrc, "int", ySrc, "int", wSrc, "int", hSrc, "ptr", IsObject(rect) ? rect.ToStructPtr() : rect))
	}

	/*
	Method: set_hPal
	Assigns a GDI palette to the picture contained in the picture object.

	Parameters:
		UPTR palette - the new palette to use

	Returns:
		BOOL success - true on success, false otherwise.

	corresponding property: <hPal>
	*/
	set_hPal(value)
	{
		return this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "uint", value))
	}

	/*
	Method: get_CurDC
	Retrieves the handle of the current device context. This property is valid only for bitmap pictures.

	Returns:
		HDC curDC - the handle to the current device context

	corresponding property: <CurDC>
	*/
	get_CurDC()
	{
		local hDC
		this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "ptr*", hDC))
		return hDC
	}

	/*
	Method: SelectPicture
	Selects a bitmap picture into a given device context, and returns the device context in which the picture was previously selected as well as the picture's GDI handle.

	Parameters:
		HDC newHDC - A handle for the device context in which to select the picture.
		[opt] byRef HDC outHDC - receives the previous HDC.
		[opt] byRef HBITMAP outHBMP - receives the the GDI handle of the picture.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	SelectPicture(newHDC, byRef outHDC := "", byRef outHBMP := "")
	{
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "ptr", newHDC, "ptr*", outHDC, "ptr*", outHBMP))
	}

	/*
	Method: get_KeepOriginalFormat
	Retrieves the current value of the picture's KeepOriginalFormat property.

	Returns:
		BOOL keep - the current value

	corresponding property: <KeepOriginalFormat>
	*/
	get_KeepOriginalFormat()
	{
		local keep
		this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "ptr", this.ptr, "uint*", keep))
		return keep
	}

	/*
	Method: put_KeepOriginalFormat
	Sets the value of the picture's KeepOriginalFormat property.

	Parameters:
		BOOL keep - the new value for the property

	Returns:
		BOOL success - true on success, false otherwise.

	corresponding property: <KeepOriginalFormat>
	*/
	put_KeepOriginalFormat(value)
	{
		return this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "ptr", this.ptr, "uint", value))
	}

	/*
	Method: PictureChanged
	Notifies the picture object that its picture resource has changed. This method only calls IPropertyNotifySink::OnChanged with DISPID_PICT_HANDLE for any connected sinks.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	PictureChanged()
	{
		return this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: SaveAsFile
	Saves the picture's data into a stream in the same format that it would save itself into a file. Bitmaps use the BMP file format, metafiles the WMF format, and icons the ICO format.

	Parameters:
		Stream stream - either a Stream instance or a pointer to an IStream instance into which the picture writes its data.
		BOOL fSaveMemCopy - A flag indicating whether to save a copy of the picture in memory.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	SaveAsFile(stream, fSaveMemCopy)
	{
		local cbSize
		this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "ptr", this.ptr, "ptr", (IsObject(stream) ? stream.ptr : stream), "uint", fSaveMemCopy, "int*", cbSize))
		return cbSize
	}

	/*
	Method: get_Attributes
	Retrieves the current set of the picture's bit attributes.

	Returns:
		UINT attr - the value of the Attributes property. This is a combination of the values defined in the PICTUREATTRIBUTES enumeration class.

	corresponding property: <Attributes>
	*/
	get_Attributes()
	{
		local attr
		this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "ptr", this.ptr, "uint*", attr))
		return attr
	}
}