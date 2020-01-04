#Include %A_ScriptDir%\..\class_CircleProgressClass.ahk
#Include %A_ScriptDir%\..\..\lib-a_to_h\GDIP.ahk

;Example 1 - simple:

CircleProgress := new CircleProgressClass()
Loop, 100 {
	CircleProgress.Update(A_Index, "Downloading`nAutoHotkey.exe`n`n" A_Index "% done")
	Sleep, 50
}


;Example 2 - intermediate:


pToken := Gdip_Startup()	; when using multiple CircleProgressClass objects or any other GDI+ stuff, you should manually turn GDI+ on/off and release CircleProgressClass objects
CircleProgressCCleaner := new CircleProgressClass({y: 300, BackgroundColor: "ffeeeeee", BarColor: "ffaaaaaa", BarThickness: 6})
CircleProgressFirefox := new CircleProgressClass({y: 500, BackgroundColor: "ff000000", BarColor: "bbFFB200", TextColor: "ffffc018", TextStyle: "Bold", BarThickness: 40, BarDiameter: 100})
Loop, 200 {
	if (A_Index < 101)
		CircleProgressCCleaner.Update(A_Index, "Downloading`nCCleaner`n`n" A_Index "% done")
	CircleProgressFirefox.Update(A_Index/2, "Downloading`nFirefox`n`n" Round(A_Index/2) "% done")
	Sleep, 50
}
Sleep, 500
CircleProgressCCleaner := "", CircleProgressFirefox := "", Gdip_Shutdown(pToken)	; release objects, shut down GDI+
ExitApp