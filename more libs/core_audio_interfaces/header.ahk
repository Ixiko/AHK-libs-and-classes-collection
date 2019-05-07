/*
    Core Audio Interfaces
    Referencia:
        https://msdn.microsoft.com/en-us/library/dd370805(v=vs.85).aspx
*/



/*
    ===============================================================
    ==== MMDevice API
    ===============================================================
*/
#Include IMMDevice.ahk
#Include IMMDeviceCollection.ahk
#Include IMMDeviceEnumerator.ahk
;#Include IMMEndpoint.ahk
;#Include IMMNotificationClient.ahk




/*
    ===============================================================
    ==== WASAPI
    ===============================================================
*/
;#Include IActivateAudioInterfaceAsyncOperation.ahk 
;#Include IActivateAudioInterfaceCompletionHandler.ahk
;;#Include IAudioCaptureClient.ahk
;#Include IAudioClient.ahk
;#Include IAudioClock.ahk
;#Include IAudioClock2.ahk
;#Include IAudioClockAdjustment.ahk
;#Include IAudioRenderClient.ahk
#Include IAudioSessionControl.ahk
#Include IAudioSessionControl2.ahk
;#Include IAudioSessionManager.ahk
#Include IAudioSessionManager2.ahk
#Include IAudioSessionEnumerator.ahk
;#Include IAudioStreamVolume.ahk
;#Include IChannelAudioVolume.ahk
#Include ISimpleAudioVolume.ahk
;#Include IAudioSessionEvents.ahk
;#Include IAudioSessionNotification.ahk
;#Include IAudioVolumeDuckNotification.ahk




/*
    ===============================================================
    ==== DeviceTopology API
    ===============================================================
*/
;#Include IAudioAutoGainControl.ahk
;#Include IAudioBass.ahk
;#Include IAudioChannelConfig.ahk
;#Include IAudioInputSelector.ahk
;#Include IAudioLoudness.ahk
;#Include IAudioMidrange.ahk
;#Include IAudioMute.ahk
;#Include IAudioOutputSelector.ahk
;#Include IAudioPeakMeter.ahk
;#Include IAudioTreble.ahk
;#Include IAudioVolumeLevel.ahk
;#Include IConnector.ahk
;#Include IControlInterface.ahk
;#Include IDeviceSpecificProperty.ahk
;#Include IDeviceTopology.ahk
;#Include IKsFormatSupport.ahk
;#Include IKsJackDescription.ahk
;#Include IKsJackDescription2.ahk
;#Include IKsJackSinkInformation.ahk
;#Include IPart.ahk
;#Include IPartsList.ahk
;#Include IPerChannelDbLevel.ahk
;#Include ISubunit.ahk
;#Include IControlChangeNotify.ahk




/*
    ===============================================================
    ==== EndpointVolume API
    ===============================================================
*/
#Include IAudioEndpointVolume.ahk
;#Include IAudioEndpointVolumeEx.ahk
;#Include IAudioMeterInformation.ahk
;#Include IAudioEndpointVolumeCallback.ahk




/*
    ===============================================================
    ==== OTHER
    ===============================================================
*/
#Include IPropertyStore.ahk
