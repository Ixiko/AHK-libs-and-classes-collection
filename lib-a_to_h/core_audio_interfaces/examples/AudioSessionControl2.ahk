#Include ..\header.ahk
; En este ejemplo se obtiene una lista de procesos y su volumen
; Referencia: https://autohotkey.com/board/topic/21984-vista-audio-control-functions/page-12#entry608538
; -------------------------------------------------------------------------------


; Recupera el dispositivo de audio por defecto
_IMMDeviceEnumerator := new IMMDeviceEnumerator
_IMMDeviceEnumerator.GetDefaultAudioEndpoint(0, 1, _IMMDevice)
_IMMDeviceEnumerator := ''    ; eliminamos la interfaz IMMDeviceEnumerator

; Creamos la interfaz IAudioSessionManager2
_IMMDevice.IAudioSessionManager2(_IAudioSessionManager2)
_IMMDevice := ''    ; eliminamos la interfaz IMMDevice

; Enumera las sesiones para este dispositivo
_IAudioSessionManager2.GetSessionEnumerator(_IAudioSessionEnumerator)
_IAudioSessionManager2 := ''    ; eliminamos la interfaz IAudioSessionManager2

; Busca en todas la sesiones activas
_IAudioSessionEnumerator.GetCount(SessionCount)
Loop (SessionCount)
{
    _IAudioSessionEnumerator.GetSession(A_Index-1, _IAudioSessionControl)

    ; Recupera la interfaz IAudioSessionControl2
    _IAudioSessionControl.IAudioSessionControl2(_IAudioSessionControl2)
    _IAudioSessionControl := ''    ; elimina la interfaz IAudioSessionControl

    ; Recuperamos el identificador del proceso
    _IAudioSessionControl2.GetProcessId(ProcessId)

    ; Recupera la interfaz ISimpleAudioVolume y el volumen actual del proceso
    _IAudioSessionControl2.ISimpleAudioVolume(_ISimpleAudioVolume)
    _ISimpleAudioVolume.GetMasterVolume(Volume)
    List .= ProcessId . ': ' . Round(Volume*100, 2) . ' %`n'
    _ISimpleAudioVolume := ''    ; eliminamos la interfaz ISimpleAudioVolume
    _IAudioSessionControl2 := ''    ; eliminamos la interfaz IAudioSessionControl2
}
_IAudioSessionEnumerator := ''    ; elimina la interfaz IAudioSessionEnumerator

; Mostramos la información y terminamos
MsgBox(List)
ExitApp
