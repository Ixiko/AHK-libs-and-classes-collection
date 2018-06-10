;
; Image List Wrapper Class
;

/*!
	Class: CImageList
		Image list class.
	@UseShortForm
*/

class CImageList
{
	/*!
		Constructor: (initialCount := 2, growCount := 5, largeIcons := false)
			Creates an image list. Analogous to `IL_Create`.
		Parameters:
			initialCount - (Optional) The initial number of icons the image list can hold. If omitted it defaults to 2.
			growCount - (Optional) The grow amount when the capacity is exceeded. If omitted it defaults to 5.
			largeIcons - (Optional) `true` if the image list is to hold large icons. Defaults to `false`.
	*/
	
	__New(initialCount := 2, growCount := 5, largeIcons := 0)
	{
		if not this.__Handle := IL_Create(initialCount, growCount, largeIcons)
			throw Exception("IL_Create()", -1) ; Short msg since so rare
	}
	
	__Delete()
	{
		IL_Destroy(this.__Handle)
	}
	
	/*!
		Method: AddImage(filename [, iconNumber, resizeNonIcons])
			Adds an image to the list. Equivalent to `IL_Add()`.
		Remarks:
			Refer to the `IL_Add()` documentation for parameter information.
	*/
	
	AddImage(filename, p*)
	{
		return IL_Add(this.__Handle, filename, p*)
	}
}

/*!
	End of class
*/
