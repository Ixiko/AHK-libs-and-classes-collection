;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=74948
;NotStr(Value, Delimited list of unique values, Delimiter)
;NotStr() is a wrapper for SubStr()

;neogna2 wrote:
;The NotStr function cycles to the next value in a set of values, wrapping around the end.
;First parameter is a value in the set.
;Second parameter is the set, a string of delimited values.
;Third parameter (optional) is for changing the default delimiter "|".
;Examples:
;NotStr("B", "A|B|C") returns "C".
;NotStr("C", "A|B|C") returns "A" (wrap around)

;Edit: Worth pointing out also that the values in the set must be unique, otherwise the function does not cycle in the way one might expect.

NotStr(S:="", Z:="", D:="|") { ; NotStr v0.6a By SKAN on D34M/D34R @ tiny.cc/notstr
Local Q, LS:=StrLen(S), LZ:=StrLen(Z), LD:=StrLen(D), P1, P2, Q

  P1  := LS+LZ=0 || S=Z
            ? 1
      : InStr(Z,(S)(D),0,0-LZ+LS+LD)
            ? LS+LD+LD
      :  InStr(Z,(D)(S),0,LZ-LS)
            ? 1
      :  ( Q := InStr(Z,(D)(S)(D)) )
            ?  Q+LD+LS+LD
      :  1

  P2  := LS+LZ=0 ? 2 : S=Z ? 1 : ( Q := InStr(Z,D,0,P1) ) ? Q : LZ+1

Return SubStr(LZ ? Z : 1, (P1), (P2)-P1)
}