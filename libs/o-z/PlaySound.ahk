; LintaList Include
; Purpose: Play sounds
; Version: 1.7
; Date:    20151003

PlaySound(PlaySound,Action)
	{
	 Global
	 If (PlaySound = 0) ; don't play sounds
		Return
	 else If (PlaySound = 1) ; beeps
		{
		 If (Action = "paste")
			PlayBeep(playsound_1_paste)
		else If (Action = "open") ; Open GUI
			PlayBeep(playsound_1_open)
		else If (Action = "close") ; Close Gui
			PlayBeep(playsound_1_close)
		}

	 else If (PlaySound = 2) ; default sound files
		{
		 If (Action = "paste") ; paste
			{
			 If playsound_2_paste
				SoundPlay, %A_WinDir%\Media\%playsound_2_paste%
			}
		else If (Action = "open") ; Open GUI
			{
			 If playsound_2_open
				SoundPlay, %A_WinDir%\Media\%playsound_2_open%
			}
		else If (Action = "close") ; Close Gui
			{
			 If playsound_2_close
				SoundPlay, %A_WinDir%\Media\%playsound_2_close%
			}
		}

	 else If (PlaySound = 3) ; local sound files
		{
		 If (Action = "paste") ; paste
			{
			 If playsound_3_paste
				SoundPlay, Extras\sounds\%playsound_3_paste%
			}
		else If (Action = "open") ; Open GUI
			{
			 If playsound_3_open
				SoundPlay, Extras\sounds\%playsound_3_open%
			}
		else If (Action = "close") ; Close Gui
			{
			 If playsound_3_close
				SoundPlay, Extras\sounds\%playsound_3_close%
			}
		}
		
	}

PlayBeep(in)
	{
	 if (in = "")
		return

	 loop, parse, in, CSV
		{
		 StringSplit, p, A_LoopField, |
		 SoundBeep, %p1%, %p2%
		}
	}