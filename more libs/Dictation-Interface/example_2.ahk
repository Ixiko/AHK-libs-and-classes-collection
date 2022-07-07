#NoEnv
#SingleInstance ignore
SetWorkingDir % A_ScriptDir
SendMode, Input
CoordMode, ToolTip, Screen
#Warn
; Windows 8.1 64 bit - Autohotkey 1.1.30.03-4+gdd14232 32-bit Unicode
; Chrome Version 75.0.3770.142 (Build officiel) (64 bits)



; ======== SETTINGS /========
recognitionLanguage := "Français" ; the default recognition language (see available language names at the top of Dictation.ahk)
toggleRecognition := "!t" ; hotkey to start/stop the speech recognition
; ALT+X exit the script
; ========/ SETTINGS ========

#Include %A_ScriptDir%\Dictation.ahk

Dictation.hideChromeInstance := true ; comment to show the chrome instance

if not (Dictation.ID) { ; make sure an ID is provided
	MsgBox, 64,, Please copy the 'ID' of the extension and paste it into the appropriate location on the top of 'Dictation.ahk'.
ExitApp
}
if not (Sr:=new Dictation()) { ; create the speech recognition instance
	MsgBox, 64,, Could not initialize Dictation.`r`nThe program will exit.
ExitApp
} else {
	Sr.onInterimResult("updateInterimResults") ; set the function to be executed each time a new interim result is available
	Sr.onResult("sendToCursor") ; set the function to be executed as soon as the final recognition result is available during the recognition process
	Sr.setRecognitionLanguage(recognitionLanguage)
}

; ================ create a submenu in the tray menu, filling it with available recognition languages
Menu, Tray, Add
for index, language in StrSplit(Dictation.languages, "|") {
	Menu, SRLsubmenu, Add, % language, setRecognitionLanguage
}
Menu, Tray, Add, Set recognition language, :SRLsubmenu
Sr.setRecognitionLanguage(Sr.recognitionLanguage)
Menu, SRLsubmenu, Check, % Sr.recognitionLanguage

; ================ create a GUI with an embedded html document to preview interim results
Gui, 1:+LastFound -Border +AlwaysOnTop
WinSet, ExStyle, 0x08000008 ; WS_EX_NOACTIVATE := 0x08000000, WS_EX_TOPMOST := 8 (https://autohotkey.com/board/topic/10059-ws-ex-noactivate-equiv-in-ahk/)
Gui, 1:Margin, 0, 0
Gui, 1:Add, ActiveX, vDoc xm w710 h100, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge"> ; create the html document
Doc.document.Open()
html =
(
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge"><meta charset="utf-8" />
	<title>HTMLFile</title>
	<style>
	.s2 {
		vertical-align: sub;
		font-size: 9px;
		color: #666666;
	}
	</style>
</head>
<body><div class="C" style="padding: 15px;"></div></body>
</html>
)
Doc.document.Write(html), Doc.document.Close()
sleep, 100
Gui, 1:Add, Progress, vprogressControl xm wp h10 range0-100, 100
Gui, 1:Show, Hide AutoSize y0, % A_ScriptName
DetectHiddenWindows, On
WinSet, Transparent, 175
DetectHiddenWindows, Off
Hotkey % toggleRecognition, recognitionToogleState, On
return

setRecognitionLanguage:
	if (Sr.recognizing)
		return
	Menu, Tray, Disable, Set recognition language
	Menu, SRLsubmenu, UnCheck, % Sr.recognitionLanguage
	Sr.setRecognitionLanguage(A_ThisMenuItem)
	Menu, SRLsubmenu, Check, % A_ThisMenuItem
	Menu, Tray, Enable, Set recognition language
return

recognitionToogleState:
	Gui, 1:Show, NA AutoSize, % A_ScriptName
	Sr.recognitionToogleState()
	if (ErrorLevel) {
		MsgBox, 64,, Could not interact with Dictation.`r`nThe program will exit.
	ExitApp
	}
return

!x::
	Sr := "" ; delete the instance the moment the scipt exits (so that, in particular, the chrome instance on which the script relies can be properly closed)
ExitApp

updateInterimResults(_dictation, _lastInterimResult) { ; this function is executed each time a new interim result is available during the recognition process
	global Doc ; retrieves the reference to the html document defined outside the scope of the function (in the global environment)
	_t := _dictation.waitForInterimResultTimeRemaining
	GuiControl, 1:, progressControl, % (_t * 100) // _dictation.interimResultTimeout ; display the time remaining before the recognition process automatically stops for want of results
	if (_t) {
		VarSetCapacity(_str, 110 * (_interimResultsOutputArray:=StrSplit(_lastInterimResult, A_Space)).length())
			for _index, _result in _interimResultsOutputArray
				_str .= "<span class=""s1"">" . _result . "</span><span class=""s2""> " . _index . " </span>"
				Doc.document.getElementsByClassName("C")[ 0 ].innerHTML := _str
	} else { ; if, for some time, there's no more words that could be recognized....
		_dictation.recognitionToogleState() ; stops the recognition
	}
}
sendToCursor(_dictation, _result) { ; this function is executed as soon as the final speech recognition result is available
	Gui, 1:Show, Hide
	sendInput % _result ; send the final recognition result to the input-capable control where the caret lies, if applicable
}
