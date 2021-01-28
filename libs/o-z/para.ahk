/*
Title: para - Paragraph beautifier
    Word processing unit for homogenous display of paragraphs.

Group: License
    New BSD License

Copyright (c) 2010, Tuncay
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Tuncay nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Tuncay BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Group: Introduction
    This library offers basic reformatting of text. It is for reformatting text
    consisting of words, sentences and optionally paragraphs. The result would
    fit within specified line width or flowing continuesly on one line.
    
    This is explicitly not designed for formatting software source code, as it 
    would destroy the code. Also the single para() function is not thought for 
    whole files, unless someone knows what he is doing.

Links:
    * Lib Home: [http://autohotkey.net/~Tuncay/lib/index.html]
    * Download: [http://autohotkey.net/~Tuncay/lib/para.zip]
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?t=63466]
    * License: [http://autohotkey.net/~Tuncay/licenses/newBSD_tuncay.txt]
    
Date:
    2010-10-10

Revision:
    1.0

Developers:
    * Tuncay (Author)
    
Category:
    String Manipulation

Type:
    Library

Standalone (such as no need for extern file or library):
    Yes

StdLibConform (such as use of prefix and no globals use):
    Yes
    
About: Examples
    This variable is used as input in following examples.
    (start code)
text =
(
Lorem  ,ipsum dolor sit amet,   consectetuer adipiscing elit. curabitur dignissim
venenatis pede. quisque dui dui,    ultricies ut, facilisis non, pulvinar non,


    purus:

        duis quis arcu a purus volutpat iaculis. Morbi id dui in diam ornare
dictum.                                     Praesent consectetuer       vehicula ipsum. praesent tortor massa, congue et,ornare  in, posuere eget , pede.
)

    (end)

Example 1:
    Set line width to 79 and preserve identified paragraphs. And indent the first line. Also reformat some characters around punctuations.
    > text := para(text, 79, 1, true, 1)
    
    *Output:*
    (start code)
    Lorem, ipsum dolor sit amet, consectetuer adipiscing elit. Curabitur
dignissim venenatis pede. Quisque dui dui, ultricies ut, facilisis non,
pulvinar non,

    Purus:

    Duis quis arcu a purus volutpat iaculis. Morbi id dui in diam ornare
dictum. Praesent consectetuer vehicula ipsum. Praesent tortor massa, congue
et, ornare in, posuere eget, pede.
    (end)
*/

/*
Group: Functions
*/

/*
Function: para
    Reformats one or more paragraphs.

Parameters:
    text <str>              - Input string to modify.
    
    lineWidth <int>         - The width of a line, at which point a line break 
        should be inserted. 0 is the default value and means no line break, just 
        one single huge line. Very common are values of 80 or 79,because these 
        are often used terminal widths. No limit means at this point a limit of
        16777216 (256*256*256) characters per line.
    
    align <0|1|2|3>         - The mode how the lines should be aligned, to the 
        width specified with lineWidth. The names and the values can be used: 0=left 
        (default), 1=indent, 2=right, 3=center, Note: Any other value defaults to 
        standard "left" mode. And "right" and "center" have only an effect, if 
        lineWidth is greater than 0.
    
    paragraphs <0|1>        - If set to true, then individual paragraphs 
        separated by at least two newlines are identified and preserved, otherwise 
        one single paragraph is generated. Default is true (which is same as "1").
    
    reformPunct <0|1|2>     - Reformats some common puncuations. If this is set 
        to true (or 1), then whitespaces around the characters "[,.!?;:]" are cutted, 
        and one space is added after them. And after these characters "[.!?;:]" 
        (same as before, but without comma) the next alphabetical character will 
        be made upper case. If the parameter is set to "2", then an second space 
        is added after sentence characters "[.!?]". 0 will not touch this. Defaults
        to 1.
    
    hardReturn <0|1>        - If this is set to true or "1", then single CR "`r"
        are interpreted as "force newline" at that position. This is the default. 
        Otherwise, they will be just treated as whitespace.
    
    newline <str>           - This is an alternate newline character sequence. Any 
        character combination could be made. Default is "`n", also known as LF (Line 
        feed).
    
    indentFirstLine <str>   - This is needed only in case the align mode is set to 
        "indent" or "1". Then this string sequence is added in front of each known 
        paragraph. Default are four spaces in row.

Return:
    Returns the modfied string. At default all paragraphs are left justified, 
    (virtually) no limit per line and broken by two newline characters.

ErrorLevel:
    ErrorLevel is changed unconditionally.

Example:
    > MsgBox % para(text)

Remarks:    
    Spaces are compacted into one space.
    
    The two common newline types LF and CRLF are accepted as line breaks in input 
    source. CR on its own (without following LF) will be interpreted as hard return 
    at that position, on default. Output have consistent LF ("`n").
    
    Words with a huge size make problems. They are not broken and could exceed the 
    lineWidth.
*/
para(_text, _lineWidth=0, _align=0, _paragraphs=true, _reformPunct=0, _hardReturn=true, _newline="`n", _indentFirstLine="    ")
{
    Static s_indent := ""
    
    ; Normalize current threads settings.
    backupAutoTrim:=A_AutoTrim
    AutoTrim, Off
    backupStringCaseSense:=A_StringCaseSense
    StringCaseSense, Off
    
    ; Set this static variable once
    If (s_indent = "")
    {
        s_indent := Chr(02) ; STX, Start of text: Begin of first character on paragraph.
    }
    ; Some default settings and verifications
    If (_lineWidth = 0)
    {
        _lineWidth := 16777216
    }
    
    ; Normalize newline type to `n or remove all
    IfInString, _text, `r
    {
        StringReplace, _text, _text, `r`n, `n, All
        If (_hardReturn = false)
        {
            StringReplace, _text, _text, `r, %A_Space%, All
        }
    }
        
    If (_paragraphs)
    {
        _text := RegExReplace(_text, "S)(?: *\n( )*){2,}", "$1`r`r")
    }
    
    ; Compact spaces
    _text := RegExReplace(_text, "Sm`a)^ +", "") 
    _text := RegExReplace(_text, "Sm`n) {2,}", " ") 
        
    ; Set indent variables
    If (_align = 1 || _align = "indent")
    {
        WidthIndentFirstLine := StrLen(_indentFirstLine)
        wfl := WidthIndentFirstLine
    }
    else
    {
        _indentFirstLine := ""
        wfl := WidthIndentFirstLine := 0
    }
    
    ; Joins all lines
    _text := RegExReplace(_text, "S)(?:\s*\n)+", " ") 
    
    ; Prepare variables size for performance boost
    VarSetCapacity(output, StrLen(_text))
    VarSetCapacity(buf, _lineWidth)
    VarSetCapacity(op, _lineWidth)
    buf := ""
    output := ""
    op := ""
    
    spaceWidth := 1    
    Loop, Parse, _text, `r, `r
    {
        p := A_LoopField
        op := ""
        buf := ""
        
        ; Reformat some punctuations
        If (_reformPunct)
        {
            p := RegExReplace(p, "S)[ \n]?(,)[ \n]*", "$1 ")
            p := RegExReplace(p, "S)([.!?;:]) ?(\w?)", "$1 $U2") 
            p := RegExReplace(p, "S)^(\w?)", "$U1") 
            If (_reformPunct = 2)
            {
                p := RegExReplace(p, "S)([.!?]) ", "$1  ") 
            }
        }
        
        p := s_indent . p
        wfl := WidthIndentFirstLine
        
        ; Idea from http://en.wikipedia.org/wiki/Word_wrap#Algorithm
        spaceLeft := _lineWidth - wfl
        Loop, Parse, p, %A_Space%, %A_Space%
        {
            width := StrLen(A_LoopField)
            If (buf != "" && (bufwidth := StrLen(buf)) < spaceLeft - 1)
            {
                op .= buf
                buf := ""
            }
            If (width > spaceLeft - 1)
            {
                op .= buf . "`n" . A_LoopField
                buf := ""
                spaceLeft := _lineWidth - width - 1 ; 1=General toleranceWidth
                wfl := 0
            }
            else
            {
                buf .= " " . A_LoopField
                spaceLeft := spaceLeft - (width + 1) ; 1=spaceWidth
            }
        }
        output .= "`n" . RegExReplace(op . buf, "Sm)^ *| *$")
    }
    StringTrimLeft, output, output, 1 ; First newline
    
    If (_indentFirstLine != "")
    {
        output := RegExReplace(output, "Sm`n)^" . s_indent, _indentFirstLine)
    }
    StringReplace, output, output, %s_indent%,, All
    
    If (_lineWidth != 16777216 && _paragraphs)
    {
        StringReplace, output, output, `r, `n, All
    }

    ; Delete all space only lines
    output := RegExReplace(output, "Sm`n)^\s+$")
    
    If (_align && _lineWidth != 16777216)
    {
        If (_align = 2 || _align = "right")
        {
            _text := ""
            Loop, Parse, output, `n
            {
                line = %A_LoopField%
                spaces := ""
                Loop, % _lineWidth - 1 - StrLen(line)
                {
                    spaces .= A_Space
                }
                line := spaces . line
                _text .= line . "`n"
            }
            output := _text
        }
        Else If (_align = 3 || _align = "center")
        {
            _text := ""
            Loop, Parse, output, `n
            {
                line = %A_LoopField%
                spaces := ""
                Loop, % (_lineWidth - StrLen(line)) // 2
                {
                    spaces .= A_Space
                }
                line := spaces . line . spaces
                _text .= line . "`n"
            }
            output := _text
        }
    }
    
    ; Use custom newline
    If (_newline != "`n")
    {
        StringReplace, output, output, `n, %_newline%, All
    }
    
    ; Restore settings for current thread.
    AutoTrim, %backupAutoTrim%
    StringCaseSense, %backupStringCaseSense%
    
    return output    
}
