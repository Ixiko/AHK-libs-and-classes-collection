/**
 * String and RegEx manipulation functions
 *
 * FeatShare v0.2 - Text integration tool
 * Copyright (C) 2016  szapp <http:;github.com/szapp>
 *
 * This file is part of FeatShare.
 * <http:;github.com/szapp/FeatShare>
 *
 * FeatShare is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FeatShare is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FeatShare.  If not, see <http:;www.gnu.org/licenses/>.
 *
 *
 * Third-party software:
 *
 * MPRESS v2.19, Copyright (C) 2007-2012 MATCODE Software,
 * for license information see: /mpress/LICENSE
 *
 * AutoHotkey-JSON v2.1.1, 2013-2016 cocobelgica, WTFPL <http:;wtfpl.net>
 *
 * Class_RichEdit v0.1.05.00, 2013-2015 just me,
 * Unlicense <http:;unlicense.org>
 *
 *
 * Info: Comments are set to C++ style. Escape character is ` e.g.: `n
 */

#CommentFlag, ;


/**
 * Opposite of ObjHasKey: Returns if obj as val
 *
 * obj                 Object in question
 * val                 Value in obj
 *
 * returns             True if found, False otherwise
 */
ObjHasVal(ByRef obj, val) {
    for k, v in obj
        if (v == val)
            return True
    return False
}

/**
 * Counts the key-value pairs of an object.
 * ObjGetCapacity() and ObjMaxIndex() do not suffice!
 *
 * obj                  Object in question
 *
 * returns              Number of items
 */
ObjCount(ByRef obj) {
    count = 0 ; Set to zero otherwise return is empty for no items
    for k, 0 in obj
        count++
    return count
}

/**
 * Concatenate elements/array items to a string separated by a delimiter
 *
 * s                   Delimiter
 * p                   Object or list of elements
 *
 * returns             Concatenated string
 */
join(s, p*) {
    static _:="".base.join:=Func("join")
    for k,v in p {
        if isObject(v)
            for k2, v2 in v
                o .= s v2
        else
            o .= s v
    }
    return SubStr(o, StrLen(s)+1)
}

/**
 * Returns a string consisting of num times char, ex. fill("a", 3) == "aaa"
 *
 * char                Character to repeat
 * num                 Number of repetitions
 *
 * returns             Constructed string
 */
fill(char, num) {
    if (num > 0)
        Loop, %num%
            rtn .= char
    return rtn
}

/**
 * Retrieve number of lines in a sub-string
 *
 * haystack             String to search
 * startpos             Range of the string
 * length               Range of the string
 * returns              Number of lines
 */
lineNum(haystack, startpos=1, length=-1) {
    ; Haystack must exist
    if !haystack
        return 0
    ; If stringpos is negative, start from end of the string
    if (startpos > StrLen(haystack))
        startpos := StrLen(haystack)
    else if (startpos < 1)
        startpos := StrLen(haystack)+startpos
    cr := "`r", lf := "`n" ; Carrige return and line feed
    ; Do not split carriage return and line feed (Disregard line break at start when starting on lf (if there is cr))
    if (SubStr(haystack, startpos, 1) == lf) ; && (SubStr(haystack, startpos-1, 1) == cr)
        startpos++, length--
    ; else if (SubStr(haystack, startpos, 1) == lf) ; If there is no carriage return include line feed
    ;     startpos--, length++
    ; Do not split carriage return and line feed (Include complete line break (crlf) when ending on cr)
    if (SubStr(haystack, startpos+length, 1) == cr)
        length++
    ; If length is negative or too large, operate on the entire string
    if (length < 1) || (length > StrLen(haystack)-startpos)
        length := StrLen(haystack)-startpos
    StrReplace(SubStr(haystack, startpos, length), lf, lf, line)
    return 1+line ; Include the starting line
}

/**
 * Retrieve lines string by line number
 *
 * haystack             String to search
 * line                 Range of lines
 * length               Range of lines
 *
 * returns              String enclosing line ranges
 */
getLines(haystack, line=1, length=1) {
    cr := "`r", lf := "`n" ; Carrige return and line feed
    ; Haystack must exist
    if !haystack
        return ""
    totalLines := lineNum(haystack, 1, -1)
    ; If line is negative, start from end of the string
    if (line > totalLines)
        return ""
    else if (line < 1)
        line := totalLines+line
    ; If length is negative or too large, operate on the entire string
    if (length < 1) || (length > (totalLines-line)+1)
        length := (totalLines-line)+1
    lines := ""
    Loop, Parse, haystack, %lf%
        if (A_Index >= line) && (A_Index < line+length)
            lines .= A_LoopField lf
    return lines
}

/**
 * Retrieve the line around an offset (upto or from) line break
 *
 * haystack             String to search
 * pos                  Position in string
 * before               Get line upto the position or from position
 * lines                How many lines to include
 * lf                   Line-feed character
 *
 * returns              String containing part of line
 */
getContext(haystack, pos=1, before:=True, lines=0) {
    cr := "`r", lf := "`n" ; Carrige return and line feed
    ; Haystack must exist
    if !haystack
        return ""
    if (lines < 0)
        lines = 0
    ; if (SubStr(haystack, pos, StrLen(lf)) == lf)
    ;     return ""
    ; Error handling (if pos too small/large) done in SubStr()
    if before { ; Find string from last newline to pos
        posNL := InStr(SubStr(haystack, 1, pos), lf, False, 0, lines+1)
        if !posNL ; If very first line
            posNL = 0
        if (posNL >= pos)
            return ""
        return SubStr(haystack, posNL+1, pos-posNL)
    }
    else { ; Find string from pos to next newline
        posNL := InStr(SubStr(haystack, pos), lf, False, 1, lines+1)
        if !posNL ; If very last line
            posNL := (StrLen(haystack)-pos)+1
        return SubStr(haystack, pos, posNL)
    }
}

/**
 * Prefixes all lines in a string by a prefix (e.g. indent)
 *
 * haystack             String to search
 * prefix               String to prefix lines
 *
 * returns              Prefixed string
 */
prefixLines(haystack, prefix:=" ", omitFirst:=False) {
    cr := "`r", lf := "`n" ; Carrige return and line feed
    if !haystack
        return ""
    return (!omitFirst ? prefix : "") RTrim(StrReplace(haystack, lf, lf prefix), prefix)
}

/**
 * Return value, position or length of pattern or matched bracket. Patterns might be one of the following:
 * Sub-pattern of RegEx (in var match), in extendedPatterns (machtedBracket), or in storedVars (custom variables)
 *
 * numSymbol           Symbol to interpret
 *
 * returns             Interpreted symbol, -1 if not found
 */
patternVal(numSymbol) {
    global match, storedVars, extendedPatterns ; Match from previous RegEx
    if RegExMatch(numSymbol, "^\$\d+$") && (match.Count() >= SubStr(numSymbol, 2)) ; Is subpattern from RegEx, e.g. $1
        return match[SubStr(numSymbol, 2)]
    else if (SubStr(numSymbol, 1, 1) == "$") && extendedPatterns.HasKey(SubStr(numSymbol, 2)) ; Var in extendedPatterns
        return extendedPatterns[SubStr(numSymbol, 2)]["val"]
    else if (SubStr(numSymbol, 1, 1) == "$") && storedVars.HasKey("$" SubStr(numSymbol, 2)) ; Var in storedVars
        return storedVars["$" SubStr(numSymbol, 2)]
    else ; Otherwise interpret as literal string
        return numSymbol
}
patternPos(numSymbol) {
    global match, extendedPatterns
    if RegExMatch(numSymbol, "^\$\d+$") && (match.Count() >= SubStr(numSymbol, 2))
        return match.Pos(SubStr(numSymbol, 2))
    else if (SubStr(numSymbol, 1, 1) == "$") && extendedPatterns.HasKey(SubStr(numSymbol, 2))
        return extendedPatterns[SubStr(numSymbol, 2)]["pos"]
    else if RegExMatch(numSymbol, "^\d+$") ; If integer, return (Use RegEx, because type matching is bad in AHK)
        return numSymbol
    else
        return -1 ; Not found
}
patternLen(numSymbol) {
    global match, extendedPatterns
    if RegExMatch(numSymbol, "^\$\d+$") && (match.Count() >= SubStr(numSymbol, 2))
        return match.Len(SubStr(numSymbol, 2))
    else if (SubStr(numSymbol, 1, 1) == "$") && extendedPatterns.HasKey(SubStr(numSymbol, 2))
        return extendedPatterns[SubStr(numSymbol, 2)]["len"]
    else if RegExMatch(numSymbol, "^\d+$") ; If integer, return
        return numSymbol
    else
        return -1 ; Not found
}

/**
 * Returns matching closed parentheses/brackets/square brackets
 * Modified from http:;stackoverflow.com/a/27088184/1049693
 *
 * haystack            String to search
 * startIndex          Offset of open bracket
 *
 * returns             Pattern object if found, False otherwise
 */
matchClosed(haystack, startIndex) {

    ; Check whether position is on valid open bracket
    bracketOpen := SubStr(haystack, startIndex, 1)
    matchingBrackets := {"(": ")", "{": "}", "[": "]"}
    if !matchingBrackets.HasKey(bracketOpen)
        return False ; Illegal character
    bracketClosed := matchingBrackets[bracketOpen]

    currPos := startIndex+1 ; Currect position in haystack
    openBrackets = 1 ; Number of brackets to close
    waitForChar := "" ; Quotes/comments, where to ignore bracket characters

    while (openBrackets != 0) && (currPos <= StrLen(haystack)) {
        currChar := SubStr(haystack, currPos, 1)
        if (waitForChar == "") {
            if (currChar == bracketOpen)
                openBrackets++
            else if (currChar == bracketClosed)
                openBrackets--
            else if (currChar == """") || (currChar == "'")
                waitForChar := currChar
            else if (currChar == "/") {
                nextChar := SubStr(haystack, currPos+1, 1)
                if (nextChar == "/") {
                    waitForChar := "`n"
                } else if (nextChar == "*") {
                    waitForChar := "*/"
                }
            }
        } else {
            if (currChar == waitForChar)
                waitForChar := ""
            else if (currChar == "*") && (SubStr(haystack, currPos+1, 1) == "/")
                waitForChar := ""
        }
        currPos++
    }
    if (currPos > StrLen(haystack)) ; Search unsuccessful
        return False
    ; Return array of form value, position, length
    return {"val": SubStr(haystack, --currPos, 1), "pos": currPos, "len": 1}
}

/**
 * Repeat padding. Will perform one of the following actions.
 * {char:needle:num} -> repeat char (num-StrLen(replaceText)) times
 * {char:num}        -> repeat char num times
 * Where the structure around (and) char and num are searched and replaced in
 * haystack. Char is of string length one.
 *
 * haystack            String to search
 * needle              Optional var name
 * replaceText         Optional replace string (only for string length)
 * limit               Replace how many occurrences (default: all)
 *
 * returns             (Un-) Altered haystack
 */
repeatPadding(haystack, needle:="", replaceText:="", start=1, limit=-1) {
    ; Needle might be empty string (or 0)
    needle := needle ? ":" needle : ""
    replaceText := replaceText ? replaceText : needle
    cnt = 0 ; Counter
    ; Loop over haystack
    While RegExMatch(haystack, "iO)\{(.)" needle ":(\d+)\}", fnd, start)
    && (limit == -1 || (cnt++ < limit))  {
        ; Length of padding (how many times to repeat chr)
        len := needle ? fnd[2]-StrLen(replaceText) : fnd[2]
        haystack := SubStr(haystack, 1, fnd.Pos(0)-1) fill(fnd[1], len) SubStr(haystack, fnd.Pos(0)+fnd.Len(0))
    }
    return haystack
}

/**
 * Replaces all needles with separate patterns (and interprets those)
 *
 * haystack            String to search
 * patterns            Needle-replace pairs
 * feature             Feature to manipulate replace-text
 * brackets            Wrap needles in brackets
 *
 * returns             (Un-)Altered haystack
 */
replaceAllPatterns(haystack, ByRef patterns, ByRef feature=0, brackets:=True) {
    global storedVars, replaceNL

    ; If needle is enclosed by brackets
    if brackets
        bl := "\{", br := "\}"

    ; Padd by length (no needle) e.g. {\t:2} repeat tab twice
    haystack := repeatPadding(haystack)

    ; Iterate over all needle-replaceText pairs
    for needle, replaceText in patterns {

        ; Assume replace text is a custom variable
        if storedVars.HasKey("#" replaceText)
            replaceText := storedVars["#" replaceText]
        ; Assume replace text is a feature trait
        else if feature[replaceText]
            replaceText := feature[replaceText]
        ; Otherwise treat as literal text or matched pattern from regex e.g. $1
        else
            replaceText := patternVal(replaceText)

        ; Un-escape newlines and tabs
        if InStr(replaceText, "\r")
        || InStr(replaceText, "\n")
        || InStr(replaceText, "\t")
            replaceText := replaceAllPatterns(replaceText, replaceNL, 0, False)

        ; Also interpret the needle
        needle := patternVal(needle)
        ; Special case: Needle is reference to storedVars (change # to $)
        if (SubStr(needle, 1, 1) == "#")
        && storedVars.HasKey(needle)
            needle := "\$" SubStr(needle, 2)

        ; Padd with respect to needle/replaceText length
        if brackets
            haystack := repeatPadding(haystack, needle, replaceText)

        ; Finally replace all occurrences of needle with replace text
        haystack := RegExReplace(haystack, "i)" bl needle br, replaceText)
    }

    ; Return (un-)altered haystack
    return haystack
}

/**
 * RegExMatch-Wrapper function to allow to match a specific occurrence.
 * Functionality and parameters and return values are the same as RegExMatch.
 *
 * Haystack            The string whose content is searched
 * NeedleRegEx         The pattern to search for
 * OutputVar           Unquoted name of a variable in which to store the parts
 * StartingPosition    Start at the which character
 * Occurrence          Match occurrence. Negative numbers count from end
 *
 * returns             Position of the leftmost char, zero if not found
 */
RegExMatchOcc(Haystack, NeedleRegEx, ByRef OutputVar:="", StartingPosition=1, Occurrence=1) {

    ; Correct Occurrence
    if !Occurrence ; Zero means match first occurrence
        Occurrence = 1
    else if Occurrence is not integer
        Occurrence = 1 ; For some weird reason does this need its own if-clause
    else {
        ; Only pre-search regex now, wasting time otherwise
        RegExReplace(Haystack, NeedleRegEx, NeedleRegEx, cnt, -1, StartingPosition)
        if (Occurrence > cnt) ; Too big means match last occurrence
            Occurrence := cnt
        else if (Occurrence < 0) ; Count from end if negative
            Occurrence := cnt + (Occurrence + 1)
    }

    ; Find out the mode for OutputVar
    flgs := RegExReplace(SubStr(NeedleRegEx, 1, InStr(NeedleRegEx, ")")-1), "[^PO]", "")
    if (SubStr(flgs, 0) == "O")
        mode = 3 ; Mode 3 (match object)
    else if (SubStr(flgs, 0) == "P")
        mode = 2 ; Mode 2 (position-and-length)

    ; Loop over all occurrences
    pos := StartingPosition
    cnt = 1 ; Match all occurrences and stop when reaching occurrences or end
    While (pos := RegExMatch(Haystack, NeedleRegEx, OutputVar, pos)) && (cnt++ < Occurrence)
        if (mode == 3)
            pos += OutputVar.Len(0)
        else if (mode == 2)
            pos += OutputVar
        else ; mode == 1
            pos += StrLen(OutputVar)
    return pos
}

/**
 * Replace all occurrences with increasing offset (or without)
 *
 * haystack            The string whose content is searched
 * regex               The pattern to search for
 * offset              Replace text, possible index (will be incremented)
 * incr                Increments (decrements) offset by its value
 *
 * returns             (Un-)Altered haystack
 */
regexIncr(haystack, regex, ByRef offset, incr=+1) {
    cnt := True
    While cnt {
        haystack := RegExReplace(haystack, regex, offset, cnt, 1)
        if cnt && incr
            offset += incr ; Only increment if there was a replacement
    }
    return haystack
}

/**
 * Evaluates an expression consisting of integers (or $patterns) and plus/minus operators.
 * This function is very limited and tailored to specific limits. Evaluation is done strictly from left to right.
 *
 * expr                String expression to evaluate
 *
 * returns             Evaluated expression
 */
evalExprPos(expr) { ; Evaluate on the basis of patternPos
    return evalExpr(expr, "Pos")
}
evalExprLen(expr) { ; Evaluate on the basis of patternLen
    return evalExpr(expr, "Len")
}
evalExpr(expr, type) { ; Private function
    global __evaluated ; Caution: Global variable. Should not be used elsewhere
    __evaluated = 0
    ; Evaluate expression via RegEx Callouts
    RegExMatch(expr, "O)(?P<operator>[-\+]|^)(?P<operant>[^-\+]+)(?=[-\+]|$)(?CevalCallout" type ")")
    return __evaluated
}
evalCalloutPos(val) {
    global __evaluated
    __evaluated += val.operator patternPos(val.operant)
    return 1
}
evalCalloutLen(val) {
    global __evaluated
    __evaluated += val.operator patternLen(val.operant)
    return 1
}


