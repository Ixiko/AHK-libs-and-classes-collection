Class IMMDeviceEnumerator
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        ComObjError(FALSE)
        If (!(this.ptr := ComObjCreate('{BCDE0395-E52F-467C-8E3D-C4579291692E}', '{A95664D2-9614-4F35-A746-DE8DB63617E6}')))
            Return FALSE
        
        For Each, Method in ['EnumAudioEndpoints','GetDefaultAudioEndpoint','GetDevice','RegisterEndpointNotificationCallback','UnregisterEndpointNotificationCallback']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/dd371395(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    __EventContext(ByRef EventContext, ByRef GUID)
    {
        If (EventContext is 'Integer')
            Return EventContext
        If (SubStr(EventContext, 1, 1) != "{")
            Return &EventContext
        VarSetCapacity(GUID, 16)
        DllCall('Ole32.dll\CLSIDFromString', 'UPtr', &EventContext, 'UPtr', &GUID)
        Return &GUID
    }

    
    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Generates a collection of audio endpoint devices that meet the specified criteria.
        Parámetros:
            DataFlow : The data-flow direction for the endpoint devices in the collection. The caller should set this parameter to one of the following EDataFlow enumeration values:
                eRender = 0, eCapture, eAll
            StateMask: The state or states of the endpoints that are to be included in the collection. The caller should set this parameter to the bitwise OR of one or more of the following DEVICE_STATE_XXX constants:
                0x00000001 = DEVICE_STATE_ACTIVE
                0x00000002 = DEVICE_STATE_DISABLED
                0x00000004 = DEVICE_STATE_NOTPRESENT
                0x00000008 = DEVICE_STATE_UNPLUGGED
                0x0000000F = DEVICE_STATEMASK_ALL
    */
    EnumAudioEndpoints(DataFlow, StateMask, ByRef oIMMDeviceCollection)
    {
        Local pIMMDeviceCollection, R := DllCall(this.pEnumAudioEndpoints, 'UPtr', this.ptr, 'UInt', DataFlow, 'UInt', StateMask, 'UPtrP', pIMMDeviceCollection, 'UInt')
        oIMMDeviceCollection := R == 0 ? new IMMDeviceCollection(pIMMDeviceCollection) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371400(v=vs.85).aspx

    /*
        Retrieves the default audio endpoint for the specified data-flow direction and role.
        Parámetros:
            DataFlow: The data-flow direction for the endpoint device. The caller should set this parameter to one of the following two EDataFlow enumeration values:
                eRender = 0, eCapture, eAll
            Role    : The role of the endpoint device. The caller should set this parameter to one of the following ERole enumeration values:
                eConsole = 0, eMultimedia, eCommunications
    */
    GetDefaultAudioEndpoint(DataFlow, Role, ByRef oIMMDevice)
    {
        Local pIMMDevice, R := DllCall(this.pGetDefaultAudioEndpoint, 'UPtr', this.ptr, 'UInt', DataFlow, 'UInt', Role, 'UPtrP', pIMMDevice, 'UInt')
        oIMMDevice := R == 0 ? new IMMDevice(pIMMDevice) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371401(v=vs.85).aspx

    /*
        Retrieves an endpoint device that is specified by an endpoint device-identification string.
        Parámetros:
            EndpointID: Pointer to a string containing the endpoint ID. The caller typically obtains this string from the IMMDevice::GetId method or from one of the methods in the IMMNotificationClient interface.
    */
    GetDevice(EndpointID, ByRef oIMMDevice)
    {
        Local pIMMDevice, R := DllCall(this.pGetDevice, 'UPtr', this.ptr, 'UPtr', EndpointID is 'Integer' ? EndpointID : &EndpointID, 'UPtrP', pIMMDevice, 'UInt')
        oIMMDevice := R == 0 ? new IMMDevice(pIMMDevice) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371402(v=vs.85).aspx

    /*
        Registers a client's notification callback interface.
    */
    RegisterEndpointNotificationCallback(oIMMNotificationClient)
    {
        Return DllCall(this.pRegisterEndpointNotificationCallback, 'UPtr', this.ptr, 'UPtr', IsObject(oIMMNotificationClient) ? oIMMNotificationClient.ptr : oIMMNotificationClient, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd371403(v=vs.85).aspx

    /*
        Deletes the registration of a notification interface that the client registered in a previous call to the RegisterEndpointNotificationCallback method.
    */
    UnregisterEndpointNotificationCallback(oIMMNotificationClient)
    {
        Return DllCall(this.pUnregisterEndpointNotificationCallback, 'UPtr', this.ptr, 'UPtr', IsObject(oIMMNotificationClient) ? oIMMNotificationClient.ptr : oIMMNotificationClient, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd371404(v=vs.85).aspx
}
