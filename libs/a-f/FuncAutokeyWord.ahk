;/¯¯¯¯ getAutoKeywords ¯¯ 181106121229 ¯¯ 06.11.2018 12:12:29 ¯¯\
; getAutoKeywords_used_till_181209(ByRef oldKeywords
getAutoKeywords(ByRef oldKeywords
        , addKeysMAX := 9 , minLength := 4, doFirstWord := true
		, regEx := "\b((\w+?(?=[A-Z]|\b))([A-Z][a-z]*)?)([A-Z][a-z]*)?"
        , elseIfResulsEmpty := "without keywords" ){
		   ; this function works also multiline. you must not use g)

    ; AddWord rootDoObj.createKeys https://g-intellisense.myjetbrains.com/youtrack/issues?q=project:%20g-IntelliSense#issueId=GIS-65
	; https://github.com/sl5net/global-IntelliSense-everywhere/blob/master/Source/Includes/actionList.ahk#L1438
    ; https://stackoverflow.com/questions/53345266/generate-search-words-from-text-with-camelcase-by-using-regex


; for some reason we need a leading white space at the beginning !! 18-12-09_21-11

newKeyWords := " " ltrim( oldKeywords," `t`r`n") ; usefull for comparsison later with first wird is already insiede.
	; MsgBox,% ">" resultStr "<  `n`n(" A_ThisFunc ":" A_LineNumber " " RegExReplace(A_LineFile, ".*\\") ")"
resultStr  := ""

Array := [] ; or Array := Array()
if(doFirstWord){
	firstWord := RegExMatch(newKeyWords,"^\s*(\w+)",m) ? m1 : ""
	if(firstWord){
		resultStr := firstWord " "
		Array.Push(firstWord)
        if( RegexMatch(firstWord,"([A-Z][a-z0-9]+)$",Match) ){
            lastWordInWord := Match1
            if(strlen(lastWordInWord) >= minLength && !HasVal(Array,lastWordInWord) ){
                Array.Push(lastWordInWord) ; Append this line to the array.
                ArrayCount++
                resultStr .= lastWordInWord " "
                ; msgbox,% lastWordInWord " (123456789)"
            }
        }
	}
}

StartingPosition  := 2
addedKeysCounter := 0
while(foundPos := RegexMatch( newKeyWords, "(" regEx ")", Match, StartingPosition )){
		; StartingPosition := Match.Pos(1) + Match.Len(1)
	StartingPosition += strlen(Match1)
	
	loop,3
	{
		word := Match%A_Index%
			; MsgBox,% ">" word "<  (" A_ThisFunc ":" A_LineNumber " " RegExReplace(A_LineFile, ".*\\") ")"
		if(!HasVal(Array,word)){
			if(!firstWord){
				firstWord := word
				resultStr .= firstWord " "
			}
			if(strlen(word) >= minLength ){
				Array.Push(word) ; Append this line to the array.
				ArrayCount++
				resultStr .= word " "
			}
		}
        if( RegexMatch(word,"([A-Z][a-z0-9]+)$",Match) ){
		    lastWordInWord := Match1
            ; msgbox,% lastWordInWord " (123456789+++)"
			if(strlen(lastWordInWord) >= minLength && !HasVal(Array,lastWordInWord) ){
				Array.Push(lastWordInWord) ; Append this line to the array.
				ArrayCount++
				resultStr .= lastWordInWord " "
				; msgbox,% ">" lastWordInWord "<"
			}
        }
	}
	if(ArrayCount >= addKeysMAX)
		break			
}
resultStr := Trim(resultStr)
if(!resultStr)
	resultStr := elseIfResulsEmpty ; "without keywords"
	    ; MsgBox,% ">" resultStr "<  `n`n(" A_ThisFunc ":" A_LineNumber " " RegExReplace(A_LineFile, ".*\\") ")"
return resultStr
}
;\____ getAutoKeywords __ 181106121233 __ 06.11.2018 12:12:33 __/