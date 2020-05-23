; Example wrapper for PCRE regular expressions: matching
; For details about PCRE see http://www.pcre.org or http://mushclient.com/pcre/
; Parameters:
;   string: where to search
;   offset: start offset in string; 0 means first byte
;   pattern: what to search, can be any PCRE compatible regex (see PCRE docs)
;   options: 1 does a case-insensitive match; 2 ignores newlines; 3 does both
;   res: result of the search. This is a string that contains pairs of
;   integers. The first integer of each pair is an offset into string; the
;   second is the length of the found item. The first pair is always the
;   whole found string; further pairs are captured substrings (see PCRE docs)
;   The list of matches is always terminated by a pair of -1 -1.
; Return value: negative in case of an error, or 0 if nothing was
; found, or the actual number of matches (captured substrings).
RE_Match(string,offset,pattern,options,ByRef res)
{
  ; IMPORTANT: reserve space for the result string (if you expect a very
  ; large number of captured substrings tempres needs to be made bigger than
  ; 512 bytes)
  VarSetCapacity(tempres,512)
  ; call the DLL function
  i:=DllCall("pcreahk.dll\pcre_match","str",string,"int",offset,"str",pattern,"int",options,"str",tempres)
  If (i<0)
    ; error, probably something wrong with the pattern (see PCRE docs
    ; for details and the error codes)
    res:="e " . i
  Else If (i=0)
    ; no match was found
    res:="-1 0"
  Else
    ; at least one match was found
    res:=tempres
  VarSetCapacity(tempres,0)
  Return i
}

hModule:=DllCall("LoadLibrary","str","pcreahk.dll","UInt")
p:="simple"
s:="a simple test, really simple"
o:=0
; should find first simple
If (RE_Match(s,o,p,0,r)>0)
{
  StringSplit, x, r, %A_Space%
  StringMid f, s, x1+1, x2
  MsgBox result of RE_Match: %r%, found: %f%
}
Else
  MsgBox Error: %r%

; get new offset as start of match (x1) plus length (x2) and
; search again
o:=x1+x2
If (RE_Match(s,o,p,0,r)>0)
{
  StringSplit, x, r, %A_Space%
  StringMid f, s, x1+1, x2
  MsgBox result of RE_Match: %r%, found: %f%
}
Else
  MsgBox Error: %r%

; Let's have some fun: this matches standard URLs (a bit simplistic: this
; is just an example) and should produce four captured substrings:
; protocol and the three components of the URL.
; If you have no idea what the expression in p means or what a
; captured substring is, check the PCRE docs.
p:="^(http|ftp)://([-[:alnum:]]+)\.([-[:alnum:]]+)\.([A-Za-z]{2,4})$"
s:="http://www.google.com"
If (RE_Match(s,0,p,0,r)>0)
{
  MsgBox result of RE_Match: %r%
  StringSplit, x, r, %A_Space%
  i:=1
  loop
  {
    j:=i+1
    StringMid f, s, x%i%+1, x%j%
    MsgBox Found: %f%
    i:=i+2
    If (i=x0-1)
      Break
  }
}
Else
  MsgBox Error: %r%
DllCall("FreeLibrary","UInt",hModule)
Return

