/*
class: Storage
wraps the *IStorage* interface and supports the creation and management of structured storage objects.
Structured storage allows hierarchical storage of information within a single file, and is often referred to as "a file system within a file".

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/Storage)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380015%28v=vs.85%29.aspx)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - STGM, STGC, STGMOVE, STATFLAG
	Structure classes - FILETIME, STATSTG
	Other classes - SequentialStream, Stream, EnumSTATSTG, CCFramework
*/
class Storage extends Unknown
{
	/*
	Field: IID
	This is IID_IStorage. It is required to create an instance.
	*/
	static IID := "{0000000b-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer will throw an exception.

	Remarks:
		To get a pointer, you might use the StgOpenStorageEx or StgCreateStorageEx functions.
	*/
	static ThrowOnCreation := true

	/*
	Method: CreateStream
	creates and opens a stream object with the specified name contained in this storage object.
	All elements within a storage objects, both streams and other storage objects, are kept in the same name space.

	Parameters:
		STR name - the name of the stream. The name can be used later to open or reopen the stream. The name must not exceed 31 characters in length.
		UINT access - Specifies the access mode to use when opening the newly created stream. You may use the fields of the STGM class for convenience.

	Returns:
		Stream stream - the created stream, either as class instance (if available) or raw interface pointer
	*/
	CreateStream(name, access)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "Ptr", this.ptr, "Str", name, "UInt", access, "UInt", 0, "UInt", 0, "Ptr*", out)) ; msdn: param #3/4 are reserved
		return IsObject(Stream) ? new Stream(out) : out
	}

	/*
	Method: OpenStream
	opens an existing stream object within this storage object in the specified access mode.

	Parameters:
		STR name - the name of the stream
		UINT access - Specifies the access mode to be assigned to the open stream. You may use the fields of the STGM class for convenience.

	Returns:
		Stream stream - the created stream, either as class instance (if available) or raw interface pointer
	*/
	OpenStream(name, access)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "Ptr", this.ptr, "Str", name, "UInt", 0, "UInt", access, "UInt", 0, "Ptr*", out)) ; msdn: param #2/4 are reserved
		return IsObject(Stream) ? new Stream(out) : out
	}

	/*
	Method: CreateStorage
	creates and opens a new storage object nested within this storage object with the specified name in the specified access mode.

	Parameters:
		STR name - the name of the stream. The name can be used later to open or reopen the storage. The name must not exceed 31 characters in length.
		UINT access - Specifies the access mode to use when opening the newly created storage object. You may use the fields of the STGM class for convenience.

	Returns:
		Storage stg - the newly created storage, as class instance
	*/
	CreateStorage(name, access)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "Ptr", this.ptr, "Str", name, "UInt", access, "UInt", 0, "UInt", 0, "Ptr*", out)) ; msdn: param #3/4 are reserved
		return new Storage(out)
	}

	/*
	Method: OpenStorage
	opens an existing storage object with the specified name in the specified access mode.

	Parameters:
		STR name - the name of the storage
		UINT access - Specifies the access mode to use when opening the storage object. You may use the fields of the STGM class for convenience.

	Returns:
		Storage stg - the opened storage, as class instance
	*/
	OpenStorage(name, access)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "Ptr", this.ptr, "Str", name, "Ptr", 0, "UInt", access, "Ptr", 0, "UInt", 0, "Ptr*", out)) ; msdn: param #2/4 must be NULL, #5 is reserved
		return new Storage(out)
	}

	/*
	Method: CopyTo
	copies the entire contents of an open storage object to another storage object.

	Parameters:
		IID[] iidExclude - an array of IIDs to be excluded. This can be a memory pointer or an AHK array holding either memory pointers or GUID strings
		STR[] nameExclude - an array of strings to be excluded. This can either be a memory pointer (a pointer to an array of string pointers, which ends with a NULL pointer) or an AHK array of strings.
		Storage dest - the destination storage, either as class instance or raw interface pointer
		[opt] UINT iidExcludeCount - if iidExclude is a memory array, set this parameter to the number of elements in the array

	Returns:
		BOOL success - true on success, false otherwise
	*/
	CopyTo(iidExclude, nameExclude, dest, iidExcludeCount := 0)
	{
		local mem1, mem2
		if IsObject(iidExclude)
		{
			iidExcludeCount := iidExcludeCount ? iidExcludeCount : iidExclude.maxIndex(), VarSetCapacity(mem1, iidExcludeCount * 16, 00)
			Loop iidExcludeCount
			{
				if CCFramework.isInteger(iidExclude[A_Index])
					CCFramework.CopyMemory(iidExclude[A_Index], &mem1 + (A_Index - 1) * 16, 16)
				else
					CCFramework.String2GUID(iidExclude[A_Index], &mem1 + (A_Index - 1) * 16)
			}
			iidExclude := &mem1
		}
		if IsObject(nameExclude)
		{
			VarSetCapacity(mem2, nameExclude.maxIndex() * A_PtrSize, 00)
			Loop nameExclude.maxIndex()
			{
				NumPut(nameExclude.GetAdress(A_Index), mem2, (A_Index - 1) * A_PtrSize, "Ptr")
			}
			nameExclude := &mem2
		}
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "Ptr", this.ptr, "UInt", iidExcludeCount, "Ptr", iidExclude, "Ptr", nameExclude, "Ptr", IsObject(dest) ? dest.ptr : dest))
	}

	/*
	Method: MoveElementTo
	copies or moves a substorage or stream from this storage object to another storage object.

	Parameters:
		STR name - the name of the element in this storage object to be moved or copied
		Storage dest - the destination storage, either as class instance or raw interface pointer
		STR newName - the new name for the element in its new storage object
		UINT operation - Specifies whether the operation should be a move (STGMOVE.MOVE) or a copy (STGMOVE.COPY). You may use the fields of the STGMOVE class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	MoveElementTo(name, dest, newName, operation)
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "Ptr", this.ptr, "Str", name, "Ptr", IsObject(dest) ? dest.ptr : dest, "Str", newName, "UInt", operation))
	}

	/*
	Method: Commit
	ensures that any changes made to a storage object open in transacted mode are reflected in the parent storage.

	Parameters:
		UINT flags - Controls how the changes are committed to the storage object. You may use the fields of the STGC class for convenience.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		For nonroot storage objects in direct mode, this method has no effect.
		For a root storage, it reflects the changes in the actual device; for example, a file on disk.
		For a root storage object opened in direct mode, always call the <Commit> method prior to Release.
		<Commit> flushes all memory buffers to the disk for a root storage in direct mode and will return an error code upon failure.
		Although Release also flushes memory buffers to disk, it has no capacity to return any error codes upon failure.
		Therefore, calling Release without first calling <Commit> causes indeterminate results. 
	*/
	Commit(flags)
	{
		return this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "Ptr", this.ptr, "UInt", flags))
	}

	/*
	Method: Revert
	discards all changes that have been made to the storage object since the last commit operation.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Revert()
	{
		return this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "Ptr", this.ptr))
	}

	/*
	Method: EnumElements
	retrieves an enumerator object that can be used to enumerate the storage and stream objects contained within this storage object.

	Returns:
		EnumSTATSTG enumerator - the enumerator, either as class instance (if available) or raw interface pointer

	Remarks:
		The storage object must be open in read mode to allow the enumeration of its elements.
	*/
	EnumElements()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "Ptr", this.ptr, "UInt", 0, "Ptr", 0, "UInt", 0, "Ptr*", out)) ; msdn: param #1-#3 are reserved
		return IsObject(EnumSTATSTG) ? new EnumSTATSTG(out) : out
	}

	/*
	Method: DestroyElement
	removes the specified storage or stream from this storage object.

	Parameters:
		STR name - the name of the storage or stream to be removed

	Returns:
		BOOL success - true on success, false otherwise
	*/
	DestroyElement(name)
	{
		return this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "Ptr", this.ptr, "Str", name))
	}

	/*
	Method: RenameElement
	renames the specified substorage or stream in this storage object.

	Parameters:
		STR oldName - the name of the substorage or stream to be changed
		STR newName - the new name for the specified substorage or stream

	Returns:
		BOOL success - true on success, false otherwise
	*/
	RenameElement(oldName, newName)
	{
		return this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "Ptr", this.ptr, "Str", oldName, "Str", newName))
	}

	/*
	Method: SetElementTimes
	sets the modification, access, and creation times of the specified storage element, if the underlying file system supports this method.

	Parameters:
		[opt] STR name - The name of the storage object element whose times are to be modified. If ommitted, the time is set on the root storage rather than one of its elements.
		[opt] FILETIME creationTime - Either the new creation time for the element or NULL if the creation time is not to be modified.
		[opt] FILETIME accessTime - Either the new access time for the element or NULL if the access time is not to be modified.
		[opt] FILETIME modTime - Either the new modification time for the element or NULL if the modification time is not to be modified.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetElementTimes(name := "", creationTime := 0, accessTime := 0, modTime := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "Ptr", this.ptr, "Ptr", name ? &name : 0, "Ptr", IsObject(creationTime) ? creationTime.ToStructPtr() : creationTime, "Ptr", IsObject(accessTime) ? accessTime.ToStructPtr() : accessTime, "Ptr", IsObject(modTime) ? modTime.ToStructPtr() : modTime))
	}

	/*
	Method: SetClass
	assigns the specified class identifier (CLSID) to this storage object.

	Parameters:
		CLSID clsid - the CLSID, either as string or raw memory pointer

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetClass(clsid)
	{
		local mem
		if !CCFramework.isInteger(clsid)
			VarSetCapacity(mem, 16, 00), clsid := CCFramework.String2GUID(clsid, &mem)
		return this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "Ptr", this.ptr, "Ptr", clsid))
	}

	/*
	Method: SetStateBits
	stores up to 32 bits of state information in this storage object. *This method is reserved for future use.*

	Parameters:
		UINT state - Specifies the new values of the bits to set. No legal values are defined for these bits; they are all reserved for future use and must not be used by applications.
		UINT mask - A binary mask indicating which bits in state are significant in this call.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetStateBits(state, mask)
	{
		return this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "Ptr", this.ptr, "UInt", state, "UInt", mask))
	}

	/*
	Method: Stat
	retrieves the STATSTG structure for this open storage object.

	Parameters:
		[opt] UINT flags - Specifies that some of the members in the STATSTG structure are not returned, thus saving a memory allocation operation. You may use the fields of the STATFLAG class for convenience.

	Returns:
		STATSTG info - the retrieved infromation, either as class instance (if available) or raw memory pointer
	*/
	Stat(flags := 0)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+17*A_PtrSize), "Ptr", this.ptr, "Ptr*", out, "UInt", flags))
		return IsObject(STATSTG) ? new STATSTG(out) : out
	}
}