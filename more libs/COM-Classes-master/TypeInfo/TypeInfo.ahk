/*
class: TypeInfo
wraps the *ITypeInfo* interface and is used for reading information about objects.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TypeInfo)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221696)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - CCFramework, TypeLib, TypeComp
	Constant classes - DISPID, MEMBERID, TYPEKIND, DISPATCHF
	Structure classes - TYPEATTR, IDLDESC, TYPEDESC, ARRAYDESC, DISPPARAMS, EXCEPINFO
*/
class TypeInfo extends Unknown
{
	/*
	Field: IID
	This is IID_ITypeInfo. It is required to create an instance.
	*/
	static IID := "{00020401-0000-0000-C000-000000000046}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetTypeAttr
	Retrieves a TYPEATTR structure that contains the attributes of the type description.

	Returns:
		TYPEATTR info - an instance of the TYPEATTR class containing the information

	Remarks:
		Free the returned structure by passing it to <ReleaseTypeAttr>.
	*/
	GetTypeAttr()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return TYPEATTR.FromStructPtr(out, false)
	}

	/*
	Method: GetTypeComp
	Retrieves the ITypeComp interface for the type description, which enables a client compiler to bind to the type description's members.

	Returns:
		TypeComp comp - the retrieved interface
	*/
	GetTypeComp()
	{
		local out
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "ptr*", out))
		return IsObject(TypeComp) ? new TypeComp(out) : out
	}

	/*
	Method: GetFuncDesc
	Retrieves the FUNCDESC structure that contains information about a specified function.

	Parameters:
		UINT index - The index of the function whose description is to be returned. The index should be in the range of 0 to 1 less than the number of functions in this type.

	Returns:
		FUNCDESC func - the retrieved structure that describes the specified function

	Remarks:
		Use <ReleaseFuncDesc> to free the structure.
	*/
	GetFuncDesc(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "UInt", index, "ptr*", out))
		return IsObject(FUNCDESC) ? FUNCDESC.FromStructPtr(out, false) : out
	}

	/*
	Method: GetVarDesc
	Retrieves a VARDESC structure that describes the specified variable.

	Parameters:
		UINT index - The index of the variable whose description is to be returned. The index should be in the range of 0 to 1 less than the number of variables in this type.

	Returns:
		VARDESC var - A VARDESC that describes the specified variable.

	Remarks:
		Use <ReleaseVarDesc> to free the structure.
	*/
	GetVarDesc(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "UInt", index, "ptr*", out))
		return IsObject(VARDESC) ? VARDESC.FromStructPtr(out, false) : out
	}

	/*
	Method: GetNames
	Retrieves the variable with the specified member ID or the name of the property or method and the parameters that correspond to the specified function ID.

	Parameters:
		INT memid - The ID of the member whose name (or names) is to be returned. For special values, you might use the MEMBERID (or DISPID) enum class for convenience.
		byRef STR[] array - receives an AHK-array containing the names
		[opt] byRef UINT count - receives the number of names retrieved
		[opt] UINT name_count - optional: the size of the array. Defaults to 100, which should be sufficient in most cases.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	GetNames(memid, byRef array, byRef count := "", name_count := 100)
	{
		local arr, bool
		VarSetCapacity(arr, name_count * A_PtrSize, 0)
		bool := this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "Int", memid, "ptr", &arr, "UInt", name_count, "UInt*", count))
		array := []
		Loop count
		{
			array.Insert(StrGet(NumGet(&arr + (A_Index - 1) * A_PtrSize, 00, "UPtr"), "UTF-16"))
		}
		return bool
	}

	/*
	Method: GetRefTypeOfImplType
	If a type description describes a COM class, it retrieves the type description of the implemented interface types. For an interface, GetRefTypeOfImplType returns the type information for inherited interfaces, if any exist.

	Parameters:
		UINT index - The index of the implemented type whose handle is returned. The valid range is 0 to the cImplTypes field in the TYPEATTR structure.

	Returns:
		UINT handle - A handle for the implemented interface (if any). This handle can be passed to <GetRefTypeInfo()> to get the type description.
	*/
	GetRefTypeOfImplType(index)
	{
		local handle
		this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "UInt", index, "UInt*", handle))
		return handle
	}

	/*
	Method: GetImplTypeFlags
	Retrieves the IMPLTYPEFLAGS enumeration for one implemented interface or base interface in a type description.

	Parameters:
		UINT index - The index of the implemented interface or base interface for which to get the flags.

	Returns:
		UINT flags - The IMPLTYPEFLAGS enumeration value.
	*/
	GetImplTypeFlags(index)
	{
		local flags
		this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "UInt", index, "UInt*", flags))
		return flags
	}

	/*
	Method: GetIDsOfNames
	Maps between member names and member IDs, and parameter names and parameter IDs.

	Parameters:
		STR[] names - either an AHK-array or a pointer or a memory array containing the names
		[opt] UINT count - the count of the names in the array. If an AHK-array is passed, you can leave this empty.

	Returns:
		MEMBERID[] ids - an AHK-array containing the IDs
	*/
	GetIDsOfNames(names, count := -1)
	{
		local names_array, id_array, ids
		if IsObject(names)
		{
			if (count == -1)
				count := names.maxIndex()
			VarSetCapacity(names_array, A_PtrSize * count, 00)
			Loop count
			{
				NumPut(names.GetAdress(A_Index), names_array, A_PtrSize * (A_Index - 1), "UPtr")
			}
			names := &names_array
		}
		VarSetCapacity(id_array, 4 * count, 00)
		this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "ptr", names, "UInt", count, "UPtr", &id_array))
		ids := []
		Loop count
		{
			ids.Insert(NumGet(id_array, (A_Index - 1) * 4, "UInt"))
		}
		return ids
	}

	/*
	Method: Invoke
	Invokes a method, or accesses a property of an object, that implements the interface described by the type description.

	Parameters:
		PTR instance - a pointer to an instance (or a class instance) of the interface described by this type description.
		UINT memid - the member id identifying the member to be called.
		USHORT flags - Flags describing the context of the invoke call. You may use the fields of the DISPATCHF enum class for convenience.
		byRef DISPPARAMS params - An array of arguments, an array of DISPIDs for named arguments, and counts of the number of elements in each array.
		[opt] byRef VARIANT result - if the method returns anything, this receives a VARIANT wrapper object (or a pointer if CCFramework is not available)
		[opt] byRef EXCEPINFO exception - receives information about an exception if it occured
		[opt] byRef err_index - if there is an argument with an invalid type, this receives the index of this argument

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	Invoke(instance, memid, flags, byRef params, byRef result := "", byRef exception := "", byRef err_index := 0)
	{
		local bool := this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(instance) ? instance.ptr : instance, "UInt", memid, "UShort", flags, "Ptr", params := IsObject(params) ? params.ToStructPtr() : params, "Ptr*", result, "Ptr*", exception, "UInt*", err_index))
		params := IsObject(DISPPARAMS) ? DISPPARAMS.FromStructPtr(params) : params
		, result := IsObject(CCFramework) ? CCFramework.BuildVARIANT(result) : result
		, exception := IsObject(EXCEPINFO) ? EXCEPINFO.FromStructPtr(exception, false) : exception
		return bool
	}

	/*
	Method: GetDocumentation
	Retrieves the documentation string, the complete Help file name and path, and the context ID for the Help topic for a specified type description.

	Parameters:
		INT id - The member id of the member whose documentation is to be returned. For some special cases, you may use the fields of the MEMBERID class for convenience.
		[opt] byRef STR name - Receives the name of the specified item.
		[opt] byRef STR doc - Receives the documentation string for the specified item.
		[opt] byRef UINT context - Receives the Help context identifier (ID) associated with the specified item.
		[opt] byRef STR helpfile - Receives the fully-qualified name of the Help file.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If MEMBERID.NIL is passed as id, the documentation for the type information itself is returned.
	*/
	GetDocumentation(id, byRef name := "", byRef doc := "", byRef context := "", byRef helpfile := "")
	{
		local bool, pName, pDoc, pHelpfile
		bool := this._Error(DllCall(NumGet(this.vt+12*A_PtrSize), "ptr", this.ptr, "Int", id, "ptr*", pName, "ptr*", pDoc, "UInt*", context, "ptr*", pHelpfile))
		name := StrGet(pName), doc := StrGet(pDoc), helpfile := StrGet(pHelpfile)
		return bool
	}

	/*
	Method: GetDllEntry
	Retrieves a description or specification of an entry point for a function in a DLL.

	Parameters:
		INT id - The ID of the member whose documentation is to be returned. For some special cases, you may use the fields of the MEMBERID class for convenience.
		UINT invkind - The kind of member identified by id. This is important for properties, because one id can identify up to three separate functions. You may use the fields of the INVOKEKIND class for convenience.
		[opt] byRef STR dll - receives the name of the DLL.
		[opt] byRef STR name - receives the name of the entry point. If the entry point is specified by an ordinal, this argument is null.
		[opt] byRef SHORT ordinal - if the function is defined by an ordinal, receives the ordinal.

	Returns:
		BOOL success - true on success, false otherwise

	Remarks:
		If there is no DLL entry point for the function, an error occurs.
	*/
	GetDllEntry(id, invkind, byRef dll := "", byRef name := "", byRef ordinal := 0)
	{
		local bool, pDll, pName
		bool := this._Error(DllCall(NumGet(this.vt+13*A_PtrSize), "ptr", this.ptr, "Uint", id, "UInt", invkind, "ptr*", pDll, "ptr*", pName, "Short*", ordinal))
		dll := StrGet(pDll), name := StrGet(pName)
		return bool
	}

	/*
	Method: GetRefTypeInfo
	If a type description references other type descriptions, this retrieves the referenced type descriptions.

	Parameters:
		UINT handle - A handle to the referenced type description to return, such as returned by <GetRefTypeOfImplType()>.

	Returns:
		TypeInfo referenced - a TypeInfo instance for the referenced type
	*/
	GetRefTypeInfo(handle)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+14*A_PtrSize), "ptr", this.ptr, "UInt", handle, "ptr*", out))
		return new TypeInfo(out)
	}

	/*
	Method: AddressOfMember
	Retrieves the addresses of static functions or variables, such as those defined in a DLL.

	Parameters:
		UINT id - the ID of the static member whose address is to be retrieved. In some special cases, you may use the fields of MEMBERID class for convenience.
		[opt] UINT kind - Indicates whether the member is a property, and if so, what kind. You may use the fields of the INVOKEKIND class for convenience. If the member is not a property, you may leave this empty.

	Returns:
		PTR adress - the address of the member. The address is valid until the caller releases its reference to the type description.
	*/
	AddressOfMember(id, kind := 0)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+15*A_PtrSize), "ptr", this.ptr, "UInt", id, "UInt", kind, "UPtr*", out))
		return out
	}

	/*
	Method: CreateInstance
	Creates a new instance of a type that describes a component object class (coclass).

	Parameters:
		IUnknown outer - The controlling IUnknown. If Null, then a stand-alone instance is created. If valid, then an aggregate object is created. (whatever that means)
		IID iid - An ID for the interface that the caller will use to communicate with the resulting object.

	Returns:
		PTR obj - a pointer to the instance of the created object.

	Remarks:
		For types that describe a component object class (coclass), CreateInstance creates a new instance of the class. Normally, CreateInstance calls CoCreateInstance with the type description's GUID. For an Application object, it first calls GetActiveObject. If the application is active, GetActiveObject returns the active object; otherwise, if GetActiveObject fails, CreateInstance calls CoCreateInstance.
	*/
	CreateInstance(outer, iid)
	{
		local mem, out

		if !CCFramework.isInteger(iid)
			VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(iid, &mem)

		this._Error(DllCall(NumGet(this.vt+16*A_PtrSize), "ptr", this.ptr, "ptr", IsObject(outer) ? outer.ptr : outer, "ptr", iid, "ptr*", out))
		return out
	}

	/*
	Method: GetMops
	Retrieves marshaling information.

	Parameters:
		UINT id - The member ID that indicates which marshaling information is needed. In some special cases, you may use the fields of MEMBERID class for convenience.

	Returns:
		STR mops - The opcode string used in marshaling the fields of the structure described by the referenced type description, or null if there is no information to return.

	Remarks:
		If the passed-in member ID is MEMBERID.NIL, the function returns the opcode string for marshaling the fields of the structure described by the type description.
	*/
	GetMops(id)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+17*A_PtrSize), "ptr", this.ptr, "UInt", id, "Ptr*", out))
		return StrGet(out)
	}

	/*
	Method: GetContainingTypeLib
	Retrieves the containing type library and the index of the type description within that type library.

	Parameters:
		[opt] byRef TypeInfo lib - receives a TypeLib instance containing the type description
		[opt] byRef UINT index - receives the index of the type description within the containing type library.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetContainingTypeLib(byRef lib := "", byRef index := 0)
	{
		local bool, out
		bool := this._Error(DllCall(NumGet(this.vt+18*A_PtrSize), "ptr", this.ptr, "Ptr*", out, "UInt*", index))
		lib := IsObject(TypeLib) ? new TypeLib(out) : out
		return bool
	}

	/*
	Method: ReleaseTypeAttr
	Releases a TYPEATTR previously returned by <GetTypeAttr()>.

	Parameters:
		TYPEATTR attr - the structure to release
	*/
	ReleaseTypeAttr(attr)
	{
		DllCall(NumGet(this.vt+19*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(attr) ? attr.GetOriginalPointer() : attr)
	}

	/*
	Method: ReleaseFuncDesc
	Releases a FUNCDESC previously returned by <GetFuncDesc()>.

	Parameters:
		FUNCDESC attr - the structure to release
	*/
	ReleaseFuncDesc(attr)
	{
		DllCall(NumGet(this.vt+20*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(attr) ? attr.GetOriginalPointer() : attr)
	}

	/*
	Method: ReleaseVarDesc
	Releases a VARDESC previously returned by <GetVarDesc()>.

	Parameters:
		VARDESC attr - the structure to release
	*/
	ReleaseVarDesc(attr)
	{
		DllCall(NumGet(this.vt+21*A_PtrSize), "Ptr", this.ptr, "Ptr", IsObject(attr) ? attr.GetOriginalPointer() : attr)
	}
}