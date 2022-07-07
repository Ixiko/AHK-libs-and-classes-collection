; This is a library created by TheArkive
; Posted on AutoHotKey Forum


; ======================================================
; GetLastLine(sInput) - does just that
; ======================================================
GetLastLine(sInput:="") {
	sInput := Trim(sInput,OmitChars:=" `r`n"), i := 0
	Loop Parse sInput, "`r", "`n"
		i++
	Loop Parse sInput, "`r", "`n"
	{
		If (A_Index = i)
			lastLine := A_LoopField
	}
	return lastLine
}

; ======================================================
; eval(input,params*)
; ======================================================
;	This will evaluate a literal string given to it.  All `` are replaced with ".
;	Global vars are processed automatically.  Local vars need to be passed as an
;	associative array like so:
;
;			Map() is for AHK v2 / Object() is for AHK v1
;
;		myParams  := Map/Object("localVar1",localVar1,"localVar2",localVar2,...)
;		newString := eval(phrase,myParams*)
; ======================================================

eval(sInput,params*) {
	sInput := StrReplace(sInput,"``",Chr(34))	; replace `` with "
	arr := StrSplit(sInput,Chr(37))
	
	For k, v in arr {
		q := Mod(A_Index,2)						; even index are the variables
		If (q) {
			sOutput .= v
		} Else {
			t := %v%							; translate variable (which can be global or built in)
			If (t)
				sOutput .= t					; if matched, replace
			Else
				sOutput .= Chr(37) v Chr(37)	; else put it back ; chr(37) = "%"
		}
	}
	
	For index,param in params
		rpl := Chr(37) index Chr(37), sOutput := StrReplace(sOutput,rpl,param)
	
	return sOutput
}

; ======================================================
noPar(sInput) { ; remove parenthesis
	len := StrLen(sInput), StrR := SubStr(sInput,len), StrL := SubStr(sInput,1,1)
	
	If (StrR = ")") And (StrL = "(")
		Result := SubStr(sInput, 2, -1)
	Else
		Result := sInput
	return Result
}

par(InText) { ; add parenthesis
    return "(" InText ")"
}

; ======================================================
; DurationDisp(sInput,Type="col")
; ======================================================
; 		sInput is any integer or decimal
;		Type = "col" returns "hh:mm:ss.000" format
;		Type = "hms" returns "00h 00m 00s" format (no decimal
; ======================================================

DurationDisp(sInput,Type:="col") { 
    Loop Parse sInput, "."
    {
        If (A_Index = 1)
            CurInt := A_LoopField
        else if (A_Index = 2)
            Dec := A_LoopField
    }
    
    If (Dec = "")
        Dec := "000"
    
    CurMin := CurInt / 60
    
    Loop Parse CurMin, "."
    {
        If (A_Index = 1)
            CurMin := A_LoopField
    }
    
    CurSec := CurInt - (CurMin * 60)
    CurHrs := CurMin / 60
    
    Loop Parse CurHrs, "."
        If (A_Index = 1)
            CurHrs := A_LoopField
    
    If (CurMin >= 60)
        CurMin := CurMin - (CurHrs * 60)
    
    If (Type = "col") {
        CurSec := Format("{1:02d}",CurSec)
        CurMin := Format("{1:02d}",CurMin)
        CurHrs := Format("{1:02d}",CurHrs)
        FinalOutput := CurHrs ":" CurMin ":" CurSec "." Dec
    } Else If (Type = "hms")
        FinalOutput := CurHrs "h " CurMin "m " CurSec "s"
    
    return FinalOutput
}

GetInt(nInput) { ; get integer
	InputArray := StrSplit(nInput,".")
    return InputArray[1]
}

GetDec(nInput) { ; get decimal
	InputArray := StrSplit(nInput,".")
    return InputArray[2]
}

qt(sInput) {
	Result := Chr(34) sInput Chr(34)
	return Result
}

noqt(sInput) {
	len := StrLen(sInput), StrR := SubStr(sInput,len), StrL := SubStr(sInput,1,1)
	If (StrR = Chr(34)) And (StrL = Chr(34))
		Result := SubStr(sInput, 2, -1)
	Else
		Result := sInput
	return Result
}

FileExt(sInput) {
	SplitPath sInput, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	return OutExtension
}

FileTitle(sInput) {
	SplitPath sInput, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	return OutNameNoExt
}

FileFromPath(sInput) {
	SplitPath sInput, OutFileName
	return OutFileName
}

PathToFile(sInput,noSlash:=True) {
	SplitPath sInput, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	return OutDir
}

; ZeroPad(sInput,nPad) { ; quick zero pad for decimal numbers
	; If (IsNumeric(sInput) = 0) {
		; return 0
	; } Else {
		; pattern := "{:0" nPad "d}" ; "{:02d}"
		; sResult := Format(pattern,sInput)
		; return sResult
	; }
; }

StrRep(sInput,nRep) { ; repeats sInput "nRep" times
    If (nRep <= 0)
        return ""
    Else {
		i := 0
		Loop nRep
        {
			If (sResult = "")
				sResult := sInput
			Else
				sResult := sResult sInput
			i++
		}
		Return sResult
	}
}

IsDir(sInPath) {
    Result := 0
    Attrib := FileGetAttrib(sInPath)
    result := InStr(Attrib,"D")
    
	If (result)
		return 1
	Else
		return 0
}

ListifyCrlf(sInstr,lMethod,sSelect:="") {    
    If (lMethod = 1) {							; lMethod =
        Loop Parse sInstr, "`r", "`n"			;   1 = CRLF list to Control list
            If (A_LoopField != "")				;   2 = Control list to CRLF list
                sOutput .= A_LoopField "|"
        
        If (sSelect != "")
            sOutput := StrReplace(sOutput,sSelect "|",sSelect "||")
        
        If (SubStr(sOutput,-1) = "|" And SubStr(sOutput,-2) != "||")
			sOutput := Trim(sOutput,OmitChars:="|")
            ; lLen := StrLen(sOutput), sOutput := Left(sOutput,lLen-1)
		
        return sOutput
    }
    
    If (lMethod = 2) {
        Loop Parse sInstr, "|"
            If (A_LoopField != "")
                sOutput .= A_LoopField "`r`n"
        sOutput := Trim(sOutput,OmitChars:="`r`n")
        return sOutput
    }
}

Listify(sInstr,sSelect,bSelectAll:=false) {	; Returns a pipe delimited list with the selected item
    Loop Parse sInstr, "|"					; followed by || to signify pre-selection.
    {
        If (A_LoopField != "") {
            If (bSelectAll = false) {
                If (A_LoopField = sSelect)
                    NewVal := A_LoopField "||"
                Else
                    NewVal := A_LoopField "|"
            } Else
                NewVal := A_LoopField "||"
            sOutput .= NewVal
        }
    }
	If (SubStr(sOutput,-2) != "||")
		sOutput := Trim(sOutput,OmitChars:="|") ; removes trailing pipe
    return sOutput
}

FileSizeDisp(InSize,Dec) {
    NumLen := StrLen(InSize)
    
    If (NumLen <= 3)
        OutNum := InSize, OutUnit := "B"
    Else If (NumLen <= 6)
        OutNum := Round(InSize / 1000,Dec), OutUnit := "KB"
    Else If (NumLen <= 9)
        OutNum := Round(InSize / 1000000,Dec), OutUnit := "MB"
    Else If (NumLen <= 12)
        OutNum := Round(InSize / 1000000000,Dec), OutUnit := "GB"
    Else If (NumLen <= 15)
        OutNum := Round(InSize / 1000000000000,Dec), OutUnit := "TB"
    Else If (NumLen <= 18)
        OutNum := Round(InSize / 1000000000000000,Dec), OutUnit := "PB"
    Else If (NumLen <= 21)
        OutNum := Round(InSize / 1000000000000000000,Dec), OutUnit := "EB"
    
    return OutNum " " OutUnit
}

; ====================================================================
; InStrCount(InputString,SearchString)
; ====================================================================

; InStrCount(InputString,SearchString) {
    ; i := 1
    ; While (InStr(InputString,SearchString,,1,i) > 0)
        ; i += 1
    ; return i - 1
; }

; ====================================================================
; RegExMass(InputString,inRegEx,m)
; ====================================================================

RegExMatchMass(InputString,inRegEx,m) {
    ; m = mode
    ; "c" = count (ie number of matches)
    ; "v" = values (crlf separated list of matched values)
    ;
    ; inRegEx Examples
    ; ================
    ; match url of many schemes
    ; inRegEx := "(https?|ftp|irc|magnet|file)://[A-Za-z0-9_:?/#@!$&'()*+,;=\`\.\-\[\]]*"
    
    i := 0
    rp := RegExMatch(InputString,inRegEx,rv)
    rl := StrLen(rv)
    
    While (rp > 0) {
        If (LinkList = "") {
            LinkList := rv
        } Else {
            LinkList .= "`r`n" rv
        }
        
        rp := RegExMatch(InputString,inRegEx,rv,rp+rl)
        rl := StrLen(rv)
        
        i += 1
    }
    
    If (m = "c") {
        return i
    } Else If (m = "v") {
        return LinkList
    } Else {
        return
    }
}

; ====================================================================
; GetLinks(InputString)
; ====================================================================

GetLinks(InputString,schemes) {
    ; schemes := https?|ftp|irc|magnet|file
    inRegEx := "(" schemes ")://[A-Za-z0-9_:?/#@!$&'()*+,;=\`\.\-\[\]]*"
    
    rp := RegExMatch(InputString,inRegEx,rv)
    rl := StrLen(rv)
    
    While (rp > 0) {
        If (LinkList = "") {
            LinkList := rv
        } Else {
            LinkList .= "`r`n" rv
        }
        
        rp := RegExMatch(InputString,inRegEx,rv,rp+rl)
        rl := StrLen(rv)
    }
    
    return LinkList
}

; ====================================================================
; GetTxtLine(InputString,LineNum) - CountTxtLine(InputString)
; ====================================================================

CountTxtLines(InputString) {
    Loop Parse InputString, "`r", "`n"
        Result := A_Index
    return Result
}

GetTxtLine(InputString,LineNum) {
    Loop Parse InputString, "`r", "`n"
        If (A_Index = LineNum)
            return A_LoopField
}

; ====================================================================
; EnvVar() get system env var, FolderList(), SystemDrive(), UserProfile()
; ====================================================================

; EnvVar(InText) { ; Use EnvGet("environment_var")
	; EnvGet, OutVar, %InText%
	; return OutVar
; }

SystemDrive() {
	PathArray := StrSplit(A_WinDir,":")
	ResValue := PathArray[1]
	PathArray := ""
	
	return ResValue
}

UserProfile() {
	return StrReplace(A_AppData,"\AppData\Roaming","")
}

; FolderList(RootDir) {
    ; StartVar := RootDir, StartPattern := StartVar . "\*"
	; Loop Files StartPattern, "D"
		; dirList .= A_LoopFileLongPath ";"
	; FinalVar := Trim(dirList,OmitChars:=";")
	; return FinalVar
; }

; ====================================================================
; 
; ====================================================================

; ====================================================================
; support functions
; ====================================================================

; IsNumeric(vInput) {
	; test := vInput + 0
	
	; If (StrLen(test) = 0)
		; return 0
	; Else
		; return 1
; }