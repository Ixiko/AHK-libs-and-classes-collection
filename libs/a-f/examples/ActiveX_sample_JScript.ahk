#include %A_ScriptDir%\ActiveX.ahk
ActiveX()

;JScript �̃R�[�h�𖄂ߍ���script=
(
	for(var i=5;i>0;i--){
		sapi.Speak(i+",");
	}
	sapi.Speak("0!");
)

sc:=CreateObject("MSScriptControl.ScriptControl.1")
pp(sc,"Language","jscript")

sapi:=CreateObject("Sapi.SpVoice")
inv(sc,"AddObject","sapi",vObj(sapi))

inv(sc,"Eval",script)

