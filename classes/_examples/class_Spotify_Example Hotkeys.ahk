#Include %A_ScriptDir%
#Include Spotify.ahk
global VolumePercentage
global ShuffleMode
global RepeatMode := 0
spoofy := new Spotify
VolumePercentage := spoofy.Player.GetCurrentPlaybackInfo().Device.Volume
return

F1::
VolumePercentage--
spoofy.Player.SetVolume(VolumePercentage) ; Decrement the volume percentage and set the player to the new volume percentage
return

F2::
VolumePercentage++
spoofy.Player.SetVolume(VolumePercentage) ; Increment the volume percentage and set the player to the new volume percentage
return 

F3::
ShuffleMode := !ShuffleMode
spoofy.Player.SetShuffle(ShuffleMode) ; Swap the shuffle mode of the player
return 

F4::
RepeatMode := RepeatMode + (RepeatMode = 0 ? 1 : (RepeatMode = 1 ? 1 : (RepeatMode = 2 ? 1 : -2)))
spoofy.Player.SetRepeatMode(RepeatMode) ; Cycle through the three repeat modes (1-2, 2-3, 3-1)
return 
