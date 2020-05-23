#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, on

#Include %A_ScriptDir%\..\HTML2RTF.ahk
#Include %A_ScriptDir%\..\..\lib-i_to_z\WinClipAPI.ahk
#Include %A_ScriptDir%\..\..\lib-i_to_z\WinClip.ahk
wc := new WinClip
wc.Clear()
;************************
;CONVERT RTF TO HTML
;************************
TestRTF=
(LTrim Join
{\rtf1\ansi\deff0
{\colortbl;\red0\green0\blue0;\red255\green0\blue0;}
This line is the default color\line
\cf2
This line is red\line
\cf1
This line is the default color
}
)
msgbox TestRTF %TestRTF%
; wc.SetRTF(TestRTF)
HTMLResult:=sRTF_To_HTML(TestRTF)
FoundPos1 := InStr(HTMLResult, "StartFragment-->")
FoundPos2 := InStr(HTMLResult, "<!--EndFragment")
rawHTMLFragment := SubStr(HTMLResult, FoundPos1 + 16, StrLen(HTMLResult) - FoundPos1 - (StrLen(HTMLResult) - FoundPos2) - 16)
wc.SetText( rawHTMLFragment )
msgbox The converted HTML string is now in the clipboard as raw text
wc.SetText("")
wc.SetHTML(rawHTMLFragment)
msgbox The conversion is now in clipboard ready to be pasted in an HTML-aware Editor
;************************
;CONVERT HTML TO RTF
;************************
TestHTML=
(LTrim Join
<div id="corner"><i>Welcome!</i></div>
		<p><b>The standard Lorem Ipsum passage, used since the 1500s</b></p>
		<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
		<p id="footer">
)

msgbox TestHTML %TestHTML%
wc.SetHTML(TestHTML)
RTFResult:=sHTML_To_RTF(TestHTML)
wc.SetText( RTFResult )
msgbox The converted rtf string is now in the clipboard as raw text
wc.SetText("")
wc.SetRTF(RTFResult)
msgbox The conversion is now in clipboard ready to be pasted in an RTF-aware Editor
return