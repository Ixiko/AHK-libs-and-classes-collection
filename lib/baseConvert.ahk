; Number System Converter by Holle
; http://www.autohotkey.com/forum/viewtopic.php?t=56135

; Some "names" for the number systems will be accepted such as decimal/dec/d/base10/dekal or
; binary/bin/digital/dual/di/b/base2
; Use can use the names/shortcuts or the "base", like "base10" for decimal or "base2" for binary. 
baseConvert(value, from, to)                        ;the function baseConvert()
{
    if !(value and from and to)                 ;if mising data...
    {
        MsgBox, 4096 , , Missing Parameter! `n`nUse: baseConvert("Value", "From", "To") `n`nExample: `nbaseConvert("55", "dec", "hex")
        Exit
    }                                                      ;else ....
    ;some names for number systems
    base2 = Base2|Binary|Bin|Digital|Binär|Dual|Di|B
    base3 = Base3|Ternary|Triple|Trial|Ternär
    base4 = Base4|Quaternary|Quater|Tetral|Quaternär
    base5 = Base5|Quinary|Pental|Quinär
    base6 = Base6|Senary|Hexal|Senär
    base7 = Base7|Septenary|Peptal|Heptal
    base8 = Base8|Octal|Oktal|Oct|Okt|O
    base9 = Base9|Nonary|Nonal|Enneal
    base10 = Base10|Decimal|Dezimal|Denär|Dekal|Dec|Dez|D
    base11 = Base11|Undenary|Monodecimal|Monodezimal|Hendekal
    base12 = Base12|Duodecimal|Dedezimal|Dodekal
    base13 = Base13|Tridecimal|Tridezimal|Triskaidekal
    base14 = Base14|Tetradecimal|Tetradezimal|Tetrakaidekal
    base15 = Base15|Pentadecimal|Pentadezimal|Pentakaidekal
    base16 = Base16|Hexadecimal|Hexadezimal|Hektakaidekal|Hex|H
    base17 = Base17|Peptaldecimal|Peptaldezimal|Heptakaidekal
    base18 = Base18|Octaldecimal|Oktaldezimal|Octakaidekal|Oktakaidekal
    base19 = Base19|Nonarydecimal|Nonaldezimal|Enneakaidekal
    base20 = Base20|Vigesimal|Eikosal
    base30 = Base30|Triakontal
    base40 = Base40|Tettarakontal
    base50 = Base50|Pentekontal
    base60 = Base60|Sexagesimal|Hektakontal
    StringReplace, value_form, value,(,,all
    StringReplace, value_form, value_form ,),, all          ;if value is integer or letter when...
    if value_form is not Alnum                                       ;...parenthesis are removed
    {                                                                           ; if not...
        MsgBox, 4096 , , Error! `n`nOnly alphanumeric Symbols will be accepted!
        Exit
    }                                                           ;------------------------------------------------------------------------------------
    if (InStr(from, "base"))                                            ;if the word "base" is in "from"...
    {
        StringTrimLeft, base_check, from, 4                   ;...then cut "base" to have ONLY the number
        if base_check is not Integer                               ;if "from" not integer now
        {
            MsgBox, 4096 , , Unknown Number System! `n`nUse Base + Number (example: Base16), `nor the name/shortcut (example: "Hexadecimal" or "Hex")
            Exit
        }
        else                                                                  ;else replace the value from "from"
            from := base_check                                       ;with the number in base_check
    }                                                           ;------------------------------------------------------------------------------------
    if (InStr(to, "base"))                                               ;the same as above again for the destination number system
    {
        StringTrimLeft, base_check, to, 4
        if base_check is not Integer
        {
            MsgBox, 4096 , , Unknown Number System! `n`nUse Base + Number (example: Base16), `nor the name/shortcut (example: "Hexadecimal" or "Hex")
            Exit
        }
        else
            to := base_check
    }                                                           ;---------------------------------------------------------------------------------
    base_loop := 1
    loop, 60                                                ;check in a loop from 2 to 60 if the names from
    {                                                          ;the source / destination number system is in the Variable "base.."
        if from is Integer                               ;if "from" is integer...
            if to is Integer                               ;and "to" too...
                Break                                       ;...cancel the loop
        if (base_loop < 20)                            ;if base_loop < 20...
            base_loop ++                                ;...increase by 1
        else                                                  ;else...
            base_loop += 10                           ;...increase by 10
        if (base_loop > 60)                            ;and if more then 60 ...
            Break                                           ;...cancel the loop
        base := base%base_loop%
        loop parse, base, |                            ;split every base variable word by word
        {
            if (from = A_LoopField)                  ;if one of them identical with the name ...
                from := base_loop                     ;...from the source number system then save the number in "from"
            if (to = A_LoopField)                      ;        ...the same for the destination number system
                to := base_loop
        }
    }
    if (from < 11)                                        ;by source numer system to 10 (therefore Decimal)
        if value is not Integer                         ;letters are not allowed
        {                                                      ;else exit
            StringGetPos, seperator_1, base%from%, |, L1 ;position of the first seperator
            StringGetPos, seperator_2, base%from%, |, L2 ;position of the second seperator...
            StringMid, name_from, base%from%, (seperator_1 + 2), (seperator_2 - seperator_1 - 1)
            MsgBox, 4096 , , Error! `nNo letters allowed in %name_from% system!
            Exit
        }
    con_letter := "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ;allowed letters
    result_dec=
    length := StrLen(value) ;count the characters
    counter := 0
    parenthesis := False    ;no parenthesis yet
    loop, %length%           ;loop by any character from "value"
    {
        StringMid, char, value, (length + 1 - A_Index), 1 ;process "backwards" the value, character by character
        if (char = ")")                                                   ;if there an right parenthesis ...
        {                                                                    ;      (notice, we work "backwards" at this time)
            if parenthesis                                              ;...although there was an right parenthesis before (without a left parenthesis) ...
            {                                                                ;...then exit
                MsgBox, 4096 , , Error!`nOnly "simple" parenthesis will be accepted!`n`nExample:`n57AH6(45)(48)G2 = accepted`n57AH6((45)(48))G2 = NOT accepted!
                Exit
            }
            parenthesis := True                                     ;else memorize that we are between parenthesis now
            Continue                                                     ;...cancel the rest from the loop and continue from begin
        }
        else if (char = "(")                                            ;if there an right parenthesis ...
        {                                                                    ;      (notice, we work "backwards" at this time)
            if !parenthesis                                             ;...although there wasn´t a right parenthesis before...
            {                                                                ;...then exit
                MsgBox, 4096 , , Error!`nOnly "simple" parenthesis will be accepted!`n`nExample:`n57AH6(45)(48)G2 = accepted`n57AH6((45)(48))G2 = NOT accepted!
                Exit
            }
            parenthesis := False                                   ;else memorize that we are NOT between parenthesis now
            if !par_char                                                ;if nothing between the parenthesis...
            {                                                               ;...then exit
                MsgBox, 4096 , , Error! `n No value between parenthesis!
                Exit
            }
            char := par_char                                        ;else, all numbers between parenthesis are ONE character now
        }
        else if parenthesis                                          ;we are between parenthesis at this time...
        {
            if char is not Integer                                   ;...and there is some other than Integer, then cancel
            {
                MsgBox, 4096 , , Error! ´nBetween parenthesis only numbers will be accepted!
                Exit
            }
            par_char := char . par_char                        ;else put every character between the parenthesis to ONE value
            Continue                                                    ;notice, because we work backwards in this loop, the next number will put BEFORE the previous number, ...
        }
        else if char is Alpha                                        ;if there a letter
        {
            StringGetPos, char_pos, con_letter, %char%          ;then check th position from this letter in "con_letter"
            StringReplace, char, char, %char%, %char_pos%   ;and replace the letter with the position-number
            char += 10                                                            ;and add 10
            if (char >= from)
            {                                                                           ;if the number greater than the number system...
                StringGetPos, seperator_1, base%from%, |, L1  ;...Example: 18 in hexadecimal system
                StringGetPos, seperator_2, base%from%, |, L2  ;then exit
                StringMid, name_from, base%from%, (seperator_1 + 2), (seperator_2 - seperator_1 - 1)
                char := from - 10
                StringMid, char, con_letter, %char%, 1
                MsgBox, 4096 , , Error! `nOnly letters until "%char%" will be accepted in %name_from% system!
                Exit
            }
        }
        if (char >= from)   ;is the character at this position isn´t a letter, but a number which is...
        {                          ;...greater than the number system, then exit
            max_value := from - 1
            MsgBox, 4096 , , Error! `nOnly values from 0-%max_value% will be accepted in base%from% system!
            Exit
        }
        result_dec += char * (from**counter)   ;convert source number system to decimale number system
        counter ++                                        ;increase counter by one
    }
    if (to = 10)                                            ;if decimale system the destination number system
        Return %result_dec%                        ;then return the result
    result=                                                  ;else convert it to destination number system
    while (result_dec)
    {       
        char := Mod(result_dec , to)                        ; first number from destination number system
        if (char > 35)                                               ;if it greater than 35...
            char := "(" . char . ")"                               ;...put it between parenthesis
        else if (char > 9)                                          ;if it less than 36 , but greater than 9,
            StringMid, char, con_letter, (char - 9), 1    ;...replace it with a letter
        result :=  char . result                                   ;combine the characters to the result
        result_dec := Floor(result_dec / to)               ;calculate the remain to continue the converting with this
    }
    Return %result%                                             ;return result
}
