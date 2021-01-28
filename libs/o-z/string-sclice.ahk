; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=84241&sid=0222974d09410259df94520d0a3b70ba
; Author:
; Date:
; for:     	AHK_L

/*


*/

#singleInstance force
msgBox % (s:= 454212556) ":`n"  s1(s) "`n"  s2(s) "`n"  s3(s) "`n"  s4(s) "`n"  s5(s) "`n"  s6(s) "`n"  s7(s) "`n"  s8(s)
msgBox % (s:= 4542125567) ":`n"  s1(s) "`n"  s2(s) "`n"  s3(s) "`n"  s4(s) "`n"  s5(s) "`n"  s6(s) "`n"  s7(s) "`n"  s8(s)
msgBox % (s:= "ABCDEFGJIJK3941846") ":`n"  s1(s) "`n"  s2(s) "`n"  s3(s) "`n"  s4(s) "`n"  s5(s) "`n"  s6(s) "`n"  s7(s) "`n"  s8(s)

s1(maxindexzz, ch:= ".", p:=3) { ; littlegandhi1199 - https://www.autohotkey.com/boards/viewtopic.php?p=158667#p158667
    sometzzzz := StrLen(maxindexzz)
    sometzzzz /= p
    sometzzzz := Floor(sometzzzz)
    loop
    {
        if (A_Index > sometzzzz)
        {
            if (StrLen(maxindexzz) > 0)
                lovesmax = %maxindexzz%%ch%%lovesmax%
            break
        }
        stringtrimleft, maxindexzze, maxindexzz, % StrLen(maxindexzz)-p
        stringtrimright, maxindexzz, maxindexzz, %p%
        lovesmax = %maxindexzze%,%lovesmax%
    }
    stringtrimright, lovesmax, lovesmax, 1

    Return % lovesmax
}

s2(n, ch:= ".", p:= 3) { ; RRR - https://www.autohotkey.com/boards/viewtopic.php?p=358893#p358893
    loop, Parse, n
        sT.= A_LoopField (Mod(A_Index, p)-Mod(StrLen(n), p)? "": ch)
    Return RTrim(sT, ch)
}

s3(n, ch := ".") { ; Algumist "Find in Files.ahk" (part of AutoGUI v2.6.2 in Tools) -  https://sourceforge.net/projects/autogui/files/latest/download
/*
    If (n > 999) {
        n /= 1024
        Unit := " K"
    } Else {
        Unit := " B"
    }
*/
    a := ""
    Loop % l:=StrLen(n) {
        a .= SubStr(n, 1 - A_Index, 1)
        If (Mod(A_Index, 3) == 0 && A_Index < l) {
            a .= ch
        }
    }

    a := Trim(a) ;, ch)

    b := ""
    Loop % StrLen(a) {
        b .= SubStr(a, 1 - A_Index, 1)
    }

    Return b . Unit
}

s4(str, ch:=",", gr:=3){ ; watagan - https://www.autohotkey.com/boards/viewtopic.php?p=369296#p369296
	if (gr >= strLen(str))
		return str
	s := strSplit(str)
	for j in s
		gg := mIdx := a_index, k := 0
	for j in s
		i := s[mIdx--], k++, (k = gr) && !(a_index = gg) ? (p := ch, k := 0) : (p := ""), l := p . i . l
	return l
}

s5(str, ch:=",", gr:=3){ ; HotKeyIt - https://www.autohotkey.com/boards/viewtopic.php?p=369297#p369297
    Loop % len:=StrLen(str)
        res:=(!Mod(A_Index,gr) ? ch : "") SubStr(str,len-A_Index+1,1) res
    return LTrim(res,ch)
}

s6(list, count:=3){ ; by berban
	/*
		============================================================================
		Add comma grouping to large numbers
		============================================================================
		by berban
		https://autohotkey.com/board/topic/72207-complex-regex-collection-donations-wanted/
		INPUT:
		Any string containing numbers
		OUTPUT:
		All numbers valued over 1000 will contain comma separators
		EXAMPLES:
		45000             > 45,000
		-170000.2040      > -1,700,000.2040
		It cost $2050 USD > It cost $2,050 USD
		HISTORY
		Gogo (http://www.autohotkey.com/forum/viewtopic.php?t=29596) - October 11, 2011: Full string support
		Laszlo, infogulch, others - 10/8/2011
	*/
	return RegExReplace(list, "(?:^[^1-9.]*[1-9]\d{0,2}|(?<=.)\G\d{" count "})(?=(?:\d{" count "})+(?:\D|$))", "$0,")
}

S7(ByRef Lst, Len := 3, Sep := ",", EOL := "`r`n") { ; by just me - https://www.autohotkey.com/boards/viewtopic.php?p=369876#p369876
   LstLen := StrLen(Lst)
   Extra  := Ceil(LstLen / Len)
   S1 := (EOL = "`r`n") ? "`n" : EOL
   S2 := (EOL = "`r`n") ? "`r" : ""
   VarSetCapacity(Out, (LstLen + Extra) << !!A_IsUnicode)
   Out := ""
   Loop, Parse, Lst, %S1%, %S2%
      Out .= (Out ? EOL : "") . Slice_Str(A_LoopField, Len, Sep)
   Return Out
}
Slice_Str(ByRef Str, Len := 3, Sep := ",") {
   Return LTrim(SubStr(Str, 1, (L := Mod(StrLen(Str), Len))) . RegExReplace(SubStr(Str, L + 1), ".{" . Len . "}", Sep . "$0"), Sep)
}

s8(list, ch:=".", p:=3, k:=1) { ; by RRR - https://www.autohotkey.com/boards/viewtopic.php?p=369948#p369948
    Return RegExReplace(list, "`a)(.{" (k? 1: p) "})(?=(.{" (k? p: 1) "})+(?!.))", "$0" ch)
}