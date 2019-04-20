#Persistent
;#Warn All
;#Warn LocalSameAsGlobal, Off
#SingleInstance force

#Include %A_ScriptDir%\..\lib\cGithub.ahk
#Include %A_ScriptDir%\lib\JSON.ahk
#Include %A_ScriptDir%\lib\ObjTree.ahk

OutputDebug DBGVIEWCLEAR

; #################################################################################################
; Read the Configuration and extract the data
settings := A_ScriptDir "/settings.xml"
comXml:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
comXml.load(settings)
eMail:=comXml.SelectSingleNode("/Settings/github/@email").value
name:=comXml.SelectSingleNode("/Settings/github/@name").value
token:=comXml.SelectSingleNode("/Settings/github/@token").value

; #################################################################################################
gh := new github(name, email, token)

x := gh.repos.user_repos()
MsgBox % x
; xx := JSON.Load( x, true )
; WinWaitClose % "ahk_id " ObjTree(xx, "All github-Users (json)")

ExitApp
