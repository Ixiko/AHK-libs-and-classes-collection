; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RegEx%20Functions/RegExMatchAll.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*
    - Haystack
        - The string whose content is searched.
    
    - regex
        - A Perl-compatible regular expression (PCRE). 
    
    - OutputArray
        - The output variable in which to store the resulting array
    
    - Flags - Can be any combination of the following numbers:
    
        - 0x0 : OutputArray will be structured by subpattern and then by match
                - i.e. matches[subpattern][matchNumber]
                - If no subpatterns specified, values are at subpattern '0'
        - 0x1 : OutputArray will be ordered by match and then by subpattern
                - i.e. matches[matchNumber][subpattern]
                - If no subpatterns specified, values are at subpattern '0'
        
        - 0x2 : Instead of storing string value at 'matches[x][y]' the function
                will store an array in which the first key is the value and the
                second key is the offset of the value within Haystack.
                    - i.e. matches[x][y][1] and matches[x][y][2]
                
    - StartingPosition
        - The character position within Haystack from which to start the search
*/

/*   Example:

     count := RegExMatchAll("a1b2c3", "(\D)(?<digit>\d)", matches)

     for subpattern, match in matches {
         for #, string in match {
             out .= "matches[" # ", " subpattern "] =  " string "`n"
         }
         out .= "`n"
     }

     MsgBox, % out
     return

*/


RegExMatchAll(haystack, regex, ByRef outArray, flags := 0x0, startPos := 1) {
    outArray      := []
    groupByMatch  := (flags & 0x1)    
    offsetCapture := (flags & 0x2)

    offset += startPos
    
    options := RegExOptions(regex, "O")
    
    while (offset := RegExMatch(haystack, options ")" regex, matches, offset)) {
        matchNumber := A_Index

        root   := groupByMatch ? matchNumber : 0
        nested := groupByMatch ? 0 : matchNumber
        
        if (offsetCapture)
            matchVal := [matches[0], offset]
        else matchVal := matches[0]
        
        OutArray[root, nested] := matchVal
        
        While (matches[A_Index]) {
            subpattern := A_Index

            root   := groupByMatch ? matchNumber : subpattern
            nested := groupByMatch ? subpattern : matchNumber

            if (offsetCapture)
                groupVal := [matches[subpattern], offset]
            else groupVal := matches[subpattern]
            
            OutArray[root, nested] := groupVal
            
            groupName := matches.Name(subpattern)
            
            if (groupName) {
                root   := groupByMatch ? matchNumber : groupName
                nested := groupByMatch ? groupName : matchNumber
                outArray[root, nested] := groupVal
            }
        }
        
        offset += matches.Len(0)
    }

    return matchNumber
}

#Include %A_LineFile%\..\RegExOptions.ahk