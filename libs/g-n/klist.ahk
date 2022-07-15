/*
    Function: kList
        Creates a list of autohotkey compatible key names ready to be parsed.

        This function will generate a delimited list of key names that can be used in autohotkey commands
        like "hotkey" or "getkeystate" or even for more general purposes like creating a list of keys that will be
        shown on a combobox.
        

    Parameters:
        kList([inc, exc, sep])

        inc         -   Allows you to include specific keys, ascii characters or mouse keys to the list.
                        Although this option is for you to specify your own key/range you can make use
                        of some predefine keywords to add common ranges of keys:
                        
                        + *all*:        Adds all ascii characters, punctuation, numbers, keyboard and mouse keys. *
                        + *alphanum*:   Adds alphabetic and numeric characters and excludes punctuation signs. *
                        + *lower*:      Adds all alphabetic characters in lowercase.
                        + *upper*:      Adds all alphabetic characters in uppercase.
                        + *num*:        Adds only numeric characters.
                        + *punct*:      Adds only punctuation and math operator signs.
                        + --------------------------------------------------------------
                        + *msb*:        Includes mouse buttons.
                        + *mods*:       Includes modifier keys. *
                        + *fkeys*:      Includes all the F keys.
                        + *npad*:       Controls the addition of numpad keys and NumLuck.
                        + *kbd*:        For all the other keys like *Enter*, *Space*, *Backspace* and such.
                        + You can exclude one or more ranges of numbers and letters using the "1-5" or "b-h" format.
                          Ranges should always be positive. "5-1" or "h-b" are not valid.

    Note :
        + The option "mods" will only return a short version of the modifiers.
          If you want the more detailed one use a caret "^" right next to it. Ex. "mods^" would bring the long list
          of modifiers.
        
        + When using  the options "all" and "alphanum" kList will assume that you want only
          lowercase.

          Adding a "^" to those parameters would force the function to return uppercase characters.
          ex.:  "alphanum" will return 0-9 and lowercase alpha chars unless you specify
          "alphanum^".
        
        exc         -   Allows you to exclude specific keys, ascii characters or mouse keys from the list.
                        This parameter goes in the same tone of the <Parameter.inc> above so everything
                        works similar.

                        + *alphanum*:   Excludes alphabetic and numeric characters.
                        + *lower*:      Excludes all alphabetic characters in lowercase.
                        + *upper*:      Excludes all alphabetic characters in uppercase.
                        + *num*:        Excludes numeric characters.
                        + *punct*:      Excludes punctuation and math operator signs.
                        + --------------------------------------------------------------
                        + *msb*:        Excludes mouse buttons.
                        + *mods*:       Excludes modifier keys.
                        + *fkeys*:      Excludes all the F keys.
                        + *npad*:       Excludes numpad keys and NumLuck.
                        + *kbd*:        Excludes all the other keys like *Enter*, *Space*, *Backspace* and such.
                        + You can exclude one or more ranges of numbers and letters using the "1-5" or "b-h" format.
                          Ranges should always be positive. "5-1" or "h-b" are not valid.

        sep         -   Allows you to specify a custom separator delimiter for the lists.
                        Note that the separator itself is not going to be added to the list, so specifying "+" as a 
                        delimiter will cause it to be absent from the list.

    Returns:
        kList       -   List of ascii keys, mouse and keyboard keys and punctuation signs separated by spaces.
        False       -   When you try to input more than 1 character on the separator parameter.

    Examples:

*/
kList(inc="all", exc="", sep=" "){
    Static lPunct,$reRF,vAll,vLower,vUpper,vNum,vAlnum,vPunct,msb,mods,fkeys,npad,kbd,nil=

    if strLen(sep) > 1
        return  False     ; You can only specify 1 character as the separator 

    ; List of keyboard and mouse names as defined in "List of Keys, Mouse Buttons, and Joystick Controls".
    vNum  :="0 1 2 3 4 5 6 7 8 9 "
    vLower:="a b c d e f g h i j k l m n o p q r s t u v w x y z "
    vUpper:="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z "
    vAlnum:= vNum (RegexMatch(inc, "(all|alphanum)\^") ? vUpper : vLower)
    vPunct:="! "" # $ % & ' ( ) * + , - . / : `; < = > ? @ [ \ ] ^ `` { | } ~ "
    msb   :="LButton RButton MButton WheelDown WheelUp "
    mods  :="AppsKey LWin RWin LControl RControl LShift RShift LAlt RAlt Control Alt Shift "
    fkeys :="F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 "
    npad  :="NumLock Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 "
          . "Numpad9 NumpadIns NumpadEnd NumpadDown NumpadPgDn NumpadLeft NumpadClear NumpadRight NumpadHome "
          . "NumpadUp NumpadPgUp NumpadDot NumpadDel NumpadDiv NumpadMult NumpadAdd NumpadSub NumpadEnter "
    kbd   :="Space Tab Enter Escape Backspace Delete Insert Home End PgUp PgDn Up Down Left Right "
          . "ScrollLock CapsLock PrintScreen CtrlBreak Pause Break Help Sleep " 
    vAll  := RegexReplace(RegexReplace(vPunct vAlnum msb mods fkeys npad kbd , "\s", sep),"\" sep "$")
    kwords:= "lower|upper|num|punct|alphanum|msb|mods|fkeys|npad|kbd"
    $reRF :="(\s?)+(?P<Start>[a-zA-Z0-9])-(?P<End>[a-zA-Z0-9])(\s?)+"
    lPunct:=",,,!,"",#,$,%,&,',(,),*,+,-,.,/,:,;,<,=,>,?,@,[,\,],^,``,{,|,},~" ; as a list for the if [in] command
    
    if (inStr(inc, "all") && !exc)
        return vAll
    
    While(RegexMatch(exc, kwords, match)){
        exc := RegexReplace(exc, "\b" match "\b(\s?)+"
                           , match = "alphanum" ? vAlnum    : nil
                           . match = "lower"    ? vLower    : nil
                           . match = "upper"    ? vUpper    : nil
                           . match = "num"      ? vNum      : nil
                           . match = "punct"    ? vPunct    : nil
                           . match = "msb"      ? msb       : nil
                           . match = "mods"     ? mods      : nil
                           . match = "fkeys"    ? fkeys     : nil
                           . match = "npad"     ? npad      : nil
                           . match = "kbd"      ? kbd       : nil)
    }
    
    ; Advanced including options.
    ; This little loop allows excluding ranges like "1-5" or "a-d".
    ; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not allowed.
    While(Regexmatch(inc, $reRF, r)){
        Loop % asc(rEnd) - asc(rStart) + 1 ; the + 1 is to include the last character in range.
            lst .= chr(a_index + asc(rStart) - 1) a_space
            
        inc := RegexReplace(inc, $reRF, "", "", 1)
    }
    
    ; This will include user specified keys and will replace keywords by their respective lists.
    lst .= inc a_space
        . (inStr(inc,"all") ? vPunct vAlnum msb mods fkeys npad kbd : nil)
        . (inStr(inc,"alphanum") && !inStr(exc, "alphanum") ? vAlnum : nil) 
        . (inStr(inc, "lower") && !inStr(inc,"alphanum") && !inStr(exc, "lower") ? vLower : nil) 
        . (inStr(inc, "upper") && !inStr(inc,"alphanum") && !inStr(exc, "upper") ? vUpper : nil) 
        . (RegexMatch(inc,"\bnum\b") && !RegexMatch(exc,"\bnum\b") ? vNum : nil)
        . (inStr(inc, "punct") && !inStr(exc, "punct") ? vPunct : nil) 
        . (inStr(inc, "msb") && !inStr(exc, "msb") ? msb : nil)
        . (inStr(inc, "fkeys") && !inStr(exc, "fkeys") ? fkeys : nil) 
        . (inStr(inc, "npad") && !inStr(exc, "npad") ? npad : nil) 
        . (inStr(inc,"kbd") && !inStr(exc,"kbd") ? kbd : nil)
        . (inStr(inc,"mods^") && !inStr(exc,"mods") ? mods : inStr(inc,"mods") && !inStr(exc,"mods") ? nil
        . RegexReplace(mods, "(AppsKey|LControl|RControl|LShift|RShift|LAlt|RAlt)(\s?)+") : nil)
    
    ; Advanced excluding options.
    ; This little loop allows excluding ranges like "1-5" or "a-d".
    ; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not allowed.
    While(Regexmatch(exc, $reRF, r)){
        Loop % asc(rEnd) - asc(rStart) + 1    ; the + 1 is to include the last character in range.
            StringReplace,lst,lst,% chr(a_index + asc(rStart) - 1) a_space

        exc := RegexReplace(exc, $reRF, "", "", 1)
    }
    
    ; Remove excluded keys from list.
    Loop, Parse, exc, %a_space%
    {
        ; needed Regex to avoid deleting "NumpadEnter" when trying to delete "Enter" and such.
        if strLen(a_loopfield) > 1
            lst := RegexReplace(lst, "i)\b" a_loopfield "\b\s?")
        else if a_loopfield in %lPunct%
            lst := a_loopfield ? RegexReplace(lst, "\" a_loopfield "\s?") : lst
        else if (a_loopfield != "")
            lst := RegexReplace(lst, "\b" a_loopfield "\b\s?")
    }
    
    ; Cleaning.
    lst := RegexReplace(lst,"(\s?)+[a-zA-Z0-9]-[a-zA-Z0-9](\s?)+") ; remove ranges from include.
    lst := RegexReplace(lst,"i)(all\^?|lower|upper|\bnum\b|alphanum\^?|punct|msb|mods\^?|fkeys|npad|kbd)(\s?)+")
    return RegexReplace(RegexReplace(lst, "\s", sep), "\" sep "$")
} ; Function End.
