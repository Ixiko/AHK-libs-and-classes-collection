Class IMMDevice
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(ptr)
    {
        this.ptr := ptr

        For Each, Method in ['Activate','OpenPropertyStore','GetId','GetState']
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
    ; HELPER METHODS
    ; ===================================================================================================================
    /*
        Crea una interfaz IAudioEndpointVolume
    */
    IAudioEndpointVolume(ByRef oIAudioEndpointVolume, ClsCtx := 23)
    {
        Local pIAudioEndpointVolume, R := this.Activate('{5CDF2C82-841E-4546-9722-0CF74078229A}', ClsCtx, 0, pIAudioEndpointVolume)
        oIAudioEndpointVolume := R == 0 ? new IAudioEndpointVolume(pIAudioEndpointVolume) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd370892(v=vs.85).aspx

    /*
        Crea una interfaz IAudioSessionManager2
    */
    IAudioSessionManager2(ByRef oIAudioSessionManager2, ClsCtx := 23)
    {
        Local pIAudioSessionManager2, R := this.Activate('{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}', ClsCtx, 0, pIAudioSessionManager2)
        oIAudioSessionManager2 := R == 0 ? new IAudioSessionManager2(pIAudioSessionManager2) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd370950%28VS.85%29.aspx


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    /*
        Crea un objeto COM con la interfaz especificada. Puede utilizar los HELPER METHODS para recuperar alguna de estas interfaces.
    */
    Activate(InterfaceID, ClsCtx, ActivationParams, ByRef pInterface)
    {
        Local pGUID, GUID
        If (InterfaceID is 'Integer')
            pGUID := InterfaceID
        Else    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680589(v=vs.85).aspx
            VarSetCapacity(GUID, 16), DllCall('Ole32.dll\CLSIDFromString', 'UPtr', &InterfaceID, 'UPtr', &GUID), pGUID := &GUID

        Return DllCall(this.pActivate, 'UPtr', this.ptr, 'UPtr', pGUID, 'UInt', ClsCtx, 'UPtr', ActivationParams, 'UPtrP', pInterface, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd371405(v=vs.85).aspx

    /*
        Recupera una interfaz para el almacén de propiedades del dispositivo.
        Parámetros:
            Access: El modo de acceso de almacenamiento. Este parámetro especifica si abrirá el almacén de propiedades en modo de lectura, modo de escritura o modo de lectura / escritura. Establezca este parámetro en una de las siguientes constantes de STGM:
                0x00000000 = STGM_READ
                0x00000001 = STGM_WRITE
                0x00000002 = STGM_READWRITE
    */
    OpenPropertyStore(Access, ByRef oIPropertyStore)
    {
        Local pIPropertyStore, R := DllCall(this.pOpenPropertyStore, 'UPtr', this.ptr, 'UInt', Access, 'UPtrP', pIPropertyStore, 'UInt')
        oIPropertyStore := R == 0 ? new IPropertyStore(pIPropertyStore) : FALSE
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371412(v=vs.85).aspx

    /*
        Recupera una cadena que identifica al dispositivo.
    */
    GetId(ByRef DeviceID)
    {
        Local R := DllCall(this.pGetId, 'UPtr', this.ptr, 'UPtrP', pBuffer, 'UInt')
        If (R == 0)
            DeviceID := StrGet(pBuffer, 'UTF-16'), DllCall('Ole32.dll\CoTaskMemFree', 'UPtr', pBuffer)
        Else DeviceID := ''
        Return R
    } ; https://msdn.microsoft.com/en-us/library/dd371407(v=vs.85).aspx

    /*
        Recupera el estado actual del dispositivo.
        Parámetros:
            State: Recibe el estado actual del dispositivo. El valor del estado del dispositivo es una de las siguientes constantes DEVICE_STATE_XXX:
                0x00000001 = DEVICE_STATE_ACTIVE
                0x00000002 = DEVICE_STATE_DISABLED
                0x00000004 = DEVICE_STATE_NOTPRESENT
                0x00000008 = DEVICE_STATE_UNPLUGGED
                0x0000000F = DEVICE_STATEMASK_ALL
    */
    GetState(ByRef State)
    {
        Return DllCall(this.pGetState, 'UPtr', this.ptr, 'UIntP', State, 'UInt')
    } ; https://msdn.microsoft.com/en-us/library/dd371410(v=vs.85).aspx
}
