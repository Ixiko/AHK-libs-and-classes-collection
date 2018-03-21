/*
Func: GetFileFolderSize
    Get folder or file size in GBs

Parameters:
    fPath         - Path to file or folder

Returns:
    Folder or file size in GBs. -1 if path is invalid
	
Examples:
    > msgbox % GetFileFolderSize(A_Temp) 
    = Messagebox with temp folder size
	
Required libs:
	-
*/
GetFileFolderSize(fPath) 
{
	if InStr(FileExist(fPath), "D") 
	{
		Loop, %fPath%\*.*, 1, 1
			FolderSize += %A_LoopFileSize%
		Size := % FolderSize ? FolderSize : 0
		Return, Round(Size/1024**3, 2)
	}
	else if (FileExist(fPath) <> "") 
	{
		FileGetSize, FileSize, %fPath%
		Size := % FileSize ? FileSize : 0
		Return, Round(Size/1024**3, 2)
	} 
	else
		Return, -1
}