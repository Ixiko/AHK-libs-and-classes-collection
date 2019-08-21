caseChange(text,type){ ; type: U=UPPER, L=Lower, T=Title, S=Sentence, I=Invert
    static X:= ["I","AHK","AutoHotkey","Dr","Mr","Ms","Mrs","AKJ"] ;list of words that should not be modified for S,T
    if (type="S") { ;Sentence case.
        text := RegExReplace(RegExReplace(text, "(.*)", "$L{1}"), "(?<=[^a-zA-Z0-9_-]\s|\n).|^.", "$U{0}")
    } else if (type="I") ;iNVERSE
        text:=RegExReplace(text, "([A-Z])|([a-z])", "$L1$U2")
    else text:=RegExReplace(text, "(.*)", "$" type "{1}")

    if (type="S" OR type="T")
        for _, word in X ;Parse the exceptions
            text:= RegExReplace(text,"i)\b" word "\b", word)
    return text
}