;~ #include <RXMS>

;~ script:="F:\scripts\Radiology\PacsIE\PacsIE.ahk"
;~ script:="M:\scripts\Radiology\YCH_main.ahk"
;~ msgbox % fileexist(script)
;~ exitapp

;~ clipboard:=JoinLib(script)
;~ FileAppend,% JoinScript("C:\Documents and Settings\ntuhuser\My Documents\Downloads\rehotkey\babysis-main.ahk"),C:\Documents and Settings\ntuhuser\My Documents\Downloads\rehotkey\All.ahk,utf-8
;~ ExitApp
JoinLib(scriptFullPath,workingDir="",keepLib=0){
	global outputvar
	IncludedScript:=[]
	static includedLib
	if !isobject(includedLib) || keepLib=0
		includedLib:=[]
	
	scriptDir:=RegExReplace(scriptFullPath,"(\/|\\)([^\/\\]+)$","")
	if workingDir=
		workingDir:=scriptDir
	
	lib:=[]
	if fileexist(workingDir "\Lib.lnk") {
		FileGetShortcut, % workingDir "\Lib.lnk", target
		lib.insert(target)
	}
	lib.insert(workingDir "\Lib")
	lib.insert(a_mydocuments "\AutoHotkey\Lib")
	
	SplitPath,a_ahkpath,,ahkpath
	lib.insert(ahkpath "\Lib")
	
		
	
	fileread,scriptText,% scriptFullPath
	
	includePattern:="is)#include(again|)\s+(?:\*i\s+)?(<?)([^\n\r;>]+)(>?)(?:;[^\n\r]*)?\r?\n?"
	matched:=[]
	
	i:=0,match:="1"
	while i:=RegExMatch(scriptText,includePattern,match,i+strlen(match))
		matched.insert(array(match,match1?1:0,match3,match2&&match4?1:0,i,strlen(match)))
		
	
	;~ RXMS(scriptText,includePattern, "sOutputVar")
	;~ split:=[]
	;~ loop %OutputVar0%
		;~ split.insert(OutputVar%a_index%)
	
	fullScript:=""
	for k,v in matched {
		valued:=0
		includePath:=v.3
		if (v.4) { ;search in lib
			for x,y in lib
				if fileexist(y "\" includePath ".ahk") {
					includePath:=y "\" includePath ".ahk"
					if includedLib.haskey(includePath)
						break
					else {
						includedLib["" includePath]:=1,valued:=1
						break
					}
				}
		}else{
			StringReplace,includePath,includePath,% "%A_AppData%",%a_appdata%,all
			StringReplace,includePath,includePath,% "%A_AppDataCommon%",%A_AppDataCommon%,all
			StringReplace,includePath,includePath,% "%A_ScriptDir%",%ScriptDir%,all
			;~ clipboard:=includePath
			if instr(fx:=fileexist(includePath),"D") { ;folder
				workingDir:=RegExReplace(includePath,"(\\|\/)?$","")
				
			}else if (fx!="") {
				valued:=1
			}
		}
		
		if IncludedScript.hasKey(includePath) && v.1=0
			valued:=0
		
		
		fullScript.=(k=1?substr(scriptText,1,v.5-1):substr(scriptText,matched[k-1,5]+matched[k-1,6],v.5-matched[k-1,5]-matched[k-1,6])) . (valued?"`n" JoinLib(includePath,"",1) "`n":"")
		
		IncludedScript["" includePath]:=1
		
	
	}
	;~ if instr(scriptFullPath,"PacsIE")
			;~ clipboard:=fullScript
	if(keepLib!=0)
		return matched.maxindex()?(fullScript substr(scriptText,v.5+v.6)):scriptText
	else{
		if !InStr(FileExist(workingDir "\Lib"),"D")
			FileCreateDir,% workingDir "\Lib"
		for k,v in includedLib 
			FileCopy,% k,% workingDir "\Lib",1
	}
}

JoinScript(scriptFullPath,workingDir="",keepLib=0){
	global outputvar
	IncludedScript:=[]
	static includedLib
	if !isobject(includedLib) || keepLib=0
		includedLib:=[]
	
	scriptDir:=RegExReplace(scriptFullPath,"(\/|\\)([^\/\\]+)$","")
	if workingDir=
		workingDir:=scriptDir
	
	lib:=[]
	if fileexist(workingDir "\Lib.lnk") {
		FileGetShortcut, % workingDir "\Lib.lnk", target
		lib.insert(target)
	}
	lib.insert(workingDir "\Lib")
	lib.insert(a_mydocuments "\AutoHotkey\Lib")
	
	SplitPath,a_ahkpath,,ahkpath
	lib.insert(ahkpath "\Lib")
	
		
	
	fileread,scriptText,% scriptFullPath
	
	includePattern:="is)#include(again|)\s+(?:\*i\s+)?(<?)([^\n\r;>]+)(>?)(?:;[^\n\r]*)?\r?\n?"
	matched:=[]
	
	i:=0,match:="1"
	while i:=RegExMatch(scriptText,includePattern,match,i+strlen(match))
		matched.insert(array(match,match1?1:0,match3,match2&&match4?1:0,i,strlen(match)))
		
	
	;~ RXMS(scriptText,includePattern, "sOutputVar")
	;~ split:=[]
	;~ loop %OutputVar0%
		;~ split.insert(OutputVar%a_index%)
	
	fullScript:=""
	for k,v in matched {
		valued:=0
		includePath:=v.3
		if (v.4) { ;search in lib
			for x,y in lib
				if fileexist(y "\" includePath ".ahk") {
					includePath:=y "\" includePath ".ahk"
					if includedLib.haskey(includePath)
						break
					else {
						includedLib["" includePath]:=1,valued:=1
						break
					}
				}
		}else{
			StringReplace,includePath,includePath,% "%A_AppData%",%a_appdata%,all
			StringReplace,includePath,includePath,% "%A_AppDataCommon%",%A_AppDataCommon%,all
			StringReplace,includePath,includePath,% "%A_ScriptDir%",%ScriptDir%,all
			;~ clipboard:=includePath
			if instr(fx:=fileexist(includePath),"D") { ;folder
				workingDir:=RegExReplace(includePath,"(\\|\/)?$","")
				
			}else if (fx!="") {
				valued:=1
			}
		}
		
		if IncludedScript.hasKey(includePath) && v.1=0
			valued:=0
		
		
		fullScript.=(k=1?substr(scriptText,1,v.5-1):substr(scriptText,matched[k-1,5]+matched[k-1,6],v.5-matched[k-1,5]-matched[k-1,6])) . (valued?"`n" joinScript(includePath,"",1) "`n":"")
		
		IncludedScript["" includePath]:=1
		
	
	}
	;~ if instr(scriptFullPath,"PacsIE")
			;~ clipboard:=fullScript
	return matched.maxindex()?(fullScript substr(scriptText,v.5+v.6)):scriptText
	
}