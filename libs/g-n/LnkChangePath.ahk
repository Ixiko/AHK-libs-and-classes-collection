;LnkChangePath("E:\Users\Lyh\Desktop\chrome.exe.lnk","D:\", "E:\", 0)

LnkChangePath(LinkFile, OldPathStr:="", NewPathStr:="", Back:=0)
{
if Back
	FileCopy, % LinkFile, % LinkFile ".bak"
FileGetShortcut, % LinkFile, , , , , OutIcon, OutIconNum

SplitPath, LinkFile, OutFileName, OutDir
shell := ComObjCreate("Shell.Application")
Folder := shell.NameSpace(OutDir)
FolderItem := Folder.ParseName(OutFileName)
ShellLinkObject := FolderItem.GetLink()

if Instr(ShellLinkObject.Path, OldPathStr)
	ShellLinkObject.Path := StrReplace(ShellLinkObject.Path, OldPathStr, NewPathStr)
if Instr(ShellLinkObject.WorkingDirectory, OldPathStr)
	ShellLinkObject.WorkingDirectory := StrReplace(ShellLinkObject.WorkingDirectory, OldPathStr, NewPathStr)
if Instr(ShellLinkObject.Arguments, OldPathStr)
	ShellLinkObject.Arguments := StrReplace(ShellLinkObject.Arguments, OldPathStr, NewPathStr)
if Instr(OutIcon, OldPathStr)
	OutIcon := StrReplace(OutIcon, OldPathStr, NewPathStr)

ShellLinkObject.SetIconLocation(OutIcon, OutIconNum - 1)
ShellLinkObject.Save
return
}

LnksChangePath(LinkFile, OldPathStr:="", NewPathStr:="")
{
	if CF_IsFolder(LinkFile)
		OutDir := LinkFile
	else
		SplitPath, LinkFile, , OutDir
	Loop, Files, %OutDir%\*.lnk, R
	{
		LnkChangePath(A_LoopFileFullPath, OldPathStr, NewPathStr)
	}
	return
}
