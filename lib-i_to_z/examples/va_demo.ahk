#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Get the master volume of the default playback device.
volume := VA_GetMasterVolume()

; Get the volume of the first and second channels.
volume1 := VA_GetMasterVolume(1)
volume2 := VA_GetMasterVolume(2)

; Get the master volume of a device by name.
lineout_volume := VA_GetMasterVolume("", "Line Out")

; Get the master volume of the default recording device.
recording_volume := VA_GetMasterVolume("", "capture")

MsgBox, % "Playback volume:`t" volume
        . "`n  Channel 1:`t" volume1
        . "`n  Channel 2:`t" volume2
        . "`nLine Out volume:`t" lineout_volume
        . "`nRecording volume:`t" recording_volume
        