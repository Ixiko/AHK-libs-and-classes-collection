/*
class: STATSTG
a structure class that contains statistical data about an open storage, stream, or byte-array object. This is used by he IEnumSTATSTG, ILockBytes, IStorage, and IStream interfaces.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/STATSTG)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/aa380319)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, StructBase
	Constant classes - LOCKTYPE
	Structure classes - FILETIME
*/
class STATSTG extends StructBase
{
	/*
	Field: pwcsName
	a string that contains the name. Space for this string is allocated by the method called and freed by the caller. To not return this member, specify the STATFLAG.NONAME value when you call a method that returns a STATSTG structure, except for calls to IEnumSTATSTG::Next, which provides no way to specify this value.
	*/
	pwcsName := 0

	/*
	Field: type
	Indicates the type of storage object. This is one of the values from the STGTY enumeration.
	*/
	type := 0

	/*
	Field: cbSize
	Specifies the size, in bytes, of the stream or byte array.
	*/
	cbSize := 0

	/*
	Field: mtime
	A FILETIME instance that indicates the last modification time for this storage, stream, or byte array.
	*/
	mtime := new FILETIME()

	/*
	Field: ctime
	A FILETIME instance that indicates the creation time for this storage, stream, or byte array.
	*/
	ctime := new FILETIME()

	/*
	Field: atime
	A FILETIME structure that indicates the last access time for this storage, stream, or byte array.
	*/
	atime := new FILETIME()

	/*
	Field: grfMode
	Indicates the access mode specified when the object was opened. This member is only valid in calls to Stat methods.
	*/
	grfMode := 0

	/*
	Field: grfLocksSupported
	Indicates the types of region locking supported by the stream or byte array. For more information about the values available, see the LOCKTYPE enumeration. This member is not used for storage objects.
	*/
	grfLocksSupported := 0

	/*
	Field: clsid
	Indicates the class identifier for the storage object; set to CLSID_NULL for new storage objects. This member is not used for streams or byte arrays.

	Remarks:
		When retrieved from an instance created by <FromStructPtr()>, this is a GUID string.
		Otherwise, you may either set it to a string or a raw memory pointer to the GUID.
	*/
	clsid := 0

	/*
	Field: grfStateBits
	Indicates the current state bits of the storage object; that is, the value most recently set by the IStorage::SetStateBits method. This member is not valid for streams or byte arrays.
	*/
	grfStateBits := 0

	/*
	Field: reserved
	Reserved for future use.
	*/
	reserved := 0

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

		NumPut(this.GetAdress("pwcsName"),	1*ptr,		00 + 0*A_PtrSize,	"UPtr")
		NumPut(this.type,					1*ptr,		00 + 1*A_PtrSize,	"UInt")
		NumPut(this.cbSize,					1*ptr,		04 + 1*A_PtrSize,	"UInt64")
		this.mtime.ToStructPtr(ptr + 12 + A_PtrSize)
		this.ctime.ToStructPtr(ptr + 20 + A_PtrSize)
		this.atime.ToStructPtr(ptr + 28 + A_PtrSize)
		NumPut(this.grfMode,				1*ptr,		36 + 1*A_PtrSize,	"UInt")
		NumPut(this.grfLocksSupported,		1*ptr,		40 + 1*A_PtrSize,	"UInt")

		if !CCFramework.isInteger(this.clsid)
			CCFramework.String2GUID(this.clsid, ptr + 44 + A_PtrSize)
		else
			CCFramework.CopyMemory(this.clsid, ptr + 44 + A_PtrSize, 16)

		NumPut(this.grfStateBits,			1*ptr,		60 + 1*A_PtrSize,	"UInt")
		NumPut(this.reserved,				1*ptr,		64 + 1*A_PtrSize,	"UInt")

		return ptr
	}

	/*
	Method: FromStructPtr
	(static) method that converts a script-usable struct into a new instance of the class

	Parameters:
		UPTR ptr - a pointer to a STATSTG struct in memory
		[opt] BOOL own - false if the instance must no release the pointer (defaults to true)

	Returns:
		STATSTG instance - the new STATSTG instance
	*/
	FromStructPtr(ptr, own := true)
	{
		local instance := new STATSTG()
		instance.SetOriginalPointer(ptr, own)

		instance.pwcsName			:= StrGet(NumGet(1*ptr, 0,	"UPtr"),	"UTF-16")
		instance.type				:= NumGet(1*ptr,	00 + 1*A_PtrSize,	"UInt")
		instance.cbSize				:= NumGet(1*ptr,	04 + 1*A_PtrSize,	"UInt64")
		instance.mtime := FILETIME.FromStructPtr(ptr + 12 + A_PtrSize, false)
		instance.ctime := FILETIME.FromStructPtr(ptr + 20 + A_PtrSize, false)
		instance.atime := FILETIME.FromStructPtr(ptr + 28 + A_PtrSize, false)
		instance.grfMode			:= NumGet(1*ptr,	36 + 1*A_PtrSize,	"UInt")
		instance.grfLocksSupported	:= NumGet(1*ptr,	40 + 1*A_PtrSize,	"UInt")
		instance.clsid				:= CCFramework.GUID2String(ptr + 44 + A_PtrSize)
		instance.grfStateBits		:= NumGet(1*ptr,	60 + 1*A_PtrSize,	"UInt")
		instance.reserved			:= NumGet(1*ptr,	64 + 1*A_PtrSize,	"UInt")

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
		return A_PtrSize + 44 + 3 * FILETIME.GetRequiredSize()
	}
}