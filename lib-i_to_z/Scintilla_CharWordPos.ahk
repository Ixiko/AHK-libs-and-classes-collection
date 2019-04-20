;#include <RemoteScintilla>

;~ SetFormat,integer,h


;~ n := StrPutVar("■", UTF8, "UTF-8")
;~ MsgBox % n-1
;~ ExitApp

;~ MsgBox % MultiByteChars("一二三四五")

;~ controlget,hwnd,hwnd,,Scintilla1,simple RIS
;~ s:=new RemoteScintilla(hwnd)
;~ MsgBox % StrPut("■", "utf-8")
;~ MsgBox % Asc("■")
;~ s._setsel(0,8)
;~ ExitApp

;~ UTF16 := "■" 
;~ n := StrPutVar(UTF16, UTF8, "UTF-8")
;~ MsgBox % MCode_Bin2Hex(&UTF8, n-1)
MCode_Bin2Hex(addr, len) {
    Static fun
    If (fun = "") {
        If Not A_IsUnicode
        h=
        ( LTrim Join
            8B54240C85D2568B7424087E3A53578B7C24148A07478AC8C0E90480F9090F97C3F6
            DB80E30702D980C330240F881E463C090F97C1F6D980E10702C880C130880E464A75
            CE5F5BC606005EC3
        )
        Else
        h=
        ( LTrim Join
            8B44240C8B4C240485C07E53568B74240C578BF88A168AC2C0E804463C090FB6C076
            066683C037EB046683C03066890180E20F83C10280FA09760C0FB6D26683C2376689
            11EB0A0FB6C26683C03066890183C1024F75BD33D25F6689115EC333C0668901C3
        )
        VarSetCapacity(fun, n := StrLen(h)//2)
        Loop % n
            NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
    }
    VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
    DllCall(&fun, "uint", &hex, "uint", addr, "uint", len, "cdecl")
    VarSetCapacity(hex, -1) ;update StrLen
    Return hex
}

;~ MsgBox % MultiByteChars("■")
;~ MsgBox % Asc("■") "," ord("■")
;~ ExitApp
MultiByteChars(ByRef str){
	a:=0
	Loop,Parse,str
		;~ a+= (c:=Asc(A_LoopField))>0xFFFFFF?4:c>0xFFFF?3:c>0xFF?2:1
		a+= StrPutVar(A_LoopField, UTF8:="", "UTF-8")-1
	return a
}

CharToWordPos(ByRef str, ByRef start, ByRef end="", swap=0){
	if(End="")
		End:=start
	
	if(start>End)
		return CharToWordPos(str, End, start, 1)
	
	_start:=_end:=""

	CharPos:=0
	Loop,Parse,str
	{
		if (CharPos>start && CharPos>End)
			break
		;~ CharPos+= Asc(A_LoopField)<=0xFF?1:Asc(A_LoopField)<=0xFFFF?2:Asc(A_LoopField)<=0xFFFFFF?3:4
		CharPos+= StrPutVar(A_LoopField, UTF8, "UTF-8")-1
		if (CharPos>=start && _start="")
			_start:=A_Index
		if (CharPos>=End && _end="")
			_End:=A_Index
		ind:=A_Index
	}
	if(!swap)
		start:=_start?_start:ind, End:=_end?_end:ind
	else
		start:=_end?_end:ind, End:=_start?_start:ind

}

WordToCharPos(ByRef str, ByRef start, ByRef end="", swap=0){
	if(End="")
		End:=start
	
	if(start>End)
		return WordToCharPos(str, End, start, 1)
	
	_start:=_end:=""
	;~ ,CharPos:=0
	
	_start:=MultiByteChars(SubStr(str, 1, start)), _End:=_start+MultiByteChars(SubStr(str, start+1, End-start))
	
	if(!swap)
		start:=_start, End:=_End
	else
		start:=_End, End:=_start
	return
	/*
	Loop,Parse,str
	{
		if (A_Index>start && A_Index>End)
			break
		;~ CharPos+= Asc(A_LoopField)<=0xFF?1:Asc(A_LoopField)<=0xFFFF?2:Asc(A_LoopField)<=0xFFFFFF?3:4
		CharPos+= StrPutVar(A_LoopField, UTF8, "UTF-8")-1
		if (A_Index=start && _start="")
			_start:=CharPos
		if (A_Index=End && _end="")
			_End:=CharPos
	}
	start:=_start?_start:CharPos, End:=_end?_end:CharPos
	*/
}