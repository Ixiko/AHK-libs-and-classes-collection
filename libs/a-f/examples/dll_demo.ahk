; #Include dll.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; First specify a folder, from which to include all files into the DLL.
folderToPack := A_ScriptDir . "\newFiles"

; Fill the folder with files.
FileCreateDir, %folderToPack%
Loop, ..\*.txt
{
	FileCopy, %A_LoopFileFullPath%, %folderToPack%, 1
}

; Create the DLL from that folder.
Dll_PackFiles( folderToPack . "\", "newFiles.DLL", "Text Files" )

; Get content of file into variable.
Dll_Read( Var, "newFiles.dll", "Text Files", "COPYING.txt" )
MsgBox %Var%