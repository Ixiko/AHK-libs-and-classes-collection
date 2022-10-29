#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetBatchLines -1
FileSelectFolder, Folder, , % (Del:=0), Purge Empty Folders
If ( ErrorLevel Or Folder="" )
  Return
Loop, %Folder%\*, 2, 1
  FL .= ((FL<>"") ? "`n" : "" ) A_LoopFileFullPath
Sort, FL, R D`n ; Arrange folder-paths inside-out
Loop, Parse, FL, `n
{
  FileRemoveDir, %A_LoopField% ; Do not remove the folder unless is  empty
  If ! ErrorLevel
       Del := Del+1,  RFL .= ((RFL<>"") ? "`n" : "" ) A_LoopField
}
MsgBox, 64, Empty Folders Purged : %Del%, %RFL%