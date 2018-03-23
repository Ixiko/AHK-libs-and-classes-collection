VKSend(Sequence)
{
	SetFormat, IntegerFast, hex
	C_Index := 1
	;	StringReplace, Sequence, Sequence, %A_Space% ,, All ;stuffs up {shift down}
	StringReplace, Sequence, Sequence, `t , %A_Space%, All 
	l := strlen(Sequence) 
	while (C_Index <= l)
	{
		char := SubStr(Sequence, C_Index, 1)
		if (char = "+")
		{
			string .= "{VK" GetKeyVK("Shift") " down}"
			ReleaseModifiers .= "{VK" GetKeyVK("Shift") " up}"
		}
		else if (char = "^")
		{
			string .= "{VK" GetKeyVK("Ctrl") " down}"
			ReleaseModifiers .= "{VK" GetKeyVK("Ctrl") " up}"
		}
		else if (char = "!")
		{
			string .= "{VK" GetKeyVK("Alt") " down}"
			ReleaseModifiers .= "{VK" GetKeyVK("Alt") " up}"

		}
		else if (char = "{") 							; send {}} will fail with this test but cant use that
		{ 												; hotkey anyway in program would be ]
			if (Position := instr(Sequence, "}", False, C_Index, 1)) ; lets find the closing bracket) n
			{
				key := trim(substr(Sequence, C_Index+1, Position -  C_Index - 1))
				C_Index := Position ;PositionOfClosingBracket
				

				while (if instr(key, A_space A_space))
					StringReplace, key, key, %A_space%%A_space%, %A_space%, All
				StringSplit, outputKey, key, %A_Space%
				if (outputKey0 = 2)
				{

					if instr(outputKey2, "Down")
						string .= "{VK" GetKeyVK(outputKey1) " Down}" ReleaseModifiers
					else if instr(outputKey2, "Up")
						string .= "{VK" GetKeyVK(outputKey1) " Up}" ReleaseModifiers

				}
				else 
					string .= "{VK" GetKeyVK(key) "}" ReleaseModifiers
				ReleaseModifiers .= ""
			}
		}
		Else
		{
			string .= "{VK" GetKeyVK(char) "}" ReleaseModifiers
			ReleaseModifiers := ""
		}

	C_Index++
	}
	SetFormat, IntegerFast, d
	return	string 
}