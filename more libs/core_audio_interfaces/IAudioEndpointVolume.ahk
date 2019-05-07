Class IAudioEndpointVolume
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['RegisterControlChangeNotify','UnregisterControlChangeNotify','GetChannelCount','SetMasterVolumeLevel','SetMasterVolumeLevelScalar','GetMasterVolumeLevel','GetMasterVolumeLevelScalar','SetChannelVolumeLevel','SetChannelVolumeLevelScalar','GetChannelVolumeLevel','GetChannelVolumeLevelScalar','SetMute','GetMute','GetVolumeStepInfo','VolumeStepUp','VolumeStepDown','QueryHardwareSupport','GetVolumeRange']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/dd370892(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Registra la interfaz de devolución de llamada de un cliente.
    */
    RegisterControlChangeNotify(oIAudioEndpointVolumeCallback)
    {
        Return DllCall(this.pRegisterControlChangeNotify, 'UPtr', this.ptr, 'UPtr', IsObject(oIAudioEndpointVolumeCallback) ? oIAudioEndpointVolumeCallback.ptr : oIAudioEndpointVolumeCallback, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368050(v=vs.85).aspx

    /*
        Elimina el registro de la interfaz de devolución de llamada de un cliente.
    */
    UnregisterControlChangeNotify(oIAudioEndpointVolumeCallback)
    {
        Return DllCall(this.pUnregisterControlChangeNotify, 'UPtr', this.ptr, 'UPtr', IsObject(oIAudioEndpointVolumeCallback) ? oIAudioEndpointVolumeCallback.ptr : oIAudioEndpointVolumeCallback, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368067(v=vs.85).aspx

    /*
        Obtiene un recuento de los canales en la transmisión de audio.
    */
    GetChannelCount(ByRef ChannelCount)
    {
        Return DllCall(this.pGetChannelCount, 'UPtr', this.ptr, 'UIntP', ChannelCount, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd370918(v=vs.85).aspx

    /*
        Establece el nivel de volumen principal de la transmisión de audio, en decibelios.
    */
    SetMasterVolumeLevel(LevelDB, ByRef EventContext := 0)
    {
        Return DllCall(this.pSetMasterVolumeLevel, 'UPtr', this.ptr, 'Float', LevelDB, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368059(v=vs.85).aspx

    /*
        Establece el nivel de volumen principal, expresado como un valor normalizado, audio-cónico.
        Parámetros:
            Level: El nuevo nivel de volumen maestro. El nivel se puede expresar como un valor normalizado en el rango de 0.0 a 1.0; o como un entero de 1 a 100.
    */
    SetMasterVolumeLevelScalar(Level, ByRef EventContext := 0)
    {
        Return DllCall(this.pSetMasterVolumeLevelScalar, 'UPtr', this.ptr, 'Float', InStr(Level, '.') ? Level : Level/100.0, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368062(v=vs.85).aspx

    /*
        Obtiene el nivel de volumen principal de la transmisión de audio, en decibeles.
    */
    GetMasterVolumeLevel(ByRef LevelDB)
    {
        DllCall(this.pGetMasterVolumeLevel, 'UPtr', this.ptr, 'FloatP', LevelDB, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd370927(v=vs.85).aspx

    /*
        Obtiene el nivel de volumen principal de la transmisión de audio que ingresa o sale del dispositivo de punto final de audio.
        Parámetros:
            Level: Recibe el nivel de volumen principal. El nivel se expresa como un valor normalizado en el rango de 0.0 a 1.0.
    */
    GetMasterVolumeLevelScalar(ByRef Level)
    {
        DllCall(this.pGetMasterVolumeLevelScalar, 'UPtr', this.ptr, 'FloatP', Level, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd370930(v=vs.85).aspx

    /*
        Establece el nivel de volumen, en decibeles, del canal especificado de la transmisión de audio.
    */
    SetChannelVolumeLevel(Channel, LevelDB, ByRef EventContext := 0)
    {
        DllCall(this.pSetChannelVolumeLevel, 'UPtr', this.ptr, 'UInt', Channel, 'Float', LevelDB, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368053(v=vs.85).aspx

    /*
        Establece el nivel de volumen de audio cónico normalizado del canal especificado en la transmisión de audio.
    */
    SetChannelVolumeLevelScalar(Channel, Level, ByRef EventContext := 0)
    {
        DllCall(this.pSetChannelVolumeLevelScalar, 'UPtr', this.ptr, 'UInt', Channel, 'Float', InStr(Level, '.') ? Level : Level/100.0, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368056(v=vs.85).aspx

    /*
        Obtiene el nivel de volumen, en decibeles, del canal especificado en la transmisión de audio.
    */
    GetChannelVolumeLevel(Channel, ByRef LevelDB)
    {
        Return DllCall(this.pGetChannelVolumeLevel, 'UPtr', this.ptr, 'UInt', Channel, 'FloatP', LevelDB, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd370920(v=vs.85).aspx

    GetChannelVolumeLevelScalar(Channel, ByRef Level)
    {
        Return DllCall(this.pGetChannelVolumeLevelScalar, 'UPtr', this.ptr, 'UInt', Channel, 'FloatP', Level, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd370924(v=vs.85).aspx

    /*
        Establece el estado de silenciamiento de la transmisión de audio.
    */
    SetMute(Mute, ByRef EventContext := 0)
    {
        Local GUID
        Return DllCall(this.pSetMute, 'UPtr', this.ptr, 'Int', Mute, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368064(v=vs.85).aspx

    /*
        Obtiene el estado de silenciamiento de la transmisión de audio que ingresa o sale del dispositivo de punto final de audio.
    */
    GetMute(ByRef Mute)
    {
        Return DllCall(this.pGetMute, 'UPtr', this.ptr, 'IntP', Mute, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368037(v=vs.85).aspx

    /*
        Obtiene información sobre el paso actual en el rango de volumen.
    */
    GetVolumeStepInfo(ByRef StepIndex, ByRef StepCount)
    {
        Return DllCall(this.pGetVolumeStepInfo, 'UPtr', this.ptr, 'UIntP', StepIndex, 'UIntP', StepCount, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368042(v=vs.85).aspx

    /*
        Aumenta el nivel de volumen en un paso.
    */
    VolumeStepUp(ByRef EventContext := 0)
    {
        Return DllCall(this.pVolumeStepUp, 'UPtr', this.ptr, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368219(v=vs.85).aspx

    /*
        Disminuye el nivel de volumen en un paso.
    */
    VolumeStepDown(ByRef EventContext := 0)
    {
        Return DllCall(this.pVolumeStepDown, 'UPtr', this.ptr, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368218(v=vs.85).aspx

    /*
        Consulta el dispositivo de punto final de audio para sus funciones compatibles con hardware.
    */
    QueryHardwareSupport(ByRef HardwareSupportMask)
    {
        Return DllCall(this.pQueryHardwareSupport, 'UPtr', this.ptr, 'UIntP', HardwareSupportMask, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368047(v=vs.85).aspx

    /*
        Obtiene el rango de volumen de la transmisión de audio, en decibeles.
    */
    GetVolumeRange(ByRef LevelMinDB, ByRef LevelMaxDB, ByRef VolumeIncrementDB)
    {
        Return DllCall(this.pQueryHardwareSupport, 'UPtr', this.ptr, 'FloatP', LevelMinDB, 'FloatP', LevelMaxDB, 'FloatP', VolumeIncrementDB, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368039(v=vs.85).aspx
}
