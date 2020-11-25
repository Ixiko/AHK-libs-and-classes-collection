#NoEnv
#SingleInstance, Force


;-------------------------------------------------------------------------------
; test 1
;-------------------------------------------------------------------------------
Answer := BtnBox("JRR Tolkien", "Click a button!", "Bilbo|Frodo|Gandalf")
MsgBox,, Test: BtnBox(), %Answer%, 2


;-------------------------------------------------------------------------------
; test 2 with timeout
;-------------------------------------------------------------------------------
Answer := BtnBox("JK Rowling", "Click a button!", "Harry|Ron|Hermione", 5)
MsgBox,, Test: BtnBox(), %Answer%, 2


;-------------------------------------------------------------------------------
; test 3
;-------------------------------------------------------------------------------
Loop {
    Answer := BtnBox("Test 3", "Click a button!", "Cancel|Try Again|Continue")

    If (Answer = "WinClose")
        MsgBox,,, Instead of pressing a button`,`nyou closed the window., 2

    Else If (Answer = "EscapeKey")
        MsgBox,,, Instead of pressing a button`,`nyou pressed the {Esc} key., 2

    Else If (Answer = "Cancel")
        MsgBox,,, You pressed "Cancel"., 2

    Else If (Answer = "Try Again")
        MsgBox,,, You pressed "Try Again"., 2

    Else If (Answer = "Continue") {
        MsgBox,,, You pressed "Continue"., 2
        Break
    }
}


;-------------------------------------------------------------------------------
; test 4 with timeout
;-------------------------------------------------------------------------------
Loop {
    Answer := BtnBox("Test 4", "Hurry up and`nclick a button!", "Yes|No", 2)

    If (Answer = "WinClose")
        MsgBox,,, Instead of pressing a button`,`nyou closed the Window., 2

    Else If (Answer = "EscapeKey")
        MsgBox,,, Instead of pressing a button`,`nyou pressed the {Esc} key., 2

    Else If (Answer = "TimeOut")
        MsgBox,,, Instead of pressing a button`,`nyou did nothing., 2

    Else If (Answer = "Yes") {
        MsgBox,,, You pressed "Yes"., 2
        Break
    }

    Else If (Answer = "No")
        MsgBox,,, You pressed "No"., 2
}


ExitApp

#Include, ..\BtnBox.ahk
