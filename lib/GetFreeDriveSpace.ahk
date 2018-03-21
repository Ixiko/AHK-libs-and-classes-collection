/*
Func: GetFreeDriveSpace
    Returns available drive space in GB's

Parameters:
    fPath		- Path to any file or folder on target drive

Returns:
    Available drive space in GB's, rounded by 2 numbers after the decimal
	
Examples:
    > GetFreeDriveSpace(A_Temp)
    =	18.68
*/

GetFreeDriveSpace(fPath) {
	If !( InStr( FileExist(fPath), "D") )
		return -1

	SplitPath, % fPath, , , , , dDrive
	DriveSpaceFree, dSpace, % dDrive

	dSpace := Round(dSpace / 1000, 2)
	
	return dSpace
}