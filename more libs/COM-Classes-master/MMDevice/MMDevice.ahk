/*
class: MMDevice
wraps the *IMMDevice* interface and encapsulates the generic features of a multimedia device resource.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/MMDevice)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd371395)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - CLSCTX, DEVICE_STATE, STGM
	Structure classes - (PROPVARIANT)
	Other classes - CCFramework, PropertyStore
*/
class MMDevice extends Unknown
{
	/*
	Field: IID
	This is IID_IMMDevice. It is required to create an instance.
	*/
	static IID := "{D666063F-1587-4E43-81F1-B948E807363F}"

	/*
	Field: ThrowOnCreation
	indicates that attempting to create an instance of this class without supplying a valid pointer should throw an exception.
	*/
	static ThrowOnCreation := true

	/*
	Method: Activate
	creates a COM object with the specified interface.

	Parameters:
		GUID iid - The interface identifier. This parameter is a reference to a GUID that identifies the interface that the caller requests be activated. This can either be passed as raw pointer or string.
		UINT ctx - The execution context in which the code that manages the newly created object will run. The caller can restrict the context by setting this parameter to the bitwise OR of one or more CLSCTX enumeration values.
		[opt] PROPVARIANT params - stream-initialization information. See the msdn docs (http://msdn.microsoft.com/en-us/library/windows/desktop/dd371405).

	Returns:
		PTR obj - a raw interface pointer to the activated object.

	Remarks:
		- The supported interfaces for the "iid" parameter are: IAudioClient, IAudioEndpointVolume, IAudioMeterInformation, IAudioSessionManager, IAudioSessionManager2,
		IBaseFilter, IDeviceTopology, IDirectSound, IDirectSound8, IDirectSoundCapture, IDirectSoundCapture8, IMFTrustedOutput
	*/
	Activate(iid, ctx, params := 0)
	{
		local obj, mem
		if !CCFramework.isInteger(iid)
			VarSetCapacity(mem, 16, 00), iid := CCFramework.String2GUID(iid, &mem)
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "ptr", iid, "uint", clsctx, "uint", params, "ptr*", obj))
		return obj
	}

	/*
	Method: OpenPropertyStore
	retrieves an interface to the device's property store.

	Parameters:
		UINT access - The storage-access mode. This parameter specifies whether to open the property store in read mode, write mode, or read/write mode. You may use the fields of the STGM class for convenience.

	Returns:
		PropertyStore store - the property store, either as class instance (if available) or raw memory pointer.
	*/
	OpenPropertyStore(access)
	{
		local store
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", access, "ptr*", store))
		return IsObject(PropertyStore) ? new PropertyStore(store) : store
	}

	/*
	Method: GetId
	retrieves an endpoint ID string that identifies the audio endpoint device.

	Returns:
		STR id - the endpoint id
	*/
	GetId()
	{
		local id
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "ptr*", id))
		return StrGet(id)
	}

	/*
	Method: GetState
	retrieves the current device state.

	Returns:
		UINT state - the current state of the device. You may compare this against the fields in the DEVICE_STATE enumeration class for convenience.
	*/
	GetState()
	{
		local state
		this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "uint*", state))
		return state
	}
}