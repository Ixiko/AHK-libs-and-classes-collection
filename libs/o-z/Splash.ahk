Splash(imagePath, imageX := 0, imageY := 0, imageWidth := 32, imageHeight := 22, time := 800)
{ ; функция вывода всплывающей подсказки с последующим (убирается по таймеру)
	Gui, Margin, 0,0
	Gui, +HwndSplashHWND
	Gui, -Caption +AlwaysOnTop +Border
	Gui, Add, Picture, x%imageX% y%imageY% w%imageWidth% h%imageHeight%, %imagePath%
	; Gui, Show, AutoSize Hide
	; DllCall("AnimateWindow", "UInt", SplashHWND, "Int", time/2, "UInt", "0xa0000")
	; DllCall("AnimateWindow", "UInt", SplashHWND, "Int", time/2, "UInt", "0x90000")
	Gui, Show, AutoSize
	DllCall("AnimateWindow", "UInt", SplashHWND, "Int", time, "UInt", "0x90000")
	Gui, Destroy	
	return
}
