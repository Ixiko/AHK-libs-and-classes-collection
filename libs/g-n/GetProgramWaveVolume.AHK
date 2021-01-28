; on Vista and above this will get the process/program volume only
; on xp and below this will get the system volume
GetProgramWaveVolume(device := 1) {
    DllCall("winmm\waveOutGetVolume", "int", device-1, "uint*", v)
    return round((0xFFFF & v) / 655.35)
}