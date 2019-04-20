#NoEnv
#SingleInstance, Force

    Alphabet := "A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"

    MsgBox, % RadioBoxEx("Test 1", "Choose", Alphabet, 4)
    MsgBox, % RadioBoxEx("Test 2", "Choose", Alphabet, 5)
    MsgBox, % RadioBoxEx("Test 2", "Choose", Alphabet, 6)
    MsgBox, % RadioBoxEx("Test 2", "Choose", Alphabet, 7)

ExitApp

#Include, ..\RadioBoxEx.ahk
