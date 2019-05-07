#Include ..\header.ahk
; -------------------------------------------------------------------------------


; Enumeramos los dispositivos activos
_IMMDeviceEnumerator := new IMMDeviceEnumerator
_IMMDeviceEnumerator.EnumAudioEndpoints(0, 0x1, _IMMDeviceCollection)    ; 0x1=DEVICE_STATE_ACTIVE
_IMMDeviceEnumerator := ''

; Recuperamos la interfaz para cada dispositivo y su información
_IMMDeviceCollection.GetCount(Count)
Loop (Count)
{
    ; Recuperamos la interfaz del dispositivo de audio #A_Index-1
    _IMMDeviceCollection.Item(A_Index-1, _IMMDevice)

    ; Creamos la interfaz IPropertyStore y recuperamos el nombre del dispositivo
    _IMMDevice.OpenPropertyStore(0, _IPropertyStore)
    _IPropertyStore.GetValue(_IPropertyStore.PROPERTYKEY('{A45C254E-DF1C-4EFD-8020-67D146A850E0}', 14, PROPERTYKEY), PROPVARIANT)
    List .= _IPropertyStore.GetDeviceName(&PROPVARIANT) . '`n------------------------------------------------------`n'
    _IPropertyStore := ''    ; eliminamos la interfaz IPropertyStore

    ; Creamos la interfaz IAudioSessionManager2
    _IMMDevice.IAudioSessionManager2(_IAudioSessionManager2)
    _IMMDevice := ''    ; eliminamos la interfaz IMMDevice

    ; Recuperamos la interfaz IAudioSessionEnumerator de la sesión de audio utilizado para enumerar las sesiones
    _IAudioSessionManager2.GetSessionEnumerator(_IAudioSessionEnumerator)
    _IAudioSessionManager2 := ''    ; eliminamos la interfaz IAudioSessionManager2

    ; Enumeramos las sesiones
    _IAudioSessionEnumerator.GetCount(Count)
    Loop (Count)
    {
        _IAudioSessionEnumerator.GetSession(A_Index-1, _IAudioSessionControl)
        _IAudioSessionControl.GetDisplayName(DisplayName)
        List .= '#' . A_Index . A_Space . (DisplayName==''?'[sin nombre]':DisplayName) . '`n'
        _IAudioSessionControl := ''    ; eliminamos la interfaz IAudioSessionControl
    }
    List .= '`n'
    _IAudioSessionEnumerator := ''    ; eliminamos la interfaz IAudioSessionEnumerator
}
_IMMDeviceCollection := ''

; Mostramos las sesiones y terminamos
MsgBox(List)
ExitApp
