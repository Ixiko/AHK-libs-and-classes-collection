;
; MASTER CONTROLS
;

VA_GetMasterVolume(channel="", device_desc="playback")
{
    aev := VA_GetAudioEndpointVolume(device_desc)
    if channel =
        VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(aev, vol)
    else
        VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(aev, channel-1, vol)
    COM_Release(aev)
    return vol*100
}

VA_SetMasterVolume(vol, channel="", device_desc="playback")
{
    vol := vol>100 ? 100 : vol<0 ? 0 : vol
    aev := VA_GetAudioEndpointVolume(device_desc)
    if channel =
        VA_IAudioEndpointVolume_SetMasterVolumeLevelScalar(aev, vol/100)
    else
        VA_IAudioEndpointVolume_SetChannelVolumeLevelScalar(aev, channel-1, vol/100)
    COM_Release(aev)
}

VA_GetMasterChannelCount(device_desc="playback")
{
    aev := VA_GetAudioEndpointVolume(device_desc)
    VA_IAudioEndpointVolume_GetChannelCount(aev, count)
    COM_Release(aev)
    return count
}

VA_SetMasterMute(mute, device_desc="playback")
{
    aev := VA_GetAudioEndpointVolume(device_desc)
    VA_IAudioEndpointVolume_SetMute(aev, mute)
    COM_Release(aev)
}

VA_GetMasterMute(device_desc="playback")
{
    aev := VA_GetAudioEndpointVolume(device_desc)
    VA_IAudioEndpointVolume_GetMute(aev, mute)
    COM_Release(aev)
    return mute
}

;
; SUBUNIT CONTROLS
;

VA_GetVolume(subunit_desc="1", channel="", device_desc="playback")
{
    avl := VA_GetDeviceSubunit(device_desc, subunit_desc, "{7FB7B48F-531D-44A2-BCB3-5AD5A134B3DC}")
    if !avl
        return
    VA_IPerChannelDbLevel_GetChannelCount(avl, channel_count)
    if channel =
    {
        vol = 0
        
        Loop, %channel_count%
        {
            VA_IPerChannelDbLevel_GetLevelRange(avl, A_Index-1, min_dB, max_dB, step_dB)
            VA_IPerChannelDbLevel_GetLevel(avl, A_Index-1, this_vol)
            this_vol := VA_dB2Scalar(this_vol, min_dB, max_dB)
            
            ; "Speakers Properties" reports the highest channel as the volume.
            if (this_vol > vol)
                vol := this_vol
        }
    }
    else if channel between 1 and channel_count
    {
        channel -= 1
        VA_IPerChannelDbLevel_GetLevelRange(avl, channel, min_dB, max_dB, step_dB)
        VA_IPerChannelDbLevel_GetLevel(avl, channel, vol)
        vol := VA_dB2Scalar(vol, min_dB, max_dB)
    }
    COM_Release(avl)
    return vol
}

VA_SetVolume(vol, subunit_desc="1", channel="", device_desc="playback")
{
    avl := VA_GetDeviceSubunit(device_desc, subunit_desc, "{7FB7B48F-531D-44A2-BCB3-5AD5A134B3DC}")
    if !avl
        return
    
    vol := vol<0 ? 0 : vol>100 ? 100 : vol
    
    VA_IPerChannelDbLevel_GetChannelCount(avl, channel_count)
    
    if channel =
    {
        ; Simple method -- resets balance to "center":
        ;VA_IPerChannelDbLevel_SetLevelUniform(avl, vol)
        
        vol_max = 0
        
        Loop, %channel_count%
        {
            VA_IPerChannelDbLevel_GetLevelRange(avl, A_Index-1, min_dB, max_dB, step_dB)
            VA_IPerChannelDbLevel_GetLevel(avl, A_Index-1, this_vol)
            this_vol := VA_dB2Scalar(this_vol, min_dB, max_dB)
            
            channel%A_Index%vol := this_vol
            channel%A_Index%min := min_dB
            channel%A_Index%max := max_dB
            
            ; Scale all channels relative to the loudest channel.
            ; (This is how Vista's "Speakers Properties" dialog seems to work.)
            if (this_vol > vol_max)
                vol_max := this_vol
        }
        
        Loop, %channel_count%
        {
            this_vol := vol_max ? channel%A_Index%vol / vol_max * vol : vol
            this_vol := VA_Scalar2dB(this_vol/100, channel%A_Index%min, channel%A_Index%max)            
            VA_IPerChannelDbLevel_SetLevel(avl, A_Index-1, this_vol)
        }
    }
    else if channel between 1 and %channel_count%
    {
        channel -= 1
        VA_IPerChannelDbLevel_GetLevelRange(avl, channel, min_dB, max_dB, step_dB)
        VA_IPerChannelDbLevel_SetLevel(avl, channel, VA_Scalar2dB(vol/100, min_dB, max_dB))
    }
    COM_Release(avl)
}

VA_GetChannelCount(subunit_desc="1", device_desc="playback")
{
    avl := VA_GetDeviceSubunit(device_desc, subunit_desc, "{7FB7B48F-531D-44A2-BCB3-5AD5A134B3DC}")
    if !avl
        return
    VA_IPerChannelDbLevel_GetChannelCount(avl, channel_count)
    COM_Release(avl)
    return channel_count
}

VA_SetMute(mute, subunit_desc="1", device_desc="playback")
{
    amute := VA_GetDeviceSubunit(device_desc, subunit_desc, "{DF45AEEA-B74A-4B6B-AFAD-2366B6AA012E}")
    if !amute
        return
    VA_IAudioMute_SetMute(amute, mute)
    COM_Release(amute)
}

VA_GetMute(subunit_desc="1", device_desc="playback")
{
    amute := VA_GetDeviceSubunit(device_desc, subunit_desc, "{DF45AEEA-B74A-4B6B-AFAD-2366B6AA012E}")
    if !amute
        return
    VA_IAudioMute_GetMute(amute, muted)
    COM_Release(amute)
    return muted
}

;
; AUDIO METERING
;

VA_GetAudioMeter(device_desc="playback")
{
    if ! device := VA_GetDevice(device_desc)
        return 0
    VA_IMMDevice_Activate(device, "{C02216F6-8C67-4B5B-9D00-D008E73E0064}", 7, 0, audioMeter)
    COM_Release(device)
    return audioMeter
}

VA_GetDevicePeriod(device_desc, ByRef default_period, ByRef minimum_period="")
{
    defaultPeriod := minimumPeriod := 0
    if ! device := VA_GetDevice(device_desc)
        return false
    VA_IMMDevice_Activate(device, "{1CB9AD4C-DBFA-4c32-B178-C2F568A703B2}", 7, 0, audioClient)
    COM_Release(device)
    ; IAudioClient::GetDevicePeriod
    DllCall(NumGet(NumGet(audioClient+0)+36), "uint",audioClient, "int64*",default_period, "int64*",minimum_period)
    ; Convert 100-nanosecond units to milliseconds.
    default_period /= 10000
    minimum_period /= 10000    
    COM_Release(audioClient)
    return true
}


/* IID
    COM_GUID4String(IID_IAudioEndpointVolume,"{5CDF2C82-841E-4546-9722-0CF74078229A}")
    COM_GUID4String(IID_IAudioVolumeLevel,"{7FB7B48F-531D-44A2-BCB3-5AD5A134B3DC}")
    COM_GUID4String(IID_IAudioMute,"{DF45AEEA-B74A-4B6B-AFAD-2366B6AA012E}")
    COM_GUID4String(IID_IAudioAutoGainControl,"{85401FD4-6DE4-4b9d-9869-2D6753A82F3C}")
*/

VA_GetAudioEndpointVolume(device_desc="playback")
{
    if ! device := VA_GetDevice(device_desc)
        return 0
    VA_IMMDevice_Activate(device, "{5CDF2C82-841E-4546-9722-0CF74078229A}", 7, 0, endpointVolume)
    COM_Release(device)
    return endpointVolume
}

VA_GetDeviceSubunit(device_desc, subunit_desc, subunit_iid)
{
    device := VA_GetDevice(device_desc)
    if !device
        return 0
    subunit := VA_FindSubunit(device, subunit_desc, subunit_iid)
    COM_Release(device)
    return subunit
}

VA_FindSubunit(device, target_desc, target_iid)
{
    if target_desc is integer
        target_index := target_desc
    else
        RegExMatch(target_desc, "(?<_name>.*?)(?::(?<_index>\d+))?$", target)
    ; v2.01: Since target_name is now a regular expression, default to case-insensitive mode if no options are specified.
    if !RegExMatch(target_name,"[imsxADJUXPS`n`r`a ]+\)")
        target_name := "i)" target_name
    ; cbinfo:
    ;   @0  target_index
    ;   @4  current_index
    VarSetCapacity(cbinfo, 8, 0)
    NumPut(target_index ? target_index : 1, cbinfo, 0)
    r := VA_EnumSubunits(device, "VA_FindSubunitCallback", target_name, target_iid, &cbinfo)
    DllCall("GlobalFree", "uint", callback)
    return r
}

VA_FindSubunitCallback(part, interface, prm)
{
    NumPut(index := 1 + NumGet(prm+4), prm+4)
    if NumGet(prm+0) = index
    {
        COM_AddRef(interface)
        return interface
    }
}

VA_EnumSubunits(device, callback, target_name="", target_iid="", callback_param="")
{
    VA_IMMDevice_Activate(device, "{2A07407E-6497-4A18-9787-32F79BD0D98F}", 7, 0, deviceTopology)
    VA_IDeviceTopology_GetConnector(deviceTopology, 0, conn)
    COM_Release(deviceTopology)
    VA_IConnector_GetConnectedTo(conn, conn_to)
    VA_IConnector_GetDataFlow(conn, data_flow)
    COM_Release(conn)
    if !conn_to
        return ; blank to indicate error
    part := COM_QueryInterface(conn_to, "{AE2DE0E4-5BCA-4F2D-AA46-5D13F8FDB3A9}")
    COM_Release(conn_to)
    r := VA_EnumSubunitsEx(part, data_flow, callback, target_name, target_iid, callback_param)
    COM_Release(part)
    return r ; value returned by callback, or zero.
}

VA_EnumSubunitsEx(part, data_flow, callback, target_name="", target_iid="", callback_param="")
{
    r := 0
    
    VA_IPart_GetPartType(part, type)
    
    if type = 1 ; Subunit
    {
        VA_IPart_GetName(part, name)
        
        ; v2.01: target_name is now a regular expression.
        if RegExMatch(name, target_name)
        {
            if target_iid =
                r := %callback%(part, 0, callback_param)
            else
                if VA_IPart_Activate(part, 7, target_iid, interface) = 0
                {
                    r := %callback%(part, interface, callback_param)
                    ; The callback is responsible for calling COM_AddRef()
                    ; if it intends to keep the interface pointer.
                    COM_Release(interface)
                }

            if r
                return r ; early termination
        }
    }
    
    if data_flow = 0
        VA_IPart_EnumPartsIncoming(part, parts)
    else
        VA_IPart_EnumPartsOutgoing(part, parts)
    
    VA_IPartsList_GetCount(parts, count)
    Loop %count%
    {
        VA_IPartsList_GetPart(parts, A_Index-1, subpart)        
        r := VA_EnumSubunitsEx(subpart, data_flow, callback, target_name, target_iid, callback_param)
        COM_Release(subpart)
        if r
            break ; early termination
    }
    COM_Release(parts)
    return r ; continue/finished enumeration
}

; device_desc = device_id
;               | ( friendly_name | 'playback' | 'capture' ) [ ':' index ]
VA_GetDevice(device_desc="playback")
{
    if ! deviceEnumerator := COM_CreateObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}","{A95664D2-9614-4F35-A746-DE8DB63617E6}")
        return 0

    device := 0
    
    ; deviceEnumerator->GetDevice(device_id, [out] device)
    if DllCall(NumGet(NumGet(deviceEnumerator+0)+20), "uint",deviceEnumerator, "uint",COM_SysString(wstr, device_desc), "uint*",device) = 0
        goto VA_GetDevice_Return
    
    if device_desc is integer
    {
        m2 := device_desc
        if m2 >= 4096 ; Probably a device pointer, passed here indirectly via VA_GetAudioMeter or such.
            return m2, COM_AddRef(m2)
    }
    else
        RegExMatch(device_desc, "(.*?)\s*(?::(\d+))?$", m)
    
    if m1 in playback,p
        m1 := "", flow := 0 ; eRender
    else if m1 in capture,c
        m1 := "", flow := 1 ; eCapture
    else if (m1 . m2) = ""  ; no name or number specified
        m1 := "", flow := 0 ; eRender (default)
    else
        flow := 2 ; eAll
    
    if (m1 . m2) = ""   ; no name or number (maybe "playback" or "capture")
    {   ; deviceEnumerator->GetDefaultAudioEndpoint(dataFlow, role, [out] device)
        DllCall(NumGet(NumGet(deviceEnumerator+0)+16), "uint",deviceEnumerator, "uint",flow, "uint",0, "uint*",device)
        goto VA_GetDevice_Return
    }

    ; deviceEnumerator->EnumAudioEndpoints(dataFlow, stateMask, [out] devices)
    DllCall(NumGet(NumGet(deviceEnumerator+0)+12), "uint",deviceEnumerator, "uint",flow, "uint",1, "uint*",devices)
    
    ; devices->GetCount([out] count)
    DllCall(NumGet(NumGet(devices+0)+12), "uint",devices, "uint*",count)
    
    if m1 =
    {   ; devices->Item(m2-1, [out] device)
        DllCall(NumGet(NumGet(devices+0)+16), "uint",devices, "uint",m2-1, "uint*",device)
        goto VA_GetDevice_Return
    }
    
    index := 0
    Loop % count
        ; devices->Item(A_Index-1, [out] device)
        if DllCall(NumGet(NumGet(devices+0)+16), "uint",devices, "uint",A_Index-1, "uint*",device) = 0
            if InStr(VA_GetDeviceName(device), m1) && (m2 = "" || ++index = m2)
                goto VA_GetDevice_Return
            else
                COM_Release(device), device:=0

VA_GetDevice_Return:
    COM_Release(deviceEnumerator)
    if devices
        COM_Release(devices)
    
    return device ; may be 0
}

VA_GetDeviceName(device)
{
    static PKEY_Device_FriendlyName
    if !VarSetCapacity(PKEY_Device_FriendlyName)
        VarSetCapacity(PKEY_Device_FriendlyName, 20)
        ,COM_GUID4String(PKEY_Device_FriendlyName, "{A45C254E-DF1C-4EFD-8020-67D146A850E0}")
        ,NumPut(14, PKEY_Device_FriendlyName, 16)
    VarSetCapacity(prop, 16)
    VA_IMMDevice_OpenPropertyStore(device, 0, store)
    ; store->GetValue(.., [out] prop)
    DllCall(NumGet(NumGet(store+0)+20), "uint",store, "uint",&PKEY_Device_FriendlyName, "uint",&prop)
    COM_Release(store)
    return VA_StrGet(NumGet(prop,8)), COM_CoTaskMemFree(NumGet(prop,8))
}

VA_StrGet(pString)
{
    ; VA_StrGet: not included in AHK_L Unicode version.
    if A_IsUnicode
    {
        VarSetCapacity(sString, nLen := DllCall("msvcrt\wcslen", "uint", pString)*2)
        DllCall("RtlMoveMemory", "str", sString, "uint", pString, "uint", nLen)
        Return	sString
    }
    else
    {
        nLen := DllCall("kernel32\WideCharToMultiByte","Uint",0,"Uint",0,"Uint",pString,"int",-1,"Uint",0,"int",0,"Uint",0,"Uint",0,"Uint")
        VarSetCapacity(sString,nLen)
        If DllCall("kernel32\WideCharToMultiByte","Uint",0,"Uint",0,"Uint",pString,"int",-1,"str",sString,"int",nLen,"Uint",0,"Uint",0)
            Return	sString
    }
}


VA_dB2Scalar(dB, min_dB, max_dB) {
    min_s := 10**(min_dB/20), max_s := 10**(max_dB/20)
    return ((10**(dB/20))-min_s)/(max_s-min_s)*100
}

VA_Scalar2dB(s, min_dB, max_dB) {
    min_s := 10**(min_dB/20), max_s := 10**(max_dB/20)
    return log((max_s-min_s)*s+min_s)*20
}


;
; INTERFACE WRAPPERS
;   Reference: Core Audio APIs in Windows Vista -- Programming Reference
;       http://msdn2.microsoft.com/en-us/library/ms679156(VS.85).aspx
;

;
; IMMDevice
;
VA_IMMDevice_Activate(this, iid, ClsCtx, ActivationParams, ByRef Interface) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint", COM_GUID4String(iid,iid), "uint", ClsCtx, "uint", ActivationParams, "uint*", Interface)
}
VA_IMMDevice_OpenPropertyStore(this, Access, ByRef Properties) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint", Access, "uint*", Properties)
}
VA_IMMDevice_GetId(this, ByRef Id) {
    hr := DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint*", Id)
    Id := (VA_StrGet(Id),COM_CoTaskMemFree(Id))
    return hr
}
VA_IMMDevice_GetState(this, ByRef State) {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "uint*", State)
}

;
; IDeviceTopology
;
VA_IDeviceTopology_GetConnectorCount(this, ByRef Count) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint*", Count)
}
VA_IDeviceTopology_GetConnector(this, Index, ByRef Connector) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint", Index, "uint*", Connector)
}
VA_IDeviceTopology_GetSubunitCount(this, ByRef Count) {
    return DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint*", Count)
}
VA_IDeviceTopology_GetSubunit(this, Index, ByRef Subunit) {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "uint", Index, "uint*", Subunit)
}
VA_IDeviceTopology_GetPartById(this, Id, ByRef Part) {
    return DllCall(NumGet(NumGet(this+0)+28), "uint", this, "uint", Id, "uint*", Part)
}
VA_IDeviceTopology_GetDeviceId(this, ByRef DeviceId) {
    hr := DllCall(NumGet(NumGet(this+0)+32), "uint", this, "uint*", DeviceId)
    DeviceId := (VA_StrGet(DeviceId),COM_CoTaskMemFree(DeviceId))
    return hr
}
VA_IDeviceTopology_GetSignalPath(this, PartFrom, PartTo, RejectMixedPaths, ByRef Parts) {
    return DllCall(NumGet(NumGet(this+0)+36), "uint", this, "uint", PartFrom, "uint", PartTo, "int", RejectMixedPaths, "uint*", Parts)
}

;
; IConnector
;
VA_IConnector_GetType(this, ByRef Type) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "int*", Type)
}
VA_IConnector_GetDataFlow(this, ByRef Flow) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "int*", Flow)
}
VA_IConnector_ConnectTo(this, ConnectTo) {
    return DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint", ConnectTo)
}
VA_IConnector_Disconnect(this) {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this)
}
VA_IConnector_IsConnected(this, ByRef Connected) {
    return DllCall(NumGet(NumGet(this+0)+28), "uint", this, "int*", Connected)
}
VA_IConnector_GetConnectedTo(this, ByRef ConTo) {
    return DllCall(NumGet(NumGet(this+0)+32), "uint", this, "uint*", ConTo)
}
VA_IConnector_GetConnectorIdConnectedTo(this, ByRef ConnectorId) {
    hr := DllCall(NumGet(NumGet(this+0)+36), "uint", this, "uint*", ConnectorId)
    ConnectorId := (VA_StrGet(ConnectorId),COM_CoTaskMemFree(ConnectorId))
    return hr
}
VA_IConnector_GetDeviceIdConnectedTo(this, ByRef DeviceId) {
    hr := DllCall(NumGet(NumGet(this+0)+40), "uint", this, "uint*", DeviceId)
    DeviceId := (VA_StrGet(DeviceId),COM_CoTaskMemFree(DeviceId))
    return hr
}

;
; IPart
;
VA_IPart_GetName(this, ByRef Name) {
    hr := DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint*", Name)
    Name := (VA_StrGet(Name),COM_CoTaskMemFree(Name))
    return hr
}
VA_IPart_GetLocalId(this, ByRef Id) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint*", Id)
}
VA_IPart_GetGlobalId(this, ByRef GlobalId) {
    hr := DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint*", GlobalId)
    GlobalId := (VA_StrGet(GlobalId),COM_CoTaskMemFree(GlobalId))
    return hr
}
VA_IPart_GetPartType(this, ByRef PartType) {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "int*", PartType)
}
VA_IPart_GetSubType(this, ByRef SubType) {
    VarSetCapacity(SubType,16,0)
    hr := DllCall(NumGet(NumGet(this+0)+28), "uint", this, "uint", &SubType)
    SubType := COM_String4GUID(&SubType)
    return hr
}
VA_IPart_GetControlInterfaceCount(this, ByRef Count) {
    return DllCall(NumGet(NumGet(this+0)+32), "uint", this, "uint*", Count)
}
VA_IPart_GetControlInterface(this, Index, ByRef InterfaceDesc) {
    return DllCall(NumGet(NumGet(this+0)+36), "uint", this, "uint", Index, "uint*", InterfaceDesc)
}
VA_IPart_EnumPartsIncoming(this, ByRef Parts) {
    return DllCall(NumGet(NumGet(this+0)+40), "uint", this, "uint*", Parts)
}
VA_IPart_EnumPartsOutgoing(this, ByRef Parts) {
    return DllCall(NumGet(NumGet(this+0)+44), "uint", this, "uint*", Parts)
}
VA_IPart_GetTopologyObject(this, ByRef Topology) {
    return DllCall(NumGet(NumGet(this+0)+48), "uint", this, "uint*", Topology)
}
VA_IPart_Activate(this, ClsContext, iid, ByRef Object) {
    return DllCall(NumGet(NumGet(this+0)+52), "uint", this, "uint", ClsContext, "uint", COM_GUID4String(iid,iid), "uint*", Object)
}
VA_IPart_RegisterControlChangeCallback(this, iid, Notify) {
    return DllCall(NumGet(NumGet(this+0)+56), "uint", this, "uint", COM_GUID4String(iid,iid), "uint", Notify)
}
VA_IPart_UnregisterControlChangeCallback(this, Notify) {
    return DllCall(NumGet(NumGet(this+0)+60), "uint", this, "uint", Notify)
}

;
; IPartsList
;
VA_IPartsList_GetCount(this, ByRef Count) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint*", Count)
}
VA_IPartsList_GetPart(this, INdex, ByRef Part) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint", INdex, "uint*", Part)
}

;
; IAudioEndpointVolume
;
VA_IAudioEndpointVolume_RegisterControlChangeNotify(this, Notify) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint", Notify)
}
VA_IAudioEndpointVolume_UnregisterControlChangeNotify(this, Notify) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint", Notify)
}
VA_IAudioEndpointVolume_GetChannelCount(this, ByRef ChannelCount) {
    return DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint*", ChannelCount)
}
VA_IAudioEndpointVolume_SetMasterVolumeLevel(this, LevelDB, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "float", LevelDB, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_SetMasterVolumeLevelScalar(this, Level, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+28), "uint", this, "float", Level, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_GetMasterVolumeLevel(this, ByRef LevelDB) {
    return DllCall(NumGet(NumGet(this+0)+32), "uint", this, "float*", LevelDB)
}
VA_IAudioEndpointVolume_GetMasterVolumeLevelScalar(this, ByRef Level) {
    return DllCall(NumGet(NumGet(this+0)+36), "uint", this, "float*", Level)
}
VA_IAudioEndpointVolume_SetChannelVolumeLevel(this, Channel, LevelDB, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+40), "uint", this, "uint", Channel, "float", LevelDB, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_SetChannelVolumeLevelScalar(this, Channel, Level, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+44), "uint", this, "uint", Channel, "float", Level, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_GetChannelVolumeLevel(this, Channel, ByRef LevelDB) {
    return DllCall(NumGet(NumGet(this+0)+48), "uint", this, "uint", Channel, "float*", LevelDB)
}
VA_IAudioEndpointVolume_GetChannelVolumeLevelScalar(this, Channel, ByRef Level) {
    return DllCall(NumGet(NumGet(this+0)+52), "uint", this, "uint", Channel, "float*", Level)
}
VA_IAudioEndpointVolume_SetMute(this, Mute, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+56), "uint", this, "int", Mute, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_GetMute(this, ByRef Mute) {
    return DllCall(NumGet(NumGet(this+0)+60), "uint", this, "int*", Mute)
}
VA_IAudioEndpointVolume_GetVolumeStepInfo(this, ByRef Step, ByRef StepCount) {
    return DllCall(NumGet(NumGet(this+0)+64), "uint", this, "uint*", Step, "uint*", StepCount)
}
VA_IAudioEndpointVolume_VolumeStepUp(this, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+68), "uint", this, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_VolumeStepDown(this, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+72), "uint", this, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioEndpointVolume_QueryHardwareSupport(this, ByRef HardwareSupportMask) {
    return DllCall(NumGet(NumGet(this+0)+76), "uint", this, "uint*", HardwareSupportMask)
}
VA_IAudioEndpointVolume_GetVolumeRange(this, ByRef MinDB, ByRef MaxDB, ByRef IncrementDB) {
    return DllCall(NumGet(NumGet(this+0)+80), "uint", this, "float*", MinDB, "float*", MaxDB, "float*", IncrementDB)
}

;
; IPerChannelDbLevel
;   Applies to IAudioVolumeLevel, IAudioBass, IAudioMidrange and IAudioTreble.
;
VA_IPerChannelDbLevel_GetChannelCount(this, ByRef Channels) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "uint*", Channels)
}
VA_IPerChannelDbLevel_GetLevelRange(this, Channel, ByRef MinLevelDB, ByRef MaxLevelDB, ByRef Stepping) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint", Channel, "float*", MinLevelDB, "float*", MaxLevelDB, "float*", Stepping)
}
VA_IPerChannelDbLevel_GetLevel(this, Channel, ByRef LevelDB) {
    return DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint", Channel, "float*", LevelDB)
}
VA_IPerChannelDbLevel_SetLevel(this, Channel, LevelDB, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "uint", Channel, "float", LevelDB, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IPerChannelDbLevel_SetLevelUniform(this, LevelDB, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+28), "uint", this, "float", LevelDB, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IPerChannelDbLevel_SetLevelAllChannels(this, LevelsDB, ChannelCount, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+32), "uint", this, "uint", LevelsDB, "uint", ChannelCount, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}

;
; IAudioMute
;
VA_IAudioMute_SetMute(this, Muted, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "int", Muted, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}
VA_IAudioMute_GetMute(this, ByRef Muted) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "int*", Muted)
}

;
; IAudioAutoGainControl
;
VA_IAudioAutoGainControl_GetEnabled(this, ByRef Enabled) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "int*", Enabled)
}
VA_IAudioAutoGainControl_SetEnabled(this, Enable, GuidEventContext="") {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "int", Enable, "uint", GuidEventContext ? COM_GUID4String(GuidEventContext,GuidEventContext) : 0)
}

;
; IAudioMeterInformation
;
VA_IAudioMeterInformation_GetPeakValue(this, ByRef Peak) {
    return DllCall(NumGet(NumGet(this+0)+12), "uint", this, "float*", Peak)
}
VA_IAudioMeterInformation_GetMeteringChannelCount(this, ByRef ChannelCount) {
    return DllCall(NumGet(NumGet(this+0)+16), "uint", this, "uint*", ChannelCount)
}
VA_IAudioMeterInformation_GetChannelsPeakValues(this, ChannelCount, PeakValues) {
    return DllCall(NumGet(NumGet(this+0)+20), "uint", this, "uint", ChannelCount, "uint", PeakValues)
}
VA_IAudioMeterInformation_QueryHardwareSupport(this, ByRef HardwareSupportMask) {
    return DllCall(NumGet(NumGet(this+0)+24), "uint", this, "uint*", HardwareSupportMask)
}
