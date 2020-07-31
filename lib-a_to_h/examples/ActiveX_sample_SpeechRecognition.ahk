#Persistent
#include *i %A_ScriptDir%\ActiveX.ahk
ActiveX()

sr:=CreateObject("SAPI.SpSharedRecognizer")

context:=inv(sr,"CreateRecoContext")
grammar:=inv(context,"CreateGrammar")
inv(grammar,"DictationSetState",0)
rules:=gp(grammar,"Rules")

rule:=inv(rules,"Add","wordsRule",33,0)
inv(rule,"Clear")

init:=gp(rule,"InitialState")
AddWord(init,"close")
AddWord(init,"yes")
AddWord(init,"no")
AddWord(init,"ok")
AddWord(init,"cancel")

inv(rules,"Commit")
inv(grammar,"CmdSetRuleState","wordsRule",1)
inv(rules,"Commit")

ConnectObject(context,"SR_")
ReleaseL(sr,context,grammar,rule,init)

AddWord(pState,word){
	inv(pState,"AddWordTransition",vNull(),word)
}
SR_Recognition(this,prm,r){
	result:=evArgv(prm,3)
	pi:=gp(result,"PhraseInfo")
	txt:=inv(pi,"GetText")
	if txt=yes
		Send,!y
	else if txt=no
		Send,!n
	else if txt=ok
		ControlClick,OK,A
	else if txt=cancel
		ControlClick,ƒLƒƒƒ“ƒZƒ‹,A
	else if txt=close
		WinClose,A
	Release(pi)
}






