; Example wrapper for PCRE regular expressions: replacing
; For details about PCRE see http://www.pcre.org or http://mushclient.com/pcre/
; Parameters:
;   string: where to replace
;   offset: start offset in string; 0 means first byte
;   pattern: what to search, can be any PCRE compatible regex (see PCRE docs)
;   options: 1 does a case-insensitive match; 2 ignores newlines; 3 does both
;   replace: the replacement, can be any string. There are a few special
;   cases: ${ refers to everything in string before the found item(s); $} to
;   everything after the found item(s); $0 is the whole found string; $1 to $9
;   refer to captured substrings (again, the details are in the PCRE docs).
; Return value: negative in case of an error (codes in the PCRE docs), or 0
; if nothing was replaced, or 1 if something was replaced.
RE_Replace(ByRef string,offset,pattern,options,replace)
{
  ; IMPORTANT: reserve enough space for the complete replacement string!
  VarSetCapacity(tempres,1024)
  tempres:=string
  ; call the DLL function
  i:=DllCall("pcreahk.dll\pcre_replace","str",tempres,"int",offset,"str",pattern,"int",options,"str",replace)
  If (i>0)
    ; at least one replacement was done, copy result back
    string:=tempres
  VarSetCapacity(tempres,0)
  Return i
}

hModule:=DllCall("LoadLibrary","str","pcreahk.dll","UInt")
p:="simple"
s:="a simple test, really simple"
o:=0
r:="${very simple$}"
e:=RE_Replace(s,o,p,0,r)
if (e>0)
  MsgBox result of RE_Replace: %s%
Else
  MsgBox Error: %e%

; jump over the first "simple"
o:=InStr(s,p)+StrLen(p)-1
e:=RE_Replace(s,o,p,0,r)
if (e>0)
  MsgBox result of RE_Replace: %s%
Else
  MsgBox Error: %e%

; Three captured substrings: 2 ts with at least 1 digit in between,
; then anything, and again 2 ts with at least 1 digit in between.
; If p looks like Greek to you, check the PCRE docs.
p:="(t[0-9]+t)(.*)(t[0-9]+t)"
s:="begin_t88888888t_middle_t123t_end"
r:="$}[[$3]]--[[$2]]--[[$1]]${"
e:=RE_Replace(s,0,p,0,r)
if (e>0)
  MsgBox result of RE_Replace: %s%
Else
  MsgBox Error: %e%

; Three captured substrings: a word, a colon surrounded by whitespace
; and another word
p:="(\w+)(\s+:\s+)(\w+)"
s:="left :   right"
r:="original was: ""$0"";  replacement is: ""$3$2$1"""
e:=RE_Replace(s,0,p,0,r)
if (e>0)
  MsgBox result of RE_Replace: %s%
Else
  MsgBox Error: %e%
DllCall("FreeLibrary","UInt",hModule)
Return

