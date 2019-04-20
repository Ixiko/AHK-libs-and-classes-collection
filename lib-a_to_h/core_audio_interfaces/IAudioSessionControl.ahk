Class IAudioSessionControl
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['GetState','GetDisplayName','SetDisplayName','GetIconPath','SetIconPath','GetGroupingParam','SetGroupingParam','RegisterAudioSessionNotification','UnregisterAudioSessionNotification']
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
    ; HELPER METHODS
    ; ===================================================================================================================
    /*
        Consulta esta interfaz por una interfaz IAudioSessionControl2.
    */
    IAudioSessionControl2(ByRef oIAudioSessionControl2)
    {
        Local pIAudioSessionControl2 := ComObjQuery(this.ptr, '{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}')
        oIAudioSessionControl2 := pIAudioSessionControl2 ? new IAudioSessionControl2(pIAudioSessionControl2) : FALSE
        Return IsObject(oIAudioSessionControl2) - 1
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Recupera el nombre para mostrar de la sesión de audio.
        Observaciones:
            Si el cliente no ha llamado a IAudioSessionControl::SetDisplayName para establecer el nombre para mostrar, la cadena estará vacía.
            En lugar de mostrar una cadena de nombre vacía, el programa Sndvol usa un nombre predeterminado generado automáticamente para etiquetar el control de volumen para la sesión de audio.
    */
    GetDisplayName(ByRef DisplayName)
    {
        Local R := DllCall(this.pGetDisplayName, 'UPtr', this.ptr, 'UPtrP', pBuffer, 'UInt')
        If (R == 0)    ; S_OK
            DisplayName := StrGet(pBuffer, 'UTF-16'), DllCall('Ole32.dll\CoTaskMemFree', 'UPtr', pBuffer)
        Else DisplayName := ''
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd368261(v=vs.85).aspx
}
