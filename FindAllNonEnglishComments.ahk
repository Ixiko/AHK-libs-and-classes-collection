#NoEnv
;#NoTrayIcon
SetBatchLines, -1
SetControlDelay, -1
SetKeyDelay, -1
FileEncoding, UTF-8

;-----------------------------------------------------------------------------------------------------------------------------------------
; some variables
;-----------------------------------------------------------------------------------------------------------------------------------------
global fileIdx	:= 0	; library counter
global files      	:= []	; files array
global baseDir := A_ScriptDir
global RefFileNum
global RefBaseDir
FileRead, directories, % A_ScriptDir "\directories"
functions          	:= Object()
Dirs                    	:= StrSplit(directories, "`n", "`r")
	FileDelete, % A_ScriptDir "\trigramStatistic.txt"

;-----------------------------------------------------------------------------------------------------------------------------------------
; scan for files
;-----------------------------------------------------------------------------------------------------------------------------------------


;clines:= lib.MaxIndex()


Gui, Ref: New, -DPIScale +HWNDhRefGui ; +AlwaysOnTop
Gui, Ref: Color, cFFDFAE
Gui, Ref: Font, s8 bold
Gui, Ref: Add, Text      	, % "xm ym"             	, % "examining file ("
Gui, Ref: Font, s8 normal
Gui, Ref: Add, Text      	, % "x+2 vRefFileNum"	, % "00000): "
Gui, Ref: Font, s6 normal
Gui, Ref: Add, Text      	, % "xm y+0 w1000 vRefBaseDir" 	, % "---"
Gui, Ref: Font, s8 bold
Gui, Ref: Add, Text      	, % "xm y+0" 	, % "file(s) containing no english comments: "
Gui, Ref: Font, s8 normal
;Gui, Ref: Add, Text      	, % "x+10"   	, % "*" AhkFileName "* (.ahk)  [" AhkFileSizeByte " bytes / " AhkFileSizekB  " kb]"
Gui, Ref: Add, Listview	, % "xm y+10 w1050 r30 BackgroundDFBF8E vREFLV1 HwndhRefLV1 +LV0x00400000 gRefListview Checked ", % "Count|Path|comments language"  ;ReadOnly -HDR

;For i, val in found
;	LV_Add("", val.lib, val.enc, val.b, val.kb, (AhkFileSizeByte>val.b ? (AhkFileSizeByte-val.b) : (val.b-AhkFileSizeByte)), (AhkFileSizekb>val.kb ? (AhkFileSizekb-val.kb) : (val.kb-AhkFileSizekb)))

Gui, Ref: Show	, AutoSize, % "Translate comments to english"
LV_ModifyCol(2, 800)

scripts:= GetFiles(Dirs)


return

RefListview:
return

RefGuiEscape:
RefGuiClose:
ExitApp

listfunc(file) {

	global rl

	rl:=""
	rf:=""
	FileRead script, % A_ScriptDir "\" file

	  identifierRE = ][#@$?\w                  ; Legal characters for AHK identifiers (variables and function names)
	  parameterListRE = %identifierRE%,=".\s-  ; Legal characters in function definition parameter list
	  lineCommentRE = \s*(?:\s;.*)?$           ; Legal line comment regex

	  functionNb := 1
	  labelNb := 1
	  hotkeyNb := 1
	  hotstringNb := 1
	  state = DEFAULT

	Loop Parse, script, `n, `r
    {
      line := A_LoopField
      If RegExMatch(line, "^\s*(?:;.*)?$")            ; Empty line or line with comment, skip it
          Continue

      Else If InStr(state, "COMMENT"){                    ; In a block comment
          If RegExMatch(line, "S)^\s*\*/")                  ; End of block comment
              state:= StrReplace(state, COMMENT)         ; Remove state
              ; "*/ function_def()" is legal but quite perverse... I won't support this

      }Else If InStr(state,"CONTSECTION") {               ; In a continuation section
          If RegExMatch(line, "^\s*\)")                   ; End of continuation section
              state = DEFAULT

      }Else If RegExMatch(line, "^\s*/\*")                ; Start of block comment, to skip
          state = %state% COMMENT

      Else If RegExMatch(line, "^\s*\(")                  ; Start of continuation section, to skip
          state = CONTSECTION

      Else If RegExMatch(line, "i)^\s*(?P<Name>[^ \s:]+?(?:\s+&\s+[^\s:]+?)?(?:\s+up)?)::", hotkey){  ;Hotkey
          hotkeyList#%hotkeyNb%@name := hotkeyName
          hotkeyList#%hotkeyNb%@line := A_Index
          hotkeyNb++
          state = DEFAULT

      }Else If RegExMatch(line, "i)^\s*(?P<Name>:(?:\*0?|\?0?|B0?|C[01]?|K(?:-1|\d+)|O0?|P\d+|R0?|S[IPE]|Z0?)*:.+?)::", hotstring){ ;HotString
          hotstringList#%hotstringNb%@name := hotstringName
          hotstringList#%hotstringNb%@line := A_Index
          hotstringNb++
          state = DEFAULT

      }Else If RegExMatch(line, "^\s*(?P<Name>[^\s,```%]+):" . lineCommentRE, label){   ; Label are very tolerant...
          labelList#%labelNb%@name := labelName
          labelList#%labelNb%@line := A_Index
          labelNb++
          state = DEFAULT

      }Else If InStr(state,"DEFAULT"){
          If RegExMatch(line, "^\s*(?P<Name>[" . identifierRE . "]+)"         ; Found a function call or a function definition
                            . "\((?P<Parameters>[" . parameterListRE . "]*)"
                            . "(?P<ClosingParen>\)\s*(?P<OpeningBrace>\{)?)?"
                            . lineCommentRE, function){
              state = FUNCTION
              functionList#%functionNb%@name := functionName
              functionList#%functionNb%@parameters := functionParameters
              functionList#%functionNb%@line := A_Index
              If functionClosingParen{        ; With closed parameter list
                  If functionOpeningBrace {     ; Found! This is a function definition
                      functionNb++                ; Validate the finding
                      state = DEFAULT
                  }Else                         ; List of parameters is closed, just search for opening brace
                      state = %state% TOBRACE
              }Else                           ; With open parameter list
                  state = %state% INPARAMS      ; Search for closing parenthesis
            }

      }Else If InStr(state,"FUNCTION"){
          If InStr(state, "INPARAMS") {     ; After a function definition or call
              ; Looking for ending parenthesis
              If (RegExMatch(line, "^\s*(?P<Parameters>,[" . parameterListRE . "]+)"
                                 . "(?P<ClosingParen>\)\s*(?P<OpeningBrace>\{)?)?" . lineCommentRE, function) > 0){
                  functionList#%functionNb%@parameters := functionList#%functionNb%@parameters . functionParameters
                  If functionClosingParen {            ; List of parameters is closed
                      If (functionOpeningBrace != ""){   ; Found! This is a function definition
                        functionNb++                     ; Validate the finding
                        state = DEFAULT
                      }Else                              ; Just search for opening brace
                        StringReplace state, state, INPARAMS, TOBRACE ; Remove state
                    }                                    ; Otherwise, we continue
              }Else
                  ; Incorrect syntax for a parameter list, it was probably just a function call
                  ;??? does this ever happen???
                  state = DEFAULT
          }Else If InStr(state,"TOBRACE"){ ; Looking for opening brace. There can be only empty lines and comments, which are already processed
              If (RegExMatch(line, "^\s*(?:\{)" . lineCommentRE) > 0){  ; Found! This is a function definition
                  functionNb++  ; Validate the finding
                  state = DEFAULT
              }Else  ; Incorrect syntax between closing parenthesis and opening brace,
                  state = DEFAULT     ; it was probably just a function call
          }
      }
    }

  functionNb--
  rf =
  Loop %functionNb%{
      pl := RegExReplace(functionList#%A_Index%@parameters, "\s\s*", " ")  ; Replace multiple blank chars with simple space
		linec:= functionList#%A_Index%@line
		linec:= SubStr("00000" . linec, -3)
		str:= functionList#%A_Index%@name
		If Not Instr(str, "if`(")
				rf := rf . "" . linec . "`t|`t" . str . "(" . pl . ")`n"
    }

  labelNb--
  rl =
  Loop %labelNb% {
		linec.= labelList#%A_Index%@line
		linec:= SubStr("00000" . linec, -3)
		rl := rl . "" . linec . "`t|`t" . labelList#%A_Index%@name . "`n"

	}
  hotkeyNb--
  rk =
  Loop %hotkeyNb%
      rk :=rk . "" . hotkeyList#%A_Index%@line . "`t|`t" . hotkeyList#%A_Index%@name . "`n"

  hotstringNb--
  rs =
  Loop %hotstringNb%
      rs := rs . "" . hotstringList#%A_Index%@line . "`t|`t" . hotstringList#%A_Index%@name . "`n"

	return rf

}

GetFiles(Dirs) {

	mdline:=""

	Loop, % Dirs.MaxIndex()
    {
        dir:= baseDir "\" Dirs[A_Index]
		Loop, % dir "\*.ahk"
		{
			If Instr(A_LoopFileName, "example")
					continue
            fileIdx ++
			GuiControl, Ref: , refFileNum, % SubStr("000000" fileIdx, -5) "): "
			GuiControl, Ref: , refBaseDir, % A_LoopFileFullPath
			FileGetSize	, fsize	, % A_ScriptDir . "\" . Directory . "\" A_LoopFileName
			fsize:= Round(fsize/1024, 2)
			FileGetTime	, ftime	, % A_ScriptDir . "\" . Directory . "\" A_LoopFileName, M
			FormatTime, ftime, % ftime, yyyy-MM-dd
			files.Push(A_LoopFileFullPath)
            FileRead, fileStr, % A_LoopFileFullPath
            lng:= GetComments(fileStr, A_LoopFileFullPath)
			If !Instr(lng, "english")
				LV_Add("", fileIdx, StrReplace(A_LoopFileFullPath, BaseDir), lng)
            ;IdentifyCommentLanguages(str)
		}
    }

	return fileIdx
}
/*
*/
GetComments(fileStr, fname) {

    startpos := 1
    comments:= Object()
    trigrams:= Object()
    static AllTrigrams:= Object()
    q:= Chr(0x22)
    ;~ pos1:= RegExMatch(fileStr, "mO)(\/\*.*?\*\/)", block)
    ;~ pos2:= RegExMatch(fileStr, "mO)(\s*\;.*?[\n\r])*", InLine)

	;~ MsgBox, % "lenght of file: " StrLen(fileStr) "`nmatchcount: " pos1 " - " block.Value(1) "`nmatchcount: "  pos2 " - "  InLine.Count()

    While, pos:= RegExMatch(fileStr, "(\/\*.*?\*\/)|(\s*;.*?[\n\r])", comment, startpos)
    {
			;RegExReplace(comment, "\/", "", count)
			;comment:= RegExReplace(comment, "[^A-Za-z\p{L}\s]")
			;comment:= RegExReplace(comment, "[A-Za-z\s]+")
            comments.Push({"start":pos, "text":comment})
            textall .= StrReplace(comment, "`n", " ") " "
			startpos:= pos + StrLen(comment)
    }

    textall	:= RegExReplace(textall, "\s+", " ")
    textall	:= RegExReplace(textall, "\/\*", "")
    textall	:= RegExReplace(textall, "\*\/", "")
    textall	:= RegExReplace(textall, ";", "")
	;MsgBox, % textall
    word	:= StrSplit(textall, " ")
	maxtrigrams:= 0
    Loop, % word.MaxIndex()
    {
			; don't count links!
			RegExReplace(word[A_Index], "\/", count)
			If count > 1
				continue
			;tmpWord     	:= RegExReplace(word[A_Index], "[^A-Za-z\p{L}]")
			tmpWord     	:= RegExReplace(word[A_Index], "[^\p{L}]")
            thisWord         	:= Format("{:L}", tmpWord)	; lower the string case
            trigramLength	:= Floor(StrLen(thisWord)/3)
			maxTrigrams 	+= trigramLength
			Loop, % trigramLength
			{
				position:= (A_Index-1)*3 + 1
				trigram:= SubStr(thisWord, position, 3)
				If trigrams.Haskey(trigram)
					trigrams[trigram]	+= 1
				else
					trigrams[trigram] :=	  1
            }
    }

	c:= 0
	For trigram, trigramcount in trigrams
	{
		 trigrams[trigram] := (trigramcount / maxtrigrams) * 100
		 t.= ((trigramcount / maxtrigrams) * 100) ";" trigram "`n"
		 c += ((trigramcount / maxtrigrams) * 100)
	}

	Sort, t, N R
	Loop, Parse, t, `n, `r
	{
		 trg:= StrSplit(A_LoopField, ";")
		 If (trg.2 = "the") && (A_Index <= 20) {
			 lng:= "english"
			 break
		 }
		 else if ((trg.2 in "for","val","add","ing","fun","for","set","app","use")) && (A_Index <=30)
		 {
				english ++
				If (english > 3) {
					lng:= "english"
					break
				}
		}

	}
	If (StrLen(lng) = 0) && (c > 0) ;, "english")
		FileAppend, % fname "`n" t c "`n", % A_ScriptDir "\trigramStatistic.txt"

	;Run, % "notepad.exe " q A_ScriptDir "\trigramStatistic.txt" q
	;MsgBox, % "Overall length of text is: " StrLen(textall) "`ncomments containing: " word.MaxIndex() " words`ntotal Trigrams found: " maxTrigrams "`nunique trigrams: " trigrams.Count()
	return lng
}

Contains(haystack, needle) {
	; If haystack is not an object, consider it a string
	if(!IsObject(haystack))
  {
    result := InStr(haystack, needle)
;     OutputDebug Contains: returning result %i%
    return
  }
	else
	{
		for i, v in haystack
		{
			if(v = needle)
      {
;         OutputDebug Contains: returning result %i%
        return i
      }
		}
;     OutputDebug Contains: returning false
		return false
	}
}


