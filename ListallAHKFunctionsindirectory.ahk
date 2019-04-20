#NoEnv
#NoTrayIcon
SetBatchLines, -1
SetControlDelay, -1
SetKeyDelay, -1
FileEncoding, UTF-8

global fileIdx:=0
functions:= Object()
Directorys = 
(LTrim 
lib-a_to_h
lib-i_to_z
classes
more libs
MSOffice
more libs\AFC
more libs\AHK-Object-Oriented-GUIs-master\gui
more libs\Canvas-AHK-master
more libs\CGUI-master
more libs\CustomBoxes
more libs\DirectX\AHK Injector
more libs\DirectX\headers
more libs\DirectX\Lib
more libs\DirectX\Lib\TexSwap
more libs\DoDragAndDrop
more libs\DX9-Overlay-API\include\ahk
more libs\more libs\Edit\_Functions
more libs\ImportTypeLib-master
more libs\ImportTypeLib-master\Lib
more libs\MCode-Ex-master\src
more libs\MCode-Ex-master\src\Compiler
more libs\MinHook-AHK-master\Lib
more libs\Mini_Framwork
more libs\Mini_Framwork\MfUnicode
more libs\Mini_Framwork\IO
more libs\minilib
more libs\RamDisk & CmdReturn
more libs\SendInput-master
more libs\Splash-Gui
more libs\TAB\_Functions
more libs\windows10DesktopManager
more libs\windows10DesktopManager\injection dll
more libs\Windy
more libs\WinLogon
)

Dir := StrSplit(Directorys, "`n", "`r")

FileDelete, files.txt
FileDelete, filesTable.md
FileDelete, FileFunctionList.txt

FileAppend, % "| **Nr** | **Library**                                               | **Directory**                                              |`n", %A_ScriptDir%\filesTable.md
FileAppend, % "| :--- | :-------------------------------------- |:----------------------------------------------------|`n", %A_ScriptDir%\filesTable.md
				
Loop, % Dir.MaxIndex()				
		fc[A_Index]:= list_files(Dir[A_Index])

;Reads files.txt , and opens file by file - it search for function - store them into functions object + store the containing script
;todo - retreave informations about the functions from script lines - detect ; or /**/

FileRead, files, %A_ScriptDir%\files.txt
Loop, Parse, files, `n, `r
	clines++

Loop, Parse, files, `n, `r
{
	filename := A_LoopField
	ToolTip, % "File: " A_Index "/" clines, 2000, 500, 6
	funcList:= listfunc(filename)
	StringSplit, path, filename, `\
	shortpath:= path7 . "`\" . path8
	FileAppend, % "[" A_Index "] " shortpath " {`n`nFunctions:`n", %A_ScriptDir%\FileFunctionList.txt   
	FileAppend, % funclist "`n", %A_ScriptDir%\FileFunctionList.txt
	FileAppend, % "}`n", FileFunctionList.txt

		/*
			Loop, Parse, funcList, `n
			{
					line:= A_LoopField
					If !line = "" 
					{
							StringSplit, line, line, `|, %A_Space%
							;FileAppend, %line2%`;%line1%`;%filename%`n, FunctionFileList.csv
					}
			}
		*/
}


/*
FileRead, Index, FunctionFileList.csv
if not ErrorLevel  ; Erfolgreich geladen.
{
    Sort, Index
    FileDelete, FunctionFileList.csv
    ;FileAppend, %Index%, FunctionFileList.csv
    Index =
}
*/


exitApp


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
              StringReplace state, state, COMMENT         ; Remove state
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
				rf := rf . "" . linec . " | " . str . "(" . pl . ")`n"
    }

  labelNb--
  rl =
  Loop %labelNb% {
		linec.= labelList#%A_Index%@line
		linec:= SubStr("00000" . linec, -3)
		rl := rl . "" . linec . " | " . labelList#%A_Index%@name . "`n"

	}
  hotkeyNb--
  rk =
  Loop %hotkeyNb%
      rk :=rk . "" . hotkeyList#%A_Index%@line . " | " . hotkeyList#%A_Index%@name . "`n"

  hotstringNb--
  rs =
  Loop %hotstringNb%
      rs := rs . "" . hotstringList#%A_Index%@line . " | " . hotstringList#%A_Index%@name . "`n"

	return rf

}

list_files(Directory) {
	
	Loop , Files, % A_ScriptDir . "\" . Directory . "\*.ahk"
	{
		If Instr(A_LoopFileName, "example")
				continue
		fileIdx ++
		MouseGetPos, mx, my
		FileAppend, % Directory . "\" . A_LoopFileName "`n", %A_ScriptDir%\Files.txt
		FileAppend, % "| **" . SubStr("0000" . fileIdx, -3) . "** | [" . A_LoopFileName . "](" . Directory . "\" . StrReplace(A_LoopFileName," ", "%20") . ") | " Directory . "\  | `n", % A_ScriptDir "\FilesTable.md"
		ToolTip, found files: %files%, %mx%, %my%, 6
	}
	return
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