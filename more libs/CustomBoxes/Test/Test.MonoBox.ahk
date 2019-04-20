#NoEnv
#SingleInstance, Force


;-------------------------------------------------------------------------------
; test 1 (title omitted)
;-------------------------------------------------------------------------------
    MonoBox("", "The title defaults to:`n" A_ScriptName)


;-------------------------------------------------------------------------------
; test 2 (with title)
;-------------------------------------------------------------------------------
    MonoBox("Test 2", "This text is displayed`nwith a monospaced font.")


;-------------------------------------------------------------------------------
; test 3
;-------------------------------------------------------------------------------
    FileRead, Code, %A_ScriptFullPath%
    MonoBox(, Code)


;-------------------------------------------------------------------------------
; tests with optional title and fontname and fontsize
;-------------------------------------------------------------------------------
    MonoBox("Test 4", "Hello world!", "Fixedsys Excelsior 3.01", 12)
    MonoBox("Test 5", "Hello world!", "Courier New", 11)
    MonoBox("Test 6", "Hello world!", "Consolas", 10)


ExitApp

#Include, ..\MonoBox.ahk
