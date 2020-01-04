#if mkex.inKW
#if
class mkex{
	clickImage(imageAndOptions, tryFor := 0, xOffset := 0, yOffest := 0, coMode := 'client', notFoundMsg := true){
		oldCM := a_coordModePixel
		coordMode 'pixel', coMode
		if coMode = 'client'
			winGetClientPos ,, width, height, 'a'
		else if coMode = 'window'
			winGetPos ,, width, height, 'a'
		else if coMode = 'screen'{
			width := a_screenWidth
			height := a_screenHeight
		}else{
			msgBox 'invalid coordinate mode'
			return false
			}
		clockStart := a_tickCount
		retry:
		if imageSearch(x, y, 0, 0, width, height, imageAndOptions){
			;send format('{{}click {} {} {}}', x + xOffset, y + yOffest)
			if coMode = 'client'
				controlClick format('x{} y{}', x + xOffset, y + yOffest)
			else{
				mouseGetPos mx, my
				click x + xOffset, y + yOffest
				mouseMove mx, my, 0
				}
			coordMode 'pixel', oldCM
			return [x, y]
		}else{
			if a_tickCount - clockStart > tryFor * 1000{
				if notFoundMsg{
					response := msgBox('The Image was not found.', imageAndOptions, 'ctc default3 iconx')
					if response = 'tryagain'{
						clockStart := a_tickCount
						goto retry
					}else if response = 'continue'{
						coordMode 'pixel', oldCM
						return false
					}else
						exitApp
					}
			}else
				goto retry
			}
		}
	/* static inKW
	
	keyWait()
		{
		mkex.inKW := true
		kwc := mkex.kwHelp.cancel.bind(kwHelp)
		hotkey, if, mkex.inKW
		hotkey, ~lButton, % kwc
		hotkey, if
		Input, keyName, l1, {Escape}{Backspace}{LControl}{LShift}{NumpadMult}{LAlt}{CapsLock}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{Pause}{ScrollLock}{NumpadHome}{NumpadUp}{NumpadPgUp}{NumpadSub}{NumpadLeft}{NumpadClear}{NumpadRight}{NumpadAdd}{NumpadEnd}{NumpadDown}{NumpadPgDn}{NumpadIns}{NumpadDel}{PrintScreen}{F11}{F12}{Help}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}{Media_Prev}{Media_Next}{NumpadEnter}{RControl}{Volume_Mute}{Launch_App2}{Media_Play_Pause}{Media_Stop}{Volume_Down}{Volume_Up}{Browser_Home}{NumpadDiv}{RShift}{RAlt}{Numlock}{CtrlBreak}{Home}{Up}{PgUp}{Left}{Right}{End}{Down}{PgDn}{Insert}{Delete}{LWin}{RWin}{AppsKey}{Sleep}{Browser_Search}{Browser_Favorites}{Browser_Refresh}{Browser_Stop}{Browser_Forward}{Browser_Back}{Launch_App1}{Launch_Mail}{Launch_Media}{Numpad0}{Numpad1}{Numpad2}{Numpad3}{Numpad4}{Numpad5}{Numpad6}{Numpad7}{Numpad8}{Numpad9}{NumpadDot}
		if((el := errorLevel) ~= "EndKey:")
			regExMatch(el, "[^:]+$", keyName)
		mkex.inKW := false
		return getKeyName(keyName)
		}
	class kwHelp
		{
		cancel()
			{
			input
			mkex.inKW := false ;for threads that cause keyWait() to buffer
			}
		}*/
	paste(text := ''){
		if(text)
			clipboard := text
		sendInput '^v'
		}
	}