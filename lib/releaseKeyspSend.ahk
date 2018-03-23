; this releases all keys vis pSend
; it can be used with the block hook, as it allows the users real key ups to pass 
; through. hence, can't get a stuck key outside of windows

releaseKeyspSend()
{
	static aKeys := []
	; returns and array of unmodified keys
	if !aKeys.maxindex()
		aKeys := getAllKeyboardAndMouseKeys()
	for index, key in aKeys
	{
		; Have to use P - as AHK blocking of its own hotkey modifers doesnt always work 
		; and these modify the in game commands.
		if (getkeystate(key, "P") || getkeystate(key))
		{
			if isKeyMouseButton(key)
				upSequence .= "{ click " key " up}"
			else upSequence .= "{ " key " up}"
		}	
	}	
	input.pSend(upSequence)
	return 
}