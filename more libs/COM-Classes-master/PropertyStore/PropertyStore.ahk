/*
class: PropertyStore
wraps the *IPropertyStore* interface and exposes methods for enumerating, getting, and setting property values.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PropertyStore)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761474)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Structure classes - PROPERTYKEY
*/
class PropertyStore extends Unknown
{
	/*
	Field: IID
	This is IID_IPropertyStore. It is required to create an instance.
	*/
	static IID := "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}"

	/*
	Field: CLSID
	This is CLSID_InMemoryPropertyStore. It is required to create an instance.
	*/
	static CLSID := "{9a02e012-6303-4e1e-b9a1-630f802592c5}"

	/*
	Method: GetCount
	Gets the number of properties attached to the file.

	Returns:
		UINT count - the property count
	*/
	GetCount()
	{
		local count
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "uint*", count))
		return count
	}

	/*
	Method: GetAt
	Gets a property key from an item's array of properties.

	Parameters:
		UINT index - The index of the property key in the array of PROPERTYKEY structures. This is a zero-based index.

	Returns:
		UPTR ptr - a PROPERTYKEY instance
	*/
	GetAt(index)
	{
		local out
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", index, "ptr*", out))
		return PROPERTYKEY.FromStructPtr(out)
	}

	/*
	Method: GetValue
	Gets data for a specific property.

	Parameters:
		PROPERTYKEY key - a reference to the PROPERTYKEY structure retrieved through IPropertyStore::GetAt (either a raw memory pointer or a PROPERTYKEY instance).

	Parameters:
		UPTR ptr - a pointer to a PROPVARIANT structure *(To be replaced by PROPVARIANT instance!)*
	*/
	GetValue(key)
	{
		local out
		if IsObject(key)
			key := key.ToStructPtr()
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "ptr", key, "ptr*", out))
		return out
	}

	/*
	Method: SetValue
	Sets a new property value, or replaces or removes an existing value.

	Parameters:
		PROPERTYKEY key - a reference to the PROPERTYKEY structure retrieved through IPropertyStore::GetAt (either a raw memory pointer or a PROPERTYKEY instance).
		UPTR ptr - a pointer to a PROPVARIANT structure

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetValue(key, value)
	{
		if IsObject(key)
			key := key.ToStructPtr()
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "ptr", key, "ptr", value))
	}

	/*
	Method: Commit
	Saves a property change.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Commit()
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr))
	}
}