class IPortableDeviceManager extends IUnknown
{
  static iid := "{a1567595-4c2f-4574-a6fa-ecef917b9a40}"
		,clsid := "{0af10cec-2ecd-4b92-9581-34f6ae0637f3}"

	; Retrieves a list of portable devices connected to the computer.
	; The list of devices is generated when the device manager is instantiated; it does not refresh as devices connect and disconnect. To refresh the list of connected devices, call RefreshDeviceList.
	; The API allocates the memory for each string pointed to by the pPnPDeviceIDs array. Once your application no longer needs these strings, it must iterate through this array and free the associated memory by calling the CoTaskMemFree function.
	GetDevices(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",0
			,"uint*",pcPnPDeviceIDs
			,"uint"),"GetDevices")
		if pcPnPDeviceIDs{
			;pPnPDeviceIDs:=struct("ptr[" pcPnPDeviceIDs "]")
			VarSetCapacity(pPnPDeviceIDs,A_PtrSize*pcPnPDeviceIDs)
			_Error(DllCall(this.vt(3),"ptr",this.__
				,"ptr",&pPnPDeviceIDs
				,"uint*",pcPnPDeviceIDs
				,"uint"),"GetDevices")
			PnPDeviceID:=[]
			loop % pcPnPDeviceIDs
				PnPDeviceID[A_Index]:=StrGet(NumGet(pPnPDeviceIDs,(A_Index-1)*A_PtrSize),"utf-16")
				,DllCall("Ole32\CoTaskMemFree","ptr",NumGet(pPnPDeviceIDs,(A_Index-1)*A_PtrSize))
			return PnPDeviceID
		}
	}

	; The RefreshDeviceList method refreshes the list of devices that are connected to the computer.
	; When the IPortableDeviceManager interface is instantiated the first time, it generates a list of the devices that are connected. However, devices can connect and disconnect from the computer, making the original list obsolete. This method enables an application to refresh the list of connected devices.
	; This method is less resource-intensive than instantiating a new device manager to generate a new device list. However, it does require some resources; therefore, we recommend that you do not call this method arbitrarily. The best solution is to have the application register to get device arrival and removal notifications, and when a notification is received, have the application call this function.
	RefreshDeviceList(){
		return _Error(DllCall(this.vt(4),"ptr",this.__,"uint"),"RefreshDeviceList")
	}

	; Retrieves the user-friendly name for the device.
	; A device is not required to support this method. If this method fails to retrieve a name, try requesting the WPD_OBJECT_NAME property of the device object (the object with the ID WPD_DEVICE_OBJECT_ID).
	GetDeviceFriendlyName(pszPnPDeviceID){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",0
			,"uint*",pcchDeviceFriendlyName
			,"uint"),"GetDeviceFriendlyName")
		VarSetCapacity(pDeviceFriendlyName,pcchDeviceFriendlyName)	
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",&pDeviceFriendlyName
			,"uint*",pcchDeviceFriendlyName
			,"uint"),"GetDeviceFriendlyName")
		return StrGet(&pDeviceFriendlyName,"utf-16")
	}

	; Retrieves the description of a device.
	GetDeviceDescription(pszPnPDeviceID){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",pszPnPDeviceID
			,"ptr",0
			,"ptr",pcchDeviceDescription
			,"uint"),"GetDeviceDescription")
		VarSetCapacity(pDeviceDescription,pcchDeviceDescription)	
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",pszPnPDeviceID
			,"ptr",&pDeviceDescription
			,"ptr",pcchDeviceDescription
			,"uint"),"GetDeviceDescription")
		return StrGet(&pDeviceDescription,"utf-16")	
	}

	; Retrieves the name of the device manufacturer.
	GetDeviceManufacturer(pszPnPDeviceID){
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",pDeviceManufacturer
			,"uint*",pcchDeviceManufacturer
			,"uint"),"GetDeviceManufacturer")
		VarSetCapacity(pDeviceManufacturer,pcchDeviceManufacturer)
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",&pDeviceManufacturer
			,"uint*",pcchDeviceManufacturer
			,"uint"),"GetDeviceManufacturer")
		return StrGet(&pcchDeviceManufacturer,"utf-16")
	}

	; Retrieves a property value stored by the device on the computer. (These are not standard properties that are defined by Windows Portable Devices.)
	; These property values are stored on device installation, or stored by a device during operation so that they can be persisted across connection sessions. An application must know the exact name of the property, which is specified by the device itself; therefore, this method is intended to be used by device developers who are creating their own applications.
	; To get Windows Portable Devices properties from the device object, call IPortableDeviceProperties::GetValues, and specify the device object with WPD_DEVICE_OBJECT_ID.
	GetDeviceProperty(pszPnPDeviceID,pszDevicePropertyName){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"wstr",pszDevicePropertyName
			,"ptr",0
			,"uint*",pcbData
			,"uint*",pdwType
			,"uint"),"GetDeviceProperty")
		VarSetCapacity(pData,pcbData)
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"wstr",pszDevicePropertyName
			,"ptr",&pData
			,"uint*",pcbData
			,"uint*",pdwType
			,"uint"),"GetDeviceProperty")
		return ; not completed
	}

	; The GetPrivateDevices method retrieves a list of private portable devices connected to the computer. These private devices are only accessible through an application that is designed for these particular devices.
	; In order to write an application that communicates with a private device, you must have knowledge of the custom functionality exposed by a particular device driver. The description of this functionality must be obtained from the device manufacturer.
	; The list of devices is generated when the device manager is instantiated; it does not refresh as devices connect and disconnect. To refresh the list of connected devices, call RefreshDeviceList.
	; The API allocates the memory for each string pointed to by the pPnPDeviceIDs array. Once your application no longer needs these strings, it must iterate through this array and free the associated memory by calling the CoTaskMemFree function.
	; A private device may not respond correctly to the standard Windows Portable Devices function calls that perform object enumeration, resource transfer, retrieval of device capabilities, and so on.
	GetPrivateDevices(){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",0
			,"uint*",pcPnPDeviceIDs
			,"uint"),"GetPrivateDevices")
		if pcPnPDeviceIDs{
			pPnPDeviceIDs:=struct("ptr[" pcPnPDeviceIDs "]")
			_Error(DllCall(this.vt(9),"ptr",this.__
				,"ptr",pPnPDeviceIDs[]
				,"uint*",pcPnPDeviceIDs
				,"uint"),"GetPrivateDevices")
			PnPDeviceID:=[]
			loop % pcPnPDeviceIDs
				PnPDeviceID[A_Index]:=StrGet(pPnPDeviceIDs[A_Index])
				,DllCall("Ole32\CoTaskMemFree","ptr",pPnPDeviceIDs[A_Index])
			return PnPDeviceID
		}
	}
}

class IPortableDevice extends IUnknown
{
	static iid := "{625e2df8-6392-4cf0-9ad1-3cfa5f17775c}"
		,clsid := "{728a21c5-3d9e-48d7-9810-864848f0f404}"

	; The Open method opens a connection between the application and the device.
	; A device must be opened before you can call any methods on it. (Note that the IPortableDeviceManager methods do not require you to open a device before calling any methods.) However, usually you do not need to call Close.
	; Administrators can restrict the access of portable devices to computers running on a network. For example, an administrator may restrict all Guest users to read-only access, while Authenticated users are given read/write access.
	; Due to these security issues, if your application will not perform write operations, it should call the Open method and request read-only access by specifying GENERIC_READ for the WPD_CLIENT_DESIRED_ACCESS property that it supplies in the pClientInfo parameter.
	; If your application requires write operations, it should call the Open method as shown in the following example code. The first time, it should request read/write access by passing the default WPD_CLIENT_DESIRED_ACCESS property in the pClientInfo parameter. If this first call fails and returns E_ACCESSDENIED, your application should call the Open method a second time and request read-only access by specifying GENERIC_READ for the WPD_CLIENT_DESIRED_ACCESS property that it supplies in the pClientInfo parameter.
	; Applications that live in Single Threaded Apartments should use CLSID_PortableDeviceFTM, as this eliminates the overhead of interface pointer marshaling. CLSID_PortableDevice is still supported for legacy applications.
	Open(pszPnPDeviceID,pClientInfo){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",IsObject(pClientInfo)?pClientInfo.__:pClientInfo ; IPortableDeviceValues
			,"uint"),"Open")
	}

	; The SendCommand method sends a command to the device and retrieves the results synchronously.
	; More Remarks and Examples, http://msdn.microsoft.com/en-us/library/dd375691(v=vs.85).aspx
	SendCommand(pParameters){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"uint",0
			,"ptr",IsObject(pParameters)?pParameters.__:pParameters
			,"ptr",ppResults
			,"uint"),"SendCommand")
		return new IPortableDeviceValues(ppResults)
	}

	; The Content method retrieves an interface that you can use to access objects on a device.
	Content(){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",ppContent
			,"uint"),"Content")
		return new IPortableDeviceContent(ppContent)
	}

	; The Capabilities method retrieves an interface used to query the capabilities of a portable device.
	Capabilities(){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppCapabilities
			,"uint"),"Capabilities")
		return new IPortableDeviceCapabilities(ppCapabilities)
	}

	; The Cancel method cancels a pending operation on this interface.
	; If your application invokes the WPD API from multiple threads, each thread should create a new instance of the IPortableDevice interface. Doing this ensures that any cancel operation affects only the I/O for the affected thread.
	; If an IStream write operation is underway when the Cancel method is invoked, your application should discard all changes by invoking the IStream::Revert method. Once the changes are discarded, the application should also close the stream by invoking the IUnknown::Release method.
	; Also, note that if the Cancel method is invoked before an IStream::Write method has completed, the data being written may be corrupted.
	Cancel(){
		return _Error(DllCall(this.vt(7),"ptr",this.__,"uint"),"Cancel")
	}

	; The Close method closes the connection with the device.
	; You should not usually need to call this method yourself. When the last reference to the IPortableDevice interface is released, Windows Portable Devices calls Close for you. Calling this method manually forces the connection to the device to close, and any Windows Portable Devices objects hosted on this device will cease to function. You can call Open to reopen the connection.
	Close(){
		return _Error(DllCall(this.vt(8),"ptr",this.__,"uint"),"Close")
	}

	; The Advise method registers an application-defined callback that receives device events.
	Advise(dwFlags,pCallback){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"uint",dwFlags
			,"ptr",pCallback
			,"ptr",0
			,"ptr*",ppszCookie
			,"uint"),"Advise")
		return StrGet(ppszCookie,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppszCookie)
	}

	; The Unadvise method unregisters a client from receiving callback notifications. You must call this method if you called Advise previously.
	Unadvise(pszCookie){
		return _Error(DllCall(this.vt(10),"ptr",this.__
			,"wstr",pszCookie
			,"uint"),"Unadvise")
	}

	; The GetPnPDeviceID method retrieves the Plug and Play (PnP) device identifier that the application used to open the device.
	; After the application is through using the string returned by this method, it must call the CoTaskMemFree function to free the string.
	; The ppszPnPDeviceID argument must not be set to NULL.
	GetPnPDeviceID(ppszPnPDeviceID){
		_Error(DllCall(this.vt(11),"ptr",this.__
			,"ptr*",ppszPnPDeviceID
			,"uint"),"GetPnPDeviceID")
		return StrGet(ppszPnPDeviceID,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppszPnPDeviceID)
	}
}

class IPortableDeviceValues extends IUnknown
{
	static iid := "{6848f6f2-3155-4f86-b6f5-263eeeab3143}"
		,clsid := "{0c15d503-d017-47ce-9016-7b3f978721cc}"

	; The GetCount method retrieves the number of items in the collection.
	GetCount(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint*",pcelt
			,"uint"),"GetCount")
		return pcelt
	}

	; The GetAt method retrieves a value from the collection using the supplied zero-based index.
	GetAt(index,pKey,pValue){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",index
			,"ptr",pKey ; PROPERTYKEY
			,"ptr",pValue ; PROPVARIANT
			,"uint"),"GetAt")
		return ; not completed
	}

	; The SetValue method adds a new PROPVARIANT value or overwrites an existing one.
	; When the VARTYPE for pValue is VT_VECTOR or VT_UI1, setting a NULL or zero-sized buffer is not supported. For example, neither pValue.caub.pElems = NULL nor pValue.caub.cElems = 0 are allowed.
	; This method can be used to retrieve a value of any type from the collection. However, if you know the value type in advance, use one of the specialized Set... methods of this interface to avoid the overhead of working with PROPVARIANT values directly.
	; If an existing value has the same key that is specified by the key parameter, it overwrites the existing value without any warning. The existing key memory is released appropriately.
	SetValue(key,pValue){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",key ; REFPROPERTYKEY
			,"ptr",pValue ; PROPVARIANT
			,"uint"),"SetValue")
		; not completed
	}

	; The GetValue method retrieves a PROPVARIANT value specified by a key.
	; When the VARTYPE for pValue is VT_VECTOR or VT_UI1, retrieving a NULL or zero-sized buffer is not supported. For example, neither pValue.caub.pElems = NULL nor pValue.caub.cElems = 0 are allowed.
	; This method can be used to retrieve a value of any type from the collection. However, if you know the value type in advance, use one of the specialized retrieval methods of this interface to avoid the overhead of working with PROPVARIANT values directly.
	GetValue(key){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",key
			,"ptr",pValue
			,"uint"),"GetValue")
		return pValue ; not completed
	}

	; The SetStringValue method adds a new string value (type VT_LPWSTR) or overwrites an existing one.
	; Any existing key memory will be released appropriately.
	SetStringValue(key,Value){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",key
			,"wstr",Value
			,"uint"),"SetStringValue")
	}

	; The GetStringValue method retrieves a string value (type VT_LPWSTR) specified by a key.
	GetStringValue(key){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"ptr",key
			,"ptr*",pValue
			,"uint"),"GetStringValue")
		return StrGet(pValue,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",pValue)
	}

	; The SetUnsignedIntegerValue method adds a new ULONG value (type VT_UI4) or overwrites an existing one.
	; If an existing value has the same key that is specified by the key parameter, it overwrites the existing value without any warning.
	SetUnsignedIntegerValue(key,Value){
		return _Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",key
			,"uint",Value
			,"uint"),"SetUnsignedIntegerValue")
	}

	; The GetUnsignedIntegerValue method retrieves a ULONG value (type VT_UI4) specified by a key.
	GetUnsignedIntegerValue(key){
		_Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr",key
			,"uint*",pValue
			,"uint"),"GetUnsignedIntegerValue")
		return pValue
	}

	; The SetSignedIntegerValue method adds a new LONG value (type VT_I4) or overwrites an existing one.
	SetSignedIntegerValue(key,Value){
		return _Error(DllCall(this.vt(11),"ptr",this.__
			,"ptr",key
			,"uint",Value
			,"uint"),"SetSignedIntegerValue")
	}

	; The GetSignedIntegerValue method retrieves a LONG value (type VT_I4) specified by a key.
	GetSignedIntegerValue(key){
		_Error(DllCall(this.vt(12),"ptr",this.__
			,"ptr",key
			,"int*",pValue
			,"uint"),"GetSignedIntegerValue")
		return pValue
	}

	; The SetUnsignedLargeIntegerValue method adds a new ULONGLONG value (type VT_UI8) or overwrites an existing one.
	SetUnsignedLargeIntegerValue(key,Value){
		return _Error(DllCall(this.vt(13),"ptr",this.__
			,"ptr",key
			,"uint64",Value
			,"uint"),"SetUnsignedLargeIntegerValue")
	}

	; The GetUnsignedLargeIntegerValue method retrieves a ULONGLONG value (type VT_UI8) specified by a key.
	GetUnsignedLargeIntegerValue(key){
		_Error(DllCall(this.vt(14),"ptr",this.__
			,"ptr",key
			,"uint64*",pValue
			,"uint"),"GetUnsignedLargeIntegerValue")
		return pValue
	}

	; The SetSignedLargeIntegerValue method adds a new LONGLONG value (type VT_I8) or overwrites an existing one.
	SetSignedLargeIntegerValue(key,Value){
		return _Error(DllCall(this.vt(15),"ptr",this.__
			,"ptr",key
			,"int64",Value
			,"uint"),"SetSignedLargeIntegerValue")
	}

	; The GetSignedLargeIntegerValue method retrieves a LONGLONG value (type VT_I8) specified by a key.
	GetSignedLargeIntegerValue(key){
		_Error(DllCall(this.vt(16),"ptr",this.__
			,"ptr",key
			,"int64*",pValue
			,"uint"),"GetSignedLargeIntegerValue")
		return pValue
	}

	; The SetFloatValue method adds a new FLOAT value (type VT_R4) or overwrites an existing one.
	SetFloatValue(key,Value){
		return _Error(DllCall(this.vt(17),"ptr",this.__
			,"ptr",key
			,"float",Value
			,"uint"),"SetFloatValue")
	}

	; The GetFloatValue method retrieves a FLOAT value (type VT_R4) specified by a key.
	GetFloatValue(key){
		_Error(DllCall(this.vt(18),"ptr",this.__
			,"ptr",key
			,"float*",pValue
			,"uint"),"GetFloatValue")
		return pValue
	}

	; The SetErrorValue method adds a new HRESULT value (type VT_ERROR) or overwrites an existing one.
	SetErrorValue(key,Value){
		return _Error(DllCall(this.vt(19),"ptr",this.__
			,"ptr",key
			,"int",Value
			,"uint"),"SetErrorValue")
	}

	; The GetErrorValue method retrieves an HRESULT value (type VT_ERROR) specified by a key.
	GetErrorValue(key){
		_Error(DllCall(this.vt(20),"ptr",this.__
			,"ptr",key
			,"int*",pValue
			,"uint"),"GetErrorValue")
		return pValue
	}

	; The SetKeyValue method adds a new REFPROPERTYKEY value (type VT_UNKNOWN) or overwrites an existing one.
	SetKeyValue(key,Value){
		return _Error(DllCall(this.vt(21),"ptr",this.__
			,"ptr",key
			,"ptr",Value
			,"uint"),"SetKeyValue")
	}

	; The GetKeyValue method retrieves a PROPERTYKEY value specified by a key.
	GetKeyValue(key){
		_Error(DllCall(this.vt(22),"ptr",this.__
			,"ptr",key
			,"ptr",pValue
			,"uint"),"GetKeyValue")
		return pValue ; not completed
	}

	; The SetBoolValue method adds a new Boolean value (type VT_BOOL) or overwrites an existing one.
	SetBoolValue(key,Value){
		return _Error(DllCall(this.vt(23),"ptr",this.__
			,"ptr",key
			,"int",Value
			,"uint"),"SetBoolValue")
	}

	; The GetBoolValue method retrieves a Boolean value (type VT_BOOL) specified by a key.
	GetBoolValue(key){
		_Error(DllCall(this.vt(24),"ptr",this.__
			,"ptr",key
			,"int*",pValue
			,"uint"),"GetBoolValue")
		return pValue
	}

	; The SetIUnknownValue method adds a new IUnknown value (type VT_UNKNOWN) or overwrites an existing one.
	SetIUnknownValue(key,pValue){
		return _Error(DllCall(this.vt(25),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue.__:pValue
			,"uint"),"SetIUnknownValue")
	}

	; The GetIUnknownValue method retrieves an IUnknown interface value (type VT_UNKNOWN) specified by a key.
	GetIUnknownValue(key){
		_Error(DllCall(this.vt(26),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint"),"GetIUnknownValue")
		return ppValue
	}

	; The SetGuidValue method adds a new GUID value (type VT_CLSID) or overwrites an existing one.
	SetGuidValue(key,Value){
		return _Error(DllCall(this.vt(27),"ptr",this.__
			,"ptr",key
			,"ptr",Value
			,"uint"),"SetGuidValue")
	}

	; The GetGuidValue method retrieves a GUID value (type VT_CLSID) specified by a key.
	GetGuidValue(key,ByRef pValue){
		VarSetCapacity(pValue,16)
		_Error(DllCall(this.vt(28),"ptr",this.__
			,"ptr",key
			,"ptr",&pValue
			,"uint"),"GetGuidValue")
		return &pValue
	}

	; The SetBufferValue method adds a new BYTE* value (type VT_VECTOR | VT_UI1) or overwrites an existing one.
	SetBufferValue(key,pValue,cbValue){
		return _Error(DllCall(this.vt(29),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue[]:pValue
			,"uint",cbValue
			,"uint"),"SetBufferValue")
	}

	; The GetBufferValue method retrieves a byte array value (type VT_VECTOR | VT_UI1) specified by a key.
	GetBufferValue(key,ByRef value){
		_Error(DllCall(this.vt(30),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint*",pcbValue
			,"uint"),"GetBufferValue")
		VarSetCapacity(value,pcbValue)
		DllCall("RtlMoveMemory","ptr",&value,"ptr",ppValue,"uint",pcbValue)
		DllCall("Ole32\CoTaskMemFree","ptr",ppValue)
		return pcbValue ; not completed
	}

	; The SetIPortableDeviceValuesValue method adds a new IPortableDeviceValues value (type VT_UNKNOWN) or overwrites an existing one.
	SetIPortableDeviceValuesValue(key,pValue){
		return _Error(DllCall(this.vt(31),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue.__:pValue
			,"uint"),"SetIPortableDeviceValuesValue")
	}

	; The GetIPortableDeviceValuesValue method retrieves an IPortableDeviceValues value (type VT_UNKNOWN) specified by a key.
	GetIPortableDeviceValuesValue(key){
		_Error(DllCall(this.vt(32),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint"),"GetIPortableDeviceValuesValue")
		return new IPortableDeviceValues(ppValue)
	}

	; The SetIPortableDevicePropVariantCollectionValue method adds a new IPortableDevicePropVariantCollection value (type VT_UNKNOWN) or overwrites an existing one.
	SetIPortableDevicePropVariantCollectionValue(key,pValue){
		return _Error(DllCall(this.vt(33),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue.__:pValue
			,"uint"),"SetIPortableDevicePropVariantCollectionValue")
	}

	; The GetIPortableDevicePropVariantCollectionValue method retrieves an IPortableDevicePropVariantCollection value (type VT_UNKNOWN) specified by a key.
	GetIPortableDevicePropVariantCollectionValue(key){
		_Error(DllCall(this.vt(34),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint"),"GetIPortableDevicePropVariantCollectionValue")
		return new IPortableDevicePropVariantCollection(ppValue)
	}

	; The SetIPortableDeviceKeyCollectionValue method adds a new SetIPortableDeviceKeyCollectionValue value (type VT_UNKNOWN) or overwrites an existing one.
	SetIPortableDeviceKeyCollectionValue(key,pValue){
		return _Error(DllCall(this.vt(35),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue.__:pValue
			,"uint"),"SetIPortableDeviceKeyCollectionValue")
	}

	; The GetIPortableDeviceKeyCollectionValue method retrieves an IPortableDeviceKeyCollection value (type VT_UNKNOWN) specified by a key.
	GetIPortableDeviceKeyCollectionValue(key){
		_Error(DllCall(this.vt(36),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint"),"GetIPortableDeviceKeyCollectionValue")
		return new IPortableDeviceKeyCollection(ppValue)
	}

	; The SetIPortableDeviceValuesCollectionValue method adds a new IPortableDeviceValuesCollection value (type VT_UNKNOWN) or overwrites an existing one
	SetIPortableDeviceValuesCollectionValue(key,pValue){
		return _Error(DllCall(this.vt(37),"ptr",this.__
			,"ptr",key
			,"ptr",IsObject(pValue)?pValue.__:pValue
			,"uint"),"SetIPortableDeviceValuesCollectionValue")
	}

	; The GetIPortableDeviceValuesCollectionValue method retrieves an IPortableDeviceValuesCollection value (type VT_UNKNOWN) specified by a key.
	GetIPortableDeviceValuesCollectionValue(key){
		_Error(DllCall(this.vt(38),"ptr",this.__
			,"ptr",key
			,"ptr*",ppValue
			,"uint"),"GetIPortableDeviceValuesCollectionValue")
		return new IPortableDeviceValuesCollection(ppValue)
	}

	; The RemoveValue method removes an item from the collection.
	RemoveValue(key){
		return _Error(DllCall(this.vt(39),"ptr",this.__
			,"ptr",key
			,"uint"),"RemoveValue")
	}

	; The CopyValuesFromPropertyStore method copies the contents of an IPropertyStore into the collection.
	CopyValuesFromPropertyStore(pStore){
		return _Error(DllCall(this.vt(40),"ptr",this.__
			,"ptr",IsObject(pStore)?pStore.__:pStore
			,"uint"),"CopyValuesFromPropertyStore")
	}

	; The CopyValuesToPropertyStore method copies all the values from a collection into an IPropertyStore interface.
	CopyValuesToPropertyStore(pStore){
		return _Error(DllCall(this.vt(41),"ptr",this.__
			,"ptr",IsObject(pStore)?pStore.__:pStore
			,"uint"),"CopyValuesToPropertyStore")
	}

	; The Clear method deletes all items from the collection.
	Clear(){
		return _Error(DllCall(this.vt(42),"ptr",this.__,"uint"),"Clear")
	}
}

class IPortableDeviceContent extends IUnknown
{
	static iid := "{6a96ed84-7c73-4480-9938-bf5af477d426}"

	; The EnumObjects method retrieves an interface that is used to enumerate the immediate child objects of an object. It has an optional filter that can enumerate objects with specific properties.
	EnumObjects(dwFlags,pszParentObjectID,pFilter){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint",dwFlags
			,"wstr",pszParentObjectID
			,"ptr",IsObject(pFilter)?pFilter.__:pFilter
			,"ptr*",ppEnum
			,"uint"),"EnumObjects")
		return new IEnumPortableDeviceObjectIDs(ppEnum)
	}

	; The Properties method retrieves the interface that is required to get or set properties on an object on the device.
	Properties(){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr*",ppProperties
			,"uint"),"Properties")
		return new IPortableDeviceProperties(ppProperties)
	}

	; The Transfer method retrieves an interface that is used to read from or write to the content data of an existing object resource.
	Transfer(){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",ppResources
			,"uint"),"Transfer")
		return new IPortableDeviceResources(ppResources)
	}

	; The CreateObjectWithPropertiesOnly method creates an object with only properties on the device.
	CreateObjectWithPropertiesOnly(pValues){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",IsObject(pValues)?pValues.__:pValues
			,"ptr*",ppszObjectID
			,"uint"),"CreateObjectWithPropertiesOnly")
		return StrGet(ppszObjectID,"utf-16"),,DllCall("Ole32\CoTaskMemFree","ptr",ppszObjectID)
	}

	; The CreateObjectWithPropertiesAndData method creates an object with both properties and data on the device.
	CreateObjectWithPropertiesAndData(pValues,ppData,pdwOptimalWriteBufferSize,ppszCookie){
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",IsObject(pValues)?pValues.__:pValues
			,"ptr*",ppData
			,"uint*",pdwOptimalWriteBufferSize
			,"ptr*",ppszCookie
			,"uint"),"CreateObjectWithPropertiesAndData")
		return [new IStream(ppData),pdwOptimalWriteBufferSize,StrGet(ppszCookie,"utf-16")],DllCall("Ole32\CoTaskMemFree","ptr",ppszCookie) ; not completed
	}

	; The Delete method deletes one or more objects from the device.
	Delete(dwOptions,pObjectIDs){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"uint",dwOptions
			,"ptr",IsObject(pObjectIDs)?pObjectIDs.__:pObjectIDs
			,"ptr*",ppResults
			,"uint"),"Delete")
		return new IPortableDevicePropVariantCollection(ppResults)
	}

	; The GetObjectIDsFromPersistentUniqueIDs method retrieves the current object ID of one or more objects, given their persistent unique IDs (PUIDs).
	GetObjectIDsFromPersistentUniqueIDs(pPersistentUniqueIDs){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",IsObject(pPersistentUniqueIDs)?pPersistentUniqueIDs.__:pPersistentUniqueIDs
			,"ptr*",ppObjectIDs
			,"uint"),"GetObjectIDsFromPersistentUniqueIDs")
		return new IPortableDevicePropVariantCollection(ppObjectIDs)
	}

	; The Cancel method cancels a pending operation called on this interface
	Cancel(){
		return _Error(DllCall(this.vt(10),"ptr",this.__,"uint"),"Cancel")
	}

	; The Move method moves one or more objects from one location on the device to another.
	Move(pObjectIDs,pszDestinationFolderObjectID){
		_Error(DllCall(this.vt(11),"ptr",this.__
			,"ptr",IsObject(pObjectIDs)?pObjectIDs.__:pObjectIDs
			,"wstr",pszDestinationFolderObjectID
			,"ptr*",ppResults
			,"uint"),"Move")
		return new IPortableDevicePropVariantCollection(ppResults)
	}

	; The Copy method copies objects from one location on a device to another.
	Copy(pObjectIDs,pszDestinationFolderObjectID){
		_Error(DllCall(this.vt(12),"ptr",this.__
			,"ptr",IsObject(pObjectIDs)?pObjectIDs.__:pObjectIDs
			,"wstr",pszDestinationFolderObjectID
			,"ptr*",ppResults
			,"uint"),"Copy")
		return new IPortableDevicePropVariantCollection(ppResults)
	}
}

class IPortableDeviceContent2 extends IPortableDeviceContent
{
	static iid := "{9b4add96-f6bf-4034-8708-eca72bf10554}"

	; The UpdateObjectWithPropertiesAndData method updates an object by using properties and data found on the device.
	UpdateObjectWithPropertiesAndData(pszObjectID,pProperties){
		_Error(DllCall(this.vt(13),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",IsObject(pProperties)?pProperties.__:pProperties
			,"ptr*",ppData
			,"uint*",pdwOptimalWriteBufferSize
			,"uint"),"UpdateObjectWithPropertiesAndData")
		return [new IStream(ppData),pdwOptimalWriteBufferSize]
	}
}

class IPortableDeviceProperties extends IUnknown
{
	static iid := "{7f6d695c-03df-4439-a809-59266beee3a6}"

	; The GetSupportedProperties method retrieves a list of properties that a specified object supports. Note that not all of these properties may actually have values.
	; To get the values of supported properties, call GetPropertyAttributes.
	GetSupportedProperties(pszObjectID){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr*",ppKeys
			,"uint"),"GetSupportedProperties")
		return new IPortableDeviceKeyCollection(ppKeys)
	}

	; The GetPropertyAttributes method retrieves attributes of a specified object property on a device.
	; Property attributes describe a property's access rights, valid values, and other information. For example, a property can have a WPD_PROPERTY_ATTRIBUTE_CAN_DELETE value set to False to prevent deletion, and have a range of valid values stored as individual entries.
	GetPropertyAttributes(pszObjectID,Key){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",Key
			,"ptr*",ppAttributes
			,"uint"),"GetPropertyAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetValues method retrieves a list of specified properties from a specified object on a device.
	GetValues(pszObjectID,pKeys){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",IsObject(pKeys)?pKeys.__:pKeys
			,"ptr*",ppValues
			,"uint"),"GetValues")
		return new IPortableDeviceValues(ppValues)
	}

	; The SetValues method adds or modifies one or more properties on a specified object on a device.
	; To delete a property, call IPortableDeviceProperties::Delete. A property can be deleted only if its WPD_PROPERTY_ATTRIBUTE_CAN_WRITE attribute is True. This attribute can be retrieved by calling GetPropertyAttributes.
	SetValues(pszObjectID,pValues){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",IsObject(pValues)?pValues.__:pValues
			,"ptr*",ppResults
			,"uint"),"SetValues")
		return new IPortableDeviceValues(ppResults)
	}

	; The Delete method deletes specified properties from a specified object on a device.
	; Properties can be deleted only if their WPD_PROPERTY_ATTRIBUTE_CAN_DELETE attribute is True. This attribute can be retrieved by calling GetPropertyAttributes.
	; The driver has no way to indicate partial success; that is, if only some properties could be deleted, the driver will return S_FALSE, but this method does not indicate which properties were successfully deleted. The only way to learn which properties were deleted is to request all properties by calling IPortableDeviceProperties::GetValues.
	Delete(pszObjectID,pKeys){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",IsObject(pKeys)?pKeys.__:pKeys
			,"uint"),"Delete")
	}

	; The Cancel method cancels a pending call.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDevice interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(8),"ptr",this.__,"uint"),"Cancel")
	}
}

class IEnumPortableDeviceObjectIDs extends IUnknown
{
	static iid := "{10ece955-cf41-4728-bfa0-41eedf1bbf19}"

	; The Next method retrieves the next one or more object IDs in the enumeration sequence.
	; If fewer than the requested number of elements remain in the sequence, this method retrieves the remaining elements. The number of elements that are actually retrieved is returned through pcFetched (unless the caller passed in NULL for that parameter). Enumerated objects are all peers—that is, enumerating children of an object will enumerate only direct children, not grandchild or deeper objects.
	Next(cObjects){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint",cObjects
			,"ptr*",pObjIDs
			,"uint*",pcFetched
			,"uint"),"Next")
		return [StrGet(pObjIDs,"utf-16"),pcFetched],DllCall("Ole32\CoTaskMemFree","ptr",pObjIDs)
	}

	; The Skip method skips a specified number of objects in the enumeration sequence.
	Skip(cObjects){
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"uint",cObjects
			,"uint"),"Skip")
	}

	; The Reset method resets the enumeration sequence to the beginning.
	; There is no guarantee that the same objects will be enumerated after this method is called. This is because objects that were enumerated previously might have been deleted or new objects might have been added.
	Reset(){
		return _Error(DllCall(this.vt(5),"ptr",this.__,"uint"),"Reset")
	}

	; The Clone method duplicates the current I EnumPortableDeviceObjectIDs interface.
	Clone(){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppEnum
			,"uint"),"Clone")
		return new IEnumPortableDeviceObjectIDs(ppEnum)
	}

	; The Cancel method cancels a pending operation.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDevice interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(7),"ptr",this.__,"uint"),"Cancel")
	}
}

class IPortableDeviceKeyCollection extends IUnknown
{
	static iid := "{dada2357-e0ad-492e-98db-dd61c53ba353}"
		,clsid := "{de2d022d-2480-43be-97f0-d1fa2cf98f4f}"

	; The GetCount method retrieves the number of keys in this collection.
	GetCount(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint*",pcElems
			,"uint"),"GetCount")
		return pcElems
	}

	; The GetAt method retrieves a PROPERTYKEY from the collection by index. 
	GetAt(dwIndex,ByRef pKey){
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"uint",dwIndex
			,"ptr",pKey
			,"uint"),"GetAt")
	}

	; The Add method adds a property key to the collection.
	Add(Key){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",Key
			,"uint"),"Add")
	}

	; The Clear method deletes all items from the collection.
	Clear(){
		return _Error(DllCall(this.vt(6),"ptr",this.__,"uint"),"Clear")
	}

	; The RemoveAt method removes the element stored at the location specified by the given index.
	RemoveAt(dwIndex){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"uint",dwIndex
			,"uint"),"RemoveAt")
	}
}

class IPortableDeviceResources extends IUnknown
{
	static iid := "{fd8878ac-d841-4d17-891c-e6829cdb6934}"

	; The GetSupportedResources method retrieves a list of resources that are supported by a specific object.
	; The list of resources returned by this method includes all resources that the object can support. This does not mean that all the listed resources actually have data, but that the object is capable of supporting each listed resource.
	GetSupportedResources(pszObjectID){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr*",ppKeys
			,"uint"),"GetSupportedResources")
		return new IPortableDeviceKeyCollection(ppKeys)
	}

	; The GetResourceAttributes method retrieves all attributes from a specified resource in an object.
	GetResourceAttributes(pszObjectID,Key){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",Key
			,"ptr*",ppResourceAttributes
			,"uint"),"GetResourceAttributes")
		return new IPortableDeviceValues(ppResourceAttributes)
	}

	; The GetStream method gets an IStream interface with which to read or write the content data in an object on a device. The retrieved interface enables you to read from or write to the object data.
	; The retrieved stream cannot read the contents of a folder recursively. To copy all the resources in an object, specify WPD_RESOURCE_DEFAULT for Key.
	; If the object does not support resources, this method will return an error, and ppStream will be NULL.
	; Applications should use the buffer size returned by pdwOptimalBufferSize when allocating the buffer for read or write operations.
	GetStream(pszObjectID,Key,dwMode){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",Key
			,"uint",dwMode
			,"uint*",pdwOptimalBufferSize
			,"ptr*",ppStream
			,"uint"),"GetStream")
		return [pdwOptimalBufferSize,new IStream(ppStream)]
	}

	; The Delete method deletes one or more resources from the object identified by the pszObjectID parameter.
	; An object can have several resources. For instance, an object may contain image data, thumbnail image data, and audio data.
	; An application can retrieve a list of supported resources by calling the GetSupportedResources method.
	Delete(pszObjectID,pKeys){
		return _Error(DllCall(this.vt(6),"ptr",this.__
			,"wstr",pszObjectID
			,"ptr",IsObject(pKeys)?pKeys.__:pKeys
			,"uint"),"Delete")
	}

	; The Cancel method cancels a pending operation.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDevice interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(7),"ptr",this.__,"uint"),"Cancel")
	}

	; The CreateResource method creates a resource.
	; When an application calls this method, it must specify the resource attributes and it must write the required data to the stream that this method returns.
	; A resource is not created when the method returns; it is created when the application commits the data by calling the Commit method on the stream at which ppData points.
	; To cancel the data transfer to a resource, the application must call the Revert method on the stream at which ppData points. Once the transfer is canceled, the application must invoke IUnknown::Release to close the stream.
	CreateResource(pResourceAttributes){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"ptr",IsObject(pResourceAttributes)?pResourceAttributes.__:pResourceAttributes
			,"ptr*",ppData
			,"uint*",pdwOptimalWriteBufferSize
			,"ptr*",ppszCookie
			,"uint"),"CreateResource")
		return [new IStream(ppData),pdwOptimalWriteBufferSize,StrGet(ppszCookie,"utf-16")]
	}
}

class IPortableDeviceCapabilities extends IUnknown
{
	static iid := "{2c8c6dbf-e3dc-4061-becc-8542e810d126}"

	; The GetSupportedCommands method retrieves a list of all the supported commands for this device.
	GetSupportedCommands(ppCommands){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr*",ppCommands
			,"uint"),"GetSupportedCommands")
		return new IPortableDeviceKeyCollection(ppCommands)
	}

	; The GetCommandOptions method retrieves all the supported options for the specified command on the device.
	; This method is called by applications that want to call a command directly on the driver by calling IPortableDevice::SendCommand. Some commands allow the caller to specify additional options. For example, some drivers support recursive child deletion when deleting an object using the WPD_COMMAND_OBJECT_MANAGEMENT_DELETE_OBJECTS command.
	; If an option is a simple Boolean value, the key of the retrieved IPortableDeviceValues interface will be the name of the option, and the PROPVARIANT value will be a VT_BOOL value of True or False. If an option has several values, the retrieved PROPVARIANT value will be a collection type that holds the supported values.
	; If this method is called for the WPD_COMMAND_STORAGE_FORMAT command and the ppOptions parameter is set to WPD_OPTION_VALID_OBJECT_IDS, the driver will return an IPortableDevicePropVariant collection of type VT_LPWSTR that specifies the identifiers for each object on the device that can be formatted. (If this option does not exist, the format command is available for all objects.)
	GetCommandOptions(Command){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",Command
			,"ptr*",ppOptions
			,"uint"),"GetCommandOptions")
		return new IPortableDeviceValues(ppOptions)
	}

	; The GetFunctionalCategories method retrieves all functional categories supported by the device.
	; Functional categories describe the types of functions that a device can perform, such as image capture, audio capture, and storage. This method is typically very fast, because the driver usually queries the device only on startup and caches the results.
	GetFunctionalCategories(){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",ppCategories
			,"uint"),"GetFunctionalCategories")
		return new IPortableDevicePropVariantCollection(ppCategories)
	}

	; The GetFunctionalObjects method retrieves all functional objects that match a specified category on the device.
	; This operation is usually fast, because the driver does not need to perform a full content enumeration, and the number of retrieved functional objects is typically less than 10. If no objects of the requested type are found, this method will not return an error, but returns an empty collection for ppObjectIDs.
	GetFunctionalObjects(Category){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",Category
			,"ptr*",ppObjectIDs
			,"uint"),"GetFunctionalObjects")
		return new IPortableDevicePropVariantCollection(ppObjectIDs)
	}

	; The GetSupportedContentTypes method retrieves all supported content types for a specified functional object type on a device.
	GetSupportedContentTypes(Category){
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",Category
			,"ptr*",ppContentTypes
			,"uint"),"GetSupportedContentTypes")
		return new IPortableDevicePropVariantCollection(ppContentTypes)
	}

	; The GetSupportedFormats method retrieves the supported formats for a specified object type on the device. For example, specifying audio objects might return WPD_OBJECT_FORMAT_WMA, WPD_OBJECT_FORMAT_WAV, and WPD_OBJECT_FORMAT_MP3.
	GetSupportedFormats(ContentType){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"ptr",ContentType
			,"ptr*",ppFormats
			,"uint"),"GetSupportedFormats")
		return new IPortableDevicePropVariantCollection(ppFormats)
	}

	; The GetSupportedFormatProperties method retrieves the properties supported by objects of a specified format on the device.
	; You can specify WPD_OBJECT_FORMAT_ALL for the Format parameter to retrieve the complete set of property attributes.
	; If an object does not have a value assigned to a specific property, or if the property was deleted, a device might not report the property at all when enumerating its properties. Another device might report the property, but with an empty string or a value of zero. In order to avoid this inconsistency, you can call this method to learn all the properties you can set on a specific object.
	GetSupportedFormatProperties(Format){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",Format
			,"ptr*",ppKeys
			,"uint"),"GetSupportedFormatProperties")
		return new IPortableDeviceKeyCollection(ppKeys)
	}

	; The GetFixedPropertyAttributes method retrieves the standard property attributes for a specified property and format. Standard attributes are those that have the same value for all objects of the same format. For example, one device might not allow users to modify video file names; this device would return WPD_PROPERTY_ATTRIBUTE_CAN_WRITE with a value of False for WMV formatted objects. Attributes that can have different values for a format, or optional attributes, are not returned.
	; You can specify WPD_OBJECT_FORMAT_ALL for the Format parameter to retrieve the complete set of property attributes.
	; Attributes describe properties. Example attributes are WPD_PROPERTY_ATTRIBUTE_CAN_READ and WPD_PROPERTY_ATTRIBUTE_CAN_WRITE. This method does not retrieve resource attributes.
	GetFixedPropertyAttributes(Format,Key){
		_Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr",Format
			,"ptr",Key
			,"ptr*",ppAttributes
			,"uint"),"GetFixedPropertyAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The Cancel method cancels a pending request on this interface.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDevice interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(11),"ptr",this.__,"uint"),"Cancel")
	}

	; The GetSupportedEvents method retrieves the supported events for this device.
	GetSupportedEvents(){
		_Error(DllCall(this.vt(12),"ptr",this.__
			,"ptr*",ppEvents
			,"uint"),"GetSupportedEvents")
		return new IPortableDevicePropVariantCollection(ppEvents)
	}

	; The GetEventOptions method retrieves all the supported options for the specified event on the device.
	GetEventOptions(Event){
		_Error(DllCall(this.vt(13),"ptr",this.__
			,"ptr",Event
			,"ptr*",ppOptions
			,"uint"),"GetEventOptions")
		return new IPortableDeviceValues(ppOptions)
	}
}

class IPortableDevicePropertiesBulk extends IUnknown
{
	static iid := "{482b05c0-4056-44ed-9e0f-5e23b009da93}"

	; The QueueGetValuesByObjectList method queues a request for one or more specified properties from one or more specified objects on the device.
	; IPortableDevicePropertiesBulk Interface.
	; Due to performance issues, some devices may not return a comprehensive list of properties when the pKeys parameter is NULL.
	QueueGetValuesByObjectList(pObjectIDs,pKeys,pCallback,ByRef pContext){
		VarSetCapacity(pContext,16)
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(pObjectIDs)?pObjectIDs.__:pObjectIDs
			,"ptr",IsObject(pKeys)?pKeys.__:pKeys
			,"ptr",IsObject(pCallback)?pCallback.__:pCallback
			,"ptr",&pContext
			,"uint"),"QueueGetValuesByObjectList")
	}

	; The QueueGetValuesByObjectFormat interface queues a request for properties of objects of a specific format on a device.
/*
	If you specify WPD_OBJECT_FORMAT_ALL for the pguidObjectFormat parameter, this method will return properties for all objects on the device.
	If the pszParentObjectID parameter is set to an empty string (""), the method will perform a search that is dependent on the dwDepth parameter as described in the following table.
		dwDepth Method returns 
		0 No results 
		1 Values for the specified device only. 
		2 Values for the specified device and all functional objects found on that device. 
	If the pszParentObjectID parameter is set to WPD_DEVICE_OBJECT_ID, the method will perform a search that is dependent on the dwDepth parameter as described in the following table.
		dwDepth Method returns 
		0 Values for the specified device only. 
		1 Values for the specified device and all functional objects found on that device. 
	The queued request is not started until the application calls Start. For more information on how to use this method, see IPortableDevicePropertiesBulk Interface.
	Due to performance issues, some devices may not return a comprehensive list of properties when the pKeys parameter is NULL.
*/
	QueueGetValuesByObjectFormat(pguidObjectFormat,pszParentObjectID,dwDepth,pKeys,pCallback,ByRef pContext){
		VarSetCapacity(pContext,16)
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",pguidObjectFormat
			,"wstr",pszParentObjectID
			,"uint",dwDepth
			,"ptr",IsObject(pKeys)?pKeys.__:pKeys
			,"ptr",IsObject(pCallback)?pCallback.__:pCallback
			,"ptr",&pContext
			,"uint"),"QueueGetValuesByObjectFormat")
	}

	; The QueueSetValuesByObjectList method queues a request to set one or more specified values on one or more specified objects on the device.
	; The queued request is not started until the application calls Start. For more information on how to use this method, see IPortableDevicePropertiesBulk Interface.
	QueueSetValuesByObjectList(pObjectValues,pCallback,ByRef pContext){
		VarSetCapacity(pContext,16)
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(pObjectValues)?pObjectValues.__:pObjectValues
			,"ptr",IsObject(pCallback)?pCallback.__:pCallback
			,"ptr",&pContext
			,"uint"),"QueueSetValuesByObjectList")
	}

	; The Start method starts a queued operation.
	Start(pContext){
		return _Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",pContext
			,"uint"),"Start")
	}

	; The Cancel method cancels a pending properties request.
	Cancel(pContext){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",pContext
			,"uint"),"Cancel")
	}
}

class IPortableDevicePropVariantCollection extends IUnknown
{
	static iid := "{89b2e422-4f1b-4316-bcef-a44afea83eb3}"
		,clsid := "{08a99e2f-6d6d-4b80-af5a-baf2bcbe4cb9}"

	; The GetCount method retrieves the number of items in this collection.
	GetCount(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint*",pcElems
			,"uint"),"GetCount")
		return pcElems
	}

	; The GetAt method retrieves an item from the collection by a zero-based index.
	GetAt(dwIndex){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",dwIndex
			,"ptr",PROPVARIANT(pValue)
			,"uint"),"GetAt")
		return GetPropVariantValue(pValue)
	}

	; The Add method adds an item to the collection.
	; When the VARTYPE for pValue is VT_VECTOR or VT_UI1, setting and retrieving a NULL or zero-sized buffer is not supported. For example, neither pValue.caub.pElems = NULL nor pValue.caub.cElems = 0 are allowed.
	; If a caller tries to add an item of a different VARTYPE contained in the collection and the PROPVARIANT value cannot be changed by this interface automatically, this method will fail. To change the collection type manually, call IPortableDevicePropVariantCollection::ChangeType.
	Add(pValue){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",pValue
			,"uint"),"Add")
	}

	; The GetType method retrieves the data type of the items in the collection.
	GetType(){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"short*",pvt
			,"uint"),"GetType")
		return pvt
	}

	; The ChangeType method converts all items in the collection to the specified VARTYPE.
	ChangeType(vt){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"short",vt
			,"uint"),"ChangeType")
	}

	; The Clear method frees, and then removes, all items from the collection. The collection is considered empty after calling this method.
	; After calling Clear, the collection is considered type-less, meaning that the VARTYPE it was previously set to is no longer restricting Add operations. A call to Add after calling Clear is considered the "first" Add for this collection.
	Clear(){
		return _Error(DllCall(this.vt(8),"ptr",this.__,"uint"),"Clear")
	}

	; The RemoveAt method removes the element stored at the location specified by the given index.
	; You must specify a zero-based index.
	RemoveAt(dwIndex){
		return _Error(DllCall(this.vt(9),"ptr",this.__
			,"uint",dwIndex
			,"uint"),"RemoveAt")
	}
}

class IPortableDeviceValuesCollection extends IUnknown
{
	static iid := "{6e3f2d79-4e07-48c4-8208-d8c2e5af4a99}"
		,clsid := "{3882134d-14cf-4220-9cb4-435f86d83f60}"

	; The GetCount method retrieves the number of items in the collection.
	GetCount(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint*",pcElems
			,"uint"),"GetCount")
		return pcElems
	}

	; The GetAt method retrieves an item from the collection by a zero-based index.
	GetAt(dwIndex){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"uint",dwIndex
			,"ptr*",ppValues
			,"uint"),"GetAt")
		return new IPortableDeviceValues(ppValues)
	}

	; The Add method adds an item to the collection.
	Add(pValues){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(pValues)?pValues.__:pValues
			,"uint"),"Add")
	}

	; The Clear method releases all items from the collection.
	Clear(){
		return _Error(DllCall(this.vt(6),"ptr",this.__,"uint"),"Clear")
	}

	; The RemoveAt method removes the element stored at the location specified by the given index.
	; You must specify a zero-based index.
	RemoveAt(dwIndex){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"uint",dwIndex
			,"uint"),"RemoveAt")
	}
}

class IPortableDeviceDataStream extends IStream
{
	static iid := "{88e04db3-1012-4d64-9996-f703a950d3f4}"

	; The GetObjectID method retrieves the object ID of the resource that was written to the device. This method is only valid after calling IStream::Commit on the data stream.
	; An object ID is created after the object is created on the device. Therefore, a new object that is created by calling IPortableDeviceContent::CreateObjectWithPropertiesAndData will not have an ID assigned until the application calls Commit on the data transfer stream.
	GetObjectID(){
		_Error(DllCall(this.vt(14),"ptr",this.__
			,"ptr*",ppszObjectID
			,"uint"),"GetObjectID")
		return StrGet(ppszObjectID,"utf-16")
	}

	; The Cancel method cancels a call in progress on this interface.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDevice interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(15),"ptr",this.__,"uint"),"Cancel")
	}
}

class IPortableDeviceServiceManager extends IUnknown
{
	static iid := "{a8abc4e9-a84a-47a9-80b3-c5d9b172a961}"

	; The GetDeviceServices method retrieves a list of the services associated with the specified device.
	; If this method succeeds, the application should call the FreePortableDevicePnPIDs function to free the array referenced by the pServices parameter.
	; An application can retrieve the PnP identifier for a device by calling the IPortableDeviceManager::GetDevices method.
	; Applications that use Single Threaded Apartments should use CLSID_PortableDeviceServiceFTM as this eliminates the overhead of interface pointer marshaling. CLSID_PortableDeviceService is still supported for legacy applications.
	GetDeviceServices(pszPnPDeviceID,guidServiceCategory){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr",guidServiceCategory
			,"ptr*",0
			,"uint*",pcServices
			,"uint"),"GetDeviceServices")
		if pcServices{
			VarSetCapacity(pServices,pcServices*A_PtrSize)
			_Error(DllCall(this.vt(3),"ptr",this.__
				,"wstr",pszPnPDeviceID
				,"ptr",guidServiceCategory
				,"ptr",&pServices
				,"uint*",pcServices
				,"uint"),"GetDeviceServices")
			Services:=[]
			loop % pcServices
				Services[A_Index]:=StrGet(NumGet(pServices,(A_Index-1)*A_PtrSize),"utf-16")
				,DllCall("Ole32\CoTaskMemFree","ptr",NumGet(pServices,(A_Index-1)*A_PtrSize))
			return Services
		}
	}

	; The GetDeviceForService method retrieves the device associated with the specified service.
	; Neither the pszPnPServiceID parameter nor the pszPnPDeviceID parameter can be NULL.
	; An application can retrieve a PnP service identifier by calling the GetDeviceServices method.
	GetDeviceForService(pszPnPServiceID){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"wstr",pszPnPServiceID
			,"ptr*",ppszPnPDeviceID
			,"uint"),"GetDeviceForService")
		return StrGet(ppszPnPDeviceID,"utf-16")
	}
}

class IPortableDeviceService extends IUnknown
{
	static iid := "{d3bd3a44-d7b5-40a9-98b7-2fa4d01dec08}"
		,clsid := "{ef5db4c2-9312-422c-9152-411cd9c4dd84}"

	; The Open method opens a connection to the service.
	Open(pszPnPServiceID,pClientInfo){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszPnPServiceID
			,"ptr",IsObject(pClientInfo)?pClientInfo.__:pClientInfo
			,"uint"),"Open")
	}

	; The Capabilities method retrieves the service capabilities.
	Capabilities(){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr*",ppCapabilities
			,"uint"),"Capabilities")
		return new IPortableDeviceServiceCapabilities(ppCapabilities)
	}

	; The Content method retrieves access to the service content.
	Content(){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr*",ppContent
			,"uint"),"Content")
		return new IPortableDeviceContent2(ppContent)
	}

	; The Methods method retrieves the IPortableDeviceServiceMethods interface that is used to invoke custom functionality on the service.
	Methods(){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppMethods
			,"uint"),"Methods")
		return new IPortableDeviceServiceMethods(ppMethods)
	}

	; The Cancel method cancels a pending operation on this interface.
	; This method cancels all pending operations on the current device handle, which corresponds to a session associated with an IPortableDeviceService interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	; If your application invokes the WPD API from multiple threads, each thread should create a new instance of the IPortableDeviceService interface. Doing this ensures that any cancel operation affects only the I/O for the affected thread.
	Cancel(){
		return _Error(DllCall(this.vt(7),"ptr",this.__,"uint"),"Cancel")
	}

	; The Close method releases the connection to the service.
	; Applications typically won't call this method, as the Windows Portable Devices (WPD) API automatically calls it when the last reference to a service is removed.
	; When an application does call this method, the WPD API releases the service connection, so that any WPD objects attached to the service will return the E_WPD_SERVICE_NOT_OPEN error.
	Close(){
		return _Error(DllCall(this.vt(8),"ptr",this.__,"uint"),"Close")
	}

	; The GetServiceObjectID method retrieves an object identifier for the service. This object identifier can be used to access the properties of the service, for example.
	GetServiceObjectID(){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr*",ppszServiceObjectID
			,"uint"),"GetServiceObjectID")
		return StrGet(ppszServiceObjectID,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppszServiceObjectID)
	}

	; The GetPnPServiceID method retrieves a Plug and Play (PnP) identifier for the service.
	GetPnPServiceID(ppszPnPServiceID){
		_Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr*",ppszPnPServiceID
			,"uint"),"GetPnPServiceID")
		return StrGet(ppszPnPServiceID,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppszPnPServiceID)
	}

	; The Advise method registers an application-defined callback object that receives service events.
	Advise(dwFlags,pCallback,pParameters,ppszCookie){
		_Error(DllCall(this.vt(11),"ptr",this.__
			,"uint",dwFlags
			,"ptr",IsObject(pCallback)?pCallback.__:pCallback
			,"ptr",IsObject(pParameters)?pParameters.__:pParameters
			,"ptr*",ppszCookie
			,"uint"),"Advise")
		return StrGet(ppszCookie,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppszCookie)
	}

	; The Unadvise method unregisters a service event callback object.
	Unadvise(pszCookie){
		return _Error(DllCall(this.vt(12),"ptr",this.__
			,"wstr",pszCookie
			,"uint"),"Unadvise")
	}

	; The SendCommand method sends a standard WPD command and its parameters to the service.
/*
	This method should only be used to send standard WPD commands to the service. To invoke service methods, use the IPortableDeviceServiceMethods interface.
	This method may fail even though it returns S_OK as its HRESULT value. To determine if a command succeeded, an application should always examine the properties referenced by the ppResults parameter:
		The WPD_PROPERTY_COMMON_HRESULT property indicates if the command succeeded. 
		If the command failed, the WPD_PROPERTY_COMMON_DRIVER_ERROR_CODE property will contain driver-specific error codes.
	The object referenced by the pParameters parameter must specify at least these properties:
		WPD_PROPERTY_COMMON_COMMAND_CATEGORY, which should contain a command category, such as the fmtid member of the WPD_COMMAND_COMMON_RESET_DEVICE property 
		WPD_PROPERTY_COMMON_COMMAND_ID, which should contain a command identifier, such as the pid member of the WPD_COMMAND_COMMON_RESET_DEVICE property.
*/
	SendCommand(dwFlags,pParameters){
		_Error(DllCall(this.vt(13),"ptr",this.__
			,"uint",dwFlags
			,"ptr",IsObject(pParameters)?pParameters.__:pParameters
			,"ptr*",ppResults
			,"uint"),"SendCommand")
		return new IPortableDeviceValues(ppResults)
	}
}

class IPortableDeviceServiceCapabilities extends IUnknown
{
	static iid := "{24dbd89d-413e-43e0-bd5b-197f3c56c886}"

	; The GetSupportedMethods method retrieves the methods supported by the service.
	GetSupportedMethods(){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr*",ppMethods
			,"uint"),"GetSupportedMethods")
		return new IPortableDevicePropVariantCollection(ppMethods)
	}

	; The GetSupportedMethodsByFormat method retrieves the methods supported by the service for the specified format.
	GetSupportedMethodsByFormat(Format){
		_Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",Format
			,"ptr*",ppMethods
			,"uint"),"GetSupportedMethodsByFormat")
		return new IPortableDevicePropVariantCollection(ppMethods)
	}

	; The GetMethodAttributes method retrieves the attributes used to describe a given method.
	GetMethodAttributes(Method){
		_Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",Method
			,"ptr*",ppAttributes
			,"uint"),"GetMethodAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetMethodParameterAttributes method retrieves the attributes used to describe a given method parameter.
	; Possible attributes include the WPD_PARAMETER_ATTRIBUTE_ORDER, WPD_PARAMETER_ATTRIBUTE_USAGE, WPD_PARAMETER_ATTRIBUTE_NAME, and WPD_PARAMETER_ATTRIBUTE_VARTYPE properties.
	GetMethodParameterAttributes(Method,Parameter){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",Method
			,"ptr",Parameter
			,"ptr*",ppAttributes
			,"uint"),"GetMethodParameterAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetSupportedFormats method retrieves the formats supported by the service.
	GetSupportedFormats(){
		_Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr*",ppFormats
			,"uint"),"GetSupportedFormats")
		return new IPortableDevicePropVariantCollection(ppFormats)
	}

	; The GetFormatAttributes method retrieves the attributes of a format.
	; WPD_FORMAT_ATTRIBUTE_NAME is an example of a commonly retrieved attribute.
	GetFormatAttributes(Format){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"ptr",Format
			,"ptr*",ppAttributes
			,"uint"),"GetFormatAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetSupportedFormatProperties method retrieves the properties supported by the service for the specified format.
	; The retrieved property collection is a superset of all properties supported by an object of the specified format.
	; An application can also retrieve the properties for an object by calling the IPortableDeviceService::SendCommand method with the WPD_COMMAND_OBJECT_PROPERTIES_GET_SUPPORTED property passed as the command identifier. However, the GetSupportedFormatProperties method is typically faster than the IPortableDeviceService::SendCommand method.
	GetSupportedFormatProperties(Format){
		_Error(DllCall(this.vt(9),"ptr",this.__
			,"ptr",Format
			,"ptr*",ppKeys
			,"uint"),"GetSupportedFormatProperties")
		return new IPortableDeviceKeyCollection(ppKeys)
	}

	; The GetFormatPropertyAttributes method retrieves the attributes of a format property.
	; A Windows Portable Devices (WPD) driver often treats objects of a given format the same. Many properties will therefore have attributes that are identical across all objects of that format. This method retrieves such attributes.
	; Note that this method will not retrieve attributes that differ across object instances.
	GetFormatPropertyAttributes(Format,Property){
		_Error(DllCall(this.vt(10),"ptr",this.__
			,"ptr",Format
			,"ptr",Property
			,"ptr*",ppAttributes
			,"uint"),"GetFormatPropertyAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetSupportedEvents method retrieves the events supported by the service.
	GetSupportedEvents(){
		_Error(DllCall(this.vt(11),"ptr",this.__
			,"ptr*",ppEvents
			,"uint"),"GetSupportedEvents")
		return new IPortableDevicePropVariantCollection(ppEvents)
	}

	; The GetEventAttributes method retrieves the attributes of an event.
	; Possible attributes include the WPD_EVENT_ATTRIBUTE_NAME, WPD_EVENT_ATTRIBUTE_PARAMETERS, and WPD_EVENT_ATTRIBUTE_OPTIONS properties.
	GetEventAttributes(Event){
		_Error(DllCall(this.vt(12),"ptr",this.__
			,"ptr",Event
			,"ptr*",ppAttributes
			,"uint"),"GetEventAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetEventParameterAttributes method retrieves the attributes of an event parameter.
	; Possible attribute values include the WPD_PARAMETER_ATTRIBUTE_VARTYPE and WPD_PARAMETER_ATTRIBUTE_FORM properties.
	GetEventParameterAttributes(Event,Parameter){
		_Error(DllCall(this.vt(13),"ptr",this.__
			,"ptr",Event
			,"ptr",Parameter
			,"ptr*",ppAttributes
			,"uint"),"GetEventParameterAttributes")
		return new IPortableDeviceValues(ppAttributes)
	}

	; The GetInheritedServices method retrieves the services having the specified inheritance type.
	; Currently, device services may only inherit by implementing an abstract service. This is analogous to how a class implements methods of an abstract interface or a virtual class in object-oriented programming. By implementing an abstract service, a device service will support all formats, properties, and method behavior that the abstract service describes. For instance, a Contacts service may implement the Anchor Sync abstract service, where the device stores markers indicating which contacts were updated since the last synchronization with the PC.
	; Possible values for the dwInheritanceType parameter are those defined in the WPD_SERVICE_INHERITANCE_TYPES enumeration. (For Windows 7, only the WPD_SERVICE_INHERITANCE_IMPLEMENTATION enumeration constant is supported.)
	; If the value of the dwInheritanceType parameter is WPD_SERVICE_INHERITANCE_IMPLEMENTATION, each item in the collection specified by the ppServices parameter has variant type VT_CLSID.
	GetInheritedServices(dwInheritanceType){
		_Error(DllCall(this.vt(14),"ptr",this.__
			,"uint",dwInheritanceType
			,"ptr*",ppServices
			,"uint"),"GetInheritedServices")
		return new IPortableDevicePropVariantCollection(ppServices)
	}

	; The GetFormatRenderingProfiles method retrieves the rendering profiles of a format.
	; The rendering profiles are similar to what the WPD_FUNCTIONAL_CATEGORY_RENDERING_INFORMATION functional object returns for device-wide rendering profiles, so that the DisplayRenderingProfile helper function described in Retrieving the Rendering Capabilities Supported by a Device could be used here as well. But there are differences: The GetFormatRenderingProfiles method retrieves only rendering profiles that apply to the selected service and have been filtered by format.
	GetFormatRenderingProfiles(Format){
		_Error(DllCall(this.vt(15),"ptr",this.__
			,"ptr",Format
			,"ptr*",ppRenderingProfiles
			,"uint"),"GetFormatRenderingProfiles")
		return new IPortableDeviceValuesCollection(ppRenderingProfiles)
	}

	; The GetSupportedCommands method retrieves the commands supported by the service.
	GetSupportedCommands(){
		_Error(DllCall(this.vt(16),"ptr",this.__
			,"ptr*",ppCommands
			,"uint"),"GetSupportedCommands")
		return new IPortableDeviceKeyCollection(ppCommands)
	}

	; The GetCommandOptions method retrieves the options of a WPD command.
	GetCommandOptions(Command){
		_Error(DllCall(this.vt(17),"ptr",this.__
			,"ptr",Command
			,"ptr*",ppOptions
			,"uint"),"GetCommandOptions")
		return new IPortableDeviceValues(ppOptions)
	}

	; The Cancel method cancels a pending operation.
	; This method cancels all pending operations on the current service handle, which corresponds to a session associated with an IPortableDeviceService interface. The Windows Portable Devices (WPD) API does not support targeted cancellation of specific operations.
	Cancel(){
		return _Error(DllCall(this.vt(18),"ptr",this.__,"uint"),"Cancel")
	}
}

class IPortableDeviceServiceMethods extends IUnknown
{
	static iid := "{e20333c9-fd34-412d-a381-cc6f2d820df7}"

	; The Invoke method synchronously invokes a method.
	; The method invocation is synchronous and will not return until the method has completed. For long-running methods, your application should call the InvokeAsync method instead.
	Invoke(Method,pParameters){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",Method
			,"ptr",IsObject(pParameters)?pParameters.__:pParameters
			,"ptr*",ppResults
			,"uint"),"Invoke")
		return new IPortableDeviceValues(ppResults)
	}

	; The InvokeAsync method asynchronously invokes a method.
	; When invoking multiple methods, clients can create a separate instance of the IPortableDeviceServiceMethodCallback interface for each invocation, saving a context with that instance object before passing it to the InvokeAsync method. This way, the method operation can be identified when the OnComplete method is called. Use of a unique object for each invocation also allows targeted cancellation of an operation by the Cancel method.
	InvokeAsync(Method,pParameters,pCallback){
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",Method
			,"ptr",IsObject(pParameters)?pParameters.__:pParameters
			,"ptr",IsObject(pCallback)?pCallback[]:pCallback
			,"uint"),"InvokeAsync")
	}

	; The Cancel method cancels a pending method invocation.
	; A callback object identifies a method invocation. If the same callback object is reused for multiple calls to the InvokeAsync method, all method invocations arising from these calls will be cancelled.
	; To enable targeted cancellation of a specific method invocation, pass a unique instance of the IPortableDeviceServiceMethodCallback interface to the InvokeAsync method.
	Cancel(pCallback){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(pCallback)?pCallback[]:pCallback
			,"uint"),"Cancel")
	}
}

class IPortableDeviceConnector extends IUnknown
{
	static iid := "{625e2df8-6392-4cf0-9ad1-3cfa5f17775c}"

	; The Connect method sends an asynchronous connection request to the MTP/Bluetooth device.
	; This method will queue a connect request and then return immediately. The connection request will result in a no-op if a device is already connected.
	; To be notified when the request is complete, applications should provide a pointer to the IConnectionRequestCallback interface.
	; If a previously paired MTP/Bluetooth device is within range, applications can call this method to instantiate the Windows Portable Devices (WPD) class driver stack for that device, so that the device can be communicated to using the WPD API.
	Connect(pCallback){
		return _Error(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(pCallback)?pCallback[]:pCallback
			,"uint"),"Connect")
	}

	; The Disconnect method sends an asynchronous disconnect request to the MTP/Bluetooth device.
	; This method will queue a disconnect request and then return immediately.
	; To be notified when the request is complete, applications should provide a pointer to the IConnectionRequestCallback interface. This will disconnect the MTP/Bluetooth link and remove the Windows Portable Devices (WPD) class driver stack for that device.
	; Once the disconnection completes, the WPD API will no longer enumerate this device.
	Disconnect(pCallback){
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"ptr",IsObject(pCallback)?pCallback[]:pCallback
			,"uint"),"Disconnect")
	}

	; The Cancel method cancels a pending request to connect or disconnect an MTP/Bluetooth device. The callback object is used to identify the request. This method returns immediately, and the request will be cancelled asynchronously.
	Cancel(pCallback){
		return _Error(DllCall(this.vt(5),"ptr",this.__
			,"ptr",IsObject(pCallback)?pCallback[]:pCallback
			,"uint"),"Cancel")
	}

	; The GetProperty method retrieves a property for the given MTP/Bluetooth Bus Enumerator device.
	; The properties retrieved by this method are set on the device node. An example property key is DEVPKEY_MTPBTH_IsConnected, which indicates whether the device is currently connected.
	; Valid values for the pPropertyType parameter are system-defined base data types of the unified device property model. The data-type names start with the prefix DEVPROP_TYPE_.
	; Once the application no longer needs the property data specified by the ppData parameter, it must call CoTaskMemAlloc to free this data.
	GetProperty(pPropertyKey){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr",pPropertyKey
			,"int*",pPropertyType
			,"ptr*",ppData
			,"uint*",pcbData
			,"uint"),"GetProperty")
		DllCall("Ole32\CoTaskMemFree","ptr",ppData)
		return [] ; not completed
	}

	; The SetProperty method sets the given property on the MTP/Bluetooth Bus Enumerator device.
	; Before calling this method, an application must verify that it has Administrator user rights.
	SetProperty(pPropertyKey,PropertyType,pData,cbData){
		return _Error(DllCall(this.vt(7),"ptr",this.__
			,"ptr",pPropertyKey
			,"int",PropertyType
			,"ptr",pData
			,"uint",cbData
			,"uint"),"SetProperty")
	}

	; The GetPnPID method retrieves the connector's Plug and Play (PnP) device identifier.
	; The identifier retrieved by this method corresponds to a handle to the MTP/Bluetooth Bus Enumerator device node that receives connect and disconnect IOCTL requests for a paired MTP/Bluetooth device. Applications can use this identifier with the SetupAPI functions to access the device node.
	; Once the application no longer needs the identifier specified by the ppwszPnPID parameter, it must call the CoTaskMemAlloc function to free the identifier.
	GetPnPID(){
		_Error(DllCall(this.vt(8),"ptr",this.__
			,"ptr*",ppwszPnPID
			,"uint"),"GetPnPID")
		return StrGet(ppwszPnPID,"utf-16"),DllCall("Ole32\CoTaskMemFree","ptr",ppwszPnPID)
	}
}

class IEnumPortableDeviceConnectors extends IUnknown
{
	static iid := "{bfdef549-9247-454f-bd82-06fe80853faa}"

	; The Next method retrieves the next one or more IPortableDeviceConnector objects in the enumeration sequence.
	Next(cRequested=1){
		VarSetCapacity(pConnectors,cRequested*A_PtrSize)
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"uint",cRequested
			,"ptr",&pConnectors
			,"uint*",pcFetched
			,"uint"),"Next")
		if pcFetched=1
			return new IPortableDeviceConnector(NumGet(pConnectors))
		else {
			Connectors:=[]
			loop % pcFetched
				Connectors[A_Index]:=new IPortableDeviceConnector(NumGet(pConnectors,(A_Index-1)*A_PtrSize))
			return Connectors
		}
	}

	; The Skip method skips the specified number of devices in the enumeration sequence.
	Skip(cConnectors){
		return _Error(DllCall(this.vt(4),"ptr",this.__
			,"uint",cConnectors
			,"uint"),"Skip")
	}

	; The Reset method resets the enumeration sequence to the beginning.
	Reset(){
		return _Error(DllCall(this.vt(5),"ptr",this.__,"uint"),"Reset")
	}

	; The Clone method creates a copy of the current IEnumPortableDeviceConnectors interface.
	Clone(){
		_Error(DllCall(this.vt(6),"ptr",this.__
			,"ptr*",ppEnum
			,"uint"),"Clone")
		return new IEnumPortableDeviceConnectors(ppEnum)
	}
}

class IPortableDeviceDispatchFactory extends IUnknown
{
	static iid := "{5e1eafc3-e3d7-4132-96fa-759c0f9d1e0f}"
		,clsid := "{43232233-8338-4658-ae01-0b4ae830b6b0}"

	; Instantiates a WPD Automation Device object for a given WPD device identifier.
	; For an example of how to use GetDeviceDispatch method to instantiate a WPD Automation Device object, see Instantiating the WPD Automation Factory Interface.
	GetDeviceDispatch(pszPnPDeviceID){
		_Error(DllCall(this.vt(3),"ptr",this.__
			,"wstr",pszPnPDeviceID
			,"ptr*",ppDeviceDispatch
			,"uint"),"GetDeviceDispatch")
		return ComObjEnwrap(ppDeviceDispatch)
	}
}

WPD_hr(a,b){
	return _error(a,b)
}

