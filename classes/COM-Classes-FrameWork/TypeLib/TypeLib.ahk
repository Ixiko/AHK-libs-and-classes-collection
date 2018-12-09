/*
class: TypeLib
wraps the *ITypeLib* interface and is used for reading information about objects.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TypeLib)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221549)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - CCFramework, TypeInfo, TypeComp
	Constant classes - TYPEKIND, MEMBERID
	Structure classes - TLIBATTR
*/
class TypeLib extends Unknown
{
	/*
	Field: IID
	This is IID_ITypeLib. It is required to create an instance.
	*/
	static IID := "{00020402-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: FromFile
	(static) method that attempts to load a type library from the specified file (*.tlb, *.exe, *.dll, *.olb).

	Parameters:
		STR file - the path to the file
		[opt] UINT index - if the file is a *.dll , *.exe or *.olb, specifies the type library resource to load from that file. Defaults to 1.

	Returns:
		TypeLib lib - the loaded library instance
	*/
	FromFile(file, index := 1)
	{
		local out
		this._Error(DllCall("OleAut32.dll\LoadTypeLib", "str", file . "\" . index, "Ptr*", out))
		return new TypeLib(out)
	}

	/*
	Method: FromRegistry
	(static) method that attempts to load a registered type library

	Parameters:
		GUID guid - the GUID of the type library. This can either be a string or a memory pointer.
		SHORT vMajor - the major version of the library.
		SHORT vMinor - the minor version of the library.

	Returns:
		TypeLib lib - the loaded library instance

	Remarks:
		Might be of interest: If you're searching for the library containing some interface, look at HKEY_CLASSES_ROOT\Interface\{...iid goes here...}\TypeLib. The "(Default)" key might contain the type library GUID, the "Version" key contains the library version.
	*/
	FromRegistry(guid, vMajor, vMinor)
	{
		local mem, out

		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)

		this._Error(DllCall("OleAut32.dll\LoadRegTypeLib", "Ptr", guid, "UShort", vMajor, "UShort", vMinor, "UInt", 0, "ptr*", out))
		return new TypeLib(out)
	}

	/*
	Method: GetTypeInfoCount
	Provides the number of type descriptions that are in a type library.

	Returns:
		UINT count - the number of type descriptions
	*/
	GetTypeInfoCount()
	{
		this._Error(0)
		return DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr)
	}

	/*
	Method: GetTypeInfo
	Retrieves the specified type description in the library.

	Parameters:
		UINT index - the index of the type description to load.

	Returns:
		TypeInfo info - the type description
	*/
	GetTypeInfo(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", index, "ptr*", out))
		return IsObject(TypeInfo) ? new TypeInfo(out) : out
	}

	/*
	Method: GetTypeInfoType
	Retrieves the type of a type description.

	Parameters:
		UINT index - the index of the type description within the type library.

	Returns:
		UINT type - the type of the type description. You may compare this to the fields of the TYPEKIND helper class for convenience.
	*/
	GetTypeInfoType(index)
	{
		local type
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "UInt", index, "UInt*", type))
		return type
	}

	/*
	Method: GetTypeInfoOfGuid
	Retrieves the type description that corresponds to the specified GUID.

	Parameters:
		GUID guid - the GUID of the type description to retrieve. This can either be a string or a memory pointer.

	Returns:
		TypeInfo info - the retrieved TypeInfo
	*/
	GetTypeInfoOfGuid(guid)
	{
		local mem, out

		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)

		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "ptr", guid, "ptr*", out))
		return IsObject(TypeInfo) ? new TypeInfo(out) : out
	}

	/*
	Method: GetLibAttr
	Retrieves the structure that contains the library's attributes.

	Returns:
		TLIBATTR attr - the retrieved information

	Remarks:
		Use <ReleaseTLibAttr> to free the structure.
	*/
	GetLibAttr()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return TLIBATTR.FromStructPtr(out, false)
	}

	/*
	Method: GetTypeComp
	Enables a client compiler to bind to the types, variables, constants, and global functions for a library.

	Returns:
		TypeComp comp - The ITypeComp instance for this ITypeLib. A client compiler uses the methods in the ITypeComp interface to bind to types in ITypeLib, as well as to the global functions, variables, and constants defined in ITypeLib.
	*/
	GetTypeComp()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return IsObject(TypeComp) ? new TypeComp(out) : out
	}

	/*
	Method: GetDocumentation
	Retrieves the documentation string for the library, the complete Help file name and path, and the context identifier for the library Help topic in the Help file.

	Parameters:
		INT index - The index of the type description whose documentation is to be returned.
		[opt] byRef STR name - Receives the name of the specified item.
		[opt] byRef STR doc - Receives the documentation string for the specified item.
		[opt] byRef UINT context - Receives the Help context identifier (ID) associated with the specified item.
		[opt] byRef STR helpfile - Receives the fully-qualified name of the Help file.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If -1 is passed as index, the documentation for the library itself is returned.
	*/
	GetDocumentation(index, byRef name := "", byRef doc := "", byRef context := "", byRef helpfile := "")
	{
		local bool, pName, pDoc, pHelpfile
		bool := this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "Int", index, "ptr*", pName, "ptr*", pDoc, "UInt*", context, "ptr*", pHelpfile))
		name := StrGet(pName), doc := StrGet(pDoc), helpfile := StrGet(pHelpfile)
		return bool
	}

	/*
	Method: IsName
	Indicates whether a passed-in string contains the name of a type or member described in the library.

	Parameters:
		byRef STR name - The string to test. If this method is successful, name is modified to match the case (capitalization) found in the type library.

	Returns:
		BOOL found - true if the name was found, false otherwise.

	Remarks:
		If the name is not found, the error code might still be 0x00 (success).
	*/
	IsName(byRef name)
	{
		local hash, bool
		hash := DllCall("OleAut32.dll\LHashValOfName", "UInt", 0, "str", name)
		this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "str", name, "UInt", hash, "UInt*", bool))
		return bool
	}

	/*
	Method: FindName
	Finds occurrences of a type description in a type library. This may be used to quickly verify that a name exists in a type library.

	Parameters:
		byRef STR name - The name to search for.
		byRef UPTR descriptions - Receives an array of pointers to the type descriptions that contain the name specified.
		byRef UPTR ids - Receives an array of MEMBERIDs.
		byRef USHORT count - on entry, specifies the number of occurrences to search for. Receives the number of occurrences found on exit.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	FindName(byRef name, byRef descriptions, byRef ids, byRef count)
	{
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "str", name, "UInt", 0, "ptr*", descriptions, "uint*", ids, "Short*", count))
	}

	/*
	Method: ReleaseTLibAttr
	Releases the TLIBATTR originally obtained from <GetLibAttr>.

	Parameters:
		TLIBATTR attr - the structure
	*/
	ReleaseTLibAttr(attr)
	{
		this._Error(0)
		DllCall(NumGet(this.vt+12*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(attr) ? attr.GetOriginalPointer() : attr)
	}
}