#Include ..\AHKLink.ahk
SetWorkingDir .. ; For the index file
; This demonstrates all options in AHKLink()
; Simple search:
MsgBox % clipboard := AHKLink("IfWinActive") ; http://www.autohotkey.net/~Lexikos/AutoHotkey_L/docs/commands/IfWinActive.htm

; From the autohotkey.com website: (AHK Basic docs)
MsgBox % clipboard := AHKLink("IfWinActive", Forcebasic := 1) ; http://www.autohotkey.com/docs/commands/IfWinActive.htm

; From the forum and documentation Search: (note that the forcebasic parameter will be ignored)
; Many consider the forum search inadequate, and this returns a link which contains the words IfWinActive and help, but might be unreliable.
MsgBox % clipboard := AHKLink("IfWinActive help", 0, ShortLink := 0, ForceSearch := 1) ; http://www.autohotkey.com/forum/topic21497.html

; Let's test the link shortening:
MsgBox % clipboard := AHKLink("IfWinActive", Forcebasic := 0, ShortLink := 1) ; http://d.ahk4.me/~IfWinActive
MsgBox % clipboard := AHKLink("IfWinActive", Forcebasic := 1, Shortlink := 1) ; http://ahk4.me/pazauC
MsgBox % clipboard := AHKLink("Hotkeys",     Forcebasic := 0, ShortLink := 1) ; http://d.ahk4.me/Hotkeys