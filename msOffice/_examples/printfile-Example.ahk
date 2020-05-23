#NoEnv
SendMode Input
#SingleInstance force

#if WinActive("ahk_class CabinetWClass") ; If Windows Explorer is active
; press one of these hotkeys while a file is selected
; I use word COM in printfile(), so the code checks if the extension contains "doc"
^#!1:: ; Ctrl + Win + Alt + 1 (will print 1 copy)
^#!2::
^#!3::
^#!4::
^#!5::
^#!6::
^#!7::
^#!8::
^#!9::

previousClip := ClipboardAll
Clipboard := "" ; Empty the Clipboard
Send ^c ; Copy the selected file
Clipwait, 2 ; wait for the clipboard to have something
if errorlevel 
{
	MsgBox, 48, Printing Labels, It seems nothing was selected. Try again.
	; if nothing was selected
	return
}
path := Clipboard ; gets the path of the copied file.
Clipboard := previousClip
previousClip := ""
SplitPath, path,,,OutExt
if !(InStr(OutExt, "doc"))
{
	MsgBox, 48, Printing Labels, The file you selected is not a Word file. Try again.
	return
}

printfile(path, SubStr(A_ThisHotkey, 0, 1))
return

#Include printfile.ahk
