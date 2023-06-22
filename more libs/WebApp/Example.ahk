#SingleInstance off
#NoTrayIcon
SendMode Input

#Include Lib\Webapp.ahk
__Webapp_AppStart:
;<< Header End >>


;Get our HTML DOM object
iWebCtrl := getDOM()

;Change App name on run-time
setAppName("My Webapp.ahk Application")

; cut auto run main thread.
Return

; Webapp.ahk-only Sensitive hotkeys
#IfWinActive, ahk_group __Webapp_windows
!Enter::
	;!toggle
	setFullscreen(!__Webapp_FullScreen)
Return
#IfWinActive

; Our custom protocol's url event handler
app_call(args) {
	MsgBox %args%
	if InStr(args,"msgbox/hello")
		MsgBox Hello world!
	else if InStr(args,"soundplay/ding")
		SoundPlay, %A_WinDir%\Media\ding.wav
}


; function to run when page is loaded
app_page(NewURL) {
	wb := getDOM()
	
	setZoomLevel(100)
	
	if InStr(NewURL,"index.html") {
		disp_info()
	}
}

disp_info() {
	wb := getDOM()
	Sleep, 10
	x := wb.document.getElementById("ahk_info")
	x.innerHTML := "<i>Webapp.ahk is currently running on " . GetAHK_EnvInfo() . ".</i>"
}

; Functions to be called from the html/js source
Hello() {
	MsgBox Hello from JS_AHK :)
}
RunMyJSFunction() {
	window := getWindow()
	window.myFunction()
}
Run(t) {
	Run, %t%
}
GetAHK_EnvInfo(){
	return "AutoHotkey v" . A_AhkVersion . " " . (A_IsUnicode?"Unicode":"ANSI") . " " . (A_PtrSize*8) . "-bit"
}
Multiply(a,b) {
	;MsgBox % a " * " b " = " a*b
	return a * b
}
MyButton1() {
	wb := getDOM()
	MsgBox % wb.Document.getElementById("MyTextBox").Value
}
MyButton2() {
	wb := getDOM()
	FormatTime, TimeString, %A_Now%, dddd MMMM d, yyyy HH:mm:ss
    Random, x, %min%, %max%
	data := "AHK Version " A_AhkVersion " - " (A_IsUnicode ? "Unicode" : "Ansi") " " (A_PtrSize == 4 ? "32" : "64") "bit`nCurrent time: " TimeString "`nRandom number: " x
	wb.Document.getElementById("MyTextBox").value := data
}