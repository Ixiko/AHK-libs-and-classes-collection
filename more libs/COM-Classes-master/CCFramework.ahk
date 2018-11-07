/*
class: CCFramework
the main class for the framework that has a lot of methods to ease the handling of other classes.

Remarks:
	This class cannot be instantiated.
*/
class CCFramework extends _CCF_Error_Handler_
{
	/*
	Field: heap
	static field that holds the process heap. For internal use only.
	*/
	static heap := DllCall("GetProcessHeap", "UPtr")

	/*
	Method: constructor
	throws an exception when an attempt is made to create an instance of this class
	*/
	__New(p*)
	{
		throw Exception("CCFramework: This class must not be instantiated!", -1)
	}

	/*
	Method: GUID2String
	Converts a GUID structure in memory to its string representation.

	Parameters:
		UPTR guid - the pointer to the GUID structure

	Returns:
		STR string - the string representation of the GUID.
	*/
	GUID2String(guid)
	{
		local string
		DllCall("Ole32.dll\StringFromCLSID", "UPtr", guid, "UPtr*", string)
		return StrGet(string, "UTF-16")
	}

	/*
	Method: String2GUID
	Converts a string represntation of a GUID to a GUID structure in memory.

	Parameters:
		STR string - the string representation
		[opt] UPTR guid - the pointer where to place the GUID in memory.

	Returns:
		UPTR guid - the pointer to the GUID structure.

	Remarks:
		If the "guid" parameter is ommitted, memory is allocted using <AllocateMemory>. In this case, you may pass the pointer returned by this method to <FreeMemory()> when you don't need the GUID any longer.
	*/
	String2GUID(string, guid := 0)
	{
		if (!guid)
			guid := CCFramework.AllocateMemory(16)
		return DllCall("ole32\CLSIDFromString", "Str", string, "UPtr", guid) >= 0 ? guid : 0
	}

	/*
	Method: AllocateMemory
	allocates a specified amount of memory

	Parameters:
		UINT bytes - the number of bytes to allocate

	Returns:
		UPTR buffer - the pointer to the allocated memory.

	Remarks:
		When you no longer need the memory, you should pass the pointer returned by this method to <FreeMemory()>.
	*/
	AllocateMemory(bytes)
	{
		static HEAP_GENERATE_EXCEPTIONS := 0x00000004, HEAP_ZERO_MEMORY := 0x00000008
		return DllCall("HeapAlloc", "UPtr", CCFramework.heap, "UInt", HEAP_GENERATE_EXCEPTIONS|HEAP_ZERO_MEMORY, "UInt", bytes)
	}

	/*
	Method: FreeMemory
	Frees memory previously allocated by <AllocateMemory>.

	Parameters:
		UPTR buffer - the memory pointer as returned by <AllocateMemory()>.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	FreeMemory(buffer)
	{
		return DllCall("HeapFree", "UPtr", CCFramework.heap, "UInt", 0, "UPtr", buffer)
	}

	/*
	Method: CopyMemory
	Copies memory from one locatin to another

	Parameters:
		UPTR src - the pointer to the source memory
		UPTR dest - the pointer to the memory to copy data to
		UINT size - the number of bytes to copy
	*/
	CopyMemory(src, dest, size)
	{
		DllCall("RtlMoveMemory", "UPtr", dest, "UPtr", src, "UInt", size)
	}

	/*
	Method: CreateVARIANT
	creates a VARIANT wrapper object from a given value

	Parameters:
		VAR value - the value to store in the VARIANT structure

	Returns:
		OBJ variant - an object representing the variant, containing 3 fields:
			PTR ref - the pointer to the VARIANT structure
			UINT vt - the value type of the VARIANT structure
			VAR value - the value in the structure: a string, integer, pointer, COM wrapper object (for dispatch objects), ...

	Remarks:
		The type is calculated automatically based on the value. If you want it to have a special type, create a value with ComObjParameter:
		> dispVariant := CCFramework.CreateVARIANT(ComObjParameter(VT_DISPATCH, disp_ptr))
	*/
	CreateVARIANT(value)
	{
		static VT_VARIANT := 0xC, VT_BYREF := 0x4000, VT_UNKNOWN := 0xD
		local array, arr_data, variant, err

		err := ComObjError(false)
		if (IsObject(value) && value.HasKey("ref") && value.HasKey("vt") && value.HasKey("value"))
			return value
		ComObjError(err)

		array := ComObjArray(VT_VARIANT, 1)
		array[0] := value

		DllCall("oleaut32\SafeArrayAccessData", "Ptr", ComObjValue(array), "Ptr*", arr_data)
		variant := CCFramework.AllocateMemory(16), CCFramework.CopyMemory(arr_data, variant, 16)
		DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", ComObjValue(array))

		return { "ref" : variant, "vt" : NumGet(1*variant, 00, "UShort"), "value" : NumGet(1*variant, 00, "UShort") == VT_UNKNOWN ? NumGet(1*variant, 08, "Ptr") : array[0] }
	}

	/*
	Method: CreateVARIANTARG
	an alias for <CreateVARIANT>.
	*/
	CreateVARIANTARG(value)
	{
		return CCFramework.CreateVARIANT(value)
	}

	/*
	Method: BuildVARIANT
	builds a VARIANT wrapper object from a given pointer

	Parameters:
		PTR ptr - the pointer to the VARIANT structure in memory

	Returns:
		OBJ variant - see <CreateVARIANT>
	*/
	BuildVARIANT(ptr)
	{
		return CCFramework.CreateVARIANT(ComObjParameter(NumGet(1*ptr, 00, "UShort"), NumGet(1*ptr, 08, "Int64")))
	}

	/*
	Method: BuildVARIANTARG
	an alias for <BuildVARIANT>.
	*/
	BuildVARIANTARG(ptr)
	{
		return CCFramework.BuildVARIANT(ptr)
	}

	/*
	Method: FormatError
	retrieves the error message for a HRESULT error code

	Parameters:
		HRESULT error - the error code, e.g. A_LastError

	Returns:
		STR description - the error message

	Credits:
		Inspired by Bentschi's A_LastError() (<http://de.autohotkey.com/forum/viewtopic.php?t=8010>)
	*/
	FormatError(error)
	{
		static ALLOCATE_BUFFER := 0x00000100, FROM_SYSTEM := 0x00001000, IGNORE_INSERTS := 0x00000200
		local size, msg, bufaddr

		size := DllCall("FormatMessageW", "UInt", ALLOCATE_BUFFER|FROM_SYSTEM|IGNORE_INSERTS, "UPtr", 0, "UInt", error, "UInt", 0, "UPtr*", bufaddr, "UInt", 0, "UPtr", 0)
		msg := StrGet(bufaddr, size, "UTF-16")

		return error . " - " . msg
	}

	/*
	Method: isInteger
	for AHK v2, this replaces "if var is integer".

	Parameters:
		VAR value - the value to test

	Returns:
		BOOL isInt - true if the value is an integer, false otherwise

	Credits:
		Thanks jaco0646 for this code! (<http://www.autohotkey.com/forum/viewtopic.php?p=507283#507283>)
	*/
	isInteger(value)
	{
		return Type(value) == "Integer" || RegExMatch(Trim(value),"^[+-]?([[:digit:]]+|(0x)?[[:xdigit:]]+)$")
	}

	/*
	Method: HasEnumFlag
	checks if a given binary combination of flags includes a specified flag

	Parameters:
		UINT var - the combination to test
		UINT flag - the flag to test for

	Returns:
		BOOL included - true if the flag is included, false otherwise

	Remarks:
		All flags added to "var" as well as "flag" must be powers of 2.
	*/
	HasEnumFlag(var, flag)
	{
		return (var & flag) == flag
	}
}