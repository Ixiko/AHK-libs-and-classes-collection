#Persistent
;#Warn All
;#Warn LocalSameAsGlobal, Off
#SingleInstance force

#Include %A_ScriptDir%\lib\ObjTree.ahk
#Include %A_ScriptDir%\lib\JSON.ahk
#Include %A_ScriptDir%\..\lib\cGithub.ahk

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

x := gh.orgs.user_orgs()
WinWaitClose % "ahk_id " ObjTree(ParseJson( x ), "List organizations for the authenticated user.")

x := gh.orgs.organizations()
WinWaitClose % "ahk_id " ObjTree(ParseJson( x ), "List all organizations.")

x := gh.orgs.members.getOrganizationMembers("ahkscript")
WinWaitClose % "ahk_id " ObjTree(ParseJson( x ), "List all users who are members of an organization.")
ExitApp
