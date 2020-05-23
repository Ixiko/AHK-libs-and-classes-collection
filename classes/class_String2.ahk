/**
 * this class allows us to interact upon strings similar to objects.
 * it gets initialized by String_Set
 * for optimal use place this is the "\lib" folder and include via
 * #include <String>
 *
 * @Remarks
 * ?: - Ternary operator [v1.0.46+]. 
 * This operator is a shorthand replacement for the if-else statement. 
 * It evaluates the condition on its left side to determine which of 
 * its two branches should become its final result. 
 * For example, var := x>y ? 2 : 3 stores 2 in Var if x is greater than y; 
 * otherwise it stores 3. 
 * To enhance performance, only the winning branch is evaluated.
*/

class String {
    static init := ("".base.base := String)
    static __Set := Func("String_Set")

/**
 * Getter meta function
 * this allows to interact on given object directly using keywords
 *
 * @Parameters
 *    @Key     - [string][int] identifier to trigger different functions.routines
 *    @Key2    - [string][int] identifier to trigger different functions.routines
 *
 * @Return
 *    string
*/
    __Get(key, key2:="") {
        if (key == "isInt") {
            ; checks if the content is an integer
            if this is integer 
            {
                out := true
            } else {
                out := false
            }

        } else if (key == "capitalize" || key == "caps") {
            ; capitalizes first letter in the string
            out := Format("{1:U}{2:L}", Substr(this, 1, 1), SubStr(this, 2))

        } else if (key == "lower") {
            ; converts string to lowercase
            out := Format("{:L}", this)

        } else if (key == "title") {
            ; Applies Title Case to the String
            out := Format("{:T}", this)

        } else if (key == "upper") {
            ; CONVERTS STRING TO UPPERCASE
            out := Format("{:U}", this)

        } else if (key == "reverse") || (key = "rev") {
            ; reverses string from left->right to right->left
            ; tfel>-thgir ot thgir>-tfel morf gnirts sesrever
            DllCall("msvcrt\_" (A_IsUnicode? "wcs":"str") "rev", "UInt",&this, "CDecl"), out:=this

        } else if (key == "length") || (key == "len") {
            ; returns the length of the string
            out := StrLen(this)

        } else if (key == "isEmpty") {
            ; checks if the string is empty
            out := StrLen(this)? False:True

        } else if (key.isInt && key2.isInt) {
            ; returns key2 characters of the string starting from key
            out := SubStr(this, key, key2)

        } else if (key.isInt && key2 == "") {
            ; returns a 1 character of the string starting from key
            out := SubStr(this, key, 1)

        } else if (key = "toHex") {
            ; transforms a number into a hex value
            out := Format("{:#x}", this)

        } else if (key = "toDec") {
            ; transforms a hex value into a decimal value - needs to be prefixed with 0x; e.g. 0xFF
            out := Format("{:#d}", this)

        } else if (key = "isStr") {
            ; checks if variable is a string by converting it to hex. 
            ; if the conversion returns 0 instead of 0x it has to be a string
            out := SubStr(Format("{:#x}", this), 1, 2)="0x"? False:True

        }
        return, out
    }

    /**
     * counts occurences of given needle inside the string
     *
     * @Parameters
     *    @needle    - [int][string] this defines what we want to have counted
     *
     * @Return
     *    int
    */
    count(needle) {
        StrReplace(this, needle , needle, count)
        return, count
    }

    /**
     * performs a check if the given needle exists in the string
     * and returns it's position, if found
     *
     * @Parameters
     *    @needle           - [string][int] value to search for
     *    @case_sensitive   - [boolean] makes the search case sensitive
     *    @starting_pos     - [int] sets the starting position
     *
     * @Return
     *    int
    */
    inStr(needle, case_sensitive:=false, starting_pos:=1) {
        out := InStr(this, needle, case_sensitive, starting_pos)
        return, out
    }

    /**
     * keeps the lines of a multiline variable and returns it
     *
     * @Parameters
     *    @lines    - [string][int] as a string use a lists like this
     *                              3,5,11
     *
     * @Return
     *    string
     *
     * @Remarks
     *     int will only consider the first value
    */
    keepLines(lines) {
        VarSetCapacity(out, n:=StrLen(this))
        Loop, Parse, this, `n, `r
            if A_Index in %lines%
                out .= A_LoopField "`n" 
        return, SubStr(out, 1, -1)
    }

    /**
     * returns the leftmost characters
     *
     * @Parameters
     *    @boundary    - [int] this sets how many characters should be returned
     *
     * @Return
     *    string
    */
    left(boundary:=1) {
       StringLeft, out, this, boundary
       return, out
    }

    /**
     * returns the rightmost characters
     *
     * @Parameters
     *    @boundary    - [int] this sets how many characters should be returned
     *
     * @Return
     *    string
    */
    right(boundary:=1) {
       StringRight, out, this, boundary
       return, out
    }

    /**
     * trims the left most characters until boundary is reached
     *
     * @Parameters
     *    @boundary    - [int] number of characters until trim ends
     *
     * @Return
     *    string
    */
    trimL(boundary:="") {
        if boundary.is_Str
            out := boundary? LTrim(this, boundary):LTrim(this)
        else
            StringTrimLeft, out, this, boundary
        return, out
    }

    /**
     * trims the right most characters until boundary is reached
     *
     * @Parameters
     *    @boundary    - [int] number of characters until trim ends
     *
     * @Return
     *    string
    */
    trimR(boundary:="") {
        if boundary.is_Str
            return, boundary? RTrim(this, boundary):RTrim(this)
        else
            StringTrimRight, out, this, boundary
        return, out
    }

    /**
     * searches for the needle and replaces all occurences
     *
     * @Parameters
     *    @needle           - [string] defines what to search for
     *    @replacement      - [string] defines the replacement
     *
     * @Return
     *    string
    */
    replace(needle, replacement:="") {
       StringReplace, out, this, %needle%, %replacement%, A
       return, out
    }

    /**
     * searches for the needle and replaces all occurences via Regular Expression
     *
     * @Parameters
     *    @needle           - [string] defines which Regular Expression to search for
     *    @replacement      - [string] defines the replacement
     *
     * @Return
     *    string
    */
    regExReplace(needle, replacement:="") {
        return, RegExReplace(this, needle, replacement)
    }

    /**
     * repeats the string defined number of times
     *
     * @Parameters
     *    @count   - [int] count of how many times string should be repeated
     *
     * @Return
     *    string
    */
    times(count) {
        VarSetCapacity(out, count)
        Loop, %count%
            out .= this
        return, out
    }

    /**
     * splits string by delimiters and saves values in an object
     *
     * @Parameters
     *    @delim    - [string] character which should be split upon
     *    @omit     - [string] list of characters to exclude from the 
     *                         beginning and end of each array element
     *
     * @Return
     *    object
    */
    split(delim:="", omit:="") {
        out := []
        if (SubStr(delim, 1, 2) = "R)") {
            this := this.Replace(omit), pos := 0, n:=start:=1
            if ((needle:=SubStr(delim, 3))="") {
                return, this.split(needle)
            }
            while, pos := RegExMatch(this, needle, match, start) {
                out[n++] := SubStr(this, start, pos-start), start := pos+StrLen(match)
            }
            out[n] := SubStr(this, start)
        } else {
            Loop, Parse, this, %delim%, %omit%
                out[A_Index] := A_LoopField 
        }
        return, out 
    } 

    /**
     * removes the lines of a multiline variable and returns it
     *
     * @Parameters
     *    @lines    - [string][int] as a string use a lists like this
     *                              3,5,11
     *
     * @Return
     *    string
     *
     * @Remarks
     *     int will only consider the first value
    */
    removeLines(lines) {
        VarSetCapacity(out, n:=StrLen(this))
        Loop, Parse, this, `n, `r 
            if A_Index not in %lines%
                out .= A_LoopField "`n" 
        return, SubStr(out, 1, -1)
    }

}
String_Set(byref this, key, value){
    StringReplace, this, this, %key%, %value%, all
}