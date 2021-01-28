/*
Function        : hkSwap(key,[type])
Author          : RaptorX
Version         : 1.0
Created         : July 03 , 2010
Updated         :

Description:
--------------
Converts short hotkeys (#w) to long hotkeys (Win + w) and vice-versa, the parameter must be a variable
that contains the hotkey to be swapped, and the type is the type that you want to convert it to.
The types can be the name of the type (long | short) enclosed in quotes or 0/1 respectively.

The function returns 0 on failure.

Examples:
--------------
hkey := "#W"
msgbox % key := hkSwap(hkey, "long")  ; Returns Win + W
msgbox % key := hkSwap(hkey)          ; Returns Win + W

hkey := "Win + W"
msgbox % key := hkSwap(hkey, "short") ; Returns #w
msgbox % key := hkSwap(hkey, 1)       ; Returns #w
*/

hkSwap(byref key, type = 0){

    if (type = "long" || type = 0)
    {
        long_hk := RegexReplace(key, "\+", "Shift + ")
        long_hk := RegexReplace(long_hk, "\^", "Ctrl + ")
        long_hk := RegexReplace(long_hk, "!", "Alt + ")
        long_hk := RegexReplace(long_hk, "#", "Win + ")
        return long_hk ; long hotkey, ex. Ctrl + Alt + Shift + Win + s
    }
    else if (type = "short" || type = 1)
    {
        ; This matches regardless of the spacing, ex. "Shift + " or "Shift+"
        short_hk := RegexReplace(key, "Shift\s?\+\s?", "+")
        short_hk := RegexReplace(short_hk, "Ctrl\s?\+\s?", "^")
        short_hk := RegexReplace(short_hk, "Alt\s?\+\s?", "!")
        short_hk := RegexReplace(short_hk, "Win\s?\+\s?", "#")
        return short_hk ; short hotkey, ex. ^!+#s
    }
    else if type =
    {
        ; invalid type
        return false
    }
} ; Function End
