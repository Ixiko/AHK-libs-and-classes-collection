Class ISimpleAudioVolume
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['SetMasterVolume','GetMasterVolume','SetMute','GetMute']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd316531(v=vs.85).aspx


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
        Establece el nivel de volumen maestro para la sesión de audio.
    */
    SetMasterVolume(Volume, ByRef EventContext := 0)
    {
        Return DllCall(this.pSetMasterVolume, 'UPtr', this.ptr, 'Float', InStr(Volume, '.') ? Volume : Volume/100.0, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd316537(v=vs.85).aspx

    /*
        Recupera el nivel de volumen del cliente para la sesión de audio.
    */
    GetMasterVolume(ByRef Level)
    {
        Return DllCall(this.pGetMasterVolume, 'UPtr', this.ptr, 'FloatP', Level, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd316533(v=vs.85).aspx

    /*
        Establece el estado de silenciamiento para la sesión de audio.
    */
    SetMute(Mute, ByRef EventContext := 0)
    {
        Return DllCall(this.pSetMasterVolume, 'UPtr', this.ptr, 'Int', Mute, 'UPtr', IMMDeviceEnumerator.__EventContext(EventContext, GUID), 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd316539(v=vs.85).aspx

    /*
        Recupera el estado de silenciamiento actual para la sesión de audio.
    */
    GetMute(ByRef Mute)
    {
        Return DllCall(this.pMute, 'UPtr', this.ptr, 'IntP', Mute, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd316535(v=vs.85).aspx
}
