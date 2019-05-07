#Include ..\header.ahk
; -------------------------------------------------------------------------------


; GetDefaultAudioEndpoint
_IMMDeviceEnumerator := new IMMDeviceEnumerator
_IMMDeviceEnumerator.GetDefaultAudioEndpoint(0, 1, _IMMDevice)
_IMMDeviceEnumerator := ''

; Create IAudioEndpointVolume Interface
_IMMDevice.IAudioEndpointVolume(_IAudioEndpointVolume, 7)
_IMMDevice := ''

; SetMute
MsgBox 'SetMute(TRUE) = ' . _IAudioEndpointVolume.SetMute(TRUE)
MsgBox 'SetMute(FALSE) = ' . _IAudioEndpointVolume.SetMute(FALSE)

; GetMasterVolumeLevelScalar / SetMasterVolumeLevelScalar
_IAudioEndpointVolume.GetMasterVolumeLevelScalar(MVLS)
MsgBox 'SetMasterVolumeLevelScalar(1) = ' . _IAudioEndpointVolume.SetMasterVolumeLevelScalar(1)    ; 0% = 0.0 | 1% = 0.1 | 100% = 1.0
MsgBox 'SetMasterVolumeLevelScalar(' . Round(MVLS*100) . ') = ' . _IAudioEndpointVolume.SetMasterVolumeLevelScalar(MVLS)

_IAudioEndpointVolume := ''
ExitApp
