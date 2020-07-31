#Persistent

#include %A_ScriptDir%\ActiveX.ahk

;������
ActiveX()

;�I�u�W�F�N�g�쐬
ie:=CreateObject("InternetExplorer.Application")


;�v���p�e�B�ւ̏�������pp(ie,"Visible","true")

;���\�b�h�Ăяo��
inv(ie,"Navigate","about:blank")

;�v���p�e�B�I�u�W�F�N�g�̎擾
doc:=gp(ie,"Document")
win:=gp(doc,"parentWindow")

inv(doc,"write","Hello!<br><br>")

;�C�x���g�̊��蓖��ConnectObject(doc,"Document_")
ConnectObject(win,"Window_")

;�I�u�W�F�N�g��Release(doc)
Release(win)
Release(ie)
return

;�C�x���g�Ɋ��蓖�Ă�����
Document_onfocusin(this,prm,res){
	inv(this,"write","focuse in<br>")
}
Document_onfocusout(this,prm,res){
	inv(this,"write","focuse out<br>")
}
Window_onbeforeunload(this,prm,res){
	MsgBox,���܂�
	SetTimer,quit,-100
}
quit:
ExitApp


