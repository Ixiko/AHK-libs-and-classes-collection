Class IAudioSessionControl2
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetState','GetDisplayName','SetDisplayName','GetIconPath','SetIconPath','GetGroupingParam','SetGroupingParam','RegisterAudioSessionNotification','UnregisterAudioSessionNotification','GetSessionIdentifier','GetSessionInstanceIdentifier','GetProcessId','IsSystemSoundsSession','SetDuckingPreference']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd368248(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.ptr)
    }


    ; ===================================================================================================================
    ; HELPER METHODS
    ; ===================================================================================================================
    /*
        Consulta esta interfaz por la interfaz ISimpleAudioVolume
    */
    ISimpleAudioVolume(ByRef oISimpleAudioVolume)
    {
        Local pISimpleAudioVolume := ComObjQuery(this.ptr, '{87CE5498-68D6-44E5-9215-6DA47EF883D8}')
        oISimpleAudioVolume := pISimpleAudioVolume ? new ISimpleAudioVolume(pISimpleAudioVolume) : FALSE
        Return IsObject(oISimpleAudioVolume) - 1
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Recupera el identificador de proceso de la sesión.
    */
    GetProcessId(ByRef ProcessId)
    {
        Return DllCall(this.pGetProcessId, 'UPtr', this.ptr, 'UIntP', ProcessId, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/dd368250(v=vs.85).aspx
}
