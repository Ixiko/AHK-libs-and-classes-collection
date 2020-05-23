detectHiddenWindows 1
winex.setTrayHeight()
class winex
	{
	setTrayHeight(){
		winGetPos ,,,trayHeight, 'ahk_class Shell_TrayWnd ahk_exe Explorer.EXE'
		winex.trayHeight := trayHeight
		}
	relMove(winTitle := '', xPercent := 1, yPercent := 1, winText := '', excludeTitle := '', exludeText := ''){
		detectHiddenWindows 1
		winGetPos ,,width, height, winTitle, winText, excludeTitle, excludeText
		xRoom := a_screenWidth - width
		yRoom := a_screenHeight - height - winex.trayHeight
		winMove round(xPercent * xRoom), round(yPercent * yRoom),,, winTitle, winText, excludeTitle, excludeText
		}
	}