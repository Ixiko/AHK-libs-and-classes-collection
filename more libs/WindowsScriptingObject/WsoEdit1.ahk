; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=60903&hilit=createForm&sid=da4b6b3a472c35848194cd9df22b03db
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include ActiveScript.ahk

SetTitleMatchMode, 2

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

wo := new ActiveScript("VBScript")

code =
(
'WindowSystemObject (WSO) example
'Copyright (C) Veretennikov A. B. 2004

Set o = CreateObject("Scripting.WindowSystemObject")

Set f = o.CreateForm(0,0,650,400)
f.CenterControl()

Sub MouseMove(this,x,y,flags)
	this.Form.StatusBar.item(0).Text = CStr(x)+" x "+CStr(y)
End Sub

Sub MouseExit(this)
	this.Form.StatusBar.item(0).Text = "No Mouse In Control"
End Sub

Sub MouseUp(this,x,y,Button,Flags)
	this.Form.MessageBox "MouseUp "+CStr(x)+" x "+CStr(y)+", Button = "+CStr(Button)
End Sub

Sub KeyDown(this,Key,Flags)
	If ((Key <> 27) And (Key <> 112)) Then this.Form.MessageBox "KeyDown "+CStr(Key)
End Sub

Sub ButtonClick(this)
	this.Form.MessageBox "Button "+this.Text+": OnClick"
End Sub

int CanCloseVar

Sub OKResult(this)
	CanCloseVar = 1
	this.Form.Close()
End Sub

Function CanClose(Sender,Result)

CanCloseVar = 0

Set CanCloseDialog = f.CreateDialogForm(0,0,510,100)
CanCloseDialog.CenterControl()
CanCloseDialog.TextOut 10,10,"Do you really want to quit this program?"

Set YesButton = CanCloseDialog.CreateButton(10,30,75,25,"Yes")
YesButton.OnClick = GetRef("OKResult")
YesButton.Default = true

Set NoButton = CanCloseDialog.CreateButton(90,30,75,25,"No")
NoButton.OnClick = GetRef("CloseFormHandler")
NoButton.Cancel = true

Set HelpButton = CanCloseDialog.CreateButton(170,30,75,25,"Help")
HelpButton.OnClick = GetRef("HelpAbout")

CanCloseDialog.HelpButton = HelpButton
CanCloseDialog.Color = &H00FF00FF
CanCloseDialog.ShowModal()
CanCloseDialog.Destroy()

If CanCloseVar = 1 Then Result.Put(true) Else Result.Put(false)

End Function

Set Button = f.CreateButton(10,10,75,25,"Demo")

Button.AddEventHandler "OnClick",GetRef("ButtonClick")

Set CancelButton = f.CreateButton(100,10,75,25,"Close")
CancelButton.OnClick = GetRef("CloseFormHandler")

f.CreateStatusBar().Name = "StatusBar"
f.StatusBar.Add(100).AutoSize = true
f.OnMouseMove = GetRef("MouseMove")
f.OnMouseLeave = GetRef("MouseExit")
f.OnMouseUp = GetRef("MouseUp")
f.OnKeyDown = GetRef("KeyDown")
f.OnCloseQuery = GetRef("CanClose")

Set Text1 = f.TextOut(10,60,"WindowSystemObject")
Text1.Font.Size = 16
Text1.Color = 255
Text1.Font.Bold = true

f.TextOut 10,100,"This sample shows how to handle events from WindowsSystemObject using VBScript."+vbCr+vbCr+"Clicking any mouse button invokes OnMouseUp event handler."+vbCr+vbCr+"Moving mouse inside this window invokes OnMouseMove event handler."+vbCr+vbCr+"(The current mouse position is displayed in the status bar)"+vbCr+vbCr+"Moving mouse outside this window invokes OnMouseLeave event handler."+vbCr+vbCr+"Clicking Demo or Close buttons invokes OnClick event handler."+vbCr+vbCr+"Pressing any key invokes OnKeyDown event handler."+vbCr+vbCr+"Try to close this window to invoke OnCloseQuery event."

Set FileMenu = f.Menu.Add("File")
FileMenu.Add("Exit",27).OnExecute = GetRef("CloseFormHandler")

Set HelpMenu = f.Menu.Add("Help")
HelpMenu.Add("About","F1").OnExecute = GetRef("HelpAbout")

f.Show()

o.Run()

Sub HelpAbout(Sender)
	o.About()
End Sub

Function StartupDir()
	Dim s
	s = WScript.ScriptFullName
	s = Left(s,InStrRev(s,"\"))
	StartupDir = s
End Function

Sub WSOHelp(Sender)
	Set shell = WScript.CreateObject("WScript.Shell")
	shell.Run """"+StartupDir() + "..\..\wso.chm"+""""
End Sub

Sub AboutWSO_OnHitTest(Sender,x,y,ResultPtr)	
	ResultPtr.put(o.Translate("HTCAPTION"))
End Sub

Sub CloseFormHandler(Sender)
	Sender.Form.Close()
End Sub
 )
 
wo.Exec(code)


return


ShowInfo(object, objname) {
vartype := ComObjType(object)
name := ComObjType(object, "Name")
clsid := ComObjType(object, "CLSID")
cname := ComObjtype(object, "Class")
msgbox %objname%'s class is %cname%`r`nName is %name%`r`nCLSID is %clsid%`r`nVT is %vartype%
}


/*
[System.Windows.MessageBox]::Show('Would  you like to play a game?','Game input','YesNoCancel','Error')
*/

Escape::ExitApp


;ATL:00000001801D89401 ; Button's ClassNN according to WindowSpy

/*
---------------------------
WSO4.ahk
---------------------------
button's class is Button

Name is IButton

CLSID is {0DE86A81-8827-4281-8C0C-965C34F25147}

VT is 9
---------------------------
OK   
---------------------------
*/