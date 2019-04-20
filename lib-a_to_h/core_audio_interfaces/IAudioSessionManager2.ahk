Class IAudioSessionManager2
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetAudioSessionControl','GetSimpleAudioVolume','GetSessionEnumerator','RegisterSessionNotification','UnregisterSessionNotification','RegisterDuckNotification','UnregisterDuckNotification']
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
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Recupera una interfaz IAudioSessionEnumerator de la sesión de audio utilizado para enumerar las sesiones.
    */
    GetSessionEnumerator(ByRef oIAudioSessionEnumerator)
    {
        Local R := DllCall(this.pGetSessionEnumerator, 'UPtr', this.ptr, 'UPtrP', pIAudioSessionEnumerator, 'UInt')
        oIAudioSessionEnumerator := R == 0 ? new IAudioSessionEnumerator(pIAudioSessionEnumerator) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd370952(v=vs.85).aspx
}
