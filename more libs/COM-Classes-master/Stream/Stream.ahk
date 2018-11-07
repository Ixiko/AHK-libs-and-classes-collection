/*
class: Stream
wraps the *IStream* interface and lets you read and write data to stream objects.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/Stream)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380034)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional, Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown, SequentialStream
	Constant classes - STGC, LOCKTYPE, STATFLAG, STREAM_SEEK
	Structure classes - STATSTG
*/
class Stream extends SequentialStream
{
	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Field: IID
	This is IID_IStream. It is required to create an instance.
	*/
	static IID := "{0000000c-0000-0000-C000-000000000046}"
	
	/*
	group: constructors

	Method: FromHGlobal
	As this class does not support direct creation, you can use this method to create an instance from a handle, e.g. a HICON.

	Parameters:
		UPTR handle - the handle to create a stream from
		[opt] BOOL autoRelease - indicates whether the underlying handle provided should be freed automatically if the object is released.

	Returns:
		Stream stream - the created instance
	*/
	FromHGlobal(handle, autoRelease := true)
	{
		local ptr
		this._Error(DllCall("Ole32.dll\CreateStreamOnHGlobal", "UPtr", handle, "UInt", autoRelease, "ptr*", ptr))
		return new Stream(ptr)
	}

	/*
	Method: Seek
	changes the seek pointer to a new location. The new location is relative to either the beginning of the stream, the end of the stream, or the current seek pointer.

	Parameters:
		INT64 move - the displacement to be added to the location indicated by the dwOrigin parameter.
		UINT dwOrigin - The origin for the displacement specified in move. You can use the fields of the STREAM_SEEK class for convenience.

	Returns:
		UINT64 newPos - the location where this method writes the value of the new seek pointer from the beginning of the stream.
	*/
	Seek(move, dwOrigin)
	{
		local pos
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "int64", move, "uint", dwOrigin, "Uint64*", pos))
		return pos
	}

	/*
	Method: SetSize
	changes the size of the stream object.

	Parameters:
		UINT64 newsize - Specifies the new size of the stream as a number of bytes.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	SetSize(newsize)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "uint64", newsize))
	}

	/*
	Method: CopyTo
	copies a specified number of bytes from the current seek pointer in the stream to the current seek pointer in another stream.

	Parameters:
		Stream destination - either a Stream instance or a pointer to the IStream instance to copy the bytes to.
		UINT64 byteCount - The number of bytes to copy from the source stream.
		[opt] byRef UINT64 bytesRead - receives the number of bytes actually read from the source stream
		[opt] byRef UINT64 bytesWritten - receives the number of byteCount actually written to the destination

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	CopyTo(destination, byteCount, byRef bytesRead := "", byRef bytesWritten := "")
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "uptr", (IsObject(destination) ? destination.ptr : destination), "uint64", byteCount, "uint64*", bytesRead, "uint64*", bytesWritten))
	}

	/*
	Method: Commit
	ensures that any changes made to a stream object open in transacted mode are reflected in the parent storage.

	Parameters:
		UINT flags - Controls how the changes for the stream object are committed. You may use the fields of the STGC enumeration class for convenience.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	Commit(flags)
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "uint", flags))
	}

	/*
	Method: Revert
	This method has no effect.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	Revert()
	{
		return this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: LockRegion
	restricts access to a specified range of bytes in the stream.

	Parameters:
		UINT64 offset - specifies the byte offset for the beginning of the range.
		UINT64 byteCount - specifies the length of the range, in bytes, to be restricted.
		UINT lockType - specifies the restrictions being requested on accessing the range. You may use the fields of the LOCKTYPE enumeration class for convenience.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	LockRegion(offset, byteCount, lockType)
	{
		return this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "uint64", offset, "uint64", byteCount, "uint", lockType))
	}

	/*
	Method: UnlockRegion
	removes the access restriction on a range of bytes previously restricted with IStream::LockRegion.

	Parameters:
		UINT64 offset - specifies the byte offset for the beginning of the range.
		UINT64 byteCount - specifies the length of the range, in bytes, to be restricted.
		UINT lockType - specifies the access restrictions previously placed on the range. You may use the fields of the LOCKTYPE enumeration class for convenience.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	UnlockRegion(offset, byteCount, lockType)
	{
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "uint64", offset, "uint64", byteCount, "uint", lockType))
	}

	/*
	Method: Stat
	retrieves the STATSTG structure for this stream.

	Parameters:
		[opt] UINT flag - indicates certain members to omit from the structure. You can use the fields of the STATFLAG enumeration class for convenience.

	Returns:
		STATSTG info - the STATSTG instance for the stream
	*/
	Stat(flag := 0)
	{
		static stat_size := STATSTG.GetRequiredSize()
		local struct := CCFramework.AllocateMemory(stat_size)
		this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "ptr", this.ptr, "ptr", struct, "uint", flag))
		return STATSTG.FromStructPtr(struct)
	}

	/*
	Method: Clone
	creates a new stream object with its own seek pointer that references the same bytes as the original stream.

	Returns:
		Stream clone - the cloned stream instance
	*/
	Clone()
	{
		local ptr
		this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "ptr", this.ptr, "ptr*", ptr))
		return new Stream(ptr)
	}
}