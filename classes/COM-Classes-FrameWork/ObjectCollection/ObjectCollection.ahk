/*
class: ObjectCollection
wraps the *IObjectCollection* interface and extends the IObjectArray interface by providing methods that enable clients to add and remove objects that support IUnknown in a collection.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ObjectCollection)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd378307)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 2008 R2 or higher
	Base classes - _CCF_Error_Handler_, Unknown, ObjectArray
*/
class ObjectCollection extends ObjectArray
{
	/*
	Field: IID
	This is IID_IObjectCollection. It is required to create an instance.
	*/
	static IID := "{5632b1a4-e38a-400a-928a-d4cd63230295}"

	/*
	Method: AddObject
	Adds a single object to the collection.

	Parameters:
		IUnknown obj - the object to add, either as raw interface pointer or as class instance.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	AddObject(obj)
	{
		if IsObject(obj)
			obj := obj.ptr
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "ptr", obj))
	}

	/*
	Method: AddFromArray
	Adds the objects contained in an IObjectArray to the collection.

	Parameters:
		ObjectArray array - the array whose contents are to be added to the collection, either as raw interface pointer or as class instance

	Returns:
		BOOL success - true on success, false otherwise
	*/
	AddFromArray(array)
	{
		if IsObject(array)
			array := array.ptr
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "ptr", array))
	}

	/*
	Method: RemoveObjectAt
	Removes a single, specified object from the collection.

	Parameters:
		UINT index - the index of the object within the collection.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	RemoveObjectAt(index)
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "uint", index))
	}

	/*
	Method: Clear
	Removes all objects from the collection.

	Returns:
		BOOL success - true on success, false otherwise
	*/
	Clear()
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "ptr", this.ptr))
	}
}