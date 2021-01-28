#NoEnv
;#NoTrayIcon
SetBatchLines, -1
SetControlDelay, -1
SetKeyDelay, -1
FileEncoding, UTF-8

;-----------------------------------------------------------------------------------------------------------------------------------------
; some variables
;-----------------------------------------------------------------------------------------------------------------------------------------
global fileIdx:=0, lib:= []

Directorys =
(LTrim
libs\a-f
libs\a-f\core_audio_interfaces
libs\g-n
libs\o-z
classes
classes\Class_PictureButton-master\lib
classes\class_Java-Access-Bridge
classes\COM-Classes-FrameWork
classes\COM-Classes-FrameWork\Constant Classes
classes\COM-Classes-FrameWork\CustomDestinationList
classes\COM-Classes-FrameWork\Dispatch
classes\COM-Classes-FrameWork\EnumShellItems
classes\COM-Classes-FrameWork\EnumSTATSTG
classes\COM-Classes-FrameWork\ImageList
classes\COM-Classes-FrameWork\ImageList2
classes\COM-Classes-FrameWork\MMDevice
classes\COM-Classes-FrameWork\MMDeviceCollection
classes\COM-Classes-FrameWork\MMDeviceEnumerator
classes\COM-Classes-FrameWork\ObjectArray
classes\COM-Classes-FrameWork\ObjectCollection
classes\COM-Classes-FrameWork\OperationsProgressDialog
classes\COM-Classes-FrameWork\Persist
classes\COM-Classes-FrameWork\PersistFile
classes\COM-Classes-FrameWork\Picture
classes\COM-Classes-FrameWork\ProgressDialog
classes\COM-Classes-FrameWork\PropertyStore
classes\COM-Classes-FrameWork\PropertyStoreCache
classes\COM-Classes-FrameWork\ProvideClassInfo
classes\COM-Classes-FrameWork\RichEditOLE
classes\COM-Classes-FrameWork\SequentialStream
classes\COM-Classes-FrameWork\ShellItem
classes\COM-Classes-FrameWork\ShellLinkA
classes\COM-Classes-FrameWork\ShellLinkW
classes\COM-Classes-FrameWork\Storage
classes\COM-Classes-FrameWork\Stream
classes\COM-Classes-FrameWork\Structure Classes
classes\COM-Classes-FrameWork\TaskbarList
classes\COM-Classes-FrameWork\TaskbarList2
classes\COM-Classes-FrameWork\TaskbarList3
classes\COM-Classes-FrameWork\TaskbarList4
classes\COM-Classes-FrameWork\TypeComp
classes\COM-Classes-FrameWork\TypeInfo
classes\COM-Classes-FrameWork\TypeInfo2
classes\COM-Classes-FrameWork\TypeLib
classes\COM-Classes-FrameWork\TypeLib2
classes\COM-Classes-FrameWork\UIAutomationBoolCondition
classes\COM-Classes-FrameWork\UIAutomationCondition
classes\COM-Classes-FrameWork\UIAutomationElementArray
classes\COM-Classes-FrameWork\UIAutomationNotCondition
classes\COM-Classes-FrameWork\Unknown
more libs
more libs\ActiveScript
more libs\AFC
more libs\AHK_DllCall_WinAPI\src\Clipboard Functions
more libs\AHK_DllCall_WinAPI\src\Cursor Functions
more libs\AHK_DllCall_WinAPI\src\Directory Management Functions
more libs\AHK_DllCall_WinAPI\src\Disk Management Functions
more libs\AHK_DllCall_WinAPI\src\Error Handling Functions
more libs\AHK_DllCall_WinAPI\src\File Management Functions
more libs\AHK_DllCall_WinAPI\src\IP Helper Functions
more libs\AHK_DllCall_WinAPI\src\Keyboard Input Functions
more libs\AHK_DllCall_WinAPI\src\Memory Management Functions
more libs\AHK_DllCall_WinAPI\src\Mouse Input Functions
more libs\AHK_DllCall_WinAPI\src\Multimedia Functions
more libs\AHK_DllCall_WinAPI\src\National Language Support Functions
more libs\AHK_DllCall_WinAPI\src\Others
more libs\AHK_DllCall_WinAPI\src\Process and Thread Functions
more libs\AHK_DllCall_WinAPI\src\PSAPI Functions
more libs\AHK_DllCall_WinAPI\src\String Functions
more libs\AHK_DllCall_WinAPI\src\System Information Functions
more libs\AHK_DllCall_WinAPI\src\System Shutdown Functions
more libs\AHK_DllCall_WinAPI\src\Time Functions
more libs\AHK_DllCall_WinAPI\src\Volume Management Functions
more libs\AHK-Object-Oriented-GUIs\gui
more libs\AHK-Object-Oriented-GUIs\gui\controls
more libs\AHK-OpenCV-master\Lib
more libs\Canvas
more libs\CGUI
more libs\CNG\win7
more libs\CNG\win10
more libs\core_audio_interfaces
more libs\CustomBoxes
more libs\Dictation-Interface
more libs\DirectX\AHK Injecto
more libs\DirectX\headers
more libs\DirectX\Lib
more libs\DirectX\Lib\TexSwap
more libs\DoDragAndDrop
more libs\DX9-Overlay-API\include\ahk
more libs\eAutocomplete
more libs\EmbedPython.ahk
more libs\EmbedPython.ahk\Lib
more libs\exLibs
more libs\Edit\_Functions
more libs\ImportTypeLib
more libs\ImportTypeLib\Lib
more libs\MCode-Ex\src
more libs\MCode-Ex\src\Compiler
more libs\MinHook\Lib
more libs\Mini_Framwork\Framework\src\System\
more libs\Mini_Framwork\Framework\src\System\IO
more libs\Mini_Framwork\Framework\src\System\MfStruct
more libs\Mini_Framwork\Framework\src\System\MfUnicode
more libs\Mini_Framwork\Framework\src\System\Text
more libs\minilib
more libs\MsgBox2
more libs\ObjCSV\lib
more libs\RamDisk & CmdReturn
more libs\SendInput
more libs\Splash-Gui
more libs\TAB\_Functions
more libs\Various1\lib
more libs\windows10DesktopManager
more libs\windows10DesktopManager\injection dll
more libs\WindowsScriptingObject
more libs\Windy
more libs\WinLogon
more libs\Wy\lib
more libs\Wy\lib\GdipC
more libs\Wy\lib\Wy
more libs\xlib
more libs\xlib\xinclude\common
more libs\xlib\xinclude\pool
more libs\xlib\xinclude\pool\threadPool
more libs\xlib\xinclude\threads
more libs\xlib\xinclude\threads\threadHandler
more libs\xlib-xdllcall
more libs\xlib-xdllcall\lib
more libs\xlib-xdllcall\lib\xinclude
msOffice
msOffice\DocX
msOffice\Excel
msOffice\more
msOffice\Outlook
msOffice\PowerPoint
msOffice\Word
)
functions          	:= Object()
Dir                    	:= StrSplit(Directorys, "`n", "`r")
file_readmeMd	:= A_ScriptDir "\readme.md"
MDTable          	:= "| **Nr** | **Library**                                      | **Directory**                                    |`n"
MDTable          	.= "| :--- | :--------------------------------- | :------------------------------------------- |`n"

;-----------------------------------------------------------------------------------------------------------------------------------------
; fileread of readme.md till table is reached
;-----------------------------------------------------------------------------------------------------------------------------------------
ReadMeMd:= MakeTableLess_readmeMd(file_readmeMd, tableStartLine, libMaxOld)
ReadMeMd .= "| **Nr** | **Library**                                      | **Directory**                                    |`n"
ReadMeMd .= "| :--- | :--------------------------------- | :------------------------------------------- |`n"
;ReadMeMd:= StrReplace(ReadMeMd, "history of updates `n`n", "history of updates `n`n* **[" A_DD "." A_MM "." A_YYYY "]** - on last update: " libMaxOld "`n")
;ReadMeMd:= RegExReplace(ReadMeMd, "M)Edition\:\s\d\d\.\d\d.\d\d\d\d", "Edition: " A_DD "." A_MM "." A_YYYY)

;-----------------------------------------------------------------------------------------------------------------------------------------
; scan for files
;-----------------------------------------------------------------------------------------------------------------------------------------
Loop, % Dir.MaxIndex()												; list all files in all directory's
{
		Md := list_files(Dir[A_Index])
		ReadMeMd .= StrReplace(Md, "\", "/")
}

clines:= lib.MaxIndex()

;-----------------------------------------------------------------------------------------------------------------------------------------
; write a functionlist - maybe you use it for fast searching
;-----------------------------------------------------------------------------------------------------------------------------------------
file:= FileOpen(A_ScriptDir "\FileFunctionList.ahk", "w")
For idx, ffpath in lib
{
	ToolTip, % "File: " A_Index "/" clines, 2000, 500, 6
	funcList:= listfunc(ffpath)
	RegExMatch(ffpath, "\w+\\[\w\s\(\)]+\.ahk", shortpath)
	File.Write("[" A_Index "] " shortpath " {`n`nLine  `t|`tFunction`n" funclist "`n}`n")
}
File.Close()

file:= FileOpen(A_ScriptDir "\README.md", "w")
file.Write(ReadMeMd)
File.Close()

MsgBox, % "Ready`nlast lib count: " libMaxOld

exitApp

MakeTableLess_readmeMd(file_readmeMd, byref tableStartLine, byref libMaxOld) {

	Table_RegExString	        	:= "O)(\|\s[^\|]+\s)"
	TableColCountHelp_RegExString:= "\|\s\-+\s\|"

	FileRead, tmp, % file_readmeMd

	Loop, Parse, tmp, `n, `r
	{
		 If RegExmatch(A_LoopField, Table_RegExString, Match)
				If !tableStartLine
				{
					tableStartLine:= A_Index
				}
				else
					tableLastLine:= A_Index, RegExMatch(A_LoopField, "(?<=\|\s\*\*)\d+", libMaxOld)
		else
			newMd.= A_LoopField "`n"
	}

return newMd
}

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

list_files(Directory) {

	mdline:=""

	Loop , Files, % A_ScriptDir . "\" . Directory . "\*.ahk"
	{
		If Instr(A_LoopFileName, "example")
				continue
		fileIdx ++
		MouseGetPos, mx, my
		FileGetSize	, fsize	, % A_ScriptDir . "\" . Directory . "\" A_LoopFileName
		fsize:= Round(fsize/1024, 2)
		FileGetTime	, ftime	, % A_ScriptDir . "\" . Directory . "\" A_LoopFileName, M
		FormatTime, ftime, % ftime, yyyy-MM-dd
		mdline .= "| **" . SubStr("0000" . fileIdx, -3) . "** | [" . A_LoopFileName . "](" . Directory . "\" . StrReplace(A_LoopFileName," ", "%20") . ") <br>" fsize "kb - " ftime " | " Directory . "|`n"
		lib.Push(Directory "\" A_LoopFileName)
		ToolTip, found files: %files%, %mx%, %my%, 6
	}

	;FileAppend, % "| **" . SubStr("0000" . fileIdx, -3) . "** | [" . A_LoopFileName . "](" . Directory . "\" . StrReplace(A_LoopFileName," ", "%20") . ") | " Directory . "  | `n", % A_ScriptDir "\FilesTable.md"

	return mdline
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


