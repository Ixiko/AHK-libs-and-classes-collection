; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RegEx%20Functions/RegExGrep.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RegExGrep(inArray, regex, negate := false, matchKeys := false) {
    outArray := []
    for key, val in inArray {
        if ((matchKeys ? key : val) ~= regex) {
            if !(negate) {
                outArray[key] := val
            }
        } else {
            if (negate) {
                outArray[key] := val
            }
        }
    }
    return outArray
}