/*
class: MMDeviceCollection
wraps the *IMMDeviceCollection* interface and represents a collection of multimedia device resources.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/MMDeviceCollection)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd371395)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Other classes - MMDevice
*/
class MMDeviceCollection extends Unknown
{
	/*
	Field: IID
	This is IID_IMMDeviceCollection. It is required to create an instance.
	*/
	static IID := "{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: GetCount
	retrieves a count of the devices in the device collection.

	Returns:
		UINT count - the device count
	*/
	GetCount()
	{
		local count
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "uint*", count))
		return count
	}

	/*
	Method: Item
	retrieves the specified item in the device collection.

	Parameters:
		UINT index - The device number. If the collection contains n devices, the devices are numbered 0 to n–1.

	Returns:
		MMDevice device - the device, either as class instance (if available) or raw interface pointer
	*/
	Item(index)
	{
		local device
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", index, "ptr*", device))
		return new MMDevice(device)
	}
}