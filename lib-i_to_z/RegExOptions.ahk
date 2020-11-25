; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RegEx%20Functions/RegExOptions.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RegExOptions(ByRef regex, add := "", remove := "") {
    
    flags := ["i", "m", "s", "x", "A", "C", "D", "J"
            , "O", "P", "S", "U", "X","`a","`n","`r"]

    for #, char in StrSplit(regex) {
        ; if we reach a ')' then the options section has ended
        if (char = ")")
            break
        
        ; spaces and tabs are allowed in the options and they need to
        ; be preserved for later
        else if (char = A_Space) || (char = A_Tab) {
            options .= char
            continue
        }
        
        for #, flag in flags {
            if (char == flag) {
                isFlag := true
                break
            } else isFlag := false
        }
        
        
        if (isFlag = true) {
            options .= char
        } else return add
    }
    
    ; remove 'n' characters from the front of the regex string
    ; where 'n' is the length of our options + 1 for the ')' symbol
    regex := SubStr(regex, StrLen(options ")") + 1)

    ; options are case sensitive
    O_StringCaseSense := A_StringCaseSense
    StringCaseSense, On

    ; It's easiest just to remove them all because we can re-add the specified flags later
    for _, alteration in [add, remove] {
        for _, option in StrSplit(alteration) {
            options := StrReplace(options, option)
        }
    }
    
    StringCaseSense, % O_StringCaseSense
    
    return add options
}