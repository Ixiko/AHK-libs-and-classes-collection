; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RegEx%20Functions/RegExEscape.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RegExEscape(string, delimiter := "") {
    
    for _, char in StrSplit(delimiter "\$()*+-.:<=>?[]^{|}")
        string := StrReplace(string, char, "\" char)
    
    return string
}