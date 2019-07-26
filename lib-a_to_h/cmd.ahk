/*
Func: cmd_exec
    Runs command line commands in hidden command line window

Parameters:
	cmd		-	Command

Returns:
	-

Examples:
    > cmd_exec(" RD /S /Q """ SourceDir """ ")
	=	Folder "e:\temp\myOtherFolder" and all contents including subfolders get deleted
*/
cmd_exec(cmd) {
	DetectHiddenWindows, On
	
	run %comspec% /C %cmd%,, Hide, cmdPID
	
	WinWait, % "ahk_pid " cmdPID, , 2 ; comspec will have fully booted after 2 seconds, and will have completed its action otherwise
	WinWaitClose, % "ahk_pid " cmdPID
}

/*
Func: cmd_fileCopy
    Copies file using robocopy

Parameters:
	SourceFile	-	The name of a single file
    DestDir 	-	Specifies the path to the destination directory

Returns:
	-

Examples:
    > cmd_fileCopy("e:\temp\myfile2.txt", "e:\temp\anotherfolder\")
	=	myfile2.txt gets copied from "e:\temp" into "e:\temp\anotherfolder"
*/
cmd_fileCopy(SourceFile, DestDir) {
	If !fileExist(SourceFile) or !( InStr( FileExist(DestDir), "D") )
		return ErrorLevel := 1
	
	DestDir := RTrim(DestDir, "\")
	
	SplitPath, SourceFile, SourceFileName, SourceDir
	
	cmd_exec("robocopy """ SourceDir """ """ DestDir """ """ SourceFileName """ ")
}

/*
Func: cmd_fileMove
    Moves file using robocopy

Parameters:
	SourceFile	-	The name of a single file
    DestDir 	-	Specifies the path to the destination directory

Returns:
	-

Examples:
    > cmd_fileMove("e:\temp\myfile2.txt", "e:\temp\anotherfolder\")
	=	myfile2.txt gets moved from "e:\temp" into "e:\temp\anotherfolder"
*/
cmd_fileMove(SourceFile, DestDir) {
	If !fileExist(SourceFile) or !( InStr( FileExist(DestDir), "D") )
		return ErrorLevel := 1
	
	DestDir := RTrim(DestDir, "\")
	
	SplitPath, SourceFile, SourceFileName, SourceDir
	
	cmd_exec("robocopy """ SourceDir """ """ DestDir """ """ SourceFileName """ /move")
}

/*
Func: cmd_fileDelete
    Delete files using command line "DEL" command

Parameters:
	SourceFile	-	The name of a single file

Returns:
	-

Examples:
    > cmd_fileDelete("e:\temp\myfile2.txt")
	=	myfile2.txt gets deleted
*/
cmd_fileDelete(SourceFile) {
	If !fileExist(SourceFile)
		return ErrorLevel := 1
	
	cmd_exec("DEL /F """ SourceFile """ ")
}

/*
Func: cmd_fileCopyDir
    Copies folder using robocopy

Parameters:
	SourceDir	-	Specifies the path to the source directory
    DestDir 	-	Specifies the path to the destination directory

Returns:
	-

Examples:
    > cmd_fileCopyDir("e:\temp", "e:\temp\testfolder")
	=	Contents including subfolders of "e:\temp" get copied into "e:\temp\testfolder"
*/
cmd_fileCopyDir(SourceDir, DestDir) {
	If !( InStr( FileExist(SourceDir), "D") )
		return ErrorLevel := 1
	
	SourceDir := RTrim(SourceDir, "\")
	DestDir := RTrim(DestDir, "\")
	
	cmd_exec("robocopy """ SourceDir """ """ DestDir """ /e")
}

/*
Func: cmd_fileMoveDir
    Moves folder using robocopy

Parameters:
	SourceDir	-	Specifies the path to the source directory
    DestDir 	-	Specifies the path to the destination directory

Returns:
	-

Examples:
    > cmd_fileMoveDir("e:\temp\myfolder", "e:\temp\myOtherFolder")
	=	Contents including subfolders of "e:\temp" get moved into "e:\temp\testfolder"
		and "e:\temp\myfolder" gets deleted once copying is finished
*/
cmd_fileMoveDir(SourceDir, DestDir) {
	If !( InStr( FileExist(SourceDir), "D") )
		return ErrorLevel := 1
	
	SourceDir := RTrim(SourceDir, "\")
	DestDir := RTrim(DestDir, "\")
	
	cmd_exec("robocopy """ SourceDir """ """ DestDir """ /e /move")
}

/*
Func: cmd_fileRemoveDir
    Deletes folder and its subfolders using command line "RD" command

Parameters:
	SourceDir	-	Specifies the path to the source directory

Returns:
	-

Examples:
    > cmd_fileRemoveDir("e:\temp\myOtherFolder")
	=	Folder "e:\temp\myOtherFolder" and all contents including subfolders get deleted
*/
cmd_fileRemoveDir(SourceDir) {
	If !( InStr( FileExist(SourceDir), "D") )
		return ErrorLevel := 1
	
	SourceDir := RTrim(SourceDir, "\")
	
	cmd_exec(" RD /S /Q """ SourceDir """ ")
}