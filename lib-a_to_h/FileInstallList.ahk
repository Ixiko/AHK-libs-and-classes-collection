/*
Func: FileInstallList
	Builds a list of FileInstall and FileCreateDir commands

Parameters:
    FI_source		-	Source folder path
    FI_dest			-	Desination folder path
    FI_overwrite	-	(optional) this flag determines whether to overwrite files if they already exist

Returns:
	List with FileInstall and FileCreateDir commands
	
Examples:
    > FileAppend, % FileInstallList(A_ScriptDir "\res", "`% A_Temp ""\0125vpk", 0), % A_ScriptDir "\fileInstallList.ahk"
    =	Writes file "A_ScriptDir\fileInstallList.ahk" with FileInstall and FileCreateDir commands to write
		the contents of "A_ScriptDir\res" into "A_Temp\0125vpk" when the files do not exist
*/
FileInstallList(FI_source, FI_dest, FI_overwrite="") {
	loop, % FI_source "\*.*", 1, 1
	{
		StringReplace, FI_cDest, A_LoopFileFullPath, % FI_source, % FI_dest, All ; build FI_cDest path by replacing FI_source with FI_dest path
		
		If !( InStr( FileExist(FI_dest), "D") )
			FI_cDest := FI_cDest """" ; add quote at the end since FI_dest is interpreted as text rather than folder eg: % A_ScriptDir "\res\steam\vpk.exe

		If ( InStr( FileExist(A_LoopFileFullPath), "D") )
			FI_list := FI_list "`n" "FileCreateDir, " FI_cDest ; add FileCreateDir if  A_LoopFileFullPath is a directory
		else ; otherwise add FileInstall line
		{
			If (FI_overwrite = "1")
				FI_list := FI_list "`n" "FileInstall, " A_LoopFileFullPath ", " FI_cDest ", 1"
			If (FI_overwrite = "0") or (FI_overwrite = "")
				FI_list := FI_list "`n" "FileInstall, " A_LoopFileFullPath ", " FI_cDest ", 0"
		}
	}
	return FI_list
}