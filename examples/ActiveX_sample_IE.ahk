#Persistent

#include %A_ScriptDir%\ActiveX.ahk

;初期化
ActiveX()

;オブジェクト作成
ie:=CreateObject("InternetExplorer.Application")


;プロパティへの書き込み
pp(ie,"Visible","true")

;メソッド呼び出し
inv(ie,"Navigate","about:blank")

;プロパティオブジェクトの取得
doc:=gp(ie,"Document")
win:=gp(doc,"parentWindow")

inv(doc,"write","Hello!<br><br>")

;イベントの割り当て
ConnectObject(doc,"Document_")
ConnectObject(win,"Window_")

;オブジェクト解放
Release(doc)
Release(win)
Release(ie)
return

;イベントに割り当てられる関数
Document_onfocusin(this,prm,res){
	inv(this,"write","focuse in<br>")
}
Document_onfocusout(this,prm,res){
	inv(this,"write","focuse out<br>")
}
Window_onbeforeunload(this,prm,res){
	MsgBox,閉じます
	SetTimer,quit,-100
}
quit:
ExitApp


