
;nifty conversion functions collection by infogulch
;http://www.autohotkey.com/forum/viewtopic.php?t=32693&highlight=encuri

;#########################################################################################
;XML encode/decode by infogulch  -  this might be handy for use with xpath by titan
;About: http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references

Dec_XML(str)
{ ;Decode xml required characters, as well as numeric character references
   Loop
      If RegexMatch(str, "S)(&#(\d+);)", dec)                  ; matches:   &#[dec];
         StringReplace, str, str, %dec1%, % Chr(dec2), All
      Else If   RegexMatch(str, "Si)(&#x([\da-f]+);)", hex)         ; matches:   &#x[hex];
         StringReplace, str, str, %hex1%, % Chr("0x" . hex2), All
      Else
         Break
   StringReplace, str, str, &nbsp;, %A_Space%, All
   StringReplace, str, str, &quot;, ", All         ;required predefined character entities &"<'>
   StringReplace, str, str, &apos;, ', All
   StringReplace, str, str, &lt;,   <, All
   StringReplace, str, str, &gt;,   >, All
   StringReplace, str, str, &amp;,  &, All         ;do this last so str doesn't resolve to other entities
   return, str
}

Enc_XML(str, chars="")
{ ;encode required xml characters. and characters listed in Param2 as numeric character references
   StringReplace, str, str, &, &amp;,  All         ;do first so it doesn't re-encode already encoded characters
   StringReplace, str, str, ", &quot;, All         ;required predefined character entities &"<'>
   StringReplace, str, str, ', &apos;, All
   StringReplace, str, str, <, &lt;,   All
   StringReplace, str, str, >, &gt;,   All
   Loop, Parse, chars
      StringReplace, str, str, %A_LoopField%, % "&#" . Asc(A_LoopField) . "`;", All
   return, str
}

;#########################################################################################
;uri encode/decode by Titan
;Thread: http://www.autohotkey.com/forum/topic18876.html
;About: http://en.wikipedia.org/wiki/Percent_encoding
;two functions by titan: (slightly modified by infogulch)

Dec_Uri(str)
{
   Loop
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      Else Break
   Return, str
}

Enc_Uri(str)
{
   f = %A_FormatInteger%
   SetFormat, Integer, Hex
   If RegExMatch(str, "^\w+:/{0,2}", pr)
      StringTrimLeft, str, str, StrLen(pr)
   StringReplace, str, str, `%, `%25, All
   Loop
      If RegExMatch(str, "i)[^\w\.~%/:]", char)
         StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
      Else Break
   SetFormat, Integer, %f%
   Return, pr . str
}


;#########################################################################################
; - String2hex, Laszlo (there are various versions (hexify) on the forum
;   http://www.autohotkey.com/forum/topic4934-15.html#158672
;   search the forum, also by Rajat if you are interested)
;   I just fiddled around a bit until I got the results I wanted :-)
;   Not all hexify version work with ASCII 1 - 15, this one does

Enc_Hex(x) ;originally: String2Hex(x) ; Convert a string to hex digits (modified to accommodate new line chars)
{
   prevFmt = %A_FormatInteger%
   SetFormat Integer, H ; this function requires hex format
   Loop Parse, x
      hex .= 0x100+Asc(A_LoopField)
   StringReplace hex, hex, 0x1,,All
   SetFormat Integer, %prevFmt% ; restore original integer formatting
   Return hex
}

Dec_Hex(x) ;originally: Hex2String(x) ; Convert a huge hex number to string (modified to suit String2Hex above)
{
   Loop % StrLen(x)/2
   {
      Pos:=(A_Index-1)*2+1
      StringMid hex, x, Pos, 2
      string := string . Chr("0x" hex)
   }
   Return string
}
