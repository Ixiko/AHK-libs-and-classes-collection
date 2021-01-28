Hotstring
===
This is a library that adds a dynamic hotstring feature for Autohotkey.

**Arguments:**

- `trigger` - A string/regex that triggers the hotstrings.
- `label` - A string to replace the trigger/label to goto/ name of function to call when the hotstring is triggered.
			If it's a label, the variable `$` will contain either the phrase that triggered the hotstring or a [MatchObject](http://ahkscript.org/docs/commands/RegExMatch.htm#MatchObject) (If `mode == 3`)
			If it's a function and the function takes atleast 1 parameter, the first parameter will be the trigger string, or the Match Object.

- `mode` - A number between 1 & 3. 1 creates a case insenstive hotstring, 2 creates a case sensitive hotstring, 3 creates a regex hotstring. **Defaults to `1`**.
- `clearTrigger` - Wheather or not to clear the trigger. Defaults to `true`.
- `cond` - A name of a function that is to be called everytime the hotstring is triggered. If this function returns a false value or if it returns nothing, the hotstring **is not triggered**.

##Examples:
```autohotkey
#Include Hotstring.ahk

Hotstring("btw", "by the way") ; Case insensitive.
; btw -> by the way
; BTW -> by the way
; BtW -> by the way
; bTw -> by the way.
; annd so on.

Hotstring("ahk", "autohotkey", 2) ; Case sensitive. 
; only ahk will trigger it. AHK, aHk, or AhK won't trigger it
```

```autohotkey
#Include Hotstring.ahk

Hotstring("toLabel", "label")
return

label:
; $ == "toLabel"
return

```

```autohotkey
#Include Hotstring.ahk
Hotstring("(\d+)\/(\d+)%", "percent",3)
return

percent:
; now $ is a match object.
sendInput, % Round(($.Value(1)/$.Value(2))*100)
; 2/2% -> 100
; 70/100 -> 70%
return
```

```autohotkey
#Include Hotstring.ahk

Hotstring("i)((d|w)on)(t)", "$1'$3",3) 
;DONT -> DON'T
;dont -> don't
;dOnt -> dOn't
;WONT -> WON'T
;and so on.

Hotstring("i)colou?rs","$0 $0 everywhere!", 3) ; Regex, Case insensitive
; colors -> 'colors colors everywhere!'
; colours -> 'colours colours everywhere!'

```

```autohotkey
#Include Hotstring.ahk

Hotstring("trigger", "replace") ;Case Insensitive
return

replace($){
	; $ == 'trigger'
	Msgbox %$% was entered!
}
```

```autohotkey
#Include Hotstring.ahk

Hotstring("i)regex_(trigger)", "replace",3) ;Regex
return

replace($){
	;$ is a match Object
	Msgbox % $.Value(0) . " was entered."
	Msgbox % $.Value(1) . " == 'trigger'"
}
```

```autohotkey
#Include Hotstring.ahk

Hotstring("trigger", "replace")
Sleep,4000
Hotstring("trigger","") ; Removes the hotstring
```