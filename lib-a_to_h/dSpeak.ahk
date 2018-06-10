dSpeak(Message, fSapi_vol="", fOverall_vol="")
{	global programVolume, speech_volume

	if !fSapi_vol
		fSapi_vol := speech_volume
	if !fOverall_vol
		fOverall_vol := programVolume
	Header := 	"programVolume := " fOverall_vol "`r`n"		; windows files require both `r`n to correctly signal end of line - but `n will work by itself....
				. "speech_volume := " fSapi_vol  "`r`n"
				. "Message := """ Message """`r`n"			; ***note "" double consecutive quotes resolve to a literal "  quote!!!
	static Footer := "
					(Join`r`n
						#NoTrayIcon
						SAPI := ComObjCreate(""SAPI.SpVoice"")	; Unlike above, these lines can take comments and formatting!
						SAPI.volume := speech_volume
						if A_OSVersion NOT in WIN_XP,WIN_2003,WIN_2000 	; below vista this sets system volume rather than
						{										; process/program volume
							v := programVolume*655.35
						    DllCall(""winmm\waveOutSetVolume"", ""int"", device-1, ""uint"", v|(v<<16))
						}						
						Try SAPI.Speak(Message)
						ExitApp
					)"

	DynaRun(CreateScript(Header . Footer), "MT_Speech.AHK", A_Temp "\AHK.exe") ; note as this script doesnt have any #includes/formatting changes - dont need to pass it to create script eg. could just DynaRun(Header . Footer)
	Return 
}