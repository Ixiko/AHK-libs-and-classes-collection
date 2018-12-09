/*
class: PropertyStoreCache
wraps the *IPropertyStoreCache* interface and exposes methods that allow a handler to manage various states for each property.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PropertyStoreCache)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb761466)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown, PropertyStore
	Constant classes - PSC
	Structure classes - PROPERTYKEY, (PROPVARIANT)
*/
class PropertyStoreCache extends PropertyStore
{
	/*
	Field: IID
	This is IID_IPropertyStoreCache. It is required to create an instance.
	*/
	static IID := "{3017056d-9a91-4e90-937d-746c72abbf4f}"

	/*
	Method: GetState
	Gets the state of a specified property key.

	Parameters:
		PROPERTYKEY key - either a raw memory pointer or a PROPERTYKEY class instance that identifies the key.

	Returns:
		UINT state - the property key's state. You may compare this to the fields of the PSC class for convenience.
	*/
	GetState(key)
	{
		local state
		if IsObject(key)
			key := key.ToStructPtr()
		this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr, "ptr", key, "uint*", state))
		return state
	}

	/*
	Method: GetValueAndState
	Gets value and state data for a property key.

	Parameters:
		PROPERTYKEY key - either a raw memory pointer or a PROPERTYKEY class instance identifying the property.
		byRef PROPVARIANT value - receives the property's value as a pointer to a PROPVARIANT struct *(to be replaced by class instance)*.
		byRef UINT state - receives the property's state. You may compare this to the fields of the PSC class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	GetValueAndState(key, byRef value, byRef state)
	{
		local bool, val
		if IsObject(key)
			key := key.ToStructPtr()
		val := CCFramework.AllocateMemory(16) ; PROPVARIANT.GetRequiredSize()
		bool := this._Error(DllCall(NumGet(this.vt+09*A_PtrSize), "ptr", this.ptr, "ptr", key, "ptr", val, "uint*", state))
		;value := PROPVARIANT.FromStructPtr(val)
		return bool
	}

	/*
	Method: SetState
	Sets the property state of a specified property key.

	Parameters:
		PROPERTYKEY key - either a raw memory pointer or a PROPERTYKEY class instance identifying the property.
		UINT state - the property's state. You may use the fields of the PSC class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetState(key, state)
	{
		if IsObject(key)
			key := key.ToStructPtr()
		return this._Error(DllCall(NumGet(this.vt+10*A_PtrSize), "ptr", this.ptr, "ptr", key, "uint", state))
	}

	/*
	Method: SetValueAndState
	Sets value and state data for a property key.

	Parameters:
		PROPERTYKEY key - either a raw memory pointer or a PROPERTYKEY class instance identifying the property.
		PROPVARIANT value - the property's value either as a raw memory pointer or as a PROPVARIANT instance *(yet to be realized)*.
		UINT state - the property's state. You may use the fields of the PSC class for convenience.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	SetValueAndState(key, value, state)
	{
		if IsObject(key)
			key := key.ToStructPtr()
		if IsObject(value)
			value := value.ToStructPtr()
		return this._Error(DllCall(NumGet(this.vt+11*A_PtrSize), "ptr", this.ptr, "ptr", key, "ptr", value, "uint", state))
	}
}