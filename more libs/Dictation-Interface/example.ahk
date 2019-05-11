#NoEnv
#SingleInstance ignore
SetWorkingDir % A_ScriptDir
SendMode, Input
CoordMode, ToolTip, Screen
#Warn
; Windows 8.1 64 bit - Autohotkey v1.1.28.00 32-bit Unicode
; Chrome v66.0.3359.139 (64 bits)


#Include %A_ScriptDir%\Dictation.ahk

; Dictation.hideChromeInstance := true ; uncomment to hide the chrome instance

global Sr, Doc
if not (Dictation.ID) {
	MsgBox, 64,, Please copy the 'ID' of the extension and paste it into the appropriate location on the top of 'Dictation.ahk'.
ExitApp
}
if not (Sr:=new Dictation()) {
	MsgBox, 64,, Could not initialize Dictation.`r`nThe program will exit.
ExitApp
} else Sr.onInterimResult("updateInterimResults"), Sr.onResult("saveToClipboard"), Sr.setRecognitionLanguage("Français")

Gui, 1:Margin, 10, 20
Gui, 1:Add, DropDownList, vdropDownListControl Section xm ym w150 R10 Sort gsetRecognitionLanguage, % Sr.languages
GuiControl, 1:ChooseString, dropDownListControl, % Sr.recognitionLanguage
Gui, 1:Add, Button, vbuttonControl ys w160 h20 grecognitionToogleState, Start/stop &recognition
Gui, 1:Add, ActiveX, vDoc xm w710 h100, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge">
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
Gui, 1:Show, AutoSize, % A_ScriptName
OnExit, handleExit
return


setRecognitionLanguage:
GuiControl, 1:Enable0, % A_GuiControl
GuiControl, 1:Enable0, buttonControl
GuiControlGet, var,, % A_GuiControl
Sr.setRecognitionLanguage(var)
GuiControl, 1:Enable1, buttonControl
GuiControl, 1:Enable1, % A_GuiControl
return

recognitionToogleState:
GuiControl, 1:Enable0, % A_GuiControl
var := Sr.recognizing
Sr.recognitionToogleState()
if (ErrorLevel) {
	MsgBox, 64,, Could not interact with Dictation.`r`nThe program will exit.
ExitApp
}
GuiControl, 1:Enable%var%, dropDownListControl
GuiControl, 1:Enable1, % A_GuiControl
return

GuiClose:
handleExit:
Sr := ""
ExitApp


updateInterimResults(_dictation, _lastInterimResult) {

_t := _dictation.waitForInterimResultTimeRemaining
GuiControl, 1:, progressControl, % (_t * 100) // _dictation.interimResultTimeout

	if (_t) {

		VarSetCapacity(_str, 110 * (_interimResultsOutputArray:=StrSplit(_lastInterimResult, A_Space)).length())

			for _index, _result in _interimResultsOutputArray
				_str .= "<span class=""s1"">" . _result . "</span><span class=""s2""> " . _index . " </span>"

				Doc.document.getElementsByClassName("C")[0].innerHTML := _str

	} else {
		_dictation.recognitionToogleState()
		GuiControl, 1:Enable, dropDownListControl
	}

}
saveToClipboard(_dictation, _result) {
	clipboard := _result
	TrayTip, % A_ScriptName, Result has been copied to clipboard.
}
