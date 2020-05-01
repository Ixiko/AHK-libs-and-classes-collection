; function by SKAN 31-Mar-2020
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=74050

xStr(ByRef H, C:=0, B:="", E:="", ByRef BO:=1, EO:="", BI:=1, EI:=1, BT:="", ET:="") {          ; for general text extraction and parsing XML / HTML

	/* What xStr() can do?

		xStr() is a wrapper for SubStr(). It was written mainly to parse structured text like XML, HTML etc
		A sub string can be extracted from text by using SubStr() with staring position and Length parameters..

	*/

	/*	Parameter names expanded
		H = Haystack
		C = Case sensitivity (for B,E)
		B = Begin match
		E = End match
		BO = Begin offset
		EO = End offet
		BI = Begin instance
		EI = End instance
		BT = Begin (un)trim
		ET = End (un)trim
	*/

	/* xStr() help

			xStr() requires an overwhelming 10 parameters because, SubStr() requires 3 and Instr() requires 5 and also, xStr() could call InStr() twice.

			The parameters for both the functions from documentation,
			NewStr := SubStr(String, StartingPos , Length)
			FoundPos := InStr(Haystack, Needle , CaseSensitive := false, StartingPos := 1, Occurrence := 1)

			xStr() parameters are H, C, B, E, BO, EO, BI, EI, BT, ET

			Parameter H (Haystack) is common for both calls. It is passed as String parameter for SubStr() and as Haystack parameter for InStr() calls
			Parameter C (Case sensitivity) is passed to InStr() either for B (Begin match) or E (End match) or both.
			Valid flags are 0,1,2,3 (Use hex values for readability.)

			0 or 0x0 ( Bits 00 ) Neither are case sensitive (Default value)
			1 or 0x1 ( Bits 01 ) Begin match is case sensitive
			2 or 0x2 ( Bits 10 ) End match is case sensitive
			3 or 0x3 ( Bits 11 ) Begin/End matches are case sensitive
			Parameters B,E (Begin match,End match) will be passed to respective InStr() calls as needle parameter
			Errorlevel: When Begin match/End match (either or both) is/are specified and match fails, ErrorLevel is set to 1
			Parameter BO is passed as StartingPos to SubStr() when parameter B (Begin match) is null or to Instr() otherwise
			BO is a ByRef parameter. xStr() will update the var whenever applicable.
			Code: Select all - Toggle Line numbers

			P := 19                  ; Starting position
			MsgBox % xStr(H,,,,P,7)  ; Extract 7 chars fron starting position
			MsgBox % P               ; Starting postion has been updated
			Parameter EO is passed as Length to SubStr() when parameter E (End match) is null or to Instr() as StartingPos otherwise
			Parameters BI,EI (Begin instance and End instance) are passed to respective Instr() calls as Occurance

			Parameters BT,ET (Begin trim, End trim) are used for computing the final length of resultant string.
			A positive value will trim and a negative value will untrim (expand) the resulting string.
			When parameters B,E,B0,EO are omitted, these parameters will simulate the deprecated commands StringTrimLeft and StringTrimRight.

	*/

	Local L, LB, LE, P1, P2, Q, F:=0 ; xStr v0.97_dev by SKAN on D1AL/D343 @ tiny.cc/xstr

	P1 := ( L := StrLen(H) )
			  ? ( LB := StrLen(B) )
						? ( F := InStr(H, B, C&1, BO, BI) )
							 ? F+(BT="" ? LB : BT)
							 : 0
			  : ( Q := (BO=1 && BT>0 ? BT+1 : BO>0 ? BO : L+BO) )>1 ? Q : 1
		  : 0


	P2 := P1
			  ?  ( LE := StrLen(E) )
						? ( F := InStr(H, E, C>>1, EO="" ? (F ? F+LB : P1) : EO, EI) )
							 ? F+LE-(ET="" ? LE : ET)
							 : 0
			  : EO="" ? (ET>0 ? L-ET+1 : L+1) : P1+EO
		  : 0

Return SubStr(H, !( ErrorLevel := !((P1) && (P2)>=P1) ) ? P1 : L+1, ( BO := Min(P2, L+1) )-P1)
}