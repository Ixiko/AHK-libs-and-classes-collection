/*
class: ImageList
wraps the *IImageList* interface and exposes methods that manipulate and interact with image lists.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ImageList)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761490)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP / Windows Server 2003 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - IDC, IDI, ILIF, ILD, OBM
	Structure classes - IMAGELISTDRAWPARAMS, IMAGEINFO, POINT, RECT
	Other classes - CCFramework

Remarks:
	- to get a HBITMAP or a HICON, use a DllCall to LoadImage, LoadBitmap, LoadIcon, LoadCursor, ...
	- the HIMAGELIST (e.g. for LV_SetImageList() or IL_xxx functions) handle can be obtained using instance.ptr
*/
class ImageList extends Unknown
{
	/*
	Field: CLSID
	This is CLSID_ImageList. It is required to create an instance.
	*/
	static CLSID := "{7C476BA2-02B1-48f4-8048-B24619DDC058}"

	/*
	Field: IID
	This is IID_IImageList. It is required to create an instance.
	*/
	static IID := "{46EB5926-582E-4017-9FDF-E8998DAA0950}"

	/*
	Field: hModule
	The module handle to the Comctl32 library, as returned by LoadLibrary()
	*/
	static hModule := DllCall("LoadLibrary", "str", "Comctl32.dll", "UPtr")

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	group: Constructors
	
	Method: FromHIMAGELIST
	creates a new instance for a given HIMAGELIST handle.
	
	Parameters:
		[opt] HIMAGELIST il - the handle to the image list as returned by IL_Create(). If omitted, a new image list is created.
		
	Remarks:
		You cannot create an instance using the usual way:
>		myIL := new ImageList()
		This throws an exception. You must create an instance from this method:
>		myIL := ImageList.FromHIMAGELIST(IL_CREATE())
		The given handle can be obtained using
>		handle := myIL.ptr
	*/
	FromHIMAGELIST(il := 0)
	{
		local iid, mem, ptr

		if (!il)
			il := IL_Create()

		VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(ImageList.IID, &mem)
		DllCall("Comctl32.dll\HIMAGELIST_QueryInterface", "ptr", il, "UPtr", iid, "ptr*", ptr)
		return new ImageList(ptr)
	}
	
	/*
	group: IImageList

	Method: Add
	adds a bitmap image to an ImageList instance.

	Parameters:
		HBITMAP bitmap - the bitmap to add
		[opt] HBITMAP maskbitmap - the bitmap to use as a mask

	Returns:
		INT index - the new (zero-based) index of the image

	Remarks:
		IImageList::Add copies the bitmap to an internal data structure.
		You must use the DeleteObject function to delete bitmap and maskbitmap when you don't need them anymore:
>		DllCall("Gdi32\DeleteObject", "uint", bitmap)
	*/
	Add(bitmap, maskbitmap := 0)
	{
		local int
		this._Error(DllCall(NumGet(this.vt+3*A_PtrSize), "ptr", this.ptr, "uint", bitmap, "uint", maskbitmap, "int*", int))
		return int
	}

	/*
	Method: ReplaceIcon
	replaces an icon in the image list or adds a new one.

	Parameters:
		HICON hIcon - the icon to add
		[opt] INT index - the index of the icon to be replaced. Leave this empty or use -1 to append the icon to the list.

	Returns:
		INT index - the new image list index of the icon
	*/
	ReplaceIcon(hIcon, index := -1)
	{
		local int
		this._Error(DllCall(NumGet(this.vt+4*A_PtrSize), "ptr", this.ptr, "int", index, "uint", hIcon, "int*", int))
		return int
	}

	/*
	Method: SetOverlayImage
	sets the overly image for an image.
	To make it visible, you must also call <Draw> and set the fStyle parameter appropriately.

	Parameters:
		INT image - the zero-based index of the image to work on
		INT overlay - the one-based index of the image to set as overlay image

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetOverlayImage(image, overlay)
	{
		return this._Error(DllCall(NumGet(this.vt+5*A_PtrSize), "ptr", this.ptr, "int", image, "int", overlay))
	}

	/*
	Method: Replace
	replaces an image in the image list with a new one

	Parameters:
		INT index - the image to be replaced
		HBITMAP bitmap - the new image
		[opt] HBITMAP maskbitmap - the optional mask bitmap for the new image

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		IImageList::Replace copies the bitmap to an internal data structure.
		You must use the DeleteObject function to delete bitmap and maskbitmap when you don't need them anymore:
>		DllCall("Gdi32\DeleteObject", "uint", bitmap)
	*/
	Replace(index, bitmap, maskbitmap := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+6*A_PtrSize), "ptr", this.ptr, "int", index, "uint", bitmap, "uint", maskbitmap))
	}

	/*
	Method: AddMasked
	Adds an image or images to an image list, generating a mask from the specified bitmap.

	Parameters:
		HBITMAP bitmap - the bitmap to add
		UINT color - the mask color (e.g. 0xFF0000)

	Returns:
		INT index - the new index of the image

	Remarks:
		IImageList::AddMasked copies the bitmap to an internal data structure.
		You must use the DeleteObject function to delete bitmap and color when you don't need them anymore:
>		DllCall("Gdi32\DeleteObject", "uint", bitmap)
	*/
	AddMasked(bitmap, color)
	{
		local int
		this._Error(DllCall(NumGet(this.vt+7*A_PtrSize), "ptr", this.ptr, "uint", bitmap, "uint", color, "int*", int))
		return int
	}

	/*
	Method: Draw
	Draws an image list item in the specified device context.

	Parameters:
		IMAGELISTDRAWPARAMS params - either a *pointer* to a valid struct or an instance of the IMAGELISTDRAWPARAMS class, specifying the options.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Draw(params)
	{
		if (IsObject(params))
			params := params.ToStructPtr()
		return this._Error(DllCall(NumGet(this.vt+8*A_PtrSize), "ptr", this.ptr, "ptr", params))
	}

	/*
	Method: Remove
	Removes an image from an image list. 

	Parameters:
		INT index - the index of the icon to be removed

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Remove(index)
	{
		return this._Error(DllCall(NumGet(this.vt+9*A_PtrSize), "ptr", this.ptr, "int", index))
	}

	/*
	Method: GetIcon
	Creates an icon from an image and a mask in an image list.

	Parameters:
		INT index - the index of the image to use
		UINT flags - a combination of flags to be used. You can use the values in the IMAGELISTDRAWFLAGS class and combine them using the "|" operator

	Returns:
		HICON icon - the generated icon	
	*/
	GetIcon(index, flags)
	{
		local hIcon
		this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "int", index, "uint", flags, "uint*", hIcon))
		return hIcon
	}

	/*
	Method: GetImageInfo
	gets information about an image

	Parameters:
		INT index - the index of the image to work on

	Returns:
		IMAGEINFO info - an IMAGEINFO instance containing the information.
	*/
	GetImageInfo(index)
	{
		local info
		VarSetCapacity(info, IMAGEINFO.GetRequiredSize(), 0)
		this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", &info))
		return IMAGEINFO.FromStructPtr(&info)
	}

	/*
	Method: Copy
	Copies images from a given ImageList instance.

	Parameters:
		INT iDest - the index the image should be copied to
		INT iSrc - the index of the source image
		UINT flags - a flag specifying how to copy the image. You might use the fields of the ILCF class for convenience.

	Remarks:
		*NOT WORKING!*
	*/
	Copy(iDest, iSrc, flags)
	{
		return this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "ptr", this.ptr, "int", iDest, "ptr", this.QueryInterface(Unknown.IID), "int", iSrc, "uint", flags))
	}

	/*
	Method: Merge
	Creates a new image by combining two existing images. This method also creates a new image list in which to store the image. 

	Remarks:
		*NOT WORKING!*	
	*/
	Merge(index1, index2, xoffset, yoffset, punk2)
	{
		local out, mem
		VarSetCapacity(mem, 16, 00)
		if this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "ptr", this.ptr, "int", index1, "ptr", punk2.QueryInterface(Unknown.IID), "int", index2
					, "int", xoffset, "int", yoffset, "UPtr", CCFramework.String2GUID(this.IID, &mem), "ptr*", out))
			return new ImageList(out)
	}

	/*
	Method: Clone
	clones an existing instance.

	Returns:
		ImageList IL - the new ImageList instance

	Remarks:
		Changes to the original image list won't be visible to the clone (and the other way round).
	*/
	Clone()
	{
		local iid, mem, out

		VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(ImageList.IID, &mem)
		this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "ptr", this.ptr, "UPtr", iid, "ptr*", out))
		return new ImageList(out)
	}

	/*
	Method: GetImageRect
	Gets an image's bounding rectangle.

	Parameters:
		INT index - the index of the image

	Returns:
		RECT image - an RECT instance representing the image.
	*/
	GetImageRect(index)
	{
		local info
		VarSetCapacity(info, RECT.GetRequiredSize(), 0)
		this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", &info))
		return RECT.FromStructPtr(&info)
	}

	/*
	Method: GetIconSize
	Gets the dimensions of images in an image list. All images in an image list have the same dimensions.

	Parameters:
		byref INT width - receives the width
		byref INT height - receives the height

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetIconSize(ByRef width, ByRef height)
	{
		return this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "ptr", this.ptr, "int*", width, "int*", height))
	}

	/*
	Method: SetIconSize
	Sets the dimensions of images in an image list and removes all images from the list.

	Parameters:
		INT width - the new width
		INT height - the new height

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetIconSize(width, height)
	{
		return this._Error(DllCall(NumGet(this.vt+17*A_PtrSize), "ptr", this.ptr, "int", width, "int", height))
	}

	/*
	Method: GetImageCount
	Gets the number of images in an image list.

	Returns:
		INT count - the count of images
	*/
	GetImageCount()
	{
		local count
		this._Error(DllCall(NumGet(this.vt+18*A_PtrSize), "ptr", this.ptr, "int*", count))
		return count
	}

	/*
	Method: SetImageCount
	Resizes an existing image list.

	Parameters:
		INT count - the new image count

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		- if you "cut" the image list, the last icons are removed.
		- if you enlarge it, the new images will be filled black.
		- if you cut and re-enlarge it, the cutted images will be present again.
	*/
	SetImageCount(count)
	{
		return this._Error(DllCall(NumGet(this.vt+19*A_PtrSize), "ptr", this.ptr, "uint", count))
	}

	/*
	Method: SetBkColor
	Sets the background color for an image list.

	Parameters:
		UINT color - the new color (e.g. 0x00FFFF)

	Returns:
		UINT old - the previous background color

	Remarks:
		This method only functions if you add an icon to the image list or use the IImageList::AddMasked method to add a black and white bitmap.
		Without a mask, the entire image draws, and the background color is not visible. 
	*/
	SetBkColor(color)
	{
		local oldColor
		this._Error(DllCall(NumGet(this.vt+20*A_PtrSize), "ptr", this.ptr, "uint", color, "uint*", oldColor))
		return oldColor
	}

	/*
	Method: GetBkColor
	Gets the current background color for an image list.

	Returns:
		UINT color - the background color
	*/
	GetBkColor()
	{
		local color
		this._Error(DllCall(NumGet(this.vt+21*A_PtrSize), "ptr", this.ptr, "uint*", color))
		return color
	}

	/*
	Method: BeginDrag
	Begins dragging an image. 

	Parameters:
		INT index - the image to drag
		INT xHotspot - the x-component of the drag position relative to the upper-left corner of the image
		INT yHotspot - the y-component of the drag position relative to the upper-left corner of the image.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	BeginDrag(index, xHotspot, yHotspot)
	{
		return this._Error(DllCall(NumGet(this.vt+22*A_PtrSize), "ptr", this.ptr, "int", index, "int", xHotspot, "int", yHotspot))
	}

	/*
	Method: EndDrag
	Ends a drag operation.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	EndDrag()
	{
		return this._Error(DllCall(NumGet(this.vt+23*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: DragEnter
	Locks updates to the specified window during a drag operation and displays the drag image at the specified position within the window. 

	Parameters:
		HWND hwnd - the window handle
		INT x - The x-coordinate at which to display the drag image. The coordinate is relative to the upper-left corner of the window, not the client area.
		INT y - The y-coordinate at which to display the drag image. The coordinate is relative to the upper-left corner of the window, not the client area.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DragEnter(hwnd, x, y)
	{
		return this._Error(DllCall(NumGet(this.vt+24*A_PtrSize), "ptr", this.ptr, "uint", hwnd, "int", x, "int", y))
	}

	/*
	Method: DragLeave
	Unlocks the specified window and hides the drag image, which enables the window to update. 

	Parameters:
		HWND hwnd - the window handle

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DragLeave(hwnd)
	{
		return this._Error(DllCall(NumGet(this.vt+25*A_PtrSize), "ptr", this.ptr, "uint", hwnd))
	}

	/*
	Method: DragMove
	Moves the image that is being dragged during a drag-and-drop operation.
	This method is typically called in response to a WM_MOUSEMOVE message. 

	Parameters:
		INT x - the image's new x-coordinate relative to the upper-left corner of the window
		INT y - the image's new y-coordinate relative to the upper-left corner of the window

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DragMove(x, y)
	{
		return this._Error(DllCall(NumGet(this.vt+26*A_PtrSize), "ptr", this.ptr, "int", x, "int", y))
	}

	/*
	Method: SetDragCursorImage
	Creates a new drag image by combining the specified image, which is typically a mouse cursor image, with the current drag image.

	Parameters:
		INT index - the index of the image
		INT xHotspot - contains the x-component of the hot spot within the new image. 
		INT yHotspot - contains the x-component of the hot spot within the new image. 
		ImageList il - the ImageList that contains the specified image.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetDragCursorImage(index, xHotspot, yHotspot, il)
	{
		return this._Error(DllCall(NumGet(this.vt+27*A_PtrSize), "ptr", this.ptr, "ptr", il.QueryInterface(Unknown.IID)
																	, "int", index, "int", xHotspot, "int", yHotspot))
	}

	/*
	Method: DragShowNoLock
	Shows or hides the image being dragged.

	Parameters:
		BOOL show - true to show, false to hide the image

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DragShowNoLock(show)
	{
		return this._Error(DllCall(NumGet(this.vt+28*A_PtrSize), "ptr", this.ptr, "uint", show))
	}

	/*
	Method: GetDragImage
	Gets the temporary image list that is used for the drag image.
	The method also retrieves the current drag position and the offset of the drag image relative to the drag position.

	Parameters:
		byref POINT dragPos - receives a POINT instance representing the current dragging position
		byref POINT imagePos - receives a POINT instance representing the current image position
		byref ImageList IL - receives an instance for the image list used for the drag image.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetDragImage(byRef dragPos, byRef imagePos, byRef IL)
	{
		local mem, iid, pt1, pt2, out, bool

		VarSetCapacity(pt1, POINT.GetRequiredSize(), 0), VarSetCapacity(pt2, POINT.GetRequiredSize(), 0)
		, VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(this.IID, &mem)
		bool := this._Error(DllCall(NumGet(this.vt+29*A_PtrSize), "ptr", this.ptr, "ptr", &pt1, "ptr", &pt2, "ptr", iid, "ptr", out))

		dragPos := POINT.FromStructPtr(&pt1)
		imagePos := POINT.FromStructPtr(&pt2)
		IL := new ImageList(out)

		return bool
	}

	/*
	Method: GetItemFlags
	Gets the flags of an image.

	Parameters:
		INT index - the image index

	Returns:
		UINT flags - the image's flags. You may use the ILIF class for convenience.

	Remarks:
		possible flag values:
			ILIF.ALPHA - Indicates that the item in the imagelist has an alpha channel.
			ILIF.LOWQUALITY - **Windows Vista and later.** Indicates that the item in the imagelist was generated via a StretchBlt method, consequently image quality may have degraded.
	*/
	GetItemFlags(index)
	{
		local flags
		this._Error(DllCall(NumGet(this.vt+30*A_PtrSize), "ptr", this.ptr, "int", index, "uint*", flags))
		return flags
	}

	/*
	Method: GetOverlayImage
	Retrieves a specified image from the list of images used as overlay masks.

	Parameters:
		INT index - the image index

	Returns:
		INT overlay - the one-based index of the overlay mask
	*/
	GetOverlayImage(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+31*A_PtrSize), "ptr", this.ptr, "int", index, "int*", out))
		return out
	}

	/*	
	group: additional methods

	Method: AddSystemBitmap
	adds a system bitmap to the image list.

	Parameters: 
		UINT bmp - the ID of a predefined system bitmap. You can use the fields of the OBM class for convenience.

	Returns:
		INT index - the new (zero-based) index of the image´
	*/
	AddSystemBitmap(bmp)
	{
		return this.Add(DllCall("LoadBitmapW", "uint", 0, "uint", bmp))
	}

	/*
	Method: AddSystemIcon
	adds a system icon to the image list.

	Parameters:
		UINT ico - the ID of a predefined system icon. You can use the fields of the IDI class for convenience.

	Returns:
		INT index - the new (zero-based) index of the image
	*/
	AddSystemIcon(ico)
	{
		return this.ReplaceIcon(DllCall("LoadIconW", "uint", 0, "uint", ico))
	}

	/*
	Method: AddSystemCursor
	adds a system cursor to the image list.

	Parameters:
		UINT cur - the ID of a predefined system cursor. You can use the fields of the IDC class for convenience.

	Returns:
		INT index - the new (zero-based) index of the image
	*/
	AddSystemCursor(cur)
	{
		return this.ReplaceIcon(DllCall("LoadCursorW", "uint", 0, "uint", cur))
	}

	/*
	Method: Unload
	unloads Comctl32.dll

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Unload()
	{
		local hM
		hM := ImageList.hModule
		ImageList.hModule := 0
		return DllCall("FreeLibrary", "UPtr", hM)
	}
}