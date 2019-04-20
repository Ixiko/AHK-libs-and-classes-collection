#Include VA.ahk

muteWindow(winName="A",mode="t"){
    winGet,winPid,PID,% winName
    if !(volume:=GetVolumeObject(winPid))
      return
    if(mode=t){
        VA_ISimpleAudioVolume_GetMute(volume,Mute)  ;Get mute state
        VA_ISimpleAudioVolume_SetMute(volume,!Mute) ;Toggle mute state
    }else if mode between 0 and 1
        VA_ISimpleAudioVolume_SetMute(volume,mode)
    objRelease(Volume)
    return
}
