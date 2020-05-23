txtList(path){ ; Pass a path to concatenate a string for splashRadio.ahk 
	global
	options = ; Clear previous %options% variable 
	Loop, read, %path% ; Read file line by line 
		options = %options%%A_LoopReadLine%| ; Append each line to options variable, adding |-separator
	StringTrimRight, options, options, 1 ; Remove last |-separator
	; StringReplace, options, options, &
	; This function returns the %options% string variable and can be used as follows:
	; EXAMPLE: splashUI("r", "Choose comment heading", options) 	
}
