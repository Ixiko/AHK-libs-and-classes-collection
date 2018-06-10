; StrTail: Return the last lines of string by Tuncay
; http://www.autohotkey.com/forum/viewtopic.php?p=262371#262371
; Creative Commons Attribution 3.0 Unported, http://creativecommons.org/licenses/by/3.0/
strTail(_Str, _LineNum = 1)
{
    StringGetPos, Pos, _Str, `n, R%_LineNum%
    StringTrimLeft, _Str, _Str, % ++Pos
    Return _Str
}

; Here is one getting last line only and optimized for speed.
strTail_last(ByRef _Str) {
    Return SubStr(_Str,InStr(_Str,"`n",False,0)+1)
}
