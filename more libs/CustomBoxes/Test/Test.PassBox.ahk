#NoEnv
#SingleInstance, Force


;-------------------------------------------------------------------------------
Loop { ; enter correct password before continuing
;-------------------------------------------------------------------------------
    Title  := "Attempt #" A_Index
    Prompt := "To be able to continue,`n"
           .  "you must enter the password:"

    If PassBox(Title, Prompt) == "1234" {
        MsgBox,,, Correct, 1
        Break
    }

    If (A_Index = 3) ; three failed attempts
        ExitApp
}


;-------------------------------------------------------------------------------
; password protected code
;-------------------------------------------------------------------------------
    Gui, 1: New, +AlwaysOnTop -Caption
    Gui, Margin, 0, 0
    Gui, Add, Picture,, Lara.jpg
    Gui, Show

Return

GuiClose:
GuiEscape:
ExitApp

#Include, ..\PassBox.ahk
