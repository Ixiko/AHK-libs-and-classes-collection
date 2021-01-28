Transform_ReadableHotkeyString_Into_AHKHotkeyString(_hotkey, _delimiter="+") {

	len := StrLen(_hotkey)
    Loop 2 {
        mainLoopIndex := A_Index
        Loop, Parse,% _hotkey,% _delimiter
        {
            parseIndex := A_Index

            if (mainLoopIndex = 1)
                parseTotal := parseIndex
            else {
                firstChar := SubStr(A_LoopField, 1, 1)
                if IsIn(A_LoopField, "Ctrl,LCtrl,RCtrl") && (parseIndex < parseTotal)
                    mod .= firstChar = "L" ? "<^" : firstChar = "R" ? ">^" : "^"
                else if IsIn(A_LoopField, "Shift,LShift,RShift") && (parseIndex < parseTotal)
                    mod .= firstChar = "L" ? "<+" : firstChar = "R" ? ">+" : "+"
                else if IsIn(A_LoopField, "Alt,LAlt,RAlt") && (parseIndex < parseTotal)
                    mod .= firstChar = "L" ? "<!" : firstChar = "R" ? ">!" : "!"
                else if IsIn(A_LoopField, "LWin,RWin") && (parseIndex < parseTotal)
                    mod .= "#" ; firstChar = "L" ? "<#" : firstChar = "R" ? ">#" : "#"
                else
                    hk := A_LoopField
            }
        }
    }

    lastChar := SubStr(_hotkey, 0, 1)
    if (lastChar = _delimiter) && (hk = "")
        hk := lastChar

    fullHk := mod . hk
    return fullHk
}

Transform_AHKHotkeyString_Into_InputSring(_hotkey) {

	readable := Transform_AHKHotkeyString_Into_ReadableHotkeyString(_hotkey)
	len := StrLen(_hotkey), inputsObj := {}
    Loop 2 {
        mainLoopIndex := A_Index
        Loop, Parse,% readable,% "+"
        {
            parseIndex := A_Index

            if (mainLoopIndex = 1)
                parseTotal := parseIndex
            else {
                firstChar := SubStr(A_LoopField, 1, 1)
                if IsIn(A_LoopField, "Ctrl,LCtrl,RCtrl") && (parseIndex < parseTotal)
                    inputsObj.Push(A_LoopField)
                else if IsIn(A_LoopField, "Shift,LShift,RShift") && (parseIndex < parseTotal)
                    inputsObj.Push(A_LoopField)
                else if IsIn(A_LoopField, "Alt,LAlt,RAlt") && (parseIndex < parseTotal)
                    inputsObj.Push(A_LoopField)
                else if IsIn(A_LoopField, "LWin,RWin") && (parseIndex < parseTotal)
                    inputsObj.Push(A_LoopField)
                else
                    inputsObj.Push(A_LoopField)
            }
        }
    }

	for index, _input in inputsObj {
        downInputs .= "{" _input " Down}"
        upInputs := "{" _input " Up}" upInputs
    }

	downAndUpInputs := downInputs . upInputs
    return downAndUpInputs
}

Transform_AHKHotkeyString_Into_ReadableHotkeyString(_hotkey, _delimiter="+") {
	len := StrLen(_hotkey)

	Loop, Parse,% _hotkey
    {
        parseIndex := A_Index
        curChar := A_LoopField, nextChar := SubStr(_hotkey, parseIndex+1, 1), curAndNextChars := curChar . nextChar

        if (skipNextChar) {
            skipNextChar := False
        }
        else if IsIn(curAndNextChars, "<^,>^,<!,>!,<+,>+,<#,>#") {
            mod := curChar = "<" ? "L" : curChar = ">" ? "R" : ""
            mod .= nextChar = "^" ? "Ctrl" : nextChar = "!" ? "Alt" : nextChar = "+" ? "Shift" : nextChar = "#" ? "Win" : ""
            modStr .= modStr ? "+" mod : mod
            skipNextChar := True
        }
        else if IsIn(curChar, "^,!,+,#") && (parseIndex < len) {
            mod := curChar = "^" ? "Ctrl" : curChar = "!" ? "Alt" : curChar = "+" ? "Shift" : curChar = "#" ? "Win" : ""
            modStr .= modStr ? "+" mod : mod
        }
        else {
            hk := SubStr(_hotkey, parseIndex)
            StringUpper, hk, hk, T
            Break
        }
    }

    hkStr := modStr ? modStr "+" hk : hk
    return hkStr
}



