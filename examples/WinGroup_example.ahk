;Example for WinGroup.ahk
;https://www.autohotkey.com/boards/viewtopic.php?t=60272
#include %A_ScriptDir%\..\lib-i_to_z\WinGroup.ahk

GroupAdd("mediaPlayers", "ahk_exe vlc.exe", "ahk_exe mpc-hc.exe")
;GroupDelete("mediaPlayers")

;create new group and make it a 'real' group...
GroupAdd("browsers", "ahk_exe chrome.exe", "ahk_exe firefox.exe")GroupTranspose("browsers")
SetTimer, listGroups, 300
;toogle group member
x::IsInGroup("mediaPlayers","vlc.exe") ? GroupDelete("mediaPlayers", "ahk_exe vlc.exe") : GroupAdd("mediaPlayers", "ahk_exe vlc.exe")

;(de)activate a group... of course group members can't be removed from the transposed 'real' group,only from the custom group they were inherited from...
a::GroupActivate % GroupTranspose("browsers")
d::GroupDeactivate % GroupTranspose("browsers")

#If GroupActive("mediaPlayers")
g::MsgBox 0x40040,, MEDIA PLAYER GROUP ACTIVE
#If

#IfWinActive ahk_group browsers	;Custom Group transformed to real group...
g::MsgBox 0x40040,, BROWSER GROUP ACTIVE
#IfWinActive

listGroups:
ToolTip % A_Groups "`n`n" GroupActive("mediaPlayers") "`n" GroupActive("browsers")
Return