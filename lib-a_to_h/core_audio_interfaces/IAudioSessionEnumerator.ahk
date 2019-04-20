Class IAudioSessionEnumerator
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetCount','GetSession']
            ObjRawSet(this, 'p' . Method, NumGet(NumGet(this.ptr) + (2 + A_Index) * A_PtrSize))
    } ; https://msdn.microsoft.com/en-us/library/dd368281(v=vs.85).aspx


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
        Obtiene la cantidad total de sesiones de audio que están abiertas en el dispositivo de audio.
    */
    GetCount(ByRef SessionCount)
    {
        Return DllCall(this.pGetCount, 'UPtr', this.ptr, 'UIntP', SessionCount, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd368284(v=vs.85).aspx

    /*
        Obtiene la sesión de audio especificada por un número de sesión de audio.
    */
    GetSession(SessionNumber, ByRef oIAudioSessionControl)
    {
        Local pIAudioSessionControl, R := DllCall(this.pGetSession, 'UPtr', this.ptr, 'Int', SessionNumber, 'UPtrP', pIAudioSessionControl, 'UInt')
        oIAudioSessionControl := R == 0 ? new IAudioSessionControl(pIAudioSessionControl) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd368286(v=vs.85).aspx
}
