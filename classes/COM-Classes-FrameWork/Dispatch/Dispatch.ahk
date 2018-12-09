/*
class: Dispatch
wraps the *IDispatch* interface and exposes objects, methods and properties to programming tools and other applications that support Automation. COM components implement the IDispatch interface to enable access by Automation clients, such as Visual Basic.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/Dispatch)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms221608)

Requirements:
	AutoHotkey - AHK v2 alpha
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - CCFramework, TypeInfo
	Constant classes - DISPID, MEMBERID, DISPATCHF
	Structure classes - DISPPARAMS, EXCEPINFO
*/
class Dispatch extends Unknown
{
	/*
	group: constructor methods

	Method: FromOBJECT
	creates an instance of this class from a scripting object.

	Parameters:
		COMOBJECT obj - the AHK COM object to create an instance for

	Returns:
		Dispatch instance - the newly created instance
	*/
	FromOBJECT(obj)
	{
		return new Dispatch(ComObjUnwrap(obj))
	}

	/*
	group: IDispatch methods

	Method: GetTypeInfoCount
	Retrieves the number of type information interfaces that an object provides (either 0 or 1).

	Returns:
		UINT count - The number of type information interfaces provided by the object. If the object provides type information, this number is 1; otherwise the number is 0.
	*/
	GetTypeInfoCount()
	{
		local count
		this._Error(DllCall(NumGet(this.vt, 03*A_PtrSize, "Ptr"), "Ptr", this.ptr, "UInt*", count, "Int"))
		return count
	}

	/*
	GetTypeInfo
	Retrieves the type information for an object, which can then be used to get the type information for an interface.

	Parameters:
		UINT index - The type information to return. Pass 0 to retrieve type information for the IDispatch implementation.
		[opt] UINT lcid - The locale identifier for the type information. Defaults to 0.

	Returns:
		TypeInfo info - The requested type information object, either as class instance (if available) or as raw interface pointer.
	*/
	GetTypeInfo(index, lcid := 0)
	{
		local out
		this._Error(DllCall(NumGet(this.vt, 04*A_PtrSize, "Ptr"), "Ptr", this.ptr, "UInt", index, "UInt", lcid, "Ptr*", out, "Int"))
		return IsObject(TypeInfo) ? new TypeInfo(out) : out
	}

	/*
	Method: GetIDsOfNames
	Maps a single member and an optional set of argument names to a corresponding set of integer DISPIDs, which can be used on subsequent calls to <Invoke>.

	Parameters:
		STR[] names - either an AHK-array or a pointer or a memory array containing the names
		[opt] UINT count - the count of the names in the array. If an AHK-array is passed, you can leave this empty.

	Returns:
		MEMBERID[] ids - an AHK-array containing the IDs
	*/
	GetIDsOfNames(names, count := -1, lcid := 0)
	{
		local names_array, id_array, ids
		if IsObject(names)
		{
			if (count == -1)
				count := names.maxIndex()
			VarSetCapacity(names_array, A_PtrSize * count, 00)
			Loop count
			{
				NumPut(names.GetAdress(A_Index), names_array, A_PtrSize * (A_Index - 1), "Ptr")
			}
			names := &names_array
		}
		VarSetCapacity(id_array, 4 * count, 00)
		this._Error(DllCall(NumGet(this.vt, 05*A_PtrSize, "Ptr"), "Ptr", this.ptr, "Ptr", 0, "Ptr", names, "UInt", count, "UInt", lcid, "Ptr", &id_array, "Int")) ; msdn: param #1 is reserved
		ids := []
		Loop count
		{
			ids.Insert(NumGet(id_array, (A_Index - 1) * 4, "UInt"))
		}
		return ids
	}

	/*
	Method: Invoke
	Provides access to properties and methods exposed by an object.

	Parameters:
		UINT memid - the member id identifying the member to be called.
		USHORT flags - Flags describing the context of the invoke call. You may use the fields of the DISPATCHF enum class for convenience.
		byRef DISPPARAMS params - An array of arguments, an array of DISPIDs for named arguments, and counts of the number of elements in each array.
		[opt] byRef VARIANT result - if the method returns anything, this receives a VARIANT wrapper object (or a pointer if CCFramework is not available)
		[opt] byRef EXCEPINFO exception - receives information about an exception if it occured
		[opt] byRef err_index - if there is an argument with an invalid type, this receives the index of this argument
		[opt] UINT lcid - The locale context in which to interpret arguments. Defaults to 0.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	Invoke(memid, flags, byRef params, byRef result := "", byRef exception := "", byRef err_index := 0, lcid := 0)
	{
		local bool := this._Error(DllCall(NumGet(this.vt, 06*A_PtrSize, "Ptr"), "Ptr", this.ptr, "UInt", memid, "Ptr", 0, "UInt", lcid, "UShort", flags, "Ptr", params := IsObject(params) ? params.ToStructPtr() : params, "Ptr*", result, "Ptr*", exception, "UInt*", err_index, "Int"))
		params := IsObject(DISPPARAMS) ? DISPPARAMS.FromStructPtr(params) : params
		, result := IsObject(CCFramework) ? CCFramework.BuildVARIANT(result) : result
		, exception := IsObject(EXCEPINFO) ? EXCEPINFO.FromStructPtr(exception, false) : exception
		return bool
	}
}