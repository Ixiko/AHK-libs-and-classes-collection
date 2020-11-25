#NoEnv
#SingleInstance, Force

Credentials := LoginBox("Title")


;-------------------------------------------------------------------------------
If IsObject(Credentials) ; show credentials
;-------------------------------------------------------------------------------
    MsgBox,, Test: LoginBox(), % ""
        . "Username:`t"   Credentials.Username "`n"
        . "Password:`t`t" Credentials.Password "`n"


;-------------------------------------------------------------------------------
Else ; no object returned -> show string
;-------------------------------------------------------------------------------
    MsgBox,, Test: LoginBox(), %Credentials%


ExitApp

#Include, ..\LoginBox.ahk
