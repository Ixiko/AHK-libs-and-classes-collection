; #Include Mount.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Select source folder
FileSelectFolder, SourcePath, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 3, Select folder to mount

If (ErrorLevel = 0)
{
	; Mount to first free drive
	path := Mount(SourcePath)

	; Open that drive and wait until MsgBox is closed for unmount
	MsgBox %SourcePath% mounted to %path%
}

Mount_GetMountPathes(pathes)
If (pathes != "")
{
	MsgBox, 4,, Unmount all these mounts?`n`n%pathes%
	IfMsgBox, Yes
	{
		Loop, Parse, pathes, `n
		{
			StringLeft, path, A_LoopField, 1
			If (path)
			{
				Mount_UnMount(path)	
			}
		}
	}
}