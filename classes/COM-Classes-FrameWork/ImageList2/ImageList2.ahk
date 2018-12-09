/*
class: ImageList2
wraps the *IImageList2* interface and provides additional methods for manipulating and interacting with image lists.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ImageList2)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761419)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown, ImageList
	Constant classes - ILGOS, ILDI, ILFIP, ILC, ILR
	Structure classes - IMAGELISTDRAWPARAMS, IMAGELISTSTATS
*/
class ImageList2 extends ImageList
{
	/*
	Field: CLSID
	This is CLSID_ImageList. It is required to create an instance.
	*/
	static CLSID := "{7C476BA2-02B1-48f4-8048-B24619DDC058}"

	/*
	Field: IID
	This is IID_IImageList2. It is required to create an instance.
	*/
	static IID := "{192b9d83-50fc-457b-90a0-2b82a8b5dae1}"

	/*
	Method: Resize
	Resizes the current image.

	Parameters:
		INT width - the new width in pixels
		INT height - the new height in pixels

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		To set the present image, use <ForceImagePresent>.
	*/
	Resize(width, height)
	{
		return this._Error(DllCall(NumGet(this.vt+32*A_PtrSize), "ptr", this.ptr, "int", width, "int", height))
	}

	/*
	Method: GetOriginalSize
	Gets the original size of a specified image.

	Parameters:
		INT index - The index of desired image.
		UINT flags - Flags for getting original size. You can use one of the fields of the ILGOS class for convenience.
		byRef INT width - receives the original width
		byRef INT height - receives the original height

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetOriginalSize(index, flags, byRef width, byRef height)
	{
		return this._Error(DllCall(NumGet(this.vt+33*A_PtrSize), "ptr", this.ptr, "int", index, "UInt", flags, "int*", width, "int*", height))
	}

	/*
	Method: SetOriginalSize
	Sets the original size of a specified image.

	Parameters:
		INT index - The index of desired image.
		INT width - the width
		INT height - the height

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetOriginalSize(index, width, height)
	{
		return this._Error(DllCall(NumGet(this.vt+34*A_PtrSize), "ptr", this.ptr, "int", index, "int", width, "int", height))
	}

	/*
	Method: SetCallback
	Not implemented
	*/
	SetCallback(p*)
	{
		throw Exception("method not implemented", -1)
	}

	/*
	Method: GetCallback
	Not implemented
	*/
	GetCallback(p*)
	{
		throw Exception("method not implemented", -1)
	}

	/*
	Method: ForceImagePresent
	Forces an image present, as specified.

	Parameters:
		INT index - the image to set as present
		UINT flags - Force image flags. You may use one of the fields of the ILFIP class.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ForceImagePresent(index, flags)
	{
		return this._Error(DllCall(NumGet(this.vt+37*A_PtrSize), "ptr", this.ptr, "int", index, "uint", flags))
	}

	/*
	Method: DiscardImages
	Discards images from list, as specified.

	Parameters:
		INT start - the index of the first image to discard.
		INT end - the index of last image to discard.
		UINT flags - Discard images flags. You may use the fields of the ILDI class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DiscardImages(start, end, flags)
	{
		return this._Error(DllCall(NumGet(this.vt+38*A_PtrSize), "ptr", this.ptr, "int", start, "int", end, "uint", flags))
	}

	/*
	Method: PreloadImages
	Preloads images, as specified.

	Parameters:
		IMAGELISTDRAWPARAMS params - either an instance of the IMAGELISTDRAWPARAMS class or a pointer to a valid IMAGELISTDRAWPARAMS struct.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	PreloadImages(params)
	{
		return this._Error(DllCall(NumGet(this.vt+39*A_PtrSize), "ptr", this.ptr, "ptr", IsObject(params) ? params.ToStructPtr() : params))
	}
	
	/*
	Method: GetStatistics
	Gets an image list statistics structure.

	Returns:
		IMAGELISTSTATS statistics - an instance of the IMAGELISTSTATS class describing the image list
	*/
	GetStatistics()
	{
		static stat_size := IMAGELISTSTATS.GetRequiredSize()
		local struct := CCFramework.AllocateMemory(stat_size)
		this._Error(DllCall(NumGet(this.vt+40*A_PtrSize), "ptr", this.ptr, "ptr", struct))
		return IMAGELISTSTATS.FromStructPtr(struct)
	}
	
	/*
	Method: Initialize
	Initializes an image list.

	Parameters:
		INT width - Width, in pixels, of each image.
		INT height - Height, in pixels, of each image.
		UINT flags - A combination of *Image List Creation Flags.* You can use the fields of the ILC class for convenience.
		INI initial - Number of images that the image list initially contains.
		INT max - Number of new images that the image list can contain.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Initialize(width, height, flags, initial, max)
	{
		return this._Error(DllCall(NumGet(this.vt+41*A_PtrSize), "ptr", this.ptr, "int", width, "int", height, "uint", flags, "int", initial, "int", max))
	}
	
	/*
	Method: Replace2
	Replaces an image in an image list.

	Parameters:
		INT index - the index of the image to replace.
		HBITMAP image - A handle to the bitmap that contains the new image.
		UINT flags - Specifies how the mask is applied to the image as one or a bitwise combination of the flags in the ILR class.
		[opt] HBITMAP mask - A handle to the bitmap that contains the mask. If no mask is used with the image list, this parameter is ignored.
		[opt] IUnknown punk - A pointer to the IUnknown interface. *(not sure what this does)*

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Replace2(index, image, flags, mask := 0, punk := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+42*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", image, "ptr", mask, "ptr", punk, "uint", flags))
	}

	/*
	Method: ReplaceFromImageList
	Replaces an image in one image list with an image from another image list.

	Parameters:
		INT index - The index of the destination image in the image list. This is the image that is overwritten by the new image.
		ImageList src - either an ImageList instance pointing to the source image list or a raw pointer such as returned by IL_Create()
		INT srcIndex - The index of the source image in the image list pointed to by src.
		[opt] IUnknown punk - A pointer to the IUnknown interface. *(not sure what this does)*

	Returns:
		BOOL success - true on success, false otherwise
	*/
	ReplaceFromImageList(index, src, srcIndex, punk := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+43*A_PtrSize), "ptr", this.ptr, "int", index, "ptr", IsObject(src) ? src.ptr : src, "Int", srcIndex, "ptr", punk, "uint", 0)) ; msdn: last param is not used
	}
}