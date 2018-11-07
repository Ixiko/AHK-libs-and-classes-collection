/*
class: ShellItem
wraps the *IShellItem* interface and exposes methods that retrieve information about a Shell item. IShellItem and IShellItem2 are the preferred representations of items in any new code.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ShellItem)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761144)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP SP1 / Windows Server 2003 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes -  SIGDN, SFGAO, SICHINT
	Other classes - CCFramework
*/
class ShellItem  extends Unknown
{
	/*
	Field: IID
	This is IID_IShellItem. It is required to create an instance.
	*/
	static IID := "{43826d1e-e718-42ee-bc55-a1e261c37bfe}"

	/*
	Field: CLSID
	This is CLSID_ShellItem. It is required to create an instance.
	*/
	static CLSID := "{9ac9fbe1-e0a2-4ad6-b4ee-e212013ea917}"

	/*
	group: Constructor methods

	Method: FromAbsolutePath
	Creates and initializes a Shell item object from an absolute path.

	Parameters:
		STR path - the path to the directory or file to create an item for
		[opt] IBindCtx bc - a raw interface pointer to an IBindCtx instance used to pass parameters as inputs and outputs to the parsing function. These passed parameters are often specific to the data source and are documented by the data source owners.

	Returns:
		ShellItem item - the created instance
	*/
	FromAbsolutePath(path, bc := 0)
	{
		local mem, iid, out
		if IsObject(bc)
			bc := bc.ptr
		VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(this.IID, &mem)
		DllCall("Shell32\SHCreateItemFromParsingName", "str", path, "ptr", bc, "ptr", iid, "ptr*", out)
		return new ShellItem(out)
	}

	/*
	Method: FromKnownFolder
	Creates a Shell item object for a known folder.

	Parameters:
		GUID folder - the GUID of the known folder, as string or pointer. You may use the fields of the KNOWNFOLDERID class for convenience.
		[opt] HTOKEN user - An access token used to represent a particular user. This parameter is usually ommited, in which case the function tries to access the current user's instance of the folder. However, you may need to assign a value to hToken for those folders that can have multiple users but are treated as belonging to a single user. The most commonly used folder of this type is Documents.

	Returns:
		ShellItem item - the created item

	Remarks:
		To call this function on public known folders, the caller must have Administrator privileges.
	*/
	FromKNOWNFOLDERID(folder, user := 0)
	{
		local iid, mem1, mem2, out

		if !CCFramework.isInteger(folder)
			VarSetCapacity(mem1, 16, 00), folder := CCFramework.String2GUID(folder, &mem1)

		VarSetCapacity(mem2, 16, 00), iid := CCFramework.String2GUID(this.IID, &mem2)
		this._Error(DllCall("Shell32\SHGetKnownFolderItem", "ptr", folder, "uint", 0, "ptr", user, "ptr", iid, "ptr*", out))

		return new ShellItem(out)
	}

	/*
	Method: FromRelativePath
	Creates and initializes a Shell item object from a relative parsing name.

	Parameters:
		STR path - the relative path to the item
		[opt] ShellItem parent - the item the path is relative to (either as ShellItem instance or raw interface pointer). If this is empty, the current working directory is used.
		[opt] IBindCtx bc - a raw interface pointer to an IBindCtx instance that controls the parsing operation.

	Returns:
		ShellItem item - the created item

	Remarks:
		Currently, this only works if a parent item is supplied.
	*/
	FromRelativePath(path, parent := 0, bc := 0)
	{
		local out, mem, iid
		if (!parent && !IsObject(parent))
			parent := ShellItem.FromAbsolutePath(A_WorkingDir)
		if IsObject(parent)
			parent := parent.ptr
		if IsObject(bc)
			bc := bc.ptr
		VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(this.IID, &mem)
		this._Error(DllCall("Shell32\SHCreateItemFromRelativeName", "ptr", parent, "str", path, "ptr", bc, "ptr", iid, "ptr*", out))
		return new ShellItem(out)
	}

	/*
	group: IShellItem methods

	Method: BindToHandler
	Binds to a handler for an item as specified by the handler ID value (BHID).

	Parameters:
		GUID mode - a GUID that specifies which handler will be created, either as GUID string or as pointer. See Remarks.
		IID interface - the IID of the interface to retrieve, either as GUID string or as pointer.
		[opt] IBindCtx bc - a raw interface pointer to an IBindCtx instance on a bind context object. Used to pass optional parameters to the handler. The contents of the bind context are handler-specific. For example, when binding to BHID_Stream, the STGM flags in the bind context indicate the mode of access desired (read or read/write).

	Returns:
		UPTR instance - a raw memory pointer to the created instance

	Remarks:
		The GUID for "mode" must be one of the following values defined in Shlguid.h:
		BHID_SFObject - Restricts usage to BindToObject.
		BHID_SFUIObject - Restricts usage to GetUIObjectOf.
		BHID_SFViewObject - Restricts usage to CreateViewObject.
		BHID_Storage - Attempts to retrieve the storage RIID, but defaults to Shell implementation on failure.
		BHID_Stream - Restricts usage to IStream.
		BHID_LinkTargetItem - CLSID_ShellItem is initialized with the target of this item (can only be SFGAO.LINK). See GetAttributesOf for a description of SFGAO.LINK.
		BHID_StorageEnum - If the item is a folder, gets an IEnumShellItems object with which to enumerate the storage contents.
		BHID_Transfer - *Windows Vista and later:* If the item is a folder, gets an ITransferSource or ITransferDestination object.
		BHID_PropertyStore - *Windows Vista and later:* Restricts usage to IPropertyStore or IPropertyStoreFactory.
		BHID_ThumbnailHandler - *Windows Vista and later:* Restricts usage to IExtractImage or IThumbnailProvider.
		BHID_EnumItems - *Windows Vista and later:* If the item is a folder, gets an IEnumShellItems object that enumerates all items in the folder. This includes folders, nonfolders, and hidden items.
		BHID_DataObject - *Windows Vista and later:* Gets an IDataObject object for use with an item or an array of items.
		BHID_AssociationArray - *Windows Vista and later:* Gets an IQueryAssociations object for use with an item or an array of items.
		BHID_Filter - *Windows Vista and later:* Restricts usage to IFilter.
		BHID_EnumAssocHandlers - *Windows 7 and later:* Retrieves an IEnumAssocHandlers that enumerates the association handlers for the given item. Returns an enumeration of recommended handlers, similar to calling SHAssocEnumHandlers with ASSOC_FILTER_RECOMMENDED.
	*/
	BindToHandler(mode, interface, bc := 0)
	{
		local mem1, mem2, out

		if !CCFramework.isInteger(interface)
			VarSetCapacity(mem1, 16, 00), interface := CCFramework.String2GUID(interface, &mem1)

		if !CCFramework.isInteger(mode)
			VarSetCapacity(mem2, 16, 00), mode := CCFramework.String2GUID(mode, &mem2)

		if IsObject(bc)
			bc := bc.ptr

		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "ptr", bc, "ptr", mode, "ptr", interface, "ptr*", out))
		return out
	}

	/*
	Method: GetParent
	Gets the parent of an IShellItem object.

	Returns:
		ShellItem parent - the parent item
	*/
	GetParent()
	{
		local parent
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "ptr*", parent))
		return new ShellItem(parent)
	}

	/*
	Method: GetDisplayName
	Gets the display name of the IShellItem object.

	Parameters:
		[opt] INT flag - a flag indicating how the name should look like. You may use the fields of the SIGDN class for convenience. Defaults to SIGDN.NORMALDISPLAY.

	Returns:
		STR name - the item's display name
	*/
	GetDisplayName(flag := 0)
	{
		local name
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "UInt", flag, "ptr*", name))
		return StrGet(name, "UTF-16")
	}

	/*
	Method: GetAttributes
	Gets a requested set of attributes of the IShellItem object.

	Parameters:
		UINT requested - a combination of flags specifying the attributes requested. You may use the fields of the SFGAO class for convenience.
		byRef UINT attr - receives a combination of SFGAO flags specifying the attributes actually present.

	Returns:
		BOOL match - true if all requested attributes are present, false otherwise (or if an error occured).
	*/
	GetAttributes(requested, byRef attr)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "UInt", requested, "UInt*", attr))
	}

	/*
	Method: Compare
	Compares two IShellItem objects.

	Parameters:
		ShellItem compareTo - the IShellItem to compare this instance to, either as raw interface pointer or ShellItem instance
		[opt] INT hint - a flag indicating how to perform the comparison. You may use the fields of the SICHINT class for convenience. Defaults to SICHINT.DISPLAY.

	Returns:
		INT result - the result of the comparison. If the two items are the same, this equals zero; if they are different the parameter is nonzero.
	*/
	Compare(compareTo, hint := 0)
	{
		local result
		this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "Ptr", IsObject(compareTo) ? compareTo.ptr : compareTo, "UInt", hint, "Int*", result))
		return result
	}
}