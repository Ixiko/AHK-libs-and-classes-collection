SetBatchLines,-1
#include <JoinScript>


;~ FileDelete, % "F:\scripts\Radiology\YCH_Enh.ahk"
;~ FileAppend,% HotstringEnhancer(JoinScript("F:\scripts\Radiology\YCH.ahk"), 15), F:\scripts\Radiology\YCH_Enh.ahk, utf-8
;~ FileDelete, % "F:\scripts\Radiology\YCH_XR_Enh.ahk"
;~ FileAppend,% HotstringEnhancer(JoinScript("F:\scripts\Radiology\YCH_XR.ahk"), 15), F:\scripts\Radiology\YCH_XR_Enh.ahk, utf-8
;~ FileDelete, % "F:\scripts\Radiology\YCH_mammo_Enh.ahk"
;~ FileAppend,% HotstringEnhancer(JoinScript("F:\scripts\Radiology\YCH_mammo.ahk"), 15), F:\scripts\Radiology\YCH_mammo_Enh.ahk, utf-8

;~ clipboard:=Joinscript("F:\scripts\Radiology\PacsIE\simpleRIS.ahk")

;~ arr:= HotstringEnhancer(JoinScript("F:\scripts\Radiology\YCH.ahk"), 15, 1)
;~ a:=1
;~ param:=[]
;~ Loop %0% 
	;~ param.Insert(%a_index%)

;~ for k,v in param
	;~ if FileExist(v)
		;~ HotstringEnhance(v)

;~ test=
;~ ( %
;~ :*:ab1::abdominal
;~ )

;~ clipboard:=HotstringEnhancer("F:\scripts\Radiology\YCH_main.ahk")
;~ MsgBox % clipboard:=HotstringEnhancer(test)
;~ ExitApp
;~ return


HotstringEnhancer(fileOrText, minStrCount=20, alsoReturnArr=false){

	
	if FileExist(fileOrText)
		fileread,fullscript,% fileOrText
	else
		fullscript:=fileOrText
	;~ clipboard:=fullscript
	arr:=[],hotstring:=[],str:="",hotstringText:=[]
	newScript:="", capitalScript:=""
	
	loop,parse,fullscript,`n,`r 
	;~ loop,read,% path 
	{ 
		;~ if InStr(A_LoopField,"brainLobe:")
			;~ aaa:=1
		if RegExMatch(A_LoopField, "is)^\s*\/\*"){
			blockComment:=1
		}else if RegExMatch(A_LoopField, "is)^\s*\*\/"){
			blockComment:=0
		}
		
		if(blockComment){
			newScript.=A_LoopField "`n"
			continue
		}
		
		RegExMatch(A_LoopField, "is)^(.*?)( +;.*)?$", thisLine)
		
		
		if (inHotstring)
			++inHotstring
		
		
		if RegExMatch(thisLine1,"is)(^:([^:]*?):(.+):[^:]?:)(.*)$",match) {
			if(inHotstring=2 && str=""){
				arr["" hotstring[1]]:=""
				,hotstring:=[], hotstringText:=[]
			}
			
			newScript.=(RegExMatch(match2, "i)c(?!\d)")?match1:StringLower(match1)) thisLine2 "`n", inHotstring:=1
			omitEndChar:=!!RegExMatch(match2, "i)o(?!0)|\*")
			
			if (Trim(match4)!=""){
				arr["" match3]:=match4, hotstring:=[], hotstringText:=[]
				, newScript.=str2clip(match4, 1) "`n" (omitEndChar?"":"send % A_EndChar`n") "return`n"
				;~ , capitalScript.=":" match2 ":" StringUpperFirst(match3) "::`n"
				;~ , capitalScript.=str2clip(StringUpperFirst(match4), 1) "`n" (omitEndChar?"":"send % A_EndChar`n") "return`n"
				;~ , capitalScript.=":" match2 ":" StringUpper(match3) "::`n"
				;~ , capitalScript.=str2clip(StringUpper(match4), 1) "`n" (omitEndChar?"":"send % A_EndChar`n") "return`n"
				, inHotstring:=0
				continue
			}else {
				hotstring.Insert(match3), str:="", blockStr:="", hotstringText.Insert(match1)
				continue
			}
			
			
		}
		
		
		if (hotstring.maxindex()>0) {
			if RegExMatch(thisLine1,"is)^(\s*)\(\s*$") && (inHotstring=2) {
				blockStr:="", inBlockStr:=1
			}else if RegExMatch(thisLine1,"is)^(\s*)\)\s*$") && inBlockStr {
				inBlockStr:=0, blockStr:=SubStr(blockStr,1,-1)
				for k,v in hotstring
					arr["" v]:=blockStr
					
				hotstring:=[], hotstringText:=[], newScript.="sendByClipboard(""`n(`n" blockStr "`n)"")`n" (omitEndChar?"":"send % a_endchar`n") "return`n", inHotstring:=0
			}else if RegExMatch(thisLine1, "is)^(\s*)return *(?!:?=)"){
				inHotstring:=0, newScript.="return`n", hotstring:=[], hotstringText:=[], str:=""
			}else{
				if(inBlockStr)
					blockStr.=Trim(A_LoopField) "`n"
				else
					str.=A_LoopField "`n"
					,newScript.=A_LoopField "`n"
			}
			
			
		}else{
			newScript.=A_LoopField "`n"
		}
		
	}
	;~ clipboard:=newScript
	;send command
	script2:=""
	i:=0 , match:="0", ind:=1
	;~ while i:=RegExMatch(newScript,"i)([^\r\n]*)\bsend\b *(,)? *(?:(\r?\n\(\r?\n(.*?)(\r?\n\)))|([^\r\n]+))", match, ind) {
	while i:=RegExMatch(newScript,"i)([^\r\n]*)\bsend\b *(,)? *(?:(\r?\n\(\r?\n(.*?)(\r?\n\)))|([^\r\n]+))", match, ind) {
		script2.=SubStr(newScript, ind, i-ind)
		;~ if InStr(SubStr(newScript, ind, i-ind), "brainLobe:")
			;~ aaa:=1
		ind:=i+StrLen(match)
		if RegExMatch(match1,"(^|\s);") {
			script2.=match
			continue
		}
		
		if(match4){ ;block
			script2.=match1 "sendByclipboard(""`n(`n" doublingQuote(match4) "`n)"")"
		}else if(match6){
			if !RegExMatch(match6, "i)^ *(%) +([^\r\n]+)", m) && SubStr(match6,1,1)!="," {
				script2.=match1 str2clip(match6, 0, match1) 
			}else{
				script2.="sendByClipboard(" m2 ")"
			}
		}
		
		;~ ToolTip % A_Index
	}
	;~ clipboard:=script2
	if(ind<StrLen(newScript))
		script2.=SubStr(newScript, ind)
	
	combineSend(script2)
	;~ combineSend(script2)
	;~ clipboard:=script2
	Func1=
	(Ltrim
	
	sendByClipboard(byref str, bs=0){
		sendlevel,0
		focused:=getFocused()
		wingetclass,class,ahk_id `%focused`%
		if(class="Scintilla"){
			sci:=new RemoteScintilla(focused)
			if(bs)
				sci.DeleteRange(sci.getCurrentPos()-bs, bs)
			sci.AddText(str)
		}else{
			clipboard:=str
			send {bs `%bs`%}
			sleep 20
			send ^v
		}
		if(class="Scintilla") || instr(class, "Edit"){
			sendlevel,1
			send {esc}
		}
	}
	;~ StringUpper(ByRef str){
		;~ StringUpper,str2,str
		;~ return str2
	;~ }
	StringUpperFirst(ByRef str){
		return StringUpper(SubStr(str,1,1)) SubStr(str,2)
	}
	getFocused(){
		static GuiThreadInfoSize = 48
		VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
		NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
		DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo)
		return FocusedHWND := NumGet(GuiThreadInfo, 12)  ; Retrieve the hwndFocus field from the struct.
	}
	)
	
	AddCapitalAlternative(script2,arr)
	AddBackspacingParameter(script2)
	
	if(alsoReturnArr)
		return ["#Hotstring oc`n" script2 "`n" Func1, arr]
	else
		return "#Hotstring oc`n" script2 "`n" Func1

	
}

AddBackspacingParameter(ByRef str){
	script:="",ind:=1,i:=0
	while i:=RegExMatch(str, "is)(:([^:\r\n]*?):([^\r\n]+):[^:]?:)([^\r\n]*\r?\n\s*sendbyclipboard\()([^\r\n]+)(\)[^\r\n]*\r?\nreturn)", match, ind){
		script.=SubStr(str,ind,i-ind)
		script.=":" match2 "B0:" match3 "::" match4 match5 "," (StrLen(match3)-(InStr(match2,"*")?1:0)) match6
	
		ind:=i+StrLen(match)
	}
	script.=SubStr(str, ind)
	str:=script
}

AddCapitalAlternative(ByRef str, ByRef arr){
	i:=0,match:="0",newScript:=str,ind:=1
	keys:="`n"
	for k,v in arr
		keys.=k "`n"
	;~ StringCaseSense,on
	addedScript:="", FirstHotstring:=0
	while i:=RegExMatch(newScript, "is)(:([^:\r\n]*?):([^\r\n]+):[^:]?:)([^\r\n]*\r?\n\s*send)(byclipboard\(| % )([^\r\n]+)([^\r\n]*\r?\n[^\r\n]*return)",match,ind){
		;~ if (FirstHotstring=0)
			;~ FirstHotstring:=i
		trigger:=match3, sendStr:=match6
		trigger1:=StringUpperFirst(trigger)
		trigger2:=StringUpper(trigger)
		if !InStr(keys, "`n" trigger1 "`n", 1)
			addedScript.="`n:" match2 ":" trigger1 "::" match4 match5 "StringUpperFirst(" match6 (")") match7 
		keys.= trigger1 "`n"
		;~ if !InStr(keys, trigger2 "`n", 1)
			;~ addedScript.="`n:" match2 ":" trigger2 "::" match4 match5 "StringUpper(" match6 (SubStr(match6,0,1)=")"?")":"") match7 
		;~ keys.=trigger2 "`n"
		ind:=i+StrLen(match)
	}
	str.= addedScript
	;~ StringCaseSense,Off
	
}


freeVar(ByRef script){
	i:=0,match:="0",newScript:="",ind:=1
	while i:=RegExMatch(script, "i)(sendByClipboard\("")([^""\r\n]+)(""\))",match,ind){
		newScript.=SubStr(script,ind,i-ind)
		str:=match1 RegExReplace(match2,"\%(\w+)\%\%(\w+)\%", """ $1 $2 """) match3
		str:=RegExReplace(str,"\%(\w+)\%", """ $1 """)
		str:=RegExReplace(str,"i)^sendbyclipboard\("""" ","sendbyclipboard(")
		str:=RegExReplace(str," """"\)$",")")
		newScript.=str
		ind:=i+StrLen(match)
	}
	newScript.=SubStr(script, ind)
	
	i:=0,match:="0",script:="",ind:=1
	while i:=RegExMatch(newScript, "i)(send \% "")([^""\r\n]+)("")",match,ind){
		script.=SubStr(newscript,ind,i-ind)
		str:=match1 RegExReplace(match2,"\%(\w+)\%\%(\w+)\%", """ $1 $2 """) match3
		str:=RegExReplace(str,"\%(\w+)\%", """ $1 """)
		str:=RegExReplace(str,"i)^send \% """" ","send % ")
		str:=RegExReplace(str," """"$","")
		script.=str
		ind:=i+StrLen(match)
	}
	script.=SubStr(newscript, ind)
	
}

combineSend(ByRef str, minStrCount=15){
	s:=RegExReplace(str, "i)(sendbyclipboard\(""""\)|send % """")[^\r\n]*\r?\n","")
	
	i:=0,match:="0",ind:=1
	while i:=RegExMatch(s, "i)([^\r\n]*)send(ByClipboard\(| % )([^\r\n]*)(\r?\n)?([\r\n]*\,[\r\n]*)?([^\r\n]*)send(ByClipboard\(| % )([^\r\n]*)",match,ind){
		script.=SubStr(s, ind, i-ind)
	
		Text1:=RegExReplace(match3, ((clip1:=InStr(match2,"clip"))?"\)":"") "\s*$", "")
		Text2:=RegExReplace(match8, ((clip2:=InStr(match7,"clip"))?"\)":"") "\s*$", "")
		
		script.=match1 RegExReplace(toStrArr2(Text1 " " Text2, minStrCount),"\n", "`n" match5 match6)
		
		ind:=i+StrLen(match)
	}
	script.=SubStr(s, ind)
	
	i:=0,match:="0",ind:=1, s:=script, script:=""
	while i:=RegExMatch(s, "i)([^\r\n]*)send(ByClipboard\(| % )([^\r\n]*)",match,ind){
		script.=SubStr(s, ind, i-ind)
	
		Text1:=RegExReplace(match3, ((clip1:=InStr(match2,"clip"))?"\)":"") "\s*$", "")
		
		
		script.=match1 RegExReplace(toStrArr2(Text1, minStrCount),"\n", "`n" match5 match6)
		
		ind:=i+StrLen(match)
	}
	script.=SubStr(s, ind)
	
	script:=RegExReplace(script, "i)(sendbyclipboard\(""""\)|send % """")[^\r\n]*\r?\n","")
	script:=RegExReplace(script, "i)(send % )("""" )*([^\r\n]+)( """")*", "$1$3")
	script:=RegExReplace(script, "i)(sendbyclipboard\()("""" )*([^\r\n]+?)( """")*\)", "$1$3)")
	str:=script
}


doublingQuote(str){
	return RegExReplace(str, """", """""")
}

encloseBracket(str){
	str:=RegExReplace(str, "i)sendByclipboard\(""""\)\s*","")
	str:=RegExReplace(str, "i)send *\% +""""(?=\s)","")
	str:=RegExReplace(str,"^\s+","")
	str:=RegExReplace(str,"\s+$","")
	str:=RegExReplace(str,"\s*(\n\s*(?!\n))+","$1")
	if InStr(str,"`n")
		return RegExReplace("{`n" str "`n}","\s*(\n\s*(?!\n))+","$1")
	else
		return str
}

StringUpper(ByRef str){
	StringUpper,str2,str
	return str2
}
StringLower(ByRef str){
	StringLower,str2,str
	return str2
}
StringUpperFirst(ByRef str){
	return StringUpper(SubStr(str,1,1)) SubStr(str,2)
}

CountExpStrLen(str){
	str:=RegExReplace(str,"\%[\w]+\%","#")
	str:=RegExReplace(str,"[\#\!\^\+]*\{[^\}]+\}","#")
	str:=RegExReplace(str,"s)``.","#")
	str:=RegExReplace(str,"""""","""")
	return StrLen(str)
}

; send abcd%var%^{up}`n
; -> send % "abcd" var 
;    send ^{up}`n
toStrArr(str, noVar=0){
	arr:=[], delim:="¢"
	str:=RegExReplace(str,escapeMatch:="s)``.",delim "$0" delim) ;escape char
	
	str:=RegExReplace(str,"i){enter}","``n")
	str:=RegExReplace(str,"i){space}"," ")
	
	if !noVar
		str:=RegExReplace(str,varMatch:="\%([\w]+)\%",delim "$0" delim)
	str:=RegExReplace(str,keyMatch:="[\#\!\^\+]*\{[^\}]+\}",delim "$0" delim) ;send combine key
	
	
	
	Loop,Parse,str,% delim
	{
		if (A_LoopField="")
			continue
		if (!noVar && RegExMatch(A_LoopField, varMatch))
			arr.Insert([SubStr(A_LoopField,2,-1), "var"])
		else if RegExMatch(A_LoopField, keyMatch)
			arr.Insert([A_LoopField, "key"])
		else if RegExMatch(A_LoopField, EscapeMatch	)
			arr.Insert([A_LoopField, "escape"])
		else
			arr.Insert([A_LoopField, "text"])
	}
	
	str:="sendByClipboard(""", useClip:=1
	for k,v in arr {
		if (v.2="var"){
			if(useClip=0)
				str.="""`nsendByClipboard("
			str.=""" " v.1 " """, useClip:=1
		}else if (v.2="key"){
			if(useClip)
				str.=""")`nsend % """
			str.=v.1, useClip:=0
		}else if (v.2="escape" || v.2="text"){
			if(useClip=0)
				str.="""`nsendByClipboard("""
			str.=doublingQuote(v.1), useClip:=1
		}
	}
	str.="""" (useClip?")":"") "`n"
	str:=RegExReplace(str, "i)(sendbyclipboard\(""""\)|send % """")[^\r\n]*\r?\n","")
	str:=SubStr(str,1,-1)
	
	if InStr(str, "`n")
		str:="{`n" str "`n}"
	
	return str	
}


; "advas^{left}df" var "asdfa"
; -> "advas"¢"^{left}"¢"df" var "asdfa"
toStrArr2(str, minStrCount=15){
	if(str="""")
		return "sendByClipboard("""
	
	
	arr:=[], delim:="¢"
	;~ str:=RegExReplace(str,escapeMatch:="s)``.",delim "$0" delim) ;escape char
	;~ str:=RegExReplace(str,varMatch:="""?\s*\.?\s*([\w]+)\s*\.?\s*""?",delim "$1" delim)
	str:=RegExReplace(str,keyMatch:="[\#\!\^\+]*\{[^\}]+\}","""" delim """$0""" delim """") ;send combine key
	
	
	
	output:=""
	Loop,Parse,str,% delim
	{
		if (A_LoopField="")
			continue
		if RegExMatch(A_LoopField, "^""" keyMatch """$")
			output.="send % " Trim(A_LoopField) "`n"
		else{
			forCount:=RegExReplace(Trim(A_LoopField),"is)``.|""""","#")
			if StrLen(forCount)>minStrCount || !RegExMatch(forCount, "^""[^""]*""$")
				output.="sendByClipboard(" Trim(A_LoopField) ")`n"
			else
				output.="send % " Trim(A_LoopField) "`n"
		}
	}
	
	
	return SubStr(output,1,-1)	
}

str2clip(script, Mode=0, indent=""){
	str:=""
	if(Mode=0){
		return RegExReplace(toStrArr(script, 0), "\n", "`n" indent)
	}else if(Mode=1){ ;no variable
		return RegExReplace(toStrArr(script, 1), "\n", "`n" indent)
	
	}else if(Mode=2){
		Text:=doublingQuote(indent script)
		if CountExpStrLen(Text)<minStrCount
			return "send, `n(`n" Text "`n" ")"
		else
			return "sendByclipboard(""`n(`n" Text "`n" ")"")"
	}
	
	
}