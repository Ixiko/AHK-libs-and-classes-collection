BuildUserAhkApi(AhkScriptPath, OverwriteAhkApi:="1", RecurseIncludes:="1", Labels:="1", WrapWidth:="265", AhkApiPath:="ReplaceThisWithFullPathTo\SciTE\user\user.ahk.api", RecursionCall:="0"){
	; Written by XeroByte
	; Generates the User.ahk.api file to add custom function & label intellisense!
	; to initate: use BuildUserAhkApi(A_ScriptFullPath,1) from the main script
	; Requires: grep() by Titan/Polyethelene https://github.com/camerb/AHKs/blob/master/thirdParty/titan/grep.ahk
	; Reqiures: isDir() Function
	; Optionally include TF_Wrap() from the TF Library https://github.com/hi5/TF/blob/master/tf.ahk
	TF_Wrap := "TF_Wrap" ; This is for a workaround to make the script still work even without the TF library - need to call the function dynamically.
	if(isDir(AhkScriptPath)){
		Loop, %AhkScriptPath%\*.ahk,0,1
			AhkApiText .= BuildUserAhkApi(A_LoopFileLongPath, 0, RecurseIncludes, Labels, WrapWidth, AhkApiPath, 1)
	}else{
		FileRead, ThisScriptTxt, %AhkScriptPath%
		; Retrieve Functions
			grep(ThisScriptTxt, "m)^\s*[a-zA-Z0-9_-]*\([^\)]*\)\s*\{(\s*;.*?$)*", MatchCollection,1,0,"§")
			loop, parse, MatchCollection, §
			{
				if(RegExMatch(A_LoopField,"iS)^\s*if\([^\)]*\)")>0)
					continue
				StringReplace, CustomFunc, A_LoopField, \, \\, All
				CustomFunc := RegExReplace(CustomFunc,"mS)(^\s*|\s*$)")
				CustomFunc := RegExReplace(CustomFunc,"S)\)\s*\{",")")
				if(IsFunc("TF_Wrap"))
					CustomFunc := %TF_Wrap%(CustomFunc, WrapWidth)
				CustomFunc := RegExReplace(CustomFunc,"S)\R", "\n")
				CustomFunc := RegExReplace(CustomFunc,"S)\t", "\t")
				CustomFunc := RegExReplace(CustomFunc,"S)([a-zA-Z0-9_-]*)\(","$1 (", ,1)
				AhkApiText .= CustomFunc . "\n; Location: " . SubStr(AhkScriptPath,InStr(AhkScriptPath,"\",0,0)+1) . "`n"
			}
			AhkApiText .= "`n"
		; Retrieve Labels
		if(Labels){
			grep(ThisScriptTxt, "mS)^\s*[a-zA-Z0-9_-]+\:\s(\s*;.*?$)*", MatchCollection,1,0,"§")
			loop, parse, MatchCollection, §
			{
				StringReplace, CustomFunc, A_LoopField, \, \\, All
				CustomFunc := RegExReplace(CustomFunc,"mS)(^\s*|\s*$)")
				if(IsFunc("TF_Wrap"))
					CustomFunc := %TF_Wrap%(CustomFunc, WrapWidth)
				CustomFunc := RegExReplace(CustomFunc,"S)\R", "\n")
				CustomFunc := RegExReplace(CustomFunc,"S)\t", "\t")
				StringReplace, CustomFunc, CustomFunc, :, %A_Space%
				AhkApiText .= CustomFunc . "\n; Location: " . SubStr(AhkScriptPath,InStr(AhkScriptPath,"\",0,0)+1) . "`n"
			}
			AhkApiText .= "`n"
		}
		; Recurse into includes
		if(RecurseIncludes){
			grep(ThisScriptTxt, "imS)^\s*\#include (.*)\s*$", IncludeCollection,1,1,"§")
			AhkScriptFolder := substr(AhkScriptPath,1,InStr(AhkScriptPath,"\",0,0))
			loop, parse, IncludeCollection, §
				AhkApiText .= BuildUserAhkApi((instr(A_LoopField,":")) ? A_LoopField : AhkScriptFolder . A_LoopField, 0, 1, Labels, WrapWidth, AhkApiPath, 1)
		}
	}
	; If this function call is the original function call (and not an autocall by the recursion).
	if(!RecursionCall){
		if(OverwriteAhkApi)
			FileDelete, %AhkApiPath%
		AhkApiText := RegExReplace(AhkApiText, "(\R){2,}","$1$1")
		FileAppend, %AhkApiText%, %AhkApiPath%
		ToolTip, Imported Custom Funcs & Labels from`n %AhkScriptPath%
		Sleep, 2000
		ToolTip
	}
	return AhkApiText
}

isDir(FilePattern){
	att := FileExist(FilePattern)
	return att = "" ? "" : InStr(att, "D") = 0 ? 0 : 1
}

grep(h, n, ByRef v, s = 1, e = 0, d = "") {
	v =
	StringReplace, h, h, %d%, , All
	Loop
		If s := RegExMatch(h, n, c, s)
			p .= d . s, s += StrLen(c), v .= d . (e ? c%e% : c)
		Else Return, SubStr(p, 2), v := SubStr(v, 2)
}