/*
class: TypeInfo2
wraps the *ITypeInfo2* interface and is used for reading information about objects.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TypeInfo2)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221565)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown, TypeInfo
	Other classes - CCFramework
	Constant classes - DISPID, MEMBERID, INVOKEKIND, TYPEFLAG, TYPEKIND
*/
class TypeInfo2 extends TypeInfo
{
	/*
	Field: IID
	This is IID_ITypeInfo2. It is required to create an instance.
	*/
	static IID := "{00020412-0000-0000-C000-000000000046}"

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
	group: ITypeInfo2 methods

	Method: GetTypeKind
	Returns the TYPEKIND enumeration value quickly, without doing any allocations.

	Returns:
		UINT kind - the kind of this type. You may compare this against the fields in the TYPEKIND enum class for convenience.
	*/
	GetTypeKind()
	{
		local kind
		this._Error(DllCall(NumGet(this.vt+22*A_PtrSize), "Ptr", this.ptr, "UInt*", kind))
		return kind
	}

	/*
	Method: GetTypeFlags
	Returns the type flags for this type without any allocations.

	Returns:
		UINT flags - the flags for this type. You may compare this against the fields in the TYPEFLAG class for convenience.
	*/
	GetTypeFlags()
	{
		local flags
		this._Error(DllCall(NumGet(this.vt+23*A_PtrSize), "Ptr", this.ptr, "UInt*", flags))
		return flags
	}

	/*
	Method: GetFuncIndexOfMemId
	Binds to a specific member based on a known DISPID, where the member name is not known (for example, when binding to a default member).

	Parameters:
		UINT id - the member identifier. For some special values (default members) you may use the fields of the MEMBERID enum class for convenience.
		UINT invkind - The invoke kind. You may use the fields of the INVOKEKIND class for convenience.

	Returns:
		UINT index - the index of the function
	*/
	GetFuncIndexOfMemId(id, invkind)
	{
		local index
		this._Error(DllCall(NumGet(this.vt+24*A_PtrSize), "Ptr", this.ptr, "UInt", id, "UInt", invkind, "UInt*", index))
		return index
	}

	/*
	Method: GetVarIndexOfMemId
	Binds to a specific member based on a known DISPID, where the member name is not known (for example, when binding to a default member).

	Parameters:
		UINT id - the member identifier. For some special values (default members) you may use the fields of the MEMBERID enum class for convenience.

	Returns:
		UINT index - the index of the variable
	*/
	GetVarIndexOfMemId(id)
	{
		local index
		this._Error(DllCall(NumGet(this.vt+25*A_PtrSize), "Ptr", this.ptr, "UInt", id, "UInt*", index))
		return index
	}

	/*
	Method: GetCustData
	Gets the custom data.

	Parameters:
		GUID guid - The GUID used to identify the data. This may either be passed as string or raw memory pointer.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetCustData(guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+26*A_PtrSize), "Ptr", this.ptr, "Ptr", guid, "Ptr*", variant))
		return CCFramework.BuildVARIANT(variant)
	}

	/*
	Method: GetFuncCustData
	Gets the custom data from the specified function.

	Parameters:
		UINT index - The index of the function for which to get the custom data.
		GUID guid - The GUID used to identify the data. This may either be passed as string or raw memory pointer.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetFuncCustData(index, guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+27*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr", guid, "Ptr*", variant))
		return CCFramework.BuildVARIANT(variant)
	}

	/*
	Method: GetParamCustData
	Gets the specified custom data parameter.

	Parameters:
		UINT indexFunc - The index of the function for which to get the custom data.
		UINT indexParam - The index of the parameter of this function for which to get the custom data.
		GUID guid - The GUID used to identify the data. This may either be passed as string or raw memory pointer.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetParamCustData(indexFunc, indexParam, guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+28*A_PtrSize), "Ptr", this.ptr, "UInt", indexFunc, "UInt", indexParam, "Ptr", guid, "Ptr*", variant))
		return CCFramework.BuildVARIANT(variant)
	}

	/*
	Method: GetVarCustData
	Gets the variable for the custom data.

	Parameters:
		UINT index - The index of the variable for which to get the custom data.
		GUID guid - The GUID used to identify the data. This may either be passed as string or raw memory pointer.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetVarCustData(index, guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+29*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr", guid, "Ptr*", variant))
		return CCFramework.BuildVARIANT(variant)
	}

	/*
	Method: GetImplTypeCustData
	Gets the implementation type of the custom data.

	Parameters:
		UINT index - The index of the implementation type for the custom data.
		GUID guid - The GUID used to identify the data. This may either be passed as string or raw memory pointer.

	Returns:
		VARIANT value - a VARIANT wrapper object for the value. (see the documentation on CCFramework.CreateVARIANT() for a description)
	*/
	GetImplTypeCustData(index, guid)
	{
		local mem, variant
		if !CCFramework.isInteger(guid)
			VarSetCapacity(mem, 16, 00), guid := CCFramework.String2GUID(guid, &mem)
		this._Error(DllCall(NumGet(this.vt+30*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr", guid, "Ptr*", variant))
		return CCFramework.BuildVARIANT(variant)
	}

	/*
	Method: GetDocumentation2
	Retrieves the documentation string, the complete Help file name and path, the localization context to use, and the context ID for the library Help topic in the Help file.

	Parameters:
		UINT id - The member identifier for the type description.
		[opt] UINT lcid - The locale identifier.
		[opt] byRef STR help - receives the name of the specified item.
		[opt] byRef UINT context - receives the Help localization context.
		[opt] byRef STR dll - receives the fully-qualified name of the file containing the DLL used for Help file.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		This function will call *_DLLGetDocumentation* in the specified DLL to retrieve the desired Help string, if there is a Help string context for this item. If no Help string context exists or an error occurs, then it will defer to the ITypeInfo::GetDocumentation method and return the associated documentation string.
	*/
	GetDocumentation2(id, lcid := 0, byRef help := "", byRef context := 0, ByRef dll := "")
	{
		local bool, pHelp, pDll
		bool := this._Error(DllCall(NumGet(this.vt+31*A_PtrSize), "Ptr", this.ptr, "UInt", id, "UInt", lcid, "Ptr*", pHelp, "UInt*", context, "Ptr*", pDll))
		help := StrGet(pHelp), dll := StrGet(pDll)
		return bool
	}

	/*
	Method: GetAllCustData
	Gets all custom data items for the type.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllCustData()
	{
		local data
		this._Error(DllCall(NumGet(this.vt+32*A_PtrSize), "Ptr", this.ptr, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}

	/*
	Method: GetAllFuncCustData
	Gets all custom data from the specified function.

	Parameters:
		UINT index - The index of the function for which to get the custom data.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllFuncCustData(index)
	{
		local data
		this._Error(DllCall(NumGet(this.vt+33*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}

	/*
	Method: GetAllParamCustData
	Gets all of the custom data for the specified function parameter.

	Parameters:
		UINT indexFunc - The index of the function for which to get the custom data.
		UINT indexParam - The index of the parameter of this function for which to get the custom data.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllParamCustData(indexFunc, indexParam)
	{
		local data
		this._Error(DllCall(NumGet(this.vt+34*A_PtrSize), "Ptr", this.ptr, "UInt", indexFunc, "UInt", indexParam, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}

	/*
	Method: GetAllVarCustData
	Gets the variable for the custom data.

	Parameters:
		UINT index - The index of the variable for which to get the custom data.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllVarCustData(index)
	{
		local data
		this._Error(DllCall(NumGet(this.vt+35*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}

	/*
	Method: GetAllImplTypeCustData
	Gets all custom data for the specified implementation type.

	Parameters:
		UINT index - The index of the implementation type for the custom data.

	Returns:
		CUSTDATA data - The custom data items, either as CUSTDATA class instance (if available) or as raw memory pointer.

	Remarks:
		When no longer needed, pass the return value to the <ClearCustData> method to release it.
	*/
	GetAllImplTypeCustData(index)
	{
		local data
		this._Error(DllCall(NumGet(this.vt+36*A_PtrSize), "Ptr", this.ptr, "UInt", index, "Ptr*", data))
		return IsObject(CUSTDATA) ? new CUSTDATA(data) : data
	}
}