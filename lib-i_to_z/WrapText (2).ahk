; TextWrapper.ahk
; Original Author: Gehn WillowGlade <gehnofsol@bigfoot.com>
;
; Script Description:
;   Wraps text manually by inserting newline characters into a string using
;   a configurable methodology. Configuration is done by passing parameters to
;   the function as detailed below. All parameters (except the text string) have
;   a default and, thus, do not absolutely require setting. Text is wrapped by
;   breaking the lines as long as possible at given 'break characters'.
;
; Updates made 04/22/2019 by Osprey:
;  - Converted the script to a function, which eliminates the need to define
;    variables (instead, pass values to the function as parameters).
;  - Defined a format to pass sets of break characters and break types.
;  - Removed the breakType variable since it was redundant.
;
; Updates made 09/14/2017 by kkwillmert:
;  - Updated to work with AutoHotkey Versions 1.0.90+ (associative arrays broke
;    the original script).
;  - Added limited ability to handle line breaks in the input string. Two
;    consecutive line breaks will be treated as a delimiter which is preserved,
;    and the content between them is what gets wrapped. Single line breaks are
;    converted to whatever the first character in breakCharacterSetString is,
;    with an attempt made at preventing this conversion from creating two
;    consecutive instances of that character. This does, however, cause some
;    probably-undesirable behavior when there are an odd number of consecutive
;    line breaks in the original string, since only double line breaks are
;    preserved.
;
; Parameters:
;   textToWrap            - The text to be wrapped. Only required parameter.
;
;   maxCharactersPerLine  - The number of characters that are allowed
;                           on a line before a wrap is attempted.
;                           Default: 80
;
;   breakCharacterSet     - A string of characters of which each is a break
;                           character, meaning that newlines will be added
;                           only at those characters. Example: "\ #"
;                           Insert | (pipe) characters to define sets of
;                           break characters that share break type and
;                           priority. Sets on the right have lower priority.
;                           Example: "\ #|-="
;                           Default: " " (space)
;
;   breakCharacterSetType - The word 'after', 'before' or 'eat' to designate
;                           whether the break should occur after the break
;                           character, before it or in its place (eating it).
;                           Insert | (pipe) characters to create break type
;                           sets that correspond to the sets defined in
;                           breakCharacterSet. Example: "after|before"
;                           Default: "after"
;
;   forceWrap             - Force wrapping of the text, even if no break
;                           characters are found. In such a case, the line
;                           will break right at the limit. Set this option
;                           to true or false. The default is false.
;                           Default: false
;
; Example #1:
;   wrappedText := WrapText("C:\Games\Guild Wars\GW.exe", 10, "\ ")
;
;   wrappedText would be assigned "C:\Games\`nGuild `nWars\`nGW.exe" because
;   maxCharactersPerLine was set to 10 and newline characters were added after
;   the nearest '\' and ' ' (break) characters. "after" doesn't need to be added
;   because it is the default break type.
;
; Example #2:
;   wrappedText := WrapText("C:\Games\Guild Wars\GW.exe", 10, "\ |.", "after|before")
;
;   wrappedText would be assigned "C:\Games\`nGuild `nWars\GW`n.exe" because
;   maxCharactersPerLine was set to 10 and newline characters were added after
;   the nearest '\' and ' ' (break) characters and before the nearest '.' character.

WrapText(textToWrap, maxCharactersPerLine := 80, breakCharacterSet := " ", breakCharacterSetType := "after", forceWrap := false) {
    GoSub, WrapText_Initialize

    ; Preserve double-line breaks, but re-wrap single-line breaks
    originalTextToWrap := textToWrap
    newWrappedText     := ""

    StringReplace, textToWrap, textToWrap, `n`n, ``, All
    StringSplit, inputTextLines, textToWrap, ``
    Loop, %inputTextLines0%
    {
        textToWrap := inputTextLines%a_index%

        ; Use the first specified wrap character instead of `n; `n characters seem to goof up
        ; the wrapping logic somewhere along the way.
        ; Also, try to prevent this conversion from creating two of the wrap character in a row
        wrapChar := SubStr(breakCharacterSet[1], 1, 1)
        StringReplace, textToWrap, textToWrap, %wrapChar%`n, %wrapChar%, All
        StringReplace, textToWrap, textToWrap, `n%wrapChar%, %wrapChar%, All
        StringReplace, textToWrap, textToWrap, `n, %wrapChar%, All

        GoSub, WrapText_BreakIntoLines

        GoSub, WrapText_CombineLines

        newWrappedText := newWrappedText "`n`n" wrappedText
    }
    StringTrimLeft, newWrappedText, newWrappedText, 2

    Return newWrappedText

    ; Makes sure all variables are user set or filled with defaults (where applicable)
    WrapText_Initialize:
        If(textToWrap = "")
            MsgBox, 48, WrapText Error, The 'textToWrap' (1st) parameter must be set.

        If maxCharactersPerLine is not integer
            MsgBox, 48, WrapText Error, The 'maxCharactersPerLine' (2nd) parameter must be a positive, non-zero integer.
        Else If(maxCharactersPerLine <= 0)
            MsgBox, 48, WrapText Error, The 'maxCharactersPerLine' (2nd) parameter must be a positive, non-zero integer.

        breakCharacterSet := StrSplit(breakCharacterSet, "|")
        breakCharacterSetType := StrSplit(breakCharacterSetType, "|")

        If(forceWrap != true AND forceWrap != false)
            MsgBox, 48, WrapText Error, The variable 'forceWrap' must be either true or false.

    Return

    ; Breaks the text into lines, as needed
    WrapText_BreakIntoLines:
        ; Chop off the ends of lines, to create new lines, until all lines are under the character limit
        WrapText_line      := Object()
        WrapText_line[1]   := textToWrap
        WrapText_lineCount := 1
        Loop
        {
            WrapText_currentLineNumber := A_Index
            WrapText_currentLineLength := StrLen(WrapText_line[WrapText_currentLineNumber])

            If(WrapText_currentLineLength <= maxCharactersPerLine)
                Break
            Else
            { 
                ; Loop through break character sets until a break character is found, or we run out of sets
                WrapText_breakCharacterPosition := -1
                Loop
                {
                    ; Search backwards from farthest possible character to find a break character
                    WrapText_currentBreakCharacterSet := A_Index

                    If((WrapText_breakCharacterPosition >= 0) OR ((breakCharacterSet[WrapText_currentBreakCharacterSet] = "") AND !forceWrap))
                        Break

;                    If((breakCharacterSet[WrapText_currentBreakCharacterSet] = "") AND forceWrap)
;                        WrapText_forceWrapTextToWrap := true
;                    Else WrapText_forceWrapTextToWrap := false

                    WrapText_forceWrapTextToWrap := forceWrap

                    If(breakCharacterSetType[WrapText_currentBreakCharacterSet] != "")
                        WrapText_currentBreakType := breakCharacterSetType[WrapText_currentBreakCharacterSet]
                    Else WrapText_currentBreakType := "after"

                    If(WrapText_currentBreakType == "after")
                        WrapText_currentPosition := maxCharactersPerLine
                    Else WrapText_currentPosition := maxCharactersPerLine + 1

                    Loop, %maxCharactersPerLine%
                    {
                        If(WrapText_forceWrapTextToWrap)
                            WrapText_breakCharacterPosition := 1
                        Else
                        {
                            WrapText_characterAtCurrentPosition := SubStr(WrapText_line[WrapText_currentLineNumber], WrapText_currentPosition, 1)
                            Loop
                            {
                                WrapText_currentBreakCharacterSet := A_Index
                                WrapText_breakCharacterPosition := InStr(breakCharacterSet[WrapText_currentBreakCharacterSet], WrapText_characterAtCurrentPosition)
                            }
                            Until WrapText_breakCharacterPosition OR breakCharacterSet[WrapText_currentBreakCharacterSet + 1] = ""
                        }

                        If(WrapText_breakCharacterPosition > 0)
                        {
                            WrapText_lineCount += 1
                            WrapText_currentBreakType := breakCharacterSetType[WrapText_currentBreakCharacterSet]

                            If(WrapText_currentBreakType == "before")
                            {
                                WrapText_line[WrapText_lineCount] := SubStr(WrapText_line[WrapText_currentLineNumber], WrapText_currentPosition )
                                WrapText_line[WrapText_currentLineNumber] := SubStr(WrapText_line[WrapText_currentLineNumber], 1, WrapText_currentPosition - 1 )
                            }
                            Else If(WrapText_currentBreakType == "eat")
                            {
                                WrapText_line[WrapText_lineCount] := SubStr(WrapText_line[WrapText_currentLineNumber], WrapText_currentPosition + 1)
                                 WrapText_line[WrapText_currentLineNumber] := SubStr(WrapText_line[WrapText_currentLineNumber], 1, WrapText_currentPosition - 1)
                            }
                            Else ; WrapText_currentBreakType == "after"
                            {
                                WrapText_line[WrapText_lineCount] := SubStr(WrapText_line[WrapText_currentLineNumber], WrapText_currentPosition + 1)
                                WrapText_line[WrapText_currentLineNumber] := SubStr(WrapText_line[WrapText_currentLineNumber], 1, WrapText_currentPosition)
                            }

                            Break
                        }

                        WrapText_currentPosition -= 1
                    }
                }
            }
        }
    Return

    ; Recombine the text into a single variable
    WrapText_CombineLines:
        wrappedText := ""
        Loop, %WrapText_lineCount%
            wrappedText := wrappedText "`n" WrapText_line[a_index]
        StringTrimLeft, wrappedText, wrappedText, 1
    Return
}