/*
class: TypeLib2
wraps the *ITypeLib2* interface and represents a type library, the data that describes a set of objects.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TypeLib2)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221256)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown, TypeLib
	Other classes - CCFramework
	Structure classes - CUSTDATA
*/
class TypeLib2 extends TypeLib
{
	/*
	Field: IID
	This is IID_ITypeLib2. It is required to create an instance.
	*/
	static IID := "{00020411-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	group: helper methods

	Method: ClearCustData
	Releases memory used to hold a custom data item.

	Parameters:
		CUSTDATA data - the data to release, either as CUSTDATA class instance or raw memory pointer
	*/
	ClearCustData(data)
	{
		DllCall("OleAut32\ClearCustData", "Ptr", IsObject(data) ? data.GetOriginalPointer() : data)
	}

	/*
	group: ITypeLib2 methods

	Method: GetCustData
	Gets the custom data.

	Parameters:
		GUID guid - The GUID used to identify the data.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetCustData(guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "Ptr", this.ptr, "Ptr", guid, "Ptr*", variant))
		return IsObject(CCFramework) ? CCFramework.BuildVARIANT(variant) : variant
	}

	/*
	Method: GetLibStatistics
	Returns statistics about a type library that are required for efficient sizing of hash tables.

	Parameters:
		[opt] byRef UINT unique - receives a count of unique names.
		[opt] byRef UINT changeUnique - receives a change in the count of unique names.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetLibStatistics(byRef unique := 0, byRef changeUnique := 0)
	{
		return this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "Ptr", this.ptr, "UInt*", unique, "UInt*", changeUnique))
	}

	/*
	Method: GetDocumentation2
	Retrieves the library's documentation string, the complete Help file name and path, the localization context to use, and the context ID for the library Help topic in the Help file.

	Parameters:
		INT index - The index of the type description whose documentation is to be returned. If index is -1, then the documentation for the library is returned.
		[opt] UINT lcid - The locale identifier.
		[opt] byRef STR help - receives the name of the specified item.
		[opt] byRef UINT context - receives the Help localization context.
		[opt] byRef STR dll - The fully-qualified name of the file containing the DLL used for Help file.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetDocumentation2(index, lcid := 0, help := "", context := 0, dll := "")
	{
		local bool, pHelp, pDll
		bool := this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "Ptr",this.ptr, "Int", index, "UInt", lcid, "Ptr*", pHelp, "UInt*", context, "Ptr*", pDll))
		help := StrGet(pHelp), dll := StrGet(pDll)
		return bool
	}

	/*
	Method: GetAllCustData
	Gets all custom data items for the library.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllCustData()
	{
		local data
		this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "Ptr", this.ptr, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}
}