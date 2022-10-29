#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


oAcrobat := ComObjCreate("acroExch.App")
oAcrobatdoc := ComObjCreate("acroExch.avdoc")      ; create an document object
     ; maximize the application window (-1 = true)
oAcrobatdoc.Open("C:\Users\babb\Desktop\First StateSuper Refund of contributions form.pdf", "")

;MsgBox % oAcrobat.GetFileName()
sleep 1000
		
return

q::

oAcrobatdoc.maximize(-1) 

MsgBox % oAcrobatdoc.GetFileName 