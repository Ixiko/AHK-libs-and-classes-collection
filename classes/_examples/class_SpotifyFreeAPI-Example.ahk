#Include, SpotifyFreeAPI.ahk

; Enable this to buffer incoming hotkeys 
; because api calls will take time to return
#MaxThreadsBuffer, On 

global spotify := new SpotifyAPI()

<^Up::spotify.SetVolume(10,1)

<^Down::spotify.SetVolume(-10,1)

<^Right::spotify.NextTrack()

<^Left::spotify.PreviousTrack()
