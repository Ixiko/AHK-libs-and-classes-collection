/*
class: MMDeviceEnumerator
wraps the *IMMDeviceEnumerator* interface and provides methods for enumerating multimedia device resources.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/MMDeviceEnumerator)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd371399)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista, Windows 2008 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
	Constant classes - EDataFlow, ERole, DEVICE_STATE
	Other classes - MMDeviceCollection, MMDevice, (MMNotificationClient)
*/
class MMDeviceEnumerator extends Unknown
{
	/*
	Field: CLSID
	This is CLSID_MMDeviceEnumerator. It is required to create an instance.
	*/
	static CLSID := "{BCDE0395-E52F-467C-8E3D-C4579291692E}"

	/*
	Field: IID
	This is IID_IMMDeviceEnumerator. It is required to create an instance.
	*/
	static IID := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"

	/*
	Function: EnumAudioEndpoints
	generates a collection of audio endpoint devices that meet the specified criteria.

	Parameters:
		UINT dataFlow - The data-flow direction for the endpoint devices in the collection. You can use the fields of the EDataFlow enumeration class for convenience. You should set this parameter either EDataFlow.eRender or EDataFlow.eCapture.
		UINT mask - The state or states of the endpoints that are to be included in the collection. You can use a combination (or just one) of the fields in the DEVICE_STATE enumeration class for convenience.

	Returns:
		MMDeviceCollection collection - a new instance of the MMDeviceCollection class
	*/
	EnumAudioEndpoints(dataFlow, mask)
	{
		local devices
		this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr, "uint", dataFlow, "uint", mask, "ptr*", devices))
		return new MMDeviceCollection(devices)
	}

	/*
	Function: GetDefaultAudioEndpoint
	retrieves the default audio endpoint for the specified data-flow direction and role. 

	Parameters:
		UINT dataFlow - The data-flow direction for the endpoint device. You can use the fields of the EDataFlow enumeration class for convenience. You should set this parameter either EDataFlow.eRender or EDataFlow.eCapture.
		UINT role - The role of the endpoint device. You can use the fields of the ERole enumeration class for convenience. You should set this parameter either to ERole.eConsole, ERole.eMultimedia or ERole.eCommunications.

	Returns:
		MMDevice endpoint - a new instance of the MMDevice class

	Remarks:
		In Windows Vista, the MMDevice API supports device roles but the system-supplied user interface programs do not. The user interface in Windows Vista enables the user to select a default audio device for rendering and a default audio device for capture. When the user changes the default rendering or capture device, the system assigns all three device roles (eConsole, eMultimedia, and eCommunications) to that device. Thus, GetDefaultAudioEndpoint always selects the default rendering or capture device, regardless of which role is indicated by the role parameter. In a future version of Windows, the user interface might enable the user to assign individual roles to different devices. In that case, the selection of a rendering or capture device by GetDefaultAudioEndpoint might depend on the role parameter. Thus, the behavior of an audio application developed to run in Windows Vista might change when run in a future version of Windows. For more information, see <Device Roles in Windows Vista at http://msdn.microsoft.com/en-us/library/windows/desktop/dd370821(v=vs.85).aspx>.
	*/
	GetDefaultAudioEndpoint(dataFlow, role)
	{
		local device
		this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "ptr", this.ptr, "uint", dataFlow, "uint", role, "ptr*", device))
		return new MMDevice(device)
	}

	/*
	Function: GetDevice
	retrieves an audio endpoint device that is identified by an endpoint ID string.

	Parameters:
		STR id - a string containing the endpoint ID. The caller typically obtains this string from the IMMDevice::GetId method or from one of the methods in the IMMNotificationClient interface.

	Returns:
		MMDevice device - a new instance of the MMDevice class
	*/
	GetDevice(id)
	{
		local device
		this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "ptr", this.ptr, "str", id, "ptr*", device))
		return new MMDevice(device)
	}

	/*
	Function: RegisterEndpointNotificationCallback

	Parameters:
		MMNotificationClient client - either a MMNotificationClient instance or a pointer to it

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	RegisterEndpointNotificationCallback(client)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "ptr", this.ptr, "ptr", IsObject(client) ? client.ptr : client))
	}

	/*
	Function: UnregisterEndpointNotificationCallback

	Parameters:
		MMNotificationClient client - either a MMNotificationClient instance or a pointer to it

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	UnregisterEndpointNotificationCallback(client)
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "ptr", this.ptr, "ptr", IsObject(client) ? client.ptr : client))
	}
}