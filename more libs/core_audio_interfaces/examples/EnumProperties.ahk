#Include ..\header.ahk
; -------------------------------------------------------------------------------


; GetDefaultAudioEndpoint
_IMMDeviceEnumerator := new IMMDeviceEnumerator
_IMMDeviceEnumerator.GetDefaultAudioEndpoint(0, 1, _IMMDevice)
_IMMDeviceEnumerator := ''

; OpenPropertyStore
_IMMDevice.OpenPropertyStore(0, _IPropertyStore)
_IMMDevice := ''

; Enum Properties
_IPropertyStore.GetCount(Count)
Loop (Count)
{
    _IPropertyStore.GetAt(A_Index-1, PROPERTYKEY)
    List .= _IPropertyStore.PROPERTYKEY(&PROPERTYKEY).GUID . '`n'
}
_IPropertyStore := ''

; show
MsgBox(List)
ExitApp
