#SingleInstance, force
#Persistent
try  ; Attempts to execute code.
{
    HelloWorld()
    MakeToast()
}
catch e  ; Handles the first error/exception raised by the block above.
{
    MsgBox, An exception was thrown!`nSpecifically: %e%
    ExitApp
}
ExitApp


HelloWorld()  ; Always succeeds.
{
    MsgBox, Hello, world!
}

MakeToast()  ; Always fails.
{
    ; Jump immediately to the try block's error handler:
    throw A_ThisFunc " is not implemented, sorry"
}